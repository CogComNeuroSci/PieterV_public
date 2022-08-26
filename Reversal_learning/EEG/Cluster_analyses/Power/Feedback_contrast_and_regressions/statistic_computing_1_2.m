% Define folders
indicesfolder         = '/Volumes/Harde ploate/EEG_reversal_learning/Behavioral_data/Indices/';

cd '/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/Cluster_data/';

%% First for feedback-locked data
load('FB_cluster_raw')

% Get feedback indices
Feedback=readtable([indicesfolder, 'Feedback.csv']);
Feedback=table2array(Feedback);
Negative_indices=Feedback==0;
Positive_indices=Feedback==1;

%compute statistic
statistic=nanmean(Power_tocluster(:,:,:,Negative_indices),4)-nanmean(Power_tocluster(:,:,:,Positive_indices),4);

save('FB_cluster_statistic','statistic')

clear all

%% Now for stimulus-locked data
load('Stim_cluster_raw')

% Get feedback indices from previous trial
Feedback=readtable([indicesfolder, 'P_FB.csv']);
Feedback=table2array(Feedback);
Negative_indices=Feedback==0;
Positive_indices=Feedback==1;

%compute statistic
statistic=nanmean(Power_tocluster(:,:,:,Negative_indices),4)-nanmean(Power_tocluster(:,:,:,Positive_indices),4);

save('Stim_cluster_statistic','statistic')