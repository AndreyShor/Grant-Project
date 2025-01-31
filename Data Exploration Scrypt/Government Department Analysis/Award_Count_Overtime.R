#government department analysis
# Load necessary libraries
library(ggplot2)
library(dplyr)
library(lubridate)
library(viridis)

# Read the data into R
raw_data <- read.csv("/Users/sandychen/Desktop/no_duplicates.csv")

# Rename columns with standardized names
colnames(raw_data) <- c("Identifier", 
                        "Title", 
                        "Description", 
                        "Currency", 
                        "Amount_Awarded", 
                        "Grant_Programme_Code", 
                        "Grant_Programme_Title", 
                        "Award_Date", 
                        "Recipient_Org_Identifier", 
                        "Recipient_Org_Name", 
                        "Recipient_Org_Charity_Number", 
                        "Recipient_Org_Company_Number", 
                        "Recipient_Org_Street_Address", 
                        "Recipient_Org_City", 
                        "Recipient_Org_Country", 
                        "Recipient_Org_Postal_Code", 
                        "Funding_Org_Identifier", 
                        "Funding_Org_Name", 
                        "Managed_by_Organisation_Name", 
                        "Allocation_Method", 
                        "From_an_Open_Call", 
                        "Award_Authority_Act_Name", 
                        "Last_Modified", 
                        "Award_Type", 
                        "Number_of_Recipients", 
                        "District", 
                        "County", 
                        "Region", 
                        "Ward", 
                        "Country", 
                        "Population")
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

# Summarize the total amount awarded by year and department (Funding_Org_Name)
award_summary_by_year <- award_summary_clean %>%
  mutate(Year = year(Award_Date)) %>%  # Extract year from Award_Date
  group_by(Year, Funding_Org_Name) %>%  # Group by year and department
  summarise(Total_Award = sum(Total_Award, na.rm = TRUE)) %>%  # Sum total awards for each group
  ungroup()

# View the summary of awards by year and department
print(award_summary_by_year)


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

######### Load necessary libraries
library(dplyr)
library(lubridate)

######## 2019 - Filter and summarize, then arrange by Total_Award in descending order
award_summary_2019 <- award_summary_clean %>%
  filter(year(Award_Date) == 2019) %>%
  group_by(Funding_Org_Name) %>%
  summarise(Total_Award = sum(Total_Award, na.rm = TRUE)) %>%
  ungroup() %>%
  arrange(desc(Total_Award))  # Sort in descending order by Total_Award

# Print summary for 2019
print("Summary for 2019:")
print(award_summary_2019)

# 2020 - Filter and summarize, then arrange by Total_Award in descending order
award_summary_2020 <- award_summary_clean %>%
  filter(year(Award_Date) == 2020) %>%
  group_by(Funding_Org_Name) %>%
  summarise(Total_Award = sum(Total_Award, na.rm = TRUE)) %>%
  ungroup() %>%
  arrange(desc(Total_Award))  # Sort in descending order by Total_Award

# Print summary for 2020
print("Summary for 2020:")
print(award_summary_2020)

# 2021 - Filter and summarize, then arrange by Total_Award in descending order
award_summary_2021 <- award_summary_clean %>%
  filter(year(Award_Date) == 2021) %>%
  group_by(Funding_Org_Name) %>%
  summarise(Total_Award = sum(Total_Award, na.rm = TRUE)) %>%
  ungroup() %>%
  arrange(desc(Total_Award))  # Sort in descending order by Total_Award

# Print summary for 2021
print("Summary for 2021:")
print(award_summary_2021)

# 2022 - Filter and summarize, then arrange by Total_Award in descending order
award_summary_2022 <- award_summary_clean %>%
  filter(year(Award_Date) == 2022) %>%
  group_by(Funding_Org_Name) %>%
  summarise(Total_Award = sum(Total_Award, na.rm = TRUE)) %>%
  ungroup() %>%
  arrange(desc(Total_Award))  # Sort in descending order by Total_Award

# Print summary for 2022
print("Summary for 2022:")
print(award_summary_2022)

# 2023 - Filter and summarize, then arrange by Total_Award in descending order
award_summary_2023 <- award_summary_clean %>%
  filter(year(Award_Date) == 2023) %>%
  group_by(Funding_Org_Name) %>%
  summarise(Total_Award = sum(Total_Award, na.rm = TRUE)) %>%
  ungroup() %>%
  arrange(desc(Total_Award))  # Sort in descending order by Total_Award

# Print summary for 2023
print("Summary for 2023:")
print(award_summary_2023)

#########
# Load libraries
library(dplyr)
library(lubridate)

# Calculate total amount for each year
total_per_year <- award_summary_clean %>%
  group_by(Year = year(Award_Date)) %>%  # Group by year
  summarise(Total_Award = sum(Total_Award, na.rm = TRUE)) %>%  # Sum the Total_Award for each year
  ungroup()  # Ungroup the data for further operations if needed

# Print the total award amounts for each year
print("Total Award Amount per Year:")
print(total_per_year)

########
# Load necessary libraries
library(ggplot2)
library(dplyr)
library(lubridate)

# Calculate total amount for each year
total_per_year <- award_summary_clean %>%
  group_by(Year = year(Award_Date)) %>%  # Group by year
  summarise(Total_Award = sum(Total_Award, na.rm = TRUE)) %>%  # Sum the Total_Award for each year
  ungroup()  # Ungroup the data for further operations if needed

# Plot the total award amount per year using ggplot2
ggplot(total_per_year, aes(x = Year, y = Total_Award)) +
  geom_line(color = "blue", size = 1.5) +  # Line plot with blue color and thickness
  geom_point(color = "red", size = 3) +  # Add red points to the line for clarity
  labs(title = "Total Award Amount Per Year (2019-2023)", 
       x = "Year", 
       y = "Total Award Amount") +
  theme_minimal() +  # Use a minimal theme for a clean look
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels for better readability


##############plot top 5 departments by total award amount (2019-2023)
top_departments_per_year <- award_summary_clean %>%
  group_by(Year = year(Award_Date), Funding_Org_Name) %>%  # Group by year and department
  summarise(Total_Award = sum(Total_Award, na.rm = TRUE)) %>%  # Calculate total awards by department
  ungroup() %>%
  arrange(Year, desc(Total_Award)) %>%  # Sort by year and total award amount
  group_by(Year) %>%  # Group by year to select top 5 departments for each year
  slice_head(n = 5)  # Get the top 5 departments for each year

ggplot(top_departments_per_year, aes(x = Year, y = Total_Award, color = Funding_Org_Name, group = Funding_Org_Name)) +
  geom_line(size = 1.5) +  # Line plot with line thickness
  geom_point(size = 3) +  # Add points at each data point
  labs(title = "Top 5 Departments by Total Award Amount (2019-2023)", 
       x = "Year", 
       y = "Total Award Amount") +
  theme_minimal() +  # Use a clean theme
  theme(axis.text.x = element_text(angle = 45, hjust = 1),  # Rotate x-axis labels for readability
        axis.text = element_text(size = 12),  # Increase text size of axis labels
        axis.title = element_text(size = 14),  # Increase size of axis titles
        axis.ticks.y = element_line(size = 1),  # Increase the thickness of y-axis ticks
        axis.ticks.length = unit(0.25, "cm"),  # Increase length of ticks on y-axis
        axis.line.y = element_line(size = 1.5),  # Increase thickness of the y-axis line
        legend.title = element_text(size = 12),  # Increase legend title size
        legend.text = element_text(size = 10)) +  # Increase legend text size
  scale_color_brewer(palette = "Set1") +  # Use a distinct color palette for each department
  scale_y_log10()  # Apply a logarithmic scale to y-axis

########
library(ggplot2)
library(dplyr)
library(scales)

# Example data preparation (assuming you have 'award_summary_clean' dataset)
top_departments_per_year <- award_summary_clean %>%
  group_by(Year = year(Award_Date), Funding_Org_Name) %>%
  summarise(Total_Award = sum(Total_Award, na.rm = TRUE)) %>%
  ungroup()

# Custom label formatting functions for each group

# Function for 2019 in thousands and millions
label_2019 <- function(x) {
  ifelse(x >= 1e6, 
         paste0(format(x / 1e6, big.mark = ",", digits = 1), " M"),
         paste0(format(x / 1e3, big.mark = ",", digits = 1), " K"))
}

# Function for 2020-2022 in millions and billions
label_2020_2022 <- function(x) {
  ifelse(x >= 1e9, 
         paste0(format(x / 1e9, big.mark = ",", digits = 1), " B"), 
         paste0(format(x / 1e6, big.mark = ",", digits = 1), " M"))
}

# Function for 2023 in thousands and millions
label_2023 <- function(x) {
  ifelse(x >= 1e6, 
         paste0(format(x / 1e6, big.mark = ",", digits = 1), " M"),
         paste0(format(x / 1e3, big.mark = ",", digits = 1), " K"))
}

# Plot 1 for 2019 with y-axis in thousands and millions
top_2019 <- top_departments_per_year %>% filter(Year == 2019)
ggplot(top_2019, aes(x = Year, y = Total_Award, color = Funding_Org_Name, group = Funding_Org_Name)) +
  geom_line(size = 1.5) +  
  geom_point(size = 3) +  
  labs(title = "Top 5 Departments by Total Award Amount (2019)", 
       x = "Year", 
       y = "Total Award Amount") +
  theme_minimal() +  
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        axis.text = element_text(size = 12), 
        axis.title = element_text(size = 14), 
        axis.ticks.y = element_line(size = 1), 
        axis.ticks.length = unit(0.25, "cm"), 
        axis.line.y = element_line(size = 1.5), 
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 10)) +
  scale_color_brewer(palette = "Set1") +
  scale_y_continuous(labels = label_2019)  # Apply custom label function for 2019

# Plot 2 for 2020-2022 with y-axis in millions and billions
top_2020_2022 <- top_departments_per_year %>% filter(Year %in% 2020:2022)
ggplot(top_2020_2022, aes(x = Year, y = Total_Award, color = Funding_Org_Name, group = Funding_Org_Name)) +
  geom_line(size = 1.5) +  
  geom_point(size = 3) +  
  labs(title = "Top 5 Departments by Total Award Amount (2020-2022)", 
       x = "Year", 
       y = "Total Award Amount") +
  theme_minimal() +  
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        axis.text = element_text(size = 12), 
        axis.title = element_text(size = 14), 
        axis.ticks.y = element_line(size = 1), 
        axis.ticks.length = unit(0.25, "cm"), 
        axis.line.y = element_line(size = 1.5), 
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 10)) +
  scale_color_brewer(palette = "Set1") +
  scale_y_continuous(labels = label_2020_2022)  # Apply custom label function for 2020-2022

# Plot 3 for 2023 with y-axis in thousands and millions
top_2023 <- top_departments_per_year %>% filter(Year == 2023)
ggplot(top_2023, aes(x = Year, y = Total_Award, color = Funding_Org_Name, group = Funding_Org_Name)) +
  geom_line(size = 1.5) +  
  geom_point(size = 3) +  
  labs(title = "Top 5 Departments by Total Award Amount (2023)", 
       x = "Year", 
       y = "Total Award Amount") +
  theme_minimal() +  
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        axis.text = element_text(size = 12), 
        axis.title = element_text(size = 14), 
        axis.ticks.y = element_line(size = 1), 
        axis.ticks.length = unit(0.25, "cm"), 
        axis.line.y = element_line(size = 1.5), 
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 10)) +
  scale_color_brewer(palette = "Set1") +
  scale_y_continuous(labels = label_2023)  # Apply custom label function for 2023

#######
# Load required packages
install.packages("ggrepel")
library(dplyr)
library(lubridate)
library(ggplot2)
library(forcats)
library(scales)
library(ggrepel)  # Make sure ggrepel is loaded

# Read the data into R
raw_data <- read.csv("/Users/sandychen/Desktop/no_duplicates.csv")

# Rename columns to standardized names (adjust if needed)
colnames(raw_data) <- c("Identifier", 
                        "Title", 
                        "Description", 
                        "Currency", 
                        "Amount_Awarded", 
                        "Grant_Programme_Code", 
                        "Grant_Programme_Title", 
                        "Award_Date", 
                        "Recipient_Org_Identifier", 
                        "Recipient_Org_Name", 
                        "Recipient_Org_Charity_Number", 
                        "Recipient_Org_Company_Number", 
                        "Recipient_Org_Street_Address", 
                        "Recipient_Org_City", 
                        "Recipient_Org_Country", 
                        "Recipient_Org_Postal_Code", 
                        "Funding_Org_Identifier", 
                        "Funding_Org_Name", 
                        "Managed_by_Organisation_Name", 
                        "Allocation_Method", 
                        "From_an_Open_Call", 
                        "Award_Authority_Act_Name", 
                        "Last_Modified", 
                        "Award_Type", 
                        "Number_of_Recipients", 
                        "District", 
                        "County", 
                        "Region", 
                        "Ward", 
                        "Country", 
                        "Population")

# Convert Award_Date to Date and extract Year
raw_data <- raw_data %>%
  mutate(Award_Date = as.Date(Award_Date),
         Year = year(Award_Date)) %>%
  filter(Year >= 2019 & Year <= 2023) # Include up to 2023

# Summarize total amount awarded per funding organization per year
annual_sums <- raw_data %>%
  group_by(Funding_Org_Name, Year) %>%
  summarise(Total_Awarded = sum(Amount_Awarded, na.rm = TRUE), .groups = "drop")

# Identify top 5 organizations based on total awards from 2019 to 2022 (exclude 2023 for ranking)
top_5_orgs <- annual_sums %>%
  filter(Year <= 2022) %>%
  group_by(Funding_Org_Name) %>%
  summarise(Grand_Total = sum(Total_Awarded)) %>%
  arrange(desc(Grand_Total)) %>%
  slice_head(n = 5) %>%
  pull(Funding_Org_Name)

# For the line plot (2019-2022)
top_5_data_line <- annual_sums %>%
  filter(Funding_Org_Name %in% top_5_orgs, Year >= 2019, Year <= 2022)

# For the bar plot (2023), ensure all top 5 are included, even if zero
top_5_data_bar <- expand.grid(Funding_Org_Name = top_5_orgs, Year = 2023) %>%
  left_join(annual_sums, by = c("Funding_Org_Name", "Year")) %>%
  mutate(Total_Awarded = ifelse(is.na(Total_Awarded), 0, Total_Awarded))

# Find starting points for labeling the line chart (label at earliest year)
starting_points <- top_5_data_line %>%
  group_by(Funding_Org_Name) %>%
  filter(Year == min(Year))

# Create the line plot (2019-2022)
p_line <- ggplot(top_5_data_line, aes(x = Year, y = Total_Awarded, 
                                      color = fct_reorder(Funding_Org_Name, -Total_Awarded))) +
  geom_line(size = 1.2) +
  geom_point(size = 3) +
  geom_text_repel(data = starting_points,
                  aes(label = Funding_Org_Name),
                  size = 4,
                  nudge_x = -0.2,   # Move labels slightly to the left
                  hjust = 1,        # Right-align the labels
                  direction = "y",
                  segment.color = NA,
                  show.legend = FALSE) +
  scale_color_brewer(palette = "Set2", guide = "none") +
  scale_y_continuous(labels = label_number(scale_cut = cut_short_scale())) +
  labs(
    title = "Top 5 Funding Organizations Over Time (2019-2022)",
    subtitle = "Total Awarded Amount by Year",
    x = "Year",
    y = "Total Amount Awarded"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(face = "bold", size = 20),
    plot.subtitle = element_text(size = 14),
    axis.title = element_text(face = "bold")
  ) +
  expand_limits(x = min(top_5_data_line$Year) - 0.5)

# Create the bar plot for 2023 (including zeros)
p_bar <- ggplot(top_5_data_bar, aes(x = fct_reorder(Funding_Org_Name, -Total_Awarded), 
                                    y = Total_Awarded, fill = Funding_Org_Name)) +
  geom_col() +
  scale_fill_brewer(palette = "Set2", guide = "none") +
  scale_y_continuous(labels = label_number(scale_cut = cut_short_scale())) +
  labs(
    title = "Total Awards in 2023 for Top 5 Organizations",
    x = "Funding Organization",
    y = "Total Amount Awarded"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(face = "bold", size = 19),
    axis.title = element_text(face = "bold"),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

# Print the plots separately

print(p_line)
print(p_bar)

######animate
# Load required libraries
library(dplyr)
library(lubridate)
library(ggplot2)
library(gganimate)
library(forcats)
library(scales)

# Read your data
raw_data <- read.csv("/Users/sandychen/Desktop/no_duplicates.csv")

# Rename columns (adjust if needed)
colnames(raw_data) <- c("Identifier", 
                        "Title", 
                        "Description", 
                        "Currency", 
                        "Amount_Awarded", 
                        "Grant_Programme_Code", 
                        "Grant_Programme_Title", 
                        "Award_Date", 
                        "Recipient_Org_Identifier", 
                        "Recipient_Org_Name", 
                        "Recipient_Org_Charity_Number", 
                        "Recipient_Org_Company_Number", 
                        "Recipient_Org_Street_Address", 
                        "Recipient_Org_City", 
                        "Recipient_Org_Country", 
                        "Recipient_Org_Postal_Code", 
                        "Funding_Org_Identifier", 
                        "Funding_Org_Name", 
                        "Managed_by_Organisation_Name", 
                        "Allocation_Method", 
                        "From_an_Open_Call", 
                        "Award_Authority_Act_Name", 
                        "Last_Modified", 
                        "Award_Type", 
                        "Number_of_Recipients", 
                        "District", 
                        "County", 
                        "Region", 
                        "Ward", 
                        "Country", 
                        "Population")

# Convert Award_Date to Date and extract Year
raw_data <- raw_data %>%
  mutate(Award_Date = as.Date(Award_Date),
         Year = year(Award_Date)) %>%
  filter(Year >= 2019 & Year <= 2023) # Include up to 2023

# Define the top 5 organizations based on 2019-2022
top_5_orgs <- raw_data %>%
  filter(Year <= 2022) %>%
  group_by(Funding_Org_Name) %>%
  summarise(Grand_Total = sum(Amount_Awarded, na.rm = TRUE)) %>%
  arrange(desc(Grand_Total)) %>%
  slice_head(n = 5) %>%
  pull(Funding_Org_Name)

# Ensure that all 5 top organizations are included in 2023 (even if no awards were given)
top_5_data_bar <- expand.grid(Funding_Org_Name = top_5_orgs, Year = 2019:2023) %>%
  left_join(raw_data, by = c("Funding_Org_Name", "Year")) %>%
  mutate(Total_Awarded = ifelse(is.na(Amount_Awarded), 0, Amount_Awarded)) %>%
  group_by(Funding_Org_Name, Year) %>%
  summarise(Total_Awarded = sum(Total_Awarded, na.rm = TRUE), .groups = "drop")

# Check and remove any missing values in critical columns
top_5_data_bar <- top_5_data_bar %>%
  filter(!is.na(Year) & !is.na(Funding_Org_Name) & !is.na(Total_Awarded))

# Ensure data types are correct (Year should be numeric and Total_Awarded should be numeric)
top_5_data_bar <- top_5_data_bar %>%
  mutate(Year = as.integer(Year),
         Total_Awarded = as.numeric(Total_Awarded))

# create the animated bar chart
p <- ggplot(top_5_data_bar, aes(x = Total_Awarded, y = fct_reorder(Funding_Org_Name, Total_Awarded), 
                                fill = Funding_Org_Name)) +
  geom_col() +
  scale_fill_brewer(palette = "Set3") +
  scale_x_continuous(labels = label_number(scale_cut = cut_short_scale())) +
  labs(
    title = 'Total Awarded Amount by Department: {frame_time}',
    subtitle = 'Year: {frame_time}',
    x = 'Total Amount Awarded',
    y = 'Department'
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(face = "bold", size = 20),
    plot.subtitle = element_text(size = 16),
    axis.title = element_text(face = "bold"),
    axis.text.x = element_text(angle = 45, hjust = 1)
  ) +
  transition_time(Year) +  # Animate over the Year variable
  ease_aes('linear')

# Print the animation
unique(top_5_data_bar$Year)  # Should return 2019, 2020, 2021, 2022, 2023

animate(p, nframes = 5, duration = 5, width = 800, height = 600, renderer = gifski_renderer())
