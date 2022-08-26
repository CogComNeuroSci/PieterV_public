
library(R.matlab)

setwd("/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/PLV_data/")
####################################
##   Determine + and - clusters   ##
####################################

### Load data
###########################

filenames 		= c(	"OverviewClustersFeedbackCutoff0.9915625Negative.txt", 		"OverviewClustersFeedbackCutoff0.9915625Positive.txt")
filenames1 		= c(	"ClusterStatistic_neg_991.5625.txt", 				"ClusterStatistic_pos_991.5625.txt")


### Calculate statistics
###########################

clusterlevel		= 4

ClusterStatisticSummary = matrix(0, nrow = length(filenames1), ncol = 2)

for(sign in 1:2){
  
  # load the clustering of the observed data
  clusterlocations 	= read.table(filenames[sign], header = T)
  clusterlocations	= clusterlocations[clusterlocations$cluster==clusterlevel,"statistic"]
  
  # load the clustering of the randomized data
  randomclusters 	= read.table(filenames1[sign], header = F, sep = ";")
  randomclusters	= randomclusters[,clusterlevel]
  
  if(sign == 1){
    if (clusterlevel<3){
      ClusterStatisticSummary[sign,1] = min(clusterlocations)*length(clusterlocations)
      ClusterStatisticSummary[sign,2] = sum(randomclusters<ClusterStatisticSummary[sign,1])/length(randomclusters)
    }else{ # when there is no clusterlevel that high
        ClusterStatisticSummary[sign,1] = 0
        ClusterStatisticSummary[sign,2] = 1
    }
  }else{
      ClusterStatisticSummary[sign,1] = max(clusterlocations)*length(clusterlocations)
      ClusterStatisticSummary[sign,2] = sum(randomclusters>ClusterStatisticSummary[sign,1])/length(randomclusters)
  }
}

ClusterStatisticSummary


### Cluster level 1
###########################

# [,1] [,2]
# [1,] -266.9779    0
# [2,]  225.2922    0


### Cluster level 2
###########################

# [,1] [,2]
# [1,] -266.9779    0
# [2,]  225.2922    0


### Cluster level 3
###########################

# [,1] [,2]
# [1,] 0.000000    1
# [2,] 3.874714    0

### Cluster level 4
###########################

#       [,1]      [,2]
# [1,] 0.000000    1
# [2,] 2.524217    0
