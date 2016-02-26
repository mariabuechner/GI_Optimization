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
                              value = 45, min = 20, max = 120),
                 numericInput("talbotOrder", label = h5("Talbot Order"),
                              value = 1, min = 1, max = 9, step = 1),
                 checkboxInput("piHalfShift", label = "pi-half shift", value = FALSE),
                 selectInput("geometry", label = h5("GI geometry"),
                             choices = list("Conventional", "Symmetrical", "Inverse"), selected = "Inverse"),
                 # Set smalles pitch of grating corresponding to selected geometry
                 conditionalPanel(
                   condition = "input.geometry == 'Inverse'",
                   numericInput("g0Pitch", label = h5("G0 pitch [um]"), value = 2, min = 1, step = 0.005)
                   ),
                 conditionalPanel(
                   condition = "input.geometry == 'Conventional' || input.geometry == 'Symmetrical'",
                   numericInput("g2Pitch", label = h5("G2 pitch [um]"), value = 2, min = 1, step = 0.005)
                   ),
                 conditionalPanel(
                   condition = "input.geometry == 'Conventional' || input.geometry == 'Inverse'",
                   numericInput("G0G1Length", label = h5("G0 to G1 distance [mm]"), value = 200, min = 1, step = 1)
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
                   column(3, numericInput("sourceG0Distance", label = h5("Source to G0 distance [mm]"), value = 100, min = 10, step = 1)),
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
                   h5("G0 performance:")
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
                                          value = 0.0, min = 0.0, step = 0.01))),
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
                                                    choices = samples, selected = 1)),
                              column(6, numericInput("sampleThickness", label = h5("Thickness [mm]"), 
                                                     value = 0.0, min = 0.0, step = 0.1))),
                            plotOutput("sampledSpectrumCompared"),
                            plotOutput("sampledSpectrum"))
                   )
                 ),
        tabPanel(h4("Visibility"),
                 h5("Add choises for vis calc?, also currently vis independent og pi or pi-half phsae grating..."),
                 fluidRow(
                   column(3, checkboxInput("includeFilterVisibility", label = "Add filter", value = FALSE)),
                   column(3, checkboxInput("includeSampleVisibility", label = "Add sample", value = FALSE))),
                 tabsetPanel(
                   tabPanel(h4("Visibility"),
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
                                                dataTableOutput("OptTablotOrders")))))),
                   tabPanel(h4("Talbot Carpet"),
                            h5("Show interference pattern at talbot distance for whole spectrum, and sum. 
                               allow selection of filter and sample"))
                 )),
        tabPanel(h4("Performance"),
                 h4("System information"),
                 fluidRow(
                   column(3, selectInput("tissueSample", label = h5("Tissue sample"), 
                                         choices = samples, selected = 1)),
                   column(3, numericInput("pixelSize", label = h5("Pixel size a [um]"),
                                          value = 75, min = 1, step = 1)),
                   column(3, numericInput("absorptionEnergy", label = h5("Absorption energy Ep [keV]"),
                                          value = 54, min = 15, max = 100))
                 ),
                 tabsetPanel(
                   tabPanel(h4("General"),
                            h5("Add sensitivity, maybe CNR etc. here...")
                            ),
                   tabPanel(h4("CT"),
#                             h5("Add Raupach calc here, with filter and sample checkboxes. Add inprovements! 
#                               And add source to detector and sample distances as options (compatible with GI setup?!)"),
                            h4("Parameters:"),
                            fluidRow(
                              column(3, numericInput("postAttenuationFactor", label = h5("Post-sample attenuation factor f ]1...2]"),
                                                     value = 2, min = 1.01, max = 2, step = 0.01)),
                              column(3, numericInput("reconstructionFactor", label = h5("Recostruction resolution factor gA ]0...0.5]"),
                                                     value = 0.3, min = 0.01, max = 0.5, step = 0.01))
                            ),
                            imageOutput("raupachImage")
                 ))))
    )
    
  )))