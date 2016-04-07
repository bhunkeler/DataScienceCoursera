# ========================================================================================================================================
# Description:   Course Project 2 / Plot1.R
#                Coursera Data Science at Johns Hopkins University
#
#                Fine particulate matter(PM2.5) is an ambient air pollutant for
#                which there is strong evidence that it is harmful to human health. In the United States, the 
#                Environmental Protection Agency(EPA) is tasked with setting national ambient air quality standards for
#                fine PM and for tracking the emissions of this pollutant into the atmosphere. Approximatly every 3 years, the EPA releases 
#                its database on emissions of PM2.5. This database is known as the National Emissions Inventory(NEI) . You can read more 
#                information about the NEI at the EPA National Emissions Inventory web site 
#                [https://www.epa.gov/air-emissions-inventories/national-emissions-inventory].
#
#
#                Assignment:
#                The overall goal of this assignment is to explore the National Emissions Inventory database and see what it say about                    
#                fine particulate matter pollution in the United states over the 10-year period 1999–2008. You may use any R package you 
#                want to support your analysis.
#
#
#                The following questions need to be answered: 
#                For each question/task you will need to make a single plot.  
#
#                1) Have total emissions from PM2.5 decreased in the United States from 1999 to 2008? Using the base plotting system, 
#                   make a plot showing the total PM2.5 emission from all sources for each of the years 1999, 2002, 2005, and 2008.
#                2) Have total emissions from PM2.5 decreased in the Baltimore City, Maryland(fips == "24510") from 1999 to 2008? 
#                   Use the base plotting system to make a plot answering this question.
#                3) Of the four types of sources indicated by the type(point, nonpoint, onroad, nonroad) variable, which of these four 
#                   sources have seen decreases in emissions from 1999 –2008 for Baltimore City ? Which have seen increases in emissions 
#                   from 1999 –2008? Use the ggplot2 plotting system to make a plot answer this question.
#                4) Across the United States, how have emissions from coal combustion - related sources changed from 1999 –2008?
#                5) How have emissions from motor vehicle sources changed from 1999 –2008 in Baltimore City ?
#                6) Compare emissions from motor vehicle sources in Baltimore City with emissions from motor vehicle sources in 
#                   Los Angeles County, California(fips == "06037") . Which city has seen greater changes over time in motor vehicle emissions?
#
#                fips:      A five - digit number(represented as a string) indicating the U.S. county
#                SCC:       The name of the source as indicated by a digit string(see source code classification table)
#                Pollutant: A string indicating the pollutant
#                Emissions: Amount of PM2.5 emitted, in tons
#                type:      The type of source(point, non - point, on - road, or non - road)
#                year:      The year of emissions recorded
# 
#                PM2.5 Emissions Data(summarySCC_PM25.rds):
#                This file contains a data frame with all of the PM2.5 emissions data for 1999, 2002, 2005, and 2008. 
#                For each year, the table contains number of tons of PM2.5 emitted from a specific type of source for
#                the entire year. 
#
#                Source Classification Code Table(Source_Classification_Code.rds):
#                This table provides a mapping from the SCC digit strings in the Emissions table to the actual name of the PM2.5 source. 
#                The sources are categorized in a few different ways from more general to more specific and you may choose to explore whatever 
#                categories you think are most useful. For example, source “10100101” is known as 
#                “Ext Comb / Electric Gen / Anthracite Coal / Pulverized Coal ”.
#
# Dataset:       Pollutant Emissions [29Mb] 
#                Download link: [https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip]
#
# Author:        Bruno Hunkeler
# Date:          xx.04.2016
#
# ========================================================================================================================================

# ========================================================================================================================================
# Load Libraries
# ========================================================================================================================================

# library('dplyr')
# library('ggplot2')
# library('reshape2')
library('plyr')

# ========================================================================================================================================
# Download and extract Data and load file
# ========================================================================================================================================

zipFile <- "exdata%2Fdata%2FNEI_data.zip"

if (!file.exists("Data/Source_Classification_Code.rds") && !file.exists("Data/summarySCC_PM25.rds")) {
    dataURL <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
    download.file(dataURL, zipFile, mode = "wb")
    unzip(zipFile, files = NULL, list = FALSE, overwrite = TRUE, junkpaths = FALSE, exdir = "Data", unzip = "internal", setTimes = FALSE)
    file.remove(zipFile)
}

# Define Directory where File is located
dirName <- 'Data'

# load classification code data
fileNameClass = "Source_Classification_Code.rds"
fileNameClass <- file.path(dirName, fileNameClass)

# load Summary CSS PM25 data
fileNameSummary = "summarySCC_PM25.rds"
fileNameSummary <- file.path(dirName, fileNameSummary)

# data <- read.table(file = fileNamePower, header = TRUE, sep = ';')
NEI <- readRDS(file = fileNameClass)
SCC <- readRDS(file = fileNameSummary)

# ========================================================================================================================================
# Data preparation (munging) 
# ========================================================================================================================================

# calculate total amount of emissions per year
data <- ddply(SCC, .(year), summarise, Emissions = sum(Emissions))

# devide total amount of emissions by 1'000'000 (million tons)
data$Emissions <- lapply(data$Emissions, function(x) round(x / 1e6, 2))

# ========================================================================================================================================
# Create and plot graph
# ========================================================================================================================================

png(filename = "plot1.png", width = 600, height = 600, units = "px", bg = "white")
# define margins
par(mfrow = c(1, 1), mar = c(5, 5, 3, 1))

with(data, plot(year, Emissions, pch = 20, col = "red", ylim = c(3, 8), xlim=c(1998, 2009), xaxt = "n", cex = 2.5, panel.first = grid(), main = expression("US Annual PM"[2.5] * " Emissions"),
     xlab = "Year", ylab = expression("PM"[2.5] * " Emissions (million tonnes)")))

# add a line between points
lines(data$year, data$Emissions, type = "l", lwd = 2)
axis(1, c(1999, 2002, 2005, 2008))

# print values for each point in graph
text(data$year, data$Emissions, data$Emissions, cex = 1.0, pos = 4, col = "black")

dev.off()
