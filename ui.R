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
                              value = 1, min = 1, max = 7, step = 2),
                 checkboxInput("piHalfShift", label = "pi-half shift", value = FALSE),
                 selectInput("geometry", label = h5("GI geometry"),
                             choices = list("Conventional", "Symmetrical", "Inverse"), selected = "Inverse"),
                 # Set smalles pitch of grating corresponding to selected geometry
                 conditionalPanel(
                   condition = "input.geometry == 'Inverse'",
                   numericInput("g0Pitch", label = h5("G0 pitch [um]"), value = 2, min = 1, step = 0.005)),
                 conditionalPanel(
                   condition = "input.geometry == 'Conventional' || input.geometry == 'Symmetrical'",
                   numericInput("g2Pitch", label = h5("G2 pitch [um]"), value = 2, min = 1, step = 0.005)),
                 fluidRow(
                   column(7, selectInput("fixedLength", label = h5("Fixed length"), 
                                         choices = list("System legth" = 1, "G0 to G1 distance" = 2, "G1 to G2 distance" = 3), selected = 1)),
                   column(5, conditionalPanel( 
                     condition = "input.fixedLength == 1",
                     numericInput("systemLength", label = h5("[mm]"), value = 1000, min = 1, step = 1)),
                     conditionalPanel( 
                       condition = "input.fixedLength == 2",
                       numericInput("G0G1Length", label = h5("[mm]"), value = 200, min = 1, step = 1)),
                     conditionalPanel( 
                       condition = "input.fixedLength == 3",
                       numericInput("G1G2Length", label = h5("[mm]"), value = 200, min = 1, step = 1))))
                 ),
    
    mainPanel(
      tabsetPanel(
        tabPanel(h4("Geometry"),
                 imageOutput("geometryImage")),
        tabPanel(h4("Filter and sample"),
                 tabsetPanel(
                   tabPanel(h4("Filter"),
                            fluidRow(
                              column(6, selectInput("filter", label = h5("Filter"), 
                                         choices = filters, selected = 1)),
                              column(6, numericInput("filterThickness", label = h5("Thickness [mm]"), 
                                          value = 0.0, min = 0.0, step = 0.01))),
                            plotOutput("filteredSpectrum")),
                   tabPanel(h4("Sample")))),
        tabPanel(h4("Visibility"),
                 fluidRow(
                   column(3, checkboxInput("includeFilterVisibility", label = "Add filter", value = FALSE)),
                   column(3, checkboxInput("includeSampleVisibility", label = "Add sample", value = FALSE))),
                 fluidRow(
                   column(3, h5("Maximum visibility:")),
                   column(3, h5("Mean Energy [keV]:"))),
                 fluidRow(
                   column(3, textOutput("MaximumVisibility")),
                   column(3, textOutput("MeanEnergy"))),
                 fluidRow(
                   column(6, plotOutput("Spectrum")),
                   column(6, plotOutput("Visibility"))),
                 fluidRow(
                   column(6, plotOutput("MaxVisibilities")),
                   column(6, 
                          fluidRow(h5(paste("Maximum")),
                                   fluidRow(
                                     dataTableOutput("OptTablotOrders"))))),
                 tabPanel(h4("Sensitivity")),
                 tabPanel(h4("Phase vs. Absorption CT"))))
    )
    
  )))