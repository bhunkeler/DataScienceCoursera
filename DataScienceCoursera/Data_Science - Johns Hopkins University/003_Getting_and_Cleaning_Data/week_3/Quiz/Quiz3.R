# =================================================================================================
# Description: Quiz3.R - Getting and Cleaning Data - John Hopkins University
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
# Quiz 3 - Parsing different web data formats
# =================================================================================================

require(data.table)
require(jpeg)
require(Hmisc)

qq1 <- TRUE
qq2 <- TRUE
qq3 <- TRUE
qq4 <- TRUE
qq5 <- TRUE

# =================================================================================================
# Quiz 3 / 1 - Create binary variable
# =================================================================================================

# Create a "agricultureLogical" logical vector that identifies the households 
# on greater than 10 acres and who sold more than $10,000 worth of agriculture products
# codebook is at https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FPUMSDataDict06.pdf 

if(qq1 == TRUE){

  dataURL  = "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06hid.csv"
  download.file(dataURL, "Data/ACS.csv", quiet = TRUE)
  data <- fread("Data/ACS.csv", sep = ",", header = TRUE, na.strings = "")

  # ACR - Lot size / AGS - Sales of Agriculture Products
  data$agricultureLogical = data$ACR == 3 & data$AGS == 6
  result <- which(data$agricultureLogical)[1:3]
  print(result)
}

# =================================================================================================
# Quiz 3 / 2 - Quantiles
# =================================================================================================

# Read the jpeg & get the 30th & 80th quantile of the resulting data

if(qq2 == TRUE){
  
  dataURL = "https://d396qusza40orc.cloudfront.net/getdata%2Fjeff.jpg"
  download.file(dataURL, "Data/jeff.jpg", mode = "wb", quiet = TRUE)
  data <- readJPEG("Data/jeff.jpg", native = TRUE)
  result <- quantile(data, c(0.3, 0.8))
  print(result)
}

# =================================================================================================
# Quiz 3 / 3 - Merge & sort data
# =================================================================================================

# Match the data based on the country shortcode
# How many of the IDs match? 
# Sort the data frame in descending order by GDP rank. What is the 13th country in the resulting data frame? 

if(qq3 == TRUE){
  
  dataURL = "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FGDP.csv"
  download.file(dataURL, "Data/GDP.csv", quiet = TRUE)

  dataURL = "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FEDSTATS_Country.csv"
  download.file(dataURL, "Data/edu.csv", quiet = TRUE)

  edu <- read.csv("Data/edu.csv", header = TRUE,  na.strings = "", blank.lines.skip = TRUE)
  GDP <- read.csv("Data/GDP.csv", header = FALSE, na.strings = "", blank.lines.skip = TRUE, skip = 5, nrows = 190,
				 colClasses = c("character", "integer", "NULL", "character", "character", rep("NULL", 5)))
  
  names(GDP) <- c("CountryCode", "GDP.Rank", "CountryName", "GDP")
  data <- merge(GDP, edu, by = "CountryCode", all = TRUE)
  result = nrow(GDP) + nrow(edu) - nrow(data)
  data <- data[order(data$GDP.Rank, decreasing = TRUE),]
  result = c(result, data[13, "CountryName"]) 
  print(result)

}

# =================================================================================================
# Quiz 3 / 4 - Subsetting & average
# =================================================================================================

# What is the average GDP ranking for the "High income: OECD" and "High income: nonOECD" group

if(qq4 == TRUE){

  data$Income.Group <- as.factor(data$Income.Group)
  result <- mean(data[data$Income.Group == "High income: OECD", "GDP.Rank"], na.rm = TRUE)
  result <- c(result, mean(data[data$Income.Group == "High income: nonOECD", "GDP.Rank"], na.rm = TRUE))
  print(result)

}

# =================================================================================================
# Quiz 3 / 5 - Subsetting & average
# =================================================================================================

if(qq5 == TRUE){

  data$GDP.Rank.Group <- cut2(data$GDP.Rank, g = 5)
  result <- sum(as.numeric(data$GDP.Rank.Group) == 1 & data$Income.Group == "Lower middle income", na.rm = TRUE)
  print(result)

}