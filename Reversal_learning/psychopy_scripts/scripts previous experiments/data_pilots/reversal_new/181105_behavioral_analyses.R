setwd("~/Documents/catastrophic forgetting/empirical/data/reversal_new")

#clear console, environment and plots
cat("\014")
rm(list = ls())

#load libraries
library(tidyverse)
#library(lattice)
#library(plyr)
library(ggplot2)
library(Rmisc)
library(yarrr)
library(scales)

#define number of participants and number of trials
pp=9
Tr=240

# read data
Data_pp1<- read.delim("Probabilistic_Reversal_task_subject_1_Session_0_data.tsv", header = TRUE, sep = "\t", quote = "\"",dec = ".", fill = TRUE)
Data_pp2<- read.delim("Probabilistic_Reversal_task_subject_2_Session_0_data.tsv", header = TRUE, sep = "\t", quote = "\"",dec = ".", fill = TRUE)
Data_pp3<- read.delim("Probabilistic_Reversal_task_subject_3_Session_0_data.tsv", header = TRUE, sep = "\t", quote = "\"",dec = ".", fill = TRUE)
Data_pp4<- read.delim("Probabilistic_Reversal_task_subject_4_Session_0_data.tsv", header = TRUE, sep = "\t", quote = "\"",dec = ".", fill = TRUE)
Data_pp5<- read.delim("Probabilistic_Reversal_task_subject_5_Session_0_data.tsv", header = TRUE, sep = "\t", quote = "\"",dec = ".", fill = TRUE)
Data_pp6<- read.delim("Probabilistic_Reversal_task_subject_6_Session_0_data.tsv", header = TRUE, sep = "\t", quote = "\"",dec = ".", fill = TRUE)
Data_pp7<- read.delim("Probabilistic_Reversal_task_subject_7_Session_0_data.tsv", header = TRUE, sep = "\t", quote = "\"",dec = ".", fill = TRUE)
Data_pp8<- read.delim("Probabilistic_Reversal_task_subject_8_Session_0_data.tsv", header = TRUE, sep = "\t", quote = "\"",dec = ".", fill = TRUE)
Data_pp9<- read.delim("Probabilistic_Reversal_task_subject_9_Session_0_data.tsv", header = TRUE, sep = "\t", quote = "\"",dec = ".", fill = TRUE)

#combine data
Data<-rbind(Data_pp1, Data_pp2, Data_pp3, Data_pp4,Data_pp5,Data_pp6,Data_pp7,Data_pp8, Data_pp9)

#first look at data
Data[1:10,]
Data=Data[,5:19]# use only relevant variables
start_situation<-Data[Data$Tr==0,]

#decode fb and accuracy on trial N-1 and whether short or long after rule switch
for (data in c(1:(Tr*pp))){
  if (Data$Tr[data]>0){
    Data$corrP[data]=Data$corr[data-1]
    Data$RTP[data]=Data$RT[data-1]
    Data$FBP[data]=Data$FB[data-1]
    Data$DetectP[data]=Data$jump_detect[data-1]
  }
  if (Data$Switch_pass[data]<10){
    Data$cond[data]=1
  }else {
    Data$cond[data]=2
  }
}

#eliminate late trials and the first trial
Data_nolates<-Data[!(Data$RT>1),]
Data_nolates<-Data_nolates[!(Data_nolates$Tr==0),]
Data_nolates<-Data_nolates[!(Data_nolates$Break_pass==0),]
Data_nolates<-Data_nolates[!(Data_nolates$RTP>1),] #also where previous trial was to late

#standardize data for plotting
Data_nolates$corr<-Data_nolates$corr*100
Data_nolates$RT<-Data_nolates$RT*1000

#define which variables are factors
Data_nolates$cond<-as.factor(Data_nolates$cond)
Data_nolates$corrP<-as.factor(Data_nolates$corrP)
Data_nolates$FBP<-as.factor(Data_nolates$FB)
Data_nolates$Block<-as.factor(Data_nolates$Block)
Data_nolates$rule<-as.factor(Data_nolates$rule)
# look at switch indications
Switches<-Data[complete.cases(Data),]
Switches<-Switches[Switches$jump_detect>0,]

count<-table(Switches$jump_detect,Switches$ppnr)
barplot(count, xlab="Participants", ylab="Counts", legend.text = c("correct", "too late","too early"), col = c("red","blue","black"), main="Switch presses", beside=TRUE)

# look at mean performance for each participant
means=aggregate(Data_nolates[,9:10], list(Data_nolates$ppnr),mean)
colnames(means)<-c("ppnr","RT","corr")

#pirateplot
pirateplot(corr~ppnr, data=Data_nolates)
pirateplot(RT~ppnr, data=Data_nolates, main="RT per participant")

#boxplot
boxplot(means$corr, main="Total task accuracy", ylab="Accuracy %")
stripchart(means$corr, vertical=TRUE, add=TRUE, method="stack", col='red', pch=19)
boxplot(means$RT, main="mean RT", ylab="RT (ms)")
stripchart(means$RT, vertical=TRUE, add=TRUE, method="stack", col='red', pch=19)

#remove participants that score too low
Data_nolates_cleanpp<-Data_nolates
Data_noerrors_cleanpp<-Data_noerrors
for (sj in c(1:pp)){
  if (means$corr[sj]<65){
    Data_nolates_cleanpp<-Data_nolates_cleanpp[!(Data_nolates_cleanpp$ppnr==sj+1),]
    Data_noerrors_cleanpp<-Data_noerrors_cleanpp[!(Data_noerrors_cleanpp$ppnr==sj+1),]
  }
} 

#compute again averages
means_cleanpp=aggregate(Data_nolates_cleanpp[,9:10], list(Data_nolates_cleanpp$ppnr),mean)
colnames(means_cleanpp)<-c("ppnr","RT","corr")

#compare blocks with and without switch indication
means_perblock_cleanpp=aggregate(Data_nolates_cleanpp[,9:10], list(Data_nolates_cleanpp$ppnr,Data_nolates_cleanpp$Block),mean)
colnames(means_perblock_cleanpp)<-c("ppnr","Block","RT","corr")

# make seperate datasets per block
block1=Data_nolates_cleanpp[Data_nolates_cleanpp$Block==0,]
block2=Data_nolates_cleanpp[Data_nolates_cleanpp$Block==1,]

#check for differences with a t-test
t.test(means_perblock_cleanpp$RT~means_perblock_cleanpp$Block, paired= TRUE)
t.test(means_perblock_cleanpp$corr~means_perblock_cleanpp$Block, paired= TRUE)

#plot differences for RT and accuracy
blockaccuracy_fig<-summarySE(data = Data_nolates_cleanpp, measurevar = "corr", groupvars = "Block")

ggplot(blockaccuracy_fig, aes(x=Block, y=corr))+
  geom_bar(stat="identity", fill="red")+
  geom_point()+
  geom_errorbar(aes(ymin=corr-ci, ymax=corr+ci))+
  theme_classic()+
  ggtitle("Accuracy per block")+
  theme(plot.title = element_text(size = 18, face = "bold", hjust=0.5))+
  labs(x="After rule switch")+
  labs(y="Accuracy %")+
  scale_x_discrete(labels=c("0"="With indication", "1"="Without indication"))+
  scale_y_continuous(limits =c(50,100), oob=rescale_none)

blockrt_fig<-summarySE(data = Data_nolates_cleanpp, measurevar = "RT", groupvars = "Block")

ggplot(blockrt_fig, aes(x=Block, y=RT))+
  geom_bar(stat="identity", fill="red")+
  geom_point()+
  geom_errorbar(aes(ymin=RT-ci, ymax=RT+ci))+
  theme_classic()+
  ggtitle("RT per block")+
  theme(plot.title = element_text(size = 18, face = "bold", hjust=0.5))+
  labs(x="Block")+
  labs(y="RT (ms)")+
  scale_x_discrete(labels=c("0"="With indication", "1"="Without indication"))+
  scale_y_continuous(limits =c(450,500), oob=rescale_none)

#new variables that indicate how long ago the participant indicated a switch
block1<-na.omit(block1)
block1[block1$DetectP==3,20]<-2

block1$sinceDetect<-0

for (x in c(2:length(block1$Block))){
  if (block1$jump_detect[x]>0){
    block1$sinceDetect[x]<-0
  }else{
    block1$sinceDetect[x]<-block1$sinceDetect[x-1]+1
  }
}

#only for correct indications here
block1$sinceDetect_extra<-0
for (x in c(2:length(block1$Block))){
  if (block1$jump_detect[x]==1){
    block1$sinceDetect_extra[x]<-0
  }else{
    block1$sinceDetect_extra[x]<-block1$sinceDetect_extra[x-1]+1
  }
}

#plot RTs and accuracy after a switch press
block1$DetectP<-as.factor(block1$DetectP)
fig_ind_accuracy<-summarySE(block1, measurevar = "corr", groupvars = "DetectP")
ggplot(fig_ind_accuracy, aes(x=DetectP, y=corr))+
  geom_bar(stat="identity", fill="red")+
  geom_point()+
  geom_errorbar(aes(ymin=corr-ci, ymax=corr+ci))+
  theme_classic()+
  ggtitle("Accuracy after indication of switch")+
  theme(plot.title = element_text(size = 18, face = "bold", hjust=0.5))+
  labs(x="Switch press")+
  labs(y="Accuracy %")+
  scale_x_discrete(labels=c("0"="no press", "1"="correct press", "2"="wrong press"))+
  scale_y_continuous(limits =c(0,100), oob=rescale_none)

fig_ind_RT=summarySE(block1, measurevar="RT", groupvars= "DetectP")
ggplot(fig_ind_RT, aes(x=DetectP, y=RT))+
  geom_bar(stat="identity", fill="red")+
  geom_point()+
  geom_errorbar(aes(ymin=RT-ci, ymax=RT+ci))+
  theme_classic()+
  ggtitle("RT after indication of switch")+
  theme(plot.title = element_text(size = 18, face = "bold", hjust=0.5))+
  labs(x="Switch press")+
  labs(y="RT (ms)")+
  scale_x_discrete(labels=c("0"="no press", "1"="correct press", "2"="wrong press"))+
  scale_y_continuous(limits =c(400,650), oob=rescale_none)

# check evolution after switch press for RT and accuracy
fig_ind_extra_RT<-summarySE(block1, measurevar="RT", groupvars=c("sinceDetect_extra"))
fig_ind_extra_RT<-na.omit(fig_ind_extra_RT)

ggplot(fig_ind_extra_RT, aes(x=sinceDetect_extra, y=RT)) + 
  geom_ribbon(aes(ymin=RT-ci, ymax=RT+ci), alpha=0.5)+
  geom_line()+
  geom_point()+
  theme_classic()+
  labs(x="Trial after switch press")+
  labs(y="RT(ms)")+
  ggtitle("RT after indication of switch")+
  theme(plot.title = element_text(size = 18, face = "bold", hjust=0.5))+
  scale_y_continuous(limits =c(250,1000), oob=rescale_none)+
  scale_x_continuous(limits =c(0,45), oob=rescale_none)

fig_ind_extra_accuracy<-summarySE(block1, measurevar="corr", groupvars=c("sinceDetect_extra"))
fig_ind_extra_accuracy<-na.omit(fig_ind_extra_accuracy)

ggplot(fig_ind_extra_accuracy, aes(x=sinceDetect_extra, y=corr)) + 
  geom_ribbon(aes(ymin=corr-ci, ymax=corr+ci), alpha=0.5)+
  geom_line()+
  geom_point()+
  theme_classic()+
  labs(x="Trial after switch press")+
  labs(y="Accuracy %")+
  ggtitle("Accuracy after indication of switch")+
  theme(plot.title = element_text(size = 18, face = "bold", hjust=0.5))+
  scale_y_continuous(limits =c(0,100), oob=rescale_none)+
  scale_x_continuous(limits =c(0,45), oob=rescale_none)

#check for effects with linear models
fit_corr<-lm(corr~cond*corrP*FBP*rule*Block,data=Data_nolates_cleanpp)
fit_RT<-lm(RT~cond*Tr*corrP*FBP*rule*Block,data=Data_nolates_cleanpp)

summary(fit_corr)
summary(fit_RT)

# check interesting effects:
# early or late after switch 
fig1<-summarySE(Data_nolates_cleanpp, measurevar="corr", groupvars="cond")
fig2<-summarySE(Data_nolates_cleanpp, measurevar="RT", groupvars="cond")

ggplot(fig1, aes(x=cond, y=corr))+
  geom_bar(stat="identity", fill="red")+
  geom_point()+
  geom_errorbar(aes(ymin=corr-ci, ymax=corr+ci))+
  theme_classic()+
  ggtitle("Accuracy after switch")+
  theme(plot.title = element_text(size = 18, face = "bold", hjust=0.5))+
  labs(x="After rule switch")+
  labs(y="Accuracy %")+
  scale_x_discrete(labels=c("1"="early", "2"="late"))+
  scale_y_continuous(limits =c(50,100), oob=rescale_none)

ggplot(fig2, aes(x=cond, y=RT))+
  geom_bar(stat="identity", fill= "red")+
  geom_point()+
  geom_errorbar(aes(ymin=RT-ci, ymax=RT+ci))+
  theme_classic()+
  ggtitle("RT after switch")+
  theme(plot.title = element_text(size = 18, face = "bold", hjust=0.5))+
  labs(x="After rule switch")+
  labs(y="RT (ms)")+
  scale_x_discrete(labels=c("1"="early", "2"="late"))+
  scale_y_continuous(limits =c(450,550), oob=rescale_none)

# effect of accuracy on previous trial
fig3<-summarySE(Data_nolates_cleanpp, measurevar="corr", groupvars=c("corrP"))
fig4<-summarySE(Data_nolates_cleanpp, measurevar="RT", groupvars=c("corrP"))

ggplot(fig3, aes(x=corrP, y=corr))+
  geom_bar(stat="identity", fill="red")+
  geom_errorbar(aes(ymin=corr-ci, ymax=corr+ci))+
  theme_classic()+
  labs(x="Accuracy previous trial")+
  labs(y="Accuracy %")+
  ggtitle("Accuracy after errors/correct trials")+
  theme(plot.title = element_text(size = 18, face = "bold", hjust=0.5))+
  scale_x_discrete(labels=c("0"="wrong", "1"="correct"))+
  scale_y_continuous(limits =c(0,100), oob=rescale_none)

ggplot(fig4, aes(x=corrP, y=RT))+
  geom_bar(stat="identity", fill="red")+
  geom_errorbar(aes(ymin=RT-ci, ymax=RT+ci))+
  theme_classic()+
  labs(x="Accuracy previous trial")+
  labs(y="RT (ms)")+
  ggtitle("RT after errors/correct trials")+
  theme(plot.title = element_text(size = 18, face = "bold", hjust=0.5))+
  scale_x_discrete(labels=c("0"="wrong", "1"="correct"))+
  scale_y_continuous(limits =c(450,550), oob=rescale_none)

# effect of feedback on previous trial
fig5<-summarySE(Data_nolates_cleanpp, measurevar="corr", groupvars=c("FBP"))
fig6<-summarySE(Data_nolates_cleanpp, measurevar="RT", groupvars=c("FBP"))

ggplot(fig5, aes(x=FBP, y=corr))+
  geom_bar(stat="identity", fill="red")+
  geom_errorbar(aes(ymin=corr-ci, ymax=corr+ci))+
  theme_classic()+
  labs(x="Feedback previous trial")+
  labs(y="Accuracy %")+
  ggtitle("Accuracy after feedback")+
  theme(plot.title = element_text(size = 18, face = "bold", hjust=0.5))+
  scale_x_discrete(labels=c("0"="Negative", "1"="Positive"))+
  scale_y_continuous(limits =c(0,100), oob=rescale_none)

ggplot(fig6, aes(x=FBP, y=RT))+
  geom_bar(stat="identity", fill="red")+
  geom_errorbar(aes(ymin=RT-ci, ymax=RT+ci))+
  theme_classic()+
  labs(x="Accuracy previous trial")+
  labs(y="RT (ms)")+
  ggtitle("RT after feedback")+
  theme(plot.title = element_text(size = 18, face = "bold", hjust=0.5))+
  scale_x_discrete(labels=c("0"="Negative", "1"="Positive"))+
  scale_y_continuous(limits =c(450,550), oob=rescale_none)

# interaction of accuracy and feedback / effect of Prediction error on previous trial
fig7<-summarySE(Data_nolates_cleanpp, measurevar="corr", groupvars=c("corrP","FBP"))
fig8<-summarySE(Data_nolates_cleanpp, measurevar="RT", groupvars=c("corrP","FBP"))

ggplot(fig7, aes(x=corrP, y=corr, fill=FBP))+
  geom_bar(stat="identity",position="dodge")+
  geom_errorbar(aes(ymin=corr-ci, ymax=corr+ci), position= "dodge")+
  theme_classic()+
  labs(x="Accuracy previous trial")+
  labs(y="Accuracy %")+
  labs(fill="Feedback previous trial")+
  ggtitle("Accuracy after PEs")+
  theme(plot.title = element_text(size = 18, face = "bold", hjust=0.5))+
  scale_x_discrete(labels=c("0"="wrong", "1"="correct"))+
  scale_y_continuous(limits =c(0,100), oob=rescale_none)+
  scale_fill_manual(values = c("red","blue"), labels=c("0"="Negative","1"="Positive")) 

ggplot(fig8, aes(x=corrP, y=RT, fill=FBP))+
  geom_bar(stat="identity",position="dodge")+
  geom_errorbar(aes(ymin=RT-ci, ymax=RT+ci), position= "dodge")+
  theme_classic()+
  labs(x="Accuracy previous trial")+
  labs(y="RT (ms)")+
  labs(fill="Feedback previous trial")+
  ggtitle("RTs after PEs")+
  theme(plot.title = element_text(size = 18, face = "bold", hjust=0.5))+
  scale_x_discrete(labels=c("0"="wrong", "1"="correct"))+
  scale_y_continuous(limits =c(450,550), oob=rescale_none)+
  scale_fill_manual(values = c("red","blue"), labels=c("0"="Negative","1"="Positive")) 

# interaction of early and late after switch with feedback on previous trial
fig9<-summarySE(Data_nolates_cleanpp, measurevar="corr", groupvars=c("cond","FBP"))
fig10<-summarySE(Data_nolates_cleanpp, measurevar="RT", groupvars=c("cond","FBP"))

ggplot(fig9, aes(x=cond, y=corr, fill=FBP))+
  geom_bar(stat="identity",position="dodge")+
  geom_errorbar(aes(ymin=corr-ci, ymax=corr+ci), position= "dodge")+
  theme_classic()+
  labs(x="After rule switch")+
  labs(y="Accuracy %")+
  labs(fill="Feedback previous trial")+
  ggtitle("Accuracy: : Feedback x after rule switch")+
  theme(plot.title = element_text(size = 18, face = "bold", hjust=0.5))+
  scale_x_discrete(labels=c("1"="early", "2"="late"))+
  scale_y_continuous(limits =c(0,100), oob=rescale_none)+
  scale_fill_manual(values = c("red","blue"), labels=c("0"="Negative","1"="Positive")) 

ggplot(fig10, aes(x=cond, y=RT, fill=FBP))+
  geom_bar(stat="identity",position="dodge")+
  geom_errorbar(aes(ymin=RT-ci, ymax=RT+ci), position= "dodge")+
  theme_classic()+
  labs(x="After rule switch")+
  labs(y="RT (ms)")+
  labs(fill="Feedback previous trial")+
  ggtitle("RT: Feedback x after rule switch")+
  theme(plot.title = element_text(size = 18, face = "bold", hjust=0.5))+
  scale_x_discrete(labels=c("1"="early", "2"="late"))+
  scale_y_continuous(limits =c(450,550), oob=rescale_none)+
  scale_fill_manual(values = c("red","blue"), labels=c("0"="Negative","1"="Positive")) 

# interaction of moment after rule switch and rule
Data_nolates_cleanpp$rule<-as.factor(Data_nolates_cleanpp$rule)
fig11<-summarySE(Data_nolates_cleanpp, measurevar="corr", groupvars=c("cond","rule"))
fig12<-summarySE(Data_nolates_cleanpp, measurevar="RT", groupvars=c("cond","rule"))

ggplot(fig11, aes(x=cond, y=corr, fill=rule))+
  geom_bar(stat="identity",position="dodge")+
  geom_errorbar(aes(ymin=corr-ci, ymax=corr+ci), position= "dodge")+
  theme_classic()+
  labs(x="After switch")+
  labs(y="Accuracy %")+
  labs(fill="rule")+
  ggtitle("Accuracy: moment after switch X rule")+
  theme(plot.title = element_text(size = 18, face = "bold", hjust=0.5))+
  scale_x_discrete(labels=c("1"="early", "2"="late"))+
  scale_y_continuous(limits =c(0,100), oob=rescale_none)+
  scale_fill_manual(values = c("red","blue"), labels=c("0"="HorLeft","1"="HorRight")) 

ggplot(fig12, aes(x=cond, y=RT, fill=rule))+
  geom_bar(stat="identity",position="dodge")+
  geom_errorbar(aes(ymin=RT-ci, ymax=RT+ci), position= "dodge")+
  theme_classic()+
  labs(x="Accuracy previous trial")+
  labs(y="RT (ms)")+
  labs(fill="Feedback previous trial")+
  ggtitle("RTs: moment after switch X rule")+
  theme(plot.title = element_text(size = 18, face = "bold", hjust=0.5))+
  scale_x_discrete(labels=c("1"="early", "2"="late"))+
  scale_y_continuous(limits =c(450,550), oob=rescale_none)+
  scale_fill_manual(values = c("red","blue"), labels=c("0"="HorLeft","1"="HorRight")) 

# interaction of feedback on previous trial and block
fig13<-summarySE(Data_nolates_cleanpp, measurevar="corr", groupvars=c("FBP","Block"))
fig14<-summarySE(Data_nolates_cleanpp, measurevar="RT", groupvars=c("FBP","Block"))

ggplot(fig13, aes(x=Block, y=corr, fill=FBP))+
  geom_bar(stat="identity",position="dodge")+
  geom_errorbar(aes(ymin=corr-ci, ymax=corr+ci), position= "dodge")+
  theme_classic()+
  labs(x="Block")+
  labs(y="Accuracy %")+
  labs(fill="Feedback previous trial")+
  ggtitle("Accuracy: : Feedback x Block")+
  theme(plot.title = element_text(size = 18, face = "bold", hjust=0.5))+
  scale_x_discrete(labels=c("0"="with indication", "1"="without indication"))+
  scale_y_continuous(limits =c(0,100), oob=rescale_none)+
  scale_fill_manual(values = c("red","blue"), labels=c("0"="Negative","1"="Positive")) 

ggplot(fig14, aes(x=Block, y=RT, fill=FBP))+
  geom_bar(stat="identity",position="dodge")+
  geom_errorbar(aes(ymin=RT-ci, ymax=RT+ci), position= "dodge")+
  theme_classic()+
  labs(x="After rule switch")+
  labs(y="RT (ms)")+
  labs(fill="Feedback previous trial")+
  ggtitle("RT: Feedback x Block")+
  theme(plot.title = element_text(size = 18, face = "bold", hjust=0.5))+
  scale_x_discrete(labels=c("0"="with indication", "1"="without indication"))+
  scale_y_continuous(limits =c(450,550), oob=rescale_none)+
  scale_fill_manual(values = c("red","blue"), labels=c("0"="Negative","1"="Positive")) 

# interaction of moment after rule switch, rule and accuracy on previous trial
fig15<-summarySE(Data_nolates_cleanpp, measurevar="corr", groupvars=c("cond","corrP", "rule"))
fig16<-summarySE(Data_nolates_cleanpp, measurevar="RT", groupvars=c("cond","corrP", "rule"))

ggplot(fig15, aes(x=cond, y=corr, fill=corrP))+
  geom_bar(stat="identity", position= "dodge")+
  geom_errorbar(aes(ymin=corr-ci, ymax=corr+ci), position="dodge")+
  facet_grid(. ~ rule, labeller = as_labeller(c("0"="HorLeft","1"="HorRight")))+
  theme_classic()+
  labs(x="After rule switch")+
  labs(y="Accuracy %")+
  labs(fill="Accuracy previous trial")+
  ggtitle("Accuracy: rule X moment after switch X accuracy previous trial")+
  theme(plot.title = element_text(size = 12, face = "bold", hjust=0.5))+
  scale_x_discrete(labels=c("1"="Early", "2"="Late"))+
  scale_y_continuous(limits =c(0,100), oob=rescale_none)+
  scale_fill_manual(values = c("red","blue"), labels=c("0"="Wrong","1"="Correct")) 

ggplot(fig16, aes(x=cond, y=RT, fill=corrP))+
  geom_bar(stat="identity", position= "dodge")+
  geom_errorbar(aes(ymin=RT-ci, ymax=RT+ci), position="dodge")+
  facet_grid(. ~ rule, labeller = as_labeller(c("0"="HorLeft","1"="HorRight")))+
  theme_classic()+
  labs(x="After rule switch")+
  labs(y="RT (ms)")+
  labs(fill="Accuracy previous trial")+
  ggtitle("Accuracy: rule X moment after switch X accuracy previous trial")+
  theme(plot.title = element_text(size = 12, face = "bold", hjust=0.5))+
  scale_x_discrete(labels=c("1"="Early", "2"="Late"))+
  scale_y_continuous(limits =c(400,550), oob=rescale_none)+
  scale_fill_manual(values = c("red","blue"), labels=c("0"="Wrong","1"="Correct")) 

# interaction of moment after rule switch, block and accuracy on previous trial
fig17<-summarySE(Data_nolates_cleanpp, measurevar="corr", groupvars=c("cond","corrP", "Block"))
fig18<-summarySE(Data_nolates_cleanpp, measurevar="RT", groupvars=c("cond","corrP", "Block"))

ggplot(fig17, aes(x=cond, y=corr, fill=corrP))+
  geom_bar(stat="identity", position= "dodge")+
  geom_errorbar(aes(ymin=corr-ci, ymax=corr+ci), position="dodge")+
  facet_grid(. ~ Block, labeller = as_labeller(c("0"="With indication","1"="Without indication")))+
  theme_classic()+
  labs(x="After rule switch")+
  labs(y="Accuracy %")+
  labs(fill="Accuracy previous trial")+
  ggtitle("Accuracy: rule X moment after switch X accuracy previous trial")+
  theme(plot.title = element_text(size = 12, face = "bold", hjust=0.5))+
  scale_x_discrete(labels=c("1"="Early", "2"="Late"))+
  scale_y_continuous(limits =c(0,100), oob=rescale_none)+
  scale_fill_manual(values = c("red","blue"), labels=c("0"="Wrong","1"="Correct")) 

ggplot(fig18, aes(x=cond, y=RT, fill=corrP))+
  geom_bar(stat="identity", position= "dodge")+
  geom_errorbar(aes(ymin=RT-ci, ymax=RT+ci), position="dodge")+
  facet_grid(. ~ Block, labeller = as_labeller(c("0"="With indication","1"="Without indication")))+
  theme_classic()+
  labs(x="After rule switch")+
  labs(y="Accuracy %")+
  labs(fill="Accuracy previous trial")+
  ggtitle("Accuracy: rule X moment after switch X accuracy previous trial")+
  theme(plot.title = element_text(size = 12, face = "bold", hjust=0.5))+
  scale_x_discrete(labels=c("1"="Early", "2"="Late"))+
  scale_y_continuous(limits =c(400,550), oob=rescale_none)+
  scale_fill_manual(values = c("red","blue"), labels=c("0"="Wrong","1"="Correct")) 

#extract the same data as in the model simulations and make comparative plots
First_trials<-Data[!(Data$Switch_pass>14),]

modeldata<-First_trials[(First_trials$part<3),]
modeldata$trial<-c(1:45)
modeldata<-modeldata[!(modeldata$RT>1000),]

#RT evolution after rule switch
modelfig_corr<-summarySE(Data_nolates_cleanpp, measurevar="corr", groupvars=c("Switch_pass"))
ggplot(modelfig_corr, aes(x=Switch_pass, y=corr)) + 
  geom_ribbon(aes(ymin=corr-ci, ymax=corr+ci), alpha=0.5)+
  geom_line()+
  geom_point()+
  theme_classic()+
  labs(x="Trial after switch")+
  labs(y="Accuracy %")+
  ggtitle("Accuracy after switch")+
  theme(plot.title = element_text(size = 18, face = "bold", hjust=0.5))

modelfig_RT<-summarySE(Data_nolates_cleanpp, measurevar="RT", groupvars=c("Switch_pass"))

#Accuracy evolution after rule switch
ggplot(modelfig_RT, aes(x=Switch_pass, y=RT)) + 
  geom_ribbon(aes(ymin=RT-ci, ymax=RT+ci), alpha=0.5)+
  geom_line()+
  geom_point()+
  theme_classic()+
  labs(x="Trial after switch")+
  labs(y="Accuracy %")+
  ggtitle("Accuracy after switch")+
  theme(plot.title = element_text(size = 18, face = "bold", hjust=0.5))

