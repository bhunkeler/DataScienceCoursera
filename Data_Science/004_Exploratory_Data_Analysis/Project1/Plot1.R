# ========================================================================================================================================
# Description:   Course Project 1 / Plot1.R
#                Coursera Data Science at Johns Hopkins 
#
#                Our overall goal here is simply to examine how household energy usage varies over a 2-day period in February, 2007. 
#                The script reconstructs the plots described on Course Project1 assignment
#                [https://www.coursera.org/learn/exploratory-data-analysis/peer/ylVFo/course-project-1]
#                All plots have been constructed using the base plotting system.
#
# Dataset:       Electric power consumption [20Mb] 
#                Download link: [https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip]
#
# Author:        Bruno Hunkeler
# Date:          30.03.2016
#
# ========================================================================================================================================

# ========================================================================================================================================
# Load Libraries
# ========================================================================================================================================

# library('dplyr')
# library('ggplot2')
# library('reshape2')

# ========================================================================================================================================
# Download and extract Data and load file
# ========================================================================================================================================

zipFile <- "exdata%2Fdata%2Fhousehold_power_consumption.zip"

if(!file.exists("Data/household_power_consumption.txt")){ 
  dataURL <- "https://archive.ics.uci.edu/ml/machine-learning-databases/00235/household_power_consumption.zip"
  # dataURL <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
  download.file(dataURL, zipFile, mode ="wb")  
  unzip(zipFile, files = NULL, list = FALSE, overwrite = TRUE, junkpaths = FALSE, exdir = "Data", unzip = "internal", setTimes = FALSE)
  file.remove(zipFile)
}

# Define Directory where File is located
dirName <- 'Data'

# load power consumption data
fileName = "household_power_consumption.txt"
fileNamePower <- file.path(dirName, fileName)

data <- read.table(file = fileNamePower, header = TRUE, sep = ';')

# subset data set
data <- subset(data, Date == '1/2/2007' | Date == '2/2/2007')

# Convert some features to numeric features
ColNames <- names(data[3:9])
numericList <- c(ColNames)
data[, numericList] <- lapply(data[, numericList], function(x) as.numeric(as.character(x)))

# Merge date & time into single column
dateTime <- as.POSIXct(paste(data$Date, data$Time, sep = ";"), format = "%d/%m/%Y;%H:%M:%S")
data <- cbind("DateTime" = dateTime, data)
data$Date <- NULL
data$Time <- NULL
remove(dateTime)

# ========================================================================================================================================
# Create and plot graph
# ========================================================================================================================================

# Plot graph
png(filename = "plot1.png", width = 480, height = 480, units = "px", bg = "transparent")
hist(data$Global_active_power, col = "red", main = "Global Active Power", xlab = "Global Active Power (kilowatts)")

dev.off()
