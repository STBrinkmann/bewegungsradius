library(shiny)

library(sf)
library(dplyr)
library(leaflet)
library(jsonlite)
library(curl)
library(lubridate)

## Geocoding function using OSM Nominatim API
## details: http://wiki.openstreetmap.org/wiki/Nominatim
## made by: D.Kisler 
geocode <- function(address = NULL) {
    d <- jsonlite::fromJSON(
        gsub('\\@addr\\@', gsub('\\s+', '\\%20', address),
             'https://nominatim.openstreetmap.org/search/@addr@?format=json&addressdetails=0&limit=1'),
        flatten = T)
    
    if(length(d) == 0) return(data.frame())
    
    data.frame(lon = as.numeric(d$lon), lat = as.numeric(d$lat)) %>%
        return()
}

# Shapefile for NUTS3 regions
germany_nuts3 <- readRDS(file.path("data", "germany_nuts3.RDS"))

# Shapefile for Gemeinden in Germany
gemeinden <- readRDS(file.path("data", "gemeinde.RDS"))


# Download recent 7 days incidence and join with NUTS3 shp
month.abb <- c("Jan", "Feb", "März", "Apr", "Mai", "Juni", "Juli", "Aug", "Sept", "Okt", "Nov", "Dez")
germany_nuts <- sapply(jsonlite::read_json("https://github.com/entorb/COVID-19-Coronavirus-German-Regions/raw/master/data/de-districts/de-districts-results.json"), 
                       function(x) {
                           if ("DIVI_Intensivstationen_Betten_belegt_Prozent" %in% names(x)) {
                               return(c(x$LK_ID, x$Cases_Last_Week_Per_100000, x$LK_Typ,
                                        paste0(x$DIVI_Intensivstationen_Betten_belegt_Prozent, "%"), 
                                        paste0(x$DIVI_Intensivstationen_Covid_Prozent, "%"),
                                        x$Date_Latest))
                           } else {
                               return(c(x$LK_ID, x$Cases_Last_Week_Per_100000, x$LK_Typ, "Nicht verfügbar", "Nicht verfügbar", x$Date_Latest))
                           }
                       }) %>%
    t() %>% 
    dplyr::as_tibble() %>% 
    dplyr::rename(Kennziffer = V1,
                  LastWeek_100k = V2,
                  LK_Typ = V3,
                  DIVI_ges = V4,
                  DIVI_covid = V5,
                  Date_Latest = V6) %>% 
    dplyr::mutate(Kennziffer = as.numeric(Kennziffer),
                  LastWeek_100k = as.numeric(LastWeek_100k),
                  #sieben_tage = round(LastWeek_100k),
                  #LastWeek_100k = dplyr::if_else(LastWeek_100k >= 200, "> 200", "< 200"),
                  Date_Latest = lubridate::ymd(Date_Latest),
                  Date_Latest = paste0(lubridate::day(Date_Latest), ". ", 
                                       month.abb[lubridate::month(Date_Latest)], " ",
                                       lubridate::year(Date_Latest)))

germany_nuts[germany_nuts$Kennziffer %in% 11001:11012, ] <- germany_nuts[germany_nuts$Kennziffer %in% 11001:11012, ] %>%
    summarize(Kennziffer = 11000, LastWeek_100k = mean(LastWeek_100k), 
              LK_Typ, DIVI_ges, DIVI_covid, Date_Latest)

germany_nuts <- germany_nuts %>% 
    mutate(sieben_tage = round(LastWeek_100k),
           LastWeek_100k = dplyr::if_else(LastWeek_100k >= 200, "> 200", "< 200")) %>% 
    distinct() %>% 
    dplyr::inner_join(germany_nuts3, .) %>% 
    dplyr::relocate(geom, .after = sieben_tage)


# Define UI -----------------------------------------------------
ui <- shinyUI(
    bootstrapPage(
        tags$head(
            #tags$a(href="https://github.com/STBrinkmann/covid_ger_buffer", "GitHub", target="_blank"),
            tags$link(href = "https://fonts.googleapis.com/css?family=Oswald", rel = "stylesheet"),
            tags$style(type = "text/css", "html, body {width:100%;height:100%; font-family: Oswald, sans-serif;}"),
            tags$script(src="https://cdnjs.cloudflare.com/ajax/libs/iframe-resizer/3.5.16/iframeResizer.contentWindow.min.js",
                        type="text/javascript"),
            tags$script(src = "enter_button.js"),
            tags$script('
                        $(document).ready(function () {
                            navigator.geolocation.getCurrentPosition(onSuccess, onError);
                            
                            function onError (err) {
                                Shiny.onInputChange("geolocation", false);
                            }
                                        
                            function onSuccess (position) {
                                setTimeout(function () {
                                    var coords = position.coords;
                                    console.log(coords.latitude + ", " + coords.longitude);
                                    Shiny.onInputChange("geolocation", true);
                                    Shiny.onInputChange("lat", coords.latitude);
                                    Shiny.onInputChange("long", coords.longitude);
                                }, 1100)
                            }
                        });
                        ')
        ),
        
        # If not using custom CSS, set height of leafletOutput to a number instead of percent
        leafletOutput("map", width="100%", height="100%"),
        
        absolutePanel(
            top = 100, left = 10, draggable = TRUE, width = "20%", style = "z-index:500; min-width: 300px;",
            textInput("address", "Bitte Adresse eingeben", placeholder = "in Deutschland"),
            checkboxInput("use_location", "Oder nutze deinen aktuelle Standort!"),
            actionButton("go", "Radius berechnen!", class = "btn-primary")
        ),
        
        absolutePanel(
            top = "96.5%", left = 10, draggable = FALSE, width = "10%", height = "3%", style = "z-index:500; min-width: 20px;",
            a(href="https://github.com/STBrinkmann/covid_ger_buffer", "Mehr Infos...", target="_blank")
        )
    )
)

# Define server ------------------------------------------------
server <- shinyServer(function(input, output) {
    # First Leaflet map
    pal <- c("dodgerblue2", "firebrick4")
    leafPal1 <- leaflet::colorFactor(pal, germany_nuts$LastWeek_100k)
    
    output$map <- renderLeaflet({
        leaflet::leaflet(leaflet::leafletOptions(leaflet::leafletCRS(crsClass = "L.CRS.EPSG4326"), )) %>%
            setMaxBounds(lng1 = -5,
                         lat1 = 40,
                         lng2 = 25,
                         lat2 = 60) %>%
            leaflet::addProviderTiles("CartoDB.Positron",
                                      options = providerTileOptions(minZoom = 6, maxZoom = 12)) %>%
            leaflet::setView(10.5, 51, zoom = 6) %>% 
            leaflet::addPolygons(data = germany_nuts,
                                 stroke = T, fill = TRUE, fillOpacity = 0.4, weight = 1.2,
                                 color = ~leafPal1(LastWeek_100k), label = ~NUTS_NAME, 
                                 popup = paste0(
                                     "
                                 <html>
                                 <head>
                                 <style>
                                 table, th, td {
                                    border-collapse: collapse;
                                 }
                                 th, td {
                                    padding: 1;
                                    text-align: left;
                                 }
                                 tr.spaceUnder>td {                                     	
                                    line-height: 2.5;
                                 }
                                 </style>
                                 </head>
                                 <body>
                                 
                                 
                                 <h5><b>", germany_nuts$NUTS_NAME, "</b></h5>
                                 <table style=\"width:100%\">
                                 <tr>
                                     <th></th>
                                     <th></th>
                                 </tr>
                                 
                                 <tr class=\"spaceUnder\">
                                     <th>7-Tage-Inzidenz</th>
                                     <td>", germany_nuts$sieben_tage, "</td>
                                 </tr>
                                 
                                 <tr>
                                     <th>Intensivbetten-Auslastung:</th>
                                     <td></td>
                                 </tr>
                                 
                                 <tr>
                                     <td>&emsp;Gesamt</td>
                                     <td>", germany_nuts$DIVI_ges, "</td>
                                 </tr>
                                 
                                 <tr>
                                     <td>&emsp;Davon COVID-19</td>
                                     <td>", germany_nuts$DIVI_covid, "</td>
                                 </tr>
                                 
                                 <tr class=\"spaceUnder\">
                                     <th>Stand</th>
                                     <td>", germany_nuts$Date_Latest, "</td>
                                 </tr>
                                 </table>
                                 </body>
                                 </html>
                                 "
                                 )) %>% 
            leaflet::addLegend(data = germany_nuts, 
                               "bottomright", pal = leafPal1, values = ~LastWeek_100k, title = "7-Tage-Inzidenz")
    })
    
    # actionButton
    shiny::observeEvent(input$go, {
        
        shiny::withProgress(
            message = "Berechne Bewegungsradius...",
            value = 1/5, {
                # Use Geolocaton
                if (input$use_location) {
                    
                    tryCatch({
                        shiny::validate(
                            shiny::need(input$geolocation, message = F)
                        )
                        
                        if(!input$geolocation) stop()
                    }, error = function(e) {
                        shiny::showModal(shiny::modalDialog(title = "Sorry!", 
                                                            tags$p("Diese Funktion ist in der aktuellen Version noch nicht verfügbar."), #Du must den Standortzugriff erlauben!
                                                            footer = shiny::modalButton("Abbrechen"),
                                                            easyClose = TRUE))
                    }
                    )
                    
                    shiny::validate(
                        shiny::need(input$geolocation, message = F)
                    )
                    
                    lat <- input$lat
                    lon <- input$long
                    
                    geo_point <- data.frame(lon = as.numeric(lon), lat = as.numeric(lat))
                    
                    # Use address input
                } else {
                shiny::validate(
                    shiny::need(nchar(input$address) > 2, message = FALSE)
                )
                
                
                tryCatch({
                    geo_point <- geocode(address = input$address)
                    
                    if (length(geo_point) == 0) stop()
                }, error = function(e) {
                    shiny::showModal(shiny::modalDialog(title = "Sorry!", 
                                                        tags$p("Wir konnten diese Adresse nicht finden."), 
                                                        tags$p("Versuch es noch einmal!"),
                                                        footer = shiny::modalButton("Abbrechen"),
                                                        easyClose = TRUE))
                }
                )
                
                shiny::validate(
                    shiny::need(length(geo_point) > 0, message = FALSE)
                )
                
                lat <- geo_point$lat
                lon <- geo_point$lon
                }
                
                incProgress(1/5)
                
                # Convert input to sf
                geo_point <- geo_point %>%
                    sf::st_as_sf(coords = c("lon", "lat"), crs = sf::st_crs(germany_nuts)) %>% 
                    dplyr::rename(geom = geometry)
                
                # Intersect of NUTS3 and address
                gemeinden_intersect <- gemeinden[geo_point, ]
                
                tryCatch({
                    if (nrow(gemeinden_intersect) == 0) stop("Error")
                }, error = function(e) {
                    shiny::showModal(shiny::modalDialog(title = "Sorry!", 
                                                        tags$p("Diese Adresse scheint nicht innerhalb von Deutschland zu liegen."), 
                                                        tags$p("Versuch es noch einmal!"),
                                                        footer = shiny::modalButton("Abbrechen"),
                                                        easyClose = TRUE))
                }
                )
                
                shiny::validate(
                    shiny::need(nrow(gemeinden_intersect) > 0, message = FALSE)
                )
                
                incProgress(1/5)
                
                # NUTS3 name
                nuts_name <- gemeinden_intersect$GEN
                
                # 15km buffer and collect all spatial features
                leaf_data <- gemeinden_intersect %>% 
                    sf::st_geometry() %>%
                    sf::st_transform(crs = sf::st_crs(4839)) %>%
                    sf::st_buffer(15000) %>% 
                    sf::st_transform(crs = sf::st_crs(germany_nuts)) %>%
                    sf::st_as_sf() %>% 
                    sf::st_difference(dplyr::select(gemeinden_intersect, geom)) %>% 
                    rbind(sf::st_as_sf(sf::st_geometry(gemeinden_intersect))) %>% 
                    rbind(sf::st_as_sf(sf::st_geometry(geo_point))) %>% 
                    dplyr::mutate(name = c("15km Radius", nuts_name, "Wohnort"))
                
                incProgress(1/5)
                
                # Update Leaflet map
                pal <- c("#009900", "gray60", "black")
                leafPal <- colorFactor(pal, leaf_data$name)
                
                leaflet::leafletProxy("map") %>%
                    leaflet::setView(lon, lat, zoom = 10) %>% 
                    leaflet::clearShapes() %>% 
                    leaflet::clearControls() %>% 
                    leaflet::clearTiles() %>% 
                    leaflet::clearMarkers() %>% 
                    leaflet::addProviderTiles("OpenStreetMap.DE",
                                              options = providerTileOptions(minZoom = 6)) %>% 
                    
                    # NUTS3 - this_Gemeinde
                    leaflet::addPolygons(data = sf::st_difference(germany_nuts, leaf_data[1,]), 
                                         stroke = FALSE, fill = TRUE, fillOpacity = 0.4, weight = 1.2,
                                         color = ~leafPal1(LastWeek_100k)) %>% 
                    # 15km radius
                    leaflet::addPolygons(data = leaf_data[1, ],
                                         stroke = FALSE, fill = TRUE, fillOpacity = 0.1, weight = 2,
                                         fillColor = leafPal(leaf_data$name[1]), label = leaf_data$name[1]) %>%
                    # Gemeinde
                    leaflet::addPolygons(data = leaf_data[2, ],
                                         stroke = TRUE, fill = FALSE, weight = 3,
                                         color = "black", label = leaf_data$name[2]) %>%
                    # Wohnort
                    leaflet::addMarkers(data = leaf_data[3, ],
                                        label = leaf_data$name[3]) %>% 
                    # Legende
                    leaflet::addLegend("bottomright", pal = leafPal, opacity = 0.3, values = leaf_data$name[1], title = NA) %>% 
                    leaflet::addLegend(data = germany_nuts,
                                       "bottomright", pal = leafPal1, values = ~LastWeek_100k, title = "7-Tage-Inzidenz") %>% 
                    # NUTS3 regions for popup
                    leaflet::addPolygons(data = germany_nuts, 
                                         stroke = TRUE, fill = TRUE, fillOpacity = 0, weight = 1.1,
                                         color = "black", label = ~NUTS_NAME,
                                         popup = paste0(
                                             
                                             "
                                             <html>
                                             <head>
                                             <style>
                                             table, th, td {
                                                border-collapse: collapse;
                                             }
                                             th, td {
                                                padding: 1;
                                                text-align: left;
                                             }
                                             tr.spaceUnder>td {                                     	
                                                line-height: 2.5;
                                             }
                                             </style>
                                             </head>
                                             <body>
                                             
                                             
                                             <h5><b>", germany_nuts$NUTS_NAME, "</b></h5>
                                             <table style=\"width:100%\">
                                             <tr>
                                                 <th></th>
                                                 <th></th>
                                             </tr>
                                             
                                             <tr class=\"spaceUnder\">
                                                 <th>7-Tage-Inzidenz</th>
                                                 <td>", germany_nuts$sieben_tage, "</td>
                                             </tr>
                                             
                                             <tr>
                                                 <th>Intensivbetten-Auslastung:</th>
                                                 <td></td>
                                             </tr>
                                             
                                             <tr>
                                                 <td>&emsp;Gesamt</td>
                                                 <td>", germany_nuts$DIVI_ges, "</td>
                                             </tr>
                                             
                                             <tr>
                                                 <td>&emsp;Davon COVID-19</td>
                                                 <td>", germany_nuts$DIVI_covid, "</td>
                                             </tr>
                                             
                                             <tr class=\"spaceUnder\">
                                                 <th>Stand</th>
                                                 <td>", germany_nuts$Date_Latest, "</td>
                                             </tr>
                                             </table>
                                             </body>
                                             </html>
                                             "
                                         ))
                incProgress(1/5)
            }
        )
    })
})

# Run the application ------------------------------------------
shinyApp(ui = ui, server = server)