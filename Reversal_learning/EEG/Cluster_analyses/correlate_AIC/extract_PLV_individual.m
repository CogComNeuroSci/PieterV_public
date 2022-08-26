%% extract PLV contrast for each cluster and each participant
cd '/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/PLV_data/';

load('PLV_conditions_lat_all')
Contrast=PLV_lat_neg_all-PLV_lat_pos_all;
frex=logspace(log10(2), log10(48), 25);  
num_subjects=27;
n_channels=64;

Data_actual_Positive=readtable('OverviewClustersFeedbackCutoff0.9915625Positive.txt');
Data_actual_Positive=table2array(Data_actual_Positive);

Data_actual_Negative=readtable('OverviewClustersFeedbackCutoff0.9915625Negative.txt');
Data_actual_Negative=table2array(Data_actual_Negative);

cluster1_actual_positive=Data_actual_Positive(:,2)==1;
cluster2_actual_positive=Data_actual_Positive(:,2)==2;

cluster3_actual_positive=Data_actual_Positive(:,2)==3;
cluster4_actual_positive=Data_actual_Positive(:,2)==4;

cluster1_actual_negative=Data_actual_Negative(:,2)==1;
cluster2_actual_negative=Data_actual_Negative(:,2)==2;

cluster_theta_ipsi=Data_actual_Positive(cluster2_actual_positive,:);
cluster_theta_contra=Data_actual_Positive(cluster1_actual_positive,:);
cluster2_theta_ipsi=Data_actual_Positive(cluster3_actual_positive,:);
cluster2_theta_contra=Data_actual_Positive(cluster4_actual_positive,:);
cluster_delta_ipsi=Data_actual_Negative(cluster2_actual_negative,:);
cluster_delta_contra=Data_actual_Negative(cluster1_actual_negative,:);

theta_ipsicluster_post=NaN(num_subjects, length(frex),n_channels,205);

theta_ipsicluster_front=NaN(num_subjects, length(frex),n_channels,205);

for i=1:size(cluster_theta_ipsi,1)
    theta_ipsicluster_post(:,cluster_theta_ipsi(i,3), cluster_theta_ipsi(i,4), cluster_theta_ipsi(i,5))=Contrast(:,cluster_theta_ipsi(i,3), cluster_theta_ipsi(i,4), cluster_theta_ipsi(i,5));
end;
for i=1:size(cluster2_theta_ipsi,1)
    theta_ipsicluster_front(:,cluster2_theta_ipsi(i,3), cluster2_theta_ipsi(i,4), cluster2_theta_ipsi(i,5))=Contrast(:,cluster2_theta_ipsi(i,3), cluster2_theta_ipsi(i,4), cluster2_theta_ipsi(i,5));
end;

theta_ipsicluster_post=squeeze(nanmean(nanmean(nanmean(theta_ipsicluster_post,4),3),2));

theta_ipsicluster_front=squeeze(nanmean(nanmean(nanmean(theta_ipsicluster_front,4),3),2));

theta_contracluster_post=NaN(num_subjects, length(frex),n_channels,205);

theta_contracluster_front=NaN(num_subjects, length(frex),n_channels,205);

for i=1:size(cluster_theta_contra,1)
    theta_contracluster_post(:,cluster_theta_contra(i,3), cluster_theta_contra(i,4), cluster_theta_contra(i,5))=Contrast(:,cluster_theta_contra(i,3), cluster_theta_contra(i,4), cluster_theta_contra(i,5));
end;
for i=1:size(cluster2_theta_contra,1)
    theta_contracluster_front(:,cluster2_theta_contra(i,3), cluster2_theta_contra(i,4), cluster2_theta_contra(i,5))=Contrast(:,cluster2_theta_contra(i,3), cluster2_theta_contra(i,4), cluster2_theta_contra(i,5));
end;

theta_contracluster_post=squeeze(nanmean(nanmean(nanmean(theta_contracluster_post,4),3),2));

theta_contracluster_front=squeeze(nanmean(nanmean(nanmean(theta_contracluster_front,4),3),2));

delta_ipsicluster=NaN(num_subjects, length(frex),n_channels,205);

for i=1:size(cluster_delta_ipsi,1)
    delta_ipsicluster(:,cluster_delta_ipsi(i,3), cluster_delta_ipsi(i,4), cluster_delta_ipsi(i,5))=Contrast(:,cluster_delta_ipsi(i,3), cluster_delta_ipsi(i,4), cluster_delta_ipsi(i,5));
end;

delta_ipsicluster=squeeze(nanmean(nanmean(nanmean(delta_ipsicluster,4),3),2));

delta_contracluster=NaN(num_subjects, length(frex),n_channels,205);

for i=1:size(cluster_delta_contra,1)
    delta_contracluster(:,cluster_delta_contra(i,3), cluster_delta_contra(i,4), cluster_delta_contra(i,5))=Contrast(:,cluster_delta_contra(i,3), cluster_delta_contra(i,4), cluster_delta_contra(i,5));
end;

delta_contracluster=squeeze(nanmean(nanmean(nanmean(delta_contracluster,4),3),2));

filename='PLV_data_individual.txt';

filePointer = fopen(filename, 'a');

fprintf(filePointer, '%d;', reshape(theta_contracluster_post,1,[]));
fprintf(filePointer, '\n');
fprintf(filePointer, '%d;', reshape(theta_ipsicluster_post,1,[]));
fprintf(filePointer, '\n');
fprintf(filePointer, '%d;', reshape(theta_contracluster_front,1,[]));
fprintf(filePointer, '\n');
fprintf(filePointer, '%d;', reshape(theta_ipsicluster_front,1,[]));
fprintf(filePointer, '\n');
fprintf(filePointer, '%d;', reshape(delta_contracluster,1,[]));
fprintf(filePointer, '\n');
fprintf(filePointer, '%d;', reshape(delta_ipsicluster,1,[]));
