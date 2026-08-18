# ============================================================
# Improved visualization for the golf hotspot analysis
# Replaces "Step 7" in golf_hotspot.R
# Assumes `grid` and `courses` already exist from the main script.
#
# Install once:
#   install.packages(c("ggplot2","sf","tigris","viridis","dplyr"))
#   # For the interactive version:
#   install.packages("leaflet")
# ============================================================

library(ggplot2)
library(sf)
library(tigris)
library(viridis)
library(dplyr)
options(tigris_use_cache = TRUE)   # cache the downloaded shapefiles

# ---- Geography (free, no API key) -------------------------
mi_counties <- counties(state = "MI", cb = TRUE, year = 2022)
tri <- mi_counties %>% filter(NAME %in% c("Wayne", "Oakland", "Macomb"))

# A handful of recognizable city labels for orientation
mi_places <- places(state = "MI", cb = TRUE, year = 2022)
label_cities <- c("South Lyon","Holly","Armada","Sumpter",
                 "Belleville","Grosse Pointe Farms",
                  "Trenton","Leonard","New Haven","Romeo", "Ortonville")
cities   <- mi_places %>% filter(NAME %in% label_cities)
city_pts <- suppressWarnings(st_point_on_surface(cities))  # label anchor points

# ---- Courses + winning location ---------------------------
course_sf <- st_as_sf(courses, coords = c("longitude","latitude"),
                      crs = 4326, remove = FALSE)
top1 <- grid[which.max(grid$course_count), ]

# ---- Static map (great for embedding as an image) ---------
p <- ggplot() +
  # heat layer: one tile per grid cell
  geom_tile(data = grid,
            aes(x = longitude, y = latitude, fill = course_count)) +
  # county outlines for orientation
  geom_sf(data = tri, fill = NA, color = "grey20", linewidth = 0.6) +
  # every course as a small dot that reads on light AND dark fill
  geom_sf(data = course_sf, shape = 21, fill = "white",
          color = "black", size = 2, stroke = 0.3, alpha = 0.9) +
  # city reference points + labels
  geom_sf(data = city_pts, color = "black", size = 1.4) +
  geom_sf_text(data = city_pts, aes(label = NAME),
               size = 4, color = "grey15", nudge_y = 0.02) +
  # call out the best location
  annotate("point", x = top1$longitude, y = top1$latitude,
           shape = 21, size = 6, stroke = 1.6, color = "#D7263D", fill = NA) +
  annotate("label", x = top1$longitude, y = top1$latitude,
           label = paste0("Best spot: ", top1$course_count, " courses within 15 mi"),
           vjust = -1.4, color = "#D7263D", fontface = "bold", size = 3.4,
           label.size = 0, fill = alpha("white", 0.8)) +
  scale_fill_viridis_c(option = "magma", direction = -1,
                       name = "Courses\nwithin 15 mi") +
  coord_sf(xlim = c(-84.0, -82.7), ylim = c(42.0, 43.05), expand = FALSE) +
  labs(title    = "Where to live for the most golf",
       subtitle = "Courses reachable within 15 miles (straight-line) — Wayne, Oakland, Macomb",
       caption  = "White dots = golf courses. Straight-line distance, not drive time.",
       x = NULL, y = NULL) +
  theme_minimal(base_size = 12) +
  theme(panel.grid   = element_blank(),
        axis.text    = element_blank(),
        axis.ticks   = element_blank(),
        plot.title   = element_text(face = "bold"),
        legend.position = "right")

print(p)

# Save a high-res image for the portfolio / dashboard
ggsave("golf_hotspot_map.png", plot = p, width = 9, height = 8, dpi = 200)


# ============================================================
# INTERACTIVE VERSION (real street tiles, pan/zoom, popups)
# The most "accessible to a viewer" option — they can find
# their own neighborhood. Uncomment to use.
# ============================================================
# library(leaflet)
# pal <- colorNumeric("magma", domain = grid$course_count, reverse = TRUE)
# leaflet(grid) %>%
#   addProviderTiles("CartoDB.Positron") %>%
#   addRectangles(
#     lng1 = ~longitude - 0.025, lat1 = ~latitude - 0.025,
#     lng2 = ~longitude + 0.025, lat2 = ~latitude + 0.025,
#     fillColor = ~pal(course_count), fillOpacity = 0.55,
#     stroke = FALSE, label = ~paste(course_count, "courses within 15 mi")
#   ) %>%
#   addCircleMarkers(
#     data = courses, ~longitude, ~latitude,
#     radius = 3, color = "black", fillColor = "white",
#     fillOpacity = 1, stroke = TRUE, weight = 1,
#     popup = ~course_name
#   ) %>%
#   addLegend(pal = pal, values = grid$course_count,
#             title = "Courses within 15 mi", position = "bottomright")