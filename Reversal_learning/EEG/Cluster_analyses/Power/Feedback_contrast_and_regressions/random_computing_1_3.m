% Define folders and variables
indicesfolder         = '/Volumes/Harde ploate/EEG_reversal_learning/Behavioral_data/Indices/';

cd '/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/Cluster_data/';

%% First for feedback-locked data
load('FB_cluster_raw')

num_trials=480;
num_subjects=27;

%get feedback indices and randomly shuffle them
Feedback=readtable([indicesfolder, 'Feedback.csv']);
Feedback=table2array(Feedback);

for s = 1:num_subjects
    idx = repmat((s-1)*num_trials,1,num_trials)+(1:num_trials);
    Feedback(idx) = Feedback(idx(randperm(num_trials)));
end;

Negative_indices=Feedback==0;
Positive_indices=Feedback==1;

%compute statistic
statistic=nanmean(Power_tocluster(:,:,:,Negative_indices),4)-nanmean(Power_tocluster(:,:,:,Positive_indices),4);

save('FB_random_statistic','statistic')

clear all

%% Now for stimulus-locked data
load('Stim_cluster_raw')

%get feedback indices and randomly shuffle them
Feedback=readtable([indicesfolder 'P_FB.csv']);
Feedback=table2array(Feedback);

for s = 1:num_subjects
    idx = repmat((s-1)*num_trials,1,num_trials)+(1:num_trials);
    Feedback(idx) = Feedback(idx(randperm(num_trials)));
end;

Negative_indices=Feedback==0;
Positive_indices=Feedback==1;

%compute statistic
statistic=nanmean(Power_tocluster(:,:,:,Negative_indices),4)-nanmean(Power_tocluster(:,:,:,Positive_indices),4);

save('Stim_random_statistic','statistic')