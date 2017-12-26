
library('ggplot2')      # library to create plots
library('dplyr')        # data manipulation
library('tidyr')
# library('statsr')       # staistics functions
library('BAS')          # Bayesian statistics functions
# library('GGally')       # library to create plots
library('knitr')        # required to apply knitr options
# library('grid')         # arrange plots
# library('gridExtra')    # arrange plots
source('Utilities.R')   # support functions used in the analysis - See Appendix


# ============================================================================================================
# Download and extract Data and load file
# ============================================================================================================

load("Data/movies.Rdata")
data <- movies



# ============================================================================================================
# Feature Engineering
# ============================================================================================================

# reasign yes or no to feature Oscar_Season, where release month is either  "10", "11", "12"
data <-
  data %>% mutate(oscar_season = as.factor(ifelse(
    thtr_rel_month %in% c('10', '11', '12'), 'yes', 'no'
  )))

# reasign yes or no to feature summer_season, where release month is either  "6", "7", "8"
data <-
  data %>% mutate(summer_season = as.factor(ifelse(
    thtr_rel_month %in% c('6', '7', '8'), 'yes', 'no'
  )))

# reasign yes or no to feature mpaa_rating_R, where mpaa_rating is "R"
data <-
  data %>% mutate(mpaa_rating_R = as.factor(ifelse(mpaa_rating == 'R', 'yes', 'no')))

# reasign yes or no to feature drama, where genre is "drama"
data <-
  data %>% mutate(drama = as.factor(ifelse(genre ==  'Drama', 'yes', 'no')))

# reasign yes or no to feature feature_film, where title_type is "Feature Film"
data <-
  data %>% mutate(feature_film = as.factor(ifelse(title_type ==  'Feature Film', 'yes', 'no')))



features <-
  c(
    'audience_score',
    'feature_film',
    'drama',
    'runtime',
    'mpaa_rating_R',
    'thtr_rel_year',
    'oscar_season',
    'summer_season',
    'imdb_rating',
    'imdb_num_votes',
    'critics_score',
    'best_pic_nom',
    'best_pic_win',
    'best_actor_win',
    'best_actress_win',
    'best_dir_win',
    'top200_box'
  )


features <- c( 'audience_score', 'imdb_rating', 'critics_score' )


# Create a new dataset to explicitely show dataset containing NA's
data.final <- data[, features]

# remove NA's
data.final<- data.final[complete.cases(data.final), ]

# data.final = log(data.final)


ds <- splitTrainTestSet(data = data.final, 0.6)

df.train <- data.frame(ds$train)
df.test <- data.frame(ds$test)   


audience.ZS =  bas.lm(audience_score ~ ., 
                      data = df.train,
                      prior = "ZS-null",
                      modelprior = uniform(),
                      method = "MCMC", 
                      MCMC.iterations = 10^6) 

pred.A <- predict(audience.ZS, newdata = ds$test[2,], estimator = "BPM")
pred.A$Ybma

data.prediction <- data.frame( imdb_rating = 7.6, critics_score = 74, audience_score = 80 )

pred.B <- predict(audience.ZS, newdata = data.prediction, estimator="BMA", interval = "prediction", level = 0.95)
pred.B $Ybma
confint(coefficients(pred.B))

        

