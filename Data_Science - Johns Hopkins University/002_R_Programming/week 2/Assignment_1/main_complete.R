# =============================================================================
# Description: Assignment 1 
# 
#
#
# Authhor:     Bruno Hunkeler 
# Date:        04.11.2015
# =============================================================================


# references to functions
source("complete.R")

# library references 
# library(miscTools)

# =============================================================================
#  Assignment 1/2 - complete 
# =============================================================================

directory <- "specdata"

monitorID_TC1 <- c(1)
monitorID_TC2 <- c(2, 4, 8, 10, 12)
monitorID_TC3 <- c(30:25)
monitorID_TC4 <- c(3)

dataframe_TC1 <- complete(directory, monitorID_TC1);
dataframe_TC2 <- complete(directory, monitorID_TC2);
dataframe_TC3 <- complete(directory, monitorID_TC3);
dataframe_TC4 <- complete(directory, monitorID_TC4);

print(dataframe_TC1)
print(dataframe_TC2)
print(dataframe_TC3)
print(dataframe_TC4)


# =============================================================================
#  Coursera Test Cases 
# =============================================================================

# complete("specdata", 1)
# Result: 
##   id nobs
## 1  1  117

# complete("specdata", c(2, 4, 8, 10, 12))
# Result:
##   id nobs
## 1  2 1041
## 2  4  474
## 3  8  192
## 4 10  148
## 5 12   96

# complete("specdata", 30:25)
# Result:
##   id nobs
## 1 30  932
## 2 29  711
## 3 28  475
## 4 27  338
## 5 26  586
## 6 25  463

# complete("specdata", 3)
# Result:
##   id nobs
## 1  3  243