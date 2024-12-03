#government department analysis
# Load necessary libraries
library(ggplot2)
library(dplyr)
library(lubridate)
library(viridis)

# Read the data into R
raw_data <- read.csv("/Users/sandychen/Desktop/Lancaster/SCC460 DS Fundamental/project/Grant-Project/Data/Awards_data_frame.csv")

# Convert Award_Date to Date type
raw_data$Award_Date <- as.Date(raw_data$Award_Date)

# Filter the data to include only records from 2019 to 2023
raw_data_filtered <- raw_data %>%
  filter(Award_Date >= as.Date("2019-01-01") & Award_Date <= as.Date("2023-12-31"))

# Remove rows with missing values
award_summary_clean <- raw_data_filtered %>%
  filter(!is.na(Amount_Awarded) & !is.na(Award_Date))

# Summarize the data by Date and Department (Funding_Org_Name)
award_summary_clean <- award_summary_clean %>%
  group_by(Award_Date, Funding_Org_Name) %>%
  summarise(Total_Award = sum(Amount_Awarded, na.rm = TRUE)) %>%
  ungroup()

# Create the line chart
ggplot(award_summary_clean, aes(x = Award_Date, y = Total_Award, color = Funding_Org_Name, group = Funding_Org_Name)) +
  geom_line(linewidth = 1.5) +  # Make the lines thicker for better visibility
  labs(title = "Award Amount Over Time by Department (2019-2023)",
       x = "Date", y = "Total Award Amount") +
  theme_minimal() +  # Apply a clean theme
  theme(axis.text.x = element_text(angle = 45, hjust = 1),  # Rotate the x-axis labels
        axis.text = element_text(size = 10),  # Adjust text size of axis
        axis.title = element_text(size = 12),  # Increase size of axis titles
        legend.position = "right",  # Place the legend at the bottom-right
        legend.title = element_text(size = 12),  # Increase legend title text size
        legend.text = element_text(size = 10)) +  # Increase size of legend text
  scale_color_viridis(discrete = TRUE)  # Apply viridis color palette

###########another color

# Load necessary libraries
library(ggplot2)
library(dplyr)
library(lubridate)
library(viridis)

# Read the data into R
raw_data <- read.csv("/Users/sandychen/Desktop/Lancaster/SCC460 DS Fundamental/project/Grant-Project/Data/Awards_data_frame.csv")

# Convert Award_Date to Date type
raw_data$Award_Date <- as.Date(raw_data$Award_Date)

# Filter the data to include only records from 2019 to 2023
raw_data_filtered <- raw_data %>%
  filter(Award_Date >= as.Date("2019-01-01") & Award_Date <= as.Date("2023-12-31"))

# Remove rows with missing values
award_summary_clean <- raw_data_filtered %>%
  filter(!is.na(Amount_Awarded) & !is.na(Award_Date))

# Summarize the data by Date and Department (Funding_Org_Name)
award_summary_clean <- award_summary_clean %>%
  group_by(Award_Date, Funding_Org_Name) %>%
  summarise(Total_Award = sum(Amount_Awarded, na.rm = TRUE)) %>%
  ungroup()

# Create the line chart with a more vibrant color palette
ggplot(award_summary_clean, aes(x = Award_Date, y = Total_Award, color = Funding_Org_Name, group = Funding_Org_Name)) +
  geom_line(linewidth = 2) +  # Increase the line width for better visibility
  labs(title = "Award Amount Over Time by Department (2019-2023)",
       x = "Date", y = "Total Award Amount") +
  theme_minimal() +  # Apply a clean theme
  theme(axis.text.x = element_text(angle = 45, hjust = 1),  # Rotate the x-axis labels
        axis.text = element_text(size = 10),  # Adjust text size of axis
        axis.title = element_text(size = 12),  # Increase size of axis titles
        legend.position = "right",  # Place the legend at the bottom-right
        legend.title = element_text(size = 12),  # Increase legend title text size
        legend.text = element_text(size = 10)) +  # Increase size of legend text
  scale_color_brewer(palette = "Set1")  # Set a more vibrant, distinct color palette from RColorBrewer
