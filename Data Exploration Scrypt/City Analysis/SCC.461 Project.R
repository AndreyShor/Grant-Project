library(dplyr)
library(ggplot2)

# Load data sets
awards2019_2020 <- read.csv("~/Documents/R stuff/rowData_unitedkingdom_awards2019_2020.csv")
awards2020_2021 <- read.csv("~/Documents/R stuff/rowData_unitedkingdom_awards2020_2021.csv")
awards2021_2022 <- read.csv("~/Documents/R stuff/rowData_unitedkingdom_awards2021_2022.csv")
awards2022_2023 <- read.csv("~/Documents/R stuff/rowData_unitedkingdom_awards2022_2023.csv")
awards2023_2024 <- read.csv("~/Documents/R stuff/rowData_unitedkingdom_awards2023_2024.csv")


# Keep only 'Recipient_Org_City' column and convert to lowercase
awards2019_2020 <- awards2019_2020 %>%
  select(Recipient_Org_City) %>%
  mutate(Recipient_Org_City = tolower(Recipient_Org_City))

awards2020_2021 <- awards2020_2021 %>%
  select(Recipient_Org_City) %>%
  mutate(Recipient_Org_City = tolower(Recipient_Org_City))

awards2021_2022 <- awards2021_2022 %>%
  select(Recipient_Org_City) %>%
  mutate(Recipient_Org_City = tolower(Recipient_Org_City))

awards2022_2023 <- awards2022_2023 %>%
  select(Recipient_Org_City) %>%
  mutate(Recipient_Org_City = tolower(Recipient_Org_City))

awards2023_2024 <- awards2023_2024 %>%
  select(Recipient_Org_City) %>%
  mutate(Recipient_Org_City = tolower(Recipient_Org_City))


# Function to tally city occurrences and print the top 10
top_10_cities <- function(data) {
  data %>%
    count(Recipient_Org_City, sort = TRUE) %>%
    head(10) %>%
    print()
}

# Apply the function to each dataset
cat("Top 10 Cities for Awards 2019-2020:\n")
top_10_cities(awards2019_2020)

cat("\nTop 10 Cities for Awards 2020-2021:\n")
top_10_cities(awards2020_2021)

cat("\nTop 10 Cities for Awards 2021-2022:\n")
top_10_cities(awards2021_2022)

cat("\nTop 10 Cities for Awards 2022-2023:\n")
top_10_cities(awards2022_2023)

cat("\nTop 10 Cities for Awards 2023-2024:\n")
top_10_cities(awards2023_2024)

# Function to create a bar graph for the top 10 cities
plot_top_10_cities <- function(data, title) {
  # Create a tally of cities and get the top 10
  top_cities <- data %>%
    count(Recipient_Org_City, sort = TRUE) %>%
    slice_max(n, n = 10)
  
  # Create the bar graph
  ggplot(top_cities, aes(x = reorder(Recipient_Org_City, -n), y = n)) +
    geom_bar(stat = "identity", fill = "skyblue") +
    coord_flip() +
    labs(title = title, x = "City", y = "Count") +
    theme_minimal(base_size = 14)
}

# Apply the function to each dataset
plot1 <- plot_top_10_cities(awards2019_2020, "Cities Receiving High Numbers of Grants in 2019-2020")
plot2 <- plot_top_10_cities(awards2020_2021, "Cities Receiving High Numbers of Grants in 2020-2021")
plot3 <- plot_top_10_cities(awards2021_2022, "Cities Receiving High Numbers of Grants in 2021-2022")
plot4 <- plot_top_10_cities(awards2022_2023, "Cities Receiving High Numbers of Grants in 2022-2023")
plot5 <- plot_top_10_cities(awards2023_2024, "Cities Receiving High Numbers of Grants in 2023-2024")

# Display the plots
print(plot1)
print(plot2)
print(plot3)
print(plot4)
print(plot5)


# Create variables for analysis
A1 <- top_10_cities(awards2019_2020)
A2 <- top_10_cities(awards2020_2021)
A3 <- top_10_cities(awards2021_2022)

# Create a data frame in R with city names and average populations
city_populations <- data.frame(
  City = c("london", "birmingham", "manchester", "bristol", "nottingham", 
           "bradford", "sheffield", "leeds", "leicester", "cambridge", "coventry"),
  Average_Population = c(8845841, 1147129, 470408, 425224, 299794, 
                         547048, 590067, 799933, 355000, 146000, 365562)
)

# Print the data frame
print(city_populations)

# Function to get top 10 cities with their populations
top_10_cities_with_population <- function(data, city_populations) {
  top_cities <- data %>%
    count(Recipient_Org_City, sort = TRUE) %>%
    slice_max(n, n = 10)
  
  # Merge with city populations
  top_cities <- top_cities %>%
    left_join(city_populations, by = c("Recipient_Org_City" = "City"))
  
  return(top_cities)
}

# Apply the function to each dataset
A1 <- top_10_cities_with_population(awards2019_2020, city_populations)
A2 <- top_10_cities_with_population(awards2020_2021, city_populations)
A3 <- top_10_cities_with_population(awards2021_2022, city_populations)


# Function to calculate grants per capita
calculate_grants_per_capita <- function(data) {
  data %>%
    mutate(Grants_Per_1000 = (n / Average_Population) * 1000)
}

# Apply to each dataset
A1 <- calculate_grants_per_capita(A1)
A2 <- calculate_grants_per_capita(A2)
A3 <- calculate_grants_per_capita(A3)


# Combine all years into one dataset
all_years <- bind_rows(
  A1 %>% mutate(Year = "2019-2020"),
  A2 %>% mutate(Year = "2020-2021"),
  A3 %>% mutate(Year = "2021-2022")
)

# Scatter plot of Population vs. Total Grants
ggplot(all_years, aes(x = Average_Population, y = n, color = Year)) +
  geom_point(size = 3) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Population vs. Grants Awarded",
       x = "City Population",
       y = "Number of Grants",
       color = "Year") +
  theme_minimal()



# Bar plot of grants per capita for all years
ggplot(all_years, aes(x = reorder(Recipient_Org_City, -Grants_Per_1000), y = Grants_Per_1000, fill = Year)) +
  geom_bar(stat = "identity", position = "dodge") +
  coord_flip() +
  labs(title = "Grants Per 1,000 People in Each City",
       x = "City",
       y = "Grants Per 1,000 People") +
  theme_minimal()

# Calculate correlation between Population and Grants Awarded
cor_results <- all_years %>%
  group_by(Year) %>%
  summarise(Correlation = cor(Average_Population, n))

print(cor_results)



