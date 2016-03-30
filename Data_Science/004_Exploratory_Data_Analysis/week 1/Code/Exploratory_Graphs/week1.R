# ========================================================================================================
# Description:   Week1.R - Exploratory Analysis
#
#
# Author:        Bruno Hunkeler
# Date:          xx.xx.2016
#
# ========================================================================================================

# ========================================================================================================
# Load Libraries
# ========================================================================================================

# Principles of Analytic Graphics
# Principle 1: Show Comparisons
# Principle 2: Show causality, mechanism, explanation, systematic structure
# Principle 3: Show multivariate data
# Principle 4: Integration of evidence
# Principle 5: Describe and document the evidence with appropriate labels, scales, sources, etc.
# Principle 6: Content is king


# Annual average PM2.5 averaged over the period 2008 through 2010

pollution <- read.csv("Data/avgpm25.csv", colClasses = c("numeric", "character", "factor", "numeric", "numeric"))
head(pollution)

# Five Number Summary Five Number Summary
summary(pollution$pm25)

# Boxplot
boxplot(pollution$pm25, col = "blue")

# Histogram
hist(pollution$pm25, col = "green")
rug(pollution$pm25, ticksize = 0.1)

hist(pollution$pm25, col = "green", breaks = 100)
rug(pollution$pm25, side = 1, col = "light blue")

# ========================================================================================================
# Overlaying Features
# ========================================================================================================

boxplot(pollution$pm25, col = "blue")
abline(h = 12)

hist(pollution$pm25, col = "green")
abline(v = 12,lwd = 2, h = 40)
abline(v = median(pollution$pm25), col = "magenta", lwd = 4)

# Barplot
barplot(table(pollution$region), col = "wheat", main = "Number of Counties in Each Region")

# ========================================================================================================
# Multiple dimensions
# ========================================================================================================

# Two dimensions:
# - Multiple/overlayed 1-D plots (Lattice/ggplot2)
# - Scatterplots
# - Smooth scatterplots

# More than two dimentions:
# - Overlayed/multiple 2-D plots; coplots
# - Use color, size, shape to add dimensions
# - Spinning plots
# - Actual 3-D plots (not that useful)

# Multiple Boxplots
boxplot(pm25 ~ region, data = pollution, col = "red")

# Multiple Histograms
par(mfrow = c(2, 1), mar = c(4, 4, 2, 1))
hist(subset(pollution, region == "east")$pm25, col = "green")
hist(subset(pollution, region == "west")$pm25, col = "green")

# Scatterplot
with(pollution, plot(latitude, pm25))
abline(h = 12, lwd = 2, lty = 2)

# Scatterplot - Using Color
with(pollution, plot(latitude, pm25, col = region))
abline(h = 12, lwd = 2, lty = 2)

# Multiple Scatterplots
par(mfrow = c(1, 2), mar = c(5, 4, 2, 1))
with(subset(pollution, region == "west"), plot(latitude, pm25, main = "West"))
with(subset(pollution, region == "east"), plot(latitude, pm25, main = "East"))

# The Base Plotting System
# - "Artist's palette" model
# - Start with blank canvas and build up from there
# - Start with plot function (or similar)
# - Use annotation functions to add/modify (text, lines, points, axis)

# - Convenient, mirrors how we think of building plots and analyzing data
# - Can’t go back once plot has started (i.e. to adjust margins); need to plan in advance
# - Difficult to "translate" to others once a new plot has been created (no graphical "language")
# - Plot is just a series of R commands

# Base Plot
library(datasets)
data(cars)
with(cars, plot(speed, dist))

# The Lattice System
# - Plots are created with a single function call (xyplot, bwplot, etc.)
# - Most useful for conditioning types of plots: Looking at how y changes with x across levels of z
# - Things like margins/spacing set automatically because entire plot is specified at once
# - Good for puttng many many plots on a screen

# - Sometimes awkward to specify an entire plot in a single function call
# - Annotation in plot is not especially intuitive
# - Use of panel functions and subscripts difficult to wield and requires intense preparation
# - Cannot "add" to the plot once it is created

# Lattice Plot
library(lattice)
state <- data.frame(state.x77, region = state.region)
xyplot(Life.Exp ~ Income | region, data = state, layout = c(4, 1))

# The ggplot2 System
# - Splits the difference between base and lattice in a number of ways
# - Automatically deals with spacings, text, titles but also allows you to annotate by "adding" to a plot
# - Superficial similarity to lattice but generally easier/more intuitive to use
# - Default mode makes many choices for you (but you can still customize to your heart's desire)

# ggplot2 Plot
library(ggplot2)
data(mpg)
qplot(displ, hwy, data = mpg)

# Summary:
# Base: "artist's palette" model
# Lattice: Entire plot specified by one function; conditioning
# ggplot2: Mixes elements of Base and Lattice

# Plotting System
#
# The core plotting and graphics engine in R is encapsulated in the following packages:
# - graphics: contains plotting functions for the "base" graphing systems, including plot, hist,
# boxplot and many others.
# - grDevices: contains all the code implementing the various graphics devices, including X11, PDF,
# PostScript, PNG, etc.
# 
# The lattice plotting system is implemented using the following packages:
# - lattice: contains code for producing Trellis graphics, which are independent of the “base” graphics
# system; includes functions like xyplot, bwplot, levelplot
# - grid: implements a different graphing system independent of the “base” system; the lattice
# package builds on top of grid; we seldom call functions from the grid package directly

# The Process of Making a Plot The Process of Making a Plot
# When making a plot one must first make a few considerations (not necessarily in this order):
# - Where will the plot be made? On the screen? In a file?
# - How will the plot be used?
#       - Is the plot for viewing temporarily on the screen?
#       - Will it be presented in a web browser?
#       - Will it eventually end up in a paper that might be printed?
#       - Are you using it in a presentation?
# - Is there a large amount of data going into the plot? Or is it just a few points?
# - Do you need to be able to dynamically resize the graphic?
# - What graphics system will you use: base, lattice, or ggplot2? These generally cannot be mixed.
# - Base graphics are usually constructed piecemeal, with each aspect of the plot handled
# separately through a series of function calls; this is often conceptually simpler and allows plotting
# to mirror the thought process
# - Lattice graphics are usually created in a single function call, so all of the graphics parameters
# have to specified at once; specifying everything at once allows R to automatically calculate the
# necessary spacings and font sizes.
# - ggplot2 combines concepts from both base and lattice graphics but uses an independent
# implementation

# Base Graphics
# Base graphics are used most commonly and are a very powerful system for creating 2-D graphics.
# - There are two phases to creating a base plot
#       - Initializing a new plot
#       - Annotating (adding to) an existing plot
# - Calling plot(x, y) or hist(x) will launch a graphics device (if one is not already open) and
# draw a new plot on the device
# - If the arguments to plot are not of some special class, then the default method for plot is
# called; this function has many arguments, letting you set the title, x axis label, y axis label, etc.
# - The base graphics system has many parameters that can set and tweaked; these parameters are
# documented in ?par; it wouldn’t hurt to try to memorize this help page!

# Histogram
library(datasets)
hist(airquality$Ozone) ## Draw a new plot

# Scatterplot
library(datasets)
with(airquality, plot(Wind, Ozone))

# Boxplot
library(datasets)
airquality <- transform(airquality, Month = factor(Month))
boxplot(Ozone ~ Month, airquality, xlab = "Month", ylab = "Ozone (ppb)")

# Some Important Base Graphics Parameters Some Important Base Graphics Parameters
# Many base plotting functions share a set of parameters. Here are a few key ones:
# - pch: the plotting symbol (default is open circle)
# - lty: the line type (default is solid line), can be dashed, dotted, etc.
# - lwd: the line width, specified as an integer multiple
# - col: the plotting color, specified as a number, string, or hex code; the colors() function gives
# you a vector of colors by name
# - xlab: character string for the x-axis label
# - ylab: character string for the y-axis label
# The par() function is used to specify global graphics parameters that affect all plots in an R
# session. These parameters can be overridden when specified as arguments to specific plotting
# functions.
# - las: the orientation of the axis labels on the plot
# - bg: the background color
# - mar: the margin size
# - oma: the outer margin size (default is 0 for all sides)
# - mfrow: number of plots per row, column (plots are filled row-wise)
# - mfcol: number of plots per row, column (plots are filled column-wise)

# Default values for global graphics parameters
par("lty")
## [1] "solid"
par("col")
## [1] "black"
par("pch")
## [1] 1
par("bg")
## [1] "transparent"
par("mar")
## [1] 5.1 4.1 4.1 2.1
par("mfrow")
## [1] 1 1

# Base Plotting Functions Base Plotting Functions:
# plot: make a scatterplot, or other type of plot depending on the class of the object being plotted
# lines: add lines to a plot, given a vector x values and a corresponding vector of y values (or a 2-                                                                                                    
# column matrix); this function just connects the dots
# points: add points to a plot
# text: add text labels to a plot using specified x, y coordinates
# title: add annotations to x, y axis labels, title, subtitle, outer margin
# mtext: add arbitrary text to the margins (inner or outer) of the plot
# axis: adding axis ticks/labels

# Base Plot with Annotation
with(airquality, plot(Wind, Ozone, main = "Ozone and Wind in New York City", type = "n"))
with(subset(airquality, Month == 5), points(Wind, Ozone, col = "blue"))
with(subset(airquality, Month != 5), points(Wind, Ozone, col = "red"))
legend("topright", pch = 1, col = c("blue", "red"), legend = c("May", "Other Months"))

# Base Plot with Regression Line
with(airquality, plot(Wind, Ozone, main = "Ozone and Wind in New York City", pch = 20))
model <- lm(Ozone ~ Wind, airquality)
abline(model, lwd = 2)

# Multiple Base Plots
par(mfrow = c(1, 2))
with(airquality, {
  plot(Wind, Ozone, main = "Ozone and Wind")
  plot(Solar.R, Ozone, main = "Ozone and Solar Radiation")
})

par(mfrow = c(1, 3), mar = c(4, 4, 2, 1), oma = c(0, 0, 2, 0))
with(airquality, {
  plot(Wind, Ozone, main = "Ozone and Wind")
  plot(Solar.R, Ozone, main = "Ozone and Solar Radiation")
  plot(Temp, Ozone, main = "Ozone and Temperature")
  mtext("Ozone and Weather in New York City", outer = TRUE)
})

# ========================================================================================================
# Demonstration
# ========================================================================================================

x <- rnorm(100)
hist(x)
y <- rnorm(100)
plot(x, y)
z <- rnorm(100)
plot(x, z)
plot(x, y)
par(mar = c(2, 2, 2, 2)) # change margin size (bottom-1, left-2, top-3, right-4)
plot(x, y)
par(mar = c(4, 4, 2, 2))
plot(x, y)
plot(x, y, pch = 20)
plot(x, y, pch = 19)
plot(x, y, pch = 2)
plot(x, y, pch = 3)
plot(x, y, pch = 4)
# example(points)
title("Scatterplot") # rename title
text(-2, -2, "Label")
legend("topleft", legend = "Data", pch = 20)
fit <- lm(y ~ x)
abline(fit)
abline(fit, lwd = 3)
abline(fit, lwd = 3, col = "blue")
plot(x, y, xlab = "Weight", ylab = "Height", main = "Scatterplot", pch = 20)
legend("topright", legend = "Data", pch = 20)
fit <- lm(y ~ x)
abline(fit, lwd = 3, col = "red")
z <- rpois(100, 2)
par(mfrow = c(2, 1))
plot(x, y, pch = 20)
plot(x, z, pch = 19)
par("mar")
par(mar = c(2, 2, 1, 1))
plot(x, y, pch = 20)
plot(x, z, pch = 19)
par(mfrow = c(1, 2))
plot(x, y, pch = 20)
plot(x, z, pch = 20)
par(mar = c(4, 4, 2, 2))
plot(x, y, pch = 20)
plot(x, z, pch = 20)
par(mfrow = c(2, 2))
plot(x, y)
plot(x, z)
plot(z, x)
plot(y, x)
par(mfcol = c(2, 2))
plot(x, y)
plot(x, z)
plot(z, x)
plot(y, x)
par(mfrow = c(1, 1))
x <- rnorm(100)
y <- x + rnorm(100)
g <- gl(2, 50, labels = c("Male", "Female"))
str(g)
plot(x, y)
plot(x, y, type = "n")
points(x[g == "Male"], y[g == "Male"], col = "green")
points(x[g == "Female"], y[g == "Female"], col = "blue", pch = 19)

# ========================================================================================================
# Graphics Device
# ========================================================================================================
?Devices

# for screen device:
# 1. Call a plotting function like plot, xyplot, or qplot
# 2. The plot appears on the screen device
# 3. Annotate plot if necessary
# 4. Enjoy
library(datasets)
with(faithful, plot(eruptions, waiting)) ## Make plot appear on screen device
title(main = "Old Faithful Geyser data") ## Annotate with a title


# for file devices:
# 1. Explicitly launch a graphics device
# 2. Call a plotting function to make a plot (Note: if you are using a file device, no plot will appear on the screen)
# 3. Annotate plot if necessary
# 4. Explicitly close graphics device with dev.off() (this is very important!)
pdf(file = "myplot.pdf") ## Open PDF device; create 'myplot.pdf' in my working directory
## Create plot and send to a file (no plot appears on screen)
with(faithful, plot(eruptions, waiting))
title(main = "Old Faithful Geyser data") ## Annotate plot; still nothing on screen
dev.off() ## Close the PDF file device
## Now you can view the file 'myplot.pdf' on your computer

# Graphics File Devices Graphics File Devices
# There are two basic types of file devices: vector and bitmap devices
# - Vector formats:
#       - pdf: useful for line-type graphics, resizes well, usually portable, not efficient if a plot has many
#       objects/points
#       - svg: XML-based scalable vector graphics; supports animation and interactivity, potentially useful
#       for web-based plots
#       - win.metafile: Windows metafile format (only on Windows)
#       - postscript: older format, also resizes well, usually portable, can be used to create
#       encapsulated postscript files; Windows systems often don’t have a postscript viewer
# - Bitmap formats
#       - png: bitmapped format, good for line drawings or images with solid colors, uses lossless
#       compression (like the old GIF format), most web browsers can read this format natively, good for
#       plotting many many many points, does not resize well
#       - jpeg: good for photographs or natural scenes, uses lossy compression, good for plotting many
#       many many points, does not resize well, can be read by almost any computer and any web
#       browser, not great for line drawings
#       - tiff: Creates bitmap files in the TIFF format; supports lossless compression
#       - bmp: a native Windows bitmapped format

# Multiple Open Graphics Devices Multiple Open Graphics Devices
# - It is possible to open multiple graphics devices (screen, file, or both), for example when viewing
# multiple plots at once
# - Plotting can only occur on one graphics device at a time
# - The currently active graphics device can be found by calling dev.cur()
# - Every open graphics device is assigned an integer >= 2.
# - You can change the active graphics device with dev.set(<integer>) where <integer> is the
# number associated with the graphics device you want to switch to

# Copying Plots Copying Plots
# Copying a plot to another device can be useful because some plots require a lot of code and it can
# be a pain to type all that in again for a different device.
#       - dev.copy: copy a plot from one device to another
#       - dev.copy2pdf: specifically copy a plot to a PDF file
# NOTE: Copying a plot is not an exact operation, so the result may not be identical to the original.
library(datasets)
with(faithful, plot(eruptions, waiting)) ## Create plot on screen device
title(main = "Old Faithful Geyser data") ## Add a main title
dev.copy(png, file = "geyserplot.png") ## Copy my plot to a PNG file
dev.off() ## Don't forget to close the PNG device!
