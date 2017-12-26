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
library('LearnBayes')


# ============================================================================================================
# Download and extract Data and load file
# ============================================================================================================

# credible_interval_app()
data(brfss)
table(brfss$sex)



CredibleInterval_99 <- c(0.005,0.995) 
CredibleInterval_95 <- c(0.025,0.975)
CredibleInterval_90 <- c(0.05,0.95)


x <- seq(0, 1, len = 100)
p <- qplot(x, geom = "blank")
stat <- stat_function(aes(x = x, y = ..y..), fun = dbeta, colour="red", n = 100,
                      args = list(CredibleInterval_95, shape1 = 5, shape2 = 200))
p + stat


db <- dbeta(x, 5, 2)
plot(x, db, type='l', col = 'red')


pbeta(0.2, 4, 22)
pbeta(CredibleInterval_95, 40, 60)
pbeta(CredibleInterval_95, 143, 157,lower.tail = FALSE)

# 99% Credible Interval
qbeta(c(0.005,0.995),4,8)
qbeta(CredibleInterval_99,4,8)

# 95% Credible Interval
qbeta(c(0.025,0.975),4,8)
qbeta(CredibleInterval_95,4,8)


qnorm(CredibleInterval_95, 10, sqrt(5))
qgamma(CredibleInterval_99, 4, 8)

dbeta(CredibleInterval_95,5,200)

dunif(CredibleInterval_90, min = 0, max = 300000000)

dnorm(CredibleInterval_95, 200, 2500)
pgamma(49.5, 2/(2*49 +1)
