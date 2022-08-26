###################################################################
###               Analysis clusters feedback                    ###
###################################################################

library(R.matlab)


####################################
##   Determine + and - clusters   ##
####################################

### Load data
###########################

setwd("/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/Cluster_data/")
logspace <- function( d1, d2, n) exp(log(10)*seq(d1, d2, length.out=n)) 

freq 				= logspace(log10(2),log10(48),25)
time 				= seq(-500,2000, by =1000/51.2)
timepos 		= 1:length(time)
palette 		= c("blue", "light green", "yellow", "orange", "red")
rgb.palette = colorRampPalette(palette, space = "rgb")
cutoff			= c(0.990)
negpos 			= c("Negative", "Positive")
nfreq 			= 25
ntime 			= 129
nchan 			= 64
indices 		= 1:(nfreq*ntime)
indicesElec = 1:nchan
clusternr 	= 1


### Plotting
###########################

estobs 	= readMat("cluster_statistic_interaction.mat")
estobs 	= estobs$statistic
estimates 	= as.vector(estobs)
estimates1 	= estimates[order(estimates)] 

for(c in 1:length(cutoff)){
  for(sign in 1:2){
    
    name 			= paste("OverviewClustersFeedbackCutoff", cutoff[c], negpos[sign], "_interaction.txt", sep = "")
    clusterlocations 	= read.table(name, header = T)
    
    clusters2 		= array(0, dim = c(nfreq, nchan, ntime))
    for(i in 1:dim(clusterlocations)[1]){
      clusters2[clusterlocations$freq[i], clusterlocations$chan[i], clusterlocations$time[i]] = clusterlocations$cluster[i]
    }
    
    for(clusi in 1:3){
      
      tf = matrix(0, nrow = nfreq, ncol = ntime)
      for(chanI in 1:nchan){
        for(timeI in 1:ntime){
          tf[,timeI] = tf[,timeI] + as.numeric(clusters2[1:nfreq,chanI,timeI]==clusi)
        }
      }
      adjustment 	= mean(c(max(tf),min(tf)))
      tf		= tf - adjustment
      minimum 	= floor(min(tf))
      maximum 	= ceiling(max(tf))
      
      name = paste("Overview Clusters TFplot Feedback Cutoff ", cutoff[c], " ", negpos[sign], " Cluster ", clusi, "_interaction.tiff", sep = "")
      tiff(name, width = 500, height = 500)
      
      par(mfrow = c(1,2), mar = c(4, 5, 6, 0))
      filled.contour(
        x = time[timepos]/1000, y = freq, z = t(tf), 
        zlim 		= range(z, finite = TRUE),
        levels 	= pretty(c(min(tf)-0.1,max(tf)), 10),
        color 	= rgb.palette, 
        frame.plot 	= FALSE,
        plot.title 	= title(main = paste("Feedback SRPE \n Cutoff ", cutoff[c], " ", negpos[sign], " Cluster ", clusi, sep = ""), xlab = "", ylab = ""),
        plot.axes 	= { 	axis(1, seq(0, 3, by = 0.5))
          axis(2, seq(0, 50, by = 5)) },
        key.title 	= title(main = "\n\n Voxels"))
      
      dev.off()
    }
    
    name = paste("Overview Clusters Histogram Feedback Cutoff ", cutoff[c], " ", negpos[sign], "_interaction.tiff", sep = "")
    tiff(name, width = 1500, height = 750)
    
    par(mfrow = c(2,2))
    hist(estimates1, 		nclass = 200, 				xlim = c(min(estimates1), max(estimates1)), xlab = "Observed", main = "Feedback SRPE")
    
    for(i in 1:5){
      abline(v = estimates1[length(estimates1)*   cutoff[i] ], col = palette[i], lwd = 2)
      abline(v = estimates1[length(estimates1)*(1-cutoff[i])], col = palette[i], lwd = 2)
    }
    
    for(clusi in 1:3){
      dat = clusterlocations[clusterlocations$cluster==clusi,"statistic"]
      if(length(dat)!=0){
        hist(dat, 	nclass = ceiling(length(dat)*0.2), 	xlim = c(min(estimates1), max(estimates1)), xlab = "Observed", main = "Feedback SRPE", col = palette[c], ylim = c(0,40))
      }
    }
    dev.off()
  }
}