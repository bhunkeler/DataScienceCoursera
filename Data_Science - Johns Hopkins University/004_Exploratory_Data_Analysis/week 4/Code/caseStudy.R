## setwd("~/CourseraModules/04_ExploratoryAnalysis/CaseStudy/pm25_data")

## Has fine particle pollution in the U.S. decreased from 1999 to
## 2012?

## Read in data from 1999

pm0 <- read.table("RD_501_88101_1999-0.txt", comment.char = "#", header = FALSE, sep = "|", na.strings = "")
dim(pm0)
head(pm0)
cnames <- readLines("RD_501_88101_1999-0.txt", 1)
print(cnames)

# split the names via piping
cnames <- strsplit(cnames, "|", fixed = TRUE)
print(cnames)

# character strings contain blanks. Replace them by a .
names(pm0) <- make.names(cnames[[1]])
head(pm0)

# x0 contains the pm25 values
x0 <- pm0$Sample.Value
class(x0)
str(x0)
summary(x0)

# Calculate percentage of missing values 
# Are missing values important here?
mean(is.na(x0))  

## Read in data from 2012

pm1 <- read.table("RD_501_88101_2012-0.txt", comment.char = "#", header = FALSE, sep = "|", na.strings = "", nrow = 1304290)
names(pm1) <- make.names(cnames[[1]])
head(pm1)
dim(pm1)
x1 <- pm1$Sample.Value
class(x1)

## Five number summaries for both periods
summary(x1)
summary(x0)
mean(is.na(x1))  ## Are missing values important here?

## Make a boxplot of both 1999 and 2012
boxplot(x0, x1)
boxplot(log10(x0), log10(x1))

## Check negative values in 'x1'
summary(x1)

# isoate all negative values
negative <- x1 < 0

# returns the amount of values which were negative (ignore na's)
sum(negative, na.rm = TRUE)

# calculate the percentage of negative values
mean(negative, na.rm = TRUE)
dates <- pm1$Date
str(dates)

# convert character string into date 
dates <- as.Date(as.character(dates), "%Y%m%d")
str(dates)

# plot a histogram of the months when the particulate matter measurements are negative
hist(dates, "month")  ## Check what's going on in months 1--6


## Plot a subset for one monitor at both times

## Find a monitor for New York State that exists in both datasets
site0 <- unique(subset(pm0, State.Code == 36, c(County.Code, Site.ID)))
site1 <- unique(subset(pm1, State.Code == 36, c(County.Code, Site.ID)))
site0 <- paste(site0[,1], site0[,2], sep = ".")
site1 <- paste(site1[,1], site1[,2], sep = ".")
str(site0)
str(site1)

# intersect which monitor exist in both sites 1999 and 2012
both <- intersect(site0, site1)
print(both)

## Find how many observations available at each monitor
pm0$county.site <- with(pm0, paste(County.Code, Site.ID, sep = "."))
pm1$county.site <- with(pm1, paste(County.Code, Site.ID, sep = "."))
cnt0 <- subset(pm0, State.Code == 36 & county.site %in% both)
cnt1 <- subset(pm1, State.Code == 36 & county.site %in% both)

# This will split cnt0 into several data frames according to county.site
sapply(split(cnt0, cnt0$county.site), nrow)
sapply(split(cnt1, cnt1$county.site), nrow)

## Choose county 63 and side ID 2008
pm1sub <- subset(pm1, State.Code == 36 & County.Code == 63 & Site.ID == 2008)
# pm1sub <- subset(cnt1, County.Code==63 & Site.ID==2008)

pm0sub <- subset(pm0, State.Code == 36 & County.Code == 63 & Site.ID == 2008)
# pm0sub <- subset(cnt0, County.Code==63 & Site.ID==2008)
dim(pm1sub)
dim(pm0sub)

## Plot data for 2012
dates1 <- pm1sub$Date

# create a vector containing the sample values (pm25)
x1sub <- pm1sub$Sample.Value
plot(dates1, x1sub)
dates1 <- as.Date(as.character(dates1), "%Y%m%d")
str(dates1)
plot(dates1, x1sub)

## Plot data for 1999
dates0 <- pm0sub$Date
dates0 <- as.Date(as.character(dates0), "%Y%m%d")
x0sub <- pm0sub$Sample.Value
plot(dates0, x0sub)

## Plot data for both years in same panel
par(mfrow = c(1, 2), mar = c(4, 4, 2, 1))
plot(dates0, x0sub, pch = 20)
abline(h = median(x0sub, na.rm = T), lwd = 2)

plot(dates1, x1sub, pch = 20)  ## Whoa! Different ranges
abline(h = median(x1sub, na.rm = T), lwd = 2)

## Find global range
rng <- range(x0sub, x1sub, na.rm = TRUE)
rng
par(mfrow = c(1, 2), mar = c(4, 4, 2, 1))
plot(dates0, x0sub, pch = 20, ylim = rng)
abline(h = median(x0sub, na.rm = TRUE))
plot(dates1, x1sub, pch = 20, ylim = rng)
abline(h = median(x1sub, na.rm = TRUE))

## Show state-wide means and make a plot showing trend
head(pm0)
mn0 <- with(pm0, tapply(Sample.Value, State.Code, mean, na.rm = T))
str(mn0)
summary(mn0)
mn1 <- with(pm1, tapply(Sample.Value, State.Code, mean, na.rm = T))
str(mn1)

## Make separate data frames for states / years
d0 <- data.frame(state = names(mn0), mean = mn0)
d1 <- data.frame(state = names(mn1), mean = mn1)
mrg <- merge(d0, d1, by = "state")
dim(mrg)
head(mrg)

## Connect lines
par(mfrow = c(1, 1))
with(mrg, plot(rep(1, 52), mrg[, 2], xlim = c(.5, 2.5)))
with(mrg, points(rep(2, 52), mrg[, 3]))
segments(rep(1, 52), mrg[, 2], rep(2, 52), mrg[, 3])

# which state had higher means in 2012
mrg[mrg$mean.x < mrg$mean.y, ]
