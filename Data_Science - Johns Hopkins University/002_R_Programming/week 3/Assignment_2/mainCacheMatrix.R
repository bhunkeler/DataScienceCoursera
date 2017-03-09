# ===============================================================================================
# Description: Assignment 2 
#              These functions are used to create a special object that stores a matrix 
#               and cache's its inverse.# 
#
#
# Authhor:     Bruno Hunkeler 
# Date:        08.11.2015
# ===============================================================================================


# references to functions
#source("cachematrix.R")
source("cm.R")
# source("temp.R")

# library references 

library("MASS")

x <- matrix(1:9, nrow= 3, ncol = 3)
y <- matrix(1:16, nrow= 4, ncol = 4)
x1 <- matrix(1:6, nrow= 2, ncol = 3)
y1 <- matrix(1:10, nrow= 2, ncol = 5)

xInv <- ginv(x) 

# case with cashed 
mat <- makeCacheMatrix(x)
matSetInv <- mat$setInv(xInv)
cmat <- cacheSolve(mat)


# case without cached matrix
matSet <- mat$set(x1)
cmat <- cacheSolve(mat)

matSet <- mat$set(x)
matGet <- mat$get()
matSetInv <- mat$setinverse(x)
matGetInv <- mat$getinverse()

finished <- "finished"


