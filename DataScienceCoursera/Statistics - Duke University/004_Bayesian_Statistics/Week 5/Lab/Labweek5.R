# ============================================================================================================
# Description:   Course Project Week 1 / LabWeek 1
#                Coursera Statistics at Duke University
#
# Author:        Bruno Hunkeler
# Date:          xx.07.2016
#
# ============================================================================================================

# install.packages("devtools")
# devtools::install_github("StatsWithR/statsr")

# ============================================================================================================
# Load Libraries
# ============================================================================================================

library('ggplot2')      # library to create plots
library('dplyr')        # data manipulation
library('tidyr')
library('statsr')       # staistics functions
library('BAS')          # Bayesian statistics functions
library('GGally')       # library to create plots
library('knitr')        # required to apply knitr options
library('grid')         # arrange plots
library('gridExtra')    # arrange plots
source('Utilities.R')   # support functions used in the analysis - See Appendix


# ============================================================================================================
# Download and extract Data and load file
# ============================================================================================================

load("Data/movies.Rdata")
data <- movies

# evaluate the size of the dataset
dim(data)

# verify types and summary of each variable
str(data)
summary(data)

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

# ============================================================================================================
# Exploratory Data Analysis
# ============================================================================================================

# 3. EDA: (9 points)
# Perform exploratory data analysis (EDA) of the relationship between audience_score and the new
# variables constructed in the previous part. # Your EDA should contain numerical summaries and visualizations.
# This might mean you initially create a lot more visualizations and summary statistics than
# what you finally choose to include in your paper. Each R output and plot should be accompanied by a brief interpretation.

Col <-
  c(
    'audience_score',
    'oscar_season',
    'summer_season',
    'mpaa_rating_R',
    'drama',
    'feature_film'
  )


# Create a new dataset to explicitely show dataset containing NA's
data.analysis <- data[, Col]

# remove NA's
data.analysis <- na.omit(data.analysis)
# data.final <- data[complete.cases(data), ]
hist(
  data.analysis$audience_score,
  breaks = 40,
  main = 'audience score',
  col = 'steelblue'
)


data.grouped <- gather(data.analysis, 'features', 'flag', 2:6)


p1 <- ggplot(data = data.analysis, aes(x = summer_season, y = audience_score, fill = summer_season)) + geom_boxplot() + 
      ggtitle('Audience score vs summer season') +
      xlab('summer season') + ylab('Audience Score') +
      scale_fill_brewer(name = "summer season")

p2 <- ggplot(data = data.analysis, aes(x = oscar_season, y = audience_score, fill = oscar_season)) + geom_boxplot() + 
  ggtitle('Audience score vs oscar_season') +
  xlab('oscar_season') + ylab('Audience Score') +
  scale_fill_brewer(name = "oscar_season")

p3 <- ggplot(data = data.analysis, aes(x = drama, y = audience_score, fill = drama)) + geom_boxplot() + 
  ggtitle('Audience score vs drama') +
  xlab('drama') + ylab('Audience Score') +
  scale_fill_brewer(name = "drama")

p4 <- ggplot(data = data.analysis, aes(x = feature_film, y = audience_score, fill = feature_film)) + geom_boxplot() + 
  ggtitle('Audience score vs feature_film') +
  xlab('feature_film') + ylab('Audience Score') +
  scale_fill_brewer(name = "feature_film")

p5 <- ggplot(data = data.analysis, aes(x = mpaa_rating_R, y = audience_score, fill = mpaa_rating_R)) + geom_boxplot() + 
  ggtitle('Audience score vs mpaa_rating_R') +
  xlab('mpaa_rating_R') + ylab('Audience Score') +
  scale_fill_brewer(name = "mpaa_rating_R")


grid.arrange(p1, p2, p3, p4, p5, ncol = 2)


ggplot(data = data.grouped, aes(x = features, y = audience_score, fill = flag)) + geom_boxplot() + 
  ggtitle('Audience score vs grouped featues') +
  xlab('grouped featues' ) + ylab('Audience Score') +
  theme(axis.text.x = element_text(angle = 60, hjust = 1)) +
  scale_fill_brewer(name = "grouped featues")


summary(data.analysis$audience_score)

mean(data.analysis$audience_score)
median(data.analysis$audience_score)
max(data.analysis$audience_score)

# Plot the density function of the audience_score
  
  ggplot(data = data.analysis, aes(x = audience_score, y = ..density..)) +
    geom_histogram(bins = 30, fill='#deebf7', colour='#bdbdbd') +
    geom_density(size=1, colour='#cccccc') +
    geom_vline(data = data.analysis, mapping = aes(xintercept = mean(data.analysis$audience_score), colour = 'steelblue', show_guide = F)) +
    geom_vline(data = data.analysis, mapping = aes(xintercept = median(data.analysis$audience_score), colour = 'red', show_guide = F)) +
    geom_vline(data = data.analysis, mapping = aes(xintercept = max(data.analysis$audience_score), colour = 'green', show_guide = F)) +
    geom_text(data = data.analysis, aes( x = (mean(data.analysis$audience_score) - 5), y =.020, label = 'mean', colour = 'steelblue'), size = 4, parse = T) + 
    geom_text(data = data.analysis, aes( x = (median(data.analysis$audience_score) + 5), y =.020, label = 'median', colour = 'red'), size = 4, parse = T) +
    geom_text(data = data.analysis, aes( x = (max(data.analysis$audience_score) + 5), y =.020, label = 'mode', colour = 'green'), size = 4, parse = T)

  
  # df_vline <- rbind(
  #   aggregate(pm[1], pm[2], quantile, .8), 
  #   aggregate(pm[1], pm[2], median)
  # )
  # df_vline$stat <- rep(c("percentil .8", "mediana"), each = nrow(df_vline) / 2)  
  # 
  #   
  # ggplot(data=pm, aes(x=pm10, y=..density..)) +
  #   geom_histogram(bin=15, fill='#deebf7', colour='#bdbdbd')+
  #   geom_density(size=1, colour='#cccccc')+
  #   geom_vline(data=df_vline, mapping=aes(xintercept=pm10, colour = stat), 
  #              linetype = 1, size=1, show_guide = T)+
  #   geom_text(data=curtosis, aes(x=350, y=.010, label=V1), size=3, parse=T)+
  #   geom_text(data=asimetria, aes(x=350, y=.008, label=V1), size=3, parse=T)+
  #   scale_colour_manual(values = c("#dfc27d","#80cdc1"), name = "Medida de tendencia")+
  #   xlim(0,500)+
  #   facet_wrap(~ estacion, ncol=2) 


  
  
  
  
  
# ============================================================================================================
# Modeling
# ============================================================================================================


# 4. Modeling: (15 points) Develop a Bayesian regression model to predict `audience_score` from the following explanatory variables. Note that some of these variables
# are in the original dataset provided, and others are new variables you constructed earlier:`feature_film`,` drama`, `runtime`, `mpaa_rating_R`, `thtr_rel_year`,
# `oscar_season`, `summer_season`, `imdb_rating`, `imdb_num_votes`, `critics_score`, `best_pic_nom`, `best_pic_win`, `best_actor_win`, `best_actress_win`, `best_dir_win`,
# `top200_box`. Complete Bayesian model selection and report the final model. Also perform model diagnostics and interpret coefficients of your final model in context of the data.

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


    # Create a new dataset to explicitely show dataset containing NA's
    data.model <- data[, features]
    
    # remove NA's
    data.model <- na.omit(data.model)
    
    str(data.model) 
    
    hist(
      data.model$audience_score,
      breaks = 40,
      main = 'audience score',
      col = 'steelblue'
    )
    
    
    p1 <- ggplot(data.model, aes(audience_score, fill = feature_film))
    p1 <- p1 + geom_density(size=1, colour="darkgreen") + labs(title = "Distribution of audience score vs. feature_film") + labs(x = "mpaa rating", y = "Density")
    
    p2 <- ggplot(data.model, aes(audience_score, fill = drama))
    p2 <- p2 + geom_density (alpha = 0.2) + labs(title = "Distribution of audience score vs. drama") + labs(x = "Genre", y = "Density")
    
    p3 <- ggplot(data.model, aes(audience_score, fill = thtr_rel_year))
    p3  <- p5 + geom_density (alpha = 0.2) + labs(title = "Distribution of audience score vs. thtr_rel_year") + labs(x = "Audience rating", y = "Density")
    
    p4 <- ggplot(data.model, aes(audience_score, fill = oscar_season))
    p4 <- p1 + geom_density(size=1, colour="darkgreen") + labs(title = "Distribution of audience score vs. oscar_season") + labs(x = "mpaa rating", y = "Density")
    
    p5 <- ggplot(data.model, aes(audience_score, fill = summer_season))
    p5 <- p2 + geom_density (alpha = 0.2) + labs(title = "Distribution of audience score vs. summer_season") + labs(x = "Genre", y = "Density")
    
    p6 <- ggplot(data.model, aes(audience_score, fill = best_pic_nom))
    p6  <- p5 + geom_density (alpha = 0.2) + labs(title = "Distribution of audience score vs. audience_rating") + labs(x = "Audience rating", y = "Density")
    
    p7 <- ggplot(data.model, aes(audience_score, fill = best_pic_win))
    p7 <- p1 + geom_density(size=1, colour="darkgreen") + labs(title = "Distribution of audience score vs. best_pic_win") + labs(x = "mpaa rating", y = "Density")
    
    p8 <- ggplot(data.model, aes(audience_score, fill = best_actor_win))
    p8 <- p2 + geom_density (alpha = 0.2) + labs(title = "Distribution of audience score vs. best_actor_win") + labs(x = "Genre", y = "Density")
    
    p9 <- ggplot(data.model, aes(audience_score, fill = best_dir_win))
    p9 <- p3 + geom_density (alpha = 0.2) + labs(title = "Distribution of audience score vs. best_dir_win") + labs(x = "Critics rating", y = "Density")
    
    p10 <- ggplot(data.model, aes(audience_score, fill = best_actress_win))
    p10 <- p4 + geom_density (alpha = 0.2) + labs(title = "Distribution of audience score vs. best_actress_win") + labs(x = "Title type", y = "Density")
    
    p11 <- ggplot(data.model, aes(audience_score, fill = top200_box))
    p11  <- p5 + geom_density (alpha = 0.2) + labs(title = "Distribution of audience score vs. top200_box") + labs(x = "Audience rating", y = "Density")
    
    grid.arrange(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, ncol = 2)
    

    dim(data.model)[2]
    formula <- getFormula(data.model, 'audience_score')
    formula
    
    
    # We will use a "prior" that leads to log marginals corresponding to BIC and treat all models as being equally likely a priori.
    
    
    model.audience = bas.lm(
      formula = formula,
      prior = "BIC",
      modelprior = uniform(),
      data = data.model
    )
    
    summary(model.audience)
    model.audience$probne0
    
    p1 <- plot(model.audience, which = 1)  # Residuals vs fitted plot
    p2 <- plot(model.audience, which = 2)  # Model Probabilities
    p3 <- plot(model.audience, which = 3)  # Model complexity
    
    # Coefficient Summaries
    
    model.audience.coef = coef(model.audience)
    model.audience.coef

    
    # Visualization of the Model Space
    # To visualize the space of models (by default the top 20 models in terms of their posterior probabilities), we may use the image function.
    image(model.audience, rotate = FALSE)
    
    myblue = rgb(86, 155, 189, name = "myblue", max = 256)
    mydarkgrey = rgb(.5, .5, .5, name = "mydarkgrey", max = 1)
    par(
      mfrow = c(2, 2),
      col.lab = mydarkgrey,
      col.axis = mydarkgrey,
      col = mydarkgrey
    )
    
    plot(model.audience.coef, subset = 2:4, ask = F)
    
    confint(model.audience.coef)
    # confint(model.audience.coef, parm = 2:17)

    # ===============================================================
    # Zellner-Siow Cauchy prior
    # ===============================================================
    
    audience.ZS =  bas.lm(formula = formula, 
                          data = data.final,
                          prior="ZS-null",
                          modelprior=uniform(),
                          method = "MCMC") 
    
    
    # Estimates of Marginal Posterior Inclusion Probabilities (pip)
    
    myblue = rgb(86,155,189, name="myblue", max=256)
    mydarkgrey = rgb(.5,.5,.5, name="mydarkgrey", max=1)
    plot(audience.ZS$probne0, audience.ZS$probs.MCMC, 
         xlab="pip (renormalized)", ylab="pip (MCMC)", 
         col=myblue,pch=16, cex=1.5, bty="n")
    abline(0,1)
    
    diagnostics(audience.ZS, type="pip", col=myblue, pch=16, cex=1.5)
    
    # model probabilities have converged
    diagnostics(audience.ZS, type="model", col=myblue, pch=16, cex=1.5)
    
    audience.ZS =  bas.lm(formula = formula,  
                          data = data.final,
                          prior = "ZS-null",
                          modelprior = uniform(),
                          method = "MCMC", MCMC.iterations = 10^6)  
    
    image(audience.ZS, rotate = FALSE)
    par(mfrow=c(2,2))
    plot(audience.ZS, ask=F, add.smooth=F, caption="", col.in = 'steelblue', col.ex  = 'darkgrey', pch=17, lwd=2)

    # ---------------------------------------------------------------------------------------------------------
    # AIC Model Selection 
    # ---------------------------------------------------------------------------------------------------------
    
    # The AIC model might not deliver the parsimonious model, but often provides a model, which provides a better 
    # prediction.   
    # We use the backward elimination to find the best model.  
    
    library('MASS')  # Recursive Feature Elimination functions
    lm.AIC <- lm(formula, data = data.model)
    
    aic.model <- stepAIC(lm.AIC, direction = 'backward')
    aic.model$anova  
    
    
 
   audience.AIC =  bas.lm( formula = formula, 
                           data = data.model,
                           prior="AIC",
                           modelprior=uniform(),
                           method = "MCMC", 
                           MCMC.iterations = 10^6)   
    
   image(audience.AIC, rotate = FALSE)
   par(mfrow=c(2,2))
   plot(audience.AIC, ask=F, add.smooth=F, caption="", col.in = 'steelblue', col.ex  = 'darkgrey', pch=17, lwd=2)
   
       
    
   # =========================================================================================================
   # Final Model
   # =========================================================================================================
   
   features <- c( 'audience_score', 'imdb_rating', 'critics_score' )
   
   # Create a new dataset to explicitely show dataset containing NA's
   data.final <- data[, features]
   
   # remove NA's
   data.final<- data.final[complete.cases(data.final), ]
   formula <- getFormula(data.final, 'audience_score')
   
   
   ds <- splitTrainTestSet(data = data.final, 0.6)
   
   df.train <- data.frame(ds$train)
   df.test <- data.frame(ds$test)   
   
   audience.ZS =  bas.lm(formula = formula, 
                         data = data.model,
                         prior = "ZS-null",
                         modelprior = uniform(),
                         method = "MCMC", 
                         MCMC.iterations = 10^6)    
   
   
   # predict()
   
   final.model =  bas.lm(formula = formula, 
                         data = ds$train,
                         prior = "ZS-null",
                         modelprior = uniform(),
                         method = "MCMC", 
                         MCMC.iterations = 10^6)    
   
   predict(final.model, ds$test[2,], interval = "predict")
   

#      <b>highest probability model:</b>
        
      HPM = predict(lm.audience, estimator="HPM")
      
      # show the indices of variables in the best model where 0 is the intercept
     (lm.audience$namesx[HPM$bestmodel +1])[-1]
      
      lm.audience.ZS = coef(lm.audience)
      lm.audience.ZS$conditionalmeans[HPM$best,]
      lm.audience.ZS$conditionalsd[HPM$best,]
      
#      <b>median probability model:</b>
        
      MPM = predict(lm.audience, estimator = "MPM")
      attr(MPM$fit, 'model')
      # show the indices of variables in the best model where 0 is the intercept
      (lm.audience$namesx[attr(MPM$fit, 'model') +1])[-1]
      
      lm.audience.MPM = bas.lm(formula, 
                         data = data.final,
                         prior = "ZS-null",
                         modelprior = uniform(),
                         bestmodel = lm.audience$probne0 > .5, n.models=1) 
      
      coef(lm.audience.MPM)
      
#      best predictive model:      
      
      BPM = predict(lm.audience, estimator = "BPM")
      (lm.audience$namesx[attr(BPM$fit, 'model') +1])[-1]     
      
      myblue = rgb(86,155,189, name="myblue", max=256)
      mydarkgrey = rgb(.5,.5,.5, name="mydarkgrey", max=1)
      par(cex=1.8, cex.axis=1.8, cex.lab=2, mfrow=c(2,2), mar=c(5, 5, 3, 3), col.lab = 'stellblue', col.axis=mydarkgrey, col=mydarkgrey)
      library(GGally)
      ggpairs(data.frame(HPM = as.vector(HPM$fit),  #this used predict so we need to extract fitted values
                         MPM = as.vector(MPM$fit),  # this used fitted
                         # BPM = as.vector(BPM$fit),  # this used fitted
                         BMA = as.vector(BMA$fit))) # this used predict      
      
      # ============================================================================================================
      # uncertainty
      # ============================================================================================================
      
      
      n = nrow(data.final)   
      movie.g = bas.lm(formula, data = data.final, prior = "g-prior",   a=n, modelprior = uniform()) # a is the hyperparameter in this case g=a
      movie.ZS  = bas.lm(formula, data=data.final, prior = "ZS-null",   a=n, modelprior = uniform())
      movie.BIC = bas.lm(formula, data=data.final, prior = "BIC",       a=n, modelprior = uniform())
      movie.AIC = bas.lm(formula, data=data.final, prior = "AIC",       a=n, modelprior = uniform())
      movie.HG  = bas.lm(formula, data=data.final, prior = "hyper-g-n", a=3, modelprior = uniform()) # hyperparameter a=3
      movie.EB  = bas.lm(formula, data=data.final, prior = "EB-local",  a=n, modelprior = uniform())
      
      
      # summary(movie.g)
      # summary(movie.ZS)
      # summary(movie.BIC)
      # summary(movie.AIC)
      # summary(movie.EB)
      # summary(movie.HG)
      
      
      
      probne0 = cbind(movie.BIC$probne0, movie.g$probne0, movie.ZS$probne0, movie.HG$probne0, movie.EB$probne0, movie.AIC$probne0)
      colnames(probne0) = c("BIC","g", "ZS", "HG", "EB", "AIC")
      rownames(probne0) = c(movie.BIC$namesx)
      
      # The matrix probne0 contains all of the marginal inclusion probabilities for each method.
      # probne0
      # 
      # myblue = rgb(86,155,189, name="myblue", max=256)
      # mydarkgrey = rgb(.5,.5,.5, name="mydarkgrey", max=1)
      # 
      # vec <- c(1:5)
      
      for (i in 2:4) {
        barplot(height = probne0[i,], ylim = c(0,1), main = movie.g$namesx[i], col.main = 'darkgrey', col = 'steelblue')
      }
      
      
      
# ============================================================================================================
# Prediction
# ============================================================================================================

# 5. Prediction: (5 points) Pick a movie from 2016 (a new movie that is not in the sample) and do a prediction for this movie using your the model you developed and the
# `predict` function in R.


# ============================================================================================================
# Conclusion
# ============================================================================================================


# 6. Conclusion: (3 points) A brief summary of your findings from the previous sections without repeating your statements from earlier as well as a discussion of what you have
# learned about the data and your research question. You should also discuss any shortcomings of your current study (either due to data collection or methodology) and include
# ideas for possible future research.

# In addition to these parts, there are also 6 points allocated to format, overall organization, and readability of your project. Total points add up to 50 points. See the assessment
# rubric on the Project Files and Rubric page for more details on how your peers will evaluate your work.

# You can begin working on the project immediately. Please save your work as you go along. When you're ready to submit your work for evaluation, remember to click the "Submit" button.

#After you submit your proposal, please provide feedback to others on their projects. Please assess at least 3 projects. This peer assessment will not only provide you with experience
# with a data set and research questions but also prepare for your projects in the future courses in the Specialization.
