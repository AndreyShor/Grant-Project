import os
import pandas as pd
from concurrent.futures import ThreadPoolExecutor


def read_postcode_file(file_path):
    #read CSV file and extract relevant columns (Postcode, District, County, Region, Ward, Country)
    df = pd.read_csv(file_path, encoding='utf-8-sig', low_memory=False)
    df = df[['Postcode', 'District', 'County', 'Region', 'Ward', 'Country']]
    return df


#function to process and merge with the grants dataset
def merge_grants_with_postcodes(grants_df, postcodes_df):
    #normalize postcodes for consistent comparison (strip whitespace, uppercase, and remove spaces)
    grants_df['Recipient Org:Postal Code'] = grants_df['Recipient Org:Postal Code'].str.strip().str.upper().str.replace(
        ' ', '')
    postcodes_df['Postcode'] = postcodes_df['Postcode'].str.strip().str.upper().str.replace(' ', '')

    #merge grants with the postcodes DataFrame on the postcode column
    merged_df = grants_df.merge(
        postcodes_df[['Postcode', 'District', 'County', 'Region', 'Ward', 'Country']],  #select relevant columns from postcodes
        left_on='Recipient Org:Postal Code',
        right_on='Postcode',
        how='left'
    )

    #fill missing cities (districts) in the grants dataset with District if available
    merged_df['Recipient Org:City'] = merged_df['Recipient Org:City'].fillna(merged_df['District'])

    #add the District, County, Region, and Ward to the final DataFrame, filling missing values
    merged_df['District'] = merged_df['District'].fillna('Unknown')  #replace missing District with 'Unknown'
    merged_df['County'] = merged_df['County'].fillna('Unknown')  #replace missing County with 'Unknown'
    merged_df['Region'] = merged_df['Region'].fillna('Unknown')  #replace missing Region with 'Unknown'
    merged_df['Ward'] = merged_df['Ward'].fillna('Unknown')  #replace missing Ward with 'Unknown'
    merged_df['Country'] = merged_df['Country'].fillna('Unknown')

    #drop the extra "Postcode" column from postcodes.csv after merging
    merged_df.drop(columns=['Postcode'], inplace=True)

    return merged_df


def main():
    #load the government grants dataset
    grants_file = "combined_awards.csv"
    grants_df = pd.read_csv(grants_file, encoding='ISO-8859-1', low_memory=False)

    #get the list of postcode CSV files in the postcode_data folder
    postcode_data_folder = 'postcode_data'
    postcode_files = [f for f in os.listdir(postcode_data_folder) if f.endswith('.csv')]

    #use ThreadPoolExecutor to read and merge files concurrently. Multithreading makes it so much faster.
    with ThreadPoolExecutor(max_workers=20) as executor:
        #read all postcode CSV files concurrently
        futures = [executor.submit(read_postcode_file, os.path.join(postcode_data_folder, file)) for file in
                   postcode_files]

        #collect results
        postcodes_dfs = [future.result() for future in futures]

        #merge all postcode DataFrames into one
        full_postcodes_df = pd.concat(postcodes_dfs, ignore_index=True)

        #merge the grants dataset with the concatenated postcode DataFrame
        merged_df = merge_grants_with_postcodes(grants_df, full_postcodes_df)

        #save the updated grants dataset
        merged_df.to_csv("updated_grants_with_cities_district_county_region_ward_country.csv", index=False, encoding='utf-8')

        #print summary of how many missing cities were filled
        missing_filled = merged_df['Recipient Org:City'].isna().sum()
        print(f"\nFilled {len(grants_df) - missing_filled} missing cities from postcodes.")


if __name__ == '__main__':
    main()
