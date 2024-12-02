library(ggplot2)

Government_grants <- read.csv("~/Documents/Government_grants.csv")
View(Government_grants)

# Get a list of all unique cities
unique_cities <- unique(Government_grants$Recipient.Org.City)

# Standardize city names to lowercase to ignore capitalization
Government_grants$Recipient.Org.City <- tolower(Government_grants$Recipient.Org.City)

# Get a list of unique cities and their counts
city_counts <- table(Government_grants$Recipient.Org.City)

# Print the total count of unique cities
print(length(city_counts))

# Optional: View the table of counts for each city
print(city_counts)

# Convert the city names to character type if they aren't already
Government_grants$Recipient.Org.City <- as.character(Government_grants$Recipient.Org.City)

# Remove or replace non-UTF-8 characters
Government_grants$Recipient.Org.City <- iconv(Government_grants$Recipient.Org.City, from = "latin1", to = "UTF-8", sub = "")

# Converts to lowercase
Government_grants$Recipient.Org.City <- tolower(Government_grants$Recipient.Org.City)

# Get the number of unique cities
num_unique_cities <- length(unique(Government_grants$Recipient.Org.City))

# Print the number of unique cities
print(paste("The number of unique cities is:", num_unique_cities))

# Sort the cities by count in descending order
sorted_city_counts <- sort(city_counts, decreasing = TRUE)

# Get the top 15 cities
top_15_cities <- head(sorted_city_counts, 15)

# Print the top 15 cities with their counts
print(top_15_cities)

# Remove the 1st and 3rd elements from the list of top cities
top_15_cities <- top_15_cities[-c(1, 3)]

# Print the updated top cities
print(top_15_cities)

# Convert the top cities to a data frame for ggplot2
top_cities_df <- data.frame(
  City = names(top_15_cities),
  Count = as.numeric(top_15_cities)
)

# Create the bar plot
ggplot(top_cities_df, aes(x = reorder(City, -Count), y = Count)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  theme_minimal() +
  labs(
    title = "Top Cities Receiving Government Grants",
    x = "City",
    y = "Count of Grants"
  ) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))