# =================================================================================================
# Description: Assignment 1 - complete 
#              Data files contain incomplete data rows. Isolate all incomplete 
#              rows and add number of complete cases (nobs) into a data frame 
# 
# Parameter:   directory - is a character vector of length 1 indicating the location of 
#                          the CSV files
#              id        - is an integer vector indicating the monitor ID numbers
#                          to be used
# return:      data frame where 'id' is the monitor ID number 
#              and 'nobs' is the number of complete cases
#
#              id nobs
#               1  117
#               2  1041
#
# Authhor:     Bruno Hunkeler 
# Date:        04.11.2015
# =================================================================================================

# references to functions
# source("Assignment 1/complete.R")

# library references 
# library(miscTools)


complete <- function(directory, id = 1:332) {

        nobs <- numeric(0)
        for (i in id) {
                data <- read.csv(paste(directory, "/", sprintf("%03d", i), ".csv", sep = ""))
                good <- complete.cases(data)
                nobs <- c(nobs, nrow(data[good, ]))
        }
        data.frame(id = id, nobs = nobs)
        
}
