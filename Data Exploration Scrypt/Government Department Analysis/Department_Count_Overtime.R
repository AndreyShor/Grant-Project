#government department analysis
# Load necessary libraries
library(ggplot2)
library(dplyr)
library(lubridate)

#read data
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

# Remove rows with missing values in the department column (Funding_Org_Name)
raw_data_filtered <- raw_data_filtered %>%
  filter(!is.na(Funding_Org_Name))

# Count the occurrences of each department per Award_Date
department_count_over_time <- raw_data_filtered %>%
  group_by(Award_Date, Funding_Org_Name) %>%
  summarise(Department_Count = n()) %>%  # Count records per department on each date
  ungroup()

# Create the line chart
ggplot(department_count_over_time, aes(x = Award_Date, y = Department_Count, color = Funding_Org_Name, group = Funding_Org_Name)) +
  geom_line(linewidth = 1.5) +  # Make the lines thicker for better visibility
  labs(title = "Department Count Over Time (2019-2023)",
       x = "Date", y = "Number of Records (Department Count)") +
  theme_minimal() +  # Apply a clean theme
  theme(axis.text.x = element_text(angle = 45, hjust = 1),  # Rotate the x-axis labels
        axis.text = element_text(size = 10),  # Adjust text size of axis
        axis.title = element_text(size = 12),  # Increase size of axis titles
        plot.title = element_text(size = 14, hjust = 0.5)) +  # Center the title and adjust its size
  scale_x_date(date_labels = "%b %Y", date_breaks = "6 months")  # Format x-axis labels as Month Year and set breaks every 6 months
