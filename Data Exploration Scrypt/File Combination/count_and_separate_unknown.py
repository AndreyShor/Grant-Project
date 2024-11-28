import pandas as pd

#load the data
grants_file = "updated_grants_with_cities_district_county_region_ward.csv"
grants_df = pd.read_csv(grants_file, encoding='ISO-8859-1', low_memory=False)

#filter the rows where 'District' is missing (NaN) or 'Unknown'
unknown_rows = grants_df[grants_df['District'].isna() | (grants_df['District'] == 'Unknown')]

#save the filtered rows with 'Unknown' and missing values to a new CSV file
unknown_rows.to_csv("unknown.csv", index=False)

#filter the rows where 'District' is neither missing (NaN) nor 'Unknown'
cleaned_rows = grants_df[~grants_df['District'].isna() & (grants_df['District'] != 'Unknown')]

#save the cleaned rows (without 'Unknown' and missing values) to a new CSV file
cleaned_rows.to_csv("updated_grants_with_cities_district_county_region_ward_no_unknowns.csv", index=False)

#count the rows that were excluded (missing or 'Unknown' values in 'District')
unknown_and_missing_count = unknown_rows.shape[0]
print(f"Number of missing or 'unknown' values: {unknown_and_missing_count}")
