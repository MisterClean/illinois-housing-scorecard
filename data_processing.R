library(tidyverse)
library(lubridate)

# MSA name mapping - converting informal city names to official MSA names
msa_names <- c(
    "Chicago, IL" = "Chicago-Naperville-Elgin",
    "Peoria, IL" = "Peoria",
    "Rockford, IL" = "Rockford",
    "Champaign, IL" = "Champaign-Urbana",
    "Springfield, IL" = "Springfield",
    "Davenport, IA" = "Davenport-Moline-Rock Island",
    "Bloomington, IL" = "Bloomington",
    "Ottawa, IL" = "Ottawa-Peru",
    "Carbondale, IL" = "Carbondale-Marion",
    "Kankakee, IL" = "Kankakee",
    "Decatur, IL" = "Decatur",
    "Danville, IL" = "Danville",
    "Mount Vernon, IL" = "Mount Vernon",
    "Quincy, IL" = "Quincy",
    "Sterling, IL" = "Sterling-Rock Falls"
)

# Define our priority cities
priority_cities <- names(msa_names)

process_metric <- function(file_path) {
  # Extract metric name from file path, removing any directory parts
  metric_name <- tools::file_path_sans_ext(basename(file_path))
  
  # Read data
  df <- read.csv(file_path)
  
  # Convert to long format and clean dates
  df_processed <- df %>%
    pivot_longer(
      cols = -c(RegionID, SizeRank, RegionName, RegionType, StateName),
      names_to = "date",
      values_to = "value"
    ) %>%
    mutate(
      date = gsub("X", "", date),
      date = gsub("\\.", "-", date),
      date = as.Date(date, format = "%Y-%m-%d")
    ) %>%
    # Filter to priority cities and United States, map MSA names
    filter((RegionType == "msa" & RegionName %in% priority_cities) | 
           (RegionType == "country" & RegionName == "United States")) %>%
    mutate(metropolitan_area = if_else(RegionName == "United States", 
                                     "United States", 
                                     msa_names[RegionName])) %>%
    select(date, metropolitan_area, value)
  
  # Get most recent complete month
  current_date <- Sys.Date()
  # Use previous month as most recent complete month
  most_recent_date <- floor_date(current_date - months(1), "month") + days(1)
  message(sprintf("Most recent complete month date: %s", most_recent_date))
  
  # Get corresponding date in 2019
  comparison_month <- month(most_recent_date)
  comparison_day <- day(most_recent_date)
  comparison_year_2019 <- as.Date(paste0("2019-", sprintf("%02d", comparison_month), "-", sprintf("%02d", comparison_day)))
  message(sprintf("Comparison date in 2019: %s", comparison_year_2019))
  
  # Verify we have data for both dates
  available_dates <- unique(df_processed$date)
  if (!most_recent_date %in% available_dates) {
    most_recent_date <- max(available_dates)
    message(sprintf("Adjusting to latest available date: %s", most_recent_date))
    # Recalculate 2019 comparison date
    comparison_month <- month(most_recent_date)
    comparison_day <- day(most_recent_date)
    comparison_year_2019 <- as.Date(paste0("2019-", sprintf("%02d", comparison_month), "-", sprintf("%02d", comparison_day)))
    message(sprintf("Adjusted comparison date in 2019: %s", comparison_year_2019))
  }
  
  if (!comparison_year_2019 %in% available_dates) {
    stop(sprintf("Missing 2019 comparison data for date: %s", comparison_year_2019))
  }
  
  # Calculate column names once
  month_abbr <- tolower(format(most_recent_date, "%b"))
  recent_year <- substr(year(most_recent_date), 3, 4)
  baseline_year <- "19"
  recent_col <- paste0(month_abbr, "_", recent_year)
  baseline_col <- paste0(month_abbr, "_", baseline_year)
  
  # Create comparison dataframe
  comparison_df <- df_processed %>%
    filter(date %in% c(comparison_year_2019, most_recent_date)) %>%
    mutate(
      year = year(date),
      # Create column names for pivot
      col_name = if_else(
        year == 2019,
        baseline_col,
        recent_col
      )
    ) %>%
    pivot_wider(
      id_cols = metropolitan_area,
      names_from = col_name,
      values_from = value
    ) %>%
    mutate(
      metric = metric_name,
      percent_change = (.data[[recent_col]] - .data[[baseline_col]]) / .data[[baseline_col]] * 100
    ) %>%
    select(metropolitan_area, metric, all_of(baseline_col), all_of(recent_col), percent_change)
  
  return(comparison_df)
}

# Get all CSV files from input directory
data_sources <- list.files(path = "data/input", pattern = "\\.csv$", full.names = TRUE)

# Process all CSV files
all_data <- map_dfr(data_sources, process_metric)

# Sort the combined results
final_data <- all_data %>%
  # Create a sorting helper that puts US first within each metric group
  mutate(
    sort_order = if_else(metropolitan_area == "United States", 1, 2)
  ) %>%
  arrange(metric, sort_order, percent_change) %>%
  select(-sort_order)

# Write the final comparison to CSV
write.csv(final_data, "data/output/illinois_housing_metric_comparison.csv", row.names = FALSE)

# Print the results
print(final_data)
