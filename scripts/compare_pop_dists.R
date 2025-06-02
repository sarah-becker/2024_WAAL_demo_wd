library(tidyverse)
library(terra)
library(here)
library(viridis)

#read in and plot different waal distributions
crozet <- terra::rast("/Users/sarahbecker/Dropbox/CU_ENVS/WAAL_sim_2024/updates_2025/2025_WAAL_demo_wd_updatedR/data/WAAL_dist_Carneiro/Wandering_Albatross_Crozet_year-round.tif")
kerg <- terra::rast("/Users/sarahbecker/Dropbox/CU_ENVS/WAAL_sim_2024/updates_2025/2025_WAAL_demo_wd_updatedR/data/WAAL_dist_Carneiro/Wandering_Albatross_Kerguelen_year-round.tif")
southg <- terra::rast("/Users/sarahbecker/Dropbox/CU_ENVS/WAAL_sim_2024/updates_2025/2025_WAAL_demo_wd_updatedR/data/WAAL_dist_Carneiro/Wandering_Albatross_South_Georgia_year-round.tif")

plot(crozet)
plot(kerg)
plot(southg)


# Calculate the sum of all cells in each raster to normalize them
sum_crozet <- global(crozet, fun = "sum", na.rm = TRUE)
sum_kerg <- global(kerg, fun = "sum", na.rm = TRUE)
sum_southg <- global(southg, fun = "sum", na.rm = TRUE)


# Normalize each raster by dividing by the total sum to make them proportionate (i.e., they sum to 1)
crozet_dist_norm <- crozet / 13135.49
kerg_dist_norm <- kerg / 8601.457
southg_dist_norm <- southg / 18769.6

# Check the result (optional)
print(global(crozet_dist_norm, fun = "sum", na.rm = TRUE))  # Should return 1 (or very close to 1)
print(global(kerg_dist_norm, fun = "sum", na.rm = TRUE))  # Should return 1 (or very close to 1)
print(global(southg_dist_norm, fun = "sum", na.rm = TRUE))  # Should return 1 (or very close to 1)

# You can now use the normalized rasters to calculate the proportions or for further analysis

plot(crozet_dist_norm)
plot(kerg_dist_norm)
plot(southg_dist_norm)


#Nel et al. 2002 cited by Tuck et al. 2015 states that Marion (PEI) and Possesion (Crozet) birds have the same distribution, so I will assume this for now
# In 1998, the total annual breeding population was estimated at 8,500 pairs, equivalent to c. 28,000 mature individuals (Gales 1998). However, current estimates are 
# 1,553 pairs on South Georgia (Georgias del Sur) (Poncet et al. 2006), 
# 1,800 pairs on Prince Edward Island (2008, Ryan et al. 2009), c. 
# 1,900 pairs on Marion Island (2013, ACAP 2009), c. 
# 340 pairs on Iles Crozet (CNRS Chinzè Monitoring Database 2010), c. 
# 354 pairs in Iles Kerguelen (CNRS Chinzè Monitoring Database 2011), and 
# 4 pairs on Macquarie Island (DPIWPE 2010, unpublished data), making a total of c. 6,000 annual breeding pairs. Using the same ratio as Gales (1998) for estimating the number of mature individuals, 
# this would equate to approximately 20,100 mature individuals.

# i do not need total fledged population but can use these breeding pair calculations to compare the relative population size - aka what % of the global population is each population? 
#then I can scale each raster by that % to look at relative %

crozet_global_prop <- (340/6000)
kerg_global_prop <- (354/6000)
pei_global_prop <- ((1800+1900)/6000)
southg_global_prop <- (1553/6000)
birdisland_global_prop <-southg_global_prop*0.6

crozetpei <- crozet


# Multiply each distribution by its global population percentage to get the global population contribution
weighted_crozet_dist <- crozet_dist_norm * crozet_global_prop
plot(weighted_crozet_dist)
weighted_kerg_dist <- kerg_dist_norm * kerg_global_prop
plot(weighted_kerg_dist)
weighted_pei_dist <- crozet_dist_norm * pei_global_prop
plot(weighted_pei_dist)
weighted_southg_dist <- southg_dist_norm * southg_global_prop
plot(weighted_southg_dist)

# Sum all weighted distributions to get the total percentage of the global population in each cell
total_global_population <- weighted_crozet_dist + weighted_kerg_dist + weighted_pei_dist + weighted_southg_dist
plot(total_global_population, main = "Total % global population in each cell")

# Now calculate the percentage of the global population that belongs to the study population
southg_population_pct <- weighted_southg_dist / total_global_population 

# Plot the result to visualize the percentage of the study population
plot(southg_population_pct, main="Percentage of Albatrosses from South Georgia")
plot(weighted_southg_dist, main = "Weighted South Georgia Distribution")

########################
########################


#try just clipped to sg cells
southg_dist_norm_nozero <- subst(southg_dist_norm, 0, NA)
plot(southg_dist_norm_nozero)

southg_dist_norm_no_small <- ifel(southg_dist_norm < 0.0001, NA, r)
plot(southg_dist_norm_no_small)

crozet_dist_norm_clipped <- mask(crozet_dist_norm, southg_dist_norm_no_small)
kerg_dist_norm_clipped <- mask(kerg_dist_norm, southg_dist_norm_no_small)
plot(crozet_dist_norm_clipped)
plot(kerg_dist_norm_clipped)

#Nel et al. 2002 cited by Tuck et al. 2015 states that Marion (PEI) and Possesion (Crozet) birds have the same distribution, so I will assume this for now
# In 1998, the total annual breeding population was estimated at 8,500 pairs, equivalent to c. 28,000 mature individuals (Gales 1998). However, current estimates are 
# 1,553 pairs on South Georgia (Georgias del Sur) (Poncet et al. 2006), 
# 1,800 pairs on Prince Edward Island (2008, Ryan et al. 2009), c. 
# 1,900 pairs on Marion Island (2013, ACAP 2009), c. 
# 340 pairs on Iles Crozet (CNRS Chinzè Monitoring Database 2010), c. 
# 354 pairs in Iles Kerguelen (CNRS Chinzè Monitoring Database 2011), and 
# 4 pairs on Macquarie Island (DPIWPE 2010, unpublished data), making a total of c. 6,000 annual breeding pairs. Using the same ratio as Gales (1998) for estimating the number of mature individuals, 
# this would equate to approximately 20,100 mature individuals.

# i do not need total fledged population but can use these breeding pair calculations to compare the relative population size - aka what % of the global population is each population? 
#then I can scale each raster by that % to look at relative %

crozet_global_prop <- (340/6000)
kerg_global_prop <- (354/6000)
pei_global_prop <- ((1800+1900)/6000)
southg_global_prop <- (1553/6000)
birdisland_global_prop <-southg_global_prop*0.6

crozetpei <- crozet


# Multiply each distribution by its global population percentage to get the global population contribution
weighted_crozet_dist_clipped <- crozet_dist_norm_clipped * crozet_global_prop
plot(weighted_crozet_dist_clipped)
weighted_kerg_dist_clipped <- kerg_dist_norm_clipped * kerg_global_prop
plot(weighted_kerg_dist_clipped)
weighted_pei_dist_clipped <- crozet_dist_norm_clipped * pei_global_prop
plot(weighted_pei_dist_clipped)
weighted_southg_dist_nosmall <- southg_dist_norm_no_small * southg_global_prop
plot(weighted_southg_dist_nosmall)

# Sum all weighted distributions to get the total percentage of the global population in each cell
total_global_population_clipped <- weighted_crozet_dist_clipped + weighted_kerg_dist_clipped + weighted_pei_dist_clipped + weighted_southg_dist_nosmall
plot(total_global_population_clipped, main = "Total % global population in each cell")

# Now calculate the percentage of the global population that belongs to the study population
southg_population_pct_clipped <- weighted_southg_dist_nosmall / total_global_population_clipped 

# Plot the result to visualize the percentage of the study population
plot(southg_population_pct_clipped, main="Percentage of Albatrosses from South Georgia")
ggsave()
plot(weighted_southg_dist_nosmall, main = "Weighted South Georgia Distribution")


#MAKE A GGPLOT VERSION
#plot % SG
library(terra)
library(sf)
library(ggplot2)
library(viridis)

# 1. Convert the SpatRaster to a data.frame
#    include xy=TRUE so you get columns "x" and "y" automatically
southg_population_pct_clippedt_df <- as.data.frame(southg_population_pct_clipped, xy = TRUE)

# 2. Rename the third column to something simple (e.g. "pct")
#    The default name is taken from the raster's "varname"/"name", which is long.
names(southg_population_pct_clippedt_df)[3] <- "pct"

# 3. Now build the ggplot using pct_df
southg_population_pct_clippedt_df_plot <- ggplot(data = southg_population_pct_clippedt_df, aes(x = x, y = y, fill = pct)) +
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
    name     = " ",   # or leave blank if you want no legend title
    limits   = c(0, 1),        # since pct runs 0 → 1
    labels   = scales::percent_format(accuracy = 1)  # show as “0%–100%”
  ) +
  labs(
    title = "Percent wandering albatrosses from South Georgia"
  ) +
  theme_minimal()

# 4. Print or save
print(southg_population_pct_clippedt_df_plot)
# ggsave("pct_sg_plot.png", pct_sg_plot, width=8, height=6)

ggsave("percentSG_bycatch_gg_clipped.png", southg_population_pct_clippedt_df_plot, width = 8, height = 6)





#TRY AGAIN
library(terra)

# 1. Read your three source rasters
#already done above

# 2. Replace NAs with 0
cro0  <- subst(crozet, NA, 0)
ker0  <- subst(kerg,   NA, 0)
sg0   <- subst(southg, NA, 0)

# 3. Normalize each to sum = 1
sum_c  <- global(cro0, fun="sum", na.rm=TRUE)[1]
sum_k  <- global(ker0, fun="sum", na.rm=TRUE)[1]
sum_s  <- global(sg0,  fun="sum", na.rm=TRUE)[1]

cro_n <- cro0 / 13135.49 #sum_c
ker_n <- ker0 / 8601.457 #sum_k
sg_n  <- sg0  /18769.6 # sum_s

# 4. Define your global-population weights
prop_c <- 340/6000           # Crozet
prop_k <- 354/6000           # Kerguelen
prop_s <- 1553/6000          # South Georgia
prop_p <- (1800+1900)/6000   # PEI proxy *will* use cro_n below

# 5. Weight each distribution
w_c  <- cro_n * prop_c
w_k  <- ker_n * prop_k
w_p  <- cro_n * prop_p    # ← Crozet used as PEI proxy
w_s  <- sg_n  * prop_s

# 6. Sum them, dropping any remaining NAs as zeros
#total_global <- terra::sum(w_c, w_k, w_p, w_s, na.rm=TRUE)
total_global <- w_c+ w_k+ w_p+ w_s
# 7. Compute the South-Georgia fraction, masking out zero-total cells
pct_sg <- ifel(total_global > 0,
               w_s / total_global,
               NA)

# 8. Plot
plot(pct_sg, main="Percentage of Albatrosses from South Georgia")

# pct_sg_zero <- ifel(total_global > 0,
#                     w_s / total_global,
#                     0)
# plot(pct_sg_zero, main="Pct from South Georgia (zeros outside)")



thresh <- 1e-5
pct_sg_masked <- mask(pct_sg, total_global > thresh)
plot(pct_sg_masked, main=paste0("Pct from SG (total > ", thresh, ")"))

bird_island <- pct_sg_masked*0.6
plot(bird_island)




#next steps - multiply SG by BPUE estaimtes to get a map of relative BPUE rates for SG, downscale to Bird Islabd (*0.6),
#lets assume for now that BPUE is what I used before, can update tomorrow
BPUE_1000 <- ((0.5460*0.0108)+(0.3276*(0.0066))+(0.4169*0.1111)+(0.0120*0)+(0.2690*0.044)+(0.01060*0.044))/6 
# #bycatch rate per 1000 hooks for South Atlantic (all south atlantic studies averaged) (Klaer 2012, table 2.5) #0.01111316

BPUE_1 <- BPUE_1000/1000

BPUE_map_sg <- pct_sg_masked*BPUE_1000
plot(BPUE_map_sg)

BPUE_map_bisg <- BPUE_map_sg*0.6
plot(BPUE_map_bisg)


#then * by overlap index for each age class, get the sum of the raster for each, and divide each of those by % or pop estaimtes for each age class from Tommy to get per capita rate, then plug those into old model
#crop bpue map first
#comment out dem for now as its confusing since I am using pel rates
#i think I also need to scale bycatch rates by % of pop for each age class, OR redo the work above to get a map of % of overlap of each age class of BI compared to global pop - for now I will just scale it
#WAAL_B_FB
# BPUE_map_bisg_dem <- terra::crop(BPUE_map_bisg, ext_dem)
# byc_est_waal_b_fb_dem <- BPUE_map_bisg_dem*waal_b_a_fb_dem
# plot(byc_est_waal_b_fb_dem)
# byc_est_waal_b_fb_dem_sum <- global(byc_est_waal_b_fb_dem, fun="sum", na.rm=TRUE)[1,1] #0.06749334

BPUE_map_bisg_pel <- terra::crop(BPUE_map_bisg, ext_pel)
#BPUE_map_bisg_pel_fb <- BPUE_map_bisg_pel*0.077746488
byc_est_waal_b_fb_pel <- BPUE_map_bisg_pel*waal_b_a_fb_pel
plot(byc_est_waal_b_fb_pel)
byc_est_waal_b_fb_pel_sum <- global(byc_est_waal_b_fb_pel, fun="sum", na.rm=TRUE)[1,1] #0.0009415926

#WAAL_B_SB
# byc_est_waal_b_sb_dem <- BPUE_map_bisg_dem*waal_b_a_sb_dem
# plot(byc_est_waal_b_sb_dem)
# byc_est_waal_b_sb_dem_sum <- global(byc_est_waal_b_sb_dem, fun="sum", na.rm=TRUE)[1,1] #0.1425332

#BPUE_map_bisg_pel_sb <- BPUE_map_bisg_pel*0.17258959
byc_est_waal_b_sb_pel <- BPUE_map_bisg_pel*waal_b_a_sb_pel
plot(byc_est_waal_b_sb_pel)
byc_est_waal_b_sb_pel_sum <- global(byc_est_waal_b_sb_pel, fun="sum", na.rm=TRUE)[1,1] #0.007166665

#WAAL_B_NB
# byc_est_waal_b_nb_dem <- BPUE_map_bisg_dem*waal_b_a_nb_dem
# plot(byc_est_waal_b_nb_dem)
# byc_est_waal_b_nb_dem_sum <- global(byc_est_waal_b_nb_dem, fun="sum", na.rm=TRUE)[1,1] #0.4134

byc_est_waal_b_nb_pel <- BPUE_map_bisg_pel*waal_b_a_nb_pel
plot(byc_est_waal_b_nb_pel)
byc_est_waal_b_nb_pel_sum <- global(byc_est_waal_b_nb_pel, fun="sum", na.rm=TRUE)[1,1] #0.06609237

#WAAL_B_J2J3
# byc_est_waal_b_j2j3_dem <- BPUE_map_bisg_dem*waal_b_j2j3_dem
# plot(byc_est_waal_b_j2j3_dem)
# byc_est_waal_b_j2j3_dem_sum <- global(byc_est_waal_b_j2j3_dem, fun="sum", na.rm=TRUE)[1,1] #0.12922

byc_est_waal_b_j2j3_pel <- BPUE_map_bisg_pel*waal_b_j2j3_pel
plot(byc_est_waal_b_j2j3_pel)
byc_est_waal_b_j2j3_pel_sum <- global(byc_est_waal_b_j2j3_pel, fun="sum", na.rm=TRUE)[1,1] #0.0242131


#WAAL_B_IMM
# byc_est_waal_b_i_dem <- BPUE_map_bisg_dem*waal_b_i_dem
# plot(byc_est_waal_b_i_dem)
# byc_est_waal_b_i_dem_sum <- global(byc_est_waal_b_i_dem, fun="sum", na.rm=TRUE)[1,1] #0.444619

byc_est_waal_b_i_pel <- BPUE_map_bisg_pel*waal_b_i_pel
plot(byc_est_waal_b_i_pel)
byc_est_waal_b_i_pel_sum <- global(byc_est_waal_b_i_pel, fun="sum", na.rm=TRUE)[1,1] #0.083148

#total pel 
total_pel_byc <- byc_est_waal_b_fb_pel_sum + byc_est_waal_b_sb_pel_sum + byc_est_waal_b_nb_pel_sum + byc_est_waal_b_j2j3_pel_sum + byc_est_waal_b_i_pel_sum

#total dem (BUT BASED ON A PELAGIC BYCATCH RATE SO DISREGARD)
