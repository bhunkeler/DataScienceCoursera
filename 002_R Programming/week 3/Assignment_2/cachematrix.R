# =================================================================================================
# Description: Assignment 2 - makeCacheMatrix 
#              This function creates a special "matrix" object that can cache its inverse. 
#              The function conatins 4 functions (sections)
#              
#              1) set the value of the matrix
#              2) get the value of the matrix
#              3) setInv the value of the inverse
#              4) getInv the value of the inverse
# 
# Parameter:   mat    - Matrix to cache (invert)
# return:      return - the special matrix 
#
#
# Authhor:     Bruno Hunkeler 
# Date:        08.11.2015
# =================================================================================================

makeCacheMatrix <- function(mat = matrix()) {
  
  inverse <- NULL # initialize  inverse to null
  
  # set the value of the matrix
  set <- function(y) {  
    mat <<- y
    inverse <<- NULL
  }
  
  # return the value of the matrix
  get <- function() {
    mat
  }
  
  #set(cache) the value of the inverse of the matrix
  setInv <- function(cache) {
    inverse <<- cache
  }
  
  #return the value of the inverse of the matrix
  getInv <- function() {
    inverse 
    } 
  
  #return the special matrix
  list(set = set, get = get, setInv = setInv, getInv = getInv)
  
}

# =================================================================================================
# Description: Assignment 2 - cacheSolve 
#              This function computes the inverse of the special "matrix" returned by 
#              makeCacheMatrix above. If the inverse has already been calculated (and the matrix 
#              has not changed), then the cachesolve should retrieve the inverse from the cache.
#              
# Parameter:   mat - matrix
# return:      the cached matrix (inversed) 
#
# Author:      Bruno Hunkeler 
# Date:        08.11.2015
# =================================================================================================


cacheSolve <- function(mat, ...) {
        
  #  First check to see if the inverse has already been calculated.
  inverse <- mat$getInv()
        
  # if the inverse has already been calculated and cached, 
  # return this instance
  if (!is.null(inverse)) {
     
    message("getting the cached matrix")
    return(inverse)
    }
  
  # if it is not cached, calculate it using solve() and cache the matrix,
  # then return it
  inverse <- solve(mat$get(), ...)
  mat$setInv(inverse)
  inverse
}









