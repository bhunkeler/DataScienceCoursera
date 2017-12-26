# CodeBook
This is a code book for `tidy_data.txt`, which gives you an initial overview of the experiment, describes the variables as well as the 
transformation steps performed to clean up the given dataset. Further, it describes the results of the tidy data.

Author: Bruno Hunkeler 
Date:   24.12.2015

## Data source
* Original data: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
* Original description of the dataset: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

## Study design (Dataset Information)
The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data.

The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain.

## Data
The dataset includes the following files:

- `README.txt`
- `features_info.txt`  : Shows information about the variables used on the feature vector.
- `features.txt`       : List of all features.
- `activity_labels.txt`: Links the class labels with their activity name.
- `train/X_train.txt`  : Training set.
- `train/y_train.txt`  : Training labels.
- `test/X_test.txt`    : Test set.
- `test/y_test.txt`    : Test labels.

The following files are available for the train and test data. Descriptions are equivalent.

- `train/subject_train.txt`: Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30.
- `train/Inertial Signals/total_acc_x_train.txt`: The acceleration signal from the smartphone accelerometer X axis in standard gravity units `g`. Every row shows a 128 element vector. 
   The same description applies for the `total_acc_x_train.txt` and `total_acc_z_train.txt` files for the Y and Z axis.
- `train/Inertial Signals/body_acc_x_train.txt`: The body acceleration signal obtained by subtracting the gravity from the total acceleration.
- `train/Inertial Signals/body_gyro_x_train.txt`: The angular velocity vector measured by the gyroscope for each window sample. The units are radians/second.

## Transformation details
1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement.
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names.
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

## Implementation steps following the previous steps:
**Source Script:** `run_analysis.R` 

* Load libraries `reshapre2` and `data.table`.
* Verify if source data file exists, otherwise download 
* Load X, y and subject data for train- test- and subject datasets
* Merge X, y and subject data for train-, test- and subject datasets
* Load and apply features names to columns
* Extract measurements (features) related to mean and standard deviations
* Load and apply activity labels
* Merge (bind) all data to a single data set
* Clean up data set
* write data to a txt file


## Tidy data description
The description of the applied columns is as follows, all other columns "measurements" are described in the features_info.txt file 
in the original raw data set.

Notes:   
- Features are normalized and bound within [-1,1].  

### tidy.data$ActivityLabel:

Description:  - Activity performed while measurements were taken  
Class:        - Factor w/ 6 levels 

ActivityID  | Activity label
------------|------------------------------
1           | WALKING
2           | WALKING_UPSTAIRS
3           | WALKING_DOWNSTAIRS
4           | SITTING
5           | STANDING
6           | LAYING

### tidy.data$Subject: 
Description:   - Person (subject) who performed the specified activity while measurements were taken   
Class:         - integer 

SubjectID   | Subject label
------------|------------------------------
1           | '1'
2           | '2'
3           | '3'
4           | '4'
5           | '5'
6           | '6'
7           | '7'  
8           | '8'   
9           | '9' 
10          | '10' 
11          | '11'  
12          | '12'
13          | '13' 
14          | '14' 
15          | '15' 
16          | '16' 
17          | '17' 
18          | '18' 
19          | '19' 
20          | '20' 
21          | '21'  
22          | '22'  
23          | '23' 
24          | '24' 
25          | '25' 
26          | '26' 
27          | '27' 
28          | '28' 
29          | '29'
30          | '30'


