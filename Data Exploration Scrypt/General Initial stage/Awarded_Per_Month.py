import pandas as pd
from scipy.stats import chi2_contingency, spearmanr, pearsonr
import seaborn as sns
import matplotlib.pyplot as plt

#loading the data
file_path = "Government_grants.csv"
df = pd.read_csv(file_path, encoding='ISO-8859-1') #had to put encoding to make it work

#explore relationships: in this case, i am exploring Funding and Recipient Org
#first I need to count the number of donations made by each funding org to recipient orgs
donation_counts = df.groupby(['Funding Org:Name', 'Recipient Org:Name']).size().reset_index(name='Donation Count')
print(donation_counts)

#showing the total donations made by each funding organization, in new lines.
funding_totals = df.groupby('Funding Org:Name')['Amount Awarded'].sum().reset_index()
print(funding_totals)

#showing the total donations received by the recipient organizations, in new lines.
recipient_totals = df.groupby('Recipient Org:Name')['Amount Awarded'].sum().reset_index()
print(recipient_totals)

#correlation analysis: Numerical Variables
#in this case im testing the correlation between amount awarded, with number of recipients.
if 'Amount Awarded' in df.columns and 'Number of recipients' in df.columns:
    amount = df['Amount Awarded']
    recipients = df['Number of recipients']
    corr, p_value = pearsonr(amount, recipients)
    print(f"Correlation: {corr}, P-value: {p_value}")

#categorical association: in this case, i am exploring Example Funding and Recipient Org
contingency_table = pd.crosstab(df['Funding Org:Name'], df['Recipient Org:Name'])
chi2, p, dof, ex = chi2_contingency(contingency_table)
print(f"Chi-Square Test: {chi2}, P-value: {p}")


#using the correct date column (just reading this from the file)
date_column = 'Award Date'

if date_column in df.columns:
    #converting the column to datetime
    df[date_column] = pd.to_datetime(df[date_column], errors='coerce')

    #extracting the month and year from the date
    df['Year-Month'] = df[date_column].dt.to_period('M')

    #grouping by the Year-Month and suming the donation amounts
    monthly_donations = df.groupby('Year-Month')['Amount Awarded'].sum().reset_index()

    #converting Year-Month to string for better plotting (stops the different datatypes issue)
    monthly_donations['Year-Month'] = monthly_donations['Year-Month'].astype(str)

    #plotting the bar chart
    plt.figure(figsize=(12, 6))
    sns.barplot(
        data=monthly_donations,
        x='Year-Month',
        y='Amount Awarded',
        palette='viridis'
    )

    #adding titles and labels
    plt.title('Total Amount Awarded Per Month', fontsize=16)
    plt.xlabel('Year-Month', fontsize=12)
    plt.ylabel('Amount Awarded (£)', fontsize=12)
    plt.xticks(rotation=45, ha='right')  # Rotate x-axis labels for better readability

    #showing the plot
    plt.tight_layout()
    plt.show()
else:
    #quick error checking
    print(f"The dataset does not contain a column named '{date_column}'.")