indicesfolder         = '/Volumes/Harde ploate/EEG_reversal_learning/Behavioral_data/Indices/';

cd '/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/Cluster_data/';

load('FB_cluster_raw')

num_trials=480;
num_subjects=27;

Feedback=readtable([indicesfolder, 'Feedback.csv']);
Feedback=table2array(Feedback);

for s = 1:num_subjects
    idx = repmat((s-1)*num_trials,1,num_trials)+(1:num_trials);
    Feedback(idx) = Feedback(idx(randperm(num_trials)));
end;

Negative_indices=Feedback==0;
Positive_indices=Feedback==1;

statistic=nanmean(Power_tocluster(:,:,:,Negative_indices),4)-nanmean(Power_tocluster(:,:,:,Positive_indices),4);

save('FB_random_statistic','statistic')

clear all

load('Stim_cluster_raw')

Feedback=readtable([indicesfolder 'P_FB.csv']);
Feedback=table2array(Feedback);

for s = 1:num_subjects
    idx = repmat((s-1)*num_trials,1,num_trials)+(1:num_trials);
    Feedback(idx) = Feedback(idx(randperm(num_trials)));
end;

Negative_indices=Feedback==0;
Positive_indices=Feedback==1;

statistic=nanmean(Power_tocluster(:,:,:,Negative_indices),4)-nanmean(Power_tocluster(:,:,:,Positive_indices),4);

save('Stim_random_statistic','statistic')