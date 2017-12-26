# =================================================================================================
# Description: Quiz2.R - Getting and Cleaning Data - John Hopkins University
#              Parsing different web data formats
#              
#
#
#
# Parameter:
# return:
#
#
# Authhor:     Bruno Hunkeler
# Date:        xx.xx.2015
# =================================================================================================

# =================================================================================================
# Load Libraries
# =================================================================================================

library(httr)
library(jsonlite)

# =================================================================================================
# Quiz 2 - Parsing different web data formats
# =================================================================================================

quiz1 <- FALSE
quiz2 <- TRUE
quiz3 <- TRUE
quiz4 <- TRUE

# =================================================================================================
# Quiz 2 / 1 - OAuth
# =================================================================================================

# Access the GitHub API to get information on your instructors repositories ("https://api.github.com/users/jtleek/repos"). 
# Use this data to find the time that the datasharing repo was created. 
# App keys

if (quiz1 == TRUE){


  ClientID <- "92d7a822d8640039d424"
  ClientSecret <- "c35c21f093ed1e57edf6a44ae89508f019188657"

  # Authenticate
  app <- oauth_app("github", ClientID, ClientSecret)
  token <- oauth2.0_token(oauth_endpoints("github"), app)
  token <- config(token = token)

  # API request
  # req <- with_config(token, GET("https://api.github.com/users/bhunkeler/repos"))
  req <- with_config(token, GET("https://api.github.com/users/jtleek/repos"))
  stop_for_status(req)
  data <- content(req, as = "text")

  # Format data & get results
  data <- fromJSON(data)
  result <- data$created_at[data$name == "datasharing"]
  print(result)
}


# =================================================================================================
# Quiz 2 / 2 - Web scraping
# =================================================================================================

# How many characters are in the 10th, 20th, 30th and 100th lines of HTML from 
# "http://biostat.jhsph.edu/~jleek/contact.html"
if (quiz2 == TRUE){

  con <- url("http://biostat.jhsph.edu/~jleek/contact.html")
  data <- readLines(con)
  close(con)
  
  # Data management
  result <- nchar(data[c(10,20,30,100)])
  result <- paste(result, collapse =" ")
  print(result)
}

# =================================================================================================
# Quiz 2 / 3 - Foregin file (Fixed-width file)
# =================================================================================================

# Read the data set into R and report the sum of the numbers in the fourth column
if (quiz3 == TRUE){

  dataURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fwksst8110.for"
  download.file(dataURL, "./SeaTemp.for", quiet = TRUE)
  data <- read.fwf("./SeaTemp.for", c(15,4,9,4,9,4,9,4,9), header = FALSE, skip = 4, strip.white =TRUE)

  result <- sum(data[,4])
  print(result)
}

# Clean-up
remove(data, ClientID, ClientSecret, req, token, app, con, dataURL)
