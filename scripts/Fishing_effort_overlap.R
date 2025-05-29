library(tidyverse)
library(terra)
library(here)
library(viridis)

#read in and plot different waal distributions
waal_f_a <- terra::rast("/Users/sarahbecker/Dropbox/CU_ENVS/WAAL_sim_2024/updates_2025/2025_WAAL_demo_wd_updatedR/data/WAAL_dist_Clay2019/WA_AllMonths_Female_1990-2009.tif")
waal_f_a_fb <- terra::rast("/Users/sarahbecker/Dropbox/CU_ENVS/WAAL_sim_2024/updates_2025/2025_WAAL_demo_wd_updatedR/data/WAAL_dist_Clay2019/WA_AllMonths_Female_FB_1990-2009.tif")
waal_f_a_sb <- terra::rast("/Users/sarahbecker/Dropbox/CU_ENVS/WAAL_sim_2024/updates_2025/2025_WAAL_demo_wd_updatedR/data/WAAL_dist_Clay2019/WA_AllMonths_Female_SB_1990-2009.tif")
waal_f_a_nb <- terra::rast("/Users/sarahbecker/Dropbox/CU_ENVS/WAAL_sim_2024/updates_2025/2025_WAAL_demo_wd_updatedR/data/WAAL_dist_Clay2019/WA_AllMonths_Female_NB_1990-2009.tif")

waal_b_a <- terra::rast("/Users/sarahbecker/Dropbox/CU_ENVS/WAAL_sim_2024/updates_2025/2025_WAAL_demo_wd_updatedR/data/WAAL_dist_Clay2019/WA_AllMonths_Both_1990-2009.tif")
waal_b_a_fb <- terra::rast("/Users/sarahbecker/Dropbox/CU_ENVS/WAAL_sim_2024/updates_2025/2025_WAAL_demo_wd_updatedR/data/WAAL_dist_Clay2019/WA_AllMonths_Both_FB_1990-2009.tif")
waal_b_a_sb <- terra::rast("/Users/sarahbecker/Dropbox/CU_ENVS/WAAL_sim_2024/updates_2025/2025_WAAL_demo_wd_updatedR/data/WAAL_dist_Clay2019/WA_AllMonths_Both_SB_1990-2009.tif")
waal_b_a_nb <- terra::rast("/Users/sarahbecker/Dropbox/CU_ENVS/WAAL_sim_2024/updates_2025/2025_WAAL_demo_wd_updatedR/data/WAAL_dist_Clay2019/WA_AllMonths_Both_NB_1990-2009.tif")

waal_b_j1 <- terra::rast("/Users/sarahbecker/Dropbox/CU_ENVS/WAAL_sim_2024/updates_2025/2025_WAAL_demo_wd_updatedR/data/WAAL_dist_Clay2019/WA_AllMonths_Both_J1_1990-2009.tif")
waal_b_j2j3 <- terra::rast("/Users/sarahbecker/Dropbox/CU_ENVS/WAAL_sim_2024/updates_2025/2025_WAAL_demo_wd_updatedR/data/WAAL_dist_Clay2019/WA_AllMonths_Both_J2+3_1990-2009.tif")
waal_b_i <- terra::rast("/Users/sarahbecker/Dropbox/CU_ENVS/WAAL_sim_2024/updates_2025/2025_WAAL_demo_wd_updatedR/data/WAAL_dist_Clay2019/WA_AllMonths_Both_IMM_1990-2009.tif")

terra::plot(waal_b_a)
terra::plot(waal_b_a_fb)
terra::plot(waal_b_a_sb)
terra::plot(waal_b_a_nb)
terra::plot(waal_b_j1)
terra::plot(waal_b_j2j3)
terra::plot(waal_b_i)

#read in pelagic fishing effort data and map the mean annual effort
# Read CSV
PLLdata <- read.csv(here::here("data/Pel_LL_effort.csv"))

# Calculate the mean fishing effort for each year and location (lon, lat)
library(dplyr)
annual_effort <- PLLdata %>%
  group_by(Lon, Lat, Year) %>%
  summarise(mean_effort = mean(Hooks, na.rm = TRUE), .groups = 'drop')

# Convert to spatial object
points <- terra::vect(annual_effort, geom = c("Lon", "Lat"), crs = "EPSG:4326")

# Define raster extent based on min/max lon/lat, ensuring correct alignment
xmin <- min(annual_effort$Lon) - 2.5
xmax <- max(annual_effort$Lon) + 2.5
ymin <- min(annual_effort$Lat) - 2.5
ymax <- max(annual_effort$Lat) + 2.5

# Create raster with 5-degree resolution
rastPLL <- rast(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax, resolution = 5, crs = "EPSG:4326")

# Rasterize the mean annual fishing effort
rastPLL <- rasterize(points, rastPLL, field = "mean_effort", fun = mean)

# Plot the mean annual fishing effort
plot(rastPLL)



#read in demersal fishing effort data,and merge
ccamlr_demdata <- read.csv(here::here("data/DATA_PRODUCT_725/C2_725.csv"))
#ICCAT_demdata <- read.csv(here::here("data/DemData_Clay2019_Dryad/ICCAT_hooks_all_v1.csv"))
Arg_demdata <- read.csv(here::here("data/DemData_Clay2019_Dryad/Arg_Dem_LL.csv"))
Chile_demdata <- read.csv(here::here("data/DemData_Clay2019_Dryad/Chile_LL.csv"))
Falk_demdata <- read.csv(here::here("data/DemData_Clay2019_Dryad/Falklands demersal LL.csv"))
#IOTC_demdata <- read.csv(here::here("data/DemData_Clay2019_Dryad/IOTC data.csv"))
Namibia_demdata <- read.csv(here::here("data/DemData_Clay2019_Dryad/Namibia Dem Hks Est.csv"))
SAF_demdata <- read.csv(here::here("data/DemData_Clay2019_Dryad/Saf_KKlip_Dem.csv"))

#drop unneeded columns, add label, rename for consistency 
#CCAMLR
ccamlr_demdata_s <- ccamlr_demdata %>% dplyr::select(c( "year", "month" ,"latitude_5deg"  , "longitude_5deg" , "hook_count"  ))
ccamlr_demdata_s <- ccamlr_demdata_s %>% dplyr::rename(Year = year,
                           Month = month,
                           Lat = latitude_5deg,
                           Lon = longitude_5deg,
                           Hooks = hook_count  )
ccamlr_demdata_s$dataset <- "CCAMLR"

# #ICCAT
# ICCAT_demdata_s <- ICCAT_demdata %>% dplyr::select(c( "Year", "Month" ,"Lat5"  , "Lon5" , "estHooks"  ))
# ICCAT_demdata_s <- ICCAT_demdata_s %>% dplyr::rename(Lat = Lat5,
#                                                        Lon = Lon5,
#                                                        Hooks = estHooks  )
# ICCAT_demdata_s$dataset <- "ICCAT"

#ARGENTINA
Arg_demdata_s <- Arg_demdata %>% dplyr::select(c("Year", "Month" ,"Lat"  , "Lng" , "Effort"  ))
Arg_demdata_s <- Arg_demdata_s %>% dplyr::rename(Lon = Lng,
                                                       Hooks = Effort  )
Arg_demdata_s$dataset <- "Argentina"

#CHILE
Chile_demdata_s <- Chile_demdata %>% dplyr::select(c( "Year", "Month" ,"Lat"  , "Lng" , "Effort"  )  )
Chile_demdata_s <- Chile_demdata_s %>% dplyr::rename(Lon = Lng,
                                                     Hooks = Effort  )
Chile_demdata_s$dataset <- "Chile"

#FALKLAND ISLANDS
Falk_demdata_s <- Falk_demdata %>% dplyr::select(c( "Year", "Month" ,"Lat"  , "Lng" , "Effort"  )  )
Falk_demdata_s <- Falk_demdata_s %>% dplyr::rename(Lon = Lng,
                                                     Hooks = Effort  )
Falk_demdata_s$dataset <- "Falklands"

# #IOTC
# IOTC_demdata_s <- IOTC_demdata %>% dplyr::select(c( "Year", "Month" ,"Lat"  , "Lon" , "Hooks"  )  )
# IOTC_demdata_s$dataset <- "IOTC"

#Namibia
Namibia_demdata_s <- Namibia_demdata 
Namibia_demdata_s$dataset <- "Namibia"

#South Africa
SAF_demdata_s <- SAF_demdata 
SAF_demdata_s <- SAF_demdata_s %>% dplyr::rename(Hooks = Effort  )
SAF_demdata_s$dataset <- "South Africa"

#rbind together
#DLLdata <- rbind(ccamlr_demdata_s, ICCAT_demdata_s, Arg_demdata_s, Chile_demdata_s, Falk_demdata_s, IOTC_demdata_s, Namibia_demdata_s, SAF_demdata_s)
DLLdata <- rbind(ccamlr_demdata_s, Arg_demdata_s, Chile_demdata_s, Falk_demdata_s, Namibia_demdata_s, SAF_demdata_s)


#filter to just years within 1990-2009
DLLdata_filtered <- DLLdata %>%
  filter(Year >= 1990 & Year <= 2009)

# Adjust longitude values to ensure they are within the -180 to 180 range
DLLdata_filtered <- DLLdata_filtered %>%
  mutate(Lon = ifelse(Lon > 180, Lon - 360, Lon))

# Check the summary of the adjusted data
summary(DLLdata_filtered)


#summarize annual effort
annual_effort_DLL <- DLLdata_filtered %>%
  group_by(Lon, Lat, Year) %>%
  summarise(mean_effort = mean(Hooks, na.rm = TRUE), .groups = 'drop')

# Convert to spatial object
points2 <- terra::vect(annual_effort_DLL, geom = c("Lon", "Lat"), crs = "EPSG:4326")

# Define raster extent based on min/max lon/lat, ensuring correct alignment
xmin <- min(annual_effort_DLL$Lon) - 2.5
xmax <- max(annual_effort_DLL$Lon) + 2.5
ymin <- min(annual_effort_DLL$Lat) - 2.5
ymax <- max(annual_effort_DLL$Lat) + 2.5

# Create raster with 5-degree resolution
rastDLL<- rast(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax, resolution = 5, crs = "EPSG:4326")

# Rasterize the mean annual fishing effort
rastDLL <- rasterize(points2, r2, field = "mean_effort", fun = mean)

# Plot the mean annual fishing effort
plot(rastDLL)


#check extent of bird files and dem and pel LL
terra::ext(rastDLL) #DLL SpatExtent : -180, 180, -80, 10 (xmin, xmax, ymin, ymax)
terra::ext(rastPLL) #PLL SpatExtent : -180, 180, -50, 65 (xmin, xmax, ymin, ymax)
terra::ext(waal_b_a) #SpatExtent : -180, 180, -90, 0 (xmin, xmax, ymin, ymax) - all bird files the same
terra::ext(waal_b_a_fb)
terra::ext(waal_b_a_nb)
terra::ext(waal_b_a_sb)
terra::ext(waal_b_i)
terra::ext(waal_b_j1)
terra::ext(waal_b_j2j3)
terra::ext(waal_f_a)
terra::ext(waal_f_a_fb)
terra::ext(waal_f_a_nb)
terra::ext(waal_f_a_sb)

#add all waal b together for a tatal version to test first
waal_b_all <- (waal_b_a*.6)+(waal_b_i*.37)+(waal_b_j1*0.01)+(waal_b_j2j3*0.02)
plot(waal_b_all)

#mean across all
# Stack the rasters
raster_stack <- c(waal_b_a, waal_b_i, waal_b_j1, waal_b_j2j3)

# Compute the mean across the rasters
waal_b_all_mean <- app(raster_stack, fun = mean, na.rm = TRUE)
plot(waal_b_all_mean)

#set extent for each overlap calc (pel and dem)
ext_pel <- c(-180, 180, -50, 0)
ext_dem <- c(-180, 180, -80, 0)

cropped_waal_b_all_dem <- terra::crop(waal_b_all, ext_dem)
cropped_waal_b_all_pel <- terra::crop(waal_b_all, ext_pel)
cropped_fishing_dem <- terra::crop(rastDLL, ext_dem)
cropped_fishing_pel <- terra::crop(rastPLL, ext_pel)


testcalc_dem <- cropped_waal_b_all_dem*cropped_fishing_dem
plot(testcalc_dem)

testcalc_pel <- cropped_waal_b_all_pel*cropped_fishing_pel
plot(testcalc_pel)
