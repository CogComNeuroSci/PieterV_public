Behavioral_folder   = '/Volumes/Harde ploate/EEG_reversal_learning/Behavioral_data/';
Power_folder        = '/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/Power_data/';

num_subjects=27;
num_trials=480;

Feedback=readtable([Behavioral_folder 'Feedback.csv']);
Feedback=table2array(Feedback);
Negative_indices=Feedback==0;
Positive_indices=Feedback==1;

Negative_indices=reshape(Negative_indices,480,27);
Positive_indices=reshape(Positive_indices,480,27);

load([Power_folder 'cluster_power_conservative']);

m_theta=nanmean(theta_cluster_power,2);
std_theta=nanstd(theta_cluster_power,0,2);

theta_cluster_power=(theta_cluster_power-m_theta)./std_theta;

m_delta=nanmean(delta_cluster_power,2);
std_delta=nanstd(delta_cluster_power,0,2);

delta_cluster_power=(delta_cluster_power-m_delta)./std_delta;

m_alpha=nanmean(alpha_cluster_power,2);
std_alpha=nanstd(alpha_cluster_power,0,2);

alpha_cluster_power=(alpha_cluster_power-m_alpha)./std_alpha;

for s=1:num_subjects
Cluster_theta_contrast(1,s)=nanmean(theta_cluster_power(s,Negative_indices(:,s)))-nanmean(theta_cluster_power(s,Positive_indices(:,s)));
Cluster_delta_contrast(1,s)=nanmean(delta_cluster_power(s,Negative_indices(:,s)))-nanmean(delta_cluster_power(s,Positive_indices(:,s)));
Cluster_alpha_contrast(1,s)=nanmean(alpha_cluster_power(s,Negative_indices(:,s)))-nanmean(alpha_cluster_power(s,Positive_indices(:,s)));
end;

filename='Power_data_individual.txt';

filePointer = fopen(filename, 'a');

fprintf(filePointer, '%d;', Cluster_theta_contrast);
fprintf(filePointer, '\n');
fprintf(filePointer, '%d;', Cluster_delta_contrast);
fprintf(filePointer, '\n');
fprintf(filePointer, '%d;', Cluster_alpha_contrast);
