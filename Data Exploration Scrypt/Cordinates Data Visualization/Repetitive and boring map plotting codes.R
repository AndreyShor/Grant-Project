library(ggplot2)
library(dplyr)
library(maps)
library(leaflet)
library(leaflet.extras)
library(htmlwidgets)


# Interactive map
plot_intmap = function(dataset){
  leaflet(dataset) %>% 
    addTiles() %>%
    addCircleMarkers(~Longitude,~Latitude,radius=~log(Amount_Awarded+1),
                     color = "blue",popup = ~paste("Recipient:",Recipient_Org_Name,"<br>",
                                                   "Amount:",Amount_Awarded)) %>%
    setView(lng=mean(data_2324$Longitude,na.rm=TRUE),
            lat=mean(data_2324$Latitude,na.rm=TRUE), 
            zoom=6)}

intmap = plot_intmap(data_1617)
saveWidget(intmap, "data_2016-2017_intmap.html")

intmap = plot_intmap(data_1718)
saveWidget(intmap, "data_2017-2018_intmap.html")

intmap = plot_intmap(data_1819)
saveWidget(intmap, "data_2018-2019_intmap.html")

intmap = plot_intmap(data_1920)
saveWidget(intmap, "data_2019-2020_intmap.html")

intmap = plot_intmap(data_2021)
saveWidget(intmap, "data_2020-2021_intmap.html")

intmap = plot_intmap(data_2122)
saveWidget(intmap, "data_2021-2022_intmap.html")

intmap = plot_intmap(data_2223)
saveWidget(intmap, "data_2022-2023_intmap.html")

intmap = plot_intmap(data_2324)
saveWidget(intmap, "data_2023-2024_intmap.html")





# Function for plotting heat map
plot_heatmap = function(dataset,lat_col="Latitude",lon_col="Longitude",
                        amount_col="Amount_Awarded"){
  # Plotting of heat map
  hm = leaflet(dataset) %>% addTiles() %>%
    addHeatmap(lng=~get(lon_col),lat=~get(lat_col), 
               intensity=~get(amount_col),blur=30) %>%
    setView(lng=mean(dataset[[lon_col]],na.rm=TRUE),
            lat=mean(dataset[[lat_col]],na.rm=TRUE),
            zoom=6)
  return(hm)}

heatmap = plot_heatmap(data_1617)
saveWidget(heatmap, "data_2016-2017_heatmap.html")

heatmap = plot_heatmap(data_1718)
saveWidget(heatmap, "data_2017-2018_heatmap.html")

heatmap = plot_heatmap(data_1819)
saveWidget(heatmap, "data_2018-2019_heatmap.html")

heatmap = plot_heatmap(data_1920)
saveWidget(heatmap, "data_2019-2020_heatmap.html")

heatmap = plot_heatmap(data_2021)
saveWidget(heatmap, "data_2020-2021_heatmap.html")

heatmap = plot_heatmap(data_2122)
saveWidget(heatmap, "data_2021-2022_heatmap.html")

heatmap = plot_heatmap(data_2223)
saveWidget(heatmap, "data_2022-2023_heatmap.html")

heatmap = plot_heatmap(data_2324)
saveWidget(heatmap, "data_2023-2024_heatmap.html")


# Load UK map data
uk_map = map_data("world",region="UK")

# Create the heat map
ggplot() +
  geom_polygon(data=uk_map,aes(x=long,y=lat,group=group),fill="gray90",color="black")+
  stat_density2d(data=data_1617,aes(x=Longitude,y=Latitude,fill=after_stat(level)),
                 geom="polygon",alpha=0.6)+scale_fill_gradient(low="blue",high="red")+
  labs(title="Heat Map of Awards Across the UK(2016-2017)",x="Longitude",y="Latitude")

ggplot() +
  geom_polygon(data=uk_map,aes(x=long,y=lat,group=group),fill="gray90",color="black")+
  stat_density2d(data=data_1718,aes(x=Longitude,y=Latitude,fill=after_stat(level)),
                 geom="polygon",alpha=0.6)+scale_fill_gradient(low="blue",high="red")+
  labs(title="Heat Map of Awards Across the UK(2017-2018)",x="Longitude",y="Latitude")

ggplot() +
  geom_polygon(data=uk_map,aes(x=long,y=lat,group=group),fill="gray90",color="black")+
  stat_density2d(data=data_1819,aes(x=Longitude,y=Latitude,fill=after_stat(level)),
                 geom="polygon",alpha=0.6)+scale_fill_gradient(low="blue",high="red")+
  labs(title="Heat Map of Awards Across the UK(2018-2019)",x="Longitude",y="Latitude")

ggplot() +
  geom_polygon(data=uk_map,aes(x=long,y=lat,group=group),fill="gray90",color="black")+
  stat_density2d(data=data_1920,aes(x=Longitude,y=Latitude,fill=after_stat(level)),
                 geom="polygon",alpha=0.6)+scale_fill_gradient(low="blue",high="red")+
  labs(title="Heat Map of Awards Across the UK(2019-2020)",x="Longitude",y="Latitude")

ggplot() +
  geom_polygon(data=uk_map,aes(x=long,y=lat,group=group),fill="gray90",color="black")+
  stat_density2d(data=data_2021,aes(x=Longitude,y=Latitude,fill=after_stat(level)),
                 geom="polygon",alpha=0.6)+scale_fill_gradient(low="blue",high="red")+
  labs(title="Heat Map of Awards Across the UK(2020-2021)",x="Longitude",y="Latitude")

ggplot() +
  geom_polygon(data=uk_map,aes(x=long,y=lat,group=group),fill="gray90",color="black")+
  stat_density2d(data=data_2122,aes(x=Longitude,y=Latitude,fill=after_stat(level)),
                 geom="polygon",alpha=0.6)+scale_fill_gradient(low="blue",high="red")+
  labs(title="Heat Map of Awards Across the UK(2021-2022)",x="Longitude",y="Latitude")

ggplot() +
  geom_polygon(data=uk_map,aes(x=long,y=lat,group=group),fill="gray90",color="black")+
  stat_density2d(data=data_2223,aes(x=Longitude,y=Latitude,fill=after_stat(level)),
                 geom="polygon",alpha=0.6)+scale_fill_gradient(low="blue",high="red")+
  labs(title="Heat Map of Awards Across the UK(2022-2023)",x="Longitude",y="Latitude")

ggplot() +
  geom_polygon(data=uk_map,aes(x=long,y=lat,group=group),fill="gray90",color="black")+
  stat_density2d(data=data_2324,aes(x=Longitude,y=Latitude,fill=after_stat(level)),
                 geom="polygon",alpha=0.6)+scale_fill_gradient(low="blue",high="red")+
  labs(title="Heat Map of Awards Across the UK(2023-2024)",x="Longitude",y="Latitude")