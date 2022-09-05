folder='/Volumes/Harde ploate/EEG_reversal_learning/Behavioral_data/Indices/';

RT=readtable([folder 'RT.csv']);
RT=table2array(RT);
Tr=480;
Nsubjects=27;
RT_data=reshape(RT,Tr,Nsubjects);
lateRT_indices=RT_data>1000;

Switch=table2array(readtable([folder 'Switch.csv']));
s=Switch==0;
Switch_indices=reshape(s,Tr,Nsubjects);

Threshold=table2array(readtable([folder 'Threshold.csv']));
tc=Threshold==1;
ta=Threshold>0;
correct_threshold_indices=reshape(tc,Tr,Nsubjects);
all_threshold_indices=reshape(ta,Tr,Nsubjects);

save([folder 'Indices'], 'correct_threshold_indices', 'all_threshold_indices', 'Switch_indices', 'lateRT_indices','RT_data')
            
locking_values=zeros(Nsubjects,31,15);
lt_values=zeros(Nsubjects,31,8);

for s=1: Nsubjects
    t=1:480;
    tswitch=t(Switch_indices(:,s));
    tswitch=tswitch(1,2:16);
    tthreshold=t(correct_threshold_indices(:,s));
    counter=0;
    for x=tswitch
        counter = counter +1;
        locking_values(s,:,counter)=x-15:x+15;
    end;
    counter2=0;
    for y=tthreshold
        counter2 = counter2 +1;
        lt_values(s,:,counter2)=y-15:y+15;
    end;
    counts(:,s)=[counter, counter2];
end;

locking_values=reshape(locking_values,Nsubjects, []);
lt_values=reshape(lt_values,Nsubjects, []);

save([folder 'Locking_data'], 'locking_values', 'lt_values', 'counts')

PE=readtable([folder 'PE.csv']);
PE=table2array(PE);
PE_data=reshape(PE,Tr,Nsubjects);

save([folder 'PE_data'], 'PE')