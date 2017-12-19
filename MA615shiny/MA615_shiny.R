library(shiny)
library(shinydashboard)
library(tidyverse)
library(tidyr)
library(ggplot2)
library(plyr)
library(stringr)
library(plotly)
library(wordcloud)
library(leaflet)

## data for map
sb_us.df3 <- read.csv('sb_us.csv',header = TRUE, sep = ",",stringsAsFactors = FALSE)
dd_us.df3 <- read.csv('dd_us.csv',header = TRUE, sep = ",",stringsAsFactors = FALSE)
mapdata <- rbind(dd_us.df3,sb_us.df3)
## data for hashtag
df.hash <- read.table("hashdata.csv",header = TRUE, sep = ",", stringsAsFactors = FALSE)
## data for wordcloud
worddata <- read.csv("worddata.csv",header = TRUE, sep = ",",stringsAsFactors = FALSE)
## data for sentiment score
scoredata <- read.csv("sentiment.csv",header = TRUE, sep = ",",stringsAsFactors = FALSE)



ui <- navbarPage("Brand Analysis",
                 
                 tabPanel("Home",
                          img(src='title.png', align = "center"),
                          
                          img(src='brand.png', align = "center"),
                          br(),
                          br(),
                          br(),
                          br(),
                          br(),
                          p("Cite: https://www.starbucks.com/; https://www.dunkindonuts.com/en")),
                 tabPanel("Data Map",
                          sidebarLayout(
                            sidebarPanel(radioButtons("BrandInput1", "Brand",
                                                      choices = c("Starbucks", "DunkinDonuts"),
                                                      selected = "Starbucks")),
                            mainPanel(
                              h1("Where the tweets were tweeted from?"),
                              br(),
                              leafletOutput("map",width="800px",height="400px")))),
                 tabPanel("Hashtag",
                          sidebarLayout(
                            sidebarPanel(radioButtons("BrandInput2", "Brand",
                                                      choices = c("Starbucks", "DunkinDonuts"),
                                                      selected = "Starbucks"),
                                         selectInput ("Number_of_HashtagInput", "X :Top X Hashtag",
                                                      choices = c(3:10),
                                                      selected = 5)),
                            mainPanel(h1("Hashtags!"),
                                      br(),
                                      h4("Hashtags are popular used on Twitter to index keywords or topics and allow users to easily follow topics they are interested."),
                                      br(),
                                      h4("Hence, I find the top 10 hashtags metioned related to Starbucks and Dunkin' Donuts."),
                              plotOutput("hashtag",width="700px",height="400px")))),
                 tabPanel("Emoji",
                          h1("Emoji!"),
                          br(),
                          h4("Emoji are widely used in our daily messages as well as on nearly all the social platforms. With emoji, we could express our mood more accurate and flexible."),
                          br(),
                          h4("Therefore, I try to find the popular emoji used by people when they tweeted."),
                          br(),
                          img(src='emoji.png', align = "center")
                          ),
                 tabPanel("Wordcloud",
                          sidebarLayout(
                            sidebarPanel(radioButtons("BrandInput3", "Brand",
                                                      choices = c("Starbucks", "DunkinDonuts"),
                                                      selected = "Starbucks"),
                                         sliderInput("maxInput","Maximum Number of Words:",min = 1,  max = 100,  value = 50)),
                            mainPanel(h1("Wordcloud!"),
                                      br(),
                                      h4("Highest frequent word mentiond on tweets"),
                                      plotOutput("wordcloud",width="600px",height="600px")))),
                 tabPanel("Sentiment Score",
                          sidebarLayout(
                            sidebarPanel(radioButtons("BrandInput4", "Brand",
                                                      choices = c("Starbucks", "DunkinDonuts"),
                                                      selected = "Starbucks")),
                            mainPanel(h1("Distribution of sentiment score!"),
                                      br(),
                                      plotOutput("score",width="600px",height="400px")))))







server <- function(input, output) {
  
  
  output$map <- renderLeaflet({
    
    filtered <-
      mapdata %>%
      filter(Brand == input$BrandInput1)
    color <- ifelse(input$BrandInput1 == "Starbucks","seagreen","darkorange")
    leaflet(filtered) %>% addTiles('http://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png')%>%
      setView(-95.7129, 42.358430, zoom = 4)%>% 
      addCircles(~lon, ~lat, popup=sb_us.df3$lon, weight = 3, radius=40,
                 color=color, stroke = TRUE, fillOpacity = 0.8)
  })
  
  
  output$hashtag <- renderPlot({
    
    filtered <-
      df.hash %>%
      filter(Brand == input$BrandInput2)
    
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
    
    color <- ifelse(input$BrandInput2 == "Starbucks","black","deeppink1")
    fill <- ifelse(input$BrandInput2 == "Starbucks","seagreen","darkorange")
    title <- ifelse(input$BrandInput2 == "Starbucks","Starbucks: Top X Hashtags","Dunkin' Donuts: Top X Hashtags")
    
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
    
    filtered <- subset(worddata, Brand == input$BrandInput3)[,c(1,2)]
    
    wordcloud(filtered$word, filtered$n, max.words = input$maxInput,colors=brewer.pal(n=8, "Dark2"),
              random.order=FALSE,rot.per=0.35)
    
  })
  
  
  output$score <- renderPlot({
    
    filtered <- subset(scoredata, brand == input$BrandInput4)[,c(1,2)]
    
    color <- ifelse(input$BrandInput4 == "Starbucks","black","deeppink1")
    fill <- ifelse(input$BrandInput4 == "Starbucks","seagreen","darkorange")
    title <- ifelse(input$BrandInput4 == "Starbucks","Sentiment score for Starbucks","Sentiment score for Dunkin' Donuts")
    
    ggplot(filtered)+
      geom_bar(mapping=aes(x=sentiment_score), binwidth=1,color = color, fill = fill)+
      geom_vline(xintercept = mean(filtered$sentiment_score), color="red",linetype="dashed", size=1)+
      ggtitle(title)
    
  })

  
}
shinyApp(ui = ui, server = server)
