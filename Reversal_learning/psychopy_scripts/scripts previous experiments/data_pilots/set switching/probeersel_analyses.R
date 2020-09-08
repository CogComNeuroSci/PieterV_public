setwd("~/Documents/catastrophic forgetting/empirical/data")

#clear console, environment and plots
cat("\014")
rm(list = ls())
dev.off()

#load libraries
library(tidyverse)
#library(lattice)
#library(plyr)
library(ggplot2)
library(Rmisc)
library(yarrr)
# read data
Data_pp1<- read.delim("Prob_reversal_learning_task_subject_1_Session_0_data.tsv", header = TRUE, sep = "\t", quote = "\"",dec = ".", fill = TRUE)
Data_pp2<- read.delim("Prob_reversal_learning_task_subject_2_Session_0_data.tsv", header = TRUE, sep = "\t", quote = "\"",dec = ".", fill = TRUE)
Data_pp3<- read.delim("Prob_reversal_learning_task_subject_3_Session_0_data.tsv", header = TRUE, sep = "\t", quote = "\"",dec = ".", fill = TRUE)
Data_pp4<- read.delim("Prob_reversal_learning_task_subject_4_Session_0_data.tsv", header = TRUE, sep = "\t", quote = "\"",dec = ".", fill = TRUE)
Data_pp5<- read.delim("Prob_reversal_learning_task_subject_5_Session_0_data.tsv", header = TRUE, sep = "\t", quote = "\"",dec = ".", fill = TRUE)
Data_pp6<- read.delim("Prob_reversal_learning_task_subject_6_Session_0_data.tsv", header = TRUE, sep = "\t", quote = "\"",dec = ".", fill = TRUE)
Data_pp7<- read.delim("Prob_reversal_learning_task_subject_7_Session_0_data.tsv", header = TRUE, sep = "\t", quote = "\"",dec = ".", fill = TRUE)
Data_pp8<- read.delim("Prob_reversal_learning_task_subject_8_Session_0_data.tsv", header = TRUE, sep = "\t", quote = "\"",dec = ".", fill = TRUE)
Data_pp9<- read.delim("Prob_reversal_learning_task_subject_9_Session_0_data.tsv", header = TRUE, sep = "\t", quote = "\"",dec = ".", fill = TRUE)

Data_pp10<- read.delim("Prob_reversal_learning_task_subject_10_Session_0_data.tsv", header = TRUE, sep = "\t", quote = "\"",dec = ".", fill = TRUE)
Data_pp11<- read.delim("Prob_reversal_learning_task_subject_11_Session_0_data.tsv", header = TRUE, sep = "\t", quote = "\"",dec = ".", fill = TRUE)
Data_pp12<- read.delim("Prob_reversal_learning_task_subject_12_Session_0_data.tsv", header = TRUE, sep = "\t", quote = "\"",dec = ".", fill = TRUE)
Data_pp13<- read.delim("Prob_reversal_learning_task_subject_13_Session_0_data.tsv", header = TRUE, sep = "\t", quote = "\"",dec = ".", fill = TRUE)
Data_pp14<- read.delim("Prob_reversal_learning_task_subject_14_Session_0_data.tsv", header = TRUE, sep = "\t", quote = "\"",dec = ".", fill = TRUE)

#combine data
Data_old<-rbind(Data_pp1,Data_pp2,Data_pp3,Data_pp4,Data_pp5,Data_pp6,Data_pp7,Data_pp8,Data_pp9)
Data_new<-rbind(Data_pp10,Data_pp11,Data_pp12,Data_pp13,Data_pp14)
Data<-rbind(Data_old,Data_new)

Data[1:10,]
Data=Data[,5:18]# use only relevant variables

#decode fb and accuracy on trial N-1 and whether short or long after rule switch
for (data in c(1:5600)){
  if (Data$Tr[data]>0){
    Data$corrP[data]=Data$corr[data-1]
    Data$FBP[data]=Data$FB[data-1]
  }
  if (Data$Switch_pass[data]<10){
    Data$cond[data]=1
  }else {
    Data$cond[data]=2
  }
}

#standardize data for plotting
Data$corr<-Data$corr*100
Data$RT<-Data$RT*1000

#eliminate late trials, the first  and for RT analyses also errors
Data_nolates<-Data[!(Data$FB==2),]
Data_nolates<-Data_nolates[!(Data_nolates$Tr==0),]
Data_nolates<-Data_nolates[!(Data_nolates$Break_pass==0),]
Data_nolates<-Data_nolates[!(Data_nolates$FBP==2),]
Data_noerrors<-Data_nolates[!(Data_nolates$corr==0),]

means=aggregate(Data_nolates[,8:9], list(Data_nolates$ppnr),mean)
means_RT=aggregate(Data_noerrors[,8], list(Data_noerrors$ppnr),mean)
means$RT<-means_RT$x
pirateplot(corr~ppnr, data=Data_nolates)
pirateplot(RT~ppnr, data=Data_noerrors)
boxplot(means$corr)
boxplot(means$RT)

for (sj in c(1:14)){
  if (means$RT[sj]<75){
    Data_nolates<-Data_nolates[!(Data_nolates$ppnr==sj),]
    Data_noerrors<-Data_noerrors[!(Data_noerrors$ppnr==sj),]
  }
} 

#extract the same data as in the model simulations and make comparative plots
First_trials<-Data[!(Data$Switch_pass>19),]

modeldata<-First_trials[(First_trials$part<3),]
modeldata$trial<-c(1:60)
modeldata<-modeldata[!(modeldata$FB==2),]

fig7<-summarySE(modeldata, measurevar = "corr", groupvars="trial")
fig8<-summarySE(modeldata, measurevar = "RT", groupvars="trial")

ggplot(fig7, aes(x=trial, y=corr)) + 
  geom_ribbon(aes(ymin=corr-ci, ymax=corr+ci), alpha=0.3)+
  geom_line()+
  geom_point()+
  geom_vline(xintercept=20, color="red",linetype="dashed")+
  geom_vline(xintercept=40, color="red",linetype="dashed")+
  theme_classic()+
  scale_y_continuous("Accuracy %",limits = c(-20, 120),breaks = seq(0, 100, 20)) + 
  labs(x="Trial")

ggplot(fig8, aes(x=trial, y=RT)) + 
  geom_ribbon(aes(ymin=RT-ci, ymax=RT+ci), alpha=0.3)+
  geom_line()+
  geom_point()+
  geom_vline(xintercept=20, color="red",linetype="dashed")+
  geom_vline(xintercept=40, color="red",linetype="dashed")+
  theme_classic()+
  labs(y="RT(ms)")
  labs(x="Trial")
  
model_fit<-lm(corr~part*Switch_pass,data=Data_nolates)
summary(model_fit)

#test linear models
fit_corr<-lm(corr~1+cond+part+corrP+FBP+FBP:corrP,data=Data_nolates)
fit_RT<-lm(RT~1+cond+part+corrP+FBP+FBP:corrP,data=Data_noerrors)

summary(fit_corr)
summary(fit_RT)

#plot interesting data
pirateplot(formula = corr~ corrP + FBP, data=Data_nolates)
pirateplot(formula = RT~ corrP + FBP, data=Data_noerrors)
pirateplot(formula = corr~ FBP, data=Data_nolates)
pirateplot(formula = corr~ corrP, data=Data_nolates)
pirateplot(formula = RT~ corrP, data=Data_noerrors)
pirateplot(formula = RT~ FBP, data=Data_noerrors)

fig1<- summarySE(Data_nolates, measurevar="corr", groupvars=c("FBP","corrP"))
fig2<- summarySE(Data_noerrors, measurevar="RT", groupvars=c("FBP","corrP"))

fig1$corrP<-as.factor(fig1$corrP)
fig1$FBP<-as.factor(fig1$FBP)

fig2$corrP<-as.factor(fig2$corrP)
fig2$FBP<-as.factor(fig2$FBP)

#prediction errors and RT
ggplot(fig2, aes(x=FBP, y=RT, colour=corrP, fill=corrP)) + 
  geom_errorbar(aes(ymin=RT-ci, ymax=RT+ci), position=position_dodge())+
  geom_bar(stat="identity",position=position_dodge())+
  labs(x="Feedback N-1")+
  labs(fill="Accuracy N-1")+
  scale_x_discrete(labels=c("0"="negative", "1"="positive"))+
  scale_fill_discrete(labels=c("0"="error","1"="correct"))
  
#prediction errors and accuracy
ggplot(fig1, aes(x=FBP, y=corr, colour=corrP, group=corrP)) + 
  geom_errorbar(aes(ymin=corr-ci, ymax=corr+ci))+
  geom_line()+
  geom_point()+
  labs(x="Feedback N-1")+
  labs(y="Accuracy N")+
  labs(colour="Accuracy N-1")+
  scale_x_discrete(labels=c("0"="negative", "1"="positive","2"="too late"))+
  scale_color_discrete(labels=c("0"="error","1"="correct"))

fig3<-summarySE(Data_nolates, measurevar="corr", groupvars=c("cond"))
fig4<-summarySE(Data_noerrors, measurevar="RT", groupvars=c("part"))

fig3$cond<-as.factor(fig3$cond)

# accuracy short or long after rule switch
ggplot(fig3, aes(x=cond, y=corr)) +
  geom_bar(stat="identity")+
  geom_errorbar(aes(ymin=corr-ci, ymax=corr+ci))+
  labs(x="After rule switch")+
  labs(y="Accuracy %")+
  scale_x_discrete(labels=c("1"="early", "2"="late"))

#RT evolution over blocks
ggplot(fig4, aes(x=part, y=RT)) + 
  geom_ribbon(aes(ymin=RT-ci, ymax=RT+ci), alpha=0.5)+
  geom_line()+
  geom_point()+
  labs(x="(rule)block")

fig5<-summarySE(Data_noerrors, measurevar="RT", groupvars=c("Switch_pass"))

#RT evolution after rule switch
ggplot(fig5, aes(x=Switch_pass, y=RT)) + 
  geom_ribbon(aes(ymin=RT-ci, ymax=RT+ci), alpha=0.5)+
  geom_line()+
  geom_point()+
  labs(x="Trial after switch")

fig6<-summarySE(Data_nolates, measurevar="corr", groupvars=c("Switch_pass"))

#Accuracy evolution after rule switch
ggplot(fig6, aes(x=Switch_pass, y=corr)) + 
  geom_ribbon(aes(ymin=corr-ci, ymax=corr+ci), alpha=0.5)+
  geom_line()+
  geom_point()+
  labs(x="Trial after switch")

fig9<-summarySE(Data_nolates, measurevar = "corr", groupvars="corrP")
fig10<-summarySE(Data_nolates, measurevar = "corr", groupvars="FBP")

fig11<-summarySE(Data_noerrors, measurevar = "RT", groupvars="corrP")
fig12<-summarySE(Data_noerrors, measurevar = "RT", groupvars="FBP")

fig9$corrP<-as.factor(fig9$corrP)
fig11$corrP<-as.factor(fig11$corrP)

fig10$FBP<-as.factor(fig10$FBP)
fig12$FBP<-as.factor(fig12$FBP)

ggplot(fig9, aes(x=corrP, y=corr)) +
  geom_bar(stat="identity")+
  geom_errorbar(aes(ymin=corr-ci, ymax=corr+ci))+
  labs(x="Accuracy N-1")+
  labs(y="Accuracy %")+
  scale_x_discrete(labels=c("0"="error", "1"="correct"))

ggplot(fig10, aes(x=FBP, y=corr)) +
  geom_bar(stat="identity")+
  geom_errorbar(aes(ymin=corr-ci, ymax=corr+ci))+
  labs(x="Feedback N-1")+
  labs(y="Accuracy %")+
  scale_x_discrete(labels=c("0"="negative", "1"="positive"))

ggplot(fig11, aes(x=corrP, y=RT)) +
  geom_bar(stat="identity")+
  geom_errorbar(aes(ymin=RT-ci, ymax=RT+ci))+
  labs(x="Accuracy N-1")+
  scale_x_discrete(labels=c("0"="error", "1"="correct"))

ggplot(fig12, aes(x=FBP, y=RT)) +
  geom_bar(stat="identity")+
  geom_errorbar(aes(ymin=RT-ci, ymax=RT+ci))+
  labs(x="Feedback N-1")+
  scale_x_discrete(labels=c("0"="negative", "1"="positive"))

