library(readODS)
library(readr)
library(dplyr)
library(ggplot2)
library(maps)
library(patchwork)
library(ineq)

# Only keep rows with Charity Number from each year's data file
data_16_c = data_1617[!is.na(data_1617$Recipient_Org_Charity_Number), ]
data_17_c = data_1718[!is.na(data_1718$Recipient_Org_Charity_Number), ]
data_18_c = data_1819[!is.na(data_1819$Recipient_Org_Charity_Number), ]
data_19_c = data_1920[!is.na(data_1920$Recipient_Org_Charity_Number), ]
data_20_c = data_2021[!is.na(data_2021$Recipient_Org_Charity_Number), ]
data_21_c = data_2122[!is.na(data_2122$Recipient_Org_Charity_Number), ]
data_22_c = data_2223[!is.na(data_2223$Recipient_Org_Charity_Number), ]
data_23_c = data_2324[!is.na(data_2324$Recipient_Org_Charity_Number), ]

# Dataframe details Charity recipients over the years
Char_recip_df = data.frame(
  Year = c(2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023),
  Count = c(nrow(data_16_c), nrow(data_17_c), nrow(data_18_c), 
            nrow(data_19_c), nrow(data_20_c), nrow(data_21_c), 
            nrow(data_22_c), nrow(data_23_c)),
  Amount = c(sum(data_16_c$Amount_Awarded),sum(data_17_c$Amount_Awarded),
             sum(data_18_c$Amount_Awarded),sum(data_19_c$Amount_Awarded),
             sum(data_20_c$Amount_Awarded),sum(data_21_c$Amount_Awarded),
             sum(data_22_c$Amount_Awarded),sum(data_23_c$Amount_Awarded)))
print(Char_recip_df)

# Plot the number of charity grants over the years
p1 = ggplot(data=Char_recip_df,aes(x=Year,y=Count))+
  geom_point(color="blue",size=2)+
  geom_line()+
  geom_text(aes(label=Count),vjust=-0.7,size=3)+
  labs(title="Charities receiving funds over the years",y="Charity Count")
theme_minimal()

# Plot amount awarded over the years
p2 = ggplot(data=Char_recip_df,aes(x=Year,y=Amount))+
  geom_col()+
  labs(title="amount awarded over the years",y="Total Amount Awarded (£)")+
  theme_minimal()

# Combine two plots
p1/p2


# Combining the dataset of the years into one and carry out some data cleaning.
comb_c_data = rbind(data_16_c, data_17_c, data_18_c, data_19_c,
                    data_20_c, data_21_c, data_22_c, data_23_c)
comb_c_data = comb_c_data %>%
  mutate(Recipient_Org_Name = ifelse(Recipient_Org_Name=="Hsopic UK",
                                     "Hospice UK", Recipient_Org_Name))%>%
  mutate(Recipient_Org_Name = ifelse(Recipient_Org_Name=="THE ROYAL SOCIETY",
                                     "The Royal Society",Recipient_Org_Name))%>%
  mutate(Recipient_Org_Name = ifelse(Recipient_Org_Name=="Football Foundation",
                                     "THE FOOTBALL FOUNDATION",Recipient_Org_Name))%>%
  mutate(Recipient_Org_Name = ifelse(Recipient_Org_Name=="The Football Foundation",
                                     "THE FOOTBALL FOUNDATION",Recipient_Org_Name))%>%
  mutate(Recipient_Org_City = ifelse(Recipient_Org_City=="London",
                                     "LONDON",Recipient_Org_City))


# Output a table of top 10 recipients with their awarded amount and awarded instances
top_recipients = comb_c_data %>%
  group_by(Recipient_Org_Name) %>%
  summarise(Total_Awarded=sum(Amount_Awarded,na.rm = TRUE),
            Funding_Count = n()) %>%
  arrange(desc(Total_Awarded)) %>%
  slice_head(n = 10)

# Output a table of top 10 cities with their awarded amount and awarded instances
top_recip_city = comb_c_data %>%
  group_by(Recipient_Org_City) %>%
  summarise(Total_Awarded=sum(Amount_Awarded,na.rm = TRUE),
            Funding_Count = n()) %>%
  arrange(desc(Total_Awarded)) %>%
  slice_head(n = 10)

# Output a table of top 10 Grants with the amount awarded
top_grant= comb_c_data %>%
  group_by(Grant_Programme_Title) %>%
  summarise(Total_Awarded=sum(Amount_Awarded,na.rm = TRUE),
            Funding_Count = n()) %>%
  arrange(desc(Total_Awarded)) %>%
  slice_head(n=10)

# Output a table of top 10 Funders with the amount they give out and total instances of funding
top_funder= comb_c_data %>%
  group_by(Funding_Org_Name) %>%
  summarise(Total_Awarded=sum(Amount_Awarded,na.rm = TRUE),
            Funding_Count = n()) %>%
  arrange(desc(Total_Awarded)) %>%
  slice_head(n=10)


# View the result
print(top_recipients)
print(top_recip_city)
print(top_grant)
print(top_funder)




# Calculate Gini coefficient to check for grant inequality
gini_coeff = ineq(comb_c_data$Amount_Awarded, type = "Gini")
print(gini_coeff)

# Total amount of grant awarded
total_grants = sum(comb_c_data$Amount_Awarded)
# Total amount of grant awarded for top 10 recipients
total_grants_10 =sum(top_recipients$Total_Awarded)
# Percentage of the top 10 organisations
total_grants_10/total_grants

# Total number of unique recipients
recipients = comb_c_data %>%
  group_by(Recipient_Org_Name) %>%
  summarise(Total_Awarded=sum(Amount_Awarded,na.rm=TRUE))
nrow(recipients)



# Filter out rows where Recipient_Org_Name is "Hospice UK"
filtered_data = comb_c_data %>%
  filter(Recipient_Org_Name == "Hospice UK") %>%
  mutate(Year = as.numeric(format(as.Date(Award_Date), "%Y")))  # Extract year from Award_Date

# Count the number of records for each year
yearly_counts = filtered_data %>%
  group_by(Year) %>%
  summarise(Record_Count = n())

# View the result
print(yearly_counts)