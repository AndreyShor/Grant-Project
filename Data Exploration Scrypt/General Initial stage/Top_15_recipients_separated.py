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


#test new plotting style
#identify the top 5 funders
top_funders = df.groupby('Funding Org:Name')['Amount Awarded'].sum().nlargest(5).index

#filtering data for only the top 5 funders
top_funder_data = df[df['Funding Org:Name'].isin(top_funders)]

#getting top 15 recipients for each funder
top_recipients_per_funder = (
    top_funder_data.groupby(['Funding Org:Name', 'Recipient Org:Name'])['Amount Awarded']
    .sum()
    .groupby(level=0, group_keys=False)
    .nlargest(15)
    .reset_index()
)

#plotting each of the funder's data and saving it as separate images
for funder in top_funders:
    #filter data for this specific funder
    funder_data = top_recipients_per_funder[top_recipients_per_funder['Funding Org:Name'] == funder]

    #create a new plot for this funder
    plt.figure(figsize=(10, 8))
    sns.barplot(
        data=funder_data,
        x='Amount Awarded',
        y='Recipient Org:Name',
        palette='viridis'
    )

    #adding titles and labels
    plt.title(f"Top 15 Recipients for {funder}", fontsize=16)
    plt.xlabel('Amount Awarded (£)', fontsize=12)
    plt.ylabel('Recipient Org', fontsize=12)

    #saving the plot as an image
    file_name = f"Top_15_Recipients_{funder.replace(' ', '_')}.png"
    plt.savefig(file_name, bbox_inches='tight')
    plt.close()  # Close the plot to avoid overlapping