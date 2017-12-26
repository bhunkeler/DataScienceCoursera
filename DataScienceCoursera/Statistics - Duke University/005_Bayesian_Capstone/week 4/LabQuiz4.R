# ============================================================================================================
# Description:   Course Project week2
#                Coursera Statistics at Duke University
#
# Author:        Bruno Hunkeler
# Date:          xx.04.2017
#
# ============================================================================================================

# install.packages("devtools")
# devtools::install_github("StatsWithR/statsr")

# ============================================================================================================
# Load Libraries
# ============================================================================================================

library('ggplot2')      # library to create plots
library('dplyr')        # data manipulation
library('knitr')        # required to apply knitr options 
library('statsr')       # staistics functions
library('MASS')
library('BAS')          # Bayesian statistics functions
source('utils.R')

library('labeling')
library('GGally')       # library to create plots
library('grid')         # arrange plots 
library('gridExtra')    # arrange plots
# ============================================================================================================
# Download and extract Data and load file
# ============================================================================================================

load("Data/ames_train.Rdata")


data <- ames_train
# data <- ames

# ============================================================================================================
# Exploratory Data Analysis
# ============================================================================================================

# dataset size 
dim(ames) # 2930/82

# training dataset
dim(data) # 1000/81
# str(data)

# ============================================================================================================
# Question 1


# show the histogram to verify the distribution 
hist(data$Year.Built,
     main = "Histogram for houses built in year", 
     xlab = "Year built", 
     breaks = 30, col = 'steelblue')

# ggplot(data, aes(x = Year.Built)) + 
#        geom_histogram( color = "darkblue", fill = 'steelblue', binwidth = 30) +
#        geom_density(alpha=.2, fill="red") +
#        xlab('Year built') + 
#        labs(title = "Histogram for houses built in year", x = 'Year built', y = "Frequency")

summary(data$Year.Built)

data$age <- sapply(data$Year.Built, function(x) 2017 - x) 

# calculate the mode of the distribution
mode <- dmode(data$age)


ggplot(data = data, aes(x = age, y = ..density..)) +
  geom_histogram(bins = 30, fill = 'steelblue', colour = 'black') + #bdbdbd
  geom_density(size = 1, colour = 'brown') + #cccccc
  labs(title = "Histogram - ages of houses in years", x = 'age', y = "Frequency") +
  geom_vline(data = data, mapping = aes( xintercept = mean(data$Yage), colour = 'steelblue'), size = 1.5) +
  geom_vline(data = data,mapping = aes( xintercept = median(data$age), colour = 'green'), size = 1.5) +
  geom_vline(data = data, mapping = aes( xintercept = mode, colour = 'red'), size = 1.5) +
  geom_text(data = data, aes( x = (mean(data$age) - 5), y = .020, label = 'mean', colour = 'steelblue'), size = 4, parse = T) +
  geom_text(data = data,aes( x = (median(data$age) + 5),y = .020,  label = 'median', colour = 'green'), size = 4, parse = T) +
  geom_text(data = data, aes( x = (mode + 5), y = .020, label = 'mode', colour = 'red'), size = 4, parse = T) +
  guides(color = FALSE, size = FALSE)


summary.age <- data %>% summarise(mean_age = mean(age),
                   median_age = median(age),
                   sd_age = sd(age),
                   min_age = min(age),
                   max_age = max(age),
                   IQR_age = IQR(age),
                   total = n())

# ============================================================================================================
# Question 2

price.neigborhood <- data %>% dplyr::select(price, Neighborhood)
price.neigborhood.summary <- price.neigborhood %>% group_by(Neighborhood) %>% summarise(mean_price = mean(price),
                                                                median_price = median(price),
                                                                min_price = min(price),
                                                                max_price = max(price),
                                                                IQR_price = IQR(price),
                                                                sd_price  = sd(price),
                                                                Var_price = var(price),
                                                                total = n())

price.neigborhood.StoneBr <- price.neigborhood %>% filter(Neighborhood == 'StoneBr')
range(price.neigborhood.StoneBr$price)
sd(price.neigborhood.StoneBr$price)
var(price.neigborhood.StoneBr$price)
quantile(price.neigborhood.StoneBr$price)

price.neigborhood.NridgHt <- price.neigborhood %>% filter(Neighborhood == 'NridgHt')
range(price.neigborhood.NridgHt$price)
sd(price.neigborhood.NridgHt$price)
var(price.neigborhood.NridgHt$price)
quantile(price.neigborhood.NridgHt$price)


Most.exp.Neighborhood <- price.neigborhood.summary[which(price.neigborhood.summary$median_price == max(price.neigborhood.summary$median_price)),]
Least.exp.Neighborhood <- price.neigborhood.summary[which(price.neigborhood.summary$median_price == min(price.neigborhood.summary$median_price)),]
heterogeneous.Neighborhood <- price.neigborhood.summary[which(price.neigborhood.summary$sd_price == max(price.neigborhood.summary$sd_price)),]

# boxplot(data$price ~ data$Neighborhood, col = "steelblue")

ggplot(data, aes(x = Neighborhood, y = (data$price / 1000), col = Neighborhood)) +
  geom_boxplot(color = "darkblue", fill = 'steelblue') + 
  ylab('Price in [$ 1000]') + xlab('Neigborhood') + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) 

ggplot(data, aes(x = Neighborhood, y = (data$price / 1000), col = Neighborhood)) +
  geom_boxplot(color = "darkblue", fill = 'steelblue') + 
  ylab('Price in [$ 1000]') + xlab('Neigborhood') + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) 

q1 <- price.neigborhood %>% filter(Neighborhood == 'StoneBr')
q2 <- price.neigborhood %>% filter(Neighborhood == 'NridgHt')

p1 <- ggplot(data = q1, aes(x = price, y = ..density..)) +
  geom_histogram(bins = 30, fill = 'steelblue', colour = 'black') + 
  labs(title = "StoneBr", x = 'price', y = "density") +
  geom_density(size = 1, colour = 'brown') 
  

p2 <- ggplot(data = q2, aes(x = price, y = ..density..)) +
  geom_histogram(bins = 30, fill = 'steelblue', colour = 'black') + 
  labs(title = "NridgHt", x = 'price', y = "density") +
  geom_density(size = 1, colour = 'brown') 

grid.arrange(p1, p2)


# ============================================================================================================
# Question 3

# summary(data)

# find the variable with the highest NA count
na_count <- sapply(data, function(x) sum(is.na(x)))
df.na_count <- data.frame(na_count)

df.merged <- cbind(c(row.names(df.na_count)), df.na_count[,1])
colnames(df.merged) <- c('feature', 'No_NA')

df.merged[which(df.na_count == max(df.na_count)),]
# na_count %>% dplyr::summarize(max_val = max(na_count))

index <- which(df.na_count == max(df.na_count))

term <- c('Av. high in °C', 'Av. low in °C', 'Av. precipitation in mm', 'Average snowfall in cm')
col.nm <-  c(' ', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec' ) 

av.high <- c(-1.3 , 1.4, 8.8, 17.2, 22.8, 27.5, 29.1, 28.1, 24.9, 17.8, 8.4, 0.1 )
av.low <- c(-11.3, -8.6, -2.4, 3.7, 10.1, 15.5, 17.6, 16.4, 11.6, 5, -2.1, -9.3)
av.prec <- c(18, 21, 54, 94 , 122, 126, 123, 122, 83, 66, 52, 29 )
av.snow <- c(17.8, 20.3, 12.7, 2.5, 0, 0, 0, 0, 0, 0 ,5.1, 20.3)
climate <- rbind(av.high, av.low, av.prec, av.snow)

climate <- cbind(term, climate)
rownames(climate) <- NULL
climate <- data.frame(climate)
colnames(climate) <- col.nm

# ============================================================================================================
# Question 4

data.model <- data %>% dplyr::select( Lot.Area, Land.Slope, Year.Built, Year.Remod.Add, Bedroom.AbvGr, price)

# make sure no NA values are in the dataset
data.model <- data.model[complete.cases(data.model), ]
formula1 <- as.formula(log(price) ~ Lot.Area + Land.Slope + Year.Built + Year.Remod.Add + Bedroom.AbvGr)
formula2 <- as.formula(log(price) ~ Land.Slope + Year.Built + Year.Remod.Add + Bedroom.AbvGr)
formula3 <- as.formula(log(price) ~ Lot.Area + Year.Built + Year.Remod.Add + Bedroom.AbvGr)
formula4 <- as.formula(log(price) ~ Lot.Area + Land.Slope + Year.Remod.Add + Bedroom.AbvGr)

lm.houses1 <- lm(formula1, data.model)
lm.houses2 <- lm(formula2, data.model)
lm.houses3 <- lm(formula3, data.model)
lm.houses4 <- lm(formula4, data.model)

summary(lm.houses1)
summary(lm.houses2)
summary(lm.houses3)
summary(lm.houses4)

m1 <- summary(lm.houses1)$adj.r.squared
m2 <- summary(lm.houses2)$adj.r.squared
m3 <- summary(lm.houses3)$adj.r.squared
m4 <- summary(lm.houses4)$adj.r.squared

R_Squared <- rbind(m1, m2, m3, m4)
model <- c('lm.houses1', 'lm.houses2', 'lm.houses3', 'lm.houses4')
df <- data.frame(cbind(model, R_Squared))

colnames(df) <- c('Model', 'R_Squared')

q <- data.model
q$residuals <- max(lm.houses1$residuals)


par(mfrow = c(2, 2))
plot(lm.houses.log, col = 'steelblue')

p1 <- ggplot(data.model, aes(x = log(data.model$price), y = lm.houses1$residuals)) + 
  geom_point(col = 'steelblue') + geom_hline(yintercept = 0, linetype = 'dashed', color = 'red')

p2 <- ggplot(data.model, aes(x = data.model$price, y = lm.houses2$residuals)) + 
             geom_point(col = 'brown') + geom_hline(yintercept = 0, linetype = 'dashed', color = 'red')

p3 <- ggplot(data.model, aes(x = log(data.model$price), y = lm.houses3$residuals)) + 
  geom_point(col = 'steelblue') + geom_hline(yintercept = 0, linetype = 'dashed', color = 'red')

p4 <- ggplot(data.model, aes(x = data.model$price, y = lm.houses4$residuals)) + 
  geom_point(col = 'brown') + geom_hline(yintercept = 0, linetype = 'dashed', color = 'red')

grid.arrange(p1, p2, p3, p4)



# Bayesian Information Criterion
houses.BIC = bas.lm(formula = log(price) ~ Lot.Area + Land.Slope + Year.Built + Year.Remod.Add + Bedroom.AbvGr,
                    prior = "BIC",
                    modelprior = uniform(),
                    data = data.model
)
image.bas(houses.BIC, subset=-1, rotate = FALSE)

# Zellner-Siow Cauchy
houses.ZS =  bas.lm(formula = log(price) ~ Lot.Area + Land.Slope + Year.Built + Year.Remod.Add + Bedroom.AbvGr, 
                    data = data.model,
                    prior="ZS-null",
                    modelprior=uniform(),
                    method = "MCMC", 
                    MCMC.iterations = 10^6) 
image.bas(houses.ZS, subset=-1, rotate = FALSE)


houses.bic.beta = bas.lm(formula = log(price) ~ Lot.Area + Land.Slope + Year.Built + Year.Remod.Add + Bedroom.AbvGr,
                   data = data.model, 
                   n.models=2^15, 
                   prior="AIC",
                   modelprior = beta.binomial(1,1),
                   initprobs= "eplogp")

image(houses.bic.beta, rotate = FALSE)

summary(crime.bic)
plot(crime.bic)

# more complete demo's
# demo(BAS.hald)


# ============================================================================================================
# Question 5

data.model <- data %>% dplyr::select( Lot.Area, Land.Slope, Year.Built, Year.Remod.Add, Bedroom.AbvGr, price)

# make sure no NA values are in the dataset
data.model <- data.model[complete.cases(data.model), ]
formula <- 'log(price) ~ Lot.Area + Land.Slope + Year.Built + Year.Remod.Add + Bedroom.AbvGr'
# formula <- 'log(price) ~ Lot.Area + Year.Built + Year.Remod.Add + Bedroom.AbvGr'

lm.houses <- lm(formula, data.model)
summary(lm.houses)


# type your code for Question 5 here, and Knit
par(mfrow = c(2, 2))
plot(lm.houses, col = 'steelblue')

max(resid(lm.houses))
qq <- max(abs(resid(lm.houses)))
qq <- as.data.frame(qq)

which(abs(resid(lm.houses)) == max(abs(resid(lm.houses))))

# The house whith the largest squared residual is No. 428
resid(lm.houses)[428]

coef(summary(lm.houses))


dm <- data.model
dm <- as.data.frame(dm)

mean(dm$Lot.Area)
mean(dm$Land.Slope)
mean(dm$Year.Built)
mean(dm$Year.Remod.Add)
mean(dm$Bedroom.AbvGr)
dm[428, ]

dm$predicted <- exp(predict(lm.houses))
dm$residuals <- residuals(lm.houses)


dm[428, ]

# dm <- dm[428,]

ggplot(dm, aes(x = Lot.Area, y = price)) +
  geom_smooth(method = "lm", se = FALSE, color = "lightgrey") +  # Plot regression slope
  geom_segment(aes(xend = Lot.Area, yend = predicted), alpha = .2) +  # alpha to fade lines
  geom_point() +
  geom_point(aes(y = predicted), shape = 1) +
  theme_bw()  # Add theme for cleaner look


ggplot(dm, aes(x = Lot.Area, y = price)) +
  geom_smooth(method = "lm", se = FALSE, color = "lightgrey") +  # Plot regression slope
  geom_segment(aes(xend = Lot.Area, yend = predicted), alpha = .2) +  # alpha to fade lines
  geom_point(aes(color = residuals)) +
  geom_point(aes(y = predicted), shape = 1) +
  theme_bw()  # Add theme for cleaner look


dm %>% 
  gather(key = "iv", value = "x", -price, -predicted, -residuals) %>%  # Get data into shape
  ggplot(aes(x = x, y = price)) +  # Note use of `x` here and next line
  geom_segment(aes(xend = x, yend = predicted), alpha = .2) +
  geom_point(aes(color = residuals)) +
  scale_color_gradient2(low = "blue", mid = "white", high = "red") +
  guides(color = FALSE) +
  geom_point(aes(y = predicted), shape = 1) +
  facet_grid(~ iv, scales = "free") +  # Split panels here by `iv`
  theme_bw()



data.model[428,]
a <- data[428, ]

p1 <- ggplot(data = NULL, aes(x = log(data.model$price), y = lm.houses$residuals)) + 
  geom_point(col = 'steelblue') + geom_hline(yintercept = 0, linetype = 'dashed', color = 'red')

p2 <- ggplot(data = NULL, aes(x = data.model$Lot.Area, y = lm.houses$residuals)) + 
  geom_point(col = 'darkgreen') + geom_hline(yintercept = 0, linetype = 'dashed', color = 'red')

p3 <- ggplot(data = NULL, aes(x = data.model$Year.Built, y = lm.houses$residuals)) + 
  geom_point(col = 'brown') + geom_hline(yintercept = 0, linetype = 'dashed', color = 'red')

p4 <- ggplot(data = NULL, aes(x = data.model$Bedroom.AbvGr, y = lm.houses$residuals)) + 
  geom_point(col = 'orange') + geom_hline(yintercept = 0, linetype = 'dashed', color = 'red')

p5 <- ggplot(data = NULL, aes(x = data.model$Land.Slope, y = lm.houses$residuals)) + 
  geom_point(col = 'purple') + geom_hline(yintercept = 0, linetype = 'dashed', color = 'red')

grid.arrange(p1, p2, p3, p4, p5)

# ============================================================================================================
# Question 6


data.model <- data %>% dplyr::select( Lot.Area, Land.Slope, Year.Built, Year.Remod.Add, Bedroom.AbvGr, price)

# make sure no NA values are in the dataset
data.model <- data.model[complete.cases(data.model), ]

featurs <- c( 'Lot.Area', 'Land.Slope', 'Year.Built', 'Year.Remod.Add', 'Bedroom.AbvGr', 'price' )
formula.Q6 <- 'log(price) ~ log(Lot.Area) + Land.Slope + Year.Built + Year.Remod.Add + Bedroom.AbvGr'

lm.houses.log <- lm(formula.Q6, data.model)
summary(lm.houses.log)

formula.Q6_1 <- 'log(price) ~ log(Lot.Area) + Year.Built + Year.Remod.Add + Bedroom.AbvGr'

lm.houses.log1 <- lm(formula.Q6_1, data.model)
summary(lm.houses.log1)


# Outliers
# Assessing Outliers
library(car)
outlierTest(lm.houses.log) # Bonferonni p-value for most extreme obs
qqPlot(lm.houses.log, main="QQ Plot") #qq plot for studentized resid 
leveragePlots(lm.houses.log) # leverage plots

qqPlot(lm.houses.log, id.n=3)
influenceIndexPlot(lm.houses.log, id.n=3)
influencePlot(lm.houses.log, id.n=3)

# ============================================================================================================
# Question 7

data.model <- data %>% dplyr::select( Lot.Area, Land.Slope, Year.Built, Year.Remod.Add, Bedroom.AbvGr, price)

# make sure no NA values are in the dataset
data.model <- data.model[complete.cases(data.model), ]

# prepare formulas with log transformation of Lot.Area and without
formula.nolog <- 'log(price) ~ Lot.Area + Year.Built + Year.Remod.Add + Bedroom.AbvGr'
formula.log   <- 'log(price) ~ log(Lot.Area) + Year.Built + Year.Remod.Add + Bedroom.AbvGr'

# run regression on log version
lm.houses.log <- lm(formula.log, data.model)
summary(lm.houses.log)

# run regression on nolog version
lm.houses.nolog <- lm(formula.nolog, data.model)
summary(lm.houses.nolog)


# retrieve true values from data set
true.values <- data.model[, 'price']

# prepare dataset to run test
data.test <- subset(data.model, select = -c(price) )                           
data.prediction <- data.test

data.pred.log <- predict(lm.houses.log, data.prediction, interval = "prediction", level = 0.90)
data.pred.log <- data.frame(data.pred.log)
pred.log <- sapply(data.pred.log[1], function(x) exp(x) )  

data.pred.nolog <- predict(lm.houses.nolog, data.prediction, interval = "prediction", level = 0.90)
data.pred.nolog <- data.frame(data.pred.nolog)
pred.nolog <- sapply(data.pred.nolog[1], function(x) exp(x) )  

# merge pred.log and true.values
pred.log <- cbind(pred.log, true.values)
colnames(pred.log) <- c('pred', 'true.value')

# merge pred.nolog and true.values
pred.nolog <- cbind(pred.nolog, true.values)
colnames(pred.nolog) <- c('pred', 'true.value')


p1 <- ggplot(pred.log, aes(x = pred, y = true.values)) + 
  geom_point(col = 'steelblue') + 
  geom_smooth(method = "lm", linetype = 'dashed', se = FALSE, col = 'darkgreen') + 
  geom_abline(intercept = 0, slope = 1, col = 'red')


p2 <- ggplot(pred.nolog, aes(x = pred, y = true.values)) + 
  geom_point(col = 'steelblue') + 
  geom_smooth(method = "lm", linetype = 'dashed', se = FALSE, col = 'darkgreen') + 
  geom_abline(intercept = 0, slope = 1, col = 'red')

grid.arrange(p1, p2)




diff.log <- pred.log[1] - true.values
diff.nolog <- pred.nolog[1] - true.values

dd <- cbind(diff.log, diff.nolog)
colnames(dd) <- c('diff.log', 'diff.nolog')


diff.log <- sapply(diff.log[1], function(x) as.double(x) ) 
diff.nolog <- sapply(diff.nolog[1], function(x) as.double(x) ) 

sd(diff.log)
sd(diff.nolog)

# Model 1
s1 <- sd(diff.log)
v1 <- var(diff.log)

# Model 2
s2 <- sd(diff.nolog)
v2 <- var(diff.nolog)

r.sd <- rbind(s1, s2)
r.var <- rbind(v1, v2)

model <- c('Model 1 (log)', 'Model 2 (nolog)')

df <- data.frame(cbind(model, r.sd, r.var))
colnames(df) <- c('Model', 'Standard Deviation', 'Variance')




# for(i in 1:3 ) {
#   pred.cmp <- cbind(pred.cmp, pred.cmp[i] - values.true)
# }

# colnames(pred.cmp) <- c('fit', 'lwr', 'upr', 'true value', 'diff.fit', 'diff.lwr', 'diff.upr')

ggplot(d, aes(x = hp, y = mpg)) +
  geom_smooth(method = "lm", se = FALSE, color = "lightgrey") +  # Plot regression slope
  geom_segment(aes(xend = hp, yend = predicted), alpha = .2) +  # alpha to fade lines
  geom_point() +
  geom_point(aes(y = predicted), shape = 1) +
  theme_bw()  # Add theme for cleaner look


d %>% 
  gather(key = "iv", value = "x", -mpg, -predicted, -residuals) %>%  # Get data into shape
  ggplot(aes(x = x, y = mpg)) +  # Note use of `x` here and next line
  geom_segment(aes(xend = x, yend = predicted), alpha = .2) +
  geom_point(aes(color = residuals)) +
  scale_color_gradient2(low = "blue", mid = "white", high = "red") +
  guides(color = FALSE) +
  geom_point(aes(y = predicted), shape = 1) +
  facet_grid(~ iv, scales = "free") +  # Split panels here by `iv`
  theme_bw()




