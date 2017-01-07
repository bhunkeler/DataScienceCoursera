
# install.packages('Boruta')
library(Boruta)

# ==============================================================================================================================================
# featureElimination  - will retrieve the formula based on a data set
# 
# Parameter:
#   data  - dataset
#   label - label 
# ==============================================================================================================================================


featureElimination <- function(traindata, response){

# Remove all underscores in names
names(traindata) <- gsub("_", "", names(traindata))

# place NA where empty values exist
traindata[traindata == ""] <- NA
traindata <- traindata[complete.cases(traindata),]

convert <- c(2:6, 11:13)
traindata[,convert] <- data.frame(apply(traindata[convert], 2, as.factor))

set.seed(123)
boruta.train <- Boruta(audiencescore~., data = traindata, doTrace = 2)
# boruta.train <- Boruta(audiencescore~., data = traindata,pValue = 0.05, mcAdj = TRUE, doTrace = 2)
print(boruta.train)


plot(boruta.train, xlab = "", xaxt = "n")

lz<-lapply(1:ncol(boruta.train$ImpHistory),function(i)
  boruta.train$ImpHistory[is.finite(boruta.train$ImpHistory[,i]),i])
names(lz) <- colnames(boruta.train$ImpHistory)
Labels <- sort(sapply(lz,median))
axis(side = 1,las=2,labels = names(Labels),
       at = 1:ncol(boruta.train$ImpHistory), cex.axis = 0.7)

final.boruta <- TentativeRoughFix(boruta.train)
print(final.boruta)

getSelectedAttributes(final.boruta, withTentative = F)
boruta.df <- attStats(final.boruta)
class(boruta.df)
# print(boruta.df)
return(boruta.df)
}

# ==============================================================================================================================================
# getFormula  - will retrieve the formula based on a data set
# 
# Parameter:
#   data  - dataset
#   label - label 
# ==============================================================================================================================================

getFormula <- function(data = data, label = label) {
  
  # label Variable
  labelVar <- label
  
  # separate measure Variable y column from rest 
  groupVariables <- setdiff(colnames(data), list(label))
  
  # create formula for model 
  formula <- as.formula(paste(labelVar, paste(groupVariables, collapse = ' + '), sep = ' ~ '))
  
}

shrinkage <- function(fit, k=10){
  require(bootstrap)
  theta.fit <- function(x,y){lsfit(x,y)}
  theta.predict <- function(fit,x){cbind(1,x)%*%fit$coef}
  x <- fit$model[,2:ncol(fit$model)]
  y <- fit$model[,1]
  results <- crossval(x, y, theta.fit, theta.predict, ngroup=k)
  r2 <- cor(y, fit$fitted.values)^2
  r2cv <- cor(y, results$cv.fit)^2
  cat("Original R-square =", r2, "\n")
  cat(k, "Fold Cross-Validated R-square =", r2cv, "\n")
  cat("Change =", r2-r2cv, "\n")
}


# ==============================================================================================================================================
# dmode  - will retrieve the mode of a given desity function (data) 
# 
# Parameter:
#   vector - label 
# ==============================================================================================================================================

dmode <- function(x) {
  den <- density(x, kernel = c("gaussian"))
  ( den$x[den$y == max(den$y)] )   
}  

# ==============================================================================================================================================
# Computing splitTrainTestSet 
# 
# Split the data set into a training and test set based on the given split ratio
# 
# Parameter:
#   data  - data set
#   split - split ratio
# ==============================================================================================================================================

splitTrainTestSet <- function(data = data, split = 0.5) {
  
  sub <- sample(nrow(data), floor(nrow(data) * split))
  train <- data[sub,]
  test <- data[ - sub,]
  
  split.set <- list(train = train, test = test)
  
  return(split.set)
}
