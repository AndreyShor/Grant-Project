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

# Load necessary libraries
library(ggplot2)
library(dplyr)
library(lubridate)

###### Calculate total award amount by department for each year
top_departments_per_year <- award_summary_clean %>%
  group_by(Year = year(Award_Date), Funding_Org_Name) %>%  # Group by year and department
  summarise(Total_Award = sum(Total_Award, na.rm = TRUE)) %>%  # Calculate total awards by department
  ungroup() %>%
  arrange(Year, desc(Total_Award)) %>%  # Sort by year and total award amount
  group_by(Year) %>%  # Group by year to select top 3 departments for each year
  slice_head(n = 3)  # Get the top 3 departments for each year

ggplot(top_departments_per_year, aes(x = Year, y = Total_Award, color = Funding_Org_Name, group = Funding_Org_Name)) +
  geom_line(size = 1.5) +  # Line plot with line thickness
  geom_point(size = 3) +  # Add points at each data point
  labs(title = "Top 3 Departments by Total Award Amount (2019-2023)", 
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
