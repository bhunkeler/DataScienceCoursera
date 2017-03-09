# ========================================================================================================================================
# Load Libraries
# ========================================================================================================================================

library('dplyr')
library('ggplot2')
# library('reshape2')
library(devtools)
library(statsr)

# ========================================================================================================================================
# Download and extract Data and load file
# ========================================================================================================================================


data(ames)

ggplot(data = ames, aes(x = area)) +
  geom_histogram(binwidth = 250)

ames %>%
  summarise(mu = mean(area), pop_med = median(area), 
            sigma = sd(area), pop_iqr = IQR(area),
            pop_min = min(area), pop_max = max(area),
            pop_q1 = quantile(area, 0.25),  # first quartile, 25th percentile
            pop_q3 = quantile(area, 0.75))  # third quartile, 75th percentile

summary(ames$area)


# retrieve 50 Samples 
samp1 <- ames %>%
  sample_n(size = 50)

mean(samp1$area)

# Calculate the mean of the sample 
samp1 %>%
  summarise(x_bar = mean(area))

sample_means50 <- ames %>%
  rep_sample_n(size = 50, reps = 15000, replace = TRUE) %>%
  summarise(x_bar = mean(area))

ggplot(data = sample_means50, aes(x = x_bar)) +
  geom_histogram(binwidth = 20) +
  geom_vline(xintercept=mean(sample_means50$x_bar), col = 'red')

# sample size
dim(sample_means50)[1]


sample_means_small <- ames %>%
  rep_sample_n(size = 10, reps = 25, replace = TRUE) %>%
  summarise(x_bar = mean(area))

ggplot(data = sample_means_small, aes(x = x_bar)) +
  geom_histogram(binwidth = 20) +
  geom_vline(xintercept=mean(sample_means_small$x_bar), col = 'red')


# ================================================================================
# Question 1
# ================================================================================

# 50% of houses in Ames are smaller than 1,499.69 square feet.

# ================================================================================
# Question 2
# ================================================================================

# Sample size of 1000.

# ================================================================================
# Question 3
# ================================================================================

sample_means_small <- ames %>%
  rep_sample_n(size = 10, reps = 25, replace = TRUE) %>%
  summarise(x_bar = mean(area))

ggplot(data = sample_means_small, aes(x = x_bar)) +
  geom_histogram(binwidth = 20) +
  geom_vline(xintercept=mean(sample_means_small$x_bar), col = 'red')

# sample size
dim(sample_means_small)[1]

# ================================================================================
# Question 4
# ================================================================================

# Each element represents a mean square footage from a simple random sample of 10 houses.


# ================================================================================
# Question 5
# ================================================================================


# The variability of the sampling distribution 'decreases'


# ================================================================================
# Question 6
# ================================================================================

# The variability of the sampling distribution with the smaller sample size (`sample_means50`) is smaller than the variability of the sampling distribution with the larger sample size (`sample_means150`). 



# retrieve 50 Samples 
samp1 <- ames %>%
  sample_n(size = 50)

# calculate the mean price (point estimate)
mean(samp1$price)


# calculate the mean price (point estimate) for 5000 repetitions on a sample size of 50 
sample_means50 <- ames %>%
  rep_sample_n(size = 50, reps = 5000, replace = TRUE) %>%
  summarise(x_bar = mean(price))

ggplot(data = sample_means50, aes(x = x_bar)) +
  geom_histogram(binwidth = 20) +
  geom_vline(xintercept=mean(sample_means_small$x_bar), col = 'red')


# calculate the mean price (point estimate) for 5000 repetitions on a sample size of 150 
sample_means150 <- ames %>%
  rep_sample_n(size = 150, reps = 5000, replace = TRUE) %>%
  summarise(x_bar = mean(price))

ggplot(data = sample_means150, aes(x = x_bar)) +
  geom_histogram(binwidth = 20) +
  geom_vline(xintercept=mean(sample_means150$x_bar), col = 'red')


# retrieve 50 Samples 
samp1 <- ames %>%
  sample_n(size = 15)

# calculate the mean price (point estimate)
mean(samp1$price)


# calculate the mean price (point estimate) for 2000 repetitions on a sample size of 15 
sample_means15 <- ames %>%
  rep_sample_n(size = 15, reps = 2000, replace = TRUE) %>%
  summarise(x_bar = mean(price))

ggplot(data = sample_means15, aes(x = x_bar)) +
  geom_histogram(binwidth = 20) +
  geom_vline(xintercept=mean(sample_means15$x_bar), col = 'red')

mean(sample_means15$x_bar)

# calculate the mean price (point estimate) for 2000 repetitions on a sample size of 15 
sample_means150 <- ames %>%
  rep_sample_n(size = 150, reps = 2000, replace = TRUE) %>%
  summarise(x_bar = mean(price))

ggplot(data = sample_means150, aes(x = x_bar)) +
  geom_histogram(binwidth = 20) +
  geom_vline(xintercept=mean(sample_means150$x_bar), col = 'red')

mean(sample_means150$x_bar)


# calculate the mean price (point estimate) for 2000 repetitions on a sample size of 15 
sample_means50 <- ames %>%
  rep_sample_n(size = 15, reps = 2000, replace = TRUE) %>%
  summarise(x_bar = mean(price))

ggplot(data = sample_means50, aes(x = x_bar)) +
  geom_histogram(binwidth = 20) +
  geom_vline(xintercept=mean(sample_means50$x_bar), col = 'red')

mean(sample_means50$x_bar)
mean(sample_means150$x_bar)



