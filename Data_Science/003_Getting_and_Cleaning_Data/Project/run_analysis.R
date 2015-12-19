# ========================================================================================================
# Description:   run_analysis.R - Getting and Cleaning Data - John Hopkins University
#
#                This R script called run_analysis.R does the following:
#                1. Merges the training and the test sets to create one data set.
#                2. Extracts only the measurements on the mean and standard deviation for each
#                   measurement.
#                3. Uses descriptive activity names to name the activities in the data set
#                4. Appropriately labels the data set with descriptive variable names.
#                5. From the data set in step 4, creates a second, independent tidy data set
#                   with the average of each variable for each activity and each subject.
#
# Data Resource:    https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
# Data Description: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
#
# Authhor:       Bruno Hunkeler
# Date:          xx.12.2015
#
# ========================================================================================================

# ========================================================================================================
# Load Libraries
# ========================================================================================================

library(reshape2)
library(data.table)


# download end extract ZipFile if not already downloaded
if(!file.exists("UCI HAR Dataset")){ 

  dataURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(dataURL, zipFile)
  unzip(zipFile, files = NULL, list = FALSE, overwrite = TRUE, junkpaths = FALSE, exdir = ".", unzip = "internal", setTimes = FALSE)
}

# load test data files X_test.txt and y_test.txt 
test.x <- read.table("./UCI HAR Dataset/test/X_test.txt")
test.y <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject.test <- read.table("./UCI HAR Dataset/test/subject_test.txt")

# load training data files X_train.txt and y_train.txt
train.x <- read.table("./UCI HAR Dataset/train/X_train.txt")
train.y <- read.table("./UCI HAR Dataset/train/y_train.txt")
subject.train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

# ========================================================================================================
# part 1 - Merges the training and the test sets to create one data set (vertically).
# ========================================================================================================
merged.x <- rbind(test.x, train.x)
merged.y <- rbind(test.y, train.y)
merged.subject <- rbind(subject.test, subject.train)

# add feature names to columns 
features.names <- read.table("./UCI HAR Dataset/features.txt")
features.names <- features.names$V2
colnames(merged.x)  <- features.names

# ========================================================================================================
# part 2 - Extracts only the measurements on the mean and standard deviation for each measurement.
# ========================================================================================================
merged.subset <- merged.x[ , grep("mean|std", colnames(merged.x))]

# ========================================================================================================
# part 3 - Uses descriptive activity names to name the activities in the data set
# ========================================================================================================

# load activity lables data files
activity.labels       <- read.table("./UCI HAR Dataset/activity_labels.txt")
merged.y$activity     <- activity.labels[merged.y$V1, 2]

# ========================================================================================================
# part 4 - Appropriately labels the data set with descriptive variable names.
# ========================================================================================================

names(merged.y)       <- c("ActivityID", "ActivityLabel")
names(merged.subject) <- "Subject"

# ========================================================================================================
# part 5 - From the data set in step 4, creates a second, independent tidy data set
#          with the average of each variable for each activity and each subject.
# ========================================================================================================

# merge (bind) all data to a single data set
merged.all <- cbind(merged.subject, merged.y, merged.x)
labels.all <- c("Subject", "ActivityID", "ActivityLabel")

data.labels = setdiff(colnames(merged.all), labels.all)
melted.data = melt(merged.all, id = labels.all, measure.vars = data.labels, na.rm=TRUE)
tidy.data = dcast(melted.data, Subject + ActivityLabel ~ variable, mean)

write.table(tidy.data, file = "./tidy_data.txt", row.names = FALSE)

ThisIsTheEnd <- "ThisIsTheEnd"
