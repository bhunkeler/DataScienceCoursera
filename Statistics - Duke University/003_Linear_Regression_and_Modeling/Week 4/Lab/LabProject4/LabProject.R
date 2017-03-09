# ============================================================================================================
# Description:   Course Project Week 4 / linear regression model
#                Coursera Statistics at Duke University
#  
#
# Dataset:       
# Information:       
#
# Author:        Bruno Hunkeler
# Date:          xx.078.2016
#
# ============================================================================================================

# ============================================================================================================
# Load Libraries
# ============================================================================================================

library('statsr')
library('ggplot2')    # library to create plots
library('plyr')       # data manipulation
library('dplyr')      # data manipulation
library('GGally')
source('Utilities.R')
library('MASS')
library('grid')
library('gridExtra')


RFE = FALSE

# ============================================================================================================
# Download and extract Data and load file
# ============================================================================================================

# load the data set 
load(file = 'Data/movies.RData')
data <- movies


# ============================================================================================================
# Data Analysis
# ============================================================================================================

# evaluate the size of the data set
dim(data)      # 651  /  32

# suppress this for the moment
# str(data)
# summary(data)

Col <- colnames(data)

# Create a new dataset to explicitely show dataset containing NA's
data.full.na <- data[, Col]

# remove NA's 
data.full <- data.full.na[complete.cases(data.full.na), ]
100 - round(dim(data.full)[1] * 100 / dim(data)[1], 2)
# Around 4% of the data have been removed, which is not unusual, but we are able to preserve even more, if we drop columns, 
# which are not contribute to the final model 

Col <- c('title','title_type','genre','runtime','mpaa_rating','studio','thtr_rel_year','dvd_rel_year','imdb_rating','imdb_num_votes','critics_rating','critics_score','audience_rating','audience_score','best_pic_nom','best_pic_win','best_actor_win','best_actress_win','best_dir_win','top200_box','director')
# Create a new dataset to explicitely show dataset containing NA's
data.full.na <- data[, Col]

# remove NA's 
data.full <- data.full.na[complete.cases(data.full.na), ]
100 - round(dim(data.full)[1] * 100 / dim(data)[1], 2)

# Remove features which do not contribute to the final model
# actor1, actor2 ,actor3 ,actor4 , actor5, imdb_url, rt_url

g <- ggplot(data.full, aes(audience_score))
g + geom_density(size=1, colour="darkgreen") + labs(title = "Distribution of audience score") + labs(x = "Audience score", y = "Density")

p1 <- ggplot(data.full, aes(audience_score, fill = mpaa_rating))
p1 <- p1 + geom_density(size=1, colour="darkgreen") + labs(title = "Distribution of audience score vs. mpaa_rating") + labs(x = "Audience score", y = "Density")

p2 <- ggplot(data.full, aes(audience_score, fill = genre))
p2 <- p2 + geom_density (alpha = 0.2) + labs(title = "Distribution of audience score vs. genres") + labs(x = "genre", y = "Density")

p3 <- ggplot(data.full, aes(audience_score, fill = critics_rating))
p3 <- p3 + geom_density (alpha = 0.2) + labs(title = "Distribution of audience score vs. critics_rating") + labs(x = "critics_rating", y = "Density")

p4 <- ggplot(data.full, aes(audience_score, fill = title_type))
p4 <- p4 + geom_density (alpha = 0.2) + labs(title = "Distribution of audience score vs. title_type") + labs(x = "title_type", y = "Density")

grid.arrange(p1, p2, p3, p4, ncol = 2)


px <- ggplot(data.full, aes(audience_score))
px + geom_histogram(alpha = 0.2) + labs(title = "Distribution of audience score vs. genres") + labs(x = "genre", y = "Density")


ggplot(data.full, aes(audience_score)) +
      geom_histogram(alpha = 0.2, binwidth=2, colour="blue", fill="steelblue") + labs(title = "Distribution of audience score vs. genres") + labs(x = "genre", y = "Density")
 


hist(data.full$audience_score)

# ====================================================================================================
# Data preprocessing 
# ====================================================================================================

# Backward Feature Elimination is a tideous task. Therefore Recoursive Feature Eliminaton (RFE) is a 
# helpfull method in such a case. I used the Boruta Library to achieve the parsimoneous model
if (RFE == TRUE) {
  parameter.final <- featureElimination(data, audiencescore)
}

if(AIC == TRUE){
  Col <- c('title_type','genre','runtime','mpaa_rating','thtr_rel_year','dvd_rel_year','imdb_rating','imdb_num_votes','critics_rating','critics_score','audience_rating','audience_score','best_pic_nom')
  
  data.AIC.na <- data[, Col]

    # remove NA's 
  data.AIC <- data.AIC.na[complete.cases(data.AIC.na), ]
  
  # Create Formula 
  formula <- getFormula(data.AIC, 'audience_score')
  lm.AIC <- lm(formula, data = data.AIC)
  
  parameter.final <- stepAIC(lm.AIC, direction='backward')
  
  
}


cols <- colnames(data)
Col <- c('title_type','genre','runtime','mpaa_rating','thtr_rel_year','dvd_rel_year','imdb_rating','imdb_num_votes','critics_rating','critics_score','audience_rating','audience_score','best_pic_nom')

Col <- c('genre','runtime','dvd_rel_year','imdb_rating','critics_rating','audience_rating','audience_score','best_pic_nom') # adjR2 - 0.8844
Col <- c('genre','runtime','dvd_rel_year','critics_rating','audience_rating','critics_score','audience_score','best_pic_nom') # adjR2 - 0.8092
Col <- c('genre','runtime','dvd_rel_year','imdb_rating','critics_rating','audience_rating','audience_score') # adjR2 - 0.8839
Col <- c('genre','runtime','dvd_rel_year','imdb_rating','imdb_num_votes','critics_score','audience_rating','audience_score','best_pic_nom') # adjR2 - 0.8845
Col <- c('genre','runtime','dvd_rel_year','imdb_num_votes','critics_score','audience_rating','audience_score','best_pic_nom') # adjR2 - 0.816
data.full.na <- data[, Col]
# str(data.full.na)
# summary(data.full.na)

# remove NA's 
data.full <- data.full.na[complete.cases(data.full.na), ]

# Create Formula 
formula <- getFormula(data.full, 'audience_score')
lm.movies <- lm(formula, data.full)

summary(lm.movies)
shrinkage(lm.movies)

# P-values and parameter estimates should only be trusted if the conditions for the regression are reasonable. Using diagnostic plots, 
# we can conclude that the conditions for this model are reasonable. 
par(mfrow = c(1,2))
hist(lm.movies$residuals, col = 'steelblue')
qqnorm(lm.movies$residuals, col = 'darkgreen')
qqline(lm.movies$residuals, col = 'red')


# ====================================================================================================
# Feature Elimination - AIC 
# ====================================================================================================

if(leap == TRUE){
  
   # 'genre','runtime','dvd_rel_year','imdb_num_votes','critics_score','audience_rating','audience_score','best_pic_nom'
  library(leaps)

  data.full.na <- data[, Col]
  data.full <- data.full.na[complete.cases(data.full.na), ]
  
  # Create Formula 
  formula <- getFormula(data.full, 'audience_score')
  
  leaps <- regsubsets(formula, data=data.full, nbest=1,
                               nvmax=NULL, method="backward")
  plot(leaps, scale = "adjr2", main = "Adjusted R^2") 
  
  

}

library('bootstrap')



if(AIC == TRUE){
  Col <- c('genre','runtime','dvd_rel_year','imdb_rating','imdb_num_votes','critics_score','audience_rating','audience_score','best_pic_nom')
  data.AIC.na <- data[, Col]
  # data.AIC.na <- data[, Col]
  data.AIC.na <- data
  
  # remove NA's 
  data.AIC <- data.AIC.na[complete.cases(data.AIC.na), ]
  
  # Create Formula 
  formula <- getFormula(data.AIC, 'audience_score')
  lm.AIC <- lm(formula, data = data.AIC)
  
  stepAIC(lm.AIC, direction='backward')
  
  
}


Col <- c('genre','runtime','dvd_rel_year','imdb_rating','imdb_num_votes','critics_score','audience_rating','audience_score','best_pic_nom')
data.AIC.na <- data[, Col]

# remove NA's 
data.AIC <- data.AIC.na[complete.cases(data.AIC.na), ]

# Create Formula 
formula <- getFormula(data.AIC, 'audience_score')
lm.AIC <- lm(formula, data = data.AIC)


anova(lm.movies, lm.AIC)

Col <- c('runtime','dvd_rel_year','imdb_rating','imdb_num_votes','critics_score')
data.cor <- data.full[, Col]

ggpairs(data.cor, 
        columns=1:5, 
        upper = list(continuous = wrap("cor", size = 4)), 
        lower = list(continuous = "smooth"), 
        title="correlation ",
        colour = "critics_score")

Col <- c('genre','runtime','dvd_rel_year','imdb_num_votes','critics_score','audience_rating','audience_score','best_pic_nom')
data.AIC.cor.na <- data[, Col]

# remove NA's 
data.AIC.cor <- data.AIC.cor.na[complete.cases(data.AIC.cor.na), ]

# Create Formula 
formula <- getFormula(data.AIC.cor, 'audience_score')
lm.AIC.cor <- lm(formula, data = data.AIC.cor)

anova(lm.AIC.cor, lm.AIC)

# These ANOVA tables tell us that there is good reason to drop the 'imdb_rating' feature.


# ====================================================================================================
# PREDICTION
# ====================================================================================================

# audience_score = 76
new.prediction <- data.frame(title_type = 'Feature Film',  genre = 'Drama', runtime = 142, mpaa_rating = 'PG-13', thtr_rel_year = 1986, dvd_rel_year = 2003, imdb_rating =  7.2, imdb_num_votes = 5016, critics_rating = 'Rotten', critics_score = 57, audience_rating = 'Upright', best_pic_nom = 'no')
predict(lm.movies, new.prediction)
predict(lm.movies, new.prediction, interval = "prediction", level = 0.95)

# audience_score = 64
new.prediction <- data.frame(title_type = 'Feature Film',  genre = 'Drama', runtime = 115, mpaa_rating = 'PG-13', thtr_rel_year = 1993, dvd_rel_year = 2004, imdb_rating =  6.7, imdb_num_votes = 22079, critics_rating = 'Fresh', critics_score = 67, audience_rating = 'Upright', best_pic_nom = 'no')
predict(lm.movies, new.prediction)
predict(lm.movies, new.prediction, interval = "prediction", level = 0.95)

# ====================================================================================================
# CORRELATION
# ====================================================================================================

# Verify the correlation between the different features. Only numerical features can be used to calculate the correlation. Therefore, all 
# other features have been removed 
Col <- c('runtime','thtr_rel_year','dvd_rel_year','imdb_rating','imdb_num_votes','critics_score')
data.cor <- data.full[, Col]

ggpairs(data.cor, 
        columns=1:6, 
        upper = list(continuous = wrap("cor", size = 4)), 
        lower = list(continuous = "smooth"), 
        title="correlation ",
        colour = "critics_score")

# ====================================================================================================
# COMPARE MODELS
# ====================================================================================================

Col <- c('title_type','genre','runtime','mpaa_rating','thtr_rel_year','imdb_num_votes','critics_rating','critics_score','audience_rating','audience_score','best_pic_nom')
data.cor.na <- data.full[, Col]
# str(data.full.na)
# summary(data.full.na)

# remove NA's 
data.cor <- data.cor.na[complete.cases(data.cor.na), ]

# Create Formula 
formula <- getFormula(data.cor, 'audience_score')
lm.cor <- lm(formula, data.cor)

par(mfrow = c(1,2))
hist(lm.cor$residuals, col = 'steelblue')
qqnorm(lm.cor$residuals, col = 'darkgreen')
qqline(lm.cor$residuals, col = 'red')

# audience_score = 76
cor.prediction <- data.frame(title_type = 'Feature Film',  genre = 'Drama', runtime = 142, mpaa_rating = 'PG-13', thtr_rel_year = 1986, imdb_num_votes = 5016, critics_rating = 'Rotten', critics_score = 57, audience_rating = 'Upright', best_pic_nom = 'no')
predict(lm.cor, cor.prediction)
predict(lm.cor, cor.prediction, interval = "prediction", level = 0.95)

# audience_score = 64
cor.prediction <- data.frame(title_type = 'Feature Film',  genre = 'Drama', runtime = 115, mpaa_rating = 'PG-13', thtr_rel_year = 1993, imdb_num_votes = 22079, critics_rating = 'Fresh', critics_score = 67, audience_rating = 'Upright', best_pic_nom = 'no')
predict(lm.cor, cor.prediction)
predict(lm.cor, cor.prediction, interval = "prediction", level = 0.95)


cor.prediction <- data.frame( genre = 'Drama', 
                              runtime = 96, 
                              dvd_rel_year = 2017, 
                              imdb_rating = 8.0,
                              imdb_num_votes = 18709, 
                              critics_score = 75, 
                              audience_rating = 'Upright', 
                              best_pic_nom = 'no')
predict(lm.movies, cor.prediction)
predict(lm.movies, cor.prediction, interval = "prediction", level = 0.95)



# ====================================================================================================
# COMPARE MODEL FIT
# ====================================================================================================


# The selection of a final regression model always involves a compromise between predictive accuracy (a model that fits the data
# as well as possible) and parsimony (a simple and replicable model). All things being equal, if you have two models with approximately 
# equal predictive accuracy, you favor the simpler one. This section describes methods for choosing among competing
# models. The word “best” is in quotation marks, because there’s no single criterion you can use to make the decision.

# You can compare the fit of two nested models using the anova() function in the base
# installation. A nested model is one whose terms are completely included in the other
# model. In our states multiple regression model, we found that the regression coefficients
# for Income and Frost were nonsignificant.


# Akaike Information Criterion suggests that the model 1 (lm.movies) is the better fit

# Compare Model fit
anova(lm.movies, lm.cor) 
AIC(lm.movies, lm.cor)  

# extract audience score variable
# y <- data.full[,"audience_score"]

# exclude audience score variable from data set
# x <- data.full[!names(data.full) %in% c("audience_score")]


