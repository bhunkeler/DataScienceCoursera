# ========================================================================================================================================
# Description:   Course Project 1 / Plot1.R
#                Coursera Data Science at Johns Hopkins University
#
#                It is now possible to collect a large amount of data about personal movement using activity monitoring devices such as 
#                a Fitbit, Nike Fuelband, or Jawbone Up. These type of devices are part of the ?quantified self ? movement ? a group of 
#                enthusiasts who take measurements about themselves regularly to improve their health, to find patterns in their behavior, 
#                or because they are tech geeks. But these data remain under - utilized both because the raw data are hard to obtain and 
#                there is a lack of statistical methods and software for processing and interpreting the data.
#
#                This assignment makes use of data from a personal activity monitoring device. This device collects data at 5 minute 
#                intervals through out the day. The data consists of two months of data from an anonymous individual collected during 
#                the months of October and November, 2012 and include the number of steps taken in 5 minute intervals each day.
#
# Dataset:       Activity Monitoring Data [52kB] 
#                Download link: [https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2Factivity.zip]
#
#                The variables included in this dataset are:
#                steps:       Number of steps taking in a 5 - minute interval(missing values are coded as NA)
#                date:        The date on which the measurement was taken in YYYY - MM - DD format
#                interval:    Identifier for the 5 - minute interval in which measurement was taken
#
# Author:        Bruno Hunkeler
# Date:          11.04.2016
#
# ========================================================================================================================================

# ========================================================================================================================================
# Load Libraries
# ========================================================================================================================================

# library('dplyr')
library('ggplot2')
library('reshape2')
library('plyr')
library('timeDate')

# ========================================================================================================================================
# Part 1 - Mean total number of steps taken per day?
# ========================================================================================================================================

# ========================================================================================================================================
# Step 1.1 - Loading data
# ========================================================================================================================================

zipFile <- "repdata-data-activity.zip"

if (!file.exists("Data/activity.csv")) {
    dataURL <- "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2Factivity.zip"
    download.file(dataURL, zipFile, mode = "wb")
    unzip(zipFile, files = NULL, list = FALSE, overwrite = TRUE, junkpaths = FALSE, exdir = "Data", unzip = "internal", setTimes = FALSE)
    file.remove(zipFile)
}

# Define Directory where File is located
dirName <- 'Data'

# load power consumption data
fileName = "activity.csv"
fileNameActivity <- file.path(dirName, fileName)

data <- read.csv(file = fileNameActivity, header = TRUE, colClasses = c("numeric", "Date", "numeric"))

# set locale to english 
Sys.setlocale("LC_TIME", "English")

# Step 1.2 - Preprocessing the data for analysis 

# add the weekday to the dataset
data$weekday <- weekdays(data$date)

# create a copy of data set with NA rows
data.WithNA <- data

# remove all rows with 'NA'
data.NoNA <- data[complete.cases(data),]


# Step 1.3 - Calculate the total number of steps taken per day

# Calculate total number of steps per day  
sum.steps.day <- ddply(data.NoNA, .(date), summarise, steps = sum(steps, na.rm = TRUE))


# Step 1.4 - Histogram of the total number of steps taken each day

plot(sum.steps.day$date, sum.steps.day$steps, type = "h", main = "Histogram of daily steps", xlab = "Date", ylab = "Steps per day", col = "blue", lwd = 8)
abline(h = mean(sum.steps.day$steps, na.rm = TRUE), col = "red", lwd = 2)


# Step 1.5 - Calculate and report the mean and median of the total number of steps taken per day

# Mean steps per Day
paste("Mean steps per Day =", round(mean(sum.steps.day$steps, na.rm = TRUE), 0))

# Median steps per Day
paste("Median steps per Day =", round(median(sum.steps.day$steps, na.rm = TRUE), 0))

# ========================================================================================================================================
# Part 2 - Average daily activity pattern
# ========================================================================================================================================

# Step 2.1 - Calculate total number of steps per year and interval

# Calculate total number of steps per year interval
mean.steps.interval <- ddply(data.WithNA, .(interval), summarise, steps = mean(steps, na.rm = TRUE))


# Step 2.2 - Time series plot of the 5-minute interval and the average number of steps taken, averaged across all days

plot(mean.steps.interval$interval, mean.steps.interval$steps, type = "l", main = "Average daily activity by interval", xlab = "Interval",
     ylab = "Steps per interval", col = "blue", lwd = 2)
abline(h = mean(mean.steps.interval$steps, na.rm = TRUE), col = "red", lwd = 2)


# Step 2.3 - Maximum number of steps on 5 - minute interval, on average across all the days in the dataset

# Maximum number of steps 5-minute interval
paste("Maximum number of steps in interval =", mean.steps.interval$interval[which.max(mean.steps.interval$steps)])
paste("Maximum number of steps =", round(max(mean.steps.interval$steps), 0))

# ========================================================================================================================================
# Part 3 - Imputing missing values
# ========================================================================================================================================

# Step 3.1 - Calculate number of rows with missing data (NA)

# Calculate number of rows in data set with NA rows
sum(is.na(data.WithNA$steps))

# Step 3.2 - Devise a strategy for filling in all of the missing values in the dataset

# Devised startegy
# Humans usually follow certain patterns throughout the day / week. Therefore we assume that if
# we calculate the mean number of steps per 5 - minute intervall, over all days, we will get a decent figure to add as NA value.

# Calculate the mean value per day and interval. This gives a good average of steps for a given day
mean.weekday <- ddply(data.WithNA, .(interval, weekday), summarise, steps = round(mean(steps, na.rm = TRUE), 2))

# Get list of indices where steps value = NA
naIndex = which(is.na(data.WithNA$steps))

# Merge dataset 'data.WithNA' with dataset mean.steps.interval 
merged.NA = merge(data.WithNA, mean.steps.interval, by = "interval", suffixes = c(".actual", ".stepsInt"))

# give the dataset a more precise name
data.Complete <- data.WithNA

# Replace NA values with value from steps
data.Complete[naIndex, "steps"] <- merged.NA[naIndex, 'steps.stepsInt']

# verify if dataset contains NA values
paste("Missing values in new dataset = ", sum(is.na(data.Complete)))

# Calculate total number of steps per day  
steps.day <- ddply(data.Complete, .(date), summarise, steps = round(sum(steps, na.rm = TRUE), 0))

# Step 3.3 - Create a new dataset that is equal to the original dataset but with the missing data filled in

plot(steps.day$date, steps.day$steps, type = "h", main = "Histogram of daily steps (added NA Values)", xlab = "Date", ylab = "Steps per day", col = "blue", lwd = 8)
abline(h = mean(steps.day$steps, na.rm = TRUE), col = "red", lwd = 2)

# ========================================================================================================================================
# Part 4 - Differences in activity patterns between weekdays and weekends?
# ========================================================================================================================================

# Step 4.1 - Indicating whether a given date is a weekday or weekend day.

# Evaluate wether date is weekday or weekend
data.Complete$daytype <- lapply(data.Complete$date, function(x) ifelse(isWeekday(x, wday = 1:5), 'weekday', 'weekend'))

# flatten list to vector
data.Complete$daytype <- unlist(data.Complete$daytype, use.names = TRUE)

# Create Factor variable
data.Complete$daytype <- as.factor(data.Complete$daytype)


# Step 4.2 - Time series plot of the 5 - minute interval and the average number of steps taken, averaged across all weekday days or weekend days . 

# Calculate the 5 - minute interval and the average number of steps taken on weekdays and weekends
day.interval.Steps <- ddply(data.Complete, .(interval, daytype), summarise, steps = mean(steps, na.rm = TRUE))

# Plot the time series plot (facet) of 5 - minute interval and the average number of steps taken on weekdays and weekends
ggplot(day.interval.Steps, aes(x = interval, y = steps)) +
    geom_line(col='blue') +
    ylab('Number of steps') + xlab("Interval") +
    ggtitle("Number of Steps per Interval (weekend/weekend") +
    facet_grid(daytype ~ .)
