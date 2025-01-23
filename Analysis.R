# Grid Accessibility

options(java.parameters = "-Xmx10G")
library(r5r)
library(tigris)
library(dplyr)
library(ggplot2)
library(sf)
library(mapview)

data_path = "/Users/henrymckay/Desktop/GridAccessibility/Network"
r5r_core <- setup_r5(data_path, verbose = FALSE, temp_dir = TRUE, overwrite = FALSE)

# Define the bounding box (xmin, ymin, xmax, ymax)
bbox <- st_bbox(c(xmin = -121.527765, 
                  ymin = 38.543577, 
                  xmax = -121.435230, 
                  ymax = 38.616183), 
                crs = 4326)
# Convert the bbox to an sf object
bbox_sf <- st_as_sfc(bbox)
# Create a hexagonal grid
hex_grid <- st_make_grid(bbox_sf, cellsize = .001, square = FALSE)
# Convert the grid to an sf object
hex_sf <- st_sf(geometry = hex_grid) %>%
  mutate(id = paste0("id_", row_number()))

# Define origin/dest points
geo_point <- hex_sf %>%
  st_centroid(geo_point)

dests <- read.csv("/Users/henrymckay/Desktop/GridAccessibility/coffee.csv") %>%
  mutate(count = 1)
dest_points <- st_as_sf(dests, coords = c("lon", "lat"), crs = 4326) 

departure_datetime <- as.POSIXct(
  "18-01-2025 12:00:00",
  format = "%d-%m-%Y %H:%M:%S"
)


access <- accessibility(
  r5r_core,
  origins = geo_point,
  destinations = dests,
  opportunities_colnames = "count",
  mode = "TRANSIT",
  mode_egress = "WALK",
  departure_datetime = departure_datetime,
  time_window = 120,
  decay_function = "exponential",
  cutoffs = 30,
  max_walk_time = 10,
  max_trip_duration = 120,
  progress = T
)
head(access)

map <- merge(hex_sf,
             access,
             by = "id",
             all.x = T)

mapview(map, zcol = "accessibility")
