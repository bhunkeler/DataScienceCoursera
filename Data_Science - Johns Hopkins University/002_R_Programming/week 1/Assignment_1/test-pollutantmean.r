
## test_that (Wickham) unit test - Programming Assignment 1, Part 1, pollutantmean.R

library("testthat")
context("Calculate the mean of a pollutant across a specified list of monitors")

test_that("match the example output for this function", {
  expect_equal(pollutantmean("specdata", "sulfate",  1:10), 4.064,  tolerance = .0005)
  expect_equal(pollutantmean("specdata", "nitrate", 70:72), 1.706,  tolerance = .0005)
  expect_equal(pollutantmean("specdata", "nitrate",    23), 1.281,  tolerance = .0005)
})
