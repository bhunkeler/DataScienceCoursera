# ===============================================================================================
# Description: Assignment 3 
#              
#
#
# Authhor:     Bruno Hunkeler 
# Date:        08.11.2015
# ===============================================================================================

# references to functions
source("best.R")
source("rankhospital.R")
source("rankall.R")

# library references 
#library("MASS")

assignment3_1 <- FALSE
assignment3_2 <- FALSE
assignment3_3 <- FALSE
assignment3_4 <- TRUE

# ===============================================================================================
# Assignment 3/1 - Plot the 30-day mortality rates for heart attack
# ===============================================================================================

if (assignment3_1 == TRUE ){

  outcome <- read.csv("outcome-of-care-measures.csv", colClasses = "character")
  # head(outcome)

  outcome[, 11] <- as.numeric(outcome[, 11])

  # You may get a warning about NAs being introduced; that is okay
  hist(outcome[, 11], 50)
}

# ===============================================================================================
# Assignment 3/2 - Finding the best hospital in a state
# ===============================================================================================

if (assignment3_2 == TRUE ){

  # Test Case 1
  hospital <- best("TX", "heart attack")   # "CYPRESS FAIRBANKS MEDICAL CENTER"

  # Test Case 2
  hospital <- best("TX", "heart failure")  # "FORT DUNCAN MEDICAL CENTER"

  # Test Case 3
  hospital <- best("MD", "heart attack")   # "JOHNS HOPKINS HOSPITAL, THE"

  # Test Case 4
  hospital <- best("MD", "pneumonia")      # "GREATER BALTIMORE MEDICAL CENTER"

  # Test Case 5
  hospital <- best("BB", "heart attack")   # Error in best("BB", "heart attack") : invalid state

  # Test Case 6
  hospital <- best("NY", "hert attack")   # Error in best("NY", "hert attack") : invalid outcome
}

# ===============================================================================================
# Assignment 3/3 - Ranking hospitals
# ===============================================================================================

if (assignment3_3 == TRUE ){
  
  # Test Case 1
  hospital <- rankhospital("TX", "heart failure", 4)        # "DETAR HOSPITAL NAVARRO"

  # Test Case 2
  hospital <- rankhospital("MD", "heart attack", "worst")   # "HARFORD MEMORIAL HOSPITAL"

  # Test Case 3
  hospital <- rankhospital("MN", "heart attack", 5000)      # NA
}

# ===============================================================================================
# Assignment 3/4 - Rankall hospitals
# ===============================================================================================

if (assignment3_4 == TRUE ){

  # Test Case 1
  hospitals1 <- head(rankall("heart attack", 20), 10)
  # AK <NA> AK
  # AL D W MCMILLAN MEMORIAL HOSPITAL AL
  # AR ARKANSAS METHODIST MEDICAL CENTER AR
  # AZ JOHN C LINCOLN DEER VALLEY HOSPITAL AZ
  # CA SHERMAN OAKS HOSPITAL CA
  # CO SKY RIDGE MEDICAL CENTER CO
  # CT MIDSTATE MEDICAL CENTER CT
  # DC <NA> DC
  # DE <NA> DE
  # FL SOUTH FLORIDA BAPTIST HOSPITAL FL
  
  # Test Case 2
  hospitals2 <- tail(rankall("pneumonia", "worst"), 3)
  # WI MAYO CLINIC HEALTH SYSTEM - NORTHLAND, INC WI
  # WV PLATEAU MEDICAL CENTER WV
  # WY NORTH BIG HORN HOSPITAL DISTRICT WY
  
  # Test Case 3
  hospitals3 <- tail(rankall("heart failure"), 10)
  # TN WELLMONT HAWKINS COUNTY MEMORIAL HOSPITAL TN
  # TX FORT DUNCAN MEDICAL CENTER TX
  # UT VA SALT LAKE CITY HEALTHCARE - GEORGE E. WAHLEN VA MEDICAL CENTER UT
  # VA SENTARA POTOMAC HOSPITAL VA
  # VI GOV JUAN F LUIS HOSPITAL & MEDICAL CTR VI
  # VT SPRINGFIELD HOSPITAL VT
  # WA HARBORVIEW MEDICAL CENTER WA
  # WI AURORA ST LUKES MEDICAL CENTER WI
  # WV FAIRMONT GENERAL HOSPITAL WV
  # WY CHEYENNE VA MEDICAL CENTER WY
  
  
  }


finished <- "finished"
