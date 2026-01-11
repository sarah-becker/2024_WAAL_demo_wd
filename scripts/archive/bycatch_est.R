
library(tidyverse)

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

#T_BPUE_1000_DEM <- 0.029 #https://www.sciencedirect.com/science/article/pii/S0308597X21002293 pre mitigation SG estimates (MINIMUM)

T_BPUE_1000_DEM<- (0.001837540+0.029)/2
# #bycatch rate per 1000 hooks for South Atlantic (all south atlantic studies averaged) (Klaer 2012, table 2.5) #0.01111316
mean_BPUE_pel <- (K_BPUE_1000_PEL+T_BPUE_1000_PEL)/2


BPUE_1 <- mean_BPUE_pel/1000

BPUE_map_sg <- pct_sg*BPUE_1

plot(BPUE_map_sg)

BPUE_map_bisg <- BPUE_map_sg*0.6
plot(BPUE_map_bisg)



BPUE_1dem <- T_BPUE_1000_DEM/1000
BPUE_map_sgdem <- pct_sg*BPUE_1dem #pct_sg)masked  rate got messed up use pct_sg instead 
plot(BPUE_map_sgdem)

BPUE_map_bisgdem <- BPUE_map_sgdem*0.6
plot(BPUE_map_bisgdem)



dem_props <- read.csv(here::here("data/WAAL_dist_Clay2019/Dem_props copy.csv"))
dem_props_mean <- dem_props %>% group_by(Dem_class) %>% summarise(mean_prop = mean(Prop), mean_pop = mean (Pop))

#then * by overlap index for each age class, get the sum of the raster for each, and divide each of those by % or pop estaimtes for each age class from Tommy to get per capita rate, then plug those into old model
#crop bpue map first
#comment out dem for now as its confusing since I am using pel rates
#i think I also need to scale bycatch rates by % of pop for each age class, OR redo the work above to get a map of % of overlap of each age class of BI compared to global pop - for now I will just scale it
#WAAL_B_FB

BPUE_map_bisg_dem <- terra::crop(BPUE_map_bisgdem, ext_dem)

BPUE_map_bisg_dem_fb <- BPUE_map_bisg_dem*0.05681413
byc_est_waal_b_fb_dem <- BPUE_map_bisg_dem_fb*dem_fb
plot(byc_est_waal_b_fb_dem)
byc_est_waal_b_fb_dem_sum <- global(byc_est_waal_b_fb_dem, fun="sum", na.rm=TRUE)[1,1] #1.523694


BPUE_map_bisg_pel <- terra::crop(BPUE_map_bisg, ext_pel)

BPUE_map_bisg_pel_fb <- BPUE_map_bisg_pel*0.05681413
byc_est_waal_b_fb_pel <- BPUE_map_bisg_pel_fb*pel_fb
plot(byc_est_waal_b_fb_pel)
byc_est_waal_b_fb_pel_sum <- global(byc_est_waal_b_fb_pel, fun="sum", na.rm=TRUE)[1,1] #8.851898

#WAAL_B_SB
BPUE_map_bisg_dem_sb <- BPUE_map_bisg_dem*0.16853494
byc_est_waal_b_sb_dem <- BPUE_map_bisg_dem_sb*dem_sb
plot(byc_est_waal_b_sb_dem)
byc_est_waal_b_sb_dem_sum <- global(byc_est_waal_b_sb_dem, fun="sum", na.rm=TRUE)[1,1] #10.45076

BPUE_map_bisg_pel_sb <- BPUE_map_bisg_pel*0.16853494
byc_est_waal_b_sb_pel <- BPUE_map_bisg_pel_sb*pel_sb
plot(byc_est_waal_b_sb_pel)
byc_est_waal_b_sb_pel_sum <- global(byc_est_waal_b_sb_pel, fun="sum", na.rm=TRUE)[1,1] #4.207165

#WAAL_B_NB
BPUE_map_bisg_dem_nb <- BPUE_map_bisg_dem*0.24361524
byc_est_waal_b_nb_dem <- BPUE_map_bisg_dem_nb*dem_nb
plot(byc_est_waal_b_nb_dem)
byc_est_waal_b_nb_dem_sum <- global(byc_est_waal_b_nb_dem, fun="sum", na.rm=TRUE)[1,1] #34.48033

BPUE_map_bisg_pel_nb <- BPUE_map_bisg_pel*0.24361524
byc_est_waal_b_nb_pel <- BPUE_map_bisg_pel_nb*pel_nb
plot(byc_est_waal_b_nb_pel)
byc_est_waal_b_nb_pel_sum <- global(byc_est_waal_b_nb_pel, fun="sum", na.rm=TRUE)[1,1] #29.44379

#WAAL_B_J2J3
BPUE_map_bisg_dem_j2j3 <- BPUE_map_bisg_dem*0.09981334
byc_est_waal_b_j2j3_dem <- BPUE_map_bisg_dem_j2j3*dem_j2j3
plot(byc_est_waal_b_j2j3_dem)
byc_est_waal_b_j2j3_dem_sum <- global(byc_est_waal_b_j2j3_dem, fun="sum", na.rm=TRUE)[1,1] #13.80478

BPUE_map_bisg_pel_j2j3 <- BPUE_map_bisg_pel*0.09981334
byc_est_waal_b_j2j3_pel <- BPUE_map_bisg_pel_j2j3*pel_j2j3
plot(byc_est_waal_b_j2j3_pel)
byc_est_waal_b_j2j3_pel_sum <- global(byc_est_waal_b_j2j3_pel, fun="sum", na.rm=TRUE)[1,1] #12.45385


#WAAL_B_IMM
BPUE_map_bisg_dem_i<- BPUE_map_bisg_dem*0.36345672
byc_est_waal_b_i_dem <- BPUE_map_bisg_dem_i*dem_imm
plot(byc_est_waal_b_i_dem)
byc_est_waal_b_i_dem_sum <- global(byc_est_waal_b_i_dem, fun="sum", na.rm=TRUE)[1,1] #[1] 42.43764

BPUE_map_bisg_pel_i <- BPUE_map_bisg_pel*0.36345672
plot(BPUE_map_bisg_pel_i)
byc_est_waal_b_i_pel <- BPUE_map_bisg_pel_i*pel_imm
plot(byc_est_waal_b_i_pel)
byc_est_waal_b_i_pel_sum <- global(byc_est_waal_b_i_pel, fun="sum", na.rm=TRUE)[1,1] #38.84094

#total pel 
total_pel_byc <- byc_est_waal_b_fb_pel_sum + byc_est_waal_b_sb_pel_sum + byc_est_waal_b_nb_pel_sum + byc_est_waal_b_j2j3_pel_sum + byc_est_waal_b_i_pel_sum #93.79764

#total dem 
total_dem_byc <- byc_est_waal_b_fb_dem_sum + byc_est_waal_b_sb_dem_sum + byc_est_waal_b_nb_dem_sum + byc_est_waal_b_j2j3_dem_sum + byc_est_waal_b_i_dem_sum #93.79764


#total maps
pel_byc <- byc_est_waal_b_fb_pel + byc_est_waal_b_i_pel + byc_est_waal_b_j2j3_pel + byc_est_waal_b_nb_pel + byc_est_waal_b_sb_pel
plot(pel_byc)

sum_pel <- global(pel_byc, fun="sum", na.rm=TRUE)[1,1]



dem_byc <- byc_est_waal_b_fb_dem + byc_est_waal_b_i_dem + byc_est_waal_b_j2j3_dem + byc_est_waal_b_nb_dem + byc_est_waal_b_sb_dem
plot(dem_byc)
sum_dem <- global(dem_byc, fun="sum", na.rm=TRUE)[1,1]


# 2. Convert your two SpatRasters to data.frames
dem_df <- as.data.frame(dem_byc, xy = TRUE)
names(dem_df)[3] <- "bycatch"

pel_df <- as.data.frame(pel_byc, xy = TRUE)
names(pel_df)[3] <- "bycatch"

# 3. Grab their extents for coord limits
ext_dem <- ext(dem_byc)  # c(xmin, xmax, ymin, ymax)

ext_pel <- ext(pel_byc)

# 4. Make the demersal bycatch map
p_dem <- ggplot() +
  geom_raster(data = dem_df, aes(x = x, y = y, fill = bycatch)) +
  geom_sf(data = ne_land, inherit.aes = FALSE,
          fill = "grey80", color = NA) +
  coord_sf(xlim = c(ext_dem[1], ext_dem[2]),
           ylim = c(ext_dem[3], ext_dem[4]),
           expand = FALSE) +
  scale_fill_viridis_c(name = "Bycatch") +
  labs(title = "Demersal Bycatch Density") +
  theme_minimal()

# 5. Make the pelagic bycatch map
p_pel <- ggplot() +
  geom_raster(data = pel_df, aes(x = x, y = y, fill = bycatch)) +
  geom_sf(data = ne_land, inherit.aes = FALSE,
          fill = "grey80", color = NA) +
  coord_sf(xlim = c(ext_pel[1], ext_pel[2]),
           ylim = c(ext_pel[3], ext_pel[4]),
           expand = FALSE) +
  scale_fill_viridis_c(name = "Bycatch") +
  labs(title = "Pelagic Bycatch Density") +
  theme_minimal()

# 6. Display
print(p_dem)
print(p_pel)

# (Optional) Save to disk
ggsave("demersal_bycatch_gg.png", p_dem, width = 8, height = 6)
ggsave("pelagic_bycatch_gg.png", p_pel, width = 8, height = 6)


#per capita est by age class#per capita est by age classPop
percap_fb_dem <- byc_est_waal_b_fb_dem_sum/924.2
percap_i_dem <- byc_est_waal_b_i_dem_sum/6054.8
percap_j2j3_dem <- byc_est_waal_b_j2j3_dem_sum/1642.8
percap_nb_dem <- byc_est_waal_b_nb_dem_sum/3960.4
percap_sb_dem <- byc_est_waal_b_sb_dem_sum/2735.6

percap_fb_pel <- byc_est_waal_b_fb_pel_sum/924.2
percap_i_pel <- byc_est_waal_b_i_pel_sum/6054.8
percap_j2j3_pel <- byc_est_waal_b_j2j3_pel_sum/1642.8
percap_nb_pel <- byc_est_waal_b_nb_pel_sum/3960.4
percap_sb_pel <- byc_est_waal_b_sb_pel_sum/2735.6


#plot % SG
library(terra)
library(sf)
library(ggplot2)
library(viridis)

# 1. Convert the SpatRaster to a data.frame
#    include xy=TRUE so you get columns "x" and "y" automatically
pct_df <- as.data.frame(pct_sg, xy = TRUE)

# 2. Rename the third column to something simple (e.g. "pct")
#    The default name is taken from the raster's "varname"/"name", which is long.
names(pct_df)[3] <- "pct"

# 3. Now build the ggplot using pct_df
pct_sg_plot <- ggplot(data = pct_df, aes(x = x, y = y, fill = pct)) +
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
print(pct_sg_plot)
# ggsave("pct_sg_plot.png", pct_sg_plot, width=8, height=6)

ggsave("percentSG_bycatch_gg.png", pct_sg_plot, width = 8, height = 6)



# 1) Reclassify 0 → NA in r1:
# southg_dist_norm_na <- subst(southg_dist_norm, 0, NA)
# southg_dist_norm_na <- ifel(southg_dist_norm_na < 0.00010, NA, southg_dist_norm_na)
# 
# plot(southg_dist_norm_na)
# # alternatively, using ifel():
# # r1_na <- ifel(r1 == 0, NA, r1)
# 
# # 2) Mask r2 by r1_na:
# #    This will set r2 to NA wherever r1_na is NA (i.e. where original r1 was zero).
# pct_sg_masked <- mask(pct_sg, southg_dist_norm_na)
# 
# # 3) Check the result
# plot(pct_sg_masked, main = "")





