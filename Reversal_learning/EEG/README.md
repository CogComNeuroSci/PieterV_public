# EEG folder

Order of execution is:
---
##1. Preprocessing
*1. Load_Data*: to extract all data and define electrode mapping
*2. manclean*: record of all manual cleaning
*3. Filter_Data*: frequency filtering data
*4. ICA_data*: Code to perform ICA
*5. ICA_removal and ICA_removal_special*: record of removed ICA components, special file is for a subject that was rank-deficient due to interpolating of channels.
*6. Epoching_data*: to epoch the data
*7. epoch_cleaning*: removing the bad epochs
___

##2. Time-Frequency
*1. baseline_extraction+tf_stim*: extracting the time-frequency decomposition of the stimulus epochs and the baseline period
*2. tf_feedback*: time-frequency decomposition of feedback period
*3. Extracting_phase_and_power*: from time-frequency data extract and baseline the power and extract phase data.
*4. Decibel_conversion*: convert power to decibel scale
___

##3. PLV
*1. PLV_conditions*: compute PLV for each condition
*2. PLV_lateralisation*: lateralize PLV data
___

##4. Cluster_analyses
*0. electrodedistance*: For clustering, we first make a distance matrix for all electrodes

**Power folder**
First, open *Feedback_contrast_and_regressions*
*1.1 Preparing*: Z-scoring data and remove data with too late responses.
*1.2. statistic_computing* : compute the contrast
*1.3. random_computing* : compute one instance of the random shufled contrast.
*2.1. Distribution_check* : check the distribution of your statistics, this might help to determine a good cutoff for clustering.
*2.2. Clustering_checkout* : preliminary check (one random shuffle) of which clusters survive with different cutoffs.
*2.3. plots_cluster_checkout*: plot clusters that survive with different cutoffs
*3.1. cluster_permutation* : Compute multiple instances of the random statistic
*3.2. cluster_test* : test whether clusters survive statistical thresholding
*4.1. cluster_plots* : makes plots of the cluster topography in time-frequency and channel domain
*5.1. extract_clusterpower* : extract power of each cluster
*5.2. makeR_data* :convert this data to a text file for analyses in R
*5.3. lme_cluster_5_3* : perform linear (mixed) regresion on power data

In the *Interactions* folder one can find the same analyses but for the interaction effect of reward and Prediction error.

**PLV folder**
Holds the same analyses as the power folder but for the phase locking statistic.

**Correlate_AIC folder**
*1. extract_power_individual*: extract power data for each cluster and each participant
*2. extract_PLV_individual*: extract PLV data for each cluster and each participant
*3. corr_AIC* : check for correlations between model evidence and effects in neural data
___

##5. Trial_window_analyses
*1. Locking_power* : lock power of each cluster to rule switches
*2. regression_locking : perform linear regression for empirical power depending on model simulation power.