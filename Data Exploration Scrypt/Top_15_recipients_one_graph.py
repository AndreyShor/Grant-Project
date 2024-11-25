import pandas as pd
from scipy.stats import chi2_contingency, pearsonr
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

###########################################

#calculating total funding awarded by each funding org
top_funders = df.groupby('Funding Org:Name')['Amount Awarded'].sum().nlargest(5).index

#preparing a filtered dataset for plotting
top_funder_data = df[df['Funding Org:Name'].isin(top_funders)]

#getting the top 15 recipients for each funder
top_recipients_per_funder = (
    top_funder_data.groupby(['Funding Org:Name', 'Recipient Org:Name'])['Amount Awarded']
    .sum()
    .groupby(level=0, group_keys=False)
    .nlargest(15)
    .reset_index()
)

plt.figure(figsize=(25, 10))

#creating a grouped bar chart
sns.barplot(
    data=top_recipients_per_funder,
    x='Amount Awarded',
    y='Recipient Org:Name',
    hue='Funding Org:Name',
    dodge=True
)

#adding labels and title
plt.title('Top 15 Recipients for Top 5 Funders', fontsize=16)
plt.xlabel('Amount Awarded (£)', fontsize=12)
plt.ylabel('Recipient Organization', fontsize=12)
plt.legend(title='Funding Org', fontsize=10, loc='upper right')
plt.tight_layout()

#showing the plot
plt.show()