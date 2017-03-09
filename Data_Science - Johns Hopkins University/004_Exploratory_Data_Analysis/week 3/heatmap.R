# ==================================================================================================
# hierarchical clustering
# ==================================================================================================

# install.packages('fields')

dist(dataFrame)
hc <- hclust(distxy)

plot(hc)
plot(as.dendrogram(hc))

# clustering heatmap
# http://sebastianraschka.com/Articles/heatmaps_in_r.html#clustering

heatmap(dataMatrix, col = cm.colors(25))

heatmap(mt)








