Test
library(dplyr)
library(lubridate)
library(shiny)
library(shinydashboard)
library(data.table)
library(DT)

googleAdsData <- fread("C:/Users/danko/Documents/UNH-GIT/Google_Ads_Source.csv")

# Drop a few columns that are not relevant by targeting the number 2 in their names
googleAdsData <- select (googleAdsData,-contains("2"))

# Fix the types for 4 of the columns
googleAdsData$Week <- lubridate::mdy(googleAdsData$Week)
googleAdsData$Day <- lubridate::mdy(googleAdsData$Day)
googleAdsData$CTR <- as.numeric(sub("%", "",googleAdsData$CTR,fixed=TRUE))/100
googleAdsData$`Conv Rate` <- as.numeric(sub("%", "",googleAdsData$`Conv Rate`,fixed=TRUE))/100

# Remove rows where the Conv Rate 1 is greater than 100%
googleAdsData <- googleAdsData[!(googleAdsData$`Conv Rate`>1),]


googleAdsCampaigns <- unique(googleAdsData$Campaign)
# googleAdsAdGroups <- unique(googleAdsData$'Ad Group')

# ---------------------------------------------------------------


ui <- fluidPage(
  
  # App title ----
  titlePanel("Google Ads"),
  
  sidebarPanel(
    dateRangeInput("daterange1", "Date Range", start = NULL, end = NULL, min = NULL,
                   max = NULL, format = "mm-dd-yyyy", startview = "month",
                   weekstart = 0, language = "en", separator = " to ", width = NULL,
                   autoclose = TRUE),
    
    htmlOutput("campaign_selector"),
    htmlOutput("adgroup_selector"),
    
    # selectInput("campaigns", "Choose Campaign", googleAdsCampaigns, selected = NULL, multiple = TRUE,
    #             selectize = TRUE, width = NULL, size = NULL),
    # 
    # selectInput("adgroups", "Choose AdGroup", googleAdsData$'Ad GRoup', selected = NULL, multiple = TRUE,
    #             selectize = TRUE, width = NULL, size = NULL),
    
    sliderInput("conversions", "Conversions:",
                 min = min(googleAdsData$Conversions), max = max(googleAdsData$Conversions),
                 value = c(0,60))
  ),
  
  mainPanel(
    # Output: Tabset w/ plot, summary, and table ----
    tabsetPanel(type = "tabs",
                tabPanel("Plot", plotOutput("plot")),
                tabPanel("Summary", verbatimTextOutput("summary")),
                tabPanel("Read Me", textOutput("text"))
  ),
    # Output: Histogram ----
    plotOutput(outputId = "conversions"),
  
    # Output: Histogram ----
    plotOutput(outputId = "distPlot")
)

)

server <- function(input, output, session){
  # observe({
  #   x <- input$campaigns
  # 
  #   # Can use character(0) to remove all choices
  #   if (is.null(x))
  #     x <- character(0)
  # 
  #   # Can also set the label and select items
  #   updateSelectInput(session, "adgroups",
  #                     label = paste("Select input label", length(x)),
  #                     choices = googleAdsData$'Ad Group',
  #                     selected = tail(x, 1)
  #   )
  # })
  

  output$campaign_selector <- renderUI({
    
    selectInput(
      inputId = "campaign", 
      label = "Choose Campaign:",
      choices = as.character(unique(googleAdsData$Campaign)),
      selected = NULL)
    
  })
  
  output$adgroup_selector <- renderUI({
    
    available <- googleAdsData[googleAdsData$Campaign == input$campaign, "Ad Group"]
    
    selectInput(
      inputId = "adgroup", 
      label = "Choose AdGroup",
      choices = unique(available),
      selected = unique(available)[1])
    
  })
  
}
shinyApp(ui = ui, server = server)