import pandas as pd

#load datasets with proper encoding handling and replace missing values
worldcities = pd.read_csv('worldcities.csv', encoding='utf-8').fillna('')
recipient_org = pd.read_csv('updated_grants_with_cities_district_county_region_ward_no_unknowns.csv', encoding='ISO-8859-1').fillna('')

#normalize and clean columns for consistent matching
worldcities['city_ascii'] = worldcities['city_ascii'].str.strip().str.lower()
worldcities['country'] = worldcities['country'].str.strip().str.lower()
worldcities['admin_name'] = worldcities['admin_name'].str.strip().str.lower()  #clean the admin_name column

recipient_org['District'] = recipient_org['District'].str.strip().str.lower()
recipient_org['County'] = recipient_org['County'].str.strip().str.lower()
recipient_org['Recipient Org:Country'] = recipient_org['Recipient Org:Country'].str.strip().str.lower()

#merge based on District and Country (if available)
merged_data = recipient_org.merge(
    worldcities[['city_ascii', 'country', 'population', 'admin_name']],  #include admin_name in the merge
    left_on=['District', 'Recipient Org:Country'],
    right_on=['city_ascii', 'country'],
    how='left'
)

#create a lookup table for County and admin_name combinations to population
county_population_lookup = worldcities.set_index(['admin_name', 'country'])['population'].to_dict()

#check for 'Unknown' District and match with County (using admin_name as fallback if needed)
recipient_org['Population'] = merged_data['population']

#if the population is still 'Unknown', try filling it using the County and admin_name from worldcities
def fill_population(row):
    if pd.isna(row['Population']):  #if population is missing
        #try to find population using County and Recipient Org:Country (use to admin_name if no match)
        county_key = (row['County'], row['Recipient Org:Country'])
        if county_key in county_population_lookup:
            return county_population_lookup[county_key]
        else:
            return 'Unknown'  #return 'Unknown' if no match found
    return row['Population']

recipient_org['Population'] = recipient_org.apply(fill_population, axis=1)

#save the updated DataFrame to a new CSV file
recipient_org.to_csv('updated_grant_file_with_population.csv', index=False, encoding='utf-8')

#print the first few rows to validate results
print(recipient_org.head())
