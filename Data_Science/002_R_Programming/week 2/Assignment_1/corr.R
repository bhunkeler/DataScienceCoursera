# =================================================================================================
# Description: Assignment 1 - corr.R
# 
# Parameter:   directory     - is a character vector of length 1 indicating the location of 
#                              the CSV files
#              threshold     - is a numeric vector of length 1 indicating the number of 
#                              completely observed observations (on all variables)
#                              required to compute the correlation between
#                              nitrate and sulfate; the default is 0
#
# Return:       correlations - a numeric vector
#
# Authhor:     Bruno Hunkeler 
# Date:        05.11.2015
# =================================================================================================

# references to functions
source("complete.R")

# library references 
# library(miscTools)


corr <- function(directory, threshold = 0) {
        
        complete <- complete(directory)
        meet <- complete["nobs"] > threshold
        valid <- complete[meet, ]
        correlation <- numeric(0)
        
        for (i in valid$id) {
           csvdata <- read.csv(paste(directory, "/", sprintf("%03d", i), ".csv", sep = ""))
           good <- complete.cases(csvdata)
           data <- csvdata[good, ]
           correlation <- c(correlation, cor(data["sulfate"], data["nitrate"]))
        }
        correlation
}




##test:
##cr <- corr("specdata", 150)
##head(cr)
## [1] -0.01896 -0.14051 -0.04390 -0.06816 -0.12351 -0.07589
##summary(cr)
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
## -0.2110 -0.0500  0.0946  0.1250  0.2680  0.7630
##cr <- corr("specdata", 400)
##head(cr)
## [1] -0.01896 -0.04390 -0.06816 -0.07589  0.76313 -0.15783
##summary(cr)
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
## -0.1760 -0.0311  0.1000  0.1400  0.2680  0.7630
##cr <- corr("specdata", 5000)
##summary(cr)
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
## 
##length(cr)
## [1] 0
##cr <- corr("specdata")
##summary(cr)
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
## -1.0000 -0.0528  0.1070  0.1370  0.2780  1.0000
##length(cr)
## [1] 323