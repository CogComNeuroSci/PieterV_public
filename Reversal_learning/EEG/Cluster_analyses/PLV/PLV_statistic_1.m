subject_list    = {'pp3', 'pp5', 'pp6', 'pp7', 'pp9', 'pp10', 'pp12', 'pp14', 'pp15', 'pp16', 'pp18', 'pp19', 'pp20', 'pp21', 'pp22', 'pp23', 'pp24', 'pp25','pp26','pp27','pp28','pp29','pp30','pp31','pp32','pp33','pp34'};
num_subjects    = length(subject_list);               %number of subjects

num_conditions=2;
real_array=ones(num_subjects,num_conditions);
real_array(:,2)=real_array(:,2).*-1;

for s=1:num_subjects
    random_array(s,:)=real_array(s,randperm(num_conditions));
end;

load(['PLV_conditions_lat_all'], 'PLV_lat_pos_all', 'PLV_lat_neg_all')

statistic=squeeze(nanmean((PLV_lat_neg_all.*real_array(:,1)+PLV_lat_pos_all.*real_array(:,2)),1));
random_statistic=squeeze(nanmean((PLV_lat_neg_all.*random_array(:,1)+PLV_lat_pos_all.*random_array(:,2)),1));

save('PLV_statistic', 'statistic')
save('PLV_random', 'random_statistic')