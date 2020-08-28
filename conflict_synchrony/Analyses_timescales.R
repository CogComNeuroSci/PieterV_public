library(R.matlab)
library(lmerTest) 
library(car)
library(effects)
library(ggplot2)
library(Rmisc)
library(ggpubr)
library(gridExtra)
library(scales)

# setting folder
setwd("/Users/pieter/Documents/MATLAB/ta")

#########################################################
# Loading and manipulating data
#########################################################

## dataset with only pro-active control
Dat<-read.table('Data_sim_extra.txt', header = F, sep = "")

#this pipeline will be repeated for both simulations

Dat[Dat[,5]==0,5]<-2                   #recode congruency (plots are nicer if incongruency is 2 instead of 0)
Dat[2:18000,14]<-Dat[1:17999,5]        #Code congruency of previous trial
Dat[,15]<-10*log10(Dat[,8]/Dat[,9])    #Set power to dB scale

names(Dat)<-c("Simulation", "Trial", "Stimulus", "Response","Congruency", "Accuracy", "RT", "MFC_power_Trial", "MFC_power_ITI",'Sync_relevant_Trial', 'Sync_irrelevant_Trial', 'Sync_relevant_ITI', 'Sync_irrelevant_ITI',"ConP",'Baselined_power')

Dat<-Dat[!(Dat$RT==2000),]             #eliminate too late trials
Dat<-Dat[!(Dat$Trial==1),]             #Remove first trial of every simulation

#define factors
Dat$Simulation<-as.factor(Dat$Simulation)
Dat$Trial<-as.factor(Dat$Trial)
Dat$Congruency<-as.factor(Dat$Congruency)
Dat$ConP<-as.factor(Dat$ConP)

#collapse synchrony data
Dat$MeanSyncTrial<-(Dat$Sync_relevant_Trial+Dat$Sync_irrelevant_Trial)/2
Dat$MeanSyncITI<-(Dat$Sync_relevant_ITI+Dat$Sync_irrelevant_ITI)/2

Dat$Accuracypl<-Dat$Accuracy*100

#########################################################
# Behavioral data
#########################################################

#log transform rt
Dat$LogRT<-log(Dat$RT)

Dataset_RT<-aggregate(Dat$LogRT, list(Dat$Congruency,Dat$ConP, Dat$Simulation), FUN=mean)
names(Dataset_RT)<-c("Congruency", "ConP", "Simulation", "LogRT")
RTmodel<-lm(LogRT~ Congruency*ConP, data=Dataset_RT)
summary(RTmodel)
Anova(RTmodel)

RT2<-aggregate(Dat$LogRT, list(Dat$ConP, Dat$Simulation), FUN=mean)
names(RT2)<-c("ConP", "Simulation", "LogRT")
t.test(LogRT~ConP, paired=TRUE, data=RT2)

Dataset_ACC<-aggregate(Dat$Accuracy, list(Dat$Congruency,Dat$ConP, Dat$Simulation), FUN=mean)
names(Dataset_ACC)<-c("Congruency", "ConP", "Simulation", "Accuracy")
ACCmodel<-lm(Accuracy~Congruency*ConP, data=Dataset_ACC)
summary(ACCmodel)
Anova(ACCmodel)

ACC_plot=summarySE(Dat, measurevar="Accuracypl", groupvars= c("Congruency", "ConP", "Simulation"))
ACC_eff=summarySE(Dat, measurevar="Accuracypl", groupvars= c("Congruency", "ConP"))
RT_plot=summarySE(Dat, measurevar="LogRT", groupvars= c("Congruency", "ConP", "Simulation"))
RT_eff=summarySE(Dat, measurevar="LogRT", groupvars= c("Congruency", "ConP"))

Accuracy_fig<-ggplot(data = ACC_plot, aes(y=Accuracypl, x=ConP, color=Congruency, fill=Congruency))+
              geom_violin(alpha=0.5, position = position_identity())+
              geom_point()+
              geom_line(data=ACC_eff, aes(x=ConP, y=Accuracypl, color=Congruency, group=Congruency), size=2)+
              scale_color_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
              scale_fill_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
              scale_y_continuous(limits = c(65, 100))+
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
  geom_point()+
  geom_line(data=RT_eff, aes(y=LogRT, x=ConP, color=Congruency, group=Congruency), size=2)+
  scale_color_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
  scale_fill_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
  scale_x_discrete(labels=c("1"="Congruent", "2"="Incongruent"))+
  scale_y_continuous(limits = c(5.5, 6.5))+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  ggtitle("Slow time scale (proactive)")+
  labs(x="")+
  labs(y="")+
  labs(color="Congruency N", fill="Congruency N")

RT_fig

#########################################################
# Sync data
#########################################################

Dataset_SyncTrial<-aggregate(Dat$MeanSyncTrial, list(Dat$Congruency,Dat$ConP, Dat$Simulation), FUN=mean)
names(Dataset_SyncTrial)<-c("Congruency", "ConP", "Simulation", "MeanSync")

Syncmodel<-lm(MeanSync~Congruency*ConP, data=Dataset_SyncTrial)
summary(Syncmodel)
Anova(Syncmodel)

Sync_plot=summarySE(Dat, measurevar="MeanSyncTrial", groupvars= c("Congruency", "ConP", "Simulation"))
Sync_eff=summarySE(Dat, measurevar="MeanSyncTrial", groupvars= c("Congruency", "ConP"))

Sync_fig<-ggplot(data = Sync_plot, aes(y=MeanSyncTrial, x=ConP, color=Congruency, fill=Congruency))+
  geom_violin(alpha=0.5, position = position_identity())+
  geom_point()+
  geom_line(data=Sync_eff, aes(x=ConP, y=MeanSyncTrial, color=Congruency, group=Congruency), size=2)+
  scale_color_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
  scale_fill_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  ggtitle("Neural synchrony")+
  scale_x_discrete(labels=c("1"="Congruent", "2"="Incongruent"))+
  labs(x="Congruency N-1")+
  labs(y="Mean Sync")+
  labs(color="Congruency N", fill= "Congruency N")

Sync_fig

#########################################################
# Power data
#########################################################

Dataset_Power<-aggregate(Dat$Baselined_power, list(Dat$Congruency,Dat$ConP, Dat$Simulation), FUN=mean)
names(Dataset_Power)<-c("Congruency", "ConP", "Simulation", "Power")
Powermodel<-lm(Power~Congruency*ConP, data=Dataset_Power)
summary(Powermodel)
Anova(Powermodel)

Power_plot=summarySE(Dat, measurevar="Baselined_power", groupvars= c("Congruency", "ConP", "Simulation"))
Power_eff=summarySE(Dat, measurevar="Baselined_power", groupvars= c("Congruency", "ConP"))

Power_fig<-ggplot(data = Power_plot, aes(y=Baselined_power, x=ConP, color=Congruency, fill=Congruency))+
  geom_violin(alpha=0.5, position = position_identity())+
  geom_point()+
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

Power_fig_Trial<-ggplot(data = Power_plot_Trial, aes(y=10*log10(MFC_power_Trial), x=ConP, color=Congruency, fill=Congruency))+
  geom_violin(alpha=0.5, position = position_identity())+
  geom_point()+
  geom_line(data=Power_eff_Trial, aes(x=ConP, y=10*log10(MFC_power_Trial), color=Congruency, group=Congruency), size=2)+
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

Power_fig_ITI<-ggplot(data = Power_plot_ITI, aes(y=10*log10(MFC_power_ITI), x=ConP, color=Congruency, fill=Congruency))+
  geom_violin(alpha=0.5, position = position_identity())+
  geom_point()+
  geom_line(data=Power_eff_ITI, aes(x=ConP, y=10*log10(MFC_power_ITI), color=Congruency, group=Congruency), size=2)+
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

#########################################################
# Loading and manipulating data
#########################################################
# Dataset with only reactive control
Dat<-read.table('Data_sim_rea.txt', header = F, sep = "")

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

#########################################################
# Behavioral data
#########################################################

Dat$LogRT<-log(Dat$RT)

Dataset_RT<-aggregate(Dat$LogRT, list(Dat$Congruency,Dat$ConP, Dat$Simulation), FUN=mean)
names(Dataset_RT)<-c("Congruency", "ConP", "Simulation", "LogRT")
RTmodel<-lm(LogRT~ Congruency*ConP, data=Dataset_RT)
summary(RTmodel)
Anova(RTmodel)

RT2<-aggregate(Dat$LogRT, list(Dat$ConP, Dat$Simulation), FUN=mean)
names(RT2)<-c("ConP", "Simulation", "LogRT")
t.test(LogRT~ConP, paired=TRUE, data=RT2)

Dataset_ACC<-aggregate(Dat$Accuracy, list(Dat$Congruency,Dat$ConP, Dat$Simulation), FUN=mean)
names(Dataset_ACC)<-c("Congruency", "ConP", "Simulation", "Accuracy")
ACCmodel<-lm(Accuracy~Congruency*ConP, data=Dataset_ACC)
summary(ACCmodel)
Anova(ACCmodel)

ACC_plot=summarySE(Dat, measurevar="Accuracypl", groupvars= c("Congruency", "ConP", "Simulation"))
ACC_eff=summarySE(Dat, measurevar="Accuracypl", groupvars= c("Congruency", "ConP"))
RT_plot=summarySE(Dat, measurevar="LogRT", groupvars= c("Congruency", "ConP", "Simulation"))
RT_eff=summarySE(Dat, measurevar="LogRT", groupvars= c("Congruency", "ConP"))

Accuracy_rea_fig<-ggplot(data = ACC_plot, aes(y=Accuracypl, x=ConP, color=Congruency, fill=Congruency))+
  geom_violin(alpha=0.5, position = position_identity())+
  geom_point()+
  geom_line(data=ACC_eff, aes(x=ConP, y=Accuracypl, color=Congruency, group=Congruency), size=2)+
  scale_color_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
  scale_fill_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
  scale_y_continuous(limits = c(65, 100))+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  #ggtitle("Accuracy Gratton effect")+
  scale_x_discrete(labels=c("1"="Congruent", "2"="Incongruent"))+
  labs(x="Congruency N-1")+
  labs(y="")+
  labs(color="Congruency N", fill="Congruency N")

Accuracy_rea_fig

RT_rea_fig<-ggplot(data = RT_plot, aes(y=LogRT, x=ConP, color=Congruency, fill=Congruency))+
  geom_violin(alpha=0.5, position = position_identity())+
  geom_point()+
  geom_line(data=RT_eff, aes(y=LogRT, x=ConP, color=Congruency, group=Congruency), size=2)+
  scale_color_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
  scale_fill_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
  scale_x_discrete(labels=c("1"="Congruent", "2"="Incongruent"))+
  scale_y_continuous(limits = c(5.5, 6.5))+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  ggtitle("Fast time scale (reactive)")+
  labs(x="")+
  labs(y="")+
  labs(color="Congruency N", fill="Congruency N")

RT_rea_fig

Behavioral_figure<-ggarrange(RT_fig, RT_rea_fig, Accuracy_fig, Accuracy_rea_fig, nrow = 2, ncol=2, labels = "AUTO",font.label = list(size = 10, color = "black", face = "bold", family = "Times"), common.legend = TRUE)
Behavioral_figure

#########################################################
# Sync data
#########################################################

Dataset_SyncTrial<-aggregate(Dat$MeanSyncTrial, list(Dat$Congruency,Dat$ConP, Dat$Simulation), FUN=mean)
names(Dataset_SyncTrial)<-c("Congruency", "ConP", "Simulation", "MeanSync")

Syncmodel<-lm(MeanSync~Congruency*ConP, data=Dataset_SyncTrial)
summary(Syncmodel)
Anova(Syncmodel)

Sync_plot=summarySE(Dat, measurevar="MeanSyncTrial", groupvars= c("Congruency", "ConP", "Simulation"))
Sync_eff=summarySE(Dat, measurevar="MeanSyncTrial", groupvars= c("Congruency", "ConP"))

Sync_rea_fig<-ggplot(data = Sync_plot, aes(y=MeanSyncTrial, x=ConP, color=Congruency, fill=Congruency))+
  geom_violin(alpha=0.5, position = position_identity())+
  geom_point()+
  geom_line(data=Sync_eff, aes(x=ConP, y=MeanSyncTrial, color=Congruency, group=Congruency), size=2)+
  scale_color_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
  scale_fill_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  ggtitle("Neural synchrony")+
  scale_x_discrete(labels=c("1"="Congruent", "2"="Incongruent"))+
  labs(x="Congruency N-1")+
  labs(y="Mean Sync")+
  labs(color="Congruency N", fill= "Congruency N")

Sync_rea_fig

#########################################################
# Power data
#########################################################

Dataset_Power<-aggregate(Dat$Baselined_power, list(Dat$Congruency,Dat$ConP, Dat$Simulation), FUN=mean)
names(Dataset_Power)<-c("Congruency", "ConP", "Simulation", "Power")
Powermodel<-lm(Power~Congruency*ConP, data=Dataset_Power)
summary(Powermodel)
Anova(Powermodel)

Power_plot=summarySE(Dat, measurevar="Baselined_power", groupvars= c("Congruency", "ConP", "Simulation"))
Power_eff=summarySE(Dat, measurevar="Baselined_power", groupvars= c("Congruency", "ConP"))

Power_rea_fig<-ggplot(data = Power_plot, aes(y=Baselined_power, x=ConP, color=Congruency, fill=Congruency))+
  geom_violin(alpha=0.5, position = position_identity())+
  geom_point()+
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

Power_rea_fig

Power_plot_Trial=summarySE(Dat, measurevar="MFC_power_Trial", groupvars= c("Congruency", "ConP", "Simulation"))
Power_eff_Trial=summarySE(Dat, measurevar="MFC_power_Trial", groupvars= c("Congruency", "ConP"))

Power_rea_fig_Trial<-ggplot(data = Power_plot_Trial, aes(y=10*log10(MFC_power_Trial), x=ConP, color=Congruency, fill=Congruency))+
  geom_violin(alpha=0.5, position = position_identity())+
  geom_point()+
  geom_line(data=Power_eff_Trial, aes(x=ConP, y=10*log10(MFC_power_Trial), color=Congruency, group=Congruency), size=2)+
  scale_color_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
  scale_fill_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  ggtitle("Reactive Control")+
  scale_x_discrete(labels=c("1"="Congruent", "2"="Incongruent"))+
  labs(x="Congruency N-1")+
  labs(y="unbaselined trial power (dB)")+
  labs(color="Congruency N", fill= "Congruency N")

Power_rea_fig_Trial

Power_plot_ITI=summarySE(Dat, measurevar="MFC_power_ITI", groupvars= c("Congruency", "ConP", "Simulation"))
Power_eff_ITI=summarySE(Dat, measurevar="MFC_power_ITI", groupvars= c("Congruency", "ConP"))

Power_rea_fig_ITI<-ggplot(data = Power_plot_ITI, aes(y=10*log10(MFC_power_ITI), x=ConP, color=Congruency, fill=Congruency))+
  geom_violin(alpha=0.5, position = position_identity())+
  geom_point()+
  geom_line(data=Power_eff_ITI, aes(x=ConP, y=10*log10(MFC_power_ITI), color=Congruency, group=Congruency), size=2)+
  scale_color_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
  scale_fill_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  ggtitle("Proactive control")+
  scale_x_discrete(labels=c("1"="Congruent", "2"="Incongruent"))+
  labs(x="Congruency N-1")+
  labs(y="unbaselined ITI power (dB)")+
  labs(color="Congruency N", fill= "Congruency N")

Power_rea_fig_ITI
Neural_figure_1<-ggarrange(Power_fig_Trial, Power_fig_ITI, Power_fig, Sync_fig, ncol= 4, nrow = 1, labels = "AUTO",font.label = list(size = 10, color = "black", face = "bold", family = "Times"), common.legend = TRUE)
Neural_figure_1<-annotate_figure(Neural_figure_1, left=text_grob("Slow time scale (proactive)", rot=90, face="bold", size=10, family="Times"))
Neural_figure_2<-ggarrange(Power_rea_fig_Trial, Power_rea_fig_ITI, Power_rea_fig, Sync_rea_fig, ncol = 4, nrow = 1, labels = c("E","F","G", "H"),font.label = list(size = 10, color = "black", face = "bold", family = "Times"), common.legend = TRUE)
Neural_figure_2<-annotate_figure(Neural_figure_2, left=text_grob("Fast time scale (reactive)", rot=90, face="bold", size=10, family="Times"))

Neural_figure<-ggarrange(Neural_figure_1, Neural_figure_2, nrow=2, common.legend = TRUE)

Behavioral_figure
ggsave(filename= "Behavioral_extra.tiff", Behavioral_figure, width=10, height=11, units="cm", dpi=300)
Neural_figure
ggsave(filename= "Neural_extra.tiff", Neural_figure, width=17.5, height=11, units="cm", dpi=300)

ggsave(filename= "Behavioral_extra.png", Behavioral_figure, width=10, height=11, units="cm", dpi=300)

ggsave(filename= "Neural_extra.png", Neural_figure, width=17.5, height=11, units="cm", dpi=300)

