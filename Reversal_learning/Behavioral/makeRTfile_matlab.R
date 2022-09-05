Data_folder="/Volumes/Harde ploate/EEG_reversal_learning/Behavioral_data/data"
Sync_fit_folder="/Volumes/Harde ploate/EEG_reversal_learning/model_fitting/Sync_data"


#define number of participants and number of trials
Tr=480

pplist<-c(3,5:7,9:10,12, 14:16, 18:34) #there were technical problems for subjects 1, 2, 11 and 13

pp=length(pplist)

setwd(Data_folder)
# read data
for (p in pplist){
  filename= sprintf("Probabilistic_Reversal_task_subject_%s_Session_0_data.tsv",p)
  Single_Data<-read.delim(filename, header = TRUE, sep = "\t", quote = "\"",dec = ".", fill = TRUE)
  if (p==3){
    Data<-Single_Data
  }
  else{
    Data<-rbind(Data, Single_Data)
  }
}

Data=Data[,c(5:16, 26, 28)]# use only relevant variables

setwd(Sync_fit_folder)
for (p in pplist){
  filename= sprintf('Behavioral_data_subject_%s_Sync.csv',p)
  Single_Data_model<-read.delim(filename, header = TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)
  if (p==3){
    Data_model<-Single_Data_model
  }
  else{
    Data_model<-rbind(Data_model, Single_Data_model)
  }
}

setwd("/Volumes/Harde ploate/EEG_reversal_learning/Behavioral_data/Indices")

RT_data<-Data$RT*1000
RT_data <- t(RT_data)
d<-dim(RT_data)
write(RT_data,"RT.csv",ncolumns =d[1] ,sep = ",")

corr_data<-Data$corr
corr_data <- t(corr_data)
d<-dim(corr_data)
write(corr_data,"Accuracy.csv",ncolumns =d[1] ,sep = ",")

Switch_data<-Data$Switch_pass
Switch_data <- t(Switch_data)
d<-dim(Switch_data)
write(Switch_data,"Switch.csv",ncolumns =d[1] ,sep = ",")

threshold_data<-Data$jump_detect
threshold_data[is.na(threshold_data )]<-0
threshold_data <- t(threshold_data)
d<-dim(threshold_data)
write(threshold_data,"Threshold.csv",ncolumns =d[1] ,sep = ",")

Feedback_data<-Data$FB
Feedback_data <- t(Feedback_data)
d<-dim(Feedback_data)
write(Feedback_data,"Feedback.csv",ncolumns =d[1] ,sep = ",")


for (data in c(1:(Tr*pp))){
  if (Data$Tr[data]>0){
    Data$FBP[data]=Data$FB[data-1]
  }
  if (Data$corr[data]==1){
    if(Data$Resp[data]=='f'){
      Data$side_coding[data]=0
    }else{
      Data$side_coding[data]=1
    }
  }else{
    if(Data$Resp[data]=='f'){
      Data$side_coding[data]=1
    }else{
      Data$side_coding[data]=0
    }
  }
}

P_FB_data<-Data$FB
P_FB_data <- t(P_FB_data)
indexes=(((1:pp)-1)*Tr)+1
P_FB_data[1,indexes]<-3
d<-dim(P_FB_data)
write(P_FB_data,"P_FB.csv",ncolumns =d[1] ,sep = ",")

side_data<-Data$side_coding
side_data <- t(side_data)
d<-dim(side_data)
write(side_data,"Side.csv",ncolumns =d[1] ,sep = ",")

PE_data<-Data_model$PE_estimate
PE_data <- t(PE_data)
d<-dim(PE_data)
write(PE_data,"PE.csv",ncolumns =d[1] ,sep = ",")
