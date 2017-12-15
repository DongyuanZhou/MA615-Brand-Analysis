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
#################################
##### GET DATA FROM TWITTER #####
#################################

##### Basic information #####
requestURL <- "https://api.twitter.com/oauth/request_token"
accessURL <- "https://api.twitter.com/oauth/access_token"
authURL <- "https://api.twitter.com/oauth/authorize"
consumerKey <- 	"LFNRqX5i1PkB69SjEEncXWloq"
consumerSecret <- "4sDHqY6aLm7PRfJLxpq6GsWqphZxzX3dXLjssSLXYhO8wPwL3F"
my_oauth <- OAuthFactory$new(consumerKey = consumerKey, consumerSecret = consumerSecret, 
                             requestURL = requestURL, accessURL = accessURL, authURL = authURL)
my_oauth$handshake(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl"))
save(my_oauth, file = "my_oauth.Rdata")
load("my_oauth.Rdata")

api_key <- 'gz2mMwZ034OKz7Mp8lFLUPKq0'
api_secret <- 'eRDRllxvXZa6kgrsYOqZLyFMb6cA1Y0WQ2IBa38SnAGaRPSgcK'
access_token <- '931612557604982784-yL9hkFkMFI8ec4jbGZIisQ44sX05eUs'
access_token_secret <- '0sUPjj8iRYUpUSTVqfV7pdZdt78t15mm4Fk8zKupR0TdC'
setup_twitter_oauth(api_key, 
                    api_secret, 
                    access_token, 
                    access_token_secret)

##### Get data from twitter for Text analysis #####
sb.tweets = searchTwitter('@Starbucks', n=1000,lang = 'en')
sb.text = lapply(sb.tweets, function(t) t$getText())
sb.df <- data.frame(matrix(unlist(sb.text), nrow=1000, byrow=T),stringsAsFactors=FALSE)
colnames(sb.df) <- "text"
sb.df$id <- c(1:nrow(sb.df))
dd.tweets = searchTwitter('@DunkinDonuts',n=1000,lang = 'en')
dd.text = lapply(dd.tweets, function(t) t$getText())
dd.df <- data.frame(matrix(unlist(dd.text), nrow=1000, byrow=T),stringsAsFactors=FALSE)
colnames(dd.df) <- "text"
dd.df$id <- c(1:nrow(dd.df))
write.csv(sb.df,"sb_text.csv",row.names = FALSE)
write.csv(dd.df,"dd_text.csv",row.names = FALSE)

##### Get data from twitter for Hashtags #####
sb.hash = userTimeline("Starbucks", n = 3200) #2612 tweets
sb.hash = twListToDF(sb.hash)
sb.hash$Brand <- "Starbucks"
dd.hash = userTimeline("DunkinDonuts", n = 3200) # 2926tweets
dd.hash = twListToDF(dd.hash)
dd.hash$Brand <- "DunkinDonuts"
df.hash <- rbind(sb.hash,dd.hash)
write.csv(df.hash,"hashdata.csv",row.names = FALSE)

## Get data from twitter for Maps
filterStream(file.name = "map_shiny/sb_map.json",
             track = c("Starbucks"), 
             language = "en",
             location = c(-125,25,-66,50),
             timeout = 10,
             oauth = my_oauth)
filterStream(file.name = "map_shiny/dd_map.json",
             track = c("DunkinDonuts"), 
             language = "en",
             location = c(-125,25,-66,50),
             timeout = 10,
             oauth = my_oauth)
## Save as json file
sb_us <- parseTweets("map_shiny/sb_map.json")
dd_us <- parseTweets("map_shiny/dd_map.json")
## Select the column I need
sb_us.df2 = sb_us %>% select(text, retweet_count, favorited, retweeted, created_at, 
                             verified,location, description, user_created_at, 
                             statuses_count, followers_count,favourites_count, 
                             name, time_zone, friends_count, place_lat, place_lon)
sb_us.df2 <- rename(sb_us.df2, lon = place_lon, lat = place_lat)
sb_us.df3 <- sb_us.df2[complete.cases(sb_us.df2$lon),]
dd_us.df2 = dd_us %>% select(text, retweet_count, favorited, retweeted, created_at, 
                             verified,location, description, user_created_at, 
                             statuses_count, followers_count,favourites_count, 
                             name, time_zone, friends_count, place_lat, place_lon)
dd_us.df2 <- rename(dd_us.df2, lon = place_lon, lat = place_lat)
dd_us.df3 <- dd_us.df2[complete.cases(dd_us.df2$lon),]
## Save data as csv file
write.csv(sb_us.df3, "sb_us.csv", row.names = FALSE)
write.csv(dd_us.df3, "dd_us.csv", row.names = FALSE)