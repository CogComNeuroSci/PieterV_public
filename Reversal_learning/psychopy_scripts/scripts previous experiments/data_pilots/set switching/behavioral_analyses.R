setwd("~/Documents/catastrophic forgetting/empirical/data/set switching")

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
# read data
Data_pp1<- read.delim("set_switching_subject_1_Session_0_data.tsv", header = TRUE, sep = "\t", quote = "\"",dec = ".", fill = TRUE)
Data_pp2<- read.delim("set_switching_subject_2_Session_0_data.tsv", header = TRUE, sep = "\t", quote = "\"",dec = ".", fill = TRUE)
Data_pp3<- read.delim("set_switching_subject_3_Session_0_data.tsv", header = TRUE, sep = "\t", quote = "\"",dec = ".", fill = TRUE)
Data_pp4<- read.delim("set_switching_subject_4_Session_0_data.tsv", header = TRUE, sep = "\t", quote = "\"",dec = ".", fill = TRUE)

#combine data
Data<-rbind(Data_pp1,Data_pp2,Data_pp3,Data_pp4)

Data[1:10,]
Data=Data[,5:18]# use only relevant variables

#decode fb and accuracy on trial N-1 and whether short or long after rule switch
for (data in c(1:1600)){
  if (Data$Tr[data]>0){
    Data$corrP[data]=Data$corr[data-1]
  }
  if (Data$Switch_pass[data]<10){
    Data$cond[data]=1
  }else {
    Data$cond[data]=2
  }
}

#eliminate late trials, the first  and for RT analyses also errors
Data_nolates<-Data[!(Data$corr==2),]
Data_nolates<-Data_nolates[!(Data_nolates$Tr==0),]
Data_nolates<-Data_nolates[!(Data_nolates$Break_pass==0),]
Data_nolates<-Data_nolates[!(Data_nolates$corrP==2),]

#standardize data for plotting
Data_nolates$corr<-Data_nolates$corr*100
Data_nolates$RT<-Data_nolates$RT*1000

#RTdata
Data_noerrors<-Data_nolates[!(Data_nolates$corr==0),]

means=aggregate(Data_nolates[,9:10], list(Data_nolates$ppnr),mean)
means_RT=aggregate(Data_noerrors[,9], list(Data_noerrors$ppnr),mean)
means$RT<-means_RT$x
pirateplot(corr~ppnr, data=Data_nolates)
pirateplot(RT~ppnr, data=Data_noerrors)
boxplot(means$corr)
boxplot(means$RT)

for (sj in c(1:4)){
  if (means$RT[sj]<75){
    Data_nolates<-Data_nolates[!(Data_nolates$ppnr==sj),]
    Data_noerrors<-Data_noerrors[!(Data_noerrors$ppnr==sj),]
  }
} 

#extract the same data as in the model simulations and make comparative plots
First_trials<-Data[!(Data$Switch_pass>29),]

modeldata<-First_trials[(First_trials$part<3),]
modeldata$trial<-c(1:90)
modeldata<-modeldata[!(modeldata$corr==2),]

fig7<-summarySE(modeldata, measurevar = "corr", groupvars="trial")
fig8<-summarySE(modeldata, measurevar = "RT", groupvars="trial")

ggplot(fig7, aes(x=trial, y=corr)) + 
  geom_ribbon(aes(ymin=corr-ci, ymax=corr+ci), alpha=0.3)+
  geom_line()+
  geom_point()+
  geom_vline(xintercept=30, color="red",linetype="dashed")+
  geom_vline(xintercept=60, color="red",linetype="dashed")+
  theme_classic()+
  scale_y_continuous("Accuracy %",limits = c(-0.20, 1.20),breaks = seq(0, 1, 0.20)) + 
  labs(x="Trial")

ggplot(fig8, aes(x=trial, y=RT)) + 
  geom_ribbon(aes(ymin=RT-ci, ymax=RT+ci), alpha=0.3)+
  geom_line()+
  geom_point()+
  geom_vline(xintercept=30, color="red",linetype="dashed")+
  geom_vline(xintercept=60, color="red",linetype="dashed")+
  theme_classic()+
  labs(y="RT(ms)")
  labs(x="Trial")
  
model_fit<-lm(corr~part*Switch_pass,data=Data_nolates)
summary(model_fit)

#test linear models
fit_corr<-lm(corr~cond*part*corrP,data=Data_nolates)
fit_RT<-lm(RT~cond*part*corrP,data=Data_noerrors)

summary(fit_corr)
summary(fit_RT)

#plot interesting data
pirateplot(formula = corr~ corrP, data=Data_nolates)
pirateplot(formula = RT~ corrP, data=Data_noerrors)
pirateplot(formula = corr~ part, data=Data_nolates)
pirateplot(formula = corr~ cond, data=Data_nolates)
pirateplot(formula = RT~ part, data=Data_noerrors)
pirateplot(formula = RT~ cond, data=Data_noerrors)

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
