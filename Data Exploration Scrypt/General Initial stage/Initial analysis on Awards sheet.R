library(readODS)
library(dplyr)
library(ggplot2)


# View all sheets
sheet_names = ods_sheets("2024-03-19_Government_Grants_Register_2022_to_2023.ods")
sheet_names

# Read in the sheet named "#Awards"
awards_data = read_ods("2024-03-19_Government_Grants_Register_2022_to_2023.ods",sheet="#Awards")

# Check missing data
colSums(is.na(awards_data))

# Group by funding organisations
awards_by_funder=awards_data %>%
  group_by(`Funding Org:Name`)%>%
  summarise(Total_Awarded=sum(`Amount Awarded`,na.rm = TRUE),
            Average_Awarded=mean(`Amount Awarded`,na.rm = TRUE),
            Count=n())

# Plot to show distributions of funding organisations
top_funders=awards_by_funder%>%arrange(desc(Total_Awarded))%>%head(10)

ggplot(top_funders,aes(x=reorder(`Funding Org:Name`,Total_Awarded),y=Total_Awarded))+
  geom_bar(stat="identity")+coord_flip()+
  labs(title="Top 10 Funders by Total Awarded",x="Funder",y="Total Awarded")

# Count awards per year
awards_data$Year=format(awards_data$`Award Date`,"%Y")
awards_by_year=awards_data %>%group_by(Year)%>%
  summarise(Total_Awarded=sum(`Amount Awarded`,na.rm = TRUE))

# Convert Year to numeric for proper ordering
awards_by_year$Year=as.numeric(awards_by_year$Year)

# Overlay bar plot and line chart
ggplot(awards_by_year,aes(x=Year,y=Total_Awarded))+
  geom_bar(stat="identity",fill="steelblue",alpha=0.7)+
  geom_line(color="red",size=1)+geom_point(color="darkred",size=2)+
  labs(title = "Total Awards Over the Years",x="Year",y="Total Awards")+
  scale_x_continuous(breaks=seq(1998,2023,by=1))+
  theme(axis.text.x=element_text(angle=45,hjust=1))

