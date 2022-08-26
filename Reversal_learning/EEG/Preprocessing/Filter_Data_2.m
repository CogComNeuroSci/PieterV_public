function Filter_Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%               Filter data                                 %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath('/Users/pieter/Documents/MATLAB/eeglab14_1_2b')
eeglab                                                                      % open eeglab because otherwise the script gets stuck because some functions can't be found

subject_list    = {'pp3', 'pp5', 'pp6', 'pp7', 'pp9', 'pp10', 'pp12', 'pp14', 'pp15', 'pp16', 'pp18', 'pp19', 'pp20', 'pp21', 'pp22', 'pp23', 'pp24', 'pp25','pp26','pp27','pp28','pp29','pp30','pp31','pp32','pp33','pp34'};
num_subjects    = length(subject_list);                                    
parentfolder    = '/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/Loaded_files/';  
newfolder       = '/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/Filtered_files/';  

for s = 1:num_subjects
    % set subject and subjectfolder to subject s in the loop
    subject = subject_list{s};                              % extract subject from subject array
    fprintf('\n\n\n***subject %d: %s***\n\n\n',s,subject);  % print what subject is being processed in command window
    
    % load data set 
    EEG =   pop_loadset('filename', ['clean_' subject  '.set'], 'filepath', parentfolder);
    
    %interpolate channels

    if s==5 %subject=='pp9'
        EEG =   eeg_interp(EEG, 58);
    end;   

    if s==10 %subject=='pp16'
        EEG =   eeg_interp(EEG, 29);
        EEG =   eeg_interp(EEG, 30);
    end; 
    
    if s==14 %subject=='pp21'
        EEG =   eeg_interp(EEG, 26);
        EEG =   eeg_interp(EEG, 28);
        EEG =   eeg_interp(EEG, 29);
        EEG =   eeg_interp(EEG, 30);
        EEG =   eeg_interp(EEG, 57);
    end;  
    
    if s==15 %subject=='pp22'
        EEG =   eeg_interp(EEG, 25);
        EEG =   eeg_interp(EEG, 57);
    end;
    
    if s==16 %subject=='pp23'
        EEG =   eeg_interp(EEG, 57);
    end;  
    
    if s==23 %subject='pp30'
        EEG =   eeg_interp(EEG, 62);
        EEG =   eeg_interp(EEG, 15);
    end; 
    
    if s==27 %subject=='pp34'
        EEG =   eeg_interp(EEG, 24);
    end;
    
    EEG = pop_eegfiltnew(EEG, 1,48,3380,0,[],1);
    
    % save file as dataset (.set)
    EEG =   pop_editset(EEG, 'setname', subject);
            pop_saveset(EEG, 'filename', ['Prob_reversal_filteredforICA' subject '.set'], 'filepath', newfolder);
end
%}
%% Finish
fprintf('\n\n\n***Finished filtering data***\n\n\n');

% We filtered the data and removed + interpolated bad channels that were visually detected during recording

return
