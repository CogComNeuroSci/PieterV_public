###################################################################
###               Analysis clusters feedback                    ###
###################################################################

library(R.matlab)


####################################
##   Determine + and - clusters   ##
####################################

### Distance matrix
###########################

setwd("/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/Cluster_data/")

distance	= readMat("ElectrodeDistance.mat")
distance	= data.frame(distance$epmap)
names		= readMat("ElectrodeNames.mat")
electrodes  = rep('',64)
for(elec in 1:length(electrodes)){
  electrodes[elec] = as.character(names$rownm[[elec]])
}
rownames(distance) = electrodes
colnames(distance) = electrodes

cutoff = 20
neighbours = matrix(9, nrow = 64, ncol = 64)
for(i in 1:64){
  neighbours[i,] 	= distance[i,]<40
  neighbours[i,i] 	= 0
  print(c(paste(electrodes[i], "   compatible  ", sep = ""), paste(electrodes[distance[i,]<cutoff], "    ", sep = "")))
  flush.console() 
}
#neighbours


### Load data
###########################

cutoff	= c(0.99)
negpos 	= c("Negative", "Positive")
nfreq 	= 25
ntime 	= 129
nchan 	= 64
indices 	= 1:(nfreq*ntime)
indicesElec = 1:nchan
clusternr 	= 1


### Start clustering
###########################

estobs 	= readMat("cluster_statistic_interaction.mat")
estobs 	= estobs$statistic
estimates1 	= as.vector(estobs)
estimates1 	= estimates1[order(estimates1)] 

for(c in 1:length(cutoff)){
  
  poscutoff 	= estimates1[length(estimates1)*   cutoff[c] ]
  negcutoff 	= estimates1[length(estimates1)*(1-cutoff[c])]
  
  for(sign in 1:2){
    clusters 			= array(0, dim = c(nfreq, nchan, ntime))
    nsign 			= sum(as.vector(estobs)<=negcutoff)+sum(as.vector(estobs)>=poscutoff)
    clusterlocations 		= data.frame(matrix(0, nrow = nsign, ncol = 6))
    names(clusterlocations) = c("voxelnumber","cluster","freq","chan","time","statistic")
    for(chan in 1:nchan){
      
      estimates			= as.vector(estobs[,chan,])
      
      if(sign == 1){
        idx 			= indices[estimates <= negcutoff]
      }else{
        idx 			= indices[estimates >= poscutoff]
      }
      
      freqidx 			= idx%%nfreq
      freqidx[freqidx==0] 	= nfreq
      timeidx 			= ceiling(idx/nfreq)
      
      neighbourElectrode 	= indicesElec[neighbours[chan,]==1]
      chans				= c(chan,neighbourElectrode)
      
      if(length(freqidx)>0){
        for(i in 1:length(timeidx)){
          
          freqs = freqidx[i] + (-1:1)
          times	= timeidx[i] + (-1:1)
          
          freqs = freqs[freqs>0]
          freqs = freqs[freqs<=nfreq]
          
          times = times[times>0]
          times = times[times<=ntime]
          
          identifiedClusters = unique(as.vector(clusters[freqs, chans, times]))
          
          if(max(identifiedClusters)>0){
            # we are touching upon a voxel that is already clustered
            identifiedClusters 	= identifiedClusters[identifiedClusters!=0]
            clusternr 			= min(identifiedClusters)
            clusterlocations[clusterlocations$cluster %in% identifiedClusters, "cluster"] = clusternr
            voxelnumbers = clusterlocations[clusterlocations$cluster == clusternr, "voxelnumber"]
            for(j in 1:length(voxelnumbers)){
              clusters[clusterlocations$freq[voxelnumbers[j]], clusterlocations$chan[voxelnumbers[j]], clusterlocations$time[voxelnumbers[j]]] = clusternr
            }
          }else{
            # this is a new cluster
            clusternr 			= max(clusterlocations$cluster) + 1
          }
          
          for(row in 1:length(freqs)){
            for(col in 1:length(chans)){
              for(timei in 1:length(times)){
                
                rowcheck 	= clusterlocations[clusterlocations$freq==freqs[row] 	, "voxelnumber"]
                colcheck 	= clusterlocations[clusterlocations$time==times[timei] 	, "voxelnumber"]
                timecheck 	= clusterlocations[clusterlocations$chan==chans[col], "voxelnumber"]
                
                rowcheck 	= rowcheck[rowcheck %in% colcheck]
                rowcheck 	= rowcheck[rowcheck %in% timecheck]
                
                if(length(rowcheck)==0){
                  if(sign == 1){
                    CO	= estobs[freqs[row], chans[col], times[timei]] <= negcutoff
                  }else{
                    CO 	= estobs[freqs[row], chans[col], times[timei]] >= poscutoff
                  }
                  if(CO == TRUE){
                    clusters[freqs[row], chans[col], times[timei]] 	= clusternr
                    currentlocation = sum(clusterlocations$cluster!=0)+1
                    clusterlocations[currentlocation,"voxelnumber"] = max(clusterlocations$voxelnumber)+1
                    clusterlocations[currentlocation,"cluster"] 	= clusternr
                    clusterlocations[currentlocation,"freq"] 		= freqs[row]
                    clusterlocations[currentlocation,"chan"] 		= chans[col]
                    clusterlocations[currentlocation,"time"] 		= times[timei]
                    clusterlocations[currentlocation,"statistic"] 	= estobs[freqs[row], chans[col], times[timei]]
                  }
                }
              }
            }
          }
          print(paste("Cutoff",c," Sign",sign," Channel",chan," Voxel",i, sep = ""))
          flush.console() 
        }
      }
    }
    
    clusterlocations 			= clusterlocations[clusterlocations$cluster!=0,]
    clusterlocations$cluster	= clusterlocations$cluster + max(clusterlocations$cluster)
    
    allclusters 			= unique(clusterlocations$cluster)
    allclusters				= allclusters[order(allclusters)]
    frequency 				= xtabs(~cluster, clusterlocations)
    frequencyorder			= order(frequency)
    frequencyorder			= frequencyorder[length(frequencyorder):1]
    
    for(i in 1:length(frequencyorder)){
      clusterlocations[clusterlocations$cluster==allclusters[frequencyorder[i]],"cluster"] = i
    }
    xtabs(~cluster ,clusterlocations)
    
    clusters2 	= array(0, dim = c(nfreq, nchan, ntime))
    for(i in 1:dim(clusterlocations)[1]){
      clusters2[clusterlocations$freq[i], clusterlocations$chan[i], clusterlocations$time[i]] = clusterlocations$cluster[i]
    }
    
    name = paste("OverviewClustersFeedbackCutoff", cutoff[c], negpos[sign], "_interaction.txt", sep = "")
    
    write(names(clusterlocations), file = name, ncolumns = dim(clusterlocations)[2], append = FALSE, sep = "\t")
    write(t(clusterlocations), 	 file = name, ncolumns = dim(clusterlocations)[2], append = TRUE,  sep = "\t")
  }
}