library(dplyr)
library(sf)
library(leaflet)
library(rnaturalearth)
library(rnaturalearthdata)

# Read in shapefile
boreal <- st_read("C:/Users/Kevin/Documents/Repos/Nature_Bioacoustics/Shapefile_Boreal/NABoreal.shp")

# Read in Recordings
recordings_ABMI <- read.csv("C:/Users/Kevin/Documents/Repos/Nature_Bioacoustics/Data_WildTrax/ABMI/Alberta_Biodiversity_Monitoring_Institute_recordings_20250910_213444UTC.csv")
  
  
# Adjust Recordings to give total number of recordings/location and adjusted number of locations/location
recordings_ABMI <- recordings_ABMI %>%
  group_by(location, latitude, longitude) %>%
  summarise(count = n(), .groups = "drop") %>%
  mutate(count_adjusted = pmin(count, 10)) %>%
  filter(!is.na(latitude))

# Convert to sf points
recordings_ABMI <- st_as_sf(recordings_ABMI, 
                         coords = c("longitude", "latitude"), 
                         crs = 4326)

# Make sure shapefile and points have the same CRS
boreal <- st_transform(boreal, crs = st_crs(recordings_ABMI))

# Fix duplicate vertices in shapefile
boreal <- st_make_valid(boreal)

# Join shapefiles to get only the locations that fall in the boreal shapefile
locations_ABMI_boreal <- st_join(recordings_ABMI, boreal) %>%
  filter(!is.na(TYPE))


# Map

# Get Canada boundary
canada <- ne_countries(country = "canada", returnclass = "sf")

# Colour palette for points
pal <- colorNumeric(
  palette = "Blues",
  domain  = locations_boreal$count_adjusted
)

# Build Map
leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>%
  addPolygons(data = canada, fill = FALSE, color = "black", weight = 2) %>%  # Canada outline
  addPolygons(data = boreal, fillColor = "lightblue", color = "grey", weight = 0.5) %>%    # boreal shapefile
  addCircleMarkers(data = locations_boreal,
                   radius = 2,
                   fillColor = ~pal(count_adjusted),
                   color = "white",
                   weight = 0.5,
                   stroke = TRUE,
                   fillOpacity = 0.8,
                   popup = ~paste0("<b>Location:</b> ", location,
                                   "<br><b>Count:</b> ", count_adjusted)) %>%
  addLegend("bottomright", pal = pal, values = locations_boreal$count_adjusted,
            title = "Counts", opacity = 1)
