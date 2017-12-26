
boring_function <- function(x) {
  x
}

my_mean <- function(my_vector) {
  # Write your code here!
  # Remember: the last expression evaluated will be returned! 
  mean(my_vector)
  
}

remainder <- function(num, divisor = 2) {
  
  value <- (num %% divisor) 
  value
  # Write your code here!
  # Remember: the last expression evaluated will be returned! 
}

evaluate <- function(func, dat){
  
  func(dat)
  # Write your code here!
  # Remember: the last expression evaluated will be returned! 
}


telegram <- function(arg1, arg2){
  paste("START", arg1, arg2, "STOP", sep = " ", collapse = NULL )
}

mad_libs <- function(...){
  # Do your argument unpacking here!
  args <- list(...)
  place <- args[["place"]]
  adjective <- args[["adjective"]]
  noun <- args[["noun"]]
  
  # Don't modify any code below this comment.
  # Notice the variables you'll need to create in order for the code below to
  # be functional!
  paste("News from", place, "today where", adjective, "students took to the streets in protest of the new", noun, "being installed on campus.")
}

"%p%" <- function(left, right){ # Remember to add arguments!
  paste(left, right)
}