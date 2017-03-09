# ========================================================================================================================================
# Description:   Lab Quiz 1
#                Coursera Data Science at Duke University
#
#
# Author:        Bruno Hunkeler
# Date:          02.05.2016
#
# ========================================================================================================================================

# ========================================================================================================================================
# Load Libraries
# ========================================================================================================================================

library('devtools')
library('curl')
library('ggplot2')
library('dplyr')
# library('StatsRBHU')
# install_github('StatsWithR/statsr')
library(statsr)



# ==================================================================================================
# Lab Quiz 2
# ==================================================================================================


data(nycflights)
names(nycflights)

ggplot(data = nycflights, aes(x = log10(dep_delay))) +
  geom_histogram()

ggplot(data = nycflights, aes(x = dep_delay)) +
  geom_histogram()

ggplot(data = nycflights, aes(x = dep_delay)) +
  geom_histogram(binwidth = 15)

ggplot(data = nycflights, aes(x = dep_delay)) +
  geom_histogram(binwidth = 150)

rdu_flights <- nycflights %>%
  filter(dest == "RDU")
ggplot(data = rdu_flights, aes(x = dep_delay)) +
  geom_histogram()


rdu_flights %>%
  summarise(mean_dd = mean(dep_delay), sd_dd = sd(dep_delay), n = n())

sfo_feb_flights <- nycflights %>%
  filter(dest == "SFO", month == 2)


rdu_flights %>%
  group_by(origin) %>%
  summarise(mean_dd = mean(dep_delay), sd_dd = sd(dep_delay), n = n())

nycflights %>%
  group_by(month) %>%
  summarise(mean_dd = mean(dep_delay)) %>%
  arrange(desc(mean_dd))

ggplot(nycflights, aes(x = factor(month), y = log10(dep_delay))) +
  geom_boxplot()

ggplot(data = nycflights, aes(x = origin, fill = dep_type)) +
  geom_bar()



# ==================================================================================================
# Question 1

sfo_feb_flights <- nycflights %>%
  filter(dest == "SFO", month == 2)

dim(sfo_feb_flights)

# Answer: 68


# ==================================================================================================
# Question 2

sfo_feb_flights %>%
  summarise(mean_dd = mean(arr_delay), sd_dd = sd(arr_delay), n = n())

ggplot(data = sfo_feb_flights, aes(x = arr_delay)) +
  geom_histogram(binwidth = 10)

sfo_arr_delay <- sfo_feb_flights %>%
  filter(arr_delay > 120)

# Answer: C

# ==================================================================================================
# Question 3

sfo_feb_flights %>%
  group_by(carrier) %>%
  summarise(median_dd = median(arr_delay), iqr_dd =IQR(arr_delay), n = n())

# Answer: D - Delta and United Airlines

# ==================================================================================================
# Question 4


nycflights %>%
  group_by(month) %>%
  summarise(mean_dd = mean(dep_delay)) %>%
  arrange(desc(mean_dd))

# Answer: C - July

# ==================================================================================================
# Question 5

nycflights %>%
  group_by(month) %>%
  summarise(median_dd = median(dep_delay)) %>%
  arrange(desc(median_dd))

# Answer: E - December

# ==================================================================================================
# Question 6

ggplot(nycflights, aes(x = factor(month), y = dep_delay)) +
  geom_boxplot()

# dont't know yet

# Answer: A - Mean would be more reliable as it gives us the true average.


# ==================================================================================================
# Question 7

nycflights <- nycflights %>%
  mutate(dep_type = ifelse(dep_delay < 5, "on time", "delayed"))

nycflights %>%
  group_by(origin) %>%
  summarise(ot_dep_rate = sum(dep_type == "on time") / n()) %>%
  arrange(desc(ot_dep_rate))

# or 

out_del <- nycflights %>%
  mutate(dep_type = ifelse(dep_delay < 5, "on time", "delayed")) %>%
  group_by(origin) %>%
  summarise(ot_dep_rate = sum(dep_type == "on time") / n()) %>%
  arrange(desc(ot_dep_rate))


# Answer: C - LGA


# ==================================================================================================
# Question 8


# Mutate the data frame so that it includes a new variable that contains the average speed, avg_speed 
# traveled by the plane for each flight (in mph). What is the tail number of the plane with the fastest 
# avg_speed? Hint: Average speed can be calculated as distance divided by number of hours of travel, and 
# note that air_time is given in minutes. If you just want to show the avg_speed and tailnum and none of 
# the other variables, use the select function at the end of your pipe to select just these two variables 
# with select(avg_speed, tailnum). You can Google this tail number to find out more about the aircraft.

nycflights <- nycflights %>%
  mutate(avg_speed = distance / air_time * 60) %>%
  filter(avg_speed == max(avg_speed)) %>% 
  select(tailnum, avg_speed)

# Answer: A - N666DN


# ==================================================================================================
# Question 9
ggplot(nycflights, aes(x = avg_speed, y = distance)) +
  geom_point() + geom_smooth()



ggplot(nycflights, aes(x = distance, y = avg_speed)) +
  geom_point() + geom_smooth()

# Answer: C - There is an overall postive association between distance and average speed.


# ==================================================================================================
# Question 10

nycflights <- nycflights %>%
  mutate(arr_type = ifelse(arr_delay < 5, "on time", "delayed"))
