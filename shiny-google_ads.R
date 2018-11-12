library(dplyr)
library(lubridate)
library(shiny)
library(data.table)

googleAdsData <- fread("E:/Google Drive/Shiny/Google_Ads_Source.csv")

googleAdsData <- select (googleAdsData,-contains("2"))

googleAdsData$Week <- lubridate::mdy(googleAdsData$Week)
googleAdsData$Day <- lubridate::mdy(googleAdsData$Day)
googleAdsData$CTR <- as.numeric(sub("%", "",googleAdsData$CTR,fixed=TRUE))/100
googleAdsData$`Conv Rate 1` <- as.numeric(sub("%", "",googleAdsData$`Conv Rate 1`,fixed=TRUE))/100

googleAdsData<-googleAdsData[!(googleAdsData$`Conv Rate 1`>1),]


ui <- fluidPage(
  sidebarPanel(
    dateRangeInput("daterange1", "Date Range", start = NULL, end = NULL, min = NULL,
                   max = NULL, format = "mm-dd-yyyy", startview = "month",
                   weekstart = 0, language = "en", separator = " to ", width = NULL,
                   autoclose = TRUE)
  ),
  
  mainPanel(
    DT::dataTableOutput(outputId = "googlestats")
  )
  
)

server <- function(input, output){}
shinyApp(ui = ui, server = server)