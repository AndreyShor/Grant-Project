#government department analysis
#read the data to R
raw_data <- read.csv("/Users/sandychen/Desktop/Lancaster/SCC460 DS Fundamental/project/Grant-Project/Data/Awards_data_frame.csv")

# Load dplyr package
library(dplyr)

# Select columns by name
new_data <- raw_data %>%
  select(Award_Date, Funding_Org_Name, Amount_Awarded)

# Arrange (sort) the data frame by the 'Award_Date' column in ascending order
sorted_data <- new_data %>%
  arrange(Award_Date)

# Convert the 'Award_Date' column to Date type if it's not already
sorted_data$Award_Date <- as.Date(sorted_data$Award_Date)

# Filter the rows where the date is after or in the year 2021
filtered_data <- sorted_data %>%
  filter(Award_Date >= "2022-01-01")

# Filter data for rows in the year 2022
data_2022 <- filtered_data %>%
  filter(format(Award_Date, "%Y") == "2022")
# Count the number of rows (records) for each department
department_count_2022 <- data_2022 %>%
  group_by(Funding_Org_Name) %>%
  summarise(Count = n()) %>%
  arrange(desc(Count))

# View the results
print(department_count_2022)

# Calculate the mean Grant by department
grant_by_department_2022 <- data_2022 %>%
  group_by(Funding_Org_Name) %>%
  summarise(
    Total_Grant = sum(Amount_Awarded, na.rm = TRUE),
    Min_Grant = min(Amount_Awarded, na.rm = TRUE),
    Max_Grant = max(Amount_Awarded, na.rm = TRUE)
  ) %>% 
  mutate(department_count_2022)

# View the summary statistics
print(grant_by_department_2022)


#visualizing
# Load ggplot2 package
library(ggplot2)

######## Bar plot: Number of Grant in each department
ggplot(grant_by_department_2022, aes(x = Funding_Org_Name, y = Total_Grant)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  theme_minimal() +
  labs(title = "Total Grant per Department in 2022", x = "Department", y = "Total Grant")


library(viridis)
######create pie chart
# Convert the grant into proportions (to represent them as percentages in the pie chart)
grant_by_department_2022 <- grant_by_department_2022 %>%
  mutate(Percentage = Total_Grant / sum(Total_Grant) * 100)


# Create a pie chart with the viridis color palette
ggplot(grant_by_department_2022, aes(x = "", y = Percentage, fill = Funding_Org_Name)) +
  geom_bar(stat = "identity", width = 1) +  # Create the bars
  coord_polar(theta = "y") +  # Convert it to a pie chart
  theme_void() +  # Remove background and axes
  labs(title = "Grant Distribution in 2022") +
  scale_fill_viridis(discrete = TRUE) +  # Use the viridis palette for more colors
  geom_text(aes(label = paste0(round(Percentage, 1), "%")),  # Add percentage labels
            position = position_stack(vjust = 0.5),  # Place labels inside the segments
            color = "white", size = 5)  # Set text color and size
