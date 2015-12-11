source('GI_Optimization.R')

shinyServer(function(input, output) {
  # Geometry #
  
  # 
  
  # Output:
  
  ################################################
  # Filter and sample #
  
  # Read spectrum
  inputSpectrum <- reactive({
    visibility.readSpectrum(input$spectrum)
  })
  # Read filter
  inputFilter <- reactive({
    filtering.readFilter(input$filter)
  })
  # Filter spectrum
  filterSpectrum <- reactive({
    filtering.filterEnergies(inputFilter(), input$filterThickness, inputSpectrum()$energy, inputSpectrum()$photons)
  })
  
  # Output:
  
  output$filteredSpectrum <- renderPlot({
    ggplot(NULL, aes_string(x='energy', y='photons')) +
      scale_y_continuous(labels=percent) +
      labs(x="Energy [keV]",y="Photon density / 1.0 [kev]",title=expression(paste("Filtered X-ray spectrum ", omega,"(",epsilon,")"))) +
      geom_bar(aes(fill = "Original"), data = inputSpectrum(), width=.5, stat="identity", fill='blue') +
      geom_bar(aes(fill = "Filtered"), data = filterSpectrum(), width=.5, stat="identity", fill='red')
  })
  
  ################################################

  # Visibility #
  
  # Calc visibilities
  visibilities <- reactive({
    visibility.calcVisibilities(input$designEnergy, input$talbotOrder, inputSpectrum()$energy, inputSpectrum()$photons)
  })
  
  # Output:
  
  output$Spectrum <- renderPlot({
    ggplot(inputSpectrum(),
           aes_string(x='energy', y='photons'))+
      geom_bar(width=.5, stat="identity", fill='blue')+
      scale_y_continuous(labels=percent)+
      labs(x="Energy [keV]",y="Photon density / 1.0 [kev]",title=expression(paste("X-ray spectrum ", omega,"(",epsilon,")")))
    
  })
  
  output$MaximumVisibility <- renderText({
    percent(visibility.maxVisibility(visibilities()))
  })
  output$MeanEnergy <- renderText({
    mean(inputSpectrum()$energy*inputSpectrum()$photons*100)
  })
  
  output$Visibility <- renderPlot({
    visibilityInput = cbind(inputSpectrum()['energy'], vis = visibilities())
    ggplot(visibilityInput,
           aes_string(x='energy', y='vis'))+
      geom_bar(width=.5, stat="identity", fill='blue')+
      scale_y_continuous(labels=percent)+
      labs(x="Energy [keV]",y="Visibility",title=expression(paste("Visibility by energy ", nu,"(",epsilon,")", omega,"(",epsilon,")")))
    
  })
  
  output$MaxVisibilities <- renderPlot({
    MaximumVisibilities = visibility.MaxVisibilityEnergies(input$talbotOrder, inputSpectrum()$energy, inputSpectrum()$photons)
    maxVisibilityInput = cbind(inputSpectrum()['energy'], maxVis = MaximumVisibilities)
    ggplot(maxVisibilityInput,
           aes_string(x='energy', y='maxVis'))+
      geom_bar(width=.5, stat="identity", fill='blue')+
      scale_y_continuous(labels=percent)+
      labs(x="Design Energy [keV]",y="Maximum Visibility",title=paste("Maximum visibility at fixed talbot order: m =", input$talbotOrder))
    
  })
  
  output$OptTablotOrders <- renderDataTable({
    maxVisibilityTable = visibility.MaxVisibilityTalbots(list(1, 3, 5, 7), input$designEnergy, inputSpectrum()$energy, inputSpectrum()$photons)
  },
  options = 
    list(searching=FALSE, paging=FALSE, info=FALSE))
  
})