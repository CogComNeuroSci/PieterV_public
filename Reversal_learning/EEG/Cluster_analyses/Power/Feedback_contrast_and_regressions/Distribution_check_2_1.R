###################################################################
###               Analysis clusters feedback                   ###
###################################################################

library(R.matlab)


####################################
##    Plot the voxel statistic    ##
####################################

### Load data
###########################

palette 	= c("blue", "light green", "yellow", "orange", "red")
cutoff	= c(0.995, 0.99, 0.975, 0.95, 0.90)

### Plotting
###########################

setwd("/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/Cluster_data/")

# Load statistic
estobs 	= readMat("FB_Cluster_statistic.mat")
estobs 	= estobs$statistic
estimates 	= as.vector(estobs)
estimates1 	= estimates[order(estimates)] 

# Load random statistic
estobs 	= readMat("FB_random_statistic.mat")
estobs 	= estobs$statistic
estimates 	= as.vector(estobs)
estimates2 	= estimates[order(estimates)] 


tiff("Overview voxel statistics Feedback.tiff", width = 1500, height = 750)

par(mfrow = c(2,1))
hist(estimates1, nclass=200, xlim = c(min(estimates1,estimates2), max(estimates1,estimates2)), xlab = "Observed",main="Observed statistics")

for(i in 1:5){
  abline(v = estimates1[length(estimates1)*   cutoff[i] ], col = palette[i], lwd = 2)
  abline(v = estimates1[length(estimates1)*(1-cutoff[i])], col = palette[i], lwd = 2)
}

hist(estimates2, nclass = 200, xlim = c(min(estimates1,estimates2), max(estimates1,estimates2)), xlab = "Random", main = "Random statistics")

for(i in 1:5){
  abline(v = estimates1[length(estimates2)*   cutoff[i] ], col = palette[i], lwd = 2)
  abline(v = estimates1[length(estimates2)*(1-cutoff[i])], col = palette[i], lwd = 2)
}

dev.off()