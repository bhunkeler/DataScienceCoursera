# ============================================================================================================
# Description:   Course Project Week 3 / LabWeek 3
#                Coursera Statistics at Duke University
#  
# Author:        Bruno Hunkeler
# Date:          xx.07.2016
#
# ============================================================================================================

# ============================================================================================================
# Load Libraries
# ============================================================================================================

library('dplyr')
library('ggplot2')
library('plyr')
library('devtools')
library('statsr')

# ============================================================================================================
# Download and extract Data and load file
# ============================================================================================================

data(nc)

# ============================================================================================================
# Question 1 
# ============================================================================================================

# Answer: D - The birth


# ============================================================================================================
# Question 2 
# ============================================================================================================

# Answer: C - Missing data 27

# ============================================================================================================
# Question 3 
# ============================================================================================================

boxplot(weight ~ habit, data = nc)

# Answer: C - Both distributions are extremely right skewed.

# ============================================================================================================
# Question 4 
# ============================================================================================================




nc %>%
  group_by(habit) %>%
  summarise(mean_weight = mean(weight))


# Answer: B - H0:μsmoking = μnon−smoking; HA:μsmoking ≠ μnon−smoking

# ============================================================================================================
# Question 5 
# ============================================================================================================

inference(y = weight, x = habit, data = nc, statistic = "mean", type = "ci", null = 0, 
          alternative = "twosided", method = "theoretical")

inference(y = weight, x = habit, data = nc, statistic = "mean", type = "ci",  
           method = "theoretical", conf_level = 0.95)

# Answer: D - We are 95% confident that babies born to nonsmoker mothers are on average 0.05 to 0.58 pounds heavier at birth than babies born to smoker mothers.

# ============================================================================================================
# Question 6
# ============================================================================================================

inference(y = weeks, data = nc, statistic = "mean", type = "ci",  
          method = "theoretical", conf_level = 0.99)

inference(y = weeks, data = nc, statistic = "mean", type = "ci",  
          method = "theoretical", conf_level = 0.90)

by(nc$fage, nc$mature, summary)


ncc <- nc
ncc <- na.omit(ncc)

ncc %>%
  group_by(mature) %>%
  summarise(min_age = min(fage))


ncc %>%
  filter(mature == 'younger mom') %>%
  summarise(max_age = max(fage))

ncc %>%
  filter(mature == 'mature mom') %>%
  summarise(min_age = min(fage))






# ============================================================================================================
# Question 7
# ============================================================================================================




inference(y = weight, x = whitemom, data = nc, statistic = "mean", type = "ci", 
          method = "theoretical", order = c("not white","white"))





