# ============================================================================================================
# Description:   Course Project Week 5 / Behavioral Risk Factor Surveillance System
#                Coursera Statistics at Duke University
#
#
# Dataset:       brfss2013 [53Mb](https://d3c33hcgiwev3.cloudfront.net/_384b2d9eda4b29131fb681b243a7767d_brfss2013.RData?Expires=1464220800&Signature=QjjfkYt-C-wTRcwEvnuyFDvphasfoKEAkMo-088OscAJxIV7NbLUqOmkJZBXsVLUuJmJZmatWsi7bOoG9WMkp18BK4bGVvEpAjHyar9fOMmT9TcnFax5m2Dj8nJZzqox4IV20XOtnijNbzwQH4N8yd7CtbIc1tNTgeo8mq5ezjQ_&Key-Pair-Id=APKAJLTNE6QMUY6HBC5A)
# Information:   Download Link: [http://www.cdc.gov/brfss/annual_data/annual_2013.html]    
#
# Author:        Bruno Hunkeler
# Date:          24.05.2016
#
# ============================================================================================================

# ============================================================================================================
# Load Libraries
# ============================================================================================================

library('dplyr')
library('ggplot2')
library('plyr')
library('gridExtra')
library('ggmap')

loadFunctions <- FALSE
USPopulation2016 <- 323663800

# ============================================================================================================
# Download and extract Data and load file
# ============================================================================================================

# load the data set 
load(file = 'Data/brfss2013.RData')
data <- brfss2013

# evaluate the size of the data set
# dim(data)
# str(data)
# summary(data)

# retrieve only the required columns 
Col <- c('X_state', 'sex', 'genhlth', 'hlthpln1', 'income2', 'X_incomg', 'educa', 'X_educag', 'X_frutsum', 'X_vegesum', 'X_bmi5', 'X_bmi5cat', 'exerany2')
data.req <- data[, Col]

# ====================================================================================================
# Research questions
# ====================================================================================================

# Overall assumtion should be verified 
# - BMI analysis overall US population 
# 
# 1) Has the availability of health care plan an implication on the general health of people. 
# 2) Is there a qualitative relation between general health and the income resp. the education
# 3) Is there a relation between general health and BMI
# 4) Does weekly exercise support the general health of people. 
#    What are the implications of fruit / alcohol consumption on peoples general health. Is there a relation between general health 
#    and nutrition / alcohol consumption 

# ====================================================================================================
# Research question 0
# ====================================================================================================

# evaluate the percentage of the US population based on bmi Category

bmi.cat <- count(data.req, 'X_bmi5cat')
bmi.cat <- bmi.cat[-5,]
bmi.cat$percent <- prop.table(bmi.cat$freq)
bmi.cat$population <- lapply(bmi.cat$percent, function(x) {
    USPopulation2016 * x
})

# BMI Category    | Percentage of US Population | Population   | 
# - - - - - - - - | - - - - - - - - - - - - - - | - - - -  - - | 
# UNderweight     |                      1.77%  |     5753661  | 
# Normal weight   |                     33.30%  |   107805808  | 
# Overweight      |                     35.92%  |   116287012  | 
# Obese           |                     28.98%  |    93817319  | 

ggplot(bmi.cat, aes(x = factor(X_bmi5cat), y = percent, fill = percent, alpha = 0.8)) +
 geom_bar(stat = 'identity') +
 xlab('BMI Category') + ylab('Percentage of US Population') +
 ggtitle('Distribution of US Population (BMI Category)') +
 theme(axis.text.x = element_text(angle = 90, hjust = 1)) + 
geom_text(aes(label = X_bmi5cat), vjust = 1.6, color = 'black', position = position_dodge(0.9), size = 3)

par(mfrow = c(2, 2))

# is there a relation between healt care and general condition 
mosaicplot( ~ genhlth + hlthpln1, data = data.req, xlab = 'General health', ylab = 'Health plan', color = c('lightblue', 'steelblue'), main = 'General Health vs Helth care plan')

# is there a relation between exercise and general condition 
mosaicplot( ~ genhlth + exerany2, data = data.req, xlab = 'General health', ylab = 'Excercise', color = c('lightblue', 'steelblue'), main = 'General Health vs Excercise')

# clean up unused variables 
rm(bmi.cat)
rm(bmi.category)
rm(data.req)

if (loadFunctions == TRUE) {
    # Load initial functions to convert data 
    conv.ft.m <- function(x) ifelse(x > 9000, ((x - 9000) / 100), ((x / 100) * 0.3048))
    conv.pnd.kg <- function(x) ifelse(x > 9000, (x - 9000), (x * 0.453592))

    # Body Mass Index = weight in kg / (height in m2)
    calc.BMI = function(x, y) {
        return(BMI = x / y ^ 2)
    }
}

# ====================================================================================================
# Research question 0.1 
# 
# ====================================================================================================

Col <- c('X_state', 'X_bmi5', 'X_bmi5cat')
data.rsq0 <- data[, Col]

survey.population.State <- count(data.rsq0, 'X_state')
survey.population.State <- survey.population.State[-1,]
survey.population.State <- survey.population.State[-54,]

filterObese <- data.rsq0 %>% filter(X_bmi5cat == 'Obese') %>% group_by(X_state)
obese.population.State <- count(filterObese, 'X_state')

colnames(ObeseState) <- c('X_state','Obese')
obese.population.State$sample <- survey.population.State$freq




<- bmi.cat[-5,]
bmi.cat$percent <- prop.table(bmi.cat$freq)
bmi.cat$population <- lapply(bmi.cat$percent, function(x) {
    USPopulation2016 * x
})



# ====================================================================================================
# Research question 1 
# Is there a relation between Pysical healt, Income, Health care and education 
# ====================================================================================================

Col <- c('X_state', 'sex', 'genhlth', 'hlthpln1', 'X_frutsum', 'X_vegesum', 'X_bmi5', 'X_bmi5cat',  'X_frtlt1', 'X_veglt1', 'X_pacat1', 'exract11', 'X_age80')
data.rsq1 <- data[, Col]

# create summary for used features
# summary(data$hlthpln1)
# summary(data$income2)
# summary(data$educa)

# remove all rows with 'NA'
data.rsq1 <- data.rsq1[complete.cases(data.rsq1),]

data.rsq1 <- data.rsq1 %>% mutate(X_frtlt1 = ifelse(X_frtlt1 %in% c("Consumed fruit one or more times per day"), 1, 0))
data.rsq1 <- data.rsq1 %>% mutate(X_veglt1 = ifelse(X_veglt1 %in% c("Consumed vegetables one or more times per day"), 1, 0))


plot(data.rsq1$X_age80, data.rsq1$X_bmi5)

ggplot(data = data.rsq1, aes(x = X_age80, y = X_bmi5)) + geom_point(col = 'blue') + geom_smooth(method = lm)
















ds1 <- data.rsq1 %>% group_by(X_incomg) %>% filter(genhlth == 'Excellent')
ds <- ddply(data.rsq1, .(X_incomg, genhlth), summarise, count = table(genhlth))

a <- subset(ds, count > 0)
# co <- c('red', 'green', 'blue', 'yellow', 'steelblue', 'purple')
# ggplot(a, aes(x = genhlth, y = count)) + geom_bar()
# ggplot(a, aes(x = genhlth, y = count, fill = X_incomg, col = X_incomg)) + geom_point(pch = 19, size = 5) + facet_grid(genhlth ~ .)
ggplot(a, aes(x = genhlth, y = count, fill = X_incomg, col = X_incomg)) + geom_point(pch = 19, size = 5) +
geom_line(aes(group = 1), colour = "#000099") # Blue lines

# ====================================================================================================
# Research question 2
# Is there a relation between Pysical healt, Excercise and BMI
# ====================================================================================================
Col <- c('X_state', 'sex', 'genhlth', 'hlthpln1', 'income2', 'educa', 'X_incomg', 'educa', 'X_educag', 'X_frutsum', 'X_vegesum', 'X_bmi5', 'X_bmi5cat', 'exerany2', "X_frtlt1", "X_veglt1", "X_frt16" "X_veg23")
Col <- c('X_state', 'sex', 'genhlth', 'X_bmi5', 'htm4', 'wtkg3', 'exerany2')
data.rsq2 <- data[, Col]

dim(data.rsq2)

data.rsq2 <- data.rsq2[complete.cases(data.rsq2),]
summary(data.rsq2)

hist(data.rsq2$X_bmi5, 50, col = 'steelblue')

data.rsq2 <- mutate(data.rsq2, X_bmi5 = round((X_bmi5 / 100), 2))
data.rsq2 <- mutate(data.rsq2, htm4 = round((htm4 / 100), 2))
data.rsq2 <- mutate(data.rsq2, wtkg3 = round((wtkg3 / 100), 2))

data.rsq2 <- data.rsq2 %>% filter(htm4 < 2.5)

ggplot(data.rsq2, aes(x = htm4, y = X_bmi5)) +
    geom_point(col = 'blue') +
    ylab('X_BMI') + xlab("Height") +
    ggtitle("Number of Steps per Interval (weekend/weekend") +
    facet_grid(genhlth ~ .)



dd <- data.rsq2 %>% group_by(genhlth) %>% filter(genhlth == 'Excellent') %>% summarise(mean_g = mean(genhlth), sd_dd = sd(genhlth), n = n())


# ====================================================================================================
# Research question 2
# Is there a relation between Pysical healt, Excercise and BMI
# ====================================================================================================

Col <- c('X_state', 'sex', 'genhlth', 'weight2', 'height3', 'exerany2')
data.rsq2 <- data[, Col]


# remove all rows with 'NA' and blank data
data.rsq2 <- data.rsq2[complete.cases(data.rsq2),]
data.rsq2 <- data.rsq2[ - which(data.rsq2$weight2 == ''),]

# remove row with special character 
data.rsq2 <- data.rsq2[ - which(data.rsq2$weight2 == '.b'),]

data.rsq2$weight2 <- as.numeric(as.character(data.rsq2$weight2))

# clean <- c(15688, 73709)
# data.rsq2[73709, 'weight2'] <- data.rsq2[73709, 'weight2'] - 9000
# data.rsq2[15688, 'weight2'] <- data.rsq2[15688, 'weight2'] - 9000


# Convert pounds to kg and ft to meters 
data.rsq2 <- mutate(data.rsq2, weight2 = round(conv.pnd.kg(weight2), 2))
data.rsq2 <- mutate(data.rsq2, height3 = round(conv.ft.m(height3), 2))

#remove obvisually wrong data
data.rsq2 <- data.rsq2[ - which(data.rsq2$height3 > 2.5),]
data.rsq2 <- data.rsq2[ - which(data.rsq2$weight2 > 250),]

ggplot(data = data.rsq2, aes(x = weight2), col = 'steelblue') + geom_histogram()


rdu_flights %>%
  summarise(mean_dd = mean(dep_delay), sd_dd = sd(dep_delay), n = n())

a <- data.rsq2 %>% filter(weight2 < 9000)
hist(a$weight2, breaks = 50, col = 'steelblue', xlab = 'weight', ylab = 'number', main = 'weight distribution')
hist(log10(a$weight2), breaks = 50, col = 'steelblue', xlab = 'weight', ylab = 'number', main = 'weight distribution')

b <- data.rsq2 %>% filter(height3 < 7000)
hist(b$height3, breaks = 50, col = 'steelblue', xlab = 'height3', ylab = 'number', main = 'weight distribution')
hist(log10(b$height3), breaks = 50, col = 'steelblue', xlab = 'height3', ylab = 'number', main = 'weight distribution')


ggplot(data.rsq2, aes(weight2, height3)) + geom_point()
ggplot(data.rsq2, aes(x = height3, y = weight2)) + geom_point()

# calculate the BMI 
data.rsq2 <- mutate(data.rsq2, BMI = round(calc.BMI(weight2, height3), 2))

c <- which(data.rsq2$X_state == 'Louisiana' & data.rsq2$height3 == 504 & data.rsq2$genhlth == 'Poor' & data.rsq2$sex == 'Female')
a <- data.rsq2[c,]


hist(data.rsq2$weight2, breaks = 100, col = 'blue')
hist(data.rsq2$height3, breaks = 500, col = 'green')
hist(data.rsq2$BMI, breaks = 100, col = 'blue')

# calc BMI /  Excercise 
# summary(data$weight2)
# summary(data$height3)
# summary(data$exerany2)

# handle NA values
# reasign unknown to feature which are "Not Available", "NULL", "Not Mapped"
# test <- test %>% mutate(weight2 = ifelse(weight2 %in% c("", "9999"), "NA", weight2))
# mutate(test, weight2 = ifelse(weight2 == '', 'NA', weight2))

test <- data.rsq2

test.NoNA <- test[complete.cases(test),]
test.NoNA <- test.NoNA[ - which(test.NoNA$weight2 == ''),]
test.NoNA$weight2 <- as.numeric(as.character(test.NoNA$weight2))
test.NoNA <- mutate(test.NoNA, weight2 = round(conv.pnd.kg(weight2), 2))
test.NoNA <- mutate(test.NoNA, height3 = round(conv.ft.m(height3), 2))

test.NoNA <- mutate(test.NoNA, BMI = round(calc.BMI(weight2, height3), 2))

test.NoNA$weight2 <- lapply(test.NoNA$weight2, conv.pnd.kg)

# based on variable values
data.rsq2 <- data.rsq2[which((data.rsq2$height3 > 100) & (data.rsq2$height3 < 8000)),]
data.rsq2 <- data.rsq2 %>% filter((height3 > 100) & (height3 < 8000))

rdu_flights %>%
  group_by(origin) %>%
  summarise(mean_dd = mean(dep_delay), sd_dd = sd(dep_delay), n = n())



# ====================================================================================================
# Research question 3
# Is there a relation between Pysical healt, education and nutrition
Col <- c('X_state', 'sex', 'genhlth', 'educa', 'fruit1', 'vegetab1')
data.rsq3 <- data[, Col]

# fruit & vegi consumtion
summary(data$vegetab1)
summary(data$fruit1)




# remove all rows with 'NA'
data.rsq3.NoNA <- data.rsq1[complete.cases(data.rsq3),]






# remove all rows with 'NA'
data.NoNA <- dd[complete.cases(dd),]


dd_male <- nrow(dd %>% filter(sex == "Male"))
dd_female <- nrow(dd %>% filter(sex == "Female"))

noMale <- nrow(dd$sex == 'Male', na.rm = TRUE)
noFeMale <- sum(dd$sex == 'female')

hist(as.numeric(as.factor(dd$sex)))




