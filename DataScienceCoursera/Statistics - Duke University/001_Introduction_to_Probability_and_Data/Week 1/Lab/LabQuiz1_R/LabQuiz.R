# ========================================================================================================================================
# Description:   Lab Quiz 1
#                Coursera Data Science at Duke University
#
#
# Author:        Bruno Hunkeler
# Date:          02.05.2016
#
# ========================================================================================================================================

# ========================================================================================================================================
# Load Libraries
# ========================================================================================================================================

library('devtools')
library('ggplot2')
library('dplyr')
library(statsr)
# library('StatsRBHU')
# install_github('StatsWithR/statsr')

# ========================================================================================================================================
# Part 1 - Mean total number of steps taken per day?
# ========================================================================================================================================

# Question 1
dim(arbuthnot)

# Question 2

arbuthnot$girls

# Question 3
plot(arbuthnot$year, arbuthnot$girls, type = "l")

# Question 4
dim(present)

# Question 5

data <- present 
data$total <- present$girls + present$boys
data$prop_boys  <- (total / present$boys)
plot(data$year, data$prop_boys, type ='l', col = 'green')


total <- present$girls + present$boys
prop_boys  <- (present$boys / total)
par(mfrow = c(1, 2))
plot(present$year, prop_boys, type ='l', col = 'blue')
plot(present$year, total, type ='l', col = 'red')


# Question 6
more_boys  <- ifelse(present$boys > present$girls, 'TRUE', 'FALSE')

data <- present
data$more <- ifelse(data$boys > data$girls, 'TRUE', 'FALSE')


# Question 7
prop_boy_girl <- data$boys / data$girls
plot(data$year, prop_boy_girl, type ='l', col = 'green')


# par(mfrow = c(1, 2))
# prop_boy_girl <- data$boys / data$girls
# prop_girl_boy <- data$girls / data$boys
# plot(present$year, prop_girl_boy, type ='l', col = 'green')
# plot(present$year, prop_boy_girl, type ='l', col = 'green')

# Question 8
data$total <- total

data$year[which.max(data$total)]





