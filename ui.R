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
                              value = 20, min = 20, max = 120),
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
                 )
#                  fluidRow(
#                    column(3, textOutput("p0")),
#                    column(3, textOutput("p1")),
#                    column(3, textOutput("p2"))
#                  ),
#                  textOutput("talbotDistance"),
#                  fluidRow(
#                    column(3, textOutput("l")),
#                    column(3, textOutput("d")),
#                    column(3, textOutput("s"))
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
                            plotOutput("sampledSpectrum"))
                   )
                 ),
        tabPanel(h4("Visibility"),
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
                 ),
                 tabPanel(h4("Sensitivity")),
                 tabPanel(h4("Phase vs. Absorption CT"))),
        tabPanel(h4("CT Performance"),
                 h5("Add Raupach calc here, with filter and sample checkboxes. Add inprovements! 
                    And add source to detector and sample distances as options (compatible with GI setup?!)"),
                 tabsetPanel(
                   tabPanel(h4("Source and Detector")),
                   tabPanel(h4("Absorptiond and phase comparision"))
                 )))
    )
    
  )))