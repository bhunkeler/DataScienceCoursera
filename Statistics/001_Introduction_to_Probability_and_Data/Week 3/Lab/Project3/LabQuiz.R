# ========================================================================================================================================
# Description:   Lab Quiz 3
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
library('curl')
library('ggplot2')
library('dplyr')
library(statsr)

temp = FALSE

# ==================================================================================================
# Lab Quiz 3
# ==================================================================================================

data(kobe_basket)

kobe_streak <- calc_streak(kobe_basket$shot)
ggplot(data = kobe_streak, aes(x = length)) +
  geom_histogram(binwidth = 1)

# ==================================================================================================
# Question 1

## Question 1: What does a streak length of 1 mean, i.e. how many hits and misses are in a streak of 1?

# Answer: A hit followed by a miss


# ==================================================================================================
# Question 2


## Question 2: What about a streak length of 0? How many hits and misses are in a streak of 0?

# Answer: A miss followed by a miss.

# ==================================================================================================
# Question 3

## Question 3: Which of the following is false about the distribution of Kobe’s streak lengths from the 2009 NBA finals. 
# Hint: You might want to also use other visualizations and summaries of kobe streak in order to answer this question.

# A. The distribution of Kobe’s streaks is unimodal and right skewed.
barplot(table(kobe_streak))
# TRUE

# B. The typical length of a streak, as measured by the median, is 0.
median(kobe_streak$length)
# TRUE

# C. The IQR of the distribution is 1.
summary(kobe_streak)
# TRUE

# D. The longest streak of baskets is of length 4.
barplot(kobe_streak$length)
# TRUE

# E. The shortest streak is of length 1.
# FALSE


# Answer: E - The shortest streak is of length 1.


coin_outcomes <- c("heads", "tails")
sample(coin_outcomes, size = 1, replace = TRUE)

sim_fair_coin <- sample(coin_outcomes, size = 100, replace = TRUE)
sim_fair_coin
table(sim_fair_coin)

sim_unfair_coin <- sample(coin_outcomes, size = 100, replace = TRUE, prob = c(0.2, 0.8))
table(sim_fair_coin)


# ------ 

shot_outcomes <- c("H", "M")
sim_basket <- sample(shot_outcomes, size = 1, replace = TRUE)

# unfair simulation
sim_basket <- sample(shot_outcomes, size = 133, replace = TRUE, prob = c(0.45, 0.55))
table(sim_basket)


# The 'kobe' data frame is already loaded into the workspace.
# So is the 'sim_basket' simulation.

# Calculate streak lengths:
kobe_streak <- calc_streak(kobe_basket$shot)
sim_streak <-  calc_streak(sim_basket)

# Compute summaries:
summary(kobe_streak)
summary(sim_streak)

# Make bar plots:
kobe_table <- table(kobe_streak)
sim_table <- table(sim_streak)

barplot(kobe_table, main='kobe_table')
barplot(sim_table, main='sim_table')




# ==========================================================================================
# Question 4
# If you were to run the simulation of the independent shooter a second time, how would you 
# expect its streak distribution to compare to the distribution from the exercise above?

# unfair simulation
sim_basket <- sample(shot_outcomes, size = 133, replace = TRUE, prob = c(0.45, 0.55))
table(sim_basket)

# Answer: B - Somewhat similar

# ==================================================================================================
# Question 5
# How does Kobe Bryant’s distribution of streak lengths compare to the distribution of streak lengths 
# for the simulated shooter? Using this comparison, do you have evidence that the hot hand model 
# fits Kobe’s shooting patterns?
barplot(kobe_table, main='kobe_table')
barplot(sim_table, main='sim_table')


# Answer: A - The distributions look very similar. Therefore, there doesn’t appear to be evidence for Kobe Bryant’s hot hand.

#







