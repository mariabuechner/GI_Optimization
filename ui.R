source('GI_Optimization.R')

shinyUI(fluidPage(
  titlePanel("GI Optimization for CT Systems"),
  
  sidebarLayout(
    sidebarPanel(h4("Select spectrum"),
                 selectInput("spectrum", label = h5("Spectrum"), 
                             choices = spectra, selected = 1),
                 h4("Select interferometer settings"),
                 h5("Default is cone beam, inverse geometry with pi-shift phase grating"),
                 numericInput("designEnergy", label = h5("Design energy"),
                              value = 51, min = 20, max = 120),
                 numericInput("talbotOrder", label = h5("Talbot Order"),
                              value = 1, min = 1, max = 9, step = 1),
                 checkboxInput("piHalfShift", label = "pi-half shift", value = FALSE),
                 selectInput("geometry", label = h5("GI geometry"),
                             choices = list("Conventional", "Symmetrical", "Inverse"), selected = "Inverse"),
                 # Set smalles pitch of grating corresponding to selected geometry
                 conditionalPanel(
                   condition = "input.geometry == 'Inverse'",
                   numericInput("g0Pitch", label = h5("G0 pitch [um]"), value = 2.4, min = 1, step = 0.005)
                   ),
                 conditionalPanel(
                   condition = "input.geometry == 'Conventional' || input.geometry == 'Symmetrical'",
                   numericInput("g2Pitch", label = h5("G2 pitch [um]"), value = 2, min = 1, step = 0.005)
                   ),
                 conditionalPanel(
                   condition = "input.geometry == 'Conventional' || input.geometry == 'Inverse'",
                   numericInput("G0G1Length", label = h5("G0 to G1 distance [mm]"), value = 97.5, min = 1, step = 1)
                   )
                 ),
    
    mainPanel(
      tabsetPanel(
        tabPanel(h4("Geometry"),
                 imageOutput("geometryImage"),
                 fluidRow(
                   column(3, tableOutput("pitchTable")),
                   column(3, tableOutput("distancesTable"))
                 ),
                 fluidRow(
                   column(3, numericInput("sourceG0Distance", label = h5("Source to G0 distance [mm]"), value = 149, min = 10, step = 1)),
                   column(3, numericInput("g1SampleDistance", label = h5("G1 to sample distance [mm]"), value = 10, min = 1, step = 1)),
                   column(3, numericInput("sampleDiameter", label = h5("Sample diameter [mm]"), value = 200, min = 0.1, step = 0.1))
                 ),
                 fluidRow(
                   h5("With the sample at the isocenter between source (focal spot) and detector plane:")
                 ),
                 fluidRow(
                   column(3, h5("Total length from source to detector [mm]:")),
                   column(3, h5("G2 to detector distance [mm]:"))
                 ),
                 fluidRow(
                   column(3, textOutput("totalSystemLength")),
                   column(3, textOutput("g2DetectorDistance"))
                 ),
                 br(),
                 fluidRow(
                   h5("G0 performance (not adapted to cone beam geometries!):")
                 ),
                 fluidRow(
                   column(3, h5("Transversal coherence length [um]:")),
                   column(3, h5("must be larger than (2x)")),
                   column(3, h5("Seperation of interference beams [um]:"))
                 ),
                 fluidRow(
                   column(3, textOutput("transversalCoherenceLength")),
                   column(3, h5("")),
                   column(3, textOutput("beamSeperation"))
                 )#,
#                  fluidRow(
#                    column(3, textOutput("waveLengthUM"))
#                  )
                 ),
        tabPanel(h4("Filter and sample"),
                 h5("Mean Energy [keV]:"),
                 fluidRow(
                   column(3, h5("Original spectrum:")),
                   column(3, h5("After filter:")),
                   column(3, h5("After sample:"))),
                 fluidRow(
                   column(3, textOutput("MeanEnergy")),
                   column(3, textOutput("filterMeanEnergy")),
                   column(3, textOutput("sampleMeanEnergy"))),
                 br(),
                 tabsetPanel(
                   tabPanel(h4("Filter"),
                            fluidRow(
                              column(6, selectInput("filter", label = h5("Filter"), 
                                         choices = filters, selected = 1)),
                              column(6, numericInput("filterThickness", label = h5("Thickness [mm]"), 
                                          value = 2.4, min = 0.0, step = 0.01))),
                            plotOutput("filteredSpectrumCompared"),
                            plotOutput("filteredSpectrum")
                            ),
                   tabPanel(h4("Sample"),
                            h5("Discpla change in spectrum like filter for sample in beam path"),
                            h5("1) Just variable size option with one tissue time at a time (e.g. fatty, glandular etc."),
                            h5("2) possible to include multiple tissue types? Probably won;t matter much for 
                               change in spectrum"),
                            fluidRow(
                              column(6, selectInput("sample", label = h5("Sample type"), 
                                                    choices = samples, selected = 3)),
                              column(6, numericInput("sampleThickness", label = h5("Thickness [mm]"), 
                                                     value = 200, min = 0.0, step = 0.1))),
                            plotOutput("sampledSpectrumCompared"),
                            plotOutput("sampledSpectrum"))
                   )
                 ),
        tabPanel(h4("Performance"),
                 fluidRow(
                   column(3, checkboxInput("includeFilterVisibility", label = "Add filter", value = FALSE)),
                   column(3, checkboxInput("includeSampleVisibility", label = "Add sample", value = FALSE))
                 ),
                 tabsetPanel(
                   tabPanel(h4("Visibility"),
                            h5("Add choises for vis calc?, also currently vis independent og pi or pi-half phsae grating..."),
                            fluidRow(
                              h5("Maximum visibility:"),
                              textOutput("MaximumVisibility")),
                            fluidRow(
                              column(6, plotOutput("Spectrum")),
                              column(6, plotOutput("Visibility"))),
                            fluidRow(
                              column(6, plotOutput("MaxVisibilities")),
                              column(6, 
                                     fluidRow(h5(paste("Maximum")),
                                              fluidRow(
                                                dataTableOutput("OptTablotOrders")))))
                            ),
                   tabPanel(h4("CT"),
#                             h5("Add Raupach calc here, with filter and sample checkboxes. Add inprovements! 
#                               And add source to detector and sample distances as options (compatible with GI setup?!)"),
                            h4("System information"),
                            fluidRow(
                              column(3, numericInput("pixelSize", label = h5("Pixel size a [um]"),
                                                     value = 75, min = 1, step = 1)),
                              column(3, selectInput("tissueA", label = h5("Sample A"),
                                                    choices = samples, selected = 1)),
                              column(3, selectInput("tissueB", label = h5("Sample B"), 
                                                    choices = samples, selected = 1))
#                               column(3, numericInput("absorptionEnergy", label = h5("Absorption energy Ea [keV]"),
#                                                      value = 54, min = 15, max = 100))
                            ),
                            fluidRow(
                              column(3, checkboxInput("manualInput", label = "Manual input of dMu and dPhi (for design energy)", value = FALSE)),
                              column(3, numericInput("deltaMu", label = h5("Delta mu for two different tissue types[1/cm]"),
                                              value = 0.0098, min = 0.0001, step = 0.0001)),
                              column(3, numericInput("deltaPhi", label = h5("Delta phi for two different tissue types[1/cm]"),
                                              value = 11.42, min = 0.001, step = 0.001))
                            ),
#                             fluidRow(
#                               column(3, checkboxInput("manualInput", label = "Manual input of dMu and dPhi (for design energy)", value = FALSE))
#                             ),
#                             fluidRow(
#                               column(3, conditionalPanel(
#                                 condition = "input.manualInput == TRUE",
#                                 numericInput("deltaMu", label = h5("Delta mu for two different tissue types[1/cm]"),
#                                              value = 0.0098, min = 0.0001, step = 0.0001))),
#                               column(3, conditionalPanel(
#                                 condition = "input.manualInput == TRUE",
#                                 numericInput("deltaPhi", label = h5("Delta phi for two different tissue types[1/cm]"),
#                                              value = 11.42, min = 0.001, step = 0.001)))
#                             ),
                            h4("Parameters:"),
                            fluidRow(
                              column(3, numericInput("postAttenuationFactor", label = h5("Post-sample attenuation factor f ]1...2]"),
                                                     value = 2, min = 1.01, max = 2, step = 0.01)),
                              column(3, numericInput("reconstructionFactor", label = h5("Recostruction resolution factor gA ]0...0.5]"),
                                                     value = 0.2, min = 0.01, max = 0.5, step = 0.01))
                            ),
#                             fluidRow(
#                               imageOutput("raupachImage")
#                             ),
                            h5("Note: noise is missing, image too large. Issue: calc of detla (phi) and mu the same as paper values, nist, matlab sript etc...???"),
                            fluidRow(
                              column(3, h5("Design energy CNRp/CNRa:")),
                              column(3, h5("Mean CNRp/CNRa:"))
                            ),
                            fluidRow(
                              column(3, textOutput("ctCnrRatio")),
                              column(3, textOutput("meanctCnrRatio")),
                              column(3, textOutput("testVar"))
                            ),
                            fluidRow(
                              column(9, plotOutput("cnrRatiosPlot"))
                            ),
                            imageOutput("raupachImage")
                   ),
                   tabPanel(h4("General"),
                           h5("Add sensitivity, maybe CNR etc. here...")
                           ))))
    )
    
  )))