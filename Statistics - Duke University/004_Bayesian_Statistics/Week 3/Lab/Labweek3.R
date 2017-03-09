# ============================================================================================================
# Description:   Course Project Week 1 / LabWeek 1
#                Coursera Statistics at Duke University
#  
# Author:        Bruno Hunkeler
# Date:          xx.07.2016
#
# ============================================================================================================

install.packages("devtools")
devtools::install_github("StatsWithR/statsr")

# ============================================================================================================
# Load Libraries
# ============================================================================================================

library('dplyr')
library('ggplot2')
library('plyr')
library('devtools')
library('statsr')
library('shiny')


# ============================================================================================================
# Download and extract Data and load file
# ============================================================================================================

data(nc)

# Question 1 
str(nc)

# Answer: 7

# Question 2 
hist(nc$weight)
# Answer: left skewed

# Question 3 
bayes_inference(y = weight, data = nc, cred_level = 0.99, statistic = "mean", type = "ci")
# Answer: B 99% CI: (6.9778 , 7.2244)

# Question 4
bayes_inference(y = weight, data = nc, statistic = "mean", type = "ht", null = 7, alternative = "twosided")
# Answer: Positive BF[H1:H2] = 3.3915

boxplot(weight~habit,data=nc, main="title", xlab="smoker / non smoker", ylab="weight")


dpois(10, 10)
pbeta(0.5, 1 + 5029, 1 + 4971)