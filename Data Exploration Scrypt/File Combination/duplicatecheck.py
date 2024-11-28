import pandas as pd

#load CSV file into a dataframe
df = pd.read_csv('updated_recipient_org.csv')

#find duplicate rows based on all columns
duplicates = df[df.duplicated()]

#remove duplicate rows by only keeping the first occurrence
df_no_duplicates = df.drop_duplicates()

#save the dataframe without duplicates to a new CSV
df_no_duplicates.to_csv('no_duplicates.csv', index=False)

#show the DataFrame without duplicates
print(df_no_duplicates)
