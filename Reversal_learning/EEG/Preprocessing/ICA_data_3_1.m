function File_3_1_ICA_data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%                    run ICA                     %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath('/Users/pieter/Documents/MATLAB/eeglab14_1_2b')
eeglab                                                                              % open eeglab because otherwise the script gets stuck because some functions can't be found

subject_list    = {'pp3', 'pp5', 'pp6', 'pp7', 'pp9', 'pp10', 'pp12', 'pp14', 'pp15', 'pp16', 'pp18', 'pp19', 'pp20', 'pp21', 'pp22', 'pp23', 'pp24', 'pp25','pp26','pp27','pp28','pp29','pp30','pp31','pp32','pp33','pp34'};
num_subjects    = length(subject_list);                                             % n
parentfolder    = '/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/Filtered_files/';               % folder that holds all data

newfolder       = '/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/ICA_files/';                   % folder that will hold all original sets

%% Loop for all subjects
for s = 1:num_subjects
    % set subject and subjectfolder to subject s in the loop
    subject         = subject_list{s};                      % extract subject from subject array
    fprintf('\n\n\n***subject %d: %s***\n\n\n',s,subject);  % print what subject is being processed in command window
 
    % load data set 
    EEG =   pop_loadset('filename', ['Prob_reversal_filteredforICA' subject '.set'], 'filepath', parentfolder);
    
    % ICA run
    %EEG =   pop_runica(EEG, 'extended',1);
    EEG = pop_runica(EEG, 'extended',1,'interupt','on');
    
    pop_expica(EEG, 'weights', [newfolder '/ICA_weights_' subject '.txt']); 
    
    % save file as dataset (.set)
    EEG =   pop_editset(EEG, 'setname', subject);
            pop_saveset(EEG, 'filename', ['Prob_reversal_ICA_ready_' subject '.set'], 'filepath', newfolder); 
end
    
%% Finish
fprintf('\n\n\n***Finished ICA***\n\n\n');

% now the datasets are ready for manual ICA component rejection which we will save as [subject '_ICAremoved.set']
return
