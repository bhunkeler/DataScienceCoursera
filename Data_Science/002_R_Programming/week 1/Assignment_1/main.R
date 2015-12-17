# =============================================================================
# Description: Assignment 1 
# 
#
#
# Authhor:     Bruno Hunkeler 
# Date:        04.11.2015
# =============================================================================


# references to functions
source("pollutantmean.R")

# library references 
# library(miscTools)

# =============================================================================
#  Assignment 1/1 - pollutantmean 
# =============================================================================

directory <- "specdata"

# Coursera Test Cases 
# pollutantmean("specdata", "sulfate", 1:10)  # Expected Result:  4.064
# pollutantmean("specdata", "nitrate", 70:72) # Expected Result:  1.706
# pollutantmean("specdata", "nitrate", 23)    # Expected Result:  1.281

pollutant <- c("sulfate", "nitrate")
names(pollutant) <- c("sulfate", "nitrate")

monitorID_Coursera_TC1 <- c(1:10)
monitorID_Coursera_TC2 <- c(70:72)
monitorID_Coursera_TC3 <- c(23)

pollutantmean_Coursera_TC1 <- pollutantmean(directory, pollutant["sulfate"], monitorID_Coursera_TC1)
pollutantmean_Coursera_TC2 <- pollutantmean(directory, pollutant["nitrate"], monitorID_Coursera_TC2)
pollutantmean_Coursera_TC3 <- pollutantmean(directory, pollutant["nitrate"], monitorID_Coursera_TC3)

verification = c(FALSE, FALSE, FALSE)

if (round(pollutantmean_Coursera_TC1, digits = 3) == 4.064){
  verification[1] = TRUE
  
}

if (round(pollutantmean_Coursera_TC2, digits = 3) == 1.706){
  verification[2] = TRUE
  
}

if (round(pollutantmean_Coursera_TC3, digits = 3) == 1.281){
  verification[3] = TRUE
  
}

# verify if all values are correctly calculated
print(all(verification, na.rm = TRUE))


# my own Test Cases 

monitorID_TC1 <- c(1)
monitorID_TC2 <- c(2, 4, 8, 10, 12)
monitorID_TC3 <- c(30:25)
monitorID_TC4 <- c(3)

pollutantmean_TC1 <- pollutantmean(directory, pollutant["sulfate"], monitorID_TC1)
pollutantmean_TC2 <- pollutantmean(directory, pollutant["nitrate"], monitorID_TC1)
print("Test Case 1") 
print(pollutantmean_TC1)
print("Test Case 2") 
print(pollutantmean_TC2)

pollutantmean_TC3 <- pollutantmean(directory, pollutant["sulfate"], monitorID_TC2)
pollutantmean_TC4 <- pollutantmean(directory, pollutant["nitrate"], monitorID_TC2)
print("Test Case 3")
print(pollutantmean_TC3)
print("Test Case 4") 
print(pollutantmean_TC4)

pollutantmean_TC5 <- pollutantmean(directory, pollutant["sulfate"], monitorID_TC3)
pollutantmean_TC6 <- pollutantmean(directory, pollutant["nitrate"], monitorID_TC3)
print("Test Case 5")
print(pollutantmean_TC5)
print("Test Case 6")
print(pollutantmean_TC6)

pollutantmean_TC7 <- pollutantmean(directory, pollutant["sulfate"], monitorID_TC4)
pollutantmean_TC8 <- pollutantmean(directory, pollutant["nitrate"], monitorID_TC4)
print("Test Case 7")
print(pollutantmean_TC7)
print("Test Case 8")
print(pollutantmean_TC8)












