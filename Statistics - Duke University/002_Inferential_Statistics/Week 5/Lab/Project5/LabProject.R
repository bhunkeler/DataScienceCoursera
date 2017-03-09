# ============================================================================================================
# Description:   Course Project Week 5 / Statistical inference with the GSS data
#                Coursera Statistics at Duke University
#  
#
# Dataset:       gss [2.4Mb](http://www.icpsr.umich.edu/icpsrweb/ICPSR/studies/34802/version/1)
# Information:   Download Link: [http://www.norc.org/Research/Projects/Pages/general-social-survey.aspx]    
#
# Author:        Bruno Hunkeler
# Date:          xx.07.2016
#
# ============================================================================================================

# ============================================================================================================
# Load Libraries
# ============================================================================================================

library('statsr')
library('ggplot2')    # library to create plots
library('plyr')       # data manipulation
library('dplyr')      # data manipulation
library('gridExtra')  # supports the layout functionality with ggplot

# ============================================================================================================
# Download and extract Data and load file
# ============================================================================================================

# load the data set 
load(file = 'Data/gss.RData')
data <- gss

# evaluate the size of the data set
dim(data)      # 57061  /  114

# suppress this for the moment
# str(data)
# summary(data)

# ====================================================================================================
# Data preprocessing 
# ====================================================================================================

ggplot(data, aes(x = factor(degree))) +
  geom_histogram(color = 'black', fill= 'steelblue', stat = 'count') +
  ggtitle("Distribution of Degree")

ggplot(data, aes(x = coninc)) +
  geom_histogram(binwidth=5000, colour="steelblue", fill="lightgray") +
  xlab("income") +
  ggtitle("Distribution of Family Income")

# list the unique years in the data set
unique(data.rs2$year)

# subset various individual years in the dataset, then remove rows with missing data
gss.1990.na <- subset(gss, year == 1990, select = c(year, race, class, satfin, educ, degree, richwork, coneduc, satjob, coninc, incom16, sex))
gss.1990 <- gss.1990.na[complete.cases(gss.1990.na), ]

gss.2000.na <- subset(gss, year == 2000, select = c(year, race, class, satfin, educ, degree, richwork, coneduc, satjob, coninc, incom16, sex))
gss.2012 <- gss.2000.na[complete.cases(gss.2000.na), ]

gss.2012.na <- subset(gss, year == 2012, select = c(year, race, class, satfin, educ, degree, richwork, coneduc, satjob, coninc, incom16, sex))
gss.2012 <- gss.2012.na[complete.cases(gss.2012.na), ]

dim(gss.1990)
dim(gss.2000)
dim(gss.2012)

ggplot(gss.2012, aes(x = coninc)) +
  geom_histogram(binwidth=5000, colour="steelblue", fill="lightgray") +
  xlab("income") +
  ggtitle("Distribution of Family Income")

# degree
summary(gss.2012$degree)
prop.table(summary(gss.2012$degree))

# income
summary(gss.2012$coninc)
g <- ggplot(gss.2012, aes(coninc))
g + geom_density() + labs(title = "Distribution of income in 2012") + labs(x = "Total Family Income", y = "Density")

#boxplot of income vs degree
boxplot(gss.2012$coninc ~ gss.2012$degree, xlab = "Education Level", ylab = "Total Family Income", main = "Boxplot of Total Family Income by Education Level")

ggplot(gss.2012, aes(coninc, fill = degree)) + 
 geom_density (alpha = 0.2) + labs(title = "Income distributions across Education levels") + labs(x = "Total Family Income", y = "Density")


par(mfrow = c(3,2))
qqnorm(gss.2012$coninc[gss.2012$degree == "Lt High School"], main = "Lt High School", col = 'blue')
qqline(gss.2012$coninc[gss.2012$degree == "Lt High School"], col = 'red')
qqnorm(gss.2012$coninc[gss.2012$degree == "High School"], main = "High School", col = 'darkgreen')
qqline(gss.2012$coninc[gss.2012$degree == "High School"], col = 'red')
qqnorm(gss.2012$coninc[gss.2012$degree == "Junior College"], main = "Junior College", col = 'orange')
qqline(gss.2012$coninc[gss.2012$degree == "Junior College"], col = 'red')
qqnorm(gss.2012$coninc[gss.2012$degree == "Bachelor"], main = "Bachelor", col = 'brown')
qqline(gss.2012$coninc[gss.2012$degree == "Bachelor"], col = 'red')
qqnorm(gss.2012$coninc[gss.2012$degree == "Graduate"], main = "Graduate", col = 'magenta')
qqline(gss.2012$coninc[gss.2012$degree == "Graduate"], col = 'red')

#anova of gss.2012$coninc ~ gss.2012$degree
inference(y = coninc, x = degree, data = gss.2012, statistic = "mean", type = "ht", null = 0, alternative = "greater", method = "theoretical")

ml = aov(coninc~degree,data = gss.2012)
summary(ml)



by(gss.2012$coninc, gss.2012$degree, quantile)

ggplot(gss.2012, aes(coninc, fill = sex)) + 
geom_density (alpha = 0.2) + labs(title = "Income distributions across Gender") + labs(x = "Total Family Income", y = "Density") + scale_fill_manual( values = c("#0066FF","#FF0099"))

model.lm <- lm(gss.2012$coninc ~ gss.2012$degree + gss.2012$incom16 + gss.2012$sex)
summary(model.lm)










