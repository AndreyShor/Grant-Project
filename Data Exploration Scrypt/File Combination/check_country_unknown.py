import pandas as pd

#load the data
data = pd.read_csv('unknown.csv', encoding='ISO-8859-1', low_memory=False)

#get unique countries
unique_countries = data['Recipient Org:Country'].dropna().unique()

#display the unique countries
print("Unique countries in the data:")
for country in unique_countries:
    print(country)
