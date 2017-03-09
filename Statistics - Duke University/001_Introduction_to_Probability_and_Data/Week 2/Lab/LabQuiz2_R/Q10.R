
library(statsr)
library(dplyr)
library(ggplot2)

data(nycflights)

nycflights <- nycflights %>%
  mutate(arr_type = ifelse(arr_delay < 5, "on time", "delayed"))