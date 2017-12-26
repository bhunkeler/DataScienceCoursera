# ========================================================================================================================================
# Description:   Course Project 1 / 
#                Coursera Data Science at Duke University
#
#
# Dataset:       
#
# Author:        Bruno Hunkeler
# Date:          xx.xx.2016
#
# ========================================================================================================================================



# ========================================================================================================================================
# Load Libraries
# ========================================================================================================================================

# library('dplyr')
library('ggplot2')
library('plyr')


# Define Directory where File is located
dirName <- 'Data'

# load power consumption data
fileName = "cognitive.csv"
filePath <- file.path(dirName, fileName)

# data <- read.csv(file = fileNameState, header = TRUE, colClasses = c("character", numeric", "numeric", "numeric", "numeric", "numeric"))
data <- read.csv(file = filePath, header = TRUE)

colnames(data)

lm.cognitive = lm(kid_score ~ mom_hs + mom_iq + mom_work + mom_age , data = data)
summary(lm.cognitive)
anova(lm.cognitive)