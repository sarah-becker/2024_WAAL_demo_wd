
tuck_bpue <- read.csv(here::here("data/Tuck2015_A1_bpue.csv"))


tuck_bpue <- tuck_bpue %>%
  mutate(
    # option A: ifelse
    Fleet = ifelse(Fleet == "JapS", "Pel", Fleet)
    
    # option B: recode
    # dataset = recode(dataset, JapS = "Pel")
  )

mean_t_bpue <- tuck_bpue %>% group_by(Fleet) %>% 
  summarise(mean_bpue = mean(Byc))
#next steps - multiply SG by BPUE estaimtes to get a map of relative BPUE rates for SG, downscale to Bird Islabd (*0.6),
#lets assume for now that BPUE is what I used before, can update tomorrow
BPUE_1000 <- ((0.5460*0.0108)+(0.3276*(0.0066))+(0.4169*0.1111)+(0.0120*0)+(0.2690*0.044)+(0.01060*0.044))/6 

# K_BPUE_1000_PEL <- BPUE_1000
# T_BPUE_1000_PEL <- 0.007157692
# 
# T_BPUE_1000_DEM <- 0.001837540


K_BPUE_1000_PEL <- 0.01
T_BPUE_1000_PEL <- 0.007

T_BPUE_1000_DEM <- 0.029 #https://www.sciencedirect.com/science/article/pii/S0308597X21002293 pre mitigation SG estimates (MINIMUM)


mean_BPUE_pel <- (K_BPUE_1000_PEL+T_BPUE_1000_PEL)/2


BPUE_1pel <- mean_BPUE_pel/1000

BPUE_map_sgpel <- pct_sg*BPUE_1pel

plot(BPUE_map_sgpel)

BPUE_map_bisgpel <- BPUE_map_sgpel*0.6
plot(BPUE_map_bisgpel)


BPUE_1dem <- T_BPUE_1000_DEM/1000
BPUE_map_sgdem <- pct_sg*BPUE_1dem
plot(BPUE_map_sgdem)

BPUE_map_bisgdem <- BPUE_map_sgdem*0.6
plot(BPUE_map_bisgdem)


BPUE_map_bisg_dem <- terra::crop(BPUE_map_bisgdem, ext_dem)
BPUE_map_bisg_pel <- terra::crop(BPUE_map_bisgpel, ext_pel)

plot(BPUE_map_bisg_dem)
plot(BPUE_map_bisg_pel)


global(rastPLL, fun="sum", na.rm=TRUE)[1,1] #total pel hooks mean annual
global(rastDLL, fun="sum", na.rm=TRUE)[1,1] #total dem hooks mean annual

total_hooks_dem # total bird dem hook mean annual - all age classes
total_hooks_pel # total bird pel hook mean annual - all age classes

total_hooks_dem/(global(rastDLL, fun="sum", na.rm=TRUE)[1,1])
total_hooks_pel/(global(rastPLL, fun="sum", na.rm=TRUE)[1,1])

BPUE_bird_dem <- T_BPUE_1000_DEM/(total_hooks_dem/(global(rastDLL, fun="sum", na.rm=TRUE)[1,1]))
BPUE_bird_pel <- mean_BPUE_pel/(total_hooks_pel/(global(rastPLL, fun="sum", na.rm=TRUE)[1,1]))

BPUE_bird_pel_1 <- BPUE_bird_pel/1000
BPUE_bird_pel_1_sg <- pct_sg*BPUE_bird_pel_1
plot(BPUE_bird_pel_1_sg)

BPUE_bird_pel_1_sgbi <- BPUE_bird_pel_1_sg*0.6
plot(BPUE_bird_pel_1_sgbi)


BPUE_bird_dem_1 <- BPUE_bird_dem/1000
BPUE_bird_dem_1_sg <- pct_sg*BPUE_bird_dem_1
plot(BPUE_bird_dem_1_sg)

BPUE_bird_dem_1_sgbi <- BPUE_bird_dem_1_sg*0.6
plot(BPUE_bird_dem_1_sgbi)


 BPUE_map_BPUE_bird_dem_1_sgbi <- terra::crop(BPUE_bird_dem_1_sgbi, ext_dem)
BPUE_map_BPUE_bird_pel_1_sgbi <- terra::crop(BPUE_bird_pel_1_sgbi, ext_pel)
# 
# plot(BPUE_map_bisg_dem)
# plot(BPUE_map_bisg_pel)

#BPUE_map_bisg_dem_fb <- BPUE_map_bisg_dem*0.05681413
byc2_est_all_pel <- BPUE_map_BPUE_bird_pel_1_sgbi*hooks_overlap_pel
plot(byc2_est_all_pel)
byc2_est_all_pel_sum <- global(byc2_est_all_pel, fun="sum", na.rm=TRUE)[1,1] #1.523694
# scaled_exposure_pel <- byc2_est_all_pel*cropped_waal_b_all_pel*16000 #bycatch est*dist*pop
# plot(scaled_exposure_pel)
# global(scaled_exposure_pel, fun="sum", na.rm=TRUE)[1,1] #1.523694



#BPUE_map_bisg_pel_fb <- BPUE_map_bisg_pel*0.05681413
byc2_est_all_dem <- BPUE_map_BPUE_bird_dem_1_sgbi*hooks_overlap_dem
plot(byc2_est_all_dem)
byc2_est_all_dem_sum <- global(byc2_est_all_dem, fun="sum", na.rm=TRUE)[1,1] #1.523694
