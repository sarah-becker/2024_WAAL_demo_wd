library(tidyverse)
library(sf)
library(here)
library(viridis)

# Load BLL effort data
bll <- read_csv(here("data/Rep Log 17287 BLL effort truncated.csv"),
                show_col_types = FALSE)

# Wrap longitudes > 180 to negative (e.g. 185 -> -175)
bll <- bll %>%
  mutate(lon = ifelse(truncated_long > 180, truncated_long - 360, truncated_long),
         lat = truncated_lat)

# Aggregate total hooks by 5-degree cell across all years and months
bll_agg <- bll %>%
  group_by(lon, lat) %>%
  summarise(total_hooks = sum(total_hooks, na.rm = TRUE), .groups = "drop")

# Load land basemap
ne_land <- st_read(here("data/ne_10m_land/ne_10m_land.shp"), quiet = TRUE)

# Map extent: buffer around data extent
lon_range <- range(bll_agg$lon)
lat_range <- range(bll_agg$lat)

ggplot() +
  geom_tile(data = bll_agg,
            aes(x = lon, y = lat, fill = total_hooks),
            width = 5, height = 5) +
  geom_sf(data = ne_land, fill = "grey70", color = "grey50", linewidth = 0.2) +
  coord_sf(xlim = c(lon_range[1] - 5, lon_range[2] + 5),
           ylim = c(lat_range[1] - 5, lat_range[2] + 5),
           expand = FALSE) +
  scale_fill_viridis_c(
    name = "Total hooks\n(1990–present)",
    trans = "log10",
    labels = scales::label_comma(),
    option = "magma",
    direction = -1
  ) +
  labs(
    title = "Rep Log 17287 — BLL Effort",
    subtitle = "Total hooks per 5° cell (log scale), all years and months combined",
    x = NULL, y = NULL
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title    = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 10, color = "grey40"),
    legend.position = "right",
    panel.grid    = element_line(color = "grey90", linewidth = 0.3)
  )

ggsave(here("output/maps/quick_map_BLL17287.png"),
       width = 10, height = 7, dpi = 200)

message("Map saved to output/maps/quick_map_BLL17287.png")
