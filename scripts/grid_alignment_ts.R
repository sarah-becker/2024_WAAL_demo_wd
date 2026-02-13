
library(terra)
library(here)

bi_fb <- rast(here("output/rasters/BI_density_fb_final.tif"))
bi_sb <- rast(here("output/rasters/BI_density_sb_final.tif"))
bi_nb <- rast(here("output/rasters/BI_density_nb_final.tif"))
bi_j2j3 <- rast(here("output/rasters/BI_density_j2j3_final.tif"))
bi_imm <- rast(here("output/rasters/BI_density_imm_final.tif"))

# These should sum to the BI population in each age class
global(bi_fb, "sum", na.rm = TRUE)
global(bi_sb, "sum", na.rm = TRUE)
global(bi_nb, "sum", na.rm = TRUE)
global(bi_j2j3, "sum", na.rm = TRUE)
global(bi_imm, "sum", na.rm = TRUE)

# Total should be ~931.8 × 2 (both sexes) or similar
bi_total <- bi_fb + bi_sb + bi_nb + bi_j2j3 + bi_imm
global(bi_total, "sum", na.rm = TRUE)


total_bird_density <- rast(here("output/rasters/total_bird_density_all_pops.tif"))
global(total_bird_density, "sum", na.rm = TRUE)


ext(total_bird_density)
ext(bi_total)
res(total_bird_density)
res(bi_total)


# Check if Clay originals have different extent
clay_fb <- rast(here("data/WAAL_dist_Clay2019/WA_AllMonths_Both_FB_1990-2009.tif"))
ext(clay_fb)
global(clay_fb, "sum", na.rm = TRUE)


clay_south <- crop(total_bird_density, ext(-180, 180, -90, -50))
global(clay_south, "sum", na.rm = TRUE)

clay_north <- crop(total_bird_density, ext(-180, 180, -50, 0))
global(clay_north, "sum", na.rm = TRUE)


# And check that BI never exceeds total (would be a bug)
ratio <- bi_total / total_bird_density
global(ratio, "max", na.rm = TRUE)
global(ratio, "mean", na.rm = TRUE)
