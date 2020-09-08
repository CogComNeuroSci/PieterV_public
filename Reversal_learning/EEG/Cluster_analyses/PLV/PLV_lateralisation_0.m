subject_list    = {'pp3', 'pp5', 'pp6', 'pp7', 'pp9', 'pp10', 'pp12', 'pp14', 'pp15', 'pp16', 'pp18', 'pp19', 'pp20', 'pp21', 'pp22', 'pp23', 'pp24', 'pp25','pp26','pp27','pp28','pp29','pp30','pp31','pp32','pp33','pp34'};
num_subjects    = length(subject_list);               %number of subjects

homefolder         = '/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/';

load([homefolder 'chanloc'])
chanlocations=chanlocations(1:64);
[~, sortid_pf]=sort([chanlocations(:).X]);
right_channels=[chanlocations(:).Y]<-1;
left_channels=[chanlocations(:).Y]>1;
center_channels=(([chanlocations(:).Y]<1)+([chanlocations(:).Y]>-1))==2;
peak_channel=9;

cd '/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/PLV_data';
for s=1:num_subjects
    sub=subject_list{s};
    load(['PLV_conditions' sub], 'PLV_left_pos', 'PLV_left_neg','PLV_right_pos', 'PLV_right_neg')
    
    PLV_lat_pos(:,:,left_channels,:)=(PLV_left_pos(:,center_channels,left_channels,:)+PLV_right_pos(:,center_channels,right_channels,:))./2;
    PLV_lat_pos(:,:,right_channels,:)=(PLV_left_pos(:,center_channels,right_channels,:)+PLV_right_pos(:,center_channels,left_channels,:))./2;

    PLV_lat_neg(:,:,left_channels,:)=(PLV_left_neg(:,center_channels,left_channels,:)+PLV_right_neg(:,center_channels,right_channels,:))./2;
    PLV_lat_neg(:,:,right_channels,:)=(PLV_left_neg(:,center_channels,right_channels,:)+PLV_right_neg(:,center_channels,left_channels,:))./2;
    
    PLV_lat_pos_all(s,:,:,:)=squeeze(PLV_lat_pos(:,peak_channel,:,1:5:end));
    PLV_lat_neg_all(s,:,:,:)=squeeze(PLV_lat_neg(:,peak_channel,:,1:5:end));
end;

 save(['PLV_conditions_lat_all'], 'PLV_lat_pos_all', 'PLV_lat_neg_all')
