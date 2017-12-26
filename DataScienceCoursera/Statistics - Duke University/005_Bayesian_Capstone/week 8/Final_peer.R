# ============================================================================================================
# Description:   Course Project week5
#                Coursera Statistics at Duke University
#
# Author:        Bruno Hunkeler
# Date:          xx.04.2017
#
# ============================================================================================================

# install.packages("devtools")
# library('devtools')
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

library('labeling')
require('plyr')         # data manipulation
library('GGally')       # library to create plots
library('grid')         # arrange plots 
library('gridExtra')    # arrange plots
source('helper.R')      # helper functions
library('corrplot')     # correlation plot
library('RColorBrewer') # Color scheme 
library('corrplot')     # correlation plots

# library(parallel)
# library(doParallel)
library('Boruta')
# library('leaps')
library('car')


# ============================================================================================================
# Download and extract Data and load file
# ============================================================================================================


load("Data/ames_train.Rdata")
load("Data/ames_test.Rdata")
load("Data/ames_validation.Rdata")

data.train <- ames_train
data.test <- ames_test
data.validation <- ames_validation

# str(data.train)
# summary(data.train)

# ==========================================================================
# check which features contain NA values

CheckNA(data.train, 2)

# ==========================================================================
# Clean empty fields by adding an NA vaue. Then check for NA values and
# run filling in values for missing data 

data.train <- cleanEmptyFields(data.train, NA)
data.train <- NaHandler(data.train)
CheckNA(data.train, 0)             # This check should reveil no NA values
data.train <- recode.features(data.train)

# NA value handling test data
data.test <- cleanEmptyFields(data.test, NA)
data.test <- NaHandler(data.test)
CheckNA(data.test, 0)              # This check should reveil no NA values
data.test <- recode.features(data.test)

# NA value handling validation data
data.validation <- cleanEmptyFields(data.validation, NA)
data.validation <- NaHandler(data.validation)
CheckNA(data.validation, 0)        # This check should reveil no NA values
data.validation <- recode.features(data.validation)

# ==========================================================================
# Normalize data train 

# df <- finalCleaning(data.train)
# df <- finalCleaning(data.test)
# df <- finalCleaning(data.validation)

dependentVariable <- 'price'

# Normalize training data set and store a original data set
df.train.normalized <- NormalizeDF(data.train, dependentVariable)
df.train.org <- df.train.normalized

# Normalize test data set and store a original data set
df.test.normalized <- NormalizeDF(data.test, dependentVariable)
df.test.org <- df.test.normalized

# Normalize validation data set and store a original data set
data.validation <- data.validation[complete.cases(data.validation), ]
df.validation.normalized <- NormalizeDF(data.validation, dependentVariable)
df.validation.normalized.org <- df.validation.normalized


CheckNA(data.train, TRUE)

# ==========================================================================
# Prep Data sets


df.train      <- data.train
df.test       <- data.test
df.validation <- data.validation

df.train.org  <- df.train
df.test.org   <- df.test

df.train      <- finalCleanUp(df.train)
df.test       <- finalCleanUp(df.test)
df.validation <- finalCleanUp(df.validation)


# ==========================================================================
# Part 1 Exploratory data analysis
# ==========================================================================

# ==========================================================================
# Correlation Plot

correlations = cor(df.train, method = "s")

# only want the columns that show strong correlations with price
corr.price = as.matrix(sort(correlations[,'price'], decreasing = TRUE))

corr.idx = names(which(apply(corr.price, 1, function(x) (x > 0.5 | x < -0.5))))

corrplot(as.matrix(correlations[corr.idx,corr.idx]), type = 'upper', method='color',
         addCoef.col = 'black', tl.cex = .7,cl.cex = .7, number.cex=.7)

# ========================================================================================================
# Histogram


# # show the histogram to verify the distribution 
# p1 <- ggplot(data = df.train, aes(x = price, y = ..density..)) + 
#   geom_histogram(bins = 30, fill = 'steelblue', colour = 'black') +
#   geom_density(size = 1, colour = 'brown') +
#   guides(color = FALSE) +
#   labs(title = "Histogram of house prices", x = 'price', y = "Frequency") 
# 
# # show the histogram to verify the distribution 
# p2 <- ggplot(data = df.train, aes(x = log(price), y = ..density..)) + 
#   geom_histogram(bins = 30, fill = 'steelblue', colour = 'black') +
#   geom_density(size = 1, colour = 'brown') +
#   guides(color = FALSE) +
#   labs(title = "Histogram of house prices", x = 'price', y = "Frequency") 
# 
# grid.arrange(p1, p2)
# 
# # detach("package:plyr", unload=TRUE) 
# 
# summary.Price <- df.train %>% dplyr::summarise(mean_Price   = mean(price),
#                                     median_Price = median(price),
#                                     sd_Price     = sd(price),
#                                     min_Price    = min(price),
#                                     max_Price    = max(price),
#                                     IQR_Price    = IQR(price),
#                                     total = n())
# 
# # show the histogram to verify the distribution 
# p1 <- ggplot(data = df.train, aes(x = X1st.Flr.SF, y = ..density..)) +
#   geom_histogram(bins = 30, fill = 'steelblue', colour = 'black') +
#   geom_density(size = 1, colour = 'brown') +
#   guides(color = FALSE) 

p1 <- ggplot(data = df.train, aes(x = X1st.Flr.SF, y = ..density..)) +
  geom_histogram(bins = 30, fill = 'steelblue', colour = 'black') +
  geom_density(size = 1, colour = 'brown') +
  guides(color = FALSE)

p1.1 <- ggplot(data = df.train, aes(x = log(X1st.Flr.SF), y = ..density..)) +
  geom_histogram(bins = 30, fill = 'steelblue', colour = 'black') +
  geom_density(size = 1, colour = 'brown') +
  guides(color = FALSE)

p2 <- ggplot(data = df.train, aes(x = X2nd.Flr.SF, y = ..density..)) +
  geom_histogram(bins = 30, fill = 'steelblue', colour = 'black') +
  geom_density(size = 1, colour = 'brown') +
  guides(color = FALSE)

p2.1 <- ggplot(data = df.train, aes(x = log(X2nd.Flr.SF), y = ..density..)) +
  geom_histogram(bins = 30, fill = 'steelblue', colour = 'black') +
  geom_density(size = 1, colour = 'brown') +
  guides(color = FALSE)

p3 <- ggplot(data = df.train, aes(x = Lot.Area, y = ..density..)) +
  geom_histogram(bins = 30, fill = 'steelblue', colour = 'black') +
  geom_density(size = 1, colour = 'brown') +
  guides(color = FALSE)

p3.1 <- ggplot(data = df.train, aes(x = log(Lot.Area), y = ..density..)) +
  geom_histogram(bins = 30, fill = 'steelblue', colour = 'black') +
  geom_density(size = 1, colour = 'brown') +
  guides(color = FALSE)


p4 <- ggplot(data = df.train, aes(x = MS.SubClass, y = ..density..)) +
  geom_histogram(bins = 30, fill = 'steelblue', colour = 'black') +
  geom_density(size = 1, colour = 'brown') +
  guides(color = FALSE)

p5 <- ggplot(data = df.train, aes(x = Mas.Vnr.Type, y = ..density..)) +
  geom_histogram(bins = 30, fill = 'steelblue', colour = 'black') +
  geom_density(size = 1, colour = 'brown') +
  guides(color = FALSE)

p6 <- ggplot(data = df.train, aes(x = Mas.Vnr.Area, y = ..density..)) +
  geom_histogram(bins = 30, fill = 'steelblue', colour = 'black') +
  geom_density(size = 1, colour = 'brown') +
  guides(color = FALSE)

p6.1 <- ggplot(data = df.train, aes(x = log(Mas.Vnr.Area), y = ..density..)) +
  geom_histogram(bins = 30, fill = 'steelblue', colour = 'black') +
  geom_density(size = 1, colour = 'brown') +
  guides(color = FALSE)

p7 <- ggplot(data = df.train, aes(x = Garage.Area, y = ..density..)) +
  geom_histogram(bins = 30, fill = 'steelblue', colour = 'black') +
  geom_density(size = 1, colour = 'brown') +
  guides(color = FALSE)

p7.1 <- ggplot(data = df.train, aes(x = log(Garage.Area), y = ..density..)) +
  geom_histogram(bins = 30, fill = 'steelblue', colour = 'black') +
  geom_density(size = 1, colour = 'brown') +
  guides(color = FALSE)

p8 <- ggplot(data = df.train, aes(x = Screen.Porch, y = ..density..)) +
  geom_histogram(bins = 30, fill = 'steelblue', colour = 'black') +
  geom_density(size = 1, colour = 'brown') +
  guides(color = FALSE)

p9 <- ggplot(data = df.train, aes(x = Year.Built, y = ..density..)) +
  geom_histogram(bins = 30, fill = 'steelblue', colour = 'black') +
  geom_density(size = 1, colour = 'brown') +
  guides(color = FALSE)

p10 <- ggplot(data = df.train, aes(x = BsmtFin.SF.1, y = ..density..)) +
  geom_histogram(bins = 30, fill = 'steelblue', colour = 'black') +
  geom_density(size = 1, colour = 'brown') +
  guides(color = FALSE)

p10.1 <- ggplot(data = df.train, aes(x = log(BsmtFin.SF.1), y = ..density..)) +
  geom_histogram(bins = 30, fill = 'steelblue', colour = 'black') +
  geom_density(size = 1, colour = 'brown') +
  guides(color = FALSE)

p11 <- ggplot(data = df.train, aes(x = Pool.Area, y = ..density..)) +
  geom_histogram(bins = 30, fill = 'steelblue', colour = 'black') +
  geom_density(size = 1, colour = 'brown') +
  guides(color = FALSE)

p12 <- ggplot(data = df.train, aes(x = TotRms.AbvGrd, y = ..density..)) +
  geom_histogram(bins = 30, fill = 'steelblue', colour = 'black') +
  geom_density(size = 1, colour = 'brown') +
  guides(color = FALSE)


grid.arrange(p1, p1.1, p2, p.2.1, p3, p3.1)
grid.arrange(p4, p5, p6, p6.1, p7, p7.1)
grid.arrange(p8, p9, p10, p10.1, p11, p12)

# Final.Model <- as.formula( Condition.2 + 
#                             Overall.Qual + Overall.Cond + 
#                             Exter.Qual + 
#                             Bsmt.Qual +  Bsmt.Exposure +
#                              + Bedroom.AbvGr + 
#                             Kitchen.Qual + Fireplaces + 
#                             Garage.Qual 
#                             Pool.QC + Sale.Condition)



# ==========================================================================
# Part 2 Development and assessment of initial model 
# ==========================================================================

# ==========================================================================
# 2.2.1 Initial Model selection 

df.train <- data.train

# df.train <- df.train[-c(428), ]
# df.train <- df.train[-c(310), ]


df.train1 <- df.train[complete.cases(df.train), ]

df.train <- df.train %>% dplyr::select(price, area, Overall.Qual, 
                                       Overall.Cond, Kitchen.Qual, 
                                       Year.Built, Bsmt.Qual, 
                                       Exter.Qual, Garage.Area, 
                                       Lot.Area, Fireplace.Qu)

initial.model  <- as.formula(log(price) ~ log(area) + Overall.Qual + 
                               Overall.Cond + Year.Built + 
                               Exter.Qual +  Bsmt.Qual + 
                               Lot.Area + Kitchen.Qual + 
                               Fireplace.Qu + Garage.Area)

initial.lm.model <- lm(initial.model , data = df.train)
summary(initial.lm.model)

par(mfrow = c(2, 2))
plot(initial.lm.model, which = 4)

predicted.train <- predict(initial.lm.model, df.train)
RMSE.train <- sqrt( mean((df.train$price - exp(predicted.train))^2))
RMSE.train

initial.model1  <- as.formula(price ~ area + Overall.Qual + 
                                Overall.Cond + Year.Built + 
                                Exter.Qual +  Bsmt.Qual + 
                                Lot.Area + Kitchen.Qual + 
                                Fireplace.Qu + Garage.Area)


initial.model1  <- as.formula(initial.model1)
vif(lm(price ~ area + Overall.Qual + 
         Overall.Cond + Year.Built + 
         Exter.Qual +  Bsmt.Qual + 
         Lot.Area + Kitchen.Qual, data = df.train))


initial.lm.model1 <- lm(initial.model1 , data = dd)

predicted.train1 <- predict(initial.lm.model1, df.train)
RMSE.train <- sqrt( mean((df.train$price - predicted.train1)^2))
RMSE.train



# Detect high leverage points

leverage <- hat(model.matrix(initial.lm.model))
plot(leverage, col = 'steelblue')

cook = cooks.distance(leverage)
plot(cook,ylab="Cooks distances")
points(64,cook[64],col='red')


# ==========================================================================
# 2.2.2 Model selection 

# ==========================================================================
# Model selection using AIC

initial.model  <- as.formula(price ~ area + Overall.Qual + 
                               Overall.Cond + Year.Built + 
                               Exter.Qual +  Bsmt.Qual + 
                               Lot.Area + Kitchen.Qual + 
                               Fireplace.Qu + Garage.Area)

lm.model <- lm(initial.model ,
               data = df.train)

model.AIC <- stepAIC(lm.model, k = 2, trace = FALSE)
model.AIC$anova

# ==========================================================================
# Bayesian Model selection

# Bayesian Information Criterion
houses.BIC = bas.lm(initial.model,
                    prior = "BIC",
                    modelprior = uniform(),
                    data = df.train
)
image.bas(houses.BIC, rotate = FALSE)



# # Zellner-Siow Cauchy
# houses.ZS =  bas.lm(price ~ area + Overall.Qual + 
#                       Overall.Cond + Year.Built + 
#                       Exter.Qual + Bsmt.Qual + 
#                       Lot.Area + Kitchen.Qual + 
#                       Fireplace.Qu + Garage.Area, 
#                     df.normalized,
#                     prior = "ZS-null",
#                     modelprior = uniform(),
#                     method = "MCMC", 
#                     MCMC.iterations = 10^6) 
# image.bas(houses.ZS, rotate = FALSE)

# ==========================================================================
# Boruta Model selection

set.seed(13)
boruta.model <- Boruta(initial.model, 
                       df.train,
                       maxRuns = 100, 
                       doTrace=0)
print(boruta.model)
Boruta.Final.model <- getConfirmedFormula(boruta.model)

plot(boruta.model)

boruta.median <- data.frame(attStats(boruta.model)[2])
boruta.result <- cbind(rownames(boruta.median), boruta.median)
colnames(boruta.result) <- c('features', 'medianImpact')

boruta.result <- boruta.result %>% arrange(desc(medianImpact))
boruta.result[1:10,]

# ==========================================================================
# 2.2.3 Initial Model Residuals

ggplot(data = NULL, aes(x = initial.lm.model$fitted, y = initial.lm.model$residuals)) + 
  geom_point(col = 'darkgreen') + 
  # geom_smooth(method = 'loess') + 
  geom_smooth(method = "lm", formula = y ~ splines::bs(x, 3), se = TRUE) + 
  geom_hline(yintercept = 0, linetype = 'dashed', color = 'red')

# ==========================================================================
# 2.2.4 Initial Model RMSE / adj. R Squared

predicted <- predict(initial.lm.model, df.train)

RMSE.w_outliner <- rmse(df.train$price, predicted)
adj.r.squared.w_outliner <- summary(initial.lm.model)$adj.r.squared

# ==========================================================================
# Initial Model selection log(price)

formula.log <- as.formula(log(price) ~ area + Overall.Qual + Overall.Cond + 
                            Kitchen.Qual + Year.Built + Bsmt.Qual + Exter.Qual + 
                            Garage.Area + Lot.Area + Fireplace.Qu)

initial.lm.model.log <- lm(formula.log , data = df.train)
adj.r.squared.log.w_outliner <- summary(initial.lm.model.log)$adj.r.squared

# p3 <- ggplot(data = NULL, aes(x = initial.lm.model.log$fitted, y = initial.lm.model.log$residuals)) + 
#   geom_point(col = 'darkgreen') + 
#   geom_hline(yintercept = 0, linetype = 'dashed', color = 'red')

predicted.log <- predict(initial.lm.model.log, df.train)
RMSE.log.w_outliner <- rmse(df.train$price, exp(predicted.log))

# ==========================================================================
# This part verifies the impact of the most severe outlinersn. 
# So we check for outliners. We remove the outliner and re run model
# Afterwards we compare the RMSE and adjusted R Squared. 

par(mfrow = c(2, 2))
plot(initial.lm.model, col = 'steelblue')

# remove outliner
idx_outliner <- which(abs(resid(initial.lm.model)) == max(abs(resid(initial.lm.model))))
idx_outliner <- unname(idx_outliner)

df.train.noOutliner <- df.train[-c(idx_outliner), ]
# df.train.noOutliner <- df.train

# ==========================================================================
# re run model

initial.lm.model <- lm(initial.model , data = df.train.noOutliner)
adj.r.squared.wo_outliner <- summary(initial.lm.model)$adj.r.squared

# p2 <- ggplot(data = NULL, aes(x = initial.lm.model$fitted, y = initial.lm.model$residuals)) + geom_point(col = 'darkgreen') + 
#   geom_hline(yintercept = 0, linetype = 'dashed', color = 'red')

predicted <- predict(initial.lm.model, df.train.noOutliner)
RMSE.wo_outliner <- rmse(df.train.noOutliner$price, predicted)

# ==========================================================================
# Initial Model selection log(price)

formula.log <- as.formula(log(price) ~ area + Overall.Qual + 
                            Overall.Cond + Kitchen.Qual + Year.Built + 
                            Bsmt.Qual +  Exter.Qual + Garage.Area + 
                            Lot.Area + Fireplace.Qu)

initial.lm.model.log <- lm(formula.log , data = df.train)
adj.r.squared.log.wo_outliner <- summary(initial.lm.model.log)$adj.r.squared

# p4 <- ggplot(data = NULL, aes(x = initial.lm.model.log$fitted, y = initial.lm.model.log$residuals)) + geom_point(col = 'darkgreen') + 
#   geom_hline(yintercept = 0, linetype = 'dashed', color = 'red')

predicted.log <- predict(initial.lm.model.log, df.train.noOutliner)
RMSE.log.wo_outliner <- rmse(df.train.noOutliner$price, exp(predicted.log))

with_outliner <- c(adj.r.squared.w_outliner, RMSE.w_outliner)
without_outliner <- c(adj.r.squared.wo_outliner, RMSE.wo_outliner)
log.with_outliner <- c(adj.r.squared.log.w_outliner, RMSE.log.w_outliner)
log.without_outliner <- c(adj.r.squared.log.wo_outliner, RMSE.log.wo_outliner)  
R_Squared_RMSE <- data.frame(rbind(with_outliner, without_outliner, log.with_outliner, log.without_outliner))

colnames(R_Squared_RMSE) <- c('adj_R_Squared', 'RMSE')

# grid.arrange(p1, p2, p3, p4)

kable(R_Squared_RMSE[1:2], caption = 'adj.R-Squared and RMSE')

# ==========================================================================
# 2.2.5 Overfitting

initial.model  <- as.formula(price ~ area + Overall.Qual + 
                               Overall.Cond + Year.Built + 
                               Exter.Qual +  Bsmt.Qual + 
                               Lot.Area + Kitchen.Qual + 
                               Fireplace.Qu + Garage.Area)

initial.lm.model <- lm(initial.model , data = df.train.org)

predicted.train <- predict(initial.lm.model, df.train)
RMSE.train <- sqrt( mean((df.train$price - predicted.train)^2))
RMSE.train

predicted.test <- predict(initial.lm.model, df.test)
RMSE.test <- sqrt( mean((df.test$price - predicted.test)^2))
RMSE.test

# Remove Overall.Cond from model since this feature does not support
# based on previous anlysis
initial.model.red  <- as.formula(price ~ area + Overall.Qual + 
                               Year.Built + Exter.Qual +  Bsmt.Qual + 
                               Lot.Area + Kitchen.Qual + 
                               Fireplace.Qu + Garage.Area)

initial.lm.model.red <- lm(initial.model.red , data = df.train.org)

predicted.train <- predict(initial.lm.model.red, df.train)
RMSE.train.red <- sqrt( mean((df.train$price - predicted.train)^2))

predicted.test <- predict(initial.lm.model.red, df.test)
RMSE.test.red <- sqrt( mean((df.test$price - predicted.test)^2))

# log transform feature area
initial.model.red.log  <- as.formula(price ~ log(area) + Overall.Qual + 
                                   Year.Built + Exter.Qual +  Bsmt.Qual + 
                                   Lot.Area + Kitchen.Qual + 
                                   Fireplace.Qu + Garage.Area)

initial.lm.model.red.log <- lm(initial.model.red.log , data = df.train.org)

predicted.train <- predict(initial.lm.model.red.log, df.train)
RMSE.train.red.log <- sqrt( mean((df.train$price - predicted.train)^2))

predicted.test <- predict(initial.lm.model.red.log, df.test)
RMSE.test.red.log <- sqrt( mean((df.test$price - predicted.test)^2))

Initial.Model <- c(RMSE.train, RMSE.test)
Reduced.Model <- c(RMSE.train.red, RMSE.test.red)
Reduced.Model.log <- c(RMSE.train.red.log, RMSE.test.red.log)

RMSE.Comp <-data.frame( rbind(Initial.Model, Reduced.Model, Reduced.Model.log))
colnames(RMSE.Comp) <- c('RMSE on train', 'RMSE on test')

kable(RMSE.Comp[1:2], caption = 'RMSE on training and test data')







# df.train.noOutliner <- df.train[-c(310), ]
# 
# 
# initial.model  <- as.formula(price ~ area + Overall.Qual + 
#                                Year.Built + Exter.Qual +  Bsmt.Qual + 
#                                Lot.Area + Kitchen.Qual + 
#                                Fireplace.Qu + Garage.Area)
# 
# initial.lm.model <- lm(initial.model , data = df.train.noOutliner)
# # summary(initial.lm.model)
# 
# 
# predicted.train <- predict(initial.lm.model, df.train.noOutliner)
# RMSE.train <- sqrt( mean((df.train.noOutliner$price - predicted.train)^2))
# RMSE.train
# 
# predicted.test <- predict(initial.lm.model, df.test)
# RMSE.test <- sqrt( mean((df.test$price - predicted.test)^2))
# RMSE.test


# ==========================================================================
# Part 3 Development of final Model
# ==========================================================================

# ==========================================================================
# Model selection using AIC

df.train <- df.train.org

lm.model <- lm(price ~ . ,
               data = df.train)

model.AIC <- stepAIC(lm.model, k = 2, trace = FALSE)
model.AIC$anova

# Final Model: AIC 
AIC.confirmed.model  <- as.formula(price ~ MS.SubClass + Lot.Area + Land.Slope + 
                                 Neighborhood + Condition.2 + Overall.Qual + 
                                 Overall.Cond + Year.Built + Exterior.1st + 
                                 Exterior.2nd + Mas.Vnr.Type + Mas.Vnr.Area + 
                                 Exter.Qual + Exter.Cond + Bsmt.Qual + 
                                 Bsmt.Cond + Bsmt.Exposure + BsmtFin.SF.1 + 
                                 BsmtFin.SF.2 + Bsmt.Unf.SF + Heating.QC + 
                                 X1st.Flr.SF + X2nd.Flr.SF + 
                                 Bsmt.Full.Bath + Bedroom.AbvGr + Kitchen.AbvGr + 
                                 Kitchen.Qual + TotRms.AbvGrd + Fireplaces + 
                                 Garage.Type + Garage.Finish + 
                                 Garage.Area + Garage.Qual + Open.Porch.SF + 
                                 Screen.Porch + Pool.Area + Pool.QC + Sale.Type + 
                                 Sale.Condition)

# ==========================================================================
# Model selection BORUTA 

set.seed(13)
boruta.model <- Boruta(price ~., 
                       df.train,
                       maxRuns = 100, 
                       doTrace=0)
print(boruta.model)
Boruta.Confirmed.model <- getConfirmedFormula(boruta.model)

plot(boruta.model)

Confirmed.model.boruta <- as.formula(price ~ area + MS.SubClass + MS.Zoning + Lot.Frontage + 
                                   Lot.Area + Lot.Shape + Neighborhood + Bldg.Type + 
                                   House.Style + Overall.Qual + Overall.Cond + Year.Built + 
                                   Year.Remod.Add + Exterior.1st + Exterior.2nd + Mas.Vnr.Type + 
                                   Mas.Vnr.Area +  Exter.Qual + Foundation + Bsmt.Qual + Bsmt.Exposure + 
                                   BsmtFin.Type.1 + BsmtFin.SF.1 + Bsmt.Unf.SF + Total.Bsmt.SF + 
                                   Heating.QC + Central.Air + X1st.Flr.SF + X2nd.Flr.SF + Bsmt.Full.Bath + 
                                   Full.Bath + Half.Bath + Bedroom.AbvGr +  Kitchen.AbvGr + Kitchen.Qual + 
                                   TotRms.AbvGrd + Fireplaces + Fireplace.Qu + Garage.Type + Garage.Yr.Blt + 
                                   Garage.Finish + Garage.Cars + Garage.Area + Garage.Qual + Garage.Cond + 
                                   Paved.Drive + Wood.Deck.SF + Open.Porch.SF + Screen.Porch)

boruta.median <- data.frame(attStats(boruta.model)[2])
boruta.result <- cbind(rownames(boruta.median), boruta.median)
colnames(boruta.result) <- c('features', 'medianImpact')

boruta.result <- boruta.result %>% arrange(desc(medianImpact))
boruta.result[1:20,]





# ==========================================================================
# 3.1 Final Model

# Bayesian Information Criterion
houses.BIC = bas.lm(price~ .,
                    prior = "BIC",
                    modelprior = uniform(),
                    data = df.train
)
image.bas(houses.BIC, rotate = FALSE)

# Zellner-Siow Cauchy
houses.ZS =  bas.lm(Boruta.Confirmed.model, 
                    df.train,
                    prior="ZS-null",
                    modelprior=uniform(),
                    method = "MCMC", 
                    MCMC.iterations = 10^6) 
image.bas(houses.ZS, rotate = FALSE)

# Model Selection based on Boruta
Final.Model.Boruta <- as.formula(price ~ area + Lot.Area + Bldg.Type + 
                                Overall.Qual + Overall.Cond + Year.Built + 
                                Mas.Vnr.Area + Exter.Qual + BsmtFin.SF.1 + 
                                Total.Bsmt.SF + Bedroom.AbvGr + Kitchen.Qual + 
                                TotRms.AbvGrd + Fireplace.Qu + Garage.Area + 
                                Garage.Qual + Screen.Porch)

# Bayesian Information Criterion
houses.BIC = bas.lm(AIC.confirmed.model,
                    prior = "BIC",
                    modelprior = uniform(),
                    data = df.train
)
image.bas(houses.BIC, rotate = FALSE)

# Zellner-Siow Cauchy
houses.ZS =  bas.lm(AIC.confirmed.model, 
                    df.train,
                    prior="ZS-null",
                    modelprior=uniform(),
                    method = "MCMC", 
                    MCMC.iterations = 10^6) 
image.bas(houses.ZS, rotate = FALSE)

# Model Selection based on AIC
Final.Model.AIC <- as.formula(price ~Lot.Area + MS.SubClass + Condition.2 + 
                               Overall.Qual + Overall.Cond + Year.Built + 
                               Mas.Vnr.Type + Mas.Vnr.Area + Exter.Qual + 
                               Bsmt.Qual +  Bsmt.Exposure + BsmtFin.SF.1 + 
                               X1st.Flr.SF + X2nd.Flr.SF + Bedroom.AbvGr + 
                               Kitchen.Qual + TotRms.AbvGrd + Fireplaces + 
                               Garage.Area + Garage.Qual + Screen.Porch + 
                               Pool.Area + Pool.QC + Sale.Condition)




# ==========================================================================
# Evaluation 

houses.BIC.model1 = bas.lm(Final.Model.Boruta,
                    prior = "BIC",
                    modelprior = uniform(),
                    data = df.train
)

# plot.bas(houses.BIC.model1)

# Zellner-Siow Cauchy
houses.ZS.model1 =  bas.lm(Final.Model.Boruta, 
                    df.train,
                    prior="ZS-null",
                    modelprior=uniform(),
                    method = "MCMC", 
                    MCMC.iterations = 10^6) 
# plot.bas(houses.ZS.model1)

houses.BIC.model2 = bas.lm(Final.Model.AIC,
                    prior = "BIC",
                    modelprior = uniform(),
                    data = df.train
)

# plot.bas(houses.BIC.model2)

# Zellner-Siow Cauchy
houses.ZS.model2 =  bas.lm(Final.Model.AIC, 
                    df.train,
                    prior="ZS-null",
                    modelprior=uniform(),
                    method = "MCMC", 
                    MCMC.iterations = 10^6) 
plot.bas(houses.ZS.model2)

predicted.BIC.model1 <- predict.bas(houses.BIC.model1, df.test)
predicted.ZS.model1 <- predict.bas(houses.ZS.model1, df.test)
predicted.BIC.model2 <- predict.bas(houses.BIC.model2, df.test)
predicted.ZS.model2 <- predict.bas(houses.ZS.model2, df.test)

rmse.bic.model1 <- rmse(df.test$price, predicted.BIC.model1$Ybma)
rmse.ZS.model1 <- rmse(df.test$price, predicted.ZS.model1$Ybma)
rmse.bic.model2 <- rmse(df.test$price, predicted.BIC.model2$Ybma)
rmse.ZS.model2 <- rmse(df.test$price, predicted.ZS.model2$Ybma)

RMSE <- data.frame(rbind(rmse.bic.model1, rmse.ZS.model1, rmse.bic.model2, rmse.ZS.model2))
colnames(RMSE) <- c('RMSE')

kable(RMSE[1:1], caption = 'RMSE')


houses.BIC.model2 = lm(Final.Model.AIC,
                           data = df.train
)

par(mfrow = c(2, 2))
plot(houses.BIC.model2, col = 'steelblue')

# remove outliner
idx_outliner <- which(abs(resid(houses.BIC.model2)) == max(abs(resid(houses.BIC.model2))))
idx_outliner <- unname(idx_outliner)

df.train <- df.train[-c(idx_outliner), ]

# ==========================================================================
# 3.2 Transformation

df.train <- df.train.org

# No transformation 
Final.Model.no <- as.formula(price ~ Lot.Area + MS.SubClass + Condition.2 + 
                            Overall.Qual + Overall.Cond + Year.Built + 
                            Mas.Vnr.Type + Mas.Vnr.Area + Exter.Qual + 
                            Bsmt.Qual +  Bsmt.Exposure + BsmtFin.SF.1 + 
                            X1st.Flr.SF + X2nd.Flr.SF + Bedroom.AbvGr + 
                            Kitchen.Qual + TotRms.AbvGrd + Fireplaces + 
                            Garage.Area + Garage.Qual + Screen.Porch + 
                            Pool.Area + Pool.QC + Sale.Condition)

# response variable transformation
Final.Model <- as.formula(log(price) ~ Lot.Area + MS.SubClass + Condition.2 + 
                                Overall.Qual + Overall.Cond + Year.Built + 
                                Mas.Vnr.Type + Mas.Vnr.Area + Exter.Qual + 
                                Bsmt.Qual +  Bsmt.Exposure + BsmtFin.SF.1 + 
                                X1st.Flr.SF + X2nd.Flr.SF + Bedroom.AbvGr + 
                                Kitchen.Qual + TotRms.AbvGrd + Fireplaces + 
                                Garage.Area + Garage.Qual + Screen.Porch + 
                                Pool.Area + Pool.QC + Sale.Condition)

# price lot.area and  X1st.Flr.SF variable transformation
Final.Model.log <- as.formula(log(price) ~ log(Lot.Area) + MS.SubClass + Condition.2 + 
                            Overall.Qual + Overall.Cond + Year.Built + 
                            Mas.Vnr.Type + log(Mas.Vnr.Area) + Exter.Qual + 
                            Bsmt.Qual +  Bsmt.Exposure + BsmtFin.SF.1 + 
                            log(X1st.Flr.SF) + X2nd.Flr.SF + Bedroom.AbvGr + 
                            Kitchen.Qual + TotRms.AbvGrd + Fireplaces + 
                            Garage.Area + Garage.Qual + Screen.Porch + 
                            Pool.Area + Pool.QC + Sale.Condition)

# Model Selection based on AIC
Final.Model.red <- as.formula(price ~ Lot.Area + Lot.Area + MS.SubClass + Condition.2 + 
                                Overall.Qual + Overall.Cond + Year.Built + 
                                Mas.Vnr.Type + Mas.Vnr.Area + Exter.Qual + 
                                Bsmt.Qual +  Bsmt.Exposure + BsmtFin.SF.1 + 
                                X1st.Flr.SF + X2nd.Flr.SF + Bedroom.AbvGr + 
                                Kitchen.Qual + TotRms.AbvGrd + Fireplaces + 
                                Garage.Area + Garage.Qual + Screen.Porch + 
                                Sale.Condition)

houses.BIC.no = bas.lm(Final.Model.no,
                    prior = "BIC",
                    modelprior = uniform(),
                    data = df.train
)

houses.BIC = bas.lm(Final.Model,
                    prior = "BIC",
                    modelprior = uniform(),
                    data = df.train
)

houses.BIC.log = bas.lm(Final.Model.log,
                    prior = "BIC",
                    modelprior = uniform(),
                    data = df.train
)

# Zellner-Siow Cauchy
houses.ZS.red =  bas.lm(Final.Model.red, 
                       df.train,
                       prior="ZS-null",
                       modelprior=uniform(),
                       method = "MCMC", 
                       MCMC.iterations = 10^6) 
# Zellner-Siow Cauchy
houses.ZS.no =  bas.lm(Final.Model.no, 
                    df.train,
                    prior="ZS-null",
                    modelprior=uniform(),
                    method = "MCMC", 
                    MCMC.iterations = 10^6) 

# Zellner-Siow Cauchy
houses.ZS =  bas.lm(Final.Model, 
                    df.train,
                    prior="ZS-null",
                    modelprior=uniform(),
                    method = "MCMC", 
                    MCMC.iterations = 10^6) 
# Zellner-Siow Cauchy
houses.ZS.log =  bas.lm(Final.Model.log, 
                    df.train,
                    prior="ZS-null",
                    modelprior=uniform(),
                    method = "MCMC", 
                    MCMC.iterations = 10^6) 

lm.houses.no <- lm(Final.Model.no, df.test)
lm.houses <- lm(Final.Model, df.test)
lm.houses.log <- lm(Final.Model.log, df.test)

predict.lm.no <- predict(lm.houses.no, df.test)
predict.lm <- predict(lm.houses, df.test)
predict.lm.log <- predict(lm.houses.log, df.test)

rmse.lm.no <- rmse(df.test$price, predict.lm)
rmse.lm.no
rmse.lm <- rmse(df.test$price, predict.lm)
rmse.lm
rmse.lm.log <- rmse(df.test$price, predict.lm.log)
rmse.lm.log


predicted.BIC.no <- predict.bas(houses.BIC.no, df.test)
predicted.BIC <- predict.bas(houses.BIC, df.test)
predicted.BIC.log <- predict.bas(houses.BIC.log, df.test)

predicted.ZS.red <- predict.bas(houses.ZS.red, df.test)
predicted.ZS.no <- predict.bas(houses.ZS.no, df.test)
predicted.ZS <- predict.bas(houses.ZS, df.test)
predicted.ZS.log <- predict.bas(houses.ZS.log, df.test)

rmse.bic.no <- rmse(df.test$price, predicted.BIC.no$Ybma)
rmse.bic <- rmse(df.test$price, predicted.BIC$Ybma)
rmse.bic.log <- rmse(df.test$price, predicted.BIC.log$Ybma)

rmse.ZS.red <- rmse(df.test$price, predicted.ZS.red$Ybma)
rmse.ZS <- rmse(df.test$price, predicted.ZS$Ybma)
rmse.ZS.no <- rmse(df.test$price, predicted.ZS.no$Ybma)
rmse.ZS.log <- rmse(df.test$price, predicted.ZS.log$Ybma)

rmse.lm.no <- rmse(df.test$price, prdict.lm)
rmse.lm <- rmse(df.test$price, prdict.lm)
rmse.lm.log <- rmse(df.test$price, prdict.lm.log)

RMSE <- data.frame(rbind(rmse.bic.no, rmse.ZS.no, rmse.bic, rmse.ZS, rmse.bic.log, rmse.ZS.log, rmse.lm, rmse.lm.log))
colnames(RMSE) <- c('RMSE')

kable(RMSE[1:1], caption = 'RMSE')

# plot(houses.BIC)
# plot(houses.BIC.log)
# plot(houses.ZS)
# plot(houses.ZS.log)

ggplot(data = NULL, aes(x = lm.houses$fitted, y = lm.houses$residuals)) +
  geom_point(col = 'darkgreen') +
  geom_hline(yintercept = 0, linetype = 'dashed', color = 'red')

ggplot(data = NULL, aes(x = lm.houses.log$fitted, y = lm.houses.log$residuals)) +
  geom_point(col = 'darkgreen') +
  geom_hline(yintercept = 0, linetype = 'dashed', color = 'red')


df.test <- df.test.org
# df.train <- df.train[-c(310), ]


# Model Selection 
Final.Model.base <- as.formula(price ~ Lot.Area + Lot.Area + MS.SubClass + Condition.2 + 
                                 Overall.Qual + Overall.Cond + Year.Built + 
                                 Mas.Vnr.Type + Mas.Vnr.Area + Exter.Qual + 
                                 Bsmt.Qual +  Bsmt.Exposure + BsmtFin.SF.1 + BsmtFin.SF.1 + 
                                 X1st.Flr.SF + X2nd.Flr.SF + Bedroom.AbvGr + 
                                 Kitchen.Qual + TotRms.AbvGrd + Fireplaces + 
                                 Garage.Area + Garage.Qual + Screen.Porch + 
                                 Sale.Condition)

# Zellner-Siow Cauchy
houses.ZS.base =  bas.lm(Final.Model.base, 
                         df.train,
                         prior="ZS-null",
                         modelprior=uniform(),
                         method = "MCMC", 
                         MCMC.iterations = 10^6) 


# Model Selection 
Final.Model2 <- as.formula(price ~ Lot.Area + I(Lot.Area^2) + MS.SubClass + Condition.2 + 
                             Overall.Qual + Overall.Cond + Year.Built + 
                             Mas.Vnr.Type + Mas.Vnr.Area + Exter.Qual + 
                             Bsmt.Qual +  Bsmt.Exposure + BsmtFin.SF.1 + I(BsmtFin.SF.1^2) + 
                             I(X1st.Flr.SF^2) + I(X2nd.Flr.SF^2) + I(Bedroom.AbvGr^2) + 
                             Kitchen.Qual + TotRms.AbvGrd + Fireplaces + 
                             Garage.Area + Garage.Qual + Screen.Porch + 
                             Sale.Condition)


# Zellner-Siow Cauchy
houses.ZS2 =  bas.lm(Final.Model2, 
                     df.train,
                     prior="ZS-null",
                     modelprior=uniform(),
                     method = "MCMC", 
                     MCMC.iterations = 10^6) 

plot(houses.ZS2, which = 1)

predicted.ZS.base<- predict.bas(houses.ZS.base, df.test)
predicted.ZS2 <- predict.bas(houses.ZS2, df.test)

prediction <- data.frame(cbind( predicted.ZS.base$Ybma, predicted.ZS2$Ybma))
prediction <- cbind(prediction, df.test$price)
names(prediction) <- c('SQR_Model', 'Base_Model', 'Price')


rmse.ZS.base <- rmse(df.test$price, predicted.ZS.base$Ybma)
rmse.ZS2 <- rmse(df.test$price, predicted.ZS2$Ybma)

RMSE <- data.frame(rbind(rmse.ZS.base, rmse.ZS2))
colnames(RMSE) <- c('RMSE')

kable(RMSE[1:1], caption = 'RMSE')


# ==========================================================================
# 2.3.3 Variable Interaction

dependentVariable <- 'price'

# Normalize training data set and store a original data set
df.train <- NormalizeDF(data.train, dependentVariable)
df.train.org <- df.train

# Normalize test data set and store a original data set
df.test <- NormalizeDF(data.test, dependentVariable)
df.test.org <- df.test

# Normalize validation data set and store a original data set
df.validation <- NormalizeDF(data.validation, dependentVariable)
df.validation.org <- df.validation






# Residential vs. nonresidential seems to be only relevant aspect of zoning
zo <- as.character(df$MSZoning)
res_zone <- c( "FV", "RH", "RL", "RP", "RM" )
df$Residential <- ifelse( zo %in% res_zone, 1, 0 )
df$MSZoning <- NULL

# Get rid of RoofMatl. It is an overfit dummy for one case.
# Earlier analysis showed all levels got OLS coefficients that were
# very significantly different from zero but not different from one another.
# "ClyTile" was the omitted category and was only one case.
df$RoofMatl <- NULL

# Get rid of MiscFeature. Per earlier analysis, it's a mess. Don't want to deal with it.
df$MiscFeature <- NULL

# Factors that earlier analyses didn't like and too much of a pain in the neck to keep
df$Fence <- NULL
df$RoofStyle <- NULL
df$Heating <- NULL

# I didn't see any residual seasonal pattern, so:
df$MoSold <- NULL

# These nonlinearitiesn seem to matter
df$LotFrontage2 <- df$LotFrontage^2
df$SinceRemod <- df$YrSold - df$YearRemodAdd
df$SinceRemod2 <- df$SinceRemod^2
df$YrSold <- NULL
df$YearRemodAdd <- NULL
df$BsmtFinSF1sq <- df$BsmtFinSF1^2

# The following turn out to be redundant. But may want to bring them back later.
df$TotalBsmtSF <- NULL
df$HasMasVnr <- NULL
df$KitchenAbvGr_r <- NULL
df$GarageCond.n_r <- NULL






# ==========================================================================
# 2.3.4 Variable Selection


# ==========================================================================
# 2.3.5 Model Testing


# ==========================================================================
# Part 4 Final Model Assessment
# ==========================================================================


# ==========================================================================
# 2.4.1 Final Model RMSE


# ==========================================================================
# 2.4.2 Final Model Evaluation
df.train <- df.train.org

 df.train <- df.train[-c(428), ]
 df.train <- df.train[-c(310), ]
# df.train <- df.train[-c(276), ]
# df.train <- df.train[-c(613), ]
# df.train <- df.train[-c(615), ]
# df.train <- df.train[-c(406), ]


# Model Selection 
Final.Model.base <- as.formula(price ~ Lot.Area + Lot.Area + MS.SubClass + Condition.2 + 
                                 Overall.Qual + Overall.Cond + Year.Built + 
                                 Mas.Vnr.Type + Mas.Vnr.Area + Exter.Qual + 
                                 Bsmt.Qual +  Bsmt.Exposure + BsmtFin.SF.1 + BsmtFin.SF.1 + 
                                 X1st.Flr.SF + X2nd.Flr.SF + Bedroom.AbvGr + 
                                 Kitchen.Qual + TotRms.AbvGrd + Fireplaces + 
                                 Garage.Area + Garage.Qual + Screen.Porch + 
                                 Sale.Condition)

# Zellner-Siow Cauchy
houses.ZS.base =  bas.lm(Final.Model.base, 
                         df.train,
                         prior="ZS-null",
                         modelprior=uniform(),
                         method = "MCMC", 
                         MCMC.iterations = 10^6) 

# Model Selection 
Final.Model.sqr <- as.formula(log(price) ~ log(Lot.Area)  + MS.SubClass + I(Lot.Area^2) +
                                Overall.Qual + Overall.Cond + Condition.2 + 
                                Year.Built + Mas.Vnr.Type + Mas.Vnr.Area + 
                                Exter.Qual + Bsmt.Qual +  Bsmt.Exposure + 
                                BsmtFin.SF.1 + I(BsmtFin.SF.1^2) + 
                                I(X1st.Flr.SF^2) + I(X2nd.Flr.SF^2) + 
                                I(Bedroom.AbvGr^2) + Kitchen.Qual + 
                                TotRms.AbvGrd + Fireplaces + 
                                Garage.Area + Garage.Qual + 
                                Screen.Porch + Sale.Condition)

# Zellner-Siow Cauchy
houses.ZS.sqr =  bas.lm(Final.Model.sqr, 
                        df.train,
                        prior="ZS-null",
                        modelprior=uniform(),
                        method = "MCMC", 
                        MCMC.iterations = 10^6) 

plot(houses.ZS.sqr, which = 1)
par(mfrow = c(2, 2))
plot(houses.ZS.sqr)

predicted.ZS.base<- predict.bas(houses.ZS.base, df.test)
predicted.ZS.sqr <- predict.bas(houses.ZS.sqr, df.test)

prediction <- data.frame(cbind( predicted.ZS.base$Ybma, predicted.ZS.sqr$Ybma))
prediction <- cbind(prediction, df.test$price)
names(prediction) <- c('SQR_Model', 'Base_Model', 'Price')

rmse.ZS.base <- rmse(df.test$price, predicted.ZS.base$Ybma)
rmse.ZS.sqr <- rmse(df.test$price, predicted.ZS.sqr$Ybma)

RMSE <- data.frame(rbind(rmse.ZS.base, rmse.ZS.sqr))
colnames(RMSE) <- c('RMSE')
RMSE

kable(RMSE[1:1], caption = 'RMSE')


# ==========================================================================
# 2.4.3 Final Model Validation

# Model Selection 
Final.Model.sqr <- as.formula(price ~ Lot.Area + I(Lot.Area^2) + MS.SubClass + 
                                Condition.2 + Overall.Qual + Overall.Cond + 
                                Year.Built + Mas.Vnr.Type + Mas.Vnr.Area + 
                                Exter.Qual + Bsmt.Qual +  Bsmt.Exposure + 
                                BsmtFin.SF.1 + I(BsmtFin.SF.1^2) + 
                                I(X1st.Flr.SF^2) + I(X2nd.Flr.SF^2) + 
                                I(Bedroom.AbvGr^2) + Kitchen.Qual + 
                                TotRms.AbvGrd + Fireplaces + 
                                Garage.Area + Garage.Qual + 
                                Screen.Porch + Sale.Condition)

# Zellner-Siow Cauchy
houses.ZS.sqr =  bas.lm(Final.Model.sqr, 
                        df.train,
                        prior="ZS-null",
                        modelprior=uniform(),
                        method = "MCMC", 
                        MCMC.iterations = 10^6) 

predicted.ZS.sqr <- predict.bas(houses.ZS.sqr, df.validation)
rmse.ZS <- rmse(df.validation$price, predicted.ZS.sqr$Ybma)

RMSE <- data.frame(rbind(rmse.ZS))
colnames(RMSE) <- c('RMSE')

kable(RMSE[1:1], caption = 'RMSE')




# ==========================================================================
# Part 5 Conclusion
# ==========================================================================








