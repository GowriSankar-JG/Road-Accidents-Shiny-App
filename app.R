require(shiny)
library(maptools)
require(dplyr)
require(leaflet)
library(data.table)
library(RColorBrewer)

## read crash data
crash.dt <- as.data.table(read.csv("data/crashpoints.csv",
                                   colClasses = c("character",
                                                  rep("integer", 25),
                                                  "numeric", "numeric",
                                                  "character",
                                                  "numeric", "numeric")))
## read suburbs bounding box data
suburbs.bb <- as.data.table(read.csv("data/suburbs/suburbsbb.csv",
                                     colClasses = c("integer",
                                                    "character",
                                                    "character",
                                                    rep("numeric", 4))))
## sampling for fast demo
# crash.dt <- crash.dt[sample.int(nrow(crash.dt), 5000, replace = TRUE),
#                       -c(1, 27:29), with = FALSE]
pallet <- colorFactor(c("gray32", "dodgerblue4",  "slateblue4",
                        "purple", "firebrick1"),
                      domain = c(0, 1, 2, 3, 10))

ui <- bootstrapPage(
  tags$head(
    includeCSS("styles.css")
  ),
  tags$style(type = "text/css", "html, body {width:100%;height:100%;}"
             ),
  leafletOutput("map", width = "100%", height = "100%"),
  absolutePanel(id = "controls", class = "panel panel-default",
                top = 55, right = "auto", left = 20, bottom = "auto",
                width = 450, height = "auto",
                fixed = FALSE, draggable = TRUE,
                h3("Filter data"),
                selectInput("suburb",
                            label = "Zoom to suburb",
                            choices=c(None = '.',
                                      sort(
                                        setNames(suburbs.bb$suburb,
                                                 paste(suburbs.bb$suburb,
                                                       suburbs.bb$postcode))
                                        ))),
                selectInput("LCO_NIGHT",
                            label = "Time of incident:",
                            choices = c("Both days and nights" = 3,
                                        "Days only" = 0,
                                        "Nights only" = 1),
                            selected = 3),
                # p("Notes:"),
                includeHTML("note.html")
  )
)

server <- function(input, output, session) {
  get.crash <- function(xinput) {
    if(xinput != 3) {
      xdf <- crash.dt[crash.dt$LCO_NIGHT == as.numeric(input$LCO_NIGHT),]
    }
    else {
      xdf <- crash.dt
    }
    return(xdf)
  }
  # subset based on user selection
  filteredData <- reactive({
    get.crash(input$LCO_NIGHT)
  })
  filteredPu <- reactive({
    #this can probably be avoided
    datax <- filteredData()
    pux <- paste("<b>Total crashes:</b>",
                 as.character(datax$TOTAL_CRAS), "<br>",
                 "<b>Total casualties:</b>",
                 as.character(datax$TOTAL_CASU))
    return(pux)
  })
  
  output$map <- renderLeaflet({
    pu <- filteredPu()
    leaflet(data=crash.dt) %>%
      addTiles() %>%
      setView(138.592609, -34.912760,  zoom = 9) %>%
      addCircleMarkers(~lon, ~lat,
                       popup = pu,
                       radius = ~ifelse(TOTAL_CRAS < 2, 6, 11),
                       color = ~pallet(TOTAL_CASU),
                       stroke = FALSE, fillOpacity = 0.8,
                       clusterOptions = markerClusterOptions(spiderfyOnMaxZoom = FALSE,
                                                             disableClusteringAtZoom = 16))
  })

  observe({
    if(input$suburb == ".") {
      leafletProxy("map", data = filteredData()) %>%
      clearMarkers() %>%
        clearMarkerClusters() %>%
        addCircleMarkers(~lon, ~lat,
                         popup = filteredPu(),
                         radius = ~ifelse(TOTAL_CRAS < 2, 6, 11),
                         color = ~pallet(TOTAL_CASU),
                         stroke = FALSE, fillOpacity = 0.8,
                         clusterOptions = markerClusterOptions(spiderfyOnMaxZoom = FALSE,
                                                               disableClusteringAtZoom = 16)
        )
    } else {
      this.bb <- suburbs.bb[suburbs.bb$suburb == input$suburb, ]
      leafletProxy("map", data = filteredData()) %>%
        fitBounds(this.bb$lonmin, this.bb$latmin, this.bb$lonmax, this.bb$latmax)
    }

  })
  
}

shinyApp(ui, server)