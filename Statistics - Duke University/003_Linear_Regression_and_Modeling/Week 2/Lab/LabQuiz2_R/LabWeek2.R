# ============================================================================================================
# Description:   Course Project Week 2 / LabWeek 2
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

data(mlb11)



multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  require(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}


# ============================================================================================================
# Question 1 
# ============================================================================================================

# Answer: C - Scatterplot

# ============================================================================================================
# Question 2
# ============================================================================================================


ggplot(mlb11, aes(x=at_bats, y=runs)) +
  geom_point() +    
  geom_smooth(method=lm)

# Answer: A - linear

# ============================================================================================================
# Question 3
# ============================================================================================================


# Answer: B - The relationship is positive, linear, and moderately strong. One of the potential outliers is a 
#             team with approximately 5520 at bats.


plot_ss(x = at_bats, y = runs, data = mlb11)
plot_ss(x = at_bats, y = runs, data = mlb11, showSquares = TRUE)

# ============================================================================================================
# Question 4
# ============================================================================================================

# lm.at_bats <- lm(runs ~ at_bats, data = mlb11)
# summary(lm.at_bats)


lm.homeruns <- lm(runs ~ homeruns, data = mlb11)
summary(lm.homeruns)

# y.hat = 415.2389 + 1.8345 * homeruns

y.hat1 = 415.2389 + 1.8345 * 10
y.hat1
y.hat2 = 415.2389 + 1.8345 * 11
y.hat2

y.hat_delta = y.hat2 - y.hat1
y.hat_delta

# Answer: A - For each additional home run, the model predicts 1.83 more runs, on average.

# ============================================================================================================
# Question 5
# ============================================================================================================


y.data <- mlb11 %>%
     filter(at_bats == 5579) %>%
     select(runs)

y.pred <- -2789.2429 + (0.6305 * 5579)

y.data - y.pred

# Answer A: -15.32


# ============================================================================================================
# Question 6
# ============================================================================================================

# Answer B: The residuals show a curved pattern.

# ============================================================================================================
# Question 7
# ============================================================================================================


# Answer D: The residuals are fairly symmetric, with only a slightly longer tail on the right, hence it would 
#           be appropriate to deem the the normal distribution of residuals condition met.

# ============================================================================================================
# Question 8
# ============================================================================================================

# Answer A: TRUE

lm.at_bats <- lm(runs ~ at_bats, data = mlb11)
lm.hits <- lm(runs ~ hits, data = mlb11)
lm.wins <- lm(runs ~ wins, data = mlb11)
lm.bat_avg <- lm(runs ~ bat_avg, data = mlb11)

summary(lm.at_bats)
summary(lm.hits)
summary(lm.wins)
summary(lm.bat_avg)


# Smallest Residual standard error is with lm.bat_avg

# ============================================================================================================
# Question 9
# ============================================================================================================

p1 <- ggplot(data = lm.at_bats, aes(sample = .resid)) +
  ggtitle("lm.at_bats") + 
  stat_qq()

p2 <- ggplot(data = lm.hits, aes(sample = .resid)) +
  ggtitle("lm.hits") + 
  stat_qq()

p3 <- ggplot(data = lm.wins, aes(sample = .resid)) +
  ggtitle("lm.wins") + 
  stat_qq()

p4 <- ggplot(data = lm.bat_avg, aes(sample = .resid)) +
  ggtitle("lm.bat_avg") + 
  stat_qq()

multiplot(p1, p2, p3, p4, cols=2)


# Answer: D bat_avg


# ============================================================================================================
# Question 10
# ============================================================================================================

lm.new_obs <- lm(runs ~ new_obs, data = mlb11)
lm.new_slug <- lm(runs ~ new_slug, data = mlb11)
lm.new_onbase <- lm(runs ~ new_onbase, data = mlb11)

summary(lm.new_obs)
summary(lm.new_slug)
summary(lm.new_onbase)

lm.new_onbase$coefficients
p1 <- ggplot(data = lm.new_obs, aes(sample = .resid)) +
  ggtitle("lm.new_obs") + 
  stat_qq()

p2 <- ggplot(data = lm.new_slug, aes(sample = .resid)) +
  ggtitle("lm.new_slug") + 
  stat_qq()

p3 <- ggplot(data = lm.new_onbase, aes(sample = .resid)) +
  ggtitle("lm.new_onbase") + 
  stat_qq()


multiplot(p1, p2, p3, cols=2)


# Answer A: on-base plus slugging (new_obs)
