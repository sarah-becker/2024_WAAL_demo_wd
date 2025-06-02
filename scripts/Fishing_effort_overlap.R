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

#total effort 
total_pel <- sum(PLLdata$Hooks, na.rm = TRUE)
meanl_pel <-PLLdata %>% group_by(Year) %>% summarize(totalhooks = sum(Hooks, na.rm = TRUE))
meanl_pel_t <- mean(meanl_pel$totalhooks)

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
# annual_effort_DLL <- DLLdata_filtered %>%
#   group_by(Lon, Lat, Year) %>%
#   summarise(mean_effort = mean(Hooks, na.rm = TRUE), .groups = 'drop')

#total effort 
total_dem <- sum(DLLdata_filtered$Hooks, na.rm = TRUE)
meanl_dem <-DLLdata_filtered %>% group_by(Year) %>% summarize(totalhooks = sum(Hooks, na.rm = TRUE))
meanl_dem_t <- mean(meanl_dem$totalhooks)

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
rastDLL <- rasterize(points2, rastDLL, field = "mean_effort", fun = mean)

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
terra::ext(waal_f_a_fb) # these are in a different projection?
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


#ok, now calculate this for each age class
#waal_b_a_fb
cropped_waal_b_a_fb_dem <- terra::crop(waal_b_a_fb, ext_dem)
cropped_waal_b_a_fb_pel <- terra::crop(waal_b_a_fb, ext_pel)

waal_b_a_fb_dem <- cropped_waal_b_a_fb_dem*cropped_fishing_dem
plot(waal_b_a_fb_dem)

waal_b_a_fb_pel <- cropped_waal_b_a_fb_pel*cropped_fishing_pel
plot(waal_b_a_fb_pel)


#waal_b_a_nb
cropped_waal_b_a_nb_dem <- terra::crop(waal_b_a_nb, ext_dem)
cropped_waal_b_a_nb_pel <- terra::crop(waal_b_a_nb, ext_pel)

waal_b_a_nb_dem <- cropped_waal_b_a_nb_dem*cropped_fishing_dem
plot(waal_b_a_nb_dem)

waal_b_a_nb_pel <- cropped_waal_b_a_nb_pel*cropped_fishing_pel
plot(waal_b_a_nb_pel)


#waal_b_a_sb
cropped_waal_b_a_sb_dem <- terra::crop(waal_b_a_sb, ext_dem)
cropped_waal_b_a_sb_pel <- terra::crop(waal_b_a_sb, ext_pel)

waal_b_a_sb_dem <- cropped_waal_b_a_sb_dem*cropped_fishing_dem
plot(waal_b_a_sb_dem)

waal_b_a_sb_pel <- cropped_waal_b_a_sb_pel*cropped_fishing_pel
plot(waal_b_a_sb_pel)


# waal_b_i
cropped_waal_b_i_dem <- terra::crop(waal_b_i, ext_dem)
cropped_waal_b_i_pel <- terra::crop(waal_b_i, ext_pel)

waal_b_i_dem <- cropped_waal_b_i_dem*cropped_fishing_dem
plot(waal_b_i_dem)

waal_b_i_pel <- cropped_waal_b_i_pel*cropped_fishing_pel
plot(waal_b_i_pel)


# waal_b_j1
cropped_waal_b_j1_dem <- terra::crop(waal_b_j1, ext_dem)
cropped_waal_b_j1_pel <- terra::crop(waal_b_j1, ext_pel)

waal_b_j1_dem <- cropped_waal_b_j1_dem*cropped_fishing_dem
plot(waal_b_j1_dem)

waal_b_j1_pel <- cropped_waal_b_j1_pel*cropped_fishing_pel
plot(waal_b_j1_pel)

# waal_b_j2j3
cropped_waal_b_j2j3_dem <- terra::crop(waal_b_j2j3, ext_dem)
cropped_waal_b_j2j3_pel <- terra::crop(waal_b_j2j3, ext_pel)

waal_b_j2j3_dem <- cropped_waal_b_j2j3_dem*cropped_fishing_dem
plot(waal_b_j2j3_dem)

waal_b_j2j3_pel <- cropped_waal_b_j2j3_pel*cropped_fishing_pel
plot(waal_b_j2j3_pel)


#MOdify code to sum total fishing effort in overlapping cells instead of using overlap
library(terra)

# — after you have these two cropped rasters ——
# cropped_waal_b_all_dem   # bird‐density score (WAAL) for demersal zone
# cropped_fishing_dem      # hooks raster for demersal gear

# 1. build a presence mask (TRUE where any birds occur)
bird_mask_dem <- cropped_waal_b_all_dem > 0

# 2. subset (mask) your hooks to only those cells
#    by multiplying by the logical mask (TRUE→1, FALSE→0)
hooks_overlap_dem <- cropped_fishing_dem * bird_mask_dem

# 3. plot to check
plot(hooks_overlap_dem, main="Demersal hooks overlapping birds")

# 4. sum them up
total_hooks_dem <- global(hooks_overlap_dem, fun="sum", na.rm=TRUE)[1,1]
print(total_hooks_dem)

#another way to do the same thing
hooks_overlap_dem2 <- mask(cropped_fishing_dem,
                           bird_mask_dem,
                           maskvalues=0)   # set cells to NA where bird_mask_dem == 0
total_hooks_dem2 <- global(hooks_overlap_dem2, "sum", na.rm=TRUE)[1,1]

# pelagic
bird_mask_pel <- cropped_waal_b_all_pel > 0
hooks_overlap_pel <- cropped_fishing_pel * bird_mask_pel
plot(hooks_overlap_pel, main="Pelagic hooks overlapping birds")
total_hooks_pel <- global(hooks_overlap_pel, "sum", na.rm=TRUE)[1,1]
print(total_hooks_pel)

#now a function for all age class layers

# 1. Define the helper
calc_total_hooks <- function(bird_layers,    # named list of SpatRasters
                             fishing_rast,   # SpatRaster of hooks
                             ext             # numeric c(xmin, xmax, ymin, ymax)
) {
  # crop the fishing‐effort layer once
  hooks_crop <- crop(fishing_rast, ext)
  
  # for each bird layer:
  sapply(bird_layers, function(blr) {
    b_crop <- crop(blr, ext)        # crop the bird density
    mask   <- b_crop > 0            # TRUE where birds occur
    overlap<- hooks_crop * mask     # zero out hooks where no birds
    # sum all remaining hooks
    global(overlap, "sum", na.rm=TRUE)[1,1]
  })
}

# 2. Put your age‐classes into a named list
bird_layers <- list(
  adult = waal_b_a,
  fb    = waal_b_a_fb,
  sb    = waal_b_a_sb,
  nb    = waal_b_a_nb,
  imm   = waal_b_i,
  j1    = waal_b_j1,
  j2j3  = waal_b_j2j3
)

# 3. Define your two extents
ext_dem <- c(-180, 180, -80, 0)
ext_pel <- c(-180, 180, -50, 0)

# 4. Run it for demersal and pelagic
hooks_dem <- calc_total_hooks(bird_layers, rastDLL, ext_dem)
hooks_pel <- calc_total_hooks(bird_layers, rastPLL, ext_pel)

# 5. Put results in a table
results <- data.frame(
  age_class      = names(hooks_dem),
  total_hooks_dem  = as.numeric(hooks_dem),
  total_hooks_pel  = as.numeric(hooks_pel)
)

print(results)

#now make a map for each

# assume bird_layers and ext_dem / ext_pel are already defined, and
# rastDLL (demersal hooks) and rastPLL (pelagic hooks) exist

plot_overlap_maps <- function(bird_layers, fishing_rast, ext, zone_name) {
  # crop the fishing‐effort layer once
  hooks_crop <- crop(fishing_rast, ext)
  
  for(age in names(bird_layers)) {
    # crop bird density to same extent
    b_crop <- crop(bird_layers[[age]], ext)
    # mask = TRUE where any birds occur
    mask   <- b_crop > 0
    # zero‐out hooks where no birds
    overlap <- hooks_crop * mask
    
    # plot it
    plot(
      overlap, 
      main = paste(zone_name, "—", age), 
      col   = viridis(100),
      legend.args = list(text = "Hooks", side = 4, line = 2)
    )
  }
}

# now call for demersal
plot_overlap_maps(
  bird_layers,     # your named list of waal_b_a, waal_b_i, etc.
  rastDLL,         # demersal hooks
  ext_dem,         # c(-180,180,-80,0)
  "Demersal"
)

# and for pelagic
plot_overlap_maps(
  bird_layers,
  rastPLL,
  ext_pel,         # c(-180,180,-50,0)
  "Pelagic"
)

#now with a universal color ramp


plot_overlap_maps_fixed_scale <- function(bird_layers, fishing_rast, ext, zone_name, ncol=2){
  # 1. crop the hooks once
  hooks_crop <- crop(fishing_rast, ext)
  
  # 2. build all of the overlap rasters
  overlaps <- lapply(bird_layers, function(blr){
    b_crop  <- crop(blr, ext)
    mask    <- b_crop > 0
    hooks_crop * mask
  })
  names(overlaps) <- names(bird_layers)
  
  # 3. grab global min & max across them all
  mm <- do.call(rbind, lapply(overlaps, function(r){
    global(r, c("min","max"), na.rm=TRUE)
  }))
  zmin <- min(mm[,"min"], na.rm=TRUE)
  zmax <- max(mm[,"max"], na.rm=TRUE)
  
  # 4. prep a common color ramp + breaks
  ncols  <- 100
  cols   <- viridis(ncols)
  brks   <- seq(zmin, zmax, length.out = ncols + 1)
  
  # 5. set up a multi‐panel layout
  oldpar <- par(mfrow = c(ceiling(length(overlaps)/ncol), ncol),
                mar   = c(4,4,2,1))
  
  # 6. plot each with the SAME zlim + breaks
  for(age in names(overlaps)){
    plot(
      overlaps[[age]],
      main   = paste(zone_name, age),
      col    = cols,
      breaks = brks,
      zlim   = c(zmin, zmax),
      legend.args = list(text = "Hooks", side = 4, line = 2)
    )
  }
  
  # 7. reset graphics
  par(oldpar)
}

# — example calls —
plot_overlap_maps_fixed_scale(
  bird_layers,    # your named list: waal_b_a, waal_b_i, etc.
  rastDLL,        # demersal hooks raster
  ext_dem,        # c(-180,180,-80,0)
  "Demersal"
)

plot_overlap_maps_fixed_scale(
  bird_layers,
  rastPLL,        # pelagic hooks raster
  ext_pel,        # c(-180,180,-50,0)
  "Pelagic"
)

#smaller legend

plot_overlap_maps_one_legend <- function(bird_layers, fishing_rast, ext, zone_name, ncol=2){
  # 1. crop once
  hooks_crop <- crop(fishing_rast, ext)
  
  # 2. calc overlaps
  overlaps <- lapply(bird_layers, function(blr){
    b_crop   <- crop(blr, ext)
    mask     <- b_crop > 0
    hooks_crop * mask
  })
  names(overlaps) <- names(bird_layers)
  
  # 3. get z‐range & palette
  mm   <- do.call(rbind, lapply(overlaps, function(r) global(r, c("min","max"), na.rm=TRUE)))
  zmin <- min(mm[,"min"], na.rm=TRUE);  zmax <- max(mm[,"max"], na.rm=TRUE)
  ncols <- 100
  cols  <- viridis(ncols)
  brks  <- seq(zmin, zmax, length.out=ncols+1)
  
  # 4. set up panels
  nplots <- length(overlaps)
  nrow   <- ceiling(nplots/ncol)
  oldpar <- par(mfrow=c(nrow, ncol), mar=c(4,4,2,1))
  
  # 5. loop: only the last plot gets a legend
  ages <- names(overlaps)
  for(i in seq_along(ages)){
    age <- ages[i]
    show_leg <- (i == nplots)
    plot(
      overlaps[[age]],
      main   = paste(zone_name, age),
      col    = cols,
      breaks = brks,
      zlim   = c(zmin, zmax),
      legend = show_leg,
      legend.args = list(
        text = "Hooks", 
        side = 4, 
        line = 2, 
        cex  = 0.6       # shrink the legend text
      )
    )
  }
  
  # 6. reset
  par(oldpar)
}

# usage for demersal:
plot_overlap_maps_one_legend(
  bird_layers,
  rastDLL,
  ext_dem,
  "Demersal",
  ncol=2
)

# usage for pelagic:
plot_overlap_maps_one_legend(
  bird_layers,
  rastPLL,
  ext_pel,
  "Pelagic",
  ncol=2
)
  

#save files and create as objects
create_and_save_overlap_maps <- function(bird_layers,   # named list of SpatRasters
                                         fishing_rast,  # SpatRaster of hooks
                                         ext,           # numeric c(xmin, xmax, ymin, ymax)
                                         zone_name,     # string for prefix, e.g. "demersal"
                                         out_dir        # directory to write PNGs into
) {
  # ensure output directory exists
  if (!dir.exists(out_dir)) {
    dir.create(out_dir, recursive = TRUE)
  }
  
  # 1. crop hooks once
  hooks_crop <- crop(fishing_rast, ext)
  
  # prepare container for the overlap rasters
  overlap_list <- vector("list", length(bird_layers))
  names(overlap_list) <- names(bird_layers)
  
  # 2–5. loop over age‐classes
  for(age in names(bird_layers)) {
    # crop bird density and build mask
    b_crop  <- crop(bird_layers[[age]], ext)
    mask    <- b_crop > 0
    
    # overlap raster
    overlap <- hooks_crop * mask
    
    # store in list
    overlap_list[[age]] <- overlap
    
    # interactive plot
    plot(
      overlap,
      main = paste(zone_name, age),
      col  = viridis(100),
      legend.args = list(text = "Hooks", side = 4, line = 2, cex = 0.7)
    )
    
    # save PNG
    png(
      filename = file.path(out_dir, paste0(zone_name, "_", age, "_overlap.png")),
      width    = 800, height = 600
    )
    plot(
      overlap,
      main = paste(zone_name, age),
      col  = viridis(100),
      legend.args = list(text = "Hooks", side = 4, line = 2, cex = 0.7)
    )
    dev.off()
  }
  
  # return all the overlap rasters
  return(overlap_list)
}

# — example usage — #

# assume bird_layers, ext_dem, ext_pel, rastDLL, rastPLL are already in your environment

# 1. demersal
dem_overlaps <- create_and_save_overlap_maps(
  bird_layers   = bird_layers,
  fishing_rast  = rastDLL,
  ext           = ext_dem,
  zone_name     = "demersal",
  out_dir       = here::here("output/overlap_maps/demersal")
)

# 2. pelagic
pel_overlaps <- create_and_save_overlap_maps(
  bird_layers   = bird_layers,
  fishing_rast  = rastPLL,
  ext           = ext_pel,
  zone_name     = "pelagic",
  out_dir       = here::here("output/overlap_maps/pelagic")
)

# Now:
# - You’ll have PNGs in "overlap_maps/demersal/" and "overlap_maps/pelagic/"
#   named like "demersal_adult_overlap.png", etc.
# - `dem_overlaps` and `pel_overlaps` are named lists of SpatRasters you can
#   further inspect or write to disk (with writeRaster()) if you like.


#universal color ramp, plots and saves each map

create_and_save_overlap_maps <- function(bird_layers,   # named list of SpatRasters
                                         fishing_rast,  # SpatRaster of hooks
                                         ext,           # numeric c(xmin, xmax, ymin, ymax)
                                         zone_name,     # string prefix, e.g. "pelagic"
                                         out_dir        # directory in which to write PNGs
) {
  # 1. Make sure output dir exists
  if (!dir.exists(out_dir)) dir.create(out_dir, recursive=TRUE)
  
  # 2. Crop the hooks once
  hooks_crop <- crop(fishing_rast, ext)
  
  # 3. Build ALL overlap rasters and store them
  overlaps <- lapply(bird_layers, function(blr) {
    bcr <- crop(blr, ext)
    m   <- bcr > 0
    hooks_crop * m
  })
  names(overlaps) <- names(bird_layers)
  
  # 4. Compute a common z‐range across them all
  stats <- do.call(rbind, lapply(overlaps, function(r) global(r, c("min","max"), na.rm=TRUE)))
  zmin  <- min(stats[,"min"], na.rm=TRUE)
  zmax  <- max(stats[,"max"], na.rm=TRUE)
  
  # 5. Prepare a single viridis palette + breakpoints
  ncols <- 100
  cols  <- viridis(ncols)
  brks  <- seq(zmin, zmax, length.out = ncols + 1)
  
  # 6. Plot & save each map with that common ramp
  for(age in names(overlaps)) {
    # interactive
    plot(
      overlaps[[age]],
      main   = paste(zone_name, age),
      col    = cols,
      breaks = brks,
      zlim   = c(zmin, zmax),
      legend.args = list(text="Hooks", side=4, line=2, cex=0.7)
    )
    # write out PNG
    png(
      filename = file.path(out_dir, paste0(zone_name, "_", age, "_overlap.png")),
      width    = 800, height = 600
    )
    plot(
      overlaps[[age]],
      main   = paste(zone_name, age),
      col    = cols,
      breaks = brks,
      zlim   = c(zmin, zmax),
      legend.args = list(text="Hooks", side=4, line=2, cex=0.7)
    )
    dev.off()
  }
  
  # 7. Return the list of overlap rasters for further use
  return(overlaps)
}

# — example usage — #

# your named list of WAAL layers
bird_layers <- list(
  adult = waal_b_a,
  fb    = waal_b_a_fb,
  sb    = waal_b_a_sb,
  nb    = waal_b_a_nb,
  imm   = waal_b_i,
  j1    = waal_b_j1,
  j2j3  = waal_b_j2j3
)

# your two extents
ext_dem <- c(-180, 180, -80, 0)
ext_pel <- c(-180, 180, -50, 0)

# run for demersal
dem_overlaps <- create_and_save_overlap_maps(
  bird_layers  = bird_layers,
  fishing_rast = rastDLL,
  ext          = ext_dem,
  zone_name    = "demersal",
  out_dir      = here::here("output/overlap_maps_unicolor/demersal")
)

# run for pelagic
pel_overlaps <- create_and_save_overlap_maps(
  bird_layers  = bird_layers,
  fishing_rast = rastPLL,
  ext          = ext_pel,
  zone_name    = "pelagic",
  out_dir      = here::here("output/overlap_maps_unicolor/pelagic")
)

# Now:
# - You have PNGs in "overlap_maps/demersal/" and "overlap_maps/pelagic/"  
#   named like "pelagic_adult_overlap.png", etc.  
# - The returned lists `dem_overlaps` and `pel_overlaps` contain each SpatRaster  
#   (overlaps$adult, overlaps$fb, …) ready for any downstream calculation.

#how to extract objects from lists and use downstream
# grab the adult demersal overlap raster
adult_dem <- dem_overlaps$adult
# or equivalently
adult_dem <- dem_overlaps[["adult"]]

# do something with it, for example sum all hooks again
total_adult_dem_hooks <- global(adult_dem, "sum", na.rm=TRUE)[1,1]

#loop over each
# get total hooks per age-class in demersal zone
totals_dem <- sapply(dem_overlaps, function(r) {
  global(r, "sum", na.rm=TRUE)[1,1]
})
print(totals_dem)
# a named numeric vector: adult fb sb nb imm j1 j2j3

# this will create adult, fb, sb, ... in your global env,
# each pointing to the corresponding dem overlap raster:
list2env(dem_overlaps, envir = .GlobalEnv)

# if you want to prefix them to avoid name clashes:
dem_prefixed <- setNames(dem_overlaps,
                         paste0("dem_", names(dem_overlaps)))
list2env(dem_prefixed, envir = .GlobalEnv)
# now you have dem_adult, dem_fb, dem_sb, etc.

pel_prefixed <- setNames(pel_overlaps,
                         paste0("pel_", names(pel_overlaps)))
list2env(pel_prefixed, envir = .GlobalEnv)

# # write each dem overlap to a GeoTIFF
# invisible(lapply(names(dem_overlaps), function(age) {
#   writeRaster(dem_overlaps[[age]],
#               filename = paste0("dem_overlap_", age, ".tif"),
#               overwrite = TRUE)
# }))
# 
# # OR stack all pelagic overlaps into a multi-layer SpatRaster
# pel_stack <- rast(pel_overlaps)
# plot(pel_stack)  # one panel per age class
# 
# 
# # write each dem overlap to a GeoTIFF
# invisible(lapply(names(dem_overlaps), function(age) {
#   writeRaster(dem_overlaps[[age]],
#               filename = paste0("dem_overlap_", age, ".tif"),
#               overwrite = TRUE)
# }))
# 
# # OR stack all pelagic overlaps into a multi-layer SpatRaster
# pel_stack <- rast(pel_overlaps)
# plot(pel_stack)  # one panel per age class

# In short: treat dem_overlaps and pel_overlaps exactly like lists of rasters—extract 
# by name or position, loop over them with lapply/sapply, or dump them into your environment with list2env() if you prefer standalone objects.


#now as ggplots
library(terra)
library(sf)
library(ggplot2)
library(dplyr)
library(viridis)

# 1. read your land polygon
# adjust this path/format to however you saved it
ne_land <- st_read(here::here("data/ne_10m_land/ne_10m_land.shp")  )

# 2. helper to make & save one ggplot map
plot_and_save_gg <- function(overlap_rast, zone, age, ext, out_dir){
  # convert to data.frame for ggplot
  df <- as.data.frame(overlap_rast, xy=TRUE)
  names(df)[3] <- "hooks"
  
  # build the plot
  p <- ggplot(df, aes(x=x, y=y)) +
    geom_raster(aes(fill = hooks)) +
    geom_sf(data = ne_land, inherit.aes=FALSE, fill="grey80", color=NA) +
    coord_sf(xlim = ext[1:2], ylim = ext[3:4], expand=FALSE) +
    scale_fill_viridis_c(na.value="transparent", name="Hooks") +
    labs(title = paste(zone, "—", age)) +
    theme_minimal()
  
  # ensure output dir
  if(!dir.exists(out_dir)) dir.create(out_dir, recursive=TRUE)
  # save PNG
  ggsave(
    filename = file.path(out_dir, paste0(zone, "_", age, "_gg.png")),
    plot     = p,
    width    = 8, height = 6
  )
  
  return(p)
}

# 3. loop over dem overlaps
ext_dem <- c(-180, 180, -80, 0)
dem_maps <- lapply(names(dem_overlaps), function(age){
  plot_and_save_gg(
    overlap_rast = dem_overlaps[[age]],
    zone         = "Demersal",
    age          = age,
    ext          = ext_dem,
    out_dir      = here::here("output/ggmaps/demersal")
  )
})
names(dem_maps) <- names(dem_overlaps)

# 4. loop over pel overlaps
ext_pel <- c(-180, 180, -50, 0)
pel_maps <- lapply(names(pel_overlaps), function(age){
  plot_and_save_gg(
    overlap_rast = pel_overlaps[[age]],
    zone         = "Pelagic",
    age          = age,
    ext          = ext_pel,
    out_dir      = here::here("output/ggmaps/pelagic")
  )
})
names(pel_maps) <- names(pel_overlaps)

# Now:
# - `dem_maps` and `pel_maps` are named lists of ggplot objects
#   (e.g. dem_maps$adult, pel_maps$j1, etc.) you can print or further customize.
# - PNGs are in “ggmaps/demersal/” and “ggmaps/pelagic/”.

#now with universal colors

# 1. load your land once
ne_land <- st_read(here::here("data/ne_10m_land/ne_10m_land.shp")  )

# 2. extract global z-ranges for demersal and pelagic separately
#    (you could also combine them if you want one ramp for *everything*)
get_range <- function(overlaps){
  st <- do.call(rbind, lapply(overlaps, function(r){
    terra::global(r, c("min","max"), na.rm=TRUE)
  }))
  c(min = min(st[,"min"], na.rm=TRUE),
    max = max(st[,"max"], na.rm=TRUE))
}
dem_range <- get_range(dem_overlaps)   # e.g. c(min=0, max=12345)
pel_range <- get_range(pel_overlaps)

# 3. tweak the plotting function to take limits
plot_and_save_gg_fixed <- function(overlap_rast, zone, age, ext, out_dir, zlim){
  df <- as.data.frame(overlap_rast, xy=TRUE)
  names(df)[3] <- "hooks"
  
  p <- ggplot(df, aes(x=x, y=y)) +
    geom_raster(aes(fill = hooks)) +
    geom_sf(data = ne_land, inherit.aes=FALSE,
            fill="grey80", color=NA) +
    coord_sf(xlim = ext[1:2], ylim = ext[3:4], expand=FALSE) +
    scale_fill_viridis_c(
      na.value     = "transparent",
      name         = "Hooks",
      limits       = zlim,
      oob          = scales::squish
    ) +
    labs(title = paste(zone, "—", age)) +
    theme_minimal()
  
  dir.create(out_dir, showWarnings=FALSE, recursive=TRUE)
  ggsave(
    filename = file.path(out_dir, paste0(zone, "_", age, "_gg.png")),
    plot     = p,
    width    = 8, height = 6
  )
  return(p)
}

# 4. remake your maps with fixed scales

ext_dem <- c(-180, 180, -80, 0)
ext_pel <- c(-180, 180, -50, 0)

dem_maps_fixed <- lapply(names(dem_overlaps), function(age){
  plot_and_save_gg_fixed(
    overlap_rast = dem_overlaps[[age]],
    zone         = "Demersal",
    age          = age,
    ext          = ext_dem,
    out_dir      = here::here("output/ggmaps_unicolor/demersal_fixed"),
    zlim         = dem_range
  )
})
names(dem_maps_fixed) <- names(dem_overlaps)

pel_maps_fixed <- lapply(names(pel_overlaps), function(age){
  plot_and_save_gg_fixed(
    overlap_rast = pel_overlaps[[age]],
    zone         = "Pelagic",
    age          = age,
    ext          = ext_pel,
    out_dir      = here::here("output/ggmaps_unicolor/pelagic_fixed"),
    zlim         = pel_range
  )
})
names(pel_maps_fixed) <- names(pel_overlaps)


#now overlap and density maps
library(terra)
library(sf)
library(ggplot2)
library(viridis)
library(scales)

# 1. load land
ne_land <- st_read(here::here("data/ne_10m_land/ne_10m_land.shp")  )

# 2. define your extents
ext_dem <- c(-180, 180, -80, 0)
ext_pel <- c(-180, 180, -50, 0)

# 3. helper to get [min,max] across a list of rasters cropped to ext
get_range <- function(ras_list, ext) {
  rngs <- lapply(ras_list, function(r) {
    g <- global(crop(r, ext), c("min","max"), na.rm=TRUE)
    as.numeric(g)
  }) %>% do.call(rbind, .)
  c(min = min(rngs[,1], na.rm=TRUE),
    max = max(rngs[,2], na.rm=TRUE))
}

# compute fixed scales
dem_range <- get_range(dem_overlaps, ext_dem)
pel_range <- get_range(pel_overlaps, ext_pel)

# 4. generic ggplot+save function
plot_and_save_overlap <- function(ras_list, ext, out_dir, zlim) {
  dir.create(out_dir, recursive=TRUE, showWarnings=FALSE)
  plots <- list()
  
  for(age in names(ras_list)) {
    # prep data.frame
    r   <- crop(ras_list[[age]], ext)
    df  <- as.data.frame(r, xy=TRUE)
    names(df)[3] <- "value"
    
    # build plot
    p <- ggplot(df, aes(x=x, y=y)) +
      geom_raster(aes(fill = value)) +
      geom_sf(data = ne_land, inherit.aes=FALSE,
              fill="grey80", color=NA) +
      coord_sf(xlim = ext[1:2], ylim = ext[3:4], expand=FALSE) +
      scale_fill_viridis_c(
        name   = "Hooks × Density",
        limits = zlim,
        oob    = squish,
        na.value = "transparent"
      ) +
      labs(title = paste(age)) +
      theme_minimal()
    
    # save PNG
    ggsave(
      filename = file.path(out_dir, paste0(age, "_overlap.png")),
      plot     = p,
      width    = 8, height = 6
    )
    
    plots[[age]] <- p
  }
  return(plots)
}

# 5. produce & save
dem_overlap_maps <- plot_and_save_overlap(
  dem_overlaps,
  ext     = ext_dem,
  out_dir = here::here("output/ggmaps/overlap/demersal"),
  zlim    = dem_range
)

pel_overlap_maps <- plot_and_save_overlap(
  pel_overlaps,
  ext     = ext_pel,
  out_dir = here::here("output/ggmaps/overlap/pelagic"),
  zlim    = pel_range
)

# Now:
# - dem_overlap_maps$adult, dem_overlap_maps$fb, …  are your Demersal ggplots
# - pel_overlap_maps$adult, pel_overlap_maps$fb, …  are your Pelagic ggplots
# - PNGs are saved under ggmaps/overlap/demersal/ and ggmaps/overlap/pelagic/


#new try at mapping
library(terra)
library(sf)
library(ggplot2)
library(viridis)
library(scales)

# load land
ne_land <- st_read(here::here("data/ne_10m_land/ne_10m_land.shp")  )


# 2. Define your raster object names
dem_names  <- c("waal_b_a_fb_dem",  "waal_b_a_sb_dem",  "waal_b_a_nb_dem",
                "waal_b_i_dem",     "waal_b_j1_dem",   "waal_b_j2j3_dem")
pel_names  <- c("waal_b_a_fb_pel",  "waal_b_a_sb_pel",  "waal_b_a_nb_pel",
                "waal_b_i_pel",     "waal_b_j1_pel",   "waal_b_j2j3_pel")
dens_names <- c("waal_b_a",         "waal_b_a_fb",      "waal_b_a_sb",
                "waal_b_a_nb",      "waal_b_i",         "waal_b_j1",
                "waal_b_j2j3")

# 3. Define extents
ext_dem <- c(-180, 180, -80, 0)
ext_pel <- c(-180, 180, -50, 0)
ext_den <- c(-180, 180, -90, 0)

# 4. Helper to compute z‐limits for a set of objects
get_zlim <- function(names_vec, ext) {
  mins <- sapply(names_vec, function(nm) {
    global(crop(get(nm), ext), "min", na.rm=TRUE)[1,1]
  })
  maxs <- sapply(names_vec, function(nm) {
    global(crop(get(nm), ext), "max", na.rm=TRUE)[1,1]
  })
  c(min = min(mins, na.rm=TRUE),
    max = max(maxs, na.rm=TRUE))
}

# 5. Compute fixed colour limits
dem_zlim <- get_zlim(dem_names,  ext_dem)
pel_zlim <- get_zlim(pel_names,  ext_pel)
den_zlim <- get_zlim(dens_names, ext_den)

# 6. Loop for demersal overlap maps
dir.create("ggmaps/demersal_overlap", recursive=TRUE, showWarnings=FALSE)
for(nm in dem_names) {
  r  <- crop(get(nm), ext_dem)
  df <- as.data.frame(r, xy=TRUE)
  names(df)[3] <- "value"
  
  p <- ggplot(df, aes(x=x, y=y, fill=value)) +
    geom_raster() +
    geom_sf(data = ne_land, inherit.aes=FALSE,
            fill="grey80", color=NA) +
    coord_sf(xlim = ext_dem[1:2], ylim = ext_dem[3:4], expand=FALSE) +
    scale_fill_viridis_c(name    = "Overlap",
                         limits  = dem_zlim,
                         oob      = squish,
                         na.value = "transparent") +
    ggtitle(sub("_dem$", "", nm)) +
    theme_minimal()
  
  ggsave(file.path("ggmaps/demersal_overlap", paste0(nm, ".png")),
         p, width=8, height=6)
}

# 7. Loop for pelagic overlap maps
dir.create("ggmaps/pelagic_overlap", recursive=TRUE, showWarnings=FALSE)
for(nm in pel_names) {
  r  <- crop(get(nm), ext_pel)
  df <- as.data.frame(r, xy=TRUE)
  names(df)[3] <- "value"
  
  p <- ggplot(df, aes(x=x, y=y, fill=value)) +
    geom_raster() +
    geom_sf(data = ne_land, inherit.aes=FALSE,
            fill="grey80", color=NA) +
    coord_sf(xlim = ext_pel[1:2], ylim = ext_pel[3:4], expand=FALSE) +
    scale_fill_viridis_c(name    = "Overlap",
                         limits  = pel_zlim,
                         oob      = squish,
                         na.value = "transparent") +
    ggtitle(sub("_pel$", "", nm)) +
    theme_minimal()
  
  ggsave(file.path("ggmaps/pelagic_overlap", paste0(nm, ".png")),
         p, width=8, height=6)
}

# 8. Loop for density maps
dir.create("ggmaps/density", recursive=TRUE, showWarnings=FALSE)
for(nm in dens_names) {
  r  <- crop(get(nm), ext_den)
  df <- as.data.frame(r, xy=TRUE)
  names(df)[3] <- "value"
  
  p <- ggplot(df, aes(x=x, y=y, fill=value)) +
    geom_raster() +
    geom_sf(data = ne_land, inherit.aes=FALSE,
            fill="grey80", color=NA) +
    coord_sf(xlim = ext_den[1:2], ylim = ext_den[3:4], expand=FALSE) +
    scale_fill_viridis_c(name    = "Density",
                         limits  = den_zlim,
                         oob      = squish,
                         na.value = "transparent") +
    ggtitle(nm) +
    theme_minimal()
  
  ggsave(file.path("ggmaps/density", paste0(nm, ".png")),
         p, width=8, height=6)
}

#now with different ramps

# load land
ne_land <- st_read(here::here("data/ne_10m_land/ne_10m_land.shp")  )

# names and extents
dem_names  <- c("waal_b_a_fb_dem","waal_b_a_sb_dem","waal_b_a_nb_dem",
                "waal_b_i_dem","waal_b_j1_dem","waal_b_j2j3_dem")
pel_names  <- c("waal_b_a_fb_pel","waal_b_a_sb_pel","waal_b_a_nb_pel",
                "waal_b_i_pel","waal_b_j1_pel","waal_b_j2j3_pel")
dens_names <- c("waal_b_a","waal_b_a_fb","waal_b_a_sb","waal_b_a_nb",
                "waal_b_i","waal_b_j1","waal_b_j2j3")

ext_dem <- c(-180, 180, -80, 0)
ext_pel <- c(-180, 180, -50, 0)
ext_den <- c(-180, 180, -90, 0)

# 1) Demersal overlap (per-map scales)
dir.create("ggmaps/demersal_overlap_nouni", recursive=TRUE, showWarnings=FALSE)
for(nm in dem_names) {
  r  <- crop(get(nm), ext_dem)
  df <- as.data.frame(r, xy=TRUE)
  names(df)[3] <- "value"
  
  p <- ggplot(df, aes(x=x, y=y, fill=value)) +
    geom_raster() +
    geom_sf(data = ne_land, inherit.aes=FALSE,
            fill="grey80", color=NA) +
    coord_sf(xlim = ext_dem[1:2], ylim = ext_dem[3:4], expand=FALSE) +
    scale_fill_viridis_c(name="Overlap") +
    ggtitle(sub("_dem$", "", nm)) +
    theme_minimal()
  
  ggsave(file.path("ggmaps/demersal_overlap_nouni", paste0(nm, ".png")),
         p, width=8, height=6)
}

# 2) Pelagic overlap (per-map scales)
dir.create("ggmaps/pelagic_overlap_nouni", recursive=TRUE, showWarnings=FALSE)
for(nm in pel_names) {
  r  <- crop(get(nm), ext_pel)
  df <- as.data.frame(r, xy=TRUE)
  names(df)[3] <- "value"
  
  p <- ggplot(df, aes(x=x, y=y, fill=value)) +
    geom_raster() +
    geom_sf(data = ne_land, inherit.aes=FALSE,
            fill="grey80", color=NA) +
    coord_sf(xlim = ext_pel[1:2], ylim = ext_pel[3:4], expand=FALSE) +
    scale_fill_viridis_c(name="Overlap") +
    ggtitle(sub("_pel$", "", nm)) +
    theme_minimal()
  
  ggsave(file.path("ggmaps/pelagic_overlap_nouni", paste0(nm, ".png")),
         p, width=8, height=6)
}

# 3) Density maps (per-map scales)
dir.create("ggmaps/density_nouni", recursive=TRUE, showWarnings=FALSE)
for(nm in dens_names) {
  r  <- crop(get(nm), ext_den)
  df <- as.data.frame(r, xy=TRUE)
  names(df)[3] <- "value"
  
  p <- ggplot(df, aes(x=x, y=y, fill=value)) +
    geom_raster() +
    geom_sf(data = ne_land, inherit.aes=FALSE,
            fill="grey80", color=NA) +
    coord_sf(xlim = ext_den[1:2], ylim = ext_den[3:4], expand=FALSE) +
    scale_fill_viridis_c(name="Density") +
    ggtitle(nm) +
    theme_minimal()
  
  ggsave(file.path("ggmaps/density_nouni", paste0(nm, ".png")),
         p, width=8, height=6)
}



#MEAN EFFORT MAPS FOR ALL STAGES
#plot % SG
library(terra)
library(sf)
library(ggplot2)
library(viridis)

# 1. Convert the SpatRaster to a data.frame
#    include xy=TRUE so you get columns "x" and "y" automatically
rastDLL_df <- as.data.frame(rastDLL, xy = TRUE)

# 2. Rename the third column to something simple (e.g. "pct")
#    The default name is taken from the raster's "varname"/"name", which is long.
names(rastDLL_df)[3] <- "effort"

# 3. Now build the ggplot using pct_df
testcalc_dem_df_plot <- ggplot(data = rastDLL_df, aes(x = x, y = y, fill = effort)) +
  geom_raster() +
  geom_sf(
    data = ne_land, 
    inherit.aes = FALSE,
    fill = "grey80", 
    color = NA
  ) +
  coord_sf(
    xlim   = c(-180, 180),
    ylim   = c(-90, 0),
    expand = FALSE
  ) +
  scale_fill_viridis_c(
    name     = "# hooks ",   # or leave blank if you want no legend title
  #  limits   = c(0, 1),        # since pct runs 0 → 1
   # labels   = scales::percent_format(accuracy = 1)  # show as “0%–100%”
  ) +
  labs(
    title = "Mean annual demersal fishing effort"
  ) +
  theme_minimal()

# 4. Print or save
print(testcalc_dem_df_plot)
# ggsave("pct_sg_plot.png", pct_sg_plot, width=8, height=6)

ggsave("mean_annual_dem_effort_gg.png", testcalc_dem_df_plot, width = 8, height = 6)




# 1. Convert the SpatRaster to a data.frame
#    include xy=TRUE so you get columns "x" and "y" automatically
rastPLL_df <- as.data.frame(rastPLL, xy = TRUE)

# 2. Rename the third column to something simple (e.g. "pct")
#    The default name is taken from the raster's "varname"/"name", which is long.
names(rastPLL_df)[3] <- "effort"

# 3. Now build the ggplot using pct_df
testcalc_pel_df_plot <- ggplot(data = rastPLL_df, aes(x = x, y = y, fill = effort)) +
  geom_raster() +
  geom_sf(
    data = ne_land, 
    inherit.aes = FALSE,
    fill = "grey80", 
    color = NA
  ) +
  coord_sf(
    xlim   = c(-180, 180),
    ylim   = c(-90, 0),
    expand = FALSE
  ) +
  scale_fill_viridis_c(
    name     = "# hooks ",   # or leave blank if you want no legend title
    #  limits   = c(0, 1),        # since pct runs 0 → 1
    # labels   = scales::percent_format(accuracy = 1)  # show as “0%–100%”
  ) +
  labs(
    title = "Mean annual pelagic fishing effort"
  ) +
  theme_minimal()

# 4. Print or save
print(testcalc_pel_df_plot)
# ggsave("pct_sg_plot.png", pct_sg_plot, width=8, height=6)

ggsave("mean_annual_pel_effort_gg.png", testcalc_pel_df_plot, width = 8, height = 6)





#REMAKE JUST DIST MAPS
#now with different ramps

# load land
ne_land <- st_read(here::here("data/ne_10m_land/ne_10m_land.shp")  )

#remake maps with small values cropped out
waal_b_a_small <- ifel(waal_b_a < 0.0001, NA, r)
waal_b_a_fb_small <- ifel(waal_b_a_fb < 0.0001, NA, r)
waal_b_a_sb_small <- ifel(waal_b_a_sb < 0.0001, NA, r)
waal_b_a_nb_small <- ifel(waal_b_a_nb < 0.0001, NA, r)
waal_b_i_small <- ifel(waal_b_i < 0.0001, NA, r)
waal_b_j1_small <- ifel(waal_b_j1 < 0.0001, NA, r)
waal_b_j2j3_small <- ifel(waal_b_j2j3 < 0.0001, NA, r)

# names and extents
dens_names <- c("waal_b_a_small","waal_b_a_fb_small","waal_b_a_sb_small","waal_b_a_nb_small",
                "waal_b_i_small","waal_b_j1_small","waal_b_j2j3_small")

ext_den <- c(-180, 180, -90, 0)



# 3) Density maps (per-map scales)
dir.create("ggmaps/density_clipped_nouni", recursive=TRUE, showWarnings=FALSE)
for(nm in dens_names) {
  r  <- crop(get(nm), ext_den)
  df <- as.data.frame(r, xy=TRUE)
  names(df)[3] <- "value"
  
  p <- ggplot(df, aes(x=x, y=y, fill=value)) +
    geom_raster() +
    geom_sf(data = ne_land, inherit.aes=FALSE,
            fill="grey80", color=NA) +
    coord_sf(xlim = ext_den[1:2], ylim = ext_den[3:4], expand=FALSE) +
    scale_fill_viridis_c(name="Density") +
    ggtitle(nm) +
    theme_minimal()
  
  ggsave(file.path("ggmaps/density_clipped_nouni", paste0(nm, ".png")),
         p, width=8, height=6)
}


