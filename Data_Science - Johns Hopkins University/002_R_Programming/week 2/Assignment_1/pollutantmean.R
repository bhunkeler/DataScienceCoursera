# =================================================================================================
# Description: Assignment 1 - pollutantmean 
# 
# Parameter:   directory     - is a character vector of length 1 indicating the location of 
#                              the CSV files
#              pollutant     - is a character vector of length 1 indicating
#                              the name of the pollutant for which we will calculate the
#                              mean; either "sulfate" or "nitrate".
#              id            - is an integer vector indicating the monitor ID numbers
#                              to be used
# return:      pollutantmean - mean of the pollutant across all monitors list
#                              in the 'id' vector (ignoring NA values)
#
# Authhor:     Bruno Hunkeler 
# Date:        19.11.2015
# =================================================================================================


pollutantmean <- function(directory, pollutant, id = 1:332) {
        
       data <- NA
        for (i in id) {
                csv <- read.csv(paste(directory, "/", sprintf("%03d", i), ".csv", sep = ""))
                data <- rbind(data, csv)
        }
        result <- mean(data[[pollutant]], na.rm = TRUE)
        return(result)
}





