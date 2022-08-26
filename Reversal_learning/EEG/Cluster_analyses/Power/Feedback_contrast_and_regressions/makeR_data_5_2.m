% Define folders and variables
Data_folder        = '/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/Power_data/';
R_folder            ='/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/lme_data/';

load([Data_folder 'cluster_power']);

cd '/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/lme_data/'

filename='cluster_data_conservative.txt';

num_subjects=27;

%write data
filePointer = fopen(filename, 'a');

fprintf(filePointer, '%d;', reshape(theta_cluster_power',1,[]));
fprintf(filePointer, '\n');
fprintf(filePointer, '%d;', reshape(delta_cluster_power',1,[]));
fprintf(filePointer, '\n');
fprintf(filePointer, '%d;', reshape(alpha_cluster_power',1,[]));

fclose(filePointer);
