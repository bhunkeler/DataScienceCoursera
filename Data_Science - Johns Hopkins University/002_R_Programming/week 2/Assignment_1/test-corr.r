
## test_that (Wickham) unit test - Programming Assignment 1, Part 3, corr.R

library("testthat")
context("Calculate the correlation between sulfate and nitrate")

source("test-corr-df.r")
test_that("match the example output for the corr.R function", {
  expect_equal(   head(corr("specdata",  150)), c(-0.01895754, -0.14051254, -0.04389737, -0.06815956, -0.12350667, -0.07588814), tolerance=5e-08)
  expect_equal(summary(corr("specdata",  150)), df4)
  expect_equal(   head(corr("specdata",  400)), c(-0.01895754, -0.04389737, -0.06815956, -0.07588814,  0.76312884, -0.15782860), tolerance=5e-08)
  expect_equal(summary(corr("specdata",  400)), df5)
  expect_equal(summary(corr("specdata", 5000)), df6)
  expect_equal( length(corr("specdata", 5000)), 0)
  expect_equal(summary(corr("specdata"      )), df7)
  expect_equal( length(corr("specdata"      )), 323)
})
  