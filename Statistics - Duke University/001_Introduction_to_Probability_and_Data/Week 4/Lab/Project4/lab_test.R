



# Question 1:


# Question 2:

# ===============================================================
# Question 3:

## ratings_australia is already loaded

# Print the ratings for the Australian red wine
ratings_australia

# Convert these ratings to Z-scores using the scale() function
z_scores_australia <- scale(ratings_australia)

# Arrange the histograms side-by-side
par(mfrow = c(1, 2))

# Plot the histogram for the original scores
hist(ratings_australia)

# Plot the histogram for the Z-scores
hist(z_scores_australia)


x <- seq(-4, 4, length=100)
hx <- dnorm(x)

degf <- c(1, 3, 8, 30)
colors <- c("red", "blue", "darkgreen", "gold", "black")
labels <- c("df=1", "df=3", "df=8", "df=30", "normal")

plot(x, hx, type="l", lty=2, xlab="x value", ylab="Density", main="Comparison of t Distributions")







# Display the Student's t distributions with various
# degrees of freedom and compare to the normal distribution
x <- seq(-4, 4, length=100)
hx <- dnorm(x)

degf <- c(1, 3, 8, 30)
colors <- c("red", "blue", "darkgreen", "gold", "black")
labels <- c("df=1", "df=3", "df=8", "df=30", "normal")

plot(x, hx, type="l", lty=2, xlab="x value", ylab="Density", main="Comparison of t Distributions")

for (i in 1:4){
  lines(x, dt(x,degf[i]), lwd=2, col=colors[i])
}

legend("topright", inset=.05, title="Distributions", labels, lwd=2, lty=c(1, 1, 1, 1, 2), col=colors)


# Children's IQ scores are normally distributed with a
# mean of 100 and a standard deviation of 15. What
# proportion of children are expected to have an IQ between
# 80 and 120?

mean=100; sd=15
lb=80; ub=120

x <- seq(-4,4,length=100)*sd + mean
hx <- dnorm(x,mean,sd)

plot(x, hx, type="n", xlab="IQ Values", ylab="",
     main="Normal Distribution", axes=FALSE)

i <- x >= lb & x <= ub
lines(x, hx)
polygon(c(lb,x[i],ub), c(0,hx[i],0), col="red")

area <- pnorm(ub, mean, sd) - pnorm(lb, mean, sd)
result <- paste("P(",lb,"< IQ <",ub,") =",
                signif(area, digits=3))
mtext(result,3)
axis(1, at=seq(40, 160, 20), pos=0) 


# Q-Q plots
par(mfrow=c(1,2))

# create sample data
x <- rt(100, df=3)

# normal fit
qqnorm(x); qqline(x)

# t(3Df) fit
qqplot(rt(1000,df=3), x, main="t(3) Q-Q Plot",
       ylab="Sample Quantiles")
abline(0,1) 