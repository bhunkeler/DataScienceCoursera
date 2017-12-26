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

# library('dplyr')
library('ggplot2')
library('plyr')
require(caret)

# Define Directory where File is located
dirName <- 'Data'

# load power consumption data
fileName = "states.csv"
fileNameState <- file.path(dirName, fileName)

# data <- read.csv(file = fileNameState, header = TRUE, colClasses = c("character", numeric", "numeric", "numeric", "numeric", "numeric"))
data <- read.csv(file = fileNameState, header = TRUE)

lm.states = lm(poverty ~ female_house, data = data)
summary(lm.states)
anova(lm.states)

lm.states = lm(poverty ~ female_house + white, data = data)
summary(lm.states)
anova(lm.states)



panel.cor <- function(x, y, digits=2, prefix="", cex.cor) 
{
  usr <- par("usr"); on.exit(par(usr)) 
  par(usr = c(0, 1, 0, 1)) 
  r <- abs(cor(x, y)) 
  txt <- format(c(r, 0.123456789), digits=digits)[1] 
  txt <- paste(prefix, txt, sep="") 
  if(missing(cex.cor)) cex <- 0.8/strwidth(txt) 
  
  test <- cor.test(x,y) 
  # borrowed from printCoefmat
  Signif <- symnum(test$p.value, corr = FALSE, na = FALSE, 
                   cutpoints = c(0, 0.001, 0.01, 0.05, 0.1, 1),
                   symbols = c("***", "**", "*", ".", " ")) 
  
  text(0.5, 0.5, txt, cex = cex * r) 
  text(.8, .8, Signif, cex=cex, col=2) 
}

pairs(data, lower.panel = panel.smooth, upper.panel = panel.cor)
