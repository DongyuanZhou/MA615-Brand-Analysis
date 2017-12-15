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
#####################
##### Sentiment #####
#####################

## Get data
sb.df <- read.csv("sb_text.csv", header = TRUE, sep = ",",stringsAsFactors = FALSE)
dd.df <- read.csv("dd_text.csv", header = TRUE, sep = ",",stringsAsFactors = FALSE)

sb.word <- sb.df %>%
  group_by(id) %>%
  unnest_tokens(word,text)%>% 
  anti_join(stop_words)%>%
  anti_join(my_stop_word)%>%
  filter(str_detect(word, "^[a-z']+$"))%>%
  ungroup()

dd.word <- dd.df %>%
  group_by(id) %>%
  unnest_tokens(word,text)%>% 
  anti_join(stop_words)%>%
  anti_join(my_stop_word)%>%
  filter(str_detect(word, "^[a-z']+$"))%>%
  ungroup()

## sentiment 
get_sentiments("afinn")
AFINN <- get_sentiments("afinn") %>% dplyr::select(word,score)

### Starbucks
sb.sentiment <- sb.word %>%
  inner_join(AFINN, by = "word") %>%
  group_by(id) %>%
  summarize(sentiment_score = mean(score))
sb.sentiment$brand <- "Starbucks"

### Dunkin Donuts
dd.sentiment <- dd.word %>%
  inner_join(AFINN, by = "word") %>%
  group_by(id) %>%
  summarize(sentiment_score = mean(score))
dd.sentiment$brand <- "DunkinDonuts"

## plot the result
all.score <- rbind(sb.sentiment,dd.sentiment)
ggplot(all.score)+
  geom_bar(mapping=aes(x=sentiment_score, fill=brand), binwidth=1)+
  geom_vline(data=ddply(all.score, "brand", summarise, mean=mean(sentiment_score)), 
             aes(xintercept=mean, color=brand), linetype="dashed", size=1)+
  facet_grid(brand~.)+
  theme_bw()+
  scale_fill_brewer()