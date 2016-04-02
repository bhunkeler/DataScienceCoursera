
##   Coursera Exploratory Data Analysis<br>
<b>at Johns Hopkins University</b>


### Introduction
Part of the module <b>Exploratory Data Analysis</b> are 2 Project assignements: 

<li><b><a href="#Project1">Project 1</a></b>: Individual household electric power consumption
<li><b><a href="#Project2">Project 2</a></b>: unknown yet


<h3><a name = "Project1">Project 1</a></h3>

This assignment uses data from the <a href="http://archive.ics.uci.edu/ml/">UC Irvine Machine Learning Repository</a>, a popular repository for machine learning
datasets. In particular, we used the "Individual household electric power consumption Data Set" which is available on the course web site:

* <b>Dataset</b>: <a href="https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip">Electric power consumption</a> [20Mb]

* <b>Description</b>: Measurements of electric power consumption in one household with a one-minute sampling rate over a period of almost
4 years. Different electrical quantities and some sub-metering values are available.


The following descriptions of the 9 variables in the dataset are taken from the 
<a href="https://archive.ics.uci.edu/ml/datasets/Individual+household+electric+power+consumption">UCI web site</a>:

<ol>
<li><b>Date</b>: Date in format dd/mm/yyyy </li>
<li><b>Time</b>: time in format hh:mm:ss </li>
<li><b>Global_active_power</b>: household global minute-averaged active power (in kilowatt) </li>
<li><b>Global_reactive_power</b>: household global minute-averaged reactive power (in kilowatt) </li>
<li><b>Voltage</b>: minute-averaged voltage (in volt) </li>
<li><b>Global_intensity</b>: household global minute-averaged current intensity (in ampere) </li>
<li><b>Sub_metering_1</b>: energy sub-metering No. 1 (in watt-hour of active energy). It corresponds to the kitchen, containing mainly a dishwasher, an oven and a microwave (hot plates are not electric but gas powered). </li>
<li><b>Sub_metering_2</b>: energy sub-metering No. 2 (in watt-hour of active energy). It corresponds to the laundry room, containing a washing-machine, a tumble-drier, a refrigerator and a light. </li>
<li><b>Sub_metering_3</b>: energy sub-metering No. 3 (in watt-hour of active energy). It corresponds to an electric water-heater and an air-conditioner.</li>
</ol>

<h3>Download and read data</h3>

The dataset contains 2,075,259 rows and 9 columns, therefore the download will take a while. The given code below downloads the dataset and extracts the zip container. 
The unused zip container will be removed afterwards. A download will be omitted, if the file already exists on the local file system.

```
zipFile <- "exdata%2Fdata%2Fhousehold_power_consumption.zip"

if(!file.exists("Data/household_power_consumption.txt")){ 
  dataURL <- "https://archive.ics.uci.edu/ml/machine-learning-databases/00235/household_power_consumption.zip"
  download.file(dataURL, zipFile, mode ="wb")  
  unzip(zipFile, files = NULL, list = FALSE, overwrite = TRUE, junkpaths = FALSE, exdir = "Data", unzip = "internal", setTimes = FALSE)
  file.remove(zipFile)
}
```

To read the dataset the <b>read.table</b> file reader  has been used.
```
# Define Directory where File is located
dirName <- 'Data'

# load power consumption data
fileName = "household_power_consumption.txt"
fileNamePower <- file.path(dirName, fileName)

data <- read.table(file = fileNamePower, header = TRUE, sep = ';')
```

<h3>Data preparation (munging) </h3>
Only a subset of the dataset from the dates 2007-02-01 and 2007-02-02, will be used to prepare plots. A few adjustments need to be applied to get the data ready for the 
plots. Certain features required to be converted to numeric values while the date and time columns were converted and agregated in one column. 
Unused columns will be used to didy up the data set.

```
# subset data set
data <- subset(data, Date == '1/2/2007' | Date == '2/2/2007')

# Convert some features to numeric features
ColNames <- names(data[3:9])
numericList <- c(ColNames)
data[, numericList] <- lapply(data[, numericList], function(x) as.numeric(as.character(x)))

# Merge date & time into single column
dateTime <- as.POSIXct(paste(data$Date, data$Time, sep = ";"), format = "%d/%m/%Y;%H:%M:%S")
data <- cbind("DateTime" = dateTime, data)
data$Date <- NULL
data$Time <- NULL
remove(dateTime)
```

<h3>Making Plots</h3>

Our overall goal here is simply to examine how household energy usage varies over a 2-day period in February, 2007. The mandate was to reconstruct 4 Plots, 
all of which were constructed using the base plotting system.

For each plot you should

* Construct the plot and save it to a PNG file with a width of 480 pixels and a height of 480 pixels.
* Name each of the plot files as `plot1.png`, `plot2.png`, etc.
* Create a separate R code file (`plot1.R`, `plot2.R`, etc.) that constructs the corresponding plot, i.e. code in `plot1.R` constructs the `plot1.png` plot. 


Find below the code and the resective plot.

<h4>Plot1</h4>

```
# Plot graph
png(filename = "plot1.png", width = 480, height = 480, units = "px", bg = "transparent")
hist(data$Global_active_power, col = "red", main = "Global Active Power", xlab = "Global Active Power (kilowatts)")

dev.off()
```

![plot 1](Project1/plot1.png) 

<h4>Plot2</h4>

```
# Plot graph
png(filename = "plot2.png", width = 480, height = 480, units = "px", bg = "transparent")
plot(data$Date, data$Global_active_power, type = "l", xlab = "", ylab = "Global Active Power (kilowatts)")

dev.off()

```
![plot 1](Project1/plot2.png) 

<h4>Plot3</h4>

```
# Plot graph
png(filename = "plot3.png", width = 480, height = 480, units = "px", bg = "transparent")
plot(data$DateTime, data$Sub_metering_1, type = "l", col = "black", xlab = "", ylab = "Global Active Power (kilowatts)")
lines(data$DateTime, data$Sub_metering_2, type = "l", col = "red")
lines(data$DateTime, data$Sub_metering_3, type = "l", col = "blue")
legend("topright", c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"), lty = c(1, 1, 1), col = c("black", "red", "blue"))
dev.off()
```
![plot 1](Project1/plot3.png) 


<h4>Plot4</h4>

```
# Plot graph
png(filename = "plot4.png", width = 480, height = 480, units = "px", bg = "transparent")

par(mfrow = c(2, 2))

# Add plot 1 to top, left
plot(data$DateTime, data$Global_active_power, type = "l", xlab = "", ylab = "Global Active Power")

# Add plot 2 to top, right
plot(data$DateTime, data$Voltage, type = "l", xlab = "datetime", ylab = "Voltage")

# Add plot 3 to bottom, left
plot(data$DateTime, data$Sub_metering_1, type = "l", col = "black", xlab = "", ylab = "Energy sub metering")
lines(data$DateTime, data$Sub_metering_2, type = "l", col = "red")
lines(data$DateTime, data$Sub_metering_3, type = "l", col = "blue")
legend("topright", c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"), lty = c(1, 1, 1), bty = 'n', col = c("black", "red", "blue"))

# Add plot 3 to bottom, right
plot(data$DateTime, data$Global_reactive_power, type = "l", xlab = "datetime", ylab = "Global_reactive_power", lwd = 0.5)

dev.off()
```
![plot 1](Project1/plot4.png) 


<h3><a name = "Project2">Project 2</a></h3>
