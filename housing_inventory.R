library(tidyverse)
library(scales)

# First run data_processing.R to generate the processed data
source("data_processing.R")

# Prepare data for visualization
plot_data <- comparison_df %>%
  mutate(
    sort_order = percent_change,
    RegionName = metropolitan_area
  ) %>%
  arrange(desc(sort_order))

# Create visualization
inventory_plot <- ggplot(plot_data) +
  geom_col(aes(x = percent_change, y = reorder(RegionName, sort_order),
               fill = percent_change), width = 0.95) +
  geom_text(aes(x = percent_change, y = reorder(RegionName, sort_order),
                label = sprintf("%.1f%%", percent_change)),
            hjust = -0.2, size = 4.5, color = "#333333") +
  scale_fill_gradient(low = "#FF7E47", high = "#FFD4C2", guide = "none") +
  labs(
    title = paste0("Housing Inventory Change: ", 
                  format(comparison_year_2019, "%B %Y"), 
                  " vs ",
                  format(most_recent_date, "%B %Y")),
    subtitle = "Percent change in housing inventory for Illinois Metropolitan Areas",
    x = NULL,
    y = NULL,
    caption = "Source: Zillow Housing Inventory Data"
  ) +
  scale_x_continuous(
    limits = function(x) c(min(x) - 1.5, max(x) + 3.5),
    labels = function(x) paste0(x, "%")
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 24, margin = margin(b = 10)),
    plot.subtitle = element_text(color = "#666666", size = 14, margin = margin(b = 20)),
    plot.caption = element_text(color = "#666666", size = 10, hjust = 0, margin = margin(t = 20)),
    panel.grid.major.x = element_line(color = "#F5F5F5"),
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.y = element_text(color = "#333333", size = 14),
    axis.text.x = element_text(color = "#666666", size = 12),
    plot.background = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = NA),
    plot.margin = margin(t = 20, r = 80, b = 20, l = 20, unit = "pt")
  )

# Save the plot
ggsave("housing_inventory.png", inventory_plot, width = 10, height = 12, dpi = 300, bg = "white")
