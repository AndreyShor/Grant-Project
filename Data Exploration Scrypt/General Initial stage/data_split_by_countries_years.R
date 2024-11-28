
setwd("/Users/andrejs.sorstkins/Documents/Data Science /Grant-Project")
library("tidyverse")
library(lubridate)

# Read Data
rowData_all_awards <- read.csv(file = "./Data/Awards_data_frame.csv")

######################################## Data Cleaning ########################################################

# format country names
rowData_all_awards$Recipient_Org_Country <- gsub(" ", "", tolower(rowData_all_awards$Recipient_Org_Country))

# format date
rowData_all_awards$Award_Date <- as.Date(rowData_all_awards$Award_Date, format = "%Y-%m-%d")

######################################## Main 3 Groups ########################################################
#UK Data
rowData_unitedkingdom_awards <- rowData_all_awards %>% filter(Recipient_Org_Country %in% c("unitedkingdom", "england", "scotland", "northernireland", "wales"))

summary(rowData_unitedkingdom_awards)

#Non UK Data
rowData_non_Uk_awards <- rowData_all_awards %>% filter(Recipient_Org_Country != "unitedkingdom") %>%
                                                filter(Recipient_Org_Country != "england") %>%
                                                filter(Recipient_Org_Country != "scotland") %>%
                                                filter(Recipient_Org_Country != "northernireland") %>%
                                                filter(Recipient_Org_Country != "wales") %>%
                                                filter(Recipient_Org_Country != "redacted")

#Redacted awards 
rowData_redacted_awards <- rowData_all_awards %>% filter(Recipient_Org_Country == "redacted")


######################################## Data Sets In UK marked by Year 2019 - 2024 ########################################################

# Scripts bellow to download specific data from the data frame

#Country specific data
rowData_unitedkingdom_awards <- rowData_all_awards %>% filter(Recipient_Org_Country == "unitedkingdom")
rowData_england_awards <- rowData_all_awards %>% filter(Recipient_Org_Country == "england")
rowData_scotland_awards <- rowData_all_awards %>% filter(Recipient_Org_Country == "scotland")
rowData_northernireland_awards <- rowData_all_awards %>% filter(Recipient_Org_Country == "northernireland")
rowData_wales_awards <- rowData_all_awards %>% filter(Recipient_Org_Country == "wales")

# Country specific data between 2023 and 2024 year
rowData_unitedkingdom_awards_2023_2024 <- rowData_unitedkingdom_awards %>% filter(year(Award_Date) >= 2023 & year(Award_Date) <= 2024)
rowData_england_awards_2023_2024 <- rowData_england_awards %>% filter(year(Award_Date) >= 2023 & year(Award_Date) <= 2024)
rowData_scotland_awards_2023_2024 <- rowData_scotland_awards %>% filter(year(Award_Date) >= 2023 & year(Award_Date) <= 2024)
rowData_northernireland_awards_2023_2024 <- rowData_northernireland_awards %>% filter(year(Award_Date) >= 2023 & year(Award_Date) <= 2024)
rowData_wales_awards_2023_2024 <- rowData_wales_awards %>% filter(year(Award_Date) >= 2023 & year(Award_Date) <= 2024)

# Country specific data between 2022 and 2023 year
rowData_unitedkingdom_awards_2022_2023 <- rowData_unitedkingdom_awards %>% filter(year(Award_Date) >= 2022 & year(Award_Date) < 2023)
rowData_england_awards_2022_2023 <- rowData_england_awards %>% filter(year(Award_Date) >= 2022 & year(Award_Date) < 2023)
rowData_scotland_awards_2022_2023 <- rowData_scotland_awards %>% filter(year(Award_Date) >= 2022 & year(Award_Date) < 2023)
rowData_northernireland_awards_2022_2023 <- rowData_northernireland_awards %>% filter(year(Award_Date) >= 2022 & year(Award_Date) < 2023)
rowData_wales_awards_2022_2023 <- rowData_wales_awards %>% filter(year(Award_Date) >= 2022 & year(Award_Date) < 2023)

summary(rowData_unitedkingdom_awards_2022_2023)

# Country specific data between 2021 and 2022 year

rowData_unitedkingdom_awards_2021_2022 <- rowData_unitedkingdom_awards %>% filter(year(Award_Date) >= 2021 & year(Award_Date) < 2022)
rowData_england_awards_2021_2022 <- rowData_england_awards %>% filter(year(Award_Date) >= 2021 & year(Award_Date) < 2022)
rowData_scotland_awards_2021_2022 <- rowData_scotland_awards %>% filter(year(Award_Date) >= 2021 & year(Award_Date) < 2022)
rowData_northernireland_awards_2021_2022 <- rowData_northernireland_awards %>% filter(year(Award_Date) >= 2021 & year(Award_Date) < 2022)
rowData_wales_awards_2021_2022 <- rowData_wales_awards %>% filter(year(Award_Date) >= 2021 & year(Award_Date) < 2022)

# Country specific data between 2020 and 2021 year

rowData_unitedkingdom_awards_2020_2021 <- rowData_unitedkingdom_awards %>% filter(year(Award_Date) >= 2020 & year(Award_Date) < 2021)
rowData_england_awards_2020_2021 <- rowData_england_awards %>% filter(year(Award_Date) >= 2020 & year(Award_Date) < 2021)
rowData_scotland_awards_2020_2021 <- rowData_scotland_awards %>% filter(year(Award_Date) >= 2020 & year(Award_Date) < 2021)
rowData_northernireland_awards_2020_2021 <- rowData_northernireland_awards %>% filter(year(Award_Date) >= 2020 & year(Award_Date) < 2021)
rowData_wales_awards_2020_2021 <- rowData_wales_awards %>% filter(year(Award_Date) >= 2020 & year(Award_Date) < 2021)

# Country specific data between 2019 and 2020 year

rowData_unitedkingdom_awards_2019_2020 <- rowData_unitedkingdom_awards %>% filter(year(Award_Date) >= 2019 & year(Award_Date) < 2020)
rowData_england_awards_2019_2020 <- rowData_england_awards %>% filter(year(Award_Date) >= 2019 & year(Award_Date) < 2020)
rowData_scotland_awards_2019_2020 <- rowData_scotland_awards %>% filter(year(Award_Date) >= 2019 & year(Award_Date) < 2020)
rowData_northernireland_awards_2019_2020 <- rowData_northernireland_awards %>% filter(year(Award_Date) >= 2019 & year(Award_Date) < 2020)
rowData_wales_awards_2019_2020 <- rowData_wales_awards %>% filter(year(Award_Date) >= 2019 & year(Award_Date) < 2020)

######################################## Non Uk Data Grouping and UK Data ########################################################

# Group Awards by Years in Non UK Countries

summary_df_non_UK_by_Years <- rowData_non_Uk_awards %>%
  group_by(year(Award_Date)) %>%
  summarize(Total_Value = n(), .groups = "drop")

colnames(summary_df_non_UK_by_Years) <- c("Year", "Total_Value")
summary_df_non_UK_by_Years <- summary_df_non_UK_by_Years %>% arrange(desc(Year))
summary_df_non_UK_by_Years


# Group Awards by Years in UK Countries

summary_df_UK_by_Years <- rowData_unitedkingdom_awards %>%
  group_by(year(Award_Date)) %>%
  summarize(Total_Value = n(), .groups = "drop")

colnames(summary_df_UK_by_Years) <- c("Year", "Total_Value")
summary_df_UK_by_Years <- summary_df_UK_by_Years %>% arrange(desc(Year))
summary_df_UK_by_Years

# Merge UK and Non UK Data

merged_df <- merge(summary_df_UK_by_Years, summary_df_non_UK_by_Years, by = "Year", all.x = TRUE)

colnames(merged_df) <- c("Year", "Total_Value", "Total_Value_Non_UK")
merged_df <- merged_df %>% arrange(desc(Year))
merged_df


# Linear grpah of UK and Non UK Awards from mergeData set from 2019 to 2024

# limit data frmae from 2019
merged_df <- merged_df %>% filter(Year >= 2019)

# Visiualize merged_df in ggplot
ggplot(merged_df, aes(x = Year, y = Total_Value, color = "UK")) +
  geom_line() +
  geom_point() +
  geom_line(aes(x = Year, y = Total_Value_Non_UK, color = "Non UK")) +
  geom_point() +
  theme_minimal() +
  labs(title = "UK and Non UK Awards by Year", x = "Year", y = "Total Awards")


######################################## Uk Data for 2022 and 2023 by Month ########################################################


# Group by month
summary_df_UK_by_Month <- rowData_unitedkingdom_awards_2022_2023 %>%
  group_by(month(Award_Date)) %>%
  summarize(Total_Value = n(), .groups = "drop")

colnames(summary_df_UK_by_Month) <- c("Year", "Total_Value")
summary_df_UK_by_Month

# Visiualize summary_df_UK_by_Month in ggplot

ggplot(summary_df_UK_by_Month, aes(x = Year, y = Total_Value)) +
  geom_bar(stat = "identity") +
  theme_minimal() +
  labs(title = "UK Awards by Month from 2022 to 2023", x = "Month", y = "Total Awards")

# Get data for 4 month in 2022

rowData_unitedkingdom_awards_4_2022 <- rowData_unitedkingdom_awards %>% filter(month(Award_Date) == 4)
summary(rowData_unitedkingdom_awards_4_2022)

# Split data by days in 4.month

summary_df_UK_by_Day_4 <- rowData_unitedkingdom_awards_4_2022 %>%
  group_by(day(Award_Date)) %>%
  summarize(Total_Value = n(), .groups = "drop")

summary_df_UK_by_Day_4

# Total number of awards on 01/04/2022

day_01_04_2022 <- max(summary_df_UK_by_Day_4$Total_Value)
day_01_04_2022

totalNumberOfRows <- nrow(rowData_all_awards)
totalNumberOfRows

#percentage of awards on 01/04/2022 compare to all data 
percentage <- (day_01_04_2022 / totalNumberOfRows) * 100
percentage

# Extract data for 01/04/2022

rowData_unitedkingdom_awards_01_04_2022 <- rowData_unitedkingdom_awards_4_2022 %>% filter(day(Award_Date) == 1)
summary(rowData_unitedkingdom_awards_01_04_2022)

# Export data to csv
write.csv(rowData_unitedkingdom_awards_01_04_2022, file = "./Data/rowData_unitedkingdom_awards_01_04_2022.csv", row.names = FALSE)


