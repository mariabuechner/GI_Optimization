source('GI_Optimization.R')

shinyUI(fluidPage(
  titlePanel("GI Optimization got CT Systems"),
  
  sidebarLayout(
    sidebarPanel(h4("Select spectrum"),
                 selectInput("spectrum", label = h5("Spectrum"), 
                             choices = spectra, selected = 1),
                 h4("Select interferometer settings"),
                 h5("Default is inverse geometry with pi-shift phase grating"),
                 numericInput("designEnergy", label = h5("Design energy"),
                              value = 20, min = 20, max = 120),
                 numericInput("talbotOrder", label = h5("Talbot Order"),
                              value = 1, min = 1, max = 7, step = 2),
                 selectInput("geometry", label = h5("GI geometry"),
                             choices = list("Conventional" = 1, "Symmetric" = 2, "Inverse" = 3), selected = 3),
                 checkboxInput("piHalfShift", label = "pi-half shift", value = FALSE),
                 # Set smalles pitch of grating corresponding to selected geometry
                 conditionalPanel(
                   condition = "input.geometry == 3",
                   numericInput("g0Pitch", label = h5("G0 pitch [um]"), value = 2, min = 1, step = 0.005)),
                 conditionalPanel(
                   condition = "input.geometry == 1",
                   numericInput("g2Pitch", label = h5("G2 pitch [um]"), value = 2, min = 1, step = 0.005)),
                 conditionalPanel(
                   condition = "input.geometry == 2",
                   numericInput("g1Pitch", label = h5("G1 pitch [um]"), value = 2, min = 1, step = 0.005))
                 ),
    
    mainPanel(
      tabsetPanel(
        tabPanel(h4("Geometry")),
        tabPanel(h4("Filter and sample"),
                 h4("Filter"),
                 fluidRow(
                   column(6, selectInput("filter", label = h5("Filter"), 
                                         choices = filters, selected = 1)),
                   column(6, numericInput("filterThickness", label = h5("Thickness [mm]"), 
                                          value = 0.0, min = 0.0, step = 0.01))),
#                  fluidRow(
#                    column(6, plotOutput("originalSpectrum")),
#                    column(6, plotOutput("filteredSpectrum")))),
                plotOutput("filteredSpectrum")),
        tabPanel(h4("Visibility"),   
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