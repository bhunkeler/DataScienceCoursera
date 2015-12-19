## Getting and Cleaning Data 
### Course Project Instructions
You should create one R script called run_analysis.R that does the following. 

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement. 
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names. 
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

### Project data
Data collected from the accelerometers from the Samsung Galaxy S smartphone

### Data source
* Original data: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
* Original description of the dataset: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

### How to operate this project
1. Download the script `run_analysis.R` and place it in your working directory.
2. Run the `run_analysis.R` script by calling the command `source(run_analysis.R)` in `R`.
3. The script will automatically download the `UCI HAR Dataset`(if it hasn't been downloaded previously). The script will create a new file `tiny_data.txt` in your 
   working directory.

Please refer to the `CodeBook.md` if any further information are required about variables, data and transformations, which have been performed while ceaning the 
the data.