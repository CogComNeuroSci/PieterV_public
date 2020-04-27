  % if you want to check the power spectrum of Cleaned_files
addpath('/users/pieter/Documents/MATLAB/eeglab14_1_2b')
eeglab
  
parentfolder          = '/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/Cleaned_files/';

subject_list    = {'pp3', 'pp5', 'pp6', 'pp7', 'pp9', 'pp10', 'pp12', 'pp14', 'pp15', 'pp16', 'pp18', 'pp19', 'pp20', 'pp21', 'pp22', 'pp23', 'pp24', 'pp25','pp26','pp27','pp28','pp29','pp30','pp31','pp32','pp33','pp34'};
num_subjects    = length(subject_list);
    
subject         = subject_list{s}; 
EEG =   pop_loadset('filename', ['Cleaned_' subject '_F.set'], 'filepath', parentfolder); 

[psds, freqs] = pwelch(EEG.data(1,:,1)', 200, [], [], EEG.srate);

freqs = freqs';
psds = psds';

settings = struct();
f_range = [1, 50];

fooof_results = fooof(freqs, psds, f_range, settings);

fooof_results
