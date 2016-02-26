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
         height = 300)
    
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
  
  ################################################
  # Filter and sample #
  
  # Read spectrum
  inputSpectrum <- reactive({
    visibility.readSpectrum(input$spectrum)
  })
  # Filter
  inputFilter <- reactive({
    filtering.readFilter(input$filter)
  })
  filterSpectrum <- reactive({
    filtering.filterEnergies(inputFilter(), input$filterThickness, inputSpectrum()$energy, inputSpectrum()$photons)
  })
  
#   # Sample
#   inputSample <- reactive({
#     filtering.readFilter(input$sample)
#   })
#   sampleSpectrum <- reactive({
#     filtering.filterEnergies(filterSpectrum(), input$sampleThickness, filterSpectrum()$energy, filterSpectrum()$photons)
#   })
  
  # Get current spectrum
  currentSpectrum <- reactive({
    spectrum = inputSpectrum()
    if (input$includeFilterVisibility == TRUE) {
      spectrum = filterSpectrum()
    }
#     if (input$includeSampleVisibility == TRUE) {
#       spectrum = sampleSpectrum()
#     }
    return(spectrum)
  })
  
  # Output:
  
  output$MeanEnergy <- renderText({
    mean(inputSpectrum()$energy*inputSpectrum()$photons*100)
  })
  output$filterMeanEnergy <- renderText({
    mean(filterSpectrum()$energy*filterSpectrum()$photons*100)
  })
#   output$sampleMeanEnergy <- renderText({
#     mean(sampleSpectrum()$energy*sampleSpectrum()$photons*100)
#   })
  
  output$filteredSpectrum <- renderPlot({
    ggplot(NULL, aes_string(x='energy', y='photons')) +
      scale_y_continuous(labels=percent) +
      labs(x="Energy [keV]",y="Photon density / 1.0 [kev]",title=expression(paste("Filtered X-ray spectrum ", omega,"(",epsilon,")"))) +
      geom_bar(aes(fill = "Original"), data = inputSpectrum(), width=.5, stat="identity", fill='blue') +
      geom_bar(aes(fill = "Filtered"), data = filterSpectrum(), width=.5, stat="identity", fill='red')
  })
#   output$sampledSpectrum <- renderPlot({
#     ggplot(NULL, aes_string(x='energy', y='photons')) +
#       scale_y_continuous(labels=percent) +
#       labs(x="Energy [keV]",y="Photon density / 1.0 [kev]",title=expression(paste("Filtered X-ray spectrum ", omega,"(",epsilon,")"))) +
#       geom_bar(aes(fill = "Original"), data = inputSpectrum(), width=.5, stat="identity", fill='blue') +
#       geom_bar(aes(fill = "Sample"), data = sampleSpectrum(), width=.5, stat="identity", fill='red')
#   })
  
  ################################################

  # Visibility #
  
  # Calc visibilities
  visibilities <- reactive({
    visibility.calcVisibilities(input$designEnergy, input$talbotOrder, currentSpectrum()$energy, currentSpectrum()$photons)
  })
  
  # Output:
  
  output$Spectrum <- renderPlot({
    ggplot(currentSpectrum(),
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
  
})