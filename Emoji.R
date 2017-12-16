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
#################
##### Emoji #####
#################

##### Basic Information #####
api_secret <- 'eRDRllxvXZa6kgrsYOqZLyFMb6cA1Y0WQ2IBa38SnAGaRPSgcK'
access_token <- '931612557604982784-yL9hkFkMFI8ec4jbGZIisQ44sX05eUs'
access_token_secret <- '0sUPjj8iRYUpUSTVqfV7pdZdt78t15mm4Fk8zKupR0TdC'
setup_twitter_oauth(api_key, 
                    api_secret, 
                    access_token, 
                    access_token_secret)

##### Get data from twitter for Emoji #####
ht <- '#DunkinDonuts' 
tweets.raw <- searchTwitter(ht, n = 3000, lang = 'en')
df <- twListToDF(strip_retweets(tweets.raw, strip_manual = TRUE, strip_mt = TRUE))
df$hashtag <- ht
df$created <- as.POSIXlt(df$created)
df$text <- iconv(df$text, 'latin1', 'ASCII', 'byte')
df$url <- paste0('https://twitter.com/', df$screenName, '/status/', df$id)
names(df)[12]<-"retweets"
df.a <- subset(df, select = c(text, created, url, latitude, longitude, retweets, hashtag))
tweets$z <- 1
tweets$created <- as.POSIXlt(tweets$created)
df$username <- substr(substr(df$url, 21, nchar(as.character(df$url))), 1, nchar(substr(df$url, 21, nchar(as.character(df$url))))-26);
tweets.full <- df
tweets.full$X <- NULL
tweets.full$z <- 1
tweets.full$created <- as.POSIXlt(tweets.full$created)
tweets.dupes <- tweets.full[duplicated(tweets.full$url), ]
tweets <- tweets.full[!duplicated(tweets.full$url), ]
tweets <- arrange(tweets, url)
row.names(tweets) <- NULL
tweets$tweetid <- as.numeric(row.names(tweets))
nrow(tweets)
tweets.final <- tweets

##### Get data dictionary
emdict.la <- read.csv('emoticon_conversion_noGraphic.csv', header = F)#Lauren Ancona; https://github.com/laurenancona/twimoji/tree/master/twitterEmojiProject
emdict.la <- emdict.la[-1, ]; row.names(emdict.la) <- NULL; names(emdict.la) <- c('unicode', 'bytes', 'name'); emdict.la$emojiid <- row.names(emdict.la);
emdict.jpb <- read.csv('emDict.csv', header = F) #Jessica Peterka-Bonetta; http://opiateforthemass.es/articles/emoticons-in-R/
emdict.jpb <- emdict.jpb[-1, ]; row.names(emdict.jpb) <- NULL; names(emdict.jpb) <- c('name', 'bytes', 'rencoding'); emdict.jpb$name <- tolower(emdict.jpb$name);
emdict.jpb$bytes <- NULL;
emojis <- merge(emdict.la, emdict.jpb, by = 'name');  emojis$emojiid <- as.numeric(emojis$emojiid); emojis <- arrange(emojis, emojiid);

###### FIND TOP EMOJIS FOR A GIVEN SUBSET OF THE DATA
tweets <- tweets.final;
# tweets <- subset(tweets.final, hashtag %in% c('#womensmarch'));
## create full tweets by emojis matrix
df.s <- matrix(NA, nrow = nrow(tweets), ncol = ncol(emojis)); 
system.time(df.s <- sapply(emojis$rencoding, regexpr, tweets$text, ignore.case = T, useBytes = T));
rownames(df.s) <- 1:nrow(df.s); colnames(df.s) <- 1:ncol(df.s); df.t <- data.frame(df.s); df.t$tweetid <- tweets$tweetid;
# merge in hashtag data from original tweets dataset
df.a <- subset(tweets, select = c(tweetid, hashtag)); 
df.u <- merge(df.t, df.a, by = 'tweetid'); df.u$z <- 1; df.u <- arrange(df.u, tweetid); 
tweets.emojis.matrix <- df.u;
## create emoji count dataset
df <- subset(tweets.emojis.matrix)[, c(2:843)]; count <- colSums(df > -1);
emojis.m <- cbind(count, emojis); emojis.m <- arrange(emojis.m, desc(count));
emojis.count <- subset(emojis.m, count > 1); emojis.count$dens <- round(1000 * (emojis.count$count / nrow(tweets)), 1); emojis.count$dens.sm <- (emojis.count$count + 1) / (nrow(tweets) + 1);
emojis.count$rank <- as.numeric(row.names(emojis.count));
emojis.count.p <- subset(emojis.count, select = c(name, dens, count, rank));
# print summary stats
subset(emojis.count.p, rank <= 10);
num.tweets <- nrow(tweets); df.t <- rowSums(tweets.emojis.matrix[, c(2:843)] > -1); num.tweets.with.emojis <- length(df.t[df.t > 0]); num.emojis <- sum(emojis.count$count);
min(tweets$created); max(tweets$created); median(tweets$created);
num.tweets; num.tweets.with.emojis; round(100 * (num.tweets.with.emojis / num.tweets), 1); num.emojis; nrow(emojis.count);
df.plot <- subset(emojis.count.p, rank <= 10); xlab <- 'Rank'; ylab <- 'Overall Frequency (per 1,000 Tweets)';
setwd('C:/Users/dyzho/Documents/BU Fall 2017/MA615/finalproject/MA615FinalProject/ios_9_3_emoji_files');
df.plot <- arrange(df.plot, name);
imgs <- lapply(paste0(df.plot$name, '.png'), png::readPNG); g <- lapply(imgs, grid::rasterGrob);
k <- 0.20 * (10/nrow(df.plot)) * max(df.plot$dens); df.plot$xsize <- k; df.plot$ysize <- k; 

df.plot <- arrange(df.plot, name);
g1 <- ggplot(data = df.plot, aes(x = rank, y = dens)) +
  geom_bar(stat = 'identity', fill = 'dodgerblue4') +
  xlab(xlab) + ylab(ylab) +
  mapply(function(x, y, i) {
    annotation_custom(g[[i]], xmin = x-0.5*df.plot$xsize[i], xmax = x+0.5*df.plot$xsize[i], 
                      ymin = y-0.5*df.plot$ysize[i], ymax = y+0.5*df.plot$ysize[i])},
    df.plot$rank, df.plot$dens, seq_len(nrow(df.plot))) +
  scale_x_continuous(expand = c(0, 0), breaks = seq(1, nrow(df.plot), 1), labels = seq(1, nrow(df.plot), 1)) +
  scale_y_continuous(expand = c(0, 0), limits = c(0, 1.10 * max(df.plot$dens))) +
  labs(title="Emoji for Dunkin' Donuts")+
  theme(panel.grid.minor.y = element_blank(),
        axis.title.x = element_text(size = 10), axis.title.y = element_text(size = 14), 
        axis.text.x  = element_text(size = 8, colour = 'black'), axis.text.y  = element_text(size = 8, colour = 'black'));
g1;
setwd('C:/Users/dyzho/Documents/BU Fall 2017/MA615/finalproject/MA615FinalProject')

ht <- '#Starbucks' 
tweets.raw <- searchTwitter(ht, n = 3000, lang = 'en')
df <- twListToDF(strip_retweets(tweets.raw, strip_manual = TRUE, strip_mt = TRUE))
df$hashtag <- ht
df$created <- as.POSIXlt(df$created)
df$text <- iconv(df$text, 'latin1', 'ASCII', 'byte')
df$url <- paste0('https://twitter.com/', df$screenName, '/status/', df$id)
names(df)[12]<-"retweets"
df.a <- subset(df, select = c(text, created, url, latitude, longitude, retweets, hashtag))

tweets$z <- 1
tweets$created <- as.POSIXlt(tweets$created)
df$username <- substr(substr(df$url, 21, nchar(as.character(df$url))), 1, nchar(substr(df$url, 21, nchar(as.character(df$url))))-26);
tweets.full <- df
tweets.full$X <- NULL
tweets.full$z <- 1
tweets.full$created <- as.POSIXlt(tweets.full$created)

tweets.dupes <- tweets.full[duplicated(tweets.full$url), ]

tweets <- tweets.full[!duplicated(tweets.full$url), ]
tweets <- arrange(tweets, url)
row.names(tweets) <- NULL
tweets$tweetid <- as.numeric(row.names(tweets))
nrow(tweets)
tweets.final <- tweets
emdict.la <- read.csv('emoticon_conversion_noGraphic.csv', header = F)#Lauren Ancona; https://github.com/laurenancona/twimoji/tree/master/twitterEmojiProject
emdict.la <- emdict.la[-1, ]; row.names(emdict.la) <- NULL; names(emdict.la) <- c('unicode', 'bytes', 'name'); emdict.la$emojiid <- row.names(emdict.la);
emdict.jpb <- read.csv('emDict.csv', header = F) #Jessica Peterka-Bonetta; http://opiateforthemass.es/articles/emoticons-in-R/
emdict.jpb <- emdict.jpb[-1, ]; row.names(emdict.jpb) <- NULL; names(emdict.jpb) <- c('name', 'bytes', 'rencoding'); emdict.jpb$name <- tolower(emdict.jpb$name);
emdict.jpb$bytes <- NULL;
emojis <- merge(emdict.la, emdict.jpb, by = 'name');  emojis$emojiid <- as.numeric(emojis$emojiid); emojis <- arrange(emojis, emojiid);
###### FIND TOP EMOJIS FOR A GIVEN SUBSET OF THE DATA
tweets <- tweets.final;
# tweets <- subset(tweets.final, hashtag %in% c('#womensmarch'));
## create full tweets by emojis matrix
df.s <- matrix(NA, nrow = nrow(tweets), ncol = ncol(emojis)); 
system.time(df.s <- sapply(emojis$rencoding, regexpr, tweets$text, ignore.case = T, useBytes = T));
rownames(df.s) <- 1:nrow(df.s); colnames(df.s) <- 1:ncol(df.s); df.t <- data.frame(df.s); df.t$tweetid <- tweets$tweetid;
# merge in hashtag data from original tweets dataset
df.a <- subset(tweets, select = c(tweetid, hashtag)); 
df.u <- merge(df.t, df.a, by = 'tweetid'); df.u$z <- 1; df.u <- arrange(df.u, tweetid); 
tweets.emojis.matrix <- df.u;
## create emoji count dataset
df <- subset(tweets.emojis.matrix)[, c(2:843)]; count <- colSums(df > -1);
emojis.m <- cbind(count, emojis); emojis.m <- arrange(emojis.m, desc(count));
emojis.count <- subset(emojis.m, count > 1); emojis.count$dens <- round(1000 * (emojis.count$count / nrow(tweets)), 1); emojis.count$dens.sm <- (emojis.count$count + 1) / (nrow(tweets) + 1);
emojis.count$rank <- as.numeric(row.names(emojis.count));
emojis.count.p <- subset(emojis.count, select = c(name, dens, count, rank));
# print summary stats
subset(emojis.count.p, rank <= 10);
num.tweets <- nrow(tweets); df.t <- rowSums(tweets.emojis.matrix[, c(2:843)] > -1); num.tweets.with.emojis <- length(df.t[df.t > 0]); num.emojis <- sum(emojis.count$count);
min(tweets$created); max(tweets$created); median(tweets$created);
num.tweets; num.tweets.with.emojis; round(100 * (num.tweets.with.emojis / num.tweets), 1); num.emojis; nrow(emojis.count);
df.plot <- subset(emojis.count.p, rank <= 10); xlab <- 'Rank'; ylab <- 'Overall Frequency (per 1,000 Tweets)';
setwd('C:/Users/dyzho/Documents/BU Fall 2017/MA615/finalproject/MA615FinalProject/ios_9_3_emoji_files');
df.plot <- arrange(df.plot, name);
imgs <- lapply(paste0(df.plot$name, '.png'), png::readPNG); g <- lapply(imgs, grid::rasterGrob);
k <- 0.20 * (10/nrow(df.plot)) * max(df.plot$dens); df.plot$xsize <- k; df.plot$ysize <- k; 

df.plot <- arrange(df.plot, name);
g2 <- ggplot(data = df.plot, aes(x = rank, y = dens)) +
  geom_bar(stat = 'identity', fill = 'dodgerblue4') +
  xlab(xlab) + ylab(ylab) +
  mapply(function(x, y, i) {
    annotation_custom(g[[i]], xmin = x-0.5*df.plot$xsize[i], xmax = x+0.5*df.plot$xsize[i], 
                      ymin = y-0.5*df.plot$ysize[i], ymax = y+0.5*df.plot$ysize[i])},
    df.plot$rank, df.plot$dens, seq_len(nrow(df.plot))) +
  scale_x_continuous(expand = c(0, 0), breaks = seq(1, nrow(df.plot), 1), labels = seq(1, nrow(df.plot), 1)) +
  scale_y_continuous(expand = c(0, 0), limits = c(0, 1.10 * max(df.plot$dens))) +
  labs(title="Emoji for Starbucks")+
  theme(panel.grid.minor.y = element_blank(),
        axis.title.x = element_text(size = 10), axis.title.y = element_text(size = 14), 
        axis.text.x  = element_text(size = 8, colour = 'black'), axis.text.y  = element_text(size = 8, colour = 'black'));
g2;
gridExtra::grid.arrange(g1,g2,ncol=2)

