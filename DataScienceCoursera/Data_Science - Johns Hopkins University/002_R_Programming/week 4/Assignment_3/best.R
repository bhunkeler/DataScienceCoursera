# =================================================================================================
# Description: Assignment 3 - best.R 
#              The function reads the outcome-of-care-measures.csv file and returns a character vector
#              with the name of the hospital that has the best (i.e. lowest) 30-day mortality for the 
#              specified outcome in that state. The hospital name is the name provided in the 
#              Hospital.Name variable. The outcomes can be one of “heart attack”, “heart failure”, 
#              or “pneumonia”.
# 
# Parameter:   state    - (e.g. "TX")
#              outcome  - (e.g. "heart attack")
#                         
# return:      Hospital.Name
#
#
# Authhor:     Bruno Hunkeler 
# Date:        08.11.2015
# =================================================================================================

# references to functions
# source("best.R")

# library references 
# library(miscTools)

best <- function(state, outcome) {

  
  # Map all valid outcomes to relevant mortality rate colname in data file
  validOutcomes = list("heart attack" = "Hospital.30.Day.Death..Mortality..Rates.from.Heart.Attack",
                       "heart failure" = "Hospital.30.Day.Death..Mortality..Rates.from.Heart.Failure",
                       "pneumonia" = "Hospital.30.Day.Death..Mortality..Rates.from.Pneumonia")
  

  # Load data 
  data <- read.csv("outcome-of-care-measures.csv", colClasses = "character")
  
  # verify if requested state exists
  if(!(state %in% data$State)) {
    
    stop('invalid state')
  }
  
  # verify if requested outcome exists
  if(!(length(outcome) == 1 && outcome %in% names(validOutcomes))){
    
    stop('invalid outcome')
  }

  statehospitals <- data[ (data$State == state) == TRUE, ]
  statehospitals <- subset(statehospitals, State %in% state, select = c("Hospital.Name", validOutcomes[[outcome]]))
  statehospitals[, 2] <- as.numeric(statehospitals[, 2])
  # good <- complete.cases(statehospitals)
  
  statehospitals <- statehospitals[complete.cases(statehospitals), ]
  with(statehospitals, Hospital.Name[which.min(statehospitals[, 2])])

}
