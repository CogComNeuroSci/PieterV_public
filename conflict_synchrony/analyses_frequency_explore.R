library(R.matlab)
library(lmerTest) 
library(car)
library(effects)
library(ggplot2)
library(Rmisc)
library(ggpubr)
library(gridExtra)
library(scales)
library(wesanderson)

rm(list=ls())

# setting folder
setwd("/Volumes/backupdisc/Adaptive_control/Extra")

#########################################################
# Loading and manipulating data
#########################################################
Trials=600
cfreq=seq(2,20,by=2)
pfreq=seq(10,100,by=10)

Dat<-read.table('Data_frequency_pars.txt', header = F, sep = "")
Sims=length(Dat[,1])/600

Dat[2:length(Dat[,1]),7]<-Dat[1:length(Dat[,1])-1,6]
names(Dat)<-c("Simulation", "Pfreq", "Cfreq", "Accuracy", "RT", "Congruency", "ConP")

Aggregated_data<-Dat[seq(1, length(Dat[,1]), by=Trials),1:3]
Dat$Simulation<-rep(seq(1,Sims),each=Trials)
Dat[seq(1, length(Dat[,1]), by=Trials),]<-NaN
Dat<-Dat[!is.na(Dat$Simulation),]
Dat<-Dat[!(Dat$RT==2000),]
Dat$LogRT<-log(Dat$RT)
Dat$Accuracy<-100*Dat$Accuracy

Aggregated_accuracy<-aggregate(Accuracy~Simulation, data=Dat, FUN=mean)
Aggregated_data$Accuracy<-Aggregated_accuracy$Accuracy
Aggregated_RT<-aggregate(LogRT~Simulation, data=Dat, FUN=mean)
Aggregated_data$RT<-Aggregated_RT$LogRT

for (i in seq(1, Sims)){
  Data<-Dat[Dat$Simulation==i,]
  RTmodel<-lm(LogRT~ Congruency*ConP, data=Data)
  RT_result<-Anova(RTmodel)
  Aggregated_data[i,6]<-RT_result[1,3]
  Aggregated_data[i,7]<-RT_result[3,3]
  
  ACCmodel<-glm(Accuracy/100~ Congruency*ConP, data=Data, family = binomial)
  
  ACC_result<-Anova(ACCmodel)
  Aggregated_data[i,8]<-ACC_result[1,1]
  Aggregated_data[i,9]<-ACC_result[3,1]
}

names(Aggregated_data)<-c("Simulation", "Pfreq", "Cfreq", "Accuracy","RT", "RT_Con", "RT_Grat","ACC_Con", "ACC_Grat")
Aggregated_data$ES<-(scale(Aggregated_data$Accuracy)-scale(Aggregated_data$RT))/2
Aggregated_data$ES_Con<-(scale(Aggregated_data$ACC_Con)+scale(Aggregated_data$RT_Con))/2
Aggregated_data$ES_Grat<-(scale(Aggregated_data$ACC_Con)+scale(Aggregated_data$RT_Grat))/2

pal <- wes_palette("Zissou1", 100, type = "continuous")

Acc_PC<-ggplot(data = Aggregated_data, aes(x=Pfreq, y=Cfreq, fill=ES))+
  #geom_contour_fill()+
  geom_raster(interpolate = TRUE)+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(-.25,.25), oob=squish)+
  geom_vline(xintercept=40, linetype="longdash")+
  geom_hline(yintercept=6, linetype="longdash")+
  theme_classic()+
  ggtitle("Efficiency")+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 10, face = "bold", hjust=0.5, family="Times"))+
  theme(legend.position = "top")+
  labs(x="Processing frequency")+
  labs(y="Control frequency")+
  labs(fill="Efficiency")

AccCon_PC<-ggplot(data = Aggregated_data, aes(x=Pfreq, y=Cfreq, fill=ES_Con))+
  #geom_contour_fill()+
  geom_raster(interpolate = TRUE)+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(-.25,.25), oob=squish)+
  geom_vline(xintercept=40, linetype="longdash")+
  geom_hline(yintercept=6, linetype="longdash")+
  theme_classic()+
  ggtitle("Congruency-effect")+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 10, face = "bold", hjust=0.5, family="Times"))+
  theme(legend.position = "top")+
  labs(x="Processing frequency")+
  labs(y="Control frequency")+
  labs(fill="Statistic")

AccGrat_PC<-ggplot(data = Aggregated_data, aes(x=Pfreq, y=Cfreq, fill=ES_Grat))+
  #geom_contour_fill()+
  geom_raster(interpolate = TRUE)+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(-.25,.25), oob=squish)+
  geom_vline(xintercept=40, linetype="longdash")+
  geom_hline(yintercept=6, linetype="longdash")+
  theme_classic()+
  ggtitle("Conflict-adaptation-effect")+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 10, face = "bold", hjust=0.5, family="Times"))+
  theme(legend.position = "top")+
  labs(x="Processing frequency")+
  labs(y="Control frequency")+
  labs(fill="Statistic")


ACC_Freq_fig<-ggarrange(Acc_PC, AccCon_PC, AccGrat_PC, ncol=3)
ACC_Freq_fig

ggsave(filename= "ES_Frequency.tiff", ACC_Freq_fig, width=15, height=6, units="cm", dpi=300)
ggsave(filename= "ES_Frequency.png", ACC_Freq_fig, width=15, height=6, units="cm", dpi=300)


