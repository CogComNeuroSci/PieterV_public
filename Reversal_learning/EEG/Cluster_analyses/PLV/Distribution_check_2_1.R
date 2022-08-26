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
center_channels=10 # all this data is zero because data was lateralised. we adjust cutoffs accordingly
all_channels=64
perc=1-(center_channels/all_channels)
cutoff	= 1-c(0.005, 0.01, 0.025, 0.05, 0.1)*perc

### Plotting
###########################

setwd("/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/PLV_data/")

estobs 	= readMat("PLV_statistic.mat")
estobs 	= estobs$statistic
estimates 	= as.vector(estobs)
estimates1 	= estimates[order(estimates)] 

estobs 	= readMat("PLV_random.mat")
estobs 	= estobs$random.statistic
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
