# ========================================================================================================================================
# Description:   Course Project 2 
#                Coursera Data Science at Johns Hopkins University
#
#                Storms and other severe weather events can cause both public health and economic problems for communities and 
#                municipalities. Many severe events can result in fatalities, injuries, and property damage, and preventing such 
#                outcomes to the extent possible is a key concern.
#                This project involves exploring the U.S. National Oceanic and Atmospheric Administration's (NOAA) storm database. 
#                This database tracks characteristics of major storms and weather events in the United States, including when and 
#                where they occur, as well as estimates of any fatalities, injuries, and property damage.
#
#
# Dataset:                                    [Storm Data](https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2) [52kB] 
# National Weather Service:                   [Storm Data Documentation](https://d396qusza40orc.cloudfront.net/repdata%2Fpeer2_doc%2Fpd01016005curr.pdf)
# National Climatic Data Center Storm Events: [FAQ](https://d396qusza40orc.cloudfront.net/repdata%2Fpeer2_doc%2FNCDC%20Storm%20Events-FAQ%20Page.pdf)
#
# Author:        Bruno Hunkeler
# Date:          20.04.2016
#
# ========================================================================================================================================

# ========================================================================================================================================
# Load Libraries
# ========================================================================================================================================

library('plyr')
library('dplyr')
library('ggplot2')
library('gridExtra')

# ========================================================================================================================================
# Loading data
# ========================================================================================================================================

zipFile <- "repdata-data-StormData.csv.bz2"
if (!file.exists("Data/repdata-data-StormData.csv.bz2")) {
    dataURL <- "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2"

    if (!file.exists('Data')) {
        dir.create("Data")
    }

    download.file(dataURL, destfile = zipFile, quiet = FALSE, mode = "wb")
    file.copy(zipFile, 'Data')
    file.remove(zipFile)
}

# Define Directory where File is located
dirName <- 'Data'

# load power consumption data
fileNameStorm <- file.path(dirName, zipFile)

# Load data 
storm.data = read.csv(bzfile(fileNameStorm), header = TRUE)

# ===============================================================================================================
# Preprocessing data 
# ===============================================================================================================

Col <- c('EVTYPE', 'INJURIES', 'FATALITIES', 'PROPDMG', 'PROPDMGEXP', 'CROPDMG', 'CROPDMGEXP')

# remove not required columns 
data <- storm.data[, Col]

# Clean Variable explorer - remove unnecessary variables
rm(zipFile)
rm(dirName)
rm(fileNameStorm)
rm(Col)
rm(storm.data)

# ===============================================================================================================
# Prepare Property- and Crop damage data 
# ===============================================================================================================

# The storm data document provided by the National Weather Service, contains information regarding the financial aspects of the damage caused by
# severe wether conditions. The column PROPDMGEXP contains various characters and numbers, which indicate the magnitude of the damage.
# Characters as 'H', 'K', 'M' and 'B' stand for     the magnitude hundred, thousend, million and billion, but there are other characters defined, 
# which indicate unknown values such as '', '+', '-', '?' . Characters with 'H', 'K', 'M' and 'B' will be transformed into the respective 
# magnitude(e.g 1e+2, 1e+3, 1e+6 etc.), where the unknown values will be transformed to '0'

# convert all fields to uppercase 
data$PROPDMGEXP <- lapply(data$PROPDMGEXP, function(x) tolower(as.character(x)))
data$CROPDMGEXP <- lapply(data$CROPDMGEXP, function(x) tolower(as.character(x)))

# Prepare magnitudes for Property Damage
data$PROPDMGEXP[data$PROPDMGEXP %in% c('', '+', '-', '?')] <- "0"
data$CROPDMGEXP[data$CROPDMGEXP %in% c('', '?')] <- '0'

data$PROPDMGEXP[data$PROPDMGEXP %in% c('h')] <- '2'
data$PROPDMGEXP[data$PROPDMGEXP %in% c('k')] <- '3'
data$PROPDMGEXP[data$PROPDMGEXP %in% c('m')] <- '6'
data$PROPDMGEXP[data$PROPDMGEXP %in% c('b')] <- '9'

data$CROPDMGEXP[data$CROPDMGEXP %in% c('k')] <- '3'
data$CROPDMGEXP[data$CROPDMGEXP %in% c('m')] <- '6'
data$CROPDMGEXP[data$CROPDMGEXP %in% c('b')] <- '9'

# flatten list to vector
data$PROPDMGEXP <- unlist(data$PROPDMGEXP, use.names = TRUE)
data$CROPDMGEXP <- unlist(data$CROPDMGEXP, use.names = TRUE)

# Calculate damage 
data$PROPDMGEXP <- 10 ^ (as.numeric(data$PROPDMGEXP))
data$PROPDMG = as.numeric(data$PROPDMG) * data$PROPDMGEXP

data$CROPDMGEXP <- 10 ^ (as.numeric(data$CROPDMGEXP))
data$CROPDMG = as.numeric(data$CROPDMG) * data$CROPDMGEXP

# Clean-up unused columns
data$PROPDMGEXP <- NULL
data$CROPDMGEXP <- NULL

# convert all EVTYPE fields to uppercase 
data$EVTYPE <- lapply(data$EVTYPE, function(x) toupper(as.character(x)))

# flatten list to vector
data$EVTYPE <- as.factor(unlist(data$EVTYPE, use.names = TRUE))

# Subsetting data and also devide by billion
Property.DMG <- ddply(data, .(EVTYPE), summarise, DMG = round((sum(PROPDMG) / 1e+9), 1))
Property.DMG <- subset(Property.DMG, DMG > 0)

# Subsetting data and also devide by million
Crop.DMG <- ddply(data, .(EVTYPE), summarise, DMG = round((sum(CROPDMG) / 10e+6), 1))
Crop.DMG <- subset(Crop.DMG, DMG > 0)

# order dataset descending and filter top 10 rows
Property.DMG <- Property.DMG[order( -Property.DMG$DMG),]
data.Property.DMG <- filter(Property.DMG, DMG > 1) %>% top_n(10)

# order dataset descending and filter top 10 rows
Crop.DMG <- Crop.DMG[order( -Crop.DMG$DMG),]
data.Crop.DMG <- filter(Crop.DMG, DMG > 1) %>% top_n(10)

# ===============================================================================================================
# Prepare Injury and Fatality data 
# ===============================================================================================================

# Subsetting data 
injuries.DMG <- ddply(data, .(EVTYPE), summarise, Injuries = round((sum(INJURIES) / 1), 2))
fatalities.DMG <- ddply(data, .(EVTYPE), summarise, Fatalities = round(sum(FATALITIES), 2))

# order dataset descending and filter top 10 rows
injuries.DMG <- injuries.DMG[order( - injuries.DMG$Injuries),]
data.Injury.DMG <- filter(injuries.DMG, Injuries > 1) %>% top_n(10)

# order dataset descending and filter top 10 rows
fatalities.DMG <- fatalities.DMG[order( - fatalities.DMG$Fatalities),]
data.Fatality.DMG <- filter(fatalities.DMG, Fatalities > 1) %>% top_n(10)

data.injuries <- filter(injuries.DMG, Injuries > 1000)
data.fatalities <- filter(fatalities.DMG, Fatalities > 100)

# Clean Variable explorer - remove unnecessary variables
rm(fatalities.DMG)
rm(injuries.DMG)
rm(Crop.DMG)
rm(Property.DMG)
rm(data.injuries)
rm(data.fatalities)

# ===============================================================================================================
# Prepare and create graph of property and crop damage data 
# ===============================================================================================================

property.plot <- ggplot(data = data.Property.DMG, aes(x = data.Property.DMG$EVTYPE, y = data.Property.DMG$DMG, fill = DMG, alpha = 0.8)) +
         geom_bar(stat = "identity") +
         xlab("Event type") + ylab("Damage in [billion $]") +
         ggtitle("Property damage caused by\nsevere weather events") +
         theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
         geom_text(aes(label = DMG), vjust = 1.6, color = "black", position = position_dodge(0.9), size = 3)


crop.plot <- ggplot(data = data.Crop.DMG, aes(x = data.Crop.DMG$EVTYPE, y = data.Crop.DMG$DMG, fill = DMG, alpha = 0.8)) +
     geom_bar(stat = "identity") +
     xlab("Event type") + ylab("Damage in [million $]") +
     ggtitle("Crop damage caused by\nsevere weather events") +
     theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
     geom_text(aes(label = DMG), vjust = 1.6, color = "black", position = position_dodge(0.9), size = 3)

     grid.arrange(property.plot, crop.plot, ncol = 2)

# ===============================================================================================================
# Prepare and create graph of injuries and fatalities on people 
# ===============================================================================================================

injury.plot <- ggplot(data = data.Injury.DMG, aes(x = data.Injury.DMG$EVTYPE, y = data.Injury.DMG$Injuries, fill = Injuries, alpha = 0.8)) +
      geom_bar(stat = "identity") +
      xlab("Event type") + ylab("Injured People") +
      ggtitle("Injuries caused by\nsevere weather events") +
      theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
      geom_text(aes(label = Injuries), vjust = 1.6, color = "black", position = position_dodge(0.9), size = 3)

fatality.plot <- ggplot(data = data.Fatality.DMG, aes(x = data.Fatality.DMG$EVTYPE, y = data.Fatality.DMG$Fatalities, fill = Fatalities, alpha = 0.8)) +
      geom_bar(stat = "identity") +
      xlab("Event type") + ylab("Fatalities") +
      ggtitle("Fatalities caused by\nsevere weather events") +
      theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
      geom_text(aes(label = Fatalities), vjust = 1.6, color = "black", position = position_dodge(0.9), size = 3)

# arrange 2 plots 
grid.arrange(injury.plot, fatality.plot, ncol = 2)

