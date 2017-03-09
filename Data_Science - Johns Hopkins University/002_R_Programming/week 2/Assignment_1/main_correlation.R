# =============================================================================
# Description: Assignment 1 
# 
#
#
# Authhor:     Bruno Hunkeler 
# Date:        04.11.2015
# =============================================================================


# references to functions
source("corr.R")
source("complete.R")

# library references 
# library(miscTools)

# =============================================================================
#  Assignment 1/3 - correlation
# =============================================================================

directory <- "specdata"

# =============================================================================
#  Assignment 1/2 - correlation 
# =============================================================================

correlation_TC1 <- corr(directory, 150);
head(correlation_TC1)
summary(correlation_TC1)
length(correlation_TC1)

correlation_TC2 <- corr(directory, 400);
head(correlation_TC2)
summary(correlation_TC2)
length(correlation_TC2)

correlation_TC3 <- corr(directory, 5000);
head(correlation_TC3)
summary(correlation_TC3)
length(correlation_TC3)

correlation_TC4 <- corr(directory);
head(correlation_TC4)
summary(correlation_TC4)
length(correlation_TC4)


# =============================================================================
#  Coursera Test Cases 
# =============================================================================

# cr <- corr("specdata", 150)
# head(cr)    
## [1] -0.01896 -0.14051 -0.04390 -0.06816 -0.12351 -0.07589

# summary(cr)
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
## -0.2110 -0.0500  0.0946  0.1250  0.2680  0.7630

# cr <- corr("specdata", 400)
# head(cr)
## [1] -0.01896 -0.04390 -0.06816 -0.07589  0.76313 -0.15783
# summary(cr)
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
## -0.1760 -0.0311  0.1000  0.1400  0.2680  0.7630

# cr <- corr("specdata", 5000)
# summary(cr)
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
## 
# length(cr)
## [1] 0

# cr <- corr("specdata")
# summary(cr)
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
## -1.0000 -0.0528  0.1070  0.1370  0.2780  1.0000
# length(cr)
## [1] 323


