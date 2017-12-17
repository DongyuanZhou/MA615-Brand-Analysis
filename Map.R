library(plyr)
library(tidytext)
library(tidyverse)
library(twitteR)
library(stringr)
library(wordcloud)
library(reshape2)
library(RgoogleMaps)
library(ggmap)
library(ggplot2)
library(maptools)
library(sp)
library(tm)
library(NLP)
library(devtools)
library(streamR)
library(RCurl)
library(dplyr)
library(ROAuth)
library(graphTweets)
library(igraph)
library(readr)
library(leaflet)
library(rgdal)
library(SnowballC)
###############
##### map #####
###############
## read the data and plot map
sb_us.df3 <- read.csv('sb_us.csv',header = TRUE, sep = ",",stringsAsFactors = FALSE)
dd_us.df3 <- read.csv('dd_us.csv',header = TRUE, sep = ",",stringsAsFactors = FALSE)
sb_us.df3 <- data.frame(sb_us.df3)
sb_map <- leaflet(sb_us.df3) %>% addTiles('http://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                                          attribution='Map tiles by <a href="http://stamen.com">Stamen Design</a>, <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a> &mdash; Map data &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>')
sb_map %>% addCircles(~lon, ~lat, popup=sb_us.df3$lon, weight = 3, radius=40,
                      color="seagreen", stroke = TRUE, fillOpacity = 0.8)



dd_us.df3 <- data.frame(dd_us.df3)
dd_map <- leaflet(dd_us.df3) %>% addTiles('http://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                                          attribution='Map tiles by <a href="http://stamen.com">Stamen Design</a>, 
                                          <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a> &mdash;
                                          Map data &copy; 
                                          <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>')
dd_map %>% addCircles(~lon, ~lat, popup=dd_us.df3$lon, weight = 3, radius=40,
                      color="darkorange", stroke = TRUE, fillOpacity = 0.8) 
