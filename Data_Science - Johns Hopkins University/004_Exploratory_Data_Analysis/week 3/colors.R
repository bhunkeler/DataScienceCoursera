# ==================================================================================================
# colors
# ==================================================================================================

if (!require("RColorBrewer")) {
  install.packages("RColorBrewer")
  library(RColorBrewer)
}


par(mfrow=c(2,2))
display.brewer.all()

# library('grDrives')

pal <- colorRamp(c('red', 'blue'))
pal(0)
pal(seq(0, 1, len = 10))

pal <- colorRampPalette(c('red', 'yellow'))
pal(2)

cols <- colorRampPalette(brewer.pal(9, 'Blues'))(100)
image(volcano, col = cols)

cols <- brewer.pal(3, 'BuGn')
pal <- colorRampPalette(cols)
image(volcano, col = pal(20))

x <- rnorm(10000)
y <- rnorm(10000)
smoothScatter(x, y)

# transparency 
plot(x, y, pch = 19, col = rgb(0,0,1,0.2))
