rm(list=ls())

library(Rmisc)

setwd("/Volumes/Backupdisc/Adaptive_control/Empirical_Gratton")

pplist<-c(seq(1:16))

for (p in pplist){
  file_name <- paste("Prime_Arrow_Flanker_Subject_",p,"_log.txt", sep="")
  if (p==1){
    Data<-read.table(file_name,sep="\t", skip=4, header = TRUE, fill=TRUE)
    Data$ppnr<-p
  }else{
    D<-read.table(file_name,sep="\t", skip=4, header = TRUE, fill=TRUE)
    D$ppnr<-p
    Data<-rbind(Data, D)
  }
}

Cleaned_data<-Data[Data$Run.Number!="practice",]
Cleaned_data<-Cleaned_data[as.character(Cleaned_data$Previous.Trial.Type)!=" None",]
Cleaned_data<-Cleaned_data[Cleaned_data$RT<1.5,]

RT_data<-Cleaned_data[as.character(Cleaned_data$Accuracy) == " Correct",]
RT_data<-RT_data[as.character(RT_data$PreviousAccuracy) == " Correct",]

RT_data$LogRT<-log(1000*RT_data$RT)

RT_results<-summarySE(RT_data, measurevar="LogRT", groupvars= c("ppnr","Current.Trial.Type","Previous.Trial.Type"))
RT_results2<-summarySE(RT_results, measurevar="LogRT", groupvars= c("Current.Trial.Type","Previous.Trial.Type"))

save(RT_results2, file="RT_empirical.Rda")

Cleaned_data[as.character(Cleaned_data$Accuracy) == " Correct",14]<-100
Cleaned_data[as.character(Cleaned_data$Accuracy) == " Error",14]<-0

names(Cleaned_data)[14]<-"acc"

Accuracy_results<-summarySE(Cleaned_data, measurevar="acc", groupvars= c("ppnr","Current.Trial.Type","Previous.Trial.Type"))
Accuracy_results2<-summarySE(Accuracy_results, measurevar="acc", groupvars= c("Current.Trial.Type","Previous.Trial.Type"))

save(Accuracy_results2, file="Accuracy_empirical.Rda")

  