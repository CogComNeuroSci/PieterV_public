library(R.matlab)

setwd("/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/Cluster_data/")
####################################
##   Determine + and - clusters   ##
####################################

### Load data
###########################

filenames 		= c(	"OverviewClustersFeedbackCutoff0.99Negative_PE.txt", 		"OverviewClustersFeedbackCutoff0.99Positive_PE.txt")
filenames1 		= c(	"ClusterStatisticFeedback_neg_990_PE.txt", 				"ClusterStatisticFeedback_pos_990_PE.txt")

### Calculate statistics
###########################

clusterlevel		= 2

ClusterStatisticSummary = matrix(0, nrow = length(filenames1), ncol = 2)

for(sign in 1:2){
  
  # load the clustering of the observed data
  clusterlocations 	= read.table(filenames[sign], header = T)
  clusterlocations	= clusterlocations[clusterlocations$cluster==clusterlevel,"statistic"]
  
  # load the clustering of the randomized data
  randomclusters 	= read.table(filenames1[sign], header = F, sep = ";")
  randomclusters	= randomclusters[,clusterlevel]
  
  if(sign == 1){
    ClusterStatisticSummary[sign,1] = min(clusterlocations)*length(clusterlocations)
    ClusterStatisticSummary[sign,2] = sum(randomclusters<ClusterStatisticSummary[sign,1])/length(randomclusters)
  }else{
    if (clusterlevel==1){
      ClusterStatisticSummary[sign,1] = max(clusterlocations)*length(clusterlocations)
      ClusterStatisticSummary[sign,2] = sum(randomclusters>ClusterStatisticSummary[sign,1])/length(randomclusters)
    }else{ # when there is no clusterlevel that high
      ClusterStatisticSummary[sign,1] = 0
      ClusterStatisticSummary[sign,2] = 1
    }
  }
}

ClusterStatisticSummary


### Cluster level 1
###########################

#      [,1]      [,2]
#[1,] -270.9322    0
#[2,]  216.9425    0


### Cluster level 2
###########################

#       [,1]      [,2]
# [1,] -305.3338    0
# [2,]    0.0000    1


### Cluster level 3
###########################

#         [,1]    [,2]
# [1,] -6.829327 0.797
# [2,]  0.000000 1.000
