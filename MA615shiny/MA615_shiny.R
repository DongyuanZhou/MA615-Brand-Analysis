library(shiny)
library(tidyverse)
library(tidyr)
library(ggplot2)
library(plyr)
library(stringr)
library(plotly)
library(wordcloud)
library(leaflet)

## data for map
sb_us.df3 <- read_csv('sb_us.csv')
dd_us.df3 <- read_csv('dd_us.csv')
mapdata <- rbind(dd_us.df3,sb_us.df3)
## data for hashtag
df.hash <- read.table("hashdata.csv",header = TRUE, sep = ",", stringsAsFactors = FALSE)
## data for wordcloud
sb.df <- read.csv("sb_text.csv", header = TRUE, sep = ",",stringsAsFactors = FALSE)
dd.df <- read.csv("dd_text.csv", header = TRUE, sep = ",",stringsAsFactors = FALSE)
worddata <- rbind(dd.df,sb.df)

ui <- fluidPage(
  titlePanel("Brand Analysis"),
  sidebarLayout(
    
    sidebarPanel(radioButtons("BrandInput", "Brand",
                              choices = c("Starbucks", "DunkinDonuts"),
                              selected = "Starbucks"),
                 
                 
                 selectInput ("Number_of_HashtagInput", "X :Top X Hashtag",
                             choices = c(3:10),
                             selected = 5)),
    
    mainPanel(
      tabsetPanel(type = "tabs",
                  tabPanel("Data Map", leafletOutput("map",width="800px",height="400px")),
                  tabPanel("Hashtag", plotOutput("hashtag",width="700px",height="400px")),
                  tabPanel("Wordcloud", plotOutput("wordcloud",width="600px",height="600px")),
                  tabPanel("Sentiment Score", plotlyOutput("score",width="600px",height="400px"))
                  )
    )
    )
  )



server <- function(input, output) {
  
  output$map <- renderLeaflet({
  
    filtered <-
      mapdata %>%
      filter(Brand == input$BrandInput)
    color <- ifelse(input$BrandInput == "Starbucks","seagreen","darkorange")
    leaflet(filtered) %>% addTiles('http://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
      attribution='Map tiles by <a href="http://stamen.com">Stamen Design</a>, <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a> &mdash; Map data &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>')%>%
      setView(-95.7129, 42.358430, zoom = 4)%>% 
      addCircles(~lon, ~lat, popup=sb_us.df3$lon, weight = 3, radius=40,
                          color=color, stroke = TRUE, fillOpacity = 0.8)
  })
  
  
  output$hashtag <- renderPlot({
    
    filtered <-
      df.hash %>%
      filter(Brand == input$BrandInput)

    extract.hashes = function(vec){
      hash.pattern = "#[[:alpha:]]+"
      have.hash = grep(x = vec, pattern = hash.pattern)
      hash.matches = gregexpr(pattern = hash.pattern, text = vec[have.hash])
      extracted.hash = regmatches(x = vec[have.hash], m = hash.matches)
      df = data.frame(table(tolower(unlist(extracted.hash))))
      colnames(df) = c("tag","freq")
      df = df[order(df$freq,decreasing = TRUE),]
      return(df)
    }
    
    vec= filtered$text
    dat= head(extract.hashes(vec),50)
    dat= transform(dat,tag = reorder(tag,freq))
    
    color <- ifelse(input$BrandInput == "Starbucks","black","deeppink1")
    fill <- ifelse(input$BrandInput == "Starbucks","seagreen","darkorange")
    title <- ifelse(input$BrandInput == "Starbucks","Starbucks: Top 10 Hashtags","Dunkin' Donuts: Top 10 Hashtags")
    
    ggplot(dat[c(1:input$Number_of_HashtagInput), ], aes(x = tag, y = freq))+
      geom_bar(stat = "identity", color = color, fill = fill)+
      geom_text(aes(label = freq))+
      ggtitle(title)+
      ylab("Frequency")+
      xlab("Hashtag")+
      theme(axis.text.y = element_text(size = 15),
            axis.text.x = element_text(size = 15),
            axis.title.x = element_text(size = 15),
            axis.title.y = element_text(size = 15))+
      coord_flip()
  })
  
  output$wordcloud <- renderPlot({
    
    filtered <-
      worddata %>%
      filter(Brand == input$BrandInput)
    
    data(stop_words)
    my_stop_word <- data.frame(word=character(9))
    my_stop_word$word <- c("star","bucks","starbucks","dunkin","donuts","dunkindonuts","https","rt","ed")
    
    filtered %>%
      group_by(id) %>%
      unnest_tokens(word,text)%>% 
      anti_join(stop_words)%>%
      anti_join(my_stop_word)%>%
      filter(str_detect(word, "^[a-z']+$"))%>%
      ungroup()%>% 
      count(word,sort=TRUE)%>% 
      with(wordcloud(word, n, max.words = 50,colors=brewer.pal(n=8, "Dark2"),random.order=FALSE,rot.per=0.35))
    
  })
  
  
  output$score <- renderPlotly({
    
    filtered <- subset(worddata, Brand == input$BrandInput)[,c(1,2)]
    
    data(stop_words)
    my_stop_word <- data.frame(word=character(9))
    my_stop_word$word <- c("star","bucks","starbucks","dunkin","donuts","dunkindonuts","https","rt","ed")
    
    filtered <- filtered %>%
      group_by(id) %>%
      unnest_tokens(word,text)%>% 
      anti_join(stop_words)%>%
      anti_join(my_stop_word)%>%
      filter(str_detect(word, "^[a-z']+$"))%>%
      ungroup()
    
    get_sentiments("afinn")
    AFINN <- get_sentiments("afinn") %>% dplyr::select(word,score)
    
    sentiment <- filtered %>%
      inner_join(AFINN, by = "word") %>%
      group_by(id) %>%
      summarize(sentiment_score = mean(score))
    
    color <- ifelse(input$BrandInput == "Starbucks","black","deeppink1")
    fill <- ifelse(input$BrandInput == "Starbucks","seagreen","darkorange")
    title <- ifelse(input$BrandInput == "Starbucks","Sentiment score for Starbucks","Sentiment score for Dunkin' Donuts")
    
    ggplot(sentiment)+
      geom_bar(mapping=aes(x=sentiment_score), binwidth=1,color = color, fill = fill)+
      geom_vline(xintercept = mean(sentiment$sentiment_score), color="red",linetype="dashed", size=1)+
      ggtitle(title)
    
  })
  
}
shinyApp(ui = ui, server = server)
