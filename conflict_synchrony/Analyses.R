library(R.matlab)
library(lmerTest) 
library(car)
library(effects)
library(ggplot2)
library(Rmisc)
library(ggpubr)
library(gridExtra)
library(scales)
library(ggeffects)

# setting folder
setwd("/Users/pieter/Documents/MATLAB/ta")

#non-adaptive model data
Dat<-read.table('Data_sim_os.txt', header = F, sep = "")

#This will be repeated for all three models
Dat[Dat[,5]==0,5]<-2                 #recode incongruency from 0 to 2 (gives nicer plots)
Dat[2:18000,14]<-Dat[1:17999,5]      #shift congruency to get congruency from previous trial
Dat[,8]<-Dat[,8]
Dat[,15]<-10*log10(Dat[,8]/Dat[,9])  #convert power to dB scale

names(Dat)<-c("Simulation", "Trial", "Stimulus", "Response","Congruency", "Accuracy", "RT", "MFC_power_Trial", "MFC_power_ITI",'Sync_relevant_Trial', 'Sync_irrelevant_Trial', 'Sync_relevant_ITI', 'Sync_irrelevant_ITI',"ConP",'Baselined_power')

Dat<-Dat[!(Dat$RT==2000),]       #Remove too late trials
Dat<-Dat[!(Dat$Trial==1),]       #Remove first trial

#define factors
Dat$Simulation<-as.factor(Dat$Simulation)
Dat$Trial<-as.factor(Dat$Trial)
Dat$Congruency<-as.factor(Dat$Congruency)
Dat$ConP<-as.factor(Dat$ConP)

#Collaps synchrony data
Dat$MeanSyncTrial<-(Dat$Sync_relevant_Trial+Dat$Sync_irrelevant_Trial)/2
Dat$MeanSyncITI<-(Dat$Sync_relevant_ITI+Dat$Sync_irrelevant_ITI)/2

Dat$Accuracypl<-Dat$Accuracy*100

#Log transform data
Dat$LogRT<-log(Dat$RT)

RT_os_model<-lmer(LogRT~ (1|Simulation) + Congruency*ConP, data=Dat)
summary(RT_os_model)
Anova(RT_os_model)

ACC_os_model<-glmer(Accuracy~(1|Simulation)+Congruency*ConP, data=Dat)
summary(ACC_os_model)
Anova(ACC_os_model)

ACC_plot=summarySE(Dat, measurevar="Accuracypl", groupvars= c("Congruency", "ConP", "Simulation"))
ACC_eff=summarySE(Dat, measurevar="Accuracypl", groupvars= c("Congruency", "ConP"))
RT_plot=summarySE(Dat, measurevar="LogRT", groupvars= c("Congruency", "ConP", "Simulation"))
RT_eff=summarySE(Dat, measurevar="LogRT", groupvars= c("Congruency", "ConP"))

Accuracy_os_fig<-ggplot(data = ACC_plot, aes(y=Accuracypl, x=ConP, color=Congruency, fill=Congruency))+
  geom_violin(alpha=0.5, position = position_identity())+
  geom_point(size=0.25)+
  geom_line(data=ACC_eff, aes(x=ConP, y=Accuracypl, color=Congruency, group=Congruency), size=2)+
  scale_color_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
  scale_fill_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
  scale_y_continuous(limits = c(80, 100))+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  #ggtitle("Accuracy Gratton effect")+
  scale_x_discrete(labels=c("1"="Congruent", "2"="Incongruent"))+
  labs(x="Congruency N-1")+
  labs(y="Accuracy %")+
  labs(color="Congruency N", fill="Congruency N")

Accuracy_os_fig

RT_os_fig<-ggplot(data = RT_plot, aes(y=LogRT, x=ConP, color=Congruency, fill=Congruency))+
  geom_violin(alpha=0.5, position = position_identity())+
  geom_point(size=0.25)+
  geom_line(data=RT_eff, aes(y=LogRT, x=ConP, color=Congruency, group=Congruency), size=2)+
  scale_color_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
  scale_fill_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
  scale_x_discrete(labels=c("1"="Congruent", "2"="Incongruent"))+
  scale_y_continuous(limits = c(5.5, 6.5))+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  ggtitle("Non-adaptive model")+
  labs(x="")+
  labs(y="LogRT")+
  labs(color="Congruency N", fill="Congruency N")

RT_os_fig

##############################################################
#temporal adaptive model data
Dat<-read.table('Data_sim_bis.txt', header = F, sep = "")

Dat[Dat[,5]==0,5]<-2
Dat[2:18000,14]<-Dat[1:17999,5]
Dat[,8]<-Dat[,8]
Dat[,15]<-10*log10(Dat[,8]/Dat[,9])

names(Dat)<-c("Simulation", "Trial", "Stimulus", "Response","Congruency", "Accuracy", "RT", "MFC_power_Trial", "MFC_power_ITI",'Sync_relevant_Trial', 'Sync_irrelevant_Trial', 'Sync_relevant_ITI', 'Sync_irrelevant_ITI',"ConP",'Baselined_power')

Dat<-Dat[!(Dat$RT==2000),]
Dat<-Dat[!(Dat$Trial==1),]

Dat$Simulation<-as.factor(Dat$Simulation)
Dat$Trial<-as.factor(Dat$Trial)
Dat$Congruency<-as.factor(Dat$Congruency)
Dat$ConP<-as.factor(Dat$ConP)

Dat$MeanSyncTrial<-(Dat$Sync_relevant_Trial+Dat$Sync_irrelevant_Trial)/2
Dat$MeanSyncITI<-(Dat$Sync_relevant_ITI+Dat$Sync_irrelevant_ITI)/2
Dat$Accuracypl<-Dat$Accuracy*100

Dat$LogRT<-log(Dat$RT)

RT_bis_model<-lmer(LogRT~ (1|Simulation) + Congruency*ConP, data=Dat)
summary(RT_bis_model)
Anova(RT_bis_model)

ACC_bis_model<-glmer(Accuracy~(1|Simulation)+Congruency*ConP, data=Dat)
summary(ACC_bis_model)
Anova(ACC_bis_model)

ACC_plot=summarySE(Dat, measurevar="Accuracypl", groupvars= c("Congruency", "ConP", "Simulation"))
ACC_eff=summarySE(Dat, measurevar="Accuracypl", groupvars= c("Congruency", "ConP"))
RT_plot=summarySE(Dat, measurevar="LogRT", groupvars= c("Congruency", "ConP", "Simulation"))
RT_eff=summarySE(Dat, measurevar="LogRT", groupvars= c("Congruency", "ConP"))

Accuracy_bis_fig<-ggplot(data = ACC_plot, aes(y=Accuracypl, x=ConP, color=Congruency, fill=Congruency))+
  geom_violin(alpha=0.5, position = position_identity())+
  geom_point(size=0.25)+
  geom_line(data=ACC_eff, aes(x=ConP, y=Accuracypl, color=Congruency, group=Congruency), size=2)+
  scale_color_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
  scale_fill_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
  scale_y_continuous(limits = c(80, 100))+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  #ggtitle("Accuracy Gratton effect")+
  scale_x_discrete(labels=c("1"="Congruent", "2"="Incongruent"))+
  labs(x="Congruency N-1")+
  labs(y="")+
  labs(color="Congruency N", fill="Congruency N")

Accuracy_bis_fig

RT_bis_fig<-ggplot(data = RT_plot, aes(y=LogRT, x=ConP, color=Congruency, fill=Congruency))+
  geom_violin(alpha=0.5, position = position_identity())+
  geom_point(size=0.25)+
  geom_line(data=RT_eff, aes(y=LogRT, x=ConP, color=Congruency, group=Congruency), size=2)+
  scale_color_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
  scale_fill_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
  scale_x_discrete(labels=c("1"="Congruent", "2"="Incongruent"))+
  scale_y_continuous(limits = c(5.5, 6.5))+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  ggtitle("Temporal adaptive model")+
  labs(x="")+
  labs(y="")+
  labs(color="Congruency N", fill="Congruency N")

RT_bis_fig

#########################################################
# Loading and manipulating data
#########################################################
# spatiotemporal adaptive model data
Dat<-read.table('Data_sim_tres.txt', header = F, sep = "")

Dat[Dat[,5]==0,5]<-2
Dat[2:18000,14]<-Dat[1:17999,5]
Dat[,8]<-Dat[,8]
Dat[,15]<-10*log10(Dat[,8]/Dat[,9])

names(Dat)<-c("Simulation", "Trial", "Stimulus", "Response","Congruency", "Accuracy", "RT", "MFC_power_Trial", "MFC_power_ITI",'Sync_relevant_Trial', 'Sync_irrelevant_Trial', 'Sync_relevant_ITI', 'Sync_irrelevant_ITI',"ConP",'Baselined_power')

Dat<-Dat[!(Dat$RT==2000),]
Dat<-Dat[!(Dat$Trial==1),]

Dat$Simulation<-as.factor(Dat$Simulation)
Dat$Trial<-as.factor(Dat$Trial)
Dat$Congruency<-as.factor(Dat$Congruency)
Dat$ConP<-as.factor(Dat$ConP)

Dat$MeanSyncTrial<-(Dat$Sync_relevant_Trial+Dat$Sync_irrelevant_Trial)/2
Dat$MeanSyncITI<-(Dat$Sync_relevant_ITI+Dat$Sync_irrelevant_ITI)/2
Dat$Accuracypl<-Dat$Accuracy*100

Dat$MFC_power_ITI<-10*log10(Dat$MFC_power_ITI)
Dat$MFC_power_Trial<-10*log10(Dat$MFC_power_Trial)

#########################################################
# Behavioral data
#########################################################

#If you want to check distributions see next 4 plots
RT_density<-ggplot(data=Dat, aes(x=RT, color=Congruency, fill= Congruency))+
            geom_density(alpha=0.5)+
            scale_color_manual(values=c("lightblue", "red"), labels=c("1"="Congruent", "2"="Incongruent"))+
            scale_fill_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
            theme_classic()+
            theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
            labs(x="RT (ms)")+
            labs(y="Density")+
            ggtitle("Untransformed RT distributions")+
            labs(color="Congruency N", fill= "Congruency N")

RT_density

RT_density_conP<-ggplot(data=Dat, aes(x=RT, color=ConP, fill= Congruency))+
  geom_density(alpha=0.5, size=3)+
  scale_color_manual(values=c("black", "white"), labels=c("1"="Congruent", "2"="Incongruent"))+
  scale_fill_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  ggtitle("Untransformed RT distributions")+
  labs(x="RT (ms)")+
  labs(y="Density")+
  labs(fill="Congruency N")+
  labs(color="Congruency N-1")

RT_density_conP

Dat$LogRT<-log(Dat$RT)

LogRT_density<-ggplot(data=Dat, aes(x=LogRT, color=Congruency, fill= Congruency))+
  geom_density(alpha=0.5)+
  scale_color_manual(values=c("lightblue", "red"), labels=c("1"="Congruent", "2"="Incongruent"))+
  scale_fill_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  ggtitle("Transformed RT distributions")+
  labs(x="LogRT")+
  labs(y="Density")+
  labs(color="Congruency N", fill= "Congruency N")

LogRT_density

LogRT_density_conP<-ggplot(data=Dat, aes(x=LogRT, color=ConP, fill= Congruency))+
  geom_density(alpha=0.5, size=3)+
  scale_color_manual(values=c("black", "lightgrey"), labels=c("1"="Congruent", "2"="Incongruent"))+
  scale_fill_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  ggtitle("Transformed RT distributions")+
  labs(x="LogRT")+
  labs(y="Density")+
  labs(fill="Congruency N")+
  labs(color="Congruency N-1")

LogRT_density_conP

RTmodel<-lmer(LogRT~ (1|Simulation)+Congruency*ConP, data=Dat)
summary(RTmodel)
Anova(RTmodel)

ACCmodel<-glmer(Accuracy~ (1|Simulation)+Congruency*ConP, data=Dat)
summary(ACCmodel)
Anova(ACCmodel)

ACC_plot=summarySE(Dat, measurevar="Accuracypl", groupvars= c("Congruency", "ConP", "Simulation"))
ACC_eff=summarySE(Dat, measurevar="Accuracypl", groupvars= c("Congruency", "ConP"))
RT_plot=summarySE(Dat, measurevar="LogRT", groupvars= c("Congruency", "ConP", "Simulation"))
RT_eff=summarySE(Dat, measurevar="LogRT", groupvars= c("Congruency", "ConP"))

Accuracy_fig<-ggplot(data = ACC_plot, aes(y=Accuracypl, x=ConP, color=Congruency, fill=Congruency))+
              geom_violin(alpha=0.5, position = position_identity())+
              geom_point(size=0.25)+
              geom_line(data=ACC_eff, aes(x=ConP, y=Accuracypl, color=Congruency, group=Congruency), size=2)+
              scale_color_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
              scale_fill_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
              scale_y_continuous(limits = c(80, 100))+
              theme_classic()+
              theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
              #ggtitle("Accuracy Gratton effect")+
              scale_x_discrete(labels=c("1"="Congruent", "2"="Incongruent"))+
              labs(x="Congruency N-1")+
              labs(y="")+
              labs(color="Congruency N", fill="Congruency N")
              
Accuracy_fig

RT_fig<-ggplot(data = RT_plot, aes(y=LogRT, x=ConP, color=Congruency, fill=Congruency))+
  geom_violin(alpha=0.5, position = position_identity())+
  geom_point(size=0.25)+
  geom_line(data=RT_eff, aes(y=LogRT, x=ConP, color=Congruency, group=Congruency), size=2)+
  scale_color_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
  scale_fill_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
  scale_x_discrete(labels=c("1"="Congruent", "2"="Incongruent"))+
  scale_y_continuous(limits = c(5.5, 6.5))+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  ggtitle("Spatiotemporal adaptive model")+
  labs(x="")+
  labs(y="")+
  labs(color="Congruency N", fill="Congruency N")

RT_fig

Behavioral_figure<-ggarrange(RT_os_fig, RT_bis_fig, RT_fig, Accuracy_os_fig, Accuracy_bis_fig, Accuracy_fig, nrow = 2, ncol=3, labels = "AUTO",font.label = list(size = 10, color = "black", face = "bold", family = "Times"), common.legend = TRUE)
Behavioral_figure

#########################################################
# Sync data
#########################################################

Syncmodel<-lmer(MeanSyncTrial~ (1|Simulation)+Congruency*ConP, data=Dat)
summary(Syncmodel)
Anova(Syncmodel)

Sync_plot=summarySE(Dat, measurevar="MeanSyncTrial", groupvars= c("Congruency", "ConP", "Simulation"))
Sync_eff=summarySE(Dat, measurevar="MeanSyncTrial", groupvars= c("Congruency", "ConP"))

Sync_fig<-ggplot(data = Sync_plot, aes(y=MeanSyncTrial, x=ConP, color=Congruency, fill=Congruency))+
  geom_violin(alpha=0.5, position = position_identity())+
  geom_point(size=0.25)+
  geom_line(data=Sync_eff, aes(x=ConP, y=MeanSyncTrial, color=Congruency, group=Congruency), size=2)+
  scale_color_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
  scale_fill_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"), legend.position = "top")+
  #ggtitle("Sync Gratton")+
  scale_x_discrete(labels=c("1"="Congruent", "2"="Incongruent"))+
  labs(x="Congruency N-1")+
  labs(y="Mean Sync")+
  labs(color="Congruency N", fill= "Congruency N")

Sync_fig

SyncRT_model<-lmer(LogRT~(1|Simulation)+MeanSyncTrial+MeanSyncTrial:Congruency, data=Dat)

Anova(SyncRT_model)

Quadratic_Con<-lmer(LogRT~(1|Simulation)+ MeanSyncTrial+ I(MeanSyncTrial^2), data=Dat[Dat$Congruency==1,] )
summary(Quadratic_Con)
Anova(Quadratic_Con)
Con_data<-coef(Quadratic_Con)$Simulation

Quadratic_InCon<-lmer(LogRT~(1|Simulation)+ MeanSyncTrial+ I(MeanSyncTrial^2), data=Dat[Dat$Congruency==2,] )
Anova(Quadratic_InCon)
summary(Quadratic_InCon)
InCon_data<-coef(Quadratic_InCon)$Simulation

Fit_data<-data.frame(matrix(,30*11*2,4,dimnames=list(c(), c("Congruency", "Simulation","Sync","fit"))))
S<-seq(0,1,by=0.1)
counter1=1
counter2=length(S)
for (cong in c(1,2)){
  for (Sim in seq(1,30)){
    Fit_data$Congruency[counter1:counter2]<-rep(c(cong), times = length(S))
    Fit_data$Simulation[counter1:counter2]<-rep(c(Sim), times = length(S))
    Fit_data$Sync[counter1:counter2]<-S
    if (cong==1){
      Fit_data$fit[counter1:counter2]<-Con_data[Sim,1]+Con_data[Sim,2]*S+ Con_data[Sim,3]*S^2
    }else{
      Fit_data$fit[counter1:counter2]<-InCon_data[Sim,1]+InCon_data[Sim,2]*S+ InCon_data[Sim,3]*S^2
    }
    counter1= counter1+length(S)
    counter2=counter2+length(S)
  }
}

Fit_data$Congruency<-as.factor(Fit_data$Congruency)
RT_sync_con=summarySE(Dat, measurevar="LogRT", groupvars= c("MeanSyncTrial", "Congruency"))
RT_sync_eff = summarySE(Fit_data, measurevar="fit", groupvars= c("Sync", "Congruency"))

RTSync_fig<-ggplot(data = RT_sync_con, aes(y=LogRT, x=MeanSyncTrial, color=Congruency))+
  geom_point(size=0.01, alpha=0.25)+
  geom_line(data=RT_sync_eff, aes(y=fit, x=Sync, color=Congruency), size=2)+
  scale_color_manual(values=c("lightblue", "red"), labels=c("1"="Congruent", "2"="Incongruent"))+
  scale_x_continuous(limits=c(0,1))+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  ggtitle("Synchrony")+
  labs(x="")+
  labs(y="")+
  labs(color="Congruency N")

RTSync_fig

SyncAccuracy_model<-glmer(Accuracy~(1|Simulation)+MeanSyncTrial+MeanSyncTrial:Congruency, data=Dat, family = binomial(link = "logit"))
Anova(SyncAccuracy_model)

I<-rep(c(100), times=30)
Con_data<-as.data.frame(I)
Con_data$MeanSyncTrial<-rep(c(0), times=30)
Con_data$MeanSyncTrial2<-rep(c(0), times=30)
names(Con_data)<-c("(Intercept)", "MeanSyncTrial", "I(MeanSyncTrial^2)")

Aggregated_data=summarySE(Dat, measurevar="Accuracypl", groupvars= c("MeanSyncTrial", "Congruency","Simulation"))
Quadratic_InCon<-lmer(Accuracypl~(1|Simulation)+ MeanSyncTrial+ I(MeanSyncTrial^2), data=Aggregated_data[Aggregated_data$Congruency==2,])
Anova(Quadratic_InCon)
summary(Quadratic_InCon)
InCon_data<-coef(Quadratic_InCon)$Simulation

Fit_data<-data.frame(matrix(,30*11*2,4,dimnames=list(c(), c("Congruency", "Simulation","Sync","fit"))))
S<-seq(0,1,by=0.1)
counter1=1
counter2=length(S)
for (cong in c(1,2)){
  for (Sim in seq(1,30)){
    Fit_data$Congruency[counter1:counter2]<-rep(c(cong), times = length(S))
    Fit_data$Simulation[counter1:counter2]<-rep(c(Sim), times = length(S))
    Fit_data$Sync[counter1:counter2]<-S
    if (cong==1){
      Fit_data$fit[counter1:counter2]<-Con_data[Sim,1]+Con_data[Sim,2]*S+ Con_data[Sim,3]*S^2
    }else{
      Fit_data$fit[counter1:counter2]<-InCon_data[Sim,1]+InCon_data[Sim,2]*S+ InCon_data[Sim,3]*S^2
    }
    counter1= counter1+length(S)
    counter2=counter2+length(S)
  }
}

Fit_data$Congruency<-as.factor(Fit_data$Congruency)
Accuracy_sync_eff = summarySE(Fit_data, measurevar="fit", groupvars= c("Sync", "Congruency"))

Syncbins = cut(Dat$MeanSyncTrial, breaks=seq(0,1, by=0.1))

Accuracy_sync_con=summarySE(Dat, measurevar="Accuracypl", groupvars= c("Syncbins", "Congruency"))
levels(Accuracy_sync_con$Syncbins)<-seq(0,0.9, by=0.1)
Accuracy_sync_con$Syncbins<-as.numeric(paste(Accuracy_sync_con$Syncbins))
Accuracy_sync_con[is.na(Accuracy_sync_con$Syncbins),1]<-1

AccuracySync_fig<-ggplot(data = Accuracy_sync_con, aes(y=Accuracypl, x=Syncbins, color=Congruency))+
  geom_point(size=2)+
  geom_errorbar(aes(ymin=Accuracypl-ci, ymax=Accuracypl+ci), width=0)+
  geom_line(data=Accuracy_sync_eff, aes(y=fit, x=Sync, color= Congruency), size=2, alpha=0.5)+
  scale_color_manual(values=c("lightblue", "red"), labels=c("1"="Congruent", "2"="Incongruent"))+
  scale_x_continuous(limits=c(0,1))+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  #ggtitle("Accuracy by Sync X Congruency")+
  labs(x="Mean Sync")+
  labs(y="")+
  labs(color="Congruency N")

AccuracySync_fig

#########################################################
# Power data
#########################################################

Powermodel<-lmer(Baselined_power~(1|Simulation)+Congruency*ConP, data=Dat)
summary(Powermodel)
Anova(Powermodel)

Power_density<-ggplot(data=Dat, aes(x=Baselined_power, color=Congruency, fill= Congruency))+
  geom_density(alpha=0.5)+
  scale_color_manual(values=c("lightblue", "red"), labels=c("1"="Congruent", "2"="Incongruent"))+
  scale_fill_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  ggtitle("Power Congruency-effect")+
  labs(x="MFC baselined power (dB)")+
  labs(y="Density")+
  labs(color="Congruency N", fill= "Congruency N")

Power_density

Power_plot=summarySE(Dat, measurevar="Baselined_power", groupvars= c("Congruency", "ConP", "Simulation"))
Power_eff=summarySE(Dat, measurevar="Baselined_power", groupvars= c("Congruency", "ConP"))

Power_fig<-ggplot(data = Power_plot, aes(y=Baselined_power, x=ConP, color=Congruency, fill=Congruency))+
  geom_violin(alpha=0.5, position = position_identity())+
  geom_point(size=0.25)+
  geom_line(data=Power_eff, aes(x=ConP, y=Baselined_power, color=Congruency, group=Congruency), size=2)+
  scale_color_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
  scale_fill_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  ggtitle("Baselined reactive control")+
  scale_x_discrete(labels=c("1"="Congruent", "2"="Incongruent"))+
  labs(x="Congruency N-1")+
  labs(y="baselined trial power (dB)")+
  labs(color="Congruency N", fill= "Congruency N")

Power_fig

Power_plot_Trial=summarySE(Dat, measurevar="MFC_power_Trial", groupvars= c("Congruency", "ConP", "Simulation"))
Power_eff_Trial=summarySE(Dat, measurevar="MFC_power_Trial", groupvars= c("Congruency", "ConP"))

PowerTrialmodel<-lmer(MFC_power_Trial~(1|Simulation)+Congruency*ConP, data=Dat)
summary(PowerTrialmodel)
Anova(PowerTrialmodel)

Power_fig_Trial<-ggplot(data = Power_plot_Trial, aes(y=MFC_power_Trial, x=ConP, color=Congruency, fill=Congruency))+
  geom_violin(alpha=0.5, position = position_identity())+
  geom_point(size=0.25)+
  geom_line(data=Power_eff_Trial, aes(x=ConP, y=MFC_power_Trial, color=Congruency, group=Congruency), size=2)+
  scale_color_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
  scale_fill_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  ggtitle("Reactive Control")+
  scale_x_discrete(labels=c("1"="Congruent", "2"="Incongruent"))+
  labs(x="Congruency N-1")+
  labs(y="unbaselined trial power (dB)")+
  labs(color="Congruency N", fill= "Congruency N")

Power_fig_Trial

Power_plot_ITI=summarySE(Dat, measurevar="MFC_power_ITI", groupvars= c("Congruency", "ConP", "Simulation"))
Power_eff_ITI=summarySE(Dat, measurevar="MFC_power_ITI", groupvars= c("Congruency", "ConP"))

PowerITImodel<-lmer(MFC_power_ITI~(1|Simulation)+Congruency*ConP, data=Dat)
summary(PowerITImodel)
Anova(PowerITImodel)

Power_fig_ITI<-ggplot(data = Power_plot_ITI, aes(y=MFC_power_ITI, x=ConP, color=Congruency, fill=Congruency))+
  geom_violin(alpha=0.5, position = position_identity())+
  geom_point(size=0.25)+
  geom_line(data=Power_eff_ITI, aes(x=ConP, y=MFC_power_ITI, color=Congruency, group=Congruency), size=2)+
  scale_color_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
  scale_fill_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  ggtitle("Proactive control")+
  scale_x_discrete(labels=c("1"="Congruent", "2"="Incongruent"))+
  labs(x="Congruency N-1")+
  labs(y="unbaselined ITI power (dB)")+
  labs(color="Congruency N", fill= "Congruency N")

Power_fig_ITI

Con_Em<-as.factor(rep(c(1,2), each=2))
ConP_Em<-as.factor(rep(c(1,2), times=2))
Mean<-10*log10(c(56,62, 156, 115)/100)

Empirical_power_data<-data.frame(Con_Em, ConP_Em, Mean)
Power_fig_Empirical<-ggplot(data = Empirical_power_data, aes(y=Mean, x=ConP_Em, color=Con_Em, fill =Con_Em, group=Con_Em))+
  geom_line(size=2)+
  scale_color_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
  scale_fill_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  ggtitle("Empirical data")+
  scale_x_discrete(labels=c("1"="Congruent", "2"="Incongruent"))+
  labs(x="Congruency N-1")+
  labs(y="baselined trial power (dB)")+
  labs(color="Congruency N", fill= "Congruency N")

Power_Gratton_figure<-ggarrange(Power_fig_Trial, Power_fig_ITI, Power_fig, Power_fig_Empirical, ncol = 2, nrow = 2, labels = "AUTO",font.label = list(size = 10, color = "black", face = "bold", family = "Times"),common.legend = TRUE)
Power_Gratton_figure

PowerRT_model<-lmer(LogRT~(1|Simulation)+Baselined_power+Baselined_power:Congruency, data=Dat)
Anova(PowerRT_model)

RT_Power_con=summarySE(Dat, measurevar="LogRT", groupvars= c("Baselined_power", "Congruency"))

RT_Power_eff<-ggpredict(PowerRT_model, c("Baselined_power[all]", "Congruency"))

RTPower_fig<-ggplot(data = RT_Power_con, aes(y=LogRT, x=Baselined_power, color=Congruency))+
  geom_point(size=0.01, alpha =0.2)+
  geom_line(data=RT_Power_eff, aes(y=predicted, x=x, color= group), size=2)+
  scale_color_manual(values=c("lightblue", "red"), labels=c("1"="Congruent", "2"="Incongruent"))+
  scale_x_continuous(limits=c(-2,4))+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  ggtitle("Baselined reactive control")+
  labs(x="")+
  labs(y="")+
  labs(color="Congruency N")

RTPower_fig

PowerAccuracy_model<-glmer(Accuracy~(1|Simulation)+Baselined_power+Baselined_power:Congruency, data=Dat, family = binomial(link = "logit"))
summary(PowerAccuracy_model)
Anova(PowerAccuracy_model)

Powerbins = cut(Dat$Baselined_power, breaks=seq(-2,4, by=0.2))

Accuracy_power_con=summarySE(Dat, measurevar="Accuracypl", groupvars= c("Powerbins", "Congruency"))
levels(Accuracy_power_con$Powerbins)<-seq(-2,3.8, by=0.2)
Accuracy_power_con$Powerbins<-as.numeric(paste(Accuracy_power_con$Powerbins))
Accuracy_power_con[is.na(Accuracy_power_con$Powerbins),1]<-4

ACCPower_eff<-ggpredict(PowerAccuracy_model, c("Baselined_power[all]", "Congruency"))
ACCPower_eff$predicted[ACCPower_eff$group==1]<-1

AccuracyPower_fig<-ggplot(data = Accuracy_power_con, aes(y=Accuracypl, x=Powerbins, color=Congruency))+
  geom_point(size=2)+
  geom_errorbar(aes(ymin=Accuracypl-ci, ymax=Accuracypl+ci), width=0)+
  geom_line(data=ACCPower_eff, aes(y=predicted*100, x=x, color= group), size=2, alpha=0.5)+
  scale_color_manual(values=c("lightblue", "red"), labels=c("1"="Congruent", "2"="Incongruent"))+
  scale_x_continuous(limits=c(-2,4))+
  scale_y_continuous(limits=c(60,100))+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  #ggtitle("Re-active control")+
  labs(x="baselined trial power (dB)")+
  labs(y="")+
  labs(color="Congruency N")

AccuracyPower_fig

PowerTrial_density<-ggplot(data=Dat, aes(x=MFC_power_Trial, color=Congruency, fill= Congruency))+
  geom_density(alpha=0.5)+
  scale_color_manual(values=c("lightblue", "red"), labels=c("1"="Congruent", "2"="Incongruent"))+
  scale_fill_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  ggtitle("Power Congruency-effect")+
  labs(x="MFC power")+
  labs(y="Density")+
  labs(color="Congruency N", fill= "Congruency N")

PowerTrial_density

PowerRTTrial_model<-lmer(LogRT~(1|Simulation)+MFC_power_Trial+MFC_power_Trial:Congruency, data=Dat)
Anova(PowerRTTrial_model)
summary(PowerRTTrial_model)
RT_PowerTrial_con=summarySE(Dat, measurevar="LogRT", groupvars= c("MFC_power_Trial", "Congruency"))

RTPowerTrial_eff<-ggpredict(PowerRTTrial_model, c("MFC_power_Trial[all]", "Congruency"))

RTPowerTrial_fig<-ggplot(data = RT_PowerTrial_con, aes(y=LogRT, x=MFC_power_Trial, color=Congruency))+
  geom_point(size=0.01, alpha = 0.2)+
  geom_line(data=RTPowerTrial_eff, aes(y=predicted, x=x, color= group), size=2)+
  scale_color_manual(values=c("lightblue", "red"), labels=c("1"="Congruent", "2"="Incongruent"))+
  scale_x_continuous(limits=c(-8,4))+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  ggtitle("Reactive control")+
  labs(x="")+
  labs(y="LogRT")+
  labs(color="Congruency N")

RTPowerTrial_fig

PowerAccuracyTrial_model<-glmer(Accuracy~(1|Simulation)+MFC_power_Trial+MFC_power_Trial:Congruency, data=Dat, family = binomial(link = "logit"))
Anova(PowerAccuracyTrial_model)

PowerbinsTrial = cut(Dat$MFC_power_Trial, breaks=seq(-8,4, by=1))

Accuracy_powerTrial_con=summarySE(Dat, measurevar="Accuracypl", groupvars= c("PowerbinsTrial", "Congruency"))
levels(Accuracy_powerTrial_con$PowerbinsTrial)<-seq(-8,3, by=1)
Accuracy_powerTrial_con$PowerbinsTrial<-as.numeric(paste(Accuracy_powerTrial_con$PowerbinsTrial))
Accuracy_powerTrial_con[is.na(Accuracy_powerTrial_con$PowerbinsTrial),1]<-4

ACCPowerTrial_eff<-ggpredict(PowerAccuracyTrial_model, c("MFC_power_Trial[all]", "Congruency"))
ACCPowerTrial_eff$predicted[ACCPowerTrial_eff$group==1]<-1

AccuracyPowerTrial_fig<-ggplot(data = Accuracy_powerTrial_con, aes(y=Accuracypl, x=PowerbinsTrial, color=Congruency))+
  geom_point(size=2)+
  geom_errorbar(aes(ymin=Accuracypl-ci, ymax=Accuracypl+ci), width=0)+
  geom_line(data=ACCPowerTrial_eff, aes(y=predicted*100, x=x, color= group), size=2, alpha=0.5)+
  scale_color_manual(values=c("lightblue", "red"), labels=c("1"="Congruent", "2"="Incongruent"))+
  scale_x_continuous(limits=c(-8,4))+
  scale_y_continuous(limits=c(60,100))+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  #ggtitle("Combined control")+
  labs(x="unbaselined trial power (dB)")+
  labs(y="Accuracy %")+
  labs(color="Congruency N")

AccuracyPowerTrial_fig

PowerITI_density<-ggplot(data=Dat, aes(x=MFC_power_ITI, color=ConP, fill= ConP))+
  geom_density(alpha=0.5)+
  scale_color_manual(values=c("lightblue", "red"), labels=c("1"="Congruent", "2"="Incongruent"))+
  scale_fill_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  ggtitle("Power Congruency-effect")+
  labs(x="MFC power")+
  labs(y="Density")+
  labs(color="Congruency N-1", fill= "Congruency N-1")

PowerITI_density

PowerRTITI_model<-lmer(LogRT~(1|Simulation)+MFC_power_ITI+MFC_power_ITI:Congruency, data=Dat)
Anova(PowerRTITI_model)

RT_PowerITI_con=summarySE(Dat, measurevar="LogRT", groupvars= c("MFC_power_ITI", "Congruency"))

RTPowerITI_eff = effect("MFC_power_ITI:Congruency", PowerRTITI_model, xlevels=list(MFC_power_ITI=seq(-8,4, by=0.1)))

x.fit <- unlist(RTPowerITI_eff$x.all)
x <- data.frame(lower = RTPowerITI_eff$lower, upper = RTPowerITI_eff$upper, fit = RTPowerITI_eff$fit)
x$MFC_power_ITI<-RTPowerITI_eff$x$MFC_power_ITI
x$Congruency<-RTPowerITI_eff$x$Congruency
x$Congruency<-as.factor(x$Congruency)

RTPowerITI_fig<-ggplot(data = RT_PowerITI_con, aes(y=LogRT, x=MFC_power_ITI, color=Congruency))+
  geom_point(size=0.01, alpha =0.2)+
  geom_line(data=x, aes(y=fit, x=MFC_power_ITI, color= Congruency), size=2)+
  geom_ribbon(data= x, aes(y=fit, x=MFC_power_ITI, ymin = lower, ymax = upper, fill=Congruency), alpha=0.5, colour = NA)+
  scale_color_manual(values=c("lightblue", "red"), labels=c("1"="Congruent", "2"="Incongruent"))+
  scale_fill_manual(values=c("lightblue", "red"), labels=c("1"="Congruent", "2"="Incongruent"))+
  scale_x_continuous(limits=c(-8,4))+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  ggtitle("Proactive control")+
  labs(x="")+
  labs(y="")+
  labs(color="Congruency N")+
  labs(fill="Congruency N")

RTPowerITI_fig

PowerAccuracyITI_model<-glmer(Accuracy~(1|Simulation)+MFC_power_ITI+MFC_power_ITI:Congruency, data=Dat, family = binomial(link = "logit"))
summary(PowerAccuracyITI_model)
Anova(PowerAccuracyITI_model)

PowerbinsITI = cut(Dat$MFC_power_ITI, breaks=seq(-8,4, by=1))

Accuracy_powerITI_con=summarySE(Dat, measurevar="Accuracypl", groupvars= c("PowerbinsITI", "Congruency"))
levels(Accuracy_powerITI_con$PowerbinsITI)<-seq(-8,3, by=1)
Accuracy_powerITI_con$PowerbinsITI<-as.numeric(paste(Accuracy_powerITI_con$PowerbinsITI))
Accuracy_powerITI_con[is.na(Accuracy_powerITI_con$PowerbinsITI),1]<-4

ACCPowerITI_eff<-ggpredict(PowerAccuracyITI_model, c("MFC_power_ITI[all]", "Congruency"))
ACCPowerITI_eff$predicted[ACCPowerITI_eff$group==1]<-1

AccuracyPowerITI_fig<-ggplot(data = Accuracy_powerITI_con, aes(y=Accuracypl, x=PowerbinsITI, color=Congruency))+
  geom_point(size=2)+
  geom_errorbar(aes(ymin=Accuracypl-ci, ymax=Accuracypl+ci), width=0)+
  geom_line(data=ACCPowerITI_eff, aes(y=predicted*100, x=x, color= group), size=2, alpha=0.5)+
  scale_color_manual(values=c("lightblue", "red"), labels=c("1"="Congruent", "2"="Incongruent"))+
  scale_x_continuous(limits=c(-8,4))+
  scale_y_continuous(limits=c(60,100))+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  #ggtitle("Pro-active control")+
  labs(x="unbaselined ITI power (dB)")+
  labs(y="")+
  labs(color="Congruency N")

AccuracyPowerITI_fig

Neural_behavioral_figure<-ggarrange(RTPowerTrial_fig, RTPowerITI_fig, RTPower_fig, RTSync_fig, AccuracyPowerTrial_fig, AccuracyPowerITI_fig, AccuracyPower_fig,AccuracySync_fig, nrow = 2, ncol=4, labels = "AUTO",font.label = list(size = 10, color = "black", face = "bold", family = "Times"), common.legend = TRUE)

Behavioral_figure
ggsave(filename= "Behavioral.tiff", Behavioral_figure, width=15, height=10, units="cm", dpi=300)
Sync_fig
ggsave(filename= "Sync.tiff", Sync_fig, width=7, height=6, units="cm", dpi=300)
Power_Gratton_figure
ggsave(filename= "Power.tiff", Power_Gratton_figure, width=10, height=11, units="cm", dpi=300)
Neural_behavioral_figure
ggsave(filename= "Neural_Behavioral.tiff", Neural_behavioral_figure, width=19, height=10, units="cm", dpi=300)

ggsave(filename= "Behavioral.png", Behavioral_figure, width=15, height=10, units="cm", dpi=300)

ggsave(filename= "Sync.png", Sync_fig, width=7, height=6, units="cm", dpi=300)

ggsave(filename= "Power.png", Power_Gratton_figure, width=10, height=11, units="cm", dpi=300)

ggsave(filename= "Neural_Behavioral.png", Neural_behavioral_figure, width=19, height=10, units="cm", dpi=300)



