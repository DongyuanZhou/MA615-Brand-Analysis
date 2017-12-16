
# MA615-Brand-Analysis
Dongyuan Zhou

## Background
Coffee have been an indispensable drink in our daily life. For me, due to the large number of store located around BU, the brand I buy most often is Starbucks and Dunkin' Donuts. I'm interested in people's review towards these two brand.

## Goals
In this analysis, I mine Twitter for consumer attitudes towards two of the most popular coffee shop: Starbucks and Dunkin' Donuts.
The step I used is illustrated as follow:

**Step 1** : Search Twitter for brand mentions and collect tweet text;

**Step 2** : Score sentiment for each tweet according to sentiment word list;

**Step 3** : Summarize for each brand and Compare Twitter sentiment with ACSI (American Customer Satisfaction Index) satisfaction score.

## Data Description
I get data from twitter used TwitterR.

The code can be found from [Get data.R](https://github.com/DongyuanZhou/MA615-Brand-Analysis/blob/master/Get%20data.R).

Besides, I'm intersted in where the tweets were tweeted from. I created a map to show the location used the leaflet package.

<img width="734" alt="map" src="https://user-images.githubusercontent.com/32685027/34064896-bfccd116-e1ca-11e7-9772-5383f1d2b4f5.png">

The code can be find from [Map.R](https://github.com/DongyuanZhou/MA615-Brand-Analysis/blob/master/Map.R).

## Analysis
Before I go through the sentiment score analysis, I do EDA to show some interesting information related to later analysis. 

It is helpful for me to get better understanding towards our data. 

I create [Shiny App](https://dongyuanzhou.shinyapps.io/MA615shiny/) to show all the EDA part. 

The code for Shiny App can be found from [Shiny.R].

### Hashtags
First, hashtags! 

Hashtags are popular used on Twitter to index keywords or topics and allow users to easily follow topics they are interested. 

Hence, I find the top 10 hashtags metioned related to Starbucks and Dunkin' Donuts.

![hashtag2](https://user-images.githubusercontent.com/32685027/34074251-3ab02050-e279-11e7-824b-6b5b04b13f38.png)

### Emoji
Second, emoji! 

Emoji are widely used in our daily messages as well as on nearly all the social platforms. With emoji, we could express our mood more accurate and flexible. 

Therefore, I try to find the popular emoji used by people when they tweeted. 

![emoji](https://user-images.githubusercontent.com/32685027/34073983-ecf1210c-e273-11e7-86ce-cc8f0e9c7dfa.png)

The code can be found from [Emoji.R].

### Wordcloud
Third, wordcloud! 

I use wordcloud to find highest frequent word mentiond on tweets. 

![wc](https://user-images.githubusercontent.com/32685027/34074101-3976f270-e276-11e7-9635-9dee6e70ebc4.png)

The code can be found from [Wordcloud.R](https://github.com/DongyuanZhou/MA615-Brand-Analysis/blob/master/Wordcloud.R).

### Sentiment Score
After the initial analysis, we could go through into the sentiment analysis. I calculate the sentiment score for each tweet and plot the distribution of the score. 

The code can be found from [Sentiment.R](https://github.com/DongyuanZhou/MA615-Brand-Analysis/blob/master/Sentiment.R).

![analysis](https://user-images.githubusercontent.com/32685027/34064324-325467b2-e1c6-11e7-9653-d7b44f36163b.png)

From the chart above, we could find that Dunkin' Donuts have lower score, which means that people have more positive tweets on Starbucks.

Then we search the result created by [ACSI](www.theacsi.org/index.php?option=com_content&view=article&id=149&catid=&Itemid=214&c=Dunkin%5C%27+Donuts) and found that Dunkin' Dounuts own slightly higher satisfaction than Starbucks actually.
It is not same as what we find from twitter, but the difference is not such significant.
## Summary and Discussion
From this analysis, we can get the sentiment score for the brand from twitter, it is somewhat reasonable. However, there is still limitation, since not all the information could get from twitter. We could go deeper analysis in the near future.
