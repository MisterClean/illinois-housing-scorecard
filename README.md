# Illinois Housing Market Scorecard

This repository processes and visualizes housing market metrics for Illinois Metropolitan Statistical Areas (MSAs), comparing current conditions to 2019 baseline data.

## Data Requirements

### Required Zillow Research Data Files

Download the following CSV files from [Zillow Research Data](https://www.zillow.com/research/data/):

1. **For-Sale Inventory (Smoothed, Seasonally Adjusted)** 
   - Download "inventory_smooth_sa.csv"
   - Rename to `for_sale_inventory.csv`

2. **Median Days to Pending**
   - Download "median_days_pending.csv"
   - Rename to `median_days_to_pending.csv`

3. **Median List Price**
   - Download "median_list_price.csv"
   - Rename to `median_list_price.csv`

### How to Download Data

1. Visit [Zillow Research Data](https://www.zillow.com/research/data/)
2. Navigate to the "Housing Inventory" section
3. Download each required file
4. Rename files as specified above
5. Place all files in the `data/input` directory of this repository

## Processing the Data

The repository contains two main R scripts:

1. `data_processing.R`: Processes raw Zillow data and generates comparison metrics
2. `housing_inventory.R`: Creates visualizations of the processed data

### Required R Libraries
```R
library(tidyverse)
library(lubridate)
library(scales)
```

### Running the Analysis

1. Ensure all required CSV files are in the `data/input` directory
2. Run the visualization script (which also runs the processing script):
```R
source("housing_inventory.R")
```

## Outputs

The scripts generate several output files in the `data/output` directory:

### CSV Files (in data/output)
- `illinois_housing_metric_comparison.csv`: Combined metrics comparing current values to 2019 baseline
- `processed_inventory.csv`: Processed inventory data
- `inventory_comparison.csv`: Inventory comparisons across time periods

### Visualizations (in data/output)
- `housing_inventory.png`: Bar chart showing inventory changes across Illinois MSAs
- Additional PNG files with trends and comparisons generated in the output directory

## Metropolitan Areas Covered

The analysis includes the following Illinois Metropolitan Statistical Areas:
- Chicago-Naperville-Elgin
- Peoria
- Rockford
- Champaign-Urbana
- Springfield
- Bloomington
- Ottawa-Peru
- Carbondale-Marion
- Kankakee
- Decatur
- Danville
- Mount Vernon
- Quincy
- Sterling-Rock Falls
- Davenport-Moline-Rock Island (IL-IA)

## Notes

- The analysis automatically uses the most recent complete month of data available
- Comparisons are made against the same month in 2019 as the baseline year
- All metrics are seasonally adjusted where applicable
