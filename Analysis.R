# Grid Accessibility

options(java.parameters = "-Xmx10G")
library(r5r)
library(tigris)
library(dplyr)
library(ggplot2)
library(sf)
library(mapview)

data_path = "/Users/henrymckay/Desktop/GridAccessibility/Network"
r5r_core <- setup_r5(data_path, verbose = FALSE, temp_dir = TRUE, overwrite = TRUE)

# Define the bounding box (xmin, ymin, xmax, ymax)
bbox <- st_bbox(c(xmin = -121.527765, 
                  ymin = 38.543577, 
                  xmax = -121.435230, 
                  ymax = 38.616183), 
                crs = 4326)

# Convert the bbox to an sf object
bbox_sf <- st_as_sfc(bbox)

# Create a hexagonal grid
hex_grid <- st_make_grid(bbox_sf, cellsize = .005, square = FALSE)

# Convert the grid to an sf object
hex_sf <- st_sf(geometry = hex_grid)



# Define origin/dest points
geo_point <- grid %>%
  st_as_sf() %>%
  st_centroid(geo) %>%
  dplyr::mutate(lon = sf::st_coordinates(.)[,1],
                lat = sf::st_coordinates(.)[,2]) %>%
  mutate(from_x = lon,
         from_y = lat,
         to_x = lon,
         to_y = lat) %>%
  st_drop_geometry()
