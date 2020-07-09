#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(dplyr)
library(leaflet)
library(leaflet.providers)
library(htmltools)


# Define UI for application that draws a histogram
ui <- bootstrapPage(
    tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
    leafletOutput("map", width = "100%", height = "100%"),
    absolutePanel(bottom = 10, right = 10,
        sliderInput("freq", "Radiated Frequency (MHz)", min = 0, max = 20000, value = 10000, step = 10),
        sliderInput("alt", "Aircraft Altitude (ft)", min = 500, max= 40000, value = 20000, step = 100)
    )
)

server <- function(input, output) {

    output$map <- renderLeaflet({
        leaflet() %>% setView(lng = 45, lat = 25, zoom = 5) %>% 
            addProviderTiles("OpenTopoMap") %>% 
            addAwesomeMarkers(
                data = stations, 
                lng = ~LONGITUDE, lat = ~LATITUDE,
                popup = ~(paste(sep = "<br/>",NAME,paste("First Yr. ",FSTYEAR),paste("Last Yr. ",LSTYEAR),paste("Num Obs. ",NOBS))),
                popupOptions = popupOptions(closeButton = TRUE),
                clusterOptions = markerClusterOptions(),
                group = "Hide Wx Stations") %>%
            addLayersControl(
                overlayGroups = "Hide Wx Stations",
                options = layersControlOptions(collapsed = FALSE)
            )
    })
    observe()
}


# Run the application 
shinyApp(ui = ui, server = server)
