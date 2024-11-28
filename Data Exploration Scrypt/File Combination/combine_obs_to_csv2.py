import os
import io
import pandas as pd
from pyexcel_ods import get_data
from multiprocessing import Pool, cpu_count

# standardized header format
CORRECT_HEADER = [
    "Identifier", "Title", "Description", "Currency", "Amount Awarded",
    "Grant Programme:Code", "Grant Programme:Title", "Award Date",
    "Recipient Org:Identifier", "Recipient Org:Name", "Recipient Org:Charity Number",
    "Recipient Org:Company Number", "Recipient Org:Street Address", "Recipient Org:City",
    "Recipient Org:Country", "Recipient Org:Postal Code", "Funding Org:Identifier",
    "Funding Org:Name", "Managed by: Organisation Name", "Allocation Method",
    "From an open call?", "Award Authority Act: Authority Act Name", "Last modified",
    "Award type", "Number of recipients"
]


def load_file_to_memory(file_path):
    """Load the .ods file content into memory."""
    try:
        with open(file_path, 'rb') as f:
            return io.BytesIO(f.read())  #load file into memory as a BytesIO object
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
        return None


def align_to_standard_header(df):
    """
    Aligns a DataFrame's columns to the standard header.
    Extra columns are dropped, and missing columns are added with NaN values.
    """
    if df.empty:
        return pd.DataFrame(columns=CORRECT_HEADER)

    print(f"Original data (first 5 rows):")
    print(df.head())  #debugging step to inspect the raw data before alignment

    # Check if the first row should be the header
    if df.iloc[0].str.contains('Identifier').any():
        print("First row is a header. Re-aligning data.")
        df.columns = df.iloc[0]  #set the first row as the header
        df = df.drop(0)  #drop the first row now that it is set as header

    aligned_df = df.reindex(columns=CORRECT_HEADER, fill_value=pd.NA)
    print(f"Aligned data (first 5 rows):")
    print(aligned_df.head())  #eebugging step to inspect the aligned data

    return aligned_df


def extract_tab(file_data, tab_names=["#Awards", "Awards"]):
    #extract a tab from the .ods file and align it to the standard header
    try:
        data = get_data(file_data)
        for tab_name in tab_names:
            if tab_name in data:
                raw_data = pd.DataFrame(data[tab_name])
                print(f"Processing sheet: {tab_name} with {raw_data.shape[1]} columns.")

                #drop empty rows and columns
                raw_data = raw_data.dropna(how="all").dropna(axis=1, how="all")

                #ensure data is not empty before processing
                if raw_data.empty:
                    print(f"Sheet '{tab_name}' contains no valid data.")
                    continue

                #align the data to the standard header
                aligned_data = align_to_standard_header(raw_data)
                print(f"Aligned sheet with {aligned_data.shape[0]} rows and {aligned_data.shape[1]} columns.")
                return aligned_data

        print(f"No matching tabs found in the file. Skipping.")
        return pd.DataFrame(columns=CORRECT_HEADER)
    except Exception as e:
        print(f"Error extracting tab: {e}")
        return pd.DataFrame(columns=CORRECT_HEADER)


def process_file(file_path, combined_df):
    #process an individual file and return the aligned dataframe
    file_data = load_file_to_memory(file_path)
    if file_data:
        aligned_data = extract_tab(file_data)
        if not aligned_data.empty:
            print(f"Adding {aligned_data.shape[0]} rows from file: {file_path}")
            #append new data to combined dataframe, avoiding duplicates
            combined_df = pd.concat([combined_df, aligned_data], ignore_index=True, sort=False)
    return combined_df


def combine_tabs(folder_path, output_file, num_processes=None):
    """Combine all the #Awards tabs from .ods files in the folder."""
    all_files = [os.path.join(folder_path, f) for f in os.listdir(folder_path) if f.endswith('.ods')]
    df_list = []

    print(f"Found {len(all_files)} .ods files to process.")

    #determine the number of processes
    num_processes = num_processes or cpu_count()

    with Pool(num_processes) as pool:
        #process files in parallel and accumulate results
        results = pool.starmap(process_file, [(file, pd.DataFrame(columns=CORRECT_HEADER)) for file in all_files])

    #combine all DataFrames into one
    combined_df = pd.concat(results, ignore_index=True, sort=False)

    #debugging step: inspect the first few rows
    print("Combined DataFrame preview (first 5 rows):")
    print(combined_df.head())

    if not combined_df.empty:
        #drop duplicates (if necessary)
        combined_df = combined_df.drop_duplicates(ignore_index=True)
        print(f"Combined DataFrame has {len(combined_df)} rows.")
        combined_df.to_csv(output_file, index=False)
        print(f"Combined file saved to {output_file}")
    else:
        print("No valid data to combine. Exiting.")


# Example usage
if __name__ == "__main__":
    folder_with_ods_files = "ods"  #path to files
    output_csv = "combined_awards.csv" #output file
    combine_tabs(folder_with_ods_files, output_csv, num_processes=20)
