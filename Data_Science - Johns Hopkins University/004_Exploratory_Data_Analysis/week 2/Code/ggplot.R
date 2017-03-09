
# alpha value transperency
plot(x, y, pch = 19, col = rgb(0, .5, .5, .3))



qplot(disol, hwy, data = mpg)


qplot(displ, hwy, data = mpg, color=drv, geom(c("point", "smooth")))

qplot(y = hwy, data = mpg, color = drv)
qplot(drv, hwy, data = mpg, geom = "boxplot")

qplot(hwy, data = mpg, fill = drv)

qplot(displ, hwy, data = mpg, facets = . ~ drv)
qplot(hwy, data = mpg, facets = drv ~ ., binwidth = 2)


# ggPlot2
# DATA FRAME
# AESTHETIC MAPPINGS
# GEOMS
# FACETS


g <- ggplot(mpg, aes(displ, hwy))
g + geom_point()
g + geom_point() + geom_smooth()
g + geom_point() + geom_smooth(method = 'lm')
g + geom_point() + geom_smooth(method = 'lm') + facet_grid(. ~ drv)
g + geom_point() + geom_smooth(method = 'lm') + facet_grid(. ~ drv) + ggtitle("Swirl Rules!")

g + geom_point(color = "pink", size = 4, alpha = 1/2)
# alpha makes points transparent

g + geom_point(size = 4, alpha = 1/2, aes(color = drv))
g + geom_point(aes(color = drv)) + labs(title = "Swirl Rules!") + labs(x = "Displacement", y = "Hwy Mileage")
g + geom_point(aes(color = drv), size = 2, alpha = 1/2) + geom_smooth(size = 4, linetype = 3, method = 'lm', se = FALSE)
g + geom_point(aes(color = drv)) + theme_bw(base_family = "Times") 



g <- ggplot(testdat, aes(x = myx, y = myy)) 
g + geom_line()
g + geom_line() + ylim(-3,3)
g + geom_line() + coord_cartesian(ylim = c(-3,3))


g <- ggplot(mpg, aes(x = displ, y = hwy, color = factor(year)))
g + geom_point()
g + geom_point() + facet_grid(drv~cyl, margins = TRUE)
g + geom_point() + facet_grid(drv~cyl, margins = TRUE) + geom_smooth(method = "lm", se = FALSE, size = 2, color = 'black')
g + geom_point() + facet_grid(drv~cyl, margins = TRUE) + geom_smooth(method = "lm", se = FALSE, size = 2, color = 'black') + labs(x = "Displacement", y = "Highway Mileage", title = "Swirl Rules!")




# histogram
qplot(price,data=diamonds)
qplot(price,data=diamonds, binwidth = 18497/30)

# fill with colors based on cut feature
qplot(price,data=diamonds, binwidth = 18497/30, fill = cut)

qplot(price,data=diamonds, geom = 'density')
# plot density with colors based on cut feature
qplot(price,data=diamonds, geom = 'density', color = cut)

qplot(carat, price, data=diamonds)
qplot(carat, price, data=diamonds, shape = cut)
qplot(carat, price, data=diamonds, color = cut)

qplot(carat, price, data=diamonds, color = cut, geom = c("point" , "smooth"))
qplot(carat,price,data=diamonds, color=cut) + geom_smooth(method="lm")


qplot(carat,price,data=diamonds, color=cut, facets = .~cut) + geom_smooth(method="lm")


g <- ggplot(diamonds, aes(depth, price))
g + geom_point(alpha = 1/3)

# the data into 3 pockets, so 1/3 of the data falls into each
cutpoints <- quantile(diamonds$carat, seq(0, 1, length=4), na.rm = TRUE)
diamonds$car2 <- cut(diamonds$carat, cutpoints)
g <- ggplot(diamonds, aes(depth,price))

g + geom_point(alpha = 1/3) + facet_grid(cut ~ car2)
diamonds[myd,]
g+geom_point(alpha=1/3)+facet_grid(cut~car2) + geom_smooth(method = 'lm', size = 3, color = 'pink')
ggplot(diamonds, aes(carat, price)) + geom_boxplot() + facet_grid(. ~ cut)




