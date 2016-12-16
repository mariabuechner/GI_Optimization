source('GI_Optimization.R')

shinyServer(function(input, output) {
  # Geometry #
  
  # Calculate all GI parameters
  inputGI <- reactive({
    # Select samlles pitch based on geometry type
    if (input$geometry == "Inverse") {
      smallestPitch = input$g0Pitch
    }
    else {
      smallestPitch = input$g2Pitch
    }
    
    # Returns list with all params inside
    geometry.calcParameters(input$designEnergy, input$talbotOrder, input$geometry, smallestPitch,
                            input$G0G1Length, input$piHalfShift)
  })
  
  # Output:
  output$geometryImage <- renderImage({
    # When input$n is 3, filename is ./images/image3.jpeg
    filename <- normalizePath(file.path('./www',
                                        paste(input$geometry, '.jpg', sep='')))
    
    # Return a list containing the filename and alt text
    list(src = filename,
         width = 300)
    
  }, deleteFile = FALSE)
  
  outputPitches <- reactive({
    pitches = data.frame(inputGI()$p0, inputGI()$p1, inputGI()$p2)
    colnames(pitches) <- c("p0 [um]", "p1 [um]", "p3 [um]")
    return(pitches)
  })
  outputDistances <- reactive({
    distances = data.frame(inputGI()$G0G1, inputGI()$G1G2, inputGI()$systemLength)
    colnames(distances) <- c("l [mm]", "d [mm]", "s [mm]")
    return(distances)
  })
  output$pitchTable <- renderTable({
    outputPitches()
  }, include.rownames=FALSE)
  output$distancesTable <- renderTable({
    outputDistances()
  }, include.rownames=FALSE)
#   output$p0 <- renderText({
#     paste("G0 pitch [um]:", inputGI()$p0)
#   })
#   output$p1 <- renderText({
#     paste("G1 pitch [um]:", inputGI()$p1)
#   })
#   output$p2 <- renderText({
#     paste("G2 pitch [um]:", inputGI()$p2)
#   })
#   output$talbotDistance <- renderText({
#     paste("Talbot distance [mm]:", inputGI()$talbotDistance)
#   })
#   output$l <- renderText({
#     paste("l (distance G0 to G1) [mm]:", inputGI()$G0G1)
#   })
#   output$d <- renderText({
#     paste("d (distance G1 to G2) [mm]:", inputGI()$G1G2)
#   })
#   output$s <- renderText({
#     paste("s (total system length) [mm]:", inputGI()$systemLength)
#   })
  
  calcTotalSystemLength <- reactive({
    samplePosition = input$sourceG0Distance + inputGI()$G0G1 + input$g1SampleDistance + input$sampleDiameter/2
    return(2*samplePosition)
  })
  
  output$totalSystemLength <- renderText({
    calcTotalSystemLength()
  })
  
  output$g2DetectorDistance <- renderText({
    sourceToDetector = inputGI()$systemLength + input$sourceG0Distance
    return(calcTotalSystemLength()-sourceToDetector)
  })
  
  output$transversalCoherenceLength <- renderText({
    # wavelength [um] * G0G1Distance [mm] / sourceSize [um]
    geometry.calcWavelength(input$designEnergy) * inputGI()$G0G1*1000 / (inputGI()$p0 / 2)
  })
  output$beamSeperation <- renderText({
    # TalbotOrder * p1 / 4 [um]
    input$talbotOrder * inputGI()$p1 / 4
  })
  
#   output$waveLengthUM <- renderText({
#     geometry.calcWavelength(input$designEnergy)
#   })
  
  ################################################
  # Filter and sample #
  
  # Read spectrum
  inputSpectrum <- reactive({
    visibility.readSpectrum(input$spectrum)
  })
  
  # Filter
  inputFilter <- reactive({
    filtering.readFilter(paste("filters/",input$filter,sep=""))
  })
  filterSpectrum <- reactive({
    filtering.filterEnergies(inputFilter(), input$filterThickness, inputSpectrum()$energy, inputSpectrum()$photons)
  })
  
  # Sample
  inputSample <- reactive({
    filtering.readFilter(paste("samples/mu/",input$sample,sep=""))
  })
  sampleSpectrum <- reactive({
    spectrum = inputSpectrum()
    if (input$includeFilterVisibility == TRUE) {
      spectrum = filterSpectrum()
    }
    filtering.filterEnergies(inputSample(), input$sampleThickness, spectrum$energy, spectrum$photons)
  })
  
#   # Filter
#   inputFilter <- reactive({
#     filter = filtering.readFilter(paste("filters/",input$filter,sep=""))
#     interpolatedFilter = filtering.interpolateFilter(filter, inputSpectrum()$energy)
#   })
#   filterSpectrum <- reactive({
#     filtering.filterEnergies(inputFilter(), input$filterThickness, inputSpectrum()$photons)
#   })
#   
#   # Sample
#   inputSample <- reactive({
#     sample = filtering.readFilter(paste("samples/mu/",input$sample,sep=""))
#     interpolatedSample = filtering.interpolateFilter(sample, filterSpectrum()$energy)
#   })
#   sampleSpectrum <- reactive({
#     filtering.filterEnergies(inputSample(), input$sampleThickness, filterSpectrum()$photons)
#   })
  
  # Get current spectrum
  currentSpectrum <- reactive({
    spectrum = inputSpectrum()
    if (input$includeFilterVisibility == TRUE) {
      spectrum = filterSpectrum()
    }
    if (input$includeSampleVisibility == TRUE) {
      spectrum = sampleSpectrum()
    }
    return(spectrum)
  })
  
  # Output:
  
  output$MeanEnergy <- renderText({
    sum(inputSpectrum()$energy*inputSpectrum()$photons)/sum(inputSpectrum()$photons)
  })
  output$filterMeanEnergy <- renderText({
    sum(filterSpectrum()$energy*filterSpectrum()$photons)/sum(filterSpectrum()$photons)
  })
  output$sampleMeanEnergy <- renderText({
    sum(sampleSpectrum()$energy*sampleSpectrum()$photons)/sum(sampleSpectrum()$photons)
  })
  
  output$filteredSpectrumCompared <- renderPlot({
    ggplot(NULL, aes_string(x='energy', y='photons')) +
      scale_y_continuous(labels=percent) +
      labs(x="Energy [keV]",y="Photon density / 1.0 [kev]",title=expression(paste("Filtered X-ray spectrum ", omega,"(",epsilon,")"))) +
      geom_bar(aes(fill = "Original"), data = inputSpectrum(), width=.5, stat="identity", fill='blue') +
      geom_bar(aes(fill = "Filtered"), data = filterSpectrum(), width=.5, stat="identity", fill='red')
  })
  output$filteredSpectrum <- renderPlot({
    ggplot(NULL, aes_string(x='energy', y='photons')) +
      scale_y_continuous(labels=percent) +
      labs(x="Energy [keV]",y="Photon density / 1.0 [kev]",title=expression(paste("X-ray spectrum after filter ", omega,"(",epsilon,")"))) +
      geom_bar(aes(fill = "Filtered"), data = filterSpectrum(), width=.5, stat="identity", fill='red')
  })
  
  output$sampledSpectrumCompared <- renderPlot({
    ggplot(NULL, aes_string(x='energy', y='photons')) +
      scale_y_continuous(labels=percent) +
      labs(x="Energy [keV]",y="Photon density / 1.0 [kev]",title=expression(paste("Filtered X-ray spectrum ", omega,"(",epsilon,")"))) +
      geom_bar(aes(fill = "Original"), data = inputSpectrum(), width=.5, stat="identity", fill='blue') +
      geom_bar(aes(fill = "Sample"), data = sampleSpectrum(), width=.5, stat="identity", fill='red')
  })
  output$sampledSpectrum <- renderPlot({
    ggplot(NULL, aes_string(x='energy', y='photons')) +
      scale_y_continuous(labels=percent) +
      labs(x="Energy [keV]",y="Photon density / 1.0 [kev]",title=expression(paste("X-ray spectrum after filter and sample ", omega,"(",epsilon,")"))) +
      geom_bar(aes(fill = "Sample"), data = sampleSpectrum(), width=.5, stat="identity", fill='red')
  })
  
  ################################################

  # Visibility #
  
  # Calc visibilities
  visibilities <- reactive({
    visibility.calcVisibilities(input$designEnergy, input$talbotOrder, currentSpectrum()$energy, currentSpectrum()$photons)
  })
  
  absVisibilities <- reactive({
    visibility.calcAbsVisibilities(input$designEnergy, input$talbotOrder, currentSpectrum()$energy)
  })
  
  # Output:
  
  output$Spectrum <- renderPlot({
    normalizedSpectrum = currentSpectrum()
    normalizedSpectrum$photons = normalizedSpectrum$photons/sum(normalizedSpectrum$photons)
    ggplot(normalizedSpectrum,
           aes_string(x='energy', y='photons'))+
      geom_bar(width=.5, stat="identity", fill='blue')+
      scale_y_continuous(labels=percent)+
      labs(x="Energy [keV]",y="Photon density / 1.0 [kev]",title=expression(paste("X-ray spectrum ", omega,"(",epsilon,")")))
    
  })
  
  output$MaximumVisibility <- renderText({
    percent(visibility.maxVisibility(visibilities()))
  })
  
  output$Visibility <- renderPlot({
    visibilityInput = cbind(currentSpectrum()['energy'], vis = visibilities())
    ggplot(visibilityInput,
           aes_string(x='energy', y='vis'))+
      geom_bar(width=.5, stat="identity", fill='blue')+
      scale_y_continuous(labels=percent)+
      labs(x="Energy [keV]",y="Visibility",title=expression(paste("Visibility by energy ", nu,"(",epsilon,")", omega,"(",epsilon,")")))
    
  })
  
  output$MaxVisibilities <- renderPlot({
    MaximumVisibilities = visibility.MaxVisibilityEnergies(input$talbotOrder, currentSpectrum()$energy, currentSpectrum()$photons)
    maxVisibilityInput = cbind(currentSpectrum()['energy'], maxVis = MaximumVisibilities)
    ggplot(maxVisibilityInput,
           aes_string(x='energy', y='maxVis'))+
      geom_bar(width=.5, stat="identity", fill='blue')+
      scale_y_continuous(labels=percent)+
      labs(x="Design Energy [keV]",y="Maximum Visibility",title=paste("Maximum visibility at fixed talbot order: m =", input$talbotOrder))
    
  })
  
  output$OptTablotOrders <- renderDataTable({
    maxVisibilityTable = visibility.MaxVisibilityTalbots(list(1, 3, 5, 7), input$designEnergy,
                                                         currentSpectrum()$energy, currentSpectrum()$photons)
  },
  options = 
    list(searching=FALSE, paging=FALSE, info=FALSE))
  
  ############ PERFORMANCE ##########################
  
  output$raupachImage <- renderImage({
    # When input$n is 3, filename is ./images/image3.jpeg
    filename <- normalizePath(file.path('./www',
                                        paste("RaupachAdapted", '.jpg', sep='')))
    
    # Return a list containing the filename and alt text
    list(src = filename,
         height = 150)
    
  }, deleteFile = FALSE)
  
  deltas <- reactive({
    performance.readDelta(paste("samples/delta/",input$sample,sep=""))
  })
  
#   calcMus <-function(tissueName, energies) {
#     filter = filtering.readFilter(paste("samples/mu/",tissueName,sep=""))
#     tissue = filtering.interpolateFilter(filter,energies)
#     mus <- tissue$mu[energies] * filter$density[1]
#     return(mus)
#   } DOES NOT WORK< DO IT MANUALLY FOR NOW>>>!!!!
  calcPhis <- function(tissueName, energies) {
    lambdas = geometry.calcWavelength(energies)
    deltas = performance.readDelta(paste("samples/delta/",tissueName,sep=""))
    deltas = deltas$delta[energies]
    phis = 2*pi*deltas/lambdas # [1/um]
    phis = phis * 10000 # [1/cm]
    return(phis)
  }
  
  currentPhotons <- reactive({
    photons = currentSpectrum()$photons
  })
  
#   output$testVar <- renderText({
#     #     currentSample = filtering.interpolateFilter(inputSample(),currentSpectrum()$energy)
#     #     mus = currentSample$mu[currentSpectrum()$energy] * inputSample()$density[1]
#     #     deltas = deltas()$delta[currentSpectrum()$energy]
#     #     lambdas = geometry.calcWavelength(currentSpectrum()$energy)
#     #     phis = 2*pi*deltas/lambdas # [1/um]
#     #     mus = mus*1e-4 # [1/um]
# #     currentSample = filtering.interpolateFilter(inputSample(), input$designEnergy)
# #     mu = currentSample$mu * inputSample()$density[1]
# #     delta = deltas()$delta[input$designEnergy]
# #     lambda = geometry.calcWavelength(input$designEnergy)
# #     mu = mu*1e-4
# #     phi = 2*pi*delta/lambda
# #     beta = mu*lambda/(4*pi)
# #     cbind(beta)
# #     #mu = calcMus(input$tissueA, input$designEnergy)
# #     filterA = filtering.readFilter(paste("samples/mu/",input$tissueA,sep=""))
# #     sampleA = filtering.interpolateFilter(filterA, input$designEnergy)
# #     muA = sampleA$mu * filterA$density[1]
# #     filterB = filtering.readFilter(paste("samples/mu/",input$tissueB,sep=""))
# #     sampleB = filtering.interpolateFilter(filterB, input$designEnergy)
# #     muB = sampleB$mu * filterB$density[1]
# #     mu = abs(muA-muB)
# #     #phi = abs(calcPhis(input$tissueA, input$designEnergy) - calcPhis(input$tissueB, input$designEnergy))
#     #designVisibility = visibility.MaxVisibilityEnergies(input$talbotOrder, input$designEnergy, 1)
#     #absVisibilities()
#     #photons = currentSpectrum()$photons
#     #photons = photons/sum(photons)
#     #sum(cnrRatios()*photons, na.rm=TRUE)
#     100*absVisibilities()
# })

#   calcDeltaMus <- reactive({
#     filterA = filtering.readFilter(paste("samples/mu/",input$tissueA,sep=""))
#     tissueA = filtering.interpolateFilter(filterA,currentSpectrum()$energy)
#     musA <- tissueA$mu[currentSpectrum()$energy] * filterA$density[1]
#     filterB = filtering.readFilter(paste("samples/mu/",input$tissueB,sep=""))
#     tissueB = filtering.interpolateFilter(filterB,currentSpectrum()$energy)
#     musB <- tissueB$mu[currentSpectrum()$energy] * filterB$density[1]
#     return(abs(musA-musB))
#   })
#   
#   calcDeltaPhis <- reactive({
#     lambdas = geometry.calcWavelength(currentSpectrum()$energy)
#     deltasA = performance.readDelta(paste("samples/delta/",input$tissueA,sep=""))
#     deltasA = deltasA$delta[currentSpectrum()$energy]
#     phisA = 2*pi*deltasA/lambdas # [1/um]
#     phisA = phisA * 10000 # [1/cm]
#     deltasB = performance.readDelta(paste("samples/delta/",input$tissueB,sep=""))
#     deltasB = deltasB$delta[currentSpectrum()$energy]
#     phisB = 2*pi*deltasB/lambdas # [1/um]
#     phisB = phisB * 10000 # [1/cm]
#     return(abs(phisA-phisB))
#   })
  
  cnrRatios <- reactive({
    # Calc CNRs
    if (input$geometry == "Inverse") {
      distance = inputGI()$G0G1
      smallestPitch = inputGI()$p0
    }
    else {
      distance = inputGI()$G1G2
      smallestPitch = inputGI()$p2
    }
    lambdas = geometry.calcWavelength(currentSpectrum()$energy)
    
    filterA = filtering.readFilter(paste("samples/mu/",input$tissueA,sep=""))
    tissueA = filtering.interpolateFilter(filterA,currentSpectrum()$energy)
    musA <- tissueA$mu[currentSpectrum()$energy] * filterA$density[1]
    filterB = filtering.readFilter(paste("samples/mu/",input$tissueB,sep=""))
    tissueB = filtering.interpolateFilter(filterB,currentSpectrum()$energy)
    musB <- tissueB$mu[currentSpectrum()$energy] * filterB$density[1]
    mus = abs(musA-musB)
    #mus = abs(calcMus(input$tissueA, currentSpectrum()$energy) - calcMus(input$tissueB, currentSpectrum()$energy))
    phis = abs(calcPhis(input$tissueA, currentSpectrum()$energy) - calcPhis(input$tissueB, currentSpectrum()$energy))
    
    if (input$manualInput == TRUE) {
      vis = input$manualVis/100
    }
    else {
      vis = absVisibilities()
    }
    cnr = performance.calcCNRRatio(input$reconstructionFactor, input$pixelSize/2, input$postAttenuationFactor, vis, distance, smallestPitch, lambdas, mus, phis)
  })
  
  output$designVis <- renderText({
    visInput = cbind(currentSpectrum()['energy'], dVis=absVisibilities())
    visInputIndex = match(input$designEnergy, visInput$energy)
    vis = visInput$dVis[visInputIndex]
    return(vis*100)
  })
  
  output$meanctCnrRatio <- renderText({
    #mean(cnrRatios())
    photons = currentSpectrum()$photons/sum(currentSpectrum()$photons)
    sum(cnrRatios()*photons, na.rm=TRUE)
  })
  
  output$ctCnrRatio <- renderText({
#     if (input$manualInput == TRUE) {
#       MaximumVisibilities = visibility.MaxVisibilityEnergies(input$talbotOrder, currentSpectrum()$energy, currentSpectrum()$photons)
#       maxVisibilityInput = cbind(currentSpectrum()['energy'], maxVis = MaximumVisibilities)
#       designEnergyIndex = match(input$designEnergy, maxVisibilityInput$energy)
#       designVisibility = maxVisibilityInput$maxVis[designEnergyIndex]
#       #designVisibility = visibility.MaxVisibilityEnergies(input$talbotOrder, input$designEnergy, 1) # Not working correctly
#       if (input$geometry == "Inverse") {
#         distance = inputGI()$G0G1
#         smallestPitch = inputGI()$p0
#       }
#       else {
#         distance = inputGI()$G1G2
#         smallestPitch = inputGI()$p2
#       }
#       lambda = geometry.calcWavelength(input$designEnergy)
#       mu = input$deltaMu
#       phi = input$deltaPhi
#       cnrRatio = performance.calcCNRRatio(input$reconstructionFactor, input$pixelSize, input$postAttenuationFactor, designVisibility, distance, smallestPitch, lambda, mu, phi)
#     }
#     else {
#       cnrInput = cbind(currentSpectrum()['energy'], cnr=cnrRatios())
#       cnrInputIndex = match(input$designEnergy, cnrInput$energy)
#       cnrRatio = cnrInput$cnr[cnrInputIndex]
#     }
    cnrInput = cbind(currentSpectrum()['energy'], cnr=cnrRatios())
    cnrInputIndex = match(input$designEnergy, cnrInput$energy)
    cnrRatio = cnrInput$cnr[cnrInputIndex]
    return(cnrRatio)
  })
  
  output$cnrRatiosPlot <- renderPlot({
    # Plot
    ############
    # Calcs correct (wavelength?? etc)
    # Add real mu and phi values!
    cnrInput = cbind(currentSpectrum()['energy'], cnr=cnrRatios())
    ggplot(cnrInput,
           aes_string(x='energy', y='cnr'))+
      geom_bar(width=.5, stat="identity", fill='blue')+
      scale_y_continuous()+
      labs(x="Energy [keV]",y="CNRp/CNRa",title=expression(paste("CNR ratio by energy ")))
    
  })
  
})