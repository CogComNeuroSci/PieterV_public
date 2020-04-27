function Load_data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%               read data + channel locations               %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath('/Users/pieter/Documents/MATLAB/eeglab14_1_2b')
eeglab                                                                      % open eeglab because otherwise the script gets stuck because some functions can't be found

subject_list    = {'pp3', 'pp5', 'pp6', 'pp7', 'pp9', 'pp10', 'pp12', 'pp14', 'pp15', 'pp16', 'pp18', 'pp19', 'pp20', 'pp21', 'pp22', 'pp23', 'pp24', 'pp25', 'pp26', 'pp27','pp28','pp29','pp30','pp31','pp32','pp33','pp34'};
num_subjects    = length(subject_list);                                    
parentfolder    = '/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/Raw_data/';   
newfolder       = '/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/Loaded_files/';     

%% Loop for all subjects
for s = 27:27%num_subjects
    % set subject and subjectfolder to subject s in the loop
    subject = subject_list{s};                              % extract subject from subject array
    fprintf('\n\n\n***subject %d: %s***\n\n\n',s,subject);  % print what subject is being processed in command window
 
    % import Data from biosemi (bdf format) with average mastoid reference (channels 65 and 66)
    EEG =   pop_biosig([parentfolder, subject '.bdf'], 'ref',[65 66] );   
    
    % insert Channel Locations with standard BESA coordinates (installed with EEGlab) 
    EEG =   pop_chanedit(EEG, 'lookup','/Users/pieter/Documents/MATLAB/eeglab14_1_2b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp');
    % locations and labels for external channels
        % LH: links horizontaal ; RH: rechts horizontaal
        % LB: links boven ; LO: links onder
        % RB: rechts boven; RO: rechts onder
    EEG =   pop_chanedit(EEG,   'changefield',{67 'labels' 'LH'}, 'changefield',{68 'labels' 'RH'}, ...
                                'changefield',{69 'labels' 'LB'}, 'changefield',{70 'labels' 'LO'}, ...
                                'changefield',{71 'labels' 'RB'}, 'changefield',{72 'labels' 'RO'}, ...
                                'changefield',{67 'sph_theta' '42'}, 'changefield',{67 'sph_phi' '-28'}, 'changefield',{67 'sph_radius' '85'}, ...
                                'changefield',{68 'sph_theta' '-42'}, 'changefield',{68 'sph_phi' '-28'}, 'changefield',{68 'sph_radius' '85'}, ...
                                'changefield',{69 'sph_theta' '27'}, 'changefield',{69 'sph_phi' '-21'}, 'changefield',{69 'sph_radius' '85'}, ...
                                'changefield',{70 'sph_theta' '27'}, 'changefield',{70 'sph_phi' '-35'}, 'changefield',{70 'sph_radius' '85'}, ...
                                'changefield',{71 'sph_theta' '-27'}, 'changefield',{71 'sph_phi' '-21'}, 'changefield',{71 'sph_radius' '85'}, ...
                                'changefield',{72 'sph_theta' '-27'}, 'changefield',{72 'sph_phi' '-35'}, 'changefield',{72 'sph_radius' '85'});

    % convert tot sphericity
    EEG =   pop_chanedit(EEG, 'convert',{'sph2all'});
    % remove unused eye channels
    EEG =   pop_select(EEG, 'nochannel',{'RB'});   
    EEG =   pop_select(EEG, 'nochannel',{'RO'});  
    % remove average mastoid: EXG1 and EXG2
    EEG =   pop_select(EEG, 'nochannel',{'EXG1'}); 
    EEG =   pop_select(EEG, 'nochannel',{'EXG2'}); 
    
    
    % as we will be doing time-frequency we'll not downsample the data
    
    % save file as dataset (.set)
    EEG =   pop_editset(EEG, 'setname', subject);
            pop_saveset(EEG, 'filename', ['Prob_reversal_' subject '.set'], 'filepath', newfolder);
end

%% Finish
fprintf('\n\n\n***Finished loading data***\n\n\n');

% after this we open the data and manually cut out the breaks we save it as ['clean_' subject '.set']

return
