
# =================================================================================
# code for Quiz Number 1
# =================================================================================

data <- read.csv("hw1_data.csv")

# Extract the subset of rows of the data frame where Ozone values are above 31 and 
# Temp values are above 90. What is the mean of Solar.R in this subset?

subsetOT <- data$Ozone > 31 & data$Temp > 90
subset <-data[subsetOT > FALSE, ] # subset <-data[subsetOT > 0, ]
good <- complete.cases(subset)
subset[good, ][, 2]
mean(subset[good, ][, 2])

# What is the mean of "Temp" when "Month" is equal to 6?
subsetM <- data$Month == 6
subset <-data[subsetM > FALSE, ]
mean(subset[, ][, 4])

# What was the maximum ozone value in the month of May (i.e. Month = 5)?
subsetM <- data$Month == 5
subset <-data[subsetM > FALSE, ]

