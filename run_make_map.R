# Setup -------------
x <- c('tidyverse', 'xlsx', 'rJava', 'xlsxjars', 'stringr', 'readxl', 'countrycode', 'foreign', 'ggplot2', 'geosphere', 'maps', 'ggmap', 'RColorBrewer')
sapply(X = x, FUN = require, character.only = TRUE)
options(java.parameters = "-Xmx1024m", scipen = 15)
rm(list=ls())


# Get all call lines in the call_data data frame
source("C:/Users/thomas.preston/Desktop/TestProjects/GlobalMins/import_for_map.R")

if(nrow(call_data) == 0){stop('problem with the input function, 0 lines returned')}

# remove nas from the data frame (these can't be processed)
call_data <- call_data %>%
  filter(!is.na(lat_orig),
         !is.na(lon_orig),
         !is.na(lat_dest),
         !is.na(lon_dest)
  )

# Input country and find longitude for this country ------------------
# also filter so that we capture only call lines from said country
cntry = toupper("United Kingdom")

if(length(call_data$city_ci[call_data$orig_country==cntry]) == 0){stop('Country not in sample')}
capital_city <- as.character(unique(call_data$city_ci[call_data$orig_country==cntry]))

geocodeQueryCheck(userType = "free")
cntry_coords <- geocode(capital_city)

home_country_longitude = as.numeric(cntry_coords[[1]])
red_data <- call_data %>%
  filter(n_code_orig == countrycode(cntry, origin = "country.name", destination = "iso3n"))

# START HERE if rerunning ######################
# Import urban areas for the light effect ------------------
urban <- rgdal::readOGR("C:/Users/thomas.preston/Desktop/TestProjects/GlobalMins/ne_50m_urban_areas/ne_50m_urban_areas.shp")

urban_areas <- fortify(urban)

# Make a table with all call paths
call_lines <- list()
for(i in 1:nrow(red_data)){
  lon_orig <- red_data[i, "lon_orig"]
  lat_orig <- red_data[i, "lat_orig"]
  lat_dest <- red_data[i, "lat_dest"]
  lon_dest <- red_data[i, "lon_dest"]
  minutes <- red_data[i, "mins"]
  individual_line <- cbind(gcIntermediate(c(lon_orig, lat_orig), c(lon_dest, lat_dest), n=100, addStartEnd=TRUE, breakAtDateLine=F), i, minutes)
  call_lines[[i]] <- individual_line
}

all_lines <- as.data.frame(do.call('rbind', call_lines)) 


#Configure double map, all coords should be plotted within 
mp1 <- fortify(map(fill=TRUE, plot=FALSE))
mp2 <- mp1

mp2$long <- mp2$long + 360
mp2$group <- mp2$group + max(mp2$group) + 1

mp <- rbind(mp1, mp2)

# Adjust MAP for centring on the CAPITAL of country
# Else don't do anything, to that end we will plot in the middle portion of the graph
if(home_country_longitude < 0){
  mp$long <- mp$long - (360 + home_country_longitude)
} else {
  mp$long <- mp$long + home_country_longitude
}

# Adjust CALLS for centring on the CAPITAL of country
if(home_country_longitude < 0){
  all_lines$lon <- all_lines$lon - (360 + home_country_longitude)
} else {
  all_lines$lon <- all_lines$lon + home_country_longitude
}

# Adjust URBAN AREAS for centring on the CAPITAL of country
if(home_country_longitude < 0){
  urban_areas$long <- urban_areas$long - (360 + home_country_longitude)
} else {
  urban_areas$long <- urban_areas$long + home_country_longitude
}

# Get rid of lines that would previously have passed through the centre
all_lines <- all_lines %>%
  mutate(lon = if_else(lon < 180, lon + 360, lon),
         lon = if_else(lon >= 180, lon - 360, lon))

urban_areas <- urban_areas %>%
  mutate(long = if_else(long < 180, long + 360, long),
         long = if_else(long >= 180, long - 360, long))


# Put everythig together
call_map <- ggplot() + 
  geom_polygon(aes(x = long, y = lat, group = group), data = mp) +
  coord_map(xlim = c(-180, 180)) +
  geom_path(data = all_lines, aes(x = lon, y = lat, group = i, colour = log(minutes))) +
  scale_colour_gradient(low = "gray", high = "red") +
  geom_polygon(data = urban_areas, aes(x = long, y = lat, group = group), colour = 'white') +
  theme(panel.background = element_rect(fill = "#090D2A"),
        panel.grid.major = element_line(colour = "#090D2A"),
        panel.grid.minor = element_line(colour = "#090D2A"),
        axis.title.x = element_blank(),
        axis.text.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.y = element_blank(),
        legend.position = "none",
        axis.ticks.y = element_blank()
  ) 
call_map
ggsave(plot = call_map, filename = "C:/Users/thomas.preston/Desktop/TestProjects/GlobalMins/map_out.png", dpi = 2000)
