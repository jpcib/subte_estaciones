install.packages("ape")
library(ape)
# https://stats.oarc.ucla.edu/r/faq/how-can-i-calculate-morans-i-in-r/
ozone <- read.table("https://stats.idre.ucla.edu/stat/r/faq/ozone.csv", sep=",", header=T)
ozone

ozone.dists <- as.matrix(dist(cbind(ozone$Lon, ozone$Lat)))
view(ozone.dists)

ozone.dists.inv <- 1/ozone.dists
ozone.dists.inv[1:5,1:5]

diag(ozone.dists.inv) <- 0

Moran.I(ozone$Av8top, ozone.dists.inv)

