# =================================================================================================
# Description: Quiz_1.R - Getting and Cleaning Data - John Hopkins University
#              Parsing different raw data formats
#
# Parameter:
#
#
# return:
#
#
#
# Authhor:     Bruno Hunkeler
# Date:        xx.xx.2015
# =================================================================================================

# =================================================================================================
# Load libraries
# =================================================================================================

require(data.table)
require(xlsx)
require(XML)

# =================================================================================================
# Quiz 1 - Parsing different raw data formats
# =================================================================================================


# verify if Data directory exists otherwise create one
if(!file.exists("Data")){
  
  dir.create("Data")
}

quiz1 <- FALSE
quiz2 <- FALSE
quiz3 <- TRUE

# =================================================================================================
# Quiz 1 / 1 - Read the csv file in dataURL
# =================================================================================================

# Read the csv file in dataURL
# The code book, describing the variable names is https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FPUMSDataDict06.pdf
# How many properties are worth $1,000,000 or more?

if (quiz1 == TRUE){

dataURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06hid.csv"
download.file(dataURL, destfile = "./Data/housing.csv", quiet = TRUE)
data <- fread("./Data/housing.csv")
data <- data[, .N, by = VAL]
result <- data[ (data[, data$VAL] == 24) == TRUE, ][[2]]
print(result)

# DownloadDate_housing <- date()

}

# =================================================================================================
# Quiz 1 / 2 - Download the xlsx file in dataURL
# =================================================================================================

# Download the xlsx file in dataURL
# Read rows 18-23 and columns 7-15 into R and assign the result to a variable called dat
# What is the value of sum(dat$Zip*dat$Ext,na.rm=T)
if (quiz2 == TRUE){
  
dataURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FDATA.gov_NGAP.xlsx"
download.file(dataURL, destfile = "./Data/naturalgas.xlsx", mode = "wb", quiet = TRUE)
data <- read.xlsx("./Data/naturalgas.xlsx", sheetIndex = 1, colIndex = 7:15, rowIndex = 18:23)
result = sum(data$Zip * data$Ext,na.rm = TRUE)
print(result)

# DownloadDate_naturalglas <- date()
}

# =================================================================================================
# Quiz 1 / 3 - Read the xml file in dataURL
# =================================================================================================

# Read the xml file in dataURL
# How many restaurants have zipcode 21231?
if (quiz3 == TRUE){
  
dataURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Frestaurants.xml"
download.file(dataURL, destfile = "./Data/restaurants.xls", quiet = TRUE)
data <- xmlTreeParse("./Data/restaurants.xls", useInternal = TRUE)
data <- xmlRoot(data)

result = 0
xpathSApply(data, "//zipcode", function(zipcode) {
  if (xmlValue(zipcode) == 21231)
    result <<- result + 1
})
print(result)

# DownloadDate_restaurants >- date()
}

# data clean-up
remove(data)
remove(dataURL)