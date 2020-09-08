subject_list    = {'pp3', 'pp5', 'pp6', 'pp7', 'pp9', 'pp10', 'pp12', 'pp14', 'pp15', 'pp16', 'pp18', 'pp19', 'pp20', 'pp21', 'pp22', 'pp23', 'pp24', 'pp25','pp26','pp27','pp28','pp29','pp30','pp31','pp32','pp33','pp34'};
num_subjects    = length(subject_list);               %number of subjects

behavioral_folder   = '/Volumes/Harde ploate/EEG_reversal_learning/Behavioral_data/Indices/';
TF_folder ='/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/TF_data/';
PLV_folder ='/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/PLV_data/';

srate=512;
timestep=1000/srate;
time_feedback=-1000:timestep:2500;
tid=find(time_feedback==500);
zone=1000/timestep;
time=tid-zone:tid+zone;

frex=logspace(log10(2), log10(48), 25);               %frequency vector for data
n_channels=64;                                        %number of channels
n_trials=480;

Feedback=readtable([behavioral_folder 'Feedback.csv']);
Feedback=table2array(Feedback);
Negative_indices=Feedback==0;
Positive_indices=Feedback==1;

Side=readtable([behavioral_folder 'Side.csv']);
Side=table2array(Side);
left_indices=Side==0;
right_indices=Side==1;

left_pos=(left_indices+Positive_indices)==2;
left_neg=(left_indices+Negative_indices)==2;
right_pos=(right_indices+Positive_indices)==2;
right_neg=(right_indices+Negative_indices)==2;

for s=1:num_subjects
    sub=subject_list{s};
    load([TF_folder 'tf_feedback_' sub])
    Data=NaN(length(frex),n_channels,length(time),n_trials);
    Data(:,1:32,1:zone*2+1,:)=angle(feedback_tf_frontal(:,:,tid-zone:tid+zone,:));
    clear feedback_tf_frontal
    Data(:,33:64,1:zone*2+1,:)=angle(feedback_tf_posterior(:,:,tid-zone:tid+zone,:));
    clear feedback_tf_posterior
    
    PLV_all=NaN(length(frex),n_channels,n_channels, length(time));
    PLV_left_pos=NaN(length(frex),n_channels,n_channels, length(time));
    PLV_left_neg=NaN(length(frex),n_channels,n_channels, length(time));
    PLV_right_pos=NaN(length(frex),n_channels,n_channels, length(time));
    PLV_right_neg=NaN(length(frex),n_channels,n_channels, length(time));
    
    for c1=1:n_channels
        for c2=1:n_channels
            PLV_all(:,c1,c2,:)=abs(nanmean(imag(exp(-1i*(Data(:,c1,:,:)-Data(:,c2,:,:)))),4));
            PLV_left_pos(:,c1,c2,:)=abs(nanmean(imag(exp(-1i*(Data(:,c1,:,left_pos((s-1)*n_trials+1:s*n_trials))-Data(:,c2,:,left_pos((s-1)*n_trials+1:s*n_trials))))),4));
            PLV_left_neg(:,c1,c2,:)=abs(nanmean(imag(exp(-1i*(Data(:,c1,:,left_neg((s-1)*n_trials+1:s*n_trials))-Data(:,c2,:,left_neg((s-1)*n_trials+1:s*n_trials))))),4));
            PLV_right_pos(:,c1,c2,:)=abs(nanmean(imag(exp(-1i*(Data(:,c1,:,right_pos((s-1)*n_trials+1:s*n_trials))-Data(:,c2,:,right_pos((s-1)*n_trials+1:s*n_trials))))),4));
            PLV_right_neg(:,c1,c2,:)=abs(nanmean(imag(exp(-1i*(Data(:,c1,:,right_neg((s-1)*n_trials+1:s*n_trials))-Data(:,c2,:,right_neg((s-1)*n_trials+1:s*n_trials))))),4));
        end;
    end;
    
    save(['PLV_conditions' sub], 'PLV_all', 'PLV_left_pos', 'PLV_left_neg','PLV_right_pos', 'PLV_right_neg', '-v7.3')
    clear PLV_all PLV_positive PLV_negative
    clear Data
end;
                        
