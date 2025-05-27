library(tidyverse)
library(terra)
library(here)
library(viridis)

test <- terra::rast("/Users/sarahbecker/Dropbox/CU_ENVS/WAAL_sim_2024/updates_2025/2025_WAAL_demo_wd_updatedR/WA_AllMonths_Female_1990-2009.tif")

# file.exists("/Users/sarahbecker/Dropbox/CU_ENVS/WAAL_sim_2024/updates_2025/2025_WAAL_demo_wd_updatedR/WA_AllMonths_Female_1990-2009.tif")
# list.files("/Users/sarahbecker/Dropbox/CU_ENVS/WAAL_sim_2024/updates_2025/2025_WAAL_demo_wd_updatedR/")
#it was in assue with a space in the file name

terra::plot(test)


# Read CSV
PLLdata <- read.csv(here::here("Pel_LL_effort.csv"))


# Assuming the CSV has columns: lon, lat, value
points <- terra::vect(PLLdata, geom = c("Lon", "Lat"), crs = "EPSG:4326")

# Define raster resolution and extent
#r <- rast(points, resolution = 0.1) # Adjust resolution as needed (resolution = 5) for 5 degree grid

# Your longitude and latitude values are centered at 5-degree intervals (e.g., -47.5, -42.5 for lon and -27.5, -7.5 for lat).
# To properly align your raster, we need to ensure that the raster cell edges match this grid system. Since the points are centers, each grid cell should extend 2.5° in each direction from these points.

# Define raster extent based on min/max lon/lat, ensuring correct alignment
xmin <- min(PLLdata$Lon) - 2.5
xmax <- max(PLLdata$Lon) + 2.5
ymin <- min(PLLdata$Lat) - 2.5
ymax <- max(PLLdata$Lat) + 2.5

# Create raster with 5-degree resolution
r <- rast(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax, resolution = 5, crs = "EPSG:4326")

# Rasterize points, assigning values (replace "value" with your actual column name)
#r <- rasterize(points, r, field = "Hooks", fun = mean)  

r <- rasterize(points, r, field = "Hooks", fun = function(x) mean(x, na.rm = TRUE))
# Plot to check
plot(r)


# Create raster with 5-degree resolution
r2 <- rast(resolution = 5, crs = "EPSG:4326")
r2 <- rasterize(points, r2, field = "Hooks", fun = function(x) mean(x, na.rm = TRUE))
# Plot to check
plot(r2)


#Each grid cell extends ±2.5° around the center points
#Resolution = 5°
#Extent covers all data while keeping the 5° structure.


min(r$Lat)


  
