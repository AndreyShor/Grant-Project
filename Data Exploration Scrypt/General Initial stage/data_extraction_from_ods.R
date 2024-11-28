# Data Analysis of Grant Data

## change according to your machine
library("tidyverse")
# Library to extract data
library("readODS")

## change path name on your machinee
setwd("/Users/andrejs.sorstkins/Documents/Data Science /Grant-Project")

# Read Data
rowData_all_awards <- read_ods('./Data/2024-03-19_Government_Grants_Register_2022_to_2023.ods', sheet =6)

# Double check content
summary(rowData_all_awards)

# Check number of rows
nrow(rowData_all_awards)
# Rename titles of rows for future work
colnames(rowData_all_awards) <- c("Identifier", "Title", "Description", "Currency", "Amount_Awarded",
                                  "Grant_Programme_Code", "Grant_Programme_Title", "Award_Date",
                                  "Recipient_Org_Identifier", "Recipient_Org_Name", "Recipient_Org_Charity_Number",
                                  "Recipient_Org_Company_Number", "Recipient_Org_Street_Address", "Recipient_Org_City",
                                  "Recipient_Org_Country", "Recipient_Org_Postal_Code", "Funding_Org_Identifier",
                                  "Funding_Org_Name", "Managed_by_Organisation_Name", "Allocation_Method", "From_an_open_call",
                                  "Award_Authority_Act","Last_modified", "Award_type", " Number_of_recipients", "none")

## 
# Create CSV file
write.csv(rowData_all_awards, file = "./Data/Awards_data_frame.csv", row.names = FALSE)
# Open File in R 
View(rowData_all_awards)

