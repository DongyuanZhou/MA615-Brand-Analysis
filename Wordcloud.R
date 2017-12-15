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
######################
##### Word cloud #####
######################

## Get data from twitter
sb.df <- read.csv("sb_text.csv", header = TRUE, sep = ",",stringsAsFactors = FALSE)
dd.df <- read.csv("dd_text.csv", header = TRUE, sep = ",",stringsAsFactors = FALSE)

## Stop words
data(stop_words)
my_stop_word <- data.frame(word=character(9))
my_stop_word$word <- c("star","bucks","starbucks","dunkin","donuts","dunkindonuts","https","rt","ed")

## word cloud for starbucks
## single word
sb.word <- sb.df %>%
  group_by(id) %>%
  unnest_tokens(word,text)%>% 
  anti_join(stop_words)%>%
  anti_join(my_stop_word)%>%
  filter(str_detect(word, "^[a-z']+$"))%>%
  ungroup()
sb.word.freq <- sb.word %>% count(word,sort=TRUE)
sb.word.freq %>% with(wordcloud(word, n, max.words = 50,colors=brewer.pal(n=8, "Dark2"),random.order=FALSE,rot.per=0.35))
## bigrams
sb.bigrams <- sb.df%>%
  group_by(id)%>%
  unnest_tokens(bigram, text, token = "ngrams", n = 2)%>%
  ungroup()
sb.bigrams.freq <- sb.bigrams%>%
  count(bigram, sort = TRUE)
sb.bigrams.seperated <- sb.bigrams.freq%>%
  separate(bigram, c("word1", "word2"), sep = " ")
sb.bigrams.filtered <- sb.bigrams.seperated %>%
  filter(!word1 %in% stop_words$word) %>%
  filter(!word2 %in% stop_words$word) %>%
  filter(!word1 %in% my_stop_word$word) %>%
  filter(!word2 %in% my_stop_word$word)%>%
  filter(str_detect(word1, "^[a-z']+$"))%>%
  filter(str_detect(word1, "^[a-z']+$"))
sb.bigrams.united <- sb.bigrams.filtered %>%
  unite(bigram, word1, word2, sep = " ")
sb.bigrams.united %>%with(wordcloud(bigram, n, max.words = 50,colors=brewer.pal(8, "Dark2"),random.order=FALSE,rot.per=0.35))

## word cloud for dunkin donuts
## single word
dd.word <- dd.df %>%
  group_by(id) %>%
  unnest_tokens(word,text)%>% 
  anti_join(stop_words)%>%
  anti_join(my_stop_word)%>%
  filter(str_detect(word, "^[a-z']+$"))%>%
  ungroup()
dd.word.freq <- dd.word %>% count(word,sort=TRUE)
dd.word.freq %>% with(wordcloud(word, n, max.words = 50,colors=brewer.pal(n=8, "Dark2"),random.order=FALSE,rot.per=0.35))
## bigrams
dd.bigrams <- dd.df%>%
  group_by(id)%>%
  unnest_tokens(bigram, text, token = "ngrams", n = 2)%>%
  ungroup()
dd.bigrams.freq <- dd.bigrams%>%
  count(bigram, sort = TRUE)
dd.bigrams.seperated <- dd.bigrams.freq%>%
  separate(bigram, c("word1", "word2"), sep = " ")
dd.bigrams.filtered <- dd.bigrams.seperated %>%
  filter(!word1 %in% stop_words$word) %>%
  filter(!word2 %in% stop_words$word) %>%
  filter(!word1 %in% my_stop_word$word) %>%
  filter(!word2 %in% my_stop_word$word)%>%
  filter(str_detect(word1, "^[a-z']+$"))%>%
  filter(str_detect(word1, "^[a-z']+$"))
dd.bigrams.united <- dd.bigrams.filtered %>%
  unite(bigram, word1, word2, sep = " ")
dd.bigrams.united %>% with(wordcloud(bigram, n, max.words = 50,colors=brewer.pal(8, "Dark2"),random.order=FALSE,rot.per=0.35))
