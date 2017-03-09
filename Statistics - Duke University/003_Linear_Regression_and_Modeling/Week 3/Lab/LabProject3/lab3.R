# ========================================================================================================================================
# Description:   Course Project 1 / 
#                Coursera Data Science at Duke University
#
#
# Dataset:       
#
# Author:        Bruno Hunkeler
# Date:          xx.xx.2016
#
# ========================================================================================================================================



# ========================================================================================================================================
# Load Libraries
# ========================================================================================================================================

library(statsr)
library(dplyr)
library(ggplot2)
library(GGally)

data(evals)


# ========================================================================================================================================
# Question 1
# ========================================================================================================================================

# Answer: A - Observational study


# ========================================================================================================================================
# Question 2
# ========================================================================================================================================

# Answer: B - Yes, revise wording to “Is there an association between beauty and course evaluations?

# ========================================================================================================================================
# Question 3
# ========================================================================================================================================

dim(evals)

# mean of all scores
median(evals$score)
hist(evals$score)
# percentage of reating > 4.6
100 * dim(evals %>% filter(score > 4.6))[1] / dim(evals)[1]


# percentage of reating < 3
dim(evals %>% filter(score < 3))[1]


# Answer: C - 25\% of the students gave their professors a score of over 4.6.

ggplot(data = evals, aes(x = bty_avg, y = cls_students)) +
  geom_point()

ggplot(data = evals, aes(x = bty_avg, y = cls_students)) +
  geom_jitter()


# ========================================================================================================================================
# Question 4
# ========================================================================================================================================

lm.prof <- lm(score ~ bty_avg, data = evals)
summary(lm.prof)

# Answer: A - true

# ========================================================================================================================================
# Question 5
# ========================================================================================================================================

plot(lm.prof$residuals ~ evals$bty_avg )
hist(lm.prof$residuals)


# Answer: C - Nearly normal residuals: Residuals are right skewed, but the sample size is large, so this may not be an important violation 
#             of conditions.
#         

# ========================================================================================================================================
# Question 6
# ========================================================================================================================================

m_bty_gen <- lm(score ~ bty_avg + gender, data = evals)
summary(m_bty_gen)

hist(m_bty_gen$residuals)
qqnorm(m_bty_gen$residuals)
qqline(m_bty_gen$residuals)

# Answer: A - TRUE

# ========================================================================================================================================
# Question 7
# ========================================================================================================================================

lm.p <- lm(score ~ bty_avg + gender, data = evals)
summary(lm.p)

# Answer: A - TRUE

# ========================================================================================================================================
# Question 8
# ========================================================================================================================================

lm.m_bty_rank <- lm(score ~ bty_avg + rank, data = evals)
summary(lm.m_bty_rank)

# Answer: B - Tenure track, Tenured

# ========================================================================================================================================
# Question 9
# ========================================================================================================================================

newprof <- data.frame(gender = "male", bty_avg = 3)
predict(m_bty_gen, newprof)
predict(m_bty_gen, newprof, interval = "prediction", level = 0.95)


# Answer: B -0.12 points higher than minority professors, all else held constant.

# ========================================================================================================================================
# Question 10
# ========================================================================================================================================

lm.full <- lm(formula = score ~ rank + ethnicity + gender + language + age + cls_perc_eval + cls_students + cls_level + cls_profs + cls_credits + 
           bty_avg + pic_outfit + pic_color, data = evals)

lm.bty_avg <- lm(formula = score ~ rank + ethnicity + gender + language + age + cls_perc_eval + cls_students + cls_level + cls_profs + cls_credits + 
              pic_outfit + pic_color, data = evals)

lm.cls_profs <- lm(formula = score ~ rank + ethnicity + gender + language + age + cls_perc_eval + cls_students + cls_level + cls_credits + 
              bty_avg + pic_outfit + pic_color, data = evals)

lm.cls_students <- lm(formula = score ~ rank + ethnicity + gender + language + age + cls_perc_eval + cls_level + cls_profs + cls_credits + 
              bty_avg + pic_outfit + pic_color, data = evals)

lm.rank <- lm(formula = score ~ ethnicity + gender + language + age + cls_perc_eval + cls_students + cls_level + cls_credits + 
              bty_avg + pic_outfit + pic_color, data = evals)

summary(lm.full)$adj.r.squared
summary(lm.bty_avg)$adj.r.squared
summary(lm.cls_profs)$adj.r.squared
summary(lm.cls_students)$adj.r.squared
summary(lm.rank)$adj.r.squared


# Answer: B - cls_profs

