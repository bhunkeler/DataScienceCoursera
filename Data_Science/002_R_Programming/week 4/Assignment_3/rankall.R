# =================================================================================================
# Description: Assignment 3 - rankall.R 
#              The function called rankall takes two arguments: an outcome name (outcome) and a 
#              hospital ranking (num). The function reads the outcome-of-care-measures.csv file 
#              and returns a 2-column data frame containing the hospital in each state that has the 
#              ranking specified in num.
# 
# Parameter:   outcome - (e.g. "heart attack")
#              num     - ranking of Hospital
#                         
# return:      a 2-column data frame containing the hospital in each state that has the 
#              ranking specified in num.
#
#
# Authhor:     Bruno Hunkeler 
# Date:        13.11.2015
# =================================================================================================

# references to functions
# source("best.R")

# library references 
# library(miscTools)

rankall <- function(outcome, num = "best") {

  # used for test purposes
  # outcome <- "heart failure"
  # num = 5
  
  # Map all valid outcomes to relevant mortality rate colname in data file
  validOutcomes = list("heart attack" = "Hospital.30.Day.Death..Mortality..Rates.from.Heart.Attack",
                       "heart failure" = "Hospital.30.Day.Death..Mortality..Rates.from.Heart.Failure",
                       "pneumonia" = "Hospital.30.Day.Death..Mortality..Rates.from.Pneumonia")
  
  # Load data 
  data <- read.csv("outcome-of-care-measures.csv", colClasses = "character")
  hosp <- data[, c("Hospital.Name", "State", validOutcomes[[outcome]])]
  
  # assign new names to columns
  names(hosp) <- c("hospital", "state", "rate")
  hosp[, 3] <- as.numeric(hosp[, 3])
  
  # find rows with AN's and remove them  
  good <- complete.cases(hosp)
  hosp <- hosp[complete.cases(hosp), ]  
  
  splitted <- split(hosp, hosp$state)
  hospitals <- data.frame()
  
  for (dat in splitted) {

     # order the Names prior to the Rates increasingly 
     datName <- dat[order(dat$hospital, decreasing = FALSE), ]
     dat <- datName[order(datName$rate, decreasing = FALSE), ]
     
    if (num == "best") {
      
      hospitals <- rbind(hospitals, dat[1, ])
    } else if (num == "worst") {
      
      hospitals <- rbind(hospitals,dat[nrow(dat), ])
    } else {
      
      if ( !is.na(dat[as.numeric(num), ]$hospital) ){
        
        hospitals <- rbind(hospitals,dat[as.numeric(num), ])  
      } else{
        
        hospitals <- rbind(hospitals, data.frame(hospital = NA, state = dat[1, "state"], rate = NA))
      }
      
      
    }
  }
  
  # Return a data frame with the hospital names and the abrreviated state name
  hospitals <- hospitals[, c("hospital", "state")]
}
