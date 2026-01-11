library(terra)
library(sf)
library(ggplot2)
library(viridis)
library(scales)

library(terra)    # for raster math
library(sf)       # for land polygons
library(ggplot2)  # for plotting
library(viridis)
library(scales)




library(terra)
library(sf)
library(ggplot2)
library(viridis)
library(scales)

# 1) Read in or build your rasters -----------------------------------------

# A) Bird‐distribution: each 5° cell = fraction of total species
r_dist <- rast("path/to/WAAL_distribution.tif")
r_dist <- r_dist / global(r_dist, "sum", na.rm=TRUE)[1,1]

# B) Fishing effort: hooks per cell
r_effort <- rast("path/to/annual_hooks_per_cell.tif")

# C) Spatially‐varying BPUE: each 5° cell = birds caught per hook
#    (e.g., from stratified observer data)
r_BPUE <- rast("path/to/BPUE_by_cell.tif")

# D) Subpopulation fraction: in each cell, what fraction of the birds
#    belong to our colony?  (values 0–1; NA → 0)
r_frac <- rast("path/to/study_pop_fraction.tif")
r_frac <- subst(r_frac, NA, 0)

# E) Optional: total colony size, if you want per‐bird mortality
N_total <- 20100

# F) Natural Earth land for plotting
ne_land <- st_read("ne_10m_land.shp", quiet=TRUE)


# 2) Align all rasters to the same 5° grid -------------------------------

# Use r_dist as the template grid; resample the others to match
r_effort <- resample(r_effort, r_dist, method="near")
r_BPUE   <- resample(r_BPUE,   r_dist, method="near")
r_frac   <- resample(r_frac,   r_dist, method="near")

# 3) Compute total bycatch across all cells -------------------------------

# 3a. Compute cell‐by‐cell “raw bycatch” = hooks_i × BPUE_i
r_raw_bycatch <- r_effort * r_BPUE

# 3b. Sum over all cells to get B_total
B_total <- global(r_raw_bycatch, "sum", na.rm=TRUE)[1,1]


# 4) Build each cell’s weight = hooks_i × BPUE_i × r_dist_i -----------

r_weighted <- r_effort * r_BPUE * r_dist

# 4a. Sum weights over all cells
W <- global(r_weighted, "sum", na.rm=TRUE)[1,1]


# 5) Allocate the total bycatch to each cell (all‐birds version) ---------

r_bycatch_all <- (r_weighted / W) * B_total
# Now sum(r_bycatch_all) ≈ B_total (with only minor rounding error)


# 6) Extract the subpopulation’s bycatch per cell ------------------------

r_bycatch_subpop <- r_bycatch_all * r_frac
# Sum of this raster ≤ B_total, because 0 ≤ r_frac ≤ 1


# 7) (Optional) Compute per‐bird mortality rate for the subpop -----------

# 7a. Compute absolute subpop count in each cell:
#     (total birds in cell) = r_dist_i × N_total
#     (subpop birds in cell) = (total birds_i) × r_frac_i
cell_subpop_count <- (r_dist * N_total) * r_frac

# 7b. Mortality fraction = (bycatch_subpop_i) / (cell_subpop_count_i)
r_mort_rate_subpop <- ifel(cell_subpop_count > 0,
                           r_bycatch_subpop / cell_subpop_count,
                           NA)
# Values are between 0 and 1; NA where subpop_count = 0


# 8) Map the results with ggplot2 -----------------------------------------

# 8a. Convert rasters to data.frames
df_byc <- as.data.frame(r_bycatch_subpop,  xy = TRUE)
names(df_byc)[3] <- "bycatch"

df_mrt <- as.data.frame(r_mort_rate_subpop, xy = TRUE)
names(df_mrt)[3] <- "mortality_frac"

# 8b. Extract plotting extents
ext_byc <- ext(r_bycatch_subpop)
xlims   <- c(ext_byc[1], ext_byc[2])
ylims   <- c(ext_byc[3], ext_byc[4])

# 8c. Plot subpopulation bycatch (birds/year per cell)
p_bycatch <- ggplot(df_byc, aes(x = x, y = y, fill = bycatch)) +
  geom_raster() +
  geom_sf(data = ne_land, inherit.aes = FALSE,
          fill = "grey80", color = NA) +
  coord_sf(xlim = xlims, ylim = ylims, expand = FALSE) +
  scale_fill_viridis_c(name = "Birds killed\n(per year)",
                       na.value = "transparent") +
  labs(title = "Annual Bycatch—Subpopulation") +
  theme_minimal()

# 8d. Plot subpopulation mortality rate (fraction of local subpop lost)
p_mort <- ggplot(df_mrt, aes(x = x, y = y, fill = mortality_frac)) +
  geom_raster() +
  geom_sf(data = ne_land, inherit.aes = FALSE,
          fill = "grey80", color = NA) +
  coord_sf(xlim = xlims, ylim = ylims, expand = FALSE) +
  scale_fill_viridis_c(
    name   = "Mortality rate",
    labels = scales::percent_format(accuracy = 0.1),
    na.value = "transparent"
  ) +
  labs(title = "Annual Mortality Fraction—Subpopulation") +
  theme_minimal()

# Print or save
print(p_bycatch)
print(p_mort)
# ggsave("subpop_bycatch_map.png",   p_bycatch, width=8, height=6)
# ggsave("subpop_mortality_map.png", p_mort,    width=8, height=6)





#LAST TRY




# 1. Read/define inputs -------------------------------------------------------



# A) Bird‐distribution raster r_dist (values sum to 1 over the study area)
r_dist <- waal_b_all # rast("path/to/WAAL_distribution.tif")
# If your WAAL map isn't normalized, do:
#r_dist <- r_dist / global(r_dist, "sum", na.rm=TRUE)[1,1]

# B) Fishing‐effort raster r_effort (annual hooks per 5° cell)
r_effort_PLL <- rastPLL #rast("path/to/annual_hooks_per_cell.tif")
r_effort_DLL <- rastDLL

# Make sure they line up on the same grid & extent:
r_effort_PLL <- resample(r_effort_PLL, r_dist, method="near")
r_effort_DLL <- resample(r_effort_DLL, r_dist, method="near")

# C) BPUE estimate: say "5 birds per 1000 hooks"
BPUE_per_1000_pel <- mean_BPUE_pel
BPUE_per_1000_dem <- T_BPUE_1000_DEM
BPUE_pel <- BPUE_per_1000_pel / 1000   # (birds per hook)
BPUE_dem <- BPUE_per_1000_dem / 1000   # (birds per hook)

r_frac <- subst(pct_sg, NA, 0)
r_frac   <- resample(r_frac,   r_dist, method="near")
# BPUE_pel <- BPUE_pel*pct_sg
# BPUE_dem <- BPUE_dem*pct_sg
# D) (Optional) If you want absolute counts instead of “relative density,”
#    supply the total population size N_total. If you omit this, you get a
#    purely relative‐bycatch map (sum(bycatch) = B_total). 
#    If you DO have N_total, you can calculate cell_pop = r_dist * N_total.
N_total <-   (924.2+
                
                6054.8+
                
                1106.4+
                
                1642.8+
                
                3960.4+
                
                2735.6)
# E) A land shapefile for plotting
ne_land <- st_read(here::here("data/ne_10m_land/ne_10m_land.shp"))

# 2. Align grids  ------------------------------------------------------------

# Ensure r_effort & r_frac use exactly the same 5° grid & extent as r_dist
r_effort_PLL<- resample(r_effort_PLL, r_dist, method="near")
r_frac_PLL   <- resample(r_frac_PLL,   r_dist, method="near")

# 3. Allocate the TOTAL bycatch by “all birds”  ------------------------------

# 3a) Compute W_all = Σ_i (hooks_i * r_dist_i)
r_weighted_all_PLL <- r_effort_PLL * r_dist
W_all_PLL <- global(r_weighted_all_PLL, "sum", na.rm=TRUE)[1,1]

# 3b) Total hooks in region H_total
H_total_PLL <- global(r_effort_PLL, "sum", na.rm=TRUE)[1,1]

# 3c) Total birds caught, B_total = BPUE * H_total
B_total_PLL <- BPUE_pel * H_total_PLL

# 3d) Each cell’s total‐bird bycatch ("all") 
#     = B_total × (hooks_i × r_dist_i) / W_all
r_bycatch_all_PLL <- (r_weighted_all_PLL / W_all_PLL) * B_total_PLL

# 4. Extract your SUBPOP bycatch  --------------------------------------------

# 4a) Multiply each cell’s “all‐bird bycatch” by r_frac_i
r_bycatch_subpop_PLL <- r_bycatch_all_PLL * r_frac
#     Now ∑(r_bycatch_subpop[ ]) ≤ B_total automatically.

# 4b) (Optional) If you want per‐bird mortality for the subpop:
cell_subpop_count_PLL <- r_dist * N_total_PLL * r_frac
r_mort_rate_sub_PLL<- ifel(cell_subpop_count_PLL > 0,
                           r_bycatch_subpop_PLL / cell_subpop_count_PLL,
                        NA)

# 5. Plot the subpop bycatch map  --------------------------------------------

# 5a) Convert to data.frame for ggplot
byc_df_PLL <- as.data.frame(r_bycatch_subpop_PLL, xy=TRUE)
names(byc_df_PLL)[3] <- "bycatch"

# 5b) Extract plotting extents
ex <- ext(r_bycatch_subpop_PLL)
xlims <- c(ex[1], ex[2]); ylims <- c(ex[3], ex[4])

# 5c) Build ggplot
p_sub_byc_PLL <- ggplot(byc_df_PLL, aes(x=x, y=y, fill=bycatch)) +
  geom_raster() +
  geom_sf(data=ne_land, inherit.aes=FALSE, fill="grey80", color=NA) +
  coord_sf(xlim=xlims, ylim=ylims, expand=FALSE) +
  scale_fill_viridis_c(name="Bycatch\n(subpop)", na.value="transparent") +
  labs(title="Annual Bycatch for Study Subpopulation") +
  theme_minimal()

print(p_sub_byc_PLL)

global(r_bycatch_subpop_PLL, fun="sum", na.rm=TRUE)[1,1] #total pelagic bycatch is 435
# ggsave("subpop_bycatch_map.png", p_sub_byc, width=8, height=6)

# 6. (Optional) Plot subpop mortality rate  -----------------------------------

# mort_df <- as.data.frame(r_mort_rate_sub, xy=TRUE)
# names(mort_df)[3] <- "mort_frac"
# 
# p_sub_mort <- ggplot(mort_df, aes(x=x, y=y, fill=mort_frac)) +
#   geom_raster() +
#   geom_sf(data=ne_land, inherit.aes=FALSE, fill="grey80", color=NA) +
#   coord_sf(xlim=xlims, ylim=ylims, expand=FALSE) +
#   scale_fill_viridis_c(name="Mortality\n(fraction)",
#                        labels=scales::percent_format(accuracy=0.1),
#                        na.value="transparent") +
#   labs(title="Annual Mortality Rate (Subpopulation)") +
#   theme_minimal()
# 
# print(p_sub_mort)
# # ggsave("subpop_mortality_rate_map.png", p_sub_mort, width=8, height=6)
















#OLD VRSOIN
















# A) Bird‐distribution raster r_dist (values sum to 1 over the study area)
r_dist <- waal_b_all # rast("path/to/WAAL_distribution.tif")
# If your WAAL map isn't normalized, do:
#r_dist <- r_dist / global(r_dist, "sum", na.rm=TRUE)[1,1]

# B) Fishing‐effort raster r_effort (annual hooks per 5° cell)
r_effort_PLL <- rastPLL #rast("path/to/annual_hooks_per_cell.tif")
r_effort_DLL <- rastDLL

# Make sure they line up on the same grid & extent:
r_effort_PLL <- resample(r_effort_PLL, r_dist, method="near")
r_effort_DLL <- resample(r_effort_DLL, r_dist, method="near")

# C) BPUE estimate: say "5 birds per 1000 hooks"
BPUE_per_1000_pel <- mean_BPUE_pel
BPUE_per_1000_dem <- T_BPUE_1000_DEM
BPUE_pel <- BPUE_per_1000_pel / 1000   # (birds per hook)
BPUE_dem <- BPUE_per_1000_dem / 1000   # (birds per hook)

r_frac <- subst(pct_sg, NA, 0)
r_frac   <- resample(r_frac,   r_dist, method="near")
# BPUE_pel <- BPUE_pel*pct_sg
# BPUE_dem <- BPUE_dem*pct_sg
# D) (Optional) If you want absolute counts instead of “relative density,”
#    supply the total population size N_total. If you omit this, you get a
#    purely relative‐bycatch map (sum(bycatch) = B_total). 
#    If you DO have N_total, you can calculate cell_pop = r_dist * N_total.
N_total <-   (924.2+

6054.8+

1106.4+

1642.8+

3960.4+

2735.6)
# E) A land shapefile for plotting
ne_land <- st_read(here::here("data/ne_10m_land/ne_10m_land.shp"))


#DO PLL FIRST

# 2.1) Weight raster: hooks × relative density
r_weighted_PLL <- r_effort_PLL * r_dist  * r_frac
#    Now r_weighted[i] = hooks_i * (fraction_of_birds_in_cell_i).

# 2.2) Sum that over all cells to get W
W_PLL <- global(r_weighted_PLL, "sum", na.rm=TRUE)[1,1]

# 2.3) Total hooks across the region
H_total_PLL <- global(r_effort_PLL, "sum", na.rm=TRUE)[1,1]

# 2.4) Compute B_total = total birds caught in region PER CELL NOW
B_total_PLL <- BPUE_pel * H_total_PLL

# 5) Allocate B_total back to each cell in proportion to r_weighted:
r_bycatch_subpop <- (r_weighted / W) * B_total
#    Now sum(r_bycatch_subpop) ≈ B_total (within rounding error).

# 6) (Optional) If you want “mortality fraction per subpop bird” in each cell:
#    First compute absolute subpop bird count in each cell:
cell_subpop_count <- r_dist * N_total * r_frac
#    Then divide bycatch by local subpop abundance:
r_mort_rate_subpop <- r_bycatch_subpop / cell_subpop_count
r_mort_rate_subpop <- ifel(cell_subpop_count > 0, r_mort_rate_subpop, NA)

#———————————————————————————————————————————————————————————————
# E) Convert rasters to data.frames for plotting
#———————————————————————————————————————————————————————————————
byc_df <- as.data.frame(r_bycatch_subpop, xy=TRUE)
names(byc_df)[3] <- "bycatch"

mort_df <- as.data.frame(r_mort_rate_subpop, xy=TRUE)
names(mort_df)[3] <- "mortality_frac"

# Get plotting extents
ex_byc <- ext(r_bycatch_subpop)  # c(xmin, xmax, ymin, ymax)
ex_mrt <- ext(r_mort_rate_subpop)

#———————————————————————————————————————————————————————————————
# F) Plot the “subpop bycatch” map with ggplot2
#———————————————————————————————————————————————————————————————
p_bycatch <- ggplot(byc_df, aes(x = x, y = y, fill = bycatch)) +
  geom_raster() +
  geom_sf(data = ne_land, inherit.aes = FALSE,
          fill = "grey80", color = NA) +
  coord_sf(
    xlim   = c(ex_byc[1], ex_byc[2]),
    ylim   = c(ex_byc[3], ex_byc[4]),
    expand = FALSE
  ) +
  scale_fill_viridis_c(
    name     = "Bycatch\n(birds/yr)",
    na.value = "transparent"
  ) +
  labs(title = "Subpopulation Bycatch (Annual)") +
  theme_minimal()

print(p_bycatch)
# ggsave("subpop_bycatch_map.png", p_bycatch, width = 8, height = 6)

#———————————————————————————————————————————————————————————————

# 2.5) Distribute B_total to each cell in proportion to r_weighted
r_bycatch_PLL <- (r_weighted_PLL / W_PLL) * B_total_PLL
#    Now sum(r_bycatch) ≈ B_total (aside from tiny numerical rounding).

# If instead you want an *absolute count* of birds in each cell (for other analyses),
# you could do:
#   cell_pop <- r_dist * N_total
# and even compute a “per‐bird mortality rate” by dividing r_bycatch / cell_pop.

# 3.1) Convert r_bycatch to a data.frame for ggplot
byc_df_PLL <- as.data.frame(r_bycatch_PLL, xy=TRUE)
names(byc_df_PLL)[3] <- "bycatch"

# 3.2) Extract plotting extent
ex <- ext(r_bycatch_PLL)  # returns c(xmin, xmax, ymin, ymax)
xlims <- c(ex[1], ex[2])
ylims <- c(ex[3], ex[4])

# 3.3) Build the ggplot map
p_bycatch_PLL <- ggplot(byc_df_PLL, aes(x=x, y=y, fill=bycatch)) +
  geom_raster() +
  geom_sf(data = ne_land, inherit.aes = FALSE,
          fill = "grey80", color = NA) +
  coord_sf(xlim   = xlims,
           ylim   = ylims,
           expand = FALSE) +
  scale_fill_viridis_c(
    name     = "Bycatch\n(birds/yr)",
    na.value = "transparent",
    trans    = "sqrt"        # optional: use a sqrt‐scale if there’s a long tail
  ) +
  labs(title = "Bird‐weighted Annual Bycatch") +
  theme_minimal() +
  theme(
    plot.title     = element_text(size=14, face="bold"),
    legend.position= "right"
  )

# 3.4) Display or save
print(p_bycatch_PLL)
# ggsave("bird_weighted_bycatch.png", p_bycatch, width=8, height=6)


# A) compute absolute cell‐level bird counts:
cell_pop <- r_dist * N_total

# B) form the mortality‐fraction raster
r_mortality_PLL <- r_bycatch_PLL / cell_pop
#    (This is fraction of local birds killed in one year.)

# C) mask out places where no birds were present (i.e. cell_pop == 0)
r_mortality_PLL <- ifel(cell_pop > 0, r_mortality_PLL, NA)

# D) Convert to data.frame and plot
mort_df_PLL <- as.data.frame(r_mortality_PLL, xy=TRUE)
names(mort_df_PLL)[3] <- "mortality_frac"

p_mort_PLL <- ggplot(mort_df_PLL, aes(x=x, y=y, fill=mortality_frac)) +
  geom_raster() +
  geom_sf(data = ne_land, inherit.aes=FALSE,
          fill="grey80", color=NA) +
  coord_sf(xlim   = xlims, 
           ylim   = ylims,
           expand = FALSE) +
  scale_fill_viridis_c(
    name   = "Mortality\nfraction",
    labels = scales::percent_format(accuracy = 0.1),
    na.value = "transparent"
  ) +
  labs(title = "Annual Per‐Bird Mortality Rate") +
  theme_minimal()

print(p_mort_PLL)
# ggsave("per_bird_mortality_rate.png", p_mort, width=8, height=6)
