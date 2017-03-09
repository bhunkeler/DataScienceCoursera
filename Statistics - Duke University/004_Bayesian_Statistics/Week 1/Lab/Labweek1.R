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




# ============================================================================================================
# Download and extract Data and load file
# ============================================================================================================

bandit_posterior(data = data.frame(machine=1L, outcome="W"))
bandit_posterior(data = data.frame(machine=c(1L,1L), outcome=c("W","L")))


data1 = data.frame(machine=c(1L), outcome=c("W"))
data2 = data.frame(machine=c(1L), outcome=c("L"))
bandit_posterior(data1) %>% bandit_posterior(data2, prior=.)

data1 = data.frame(machine=c(1L, 1L), outcome=c("W", "W"))
data2 = data.frame(machine=c(2L, 2L, 2L), outcome=c("W", "W", "L"))
bandit_posterior(data1) %>% bandit_posterior(data2, prior=.)

data2 = data.frame(machine=c(1L, 1L), outcome=c("W", "W"))
data1 = data.frame(machine=c(2L, 2L, 2L), outcome=c("W", "W", "L"))
bandit_posterior(data1) %>% bandit_posterior(data2, prior=.)


data = data.frame(machine = c(1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L), outcome = c("L", "W", "W", "L", "L", "L", "L", "L", "L", "W", "W", "W", "W", "L", "L", "L", "L", "L", "L", "W", "L", "L", "L", "L", "L", "L", "W", "L", "L", "L"))

