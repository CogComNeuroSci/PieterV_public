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
library(patchwork)

# setting folder
folder = "/Volumes/backupdisc/Adaptive_Control/"
Removed <- 0
model_list <- c("Pro_When", "Pro_Where", "Pro_both", "Rea_When","Rea_Where", "Rea_both", "both_When", "both_Where", "both_both")

Accuracy_plots <- vector('list', length(model_list))
RT_plots<- vector('list', length(model_list))
Power_plots<- vector('list', length(model_list))
Power_plots_2<- vector('list', length(model_list))
Power_plots_3<- vector('list', length(model_list))
Sync_plots<- vector('list', length(model_list))

Power_RT_plots<- vector('list', length(model_list))
Power_accuracy_plots<- vector('list', length(model_list))
Power_RT_plots_2<- vector('list', length(model_list))
Power_accuracy_plots_2<- vector('list', length(model_list))
Power_RT_plots_3<- vector('list', length(model_list))
Power_accuracy_plots_3<- vector('list', length(model_list))
Sync_RT_plots<- vector('list', length(model_list))
Sync_accuracy_plots<- vector('list', length(model_list))

RT_stats<- vector('list', length(model_list))
Accuracy_stats<- vector('list', length(model_list))
Power_stats<- vector('list', length(model_list))
Power_stats_2<- vector('list', length(model_list))
Power_stats_3<- vector('list', length(model_list))
Sync_stats<- vector('list', length(model_list))

Power_RT_stats<- vector('list', length(model_list))
Power_accuracy_stats<- vector('list', length(model_list))
Power_RT_stats_2<- vector('list', length(model_list))
Power_accuracy_stats_2<- vector('list', length(model_list))
Power_RT_stats_3<- vector('list', length(model_list))
Power_accuracy_stats_3<- vector('list', length(model_list))
Sync_RT_stats<- vector('list', length(model_list))
Sync_accuracy_stats<- vector('list', length(model_list))
Sync_RT_stats_bis<- vector('list', length(model_list)*2)
Sync_accuracy_stats_bis<- vector('list', length(model_list)*2)

for (i in 1:length(model_list)){
  
  print(i)
  m=model_list[i]
  setwd(paste(folder, m, sep =""))

  Dat<-read.table('Data_sim.txt', header = F, sep = "")

  #This will be repeated for all three models
  Dat[Dat[,5]==0,5]<-2                 #recode incongruency from 0 to 2 (gives nicer plots)
  Dat[2:18000,14]<-Dat[1:17999,5]      #shift congruency to get congruency from previous trial
  Dat[,15]<-10*log10(Dat[,8]/Dat[,9])  #convert power to dB scale
  Dat[,8]<-10*log10(Dat[,8])
  Dat[,9]<-10*log10(Dat[,9])

  names(Dat)<-c("Simulation", "Trial", "Stimulus", "Response","Congruency", "Accuracy", "RT", "MFC_power_Trial", "MFC_power_ITI",'Sync_relevant_Trial', 'Sync_irrelevant_Trial', 'Sync_relevant_ITI', 'Sync_irrelevant_ITI',"ConP",'Baselined_power')

  Dat<-Dat[!(Dat$RT==2000),]       #Remove too late trials
  Removed<- Removed + sum(Dat$RT[(Dat$RT==2000)])
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

  RT_stats[[i]]<-lmer(LogRT~ (1|Simulation) + Congruency*ConP, data=Dat)

  Accuracy_stats[[i]]<-glmer(Accuracy~(1|Simulation)+Congruency*ConP, data=Dat)

  ACC_plot=summarySE(Dat, measurevar="Accuracypl", groupvars= c("Congruency", "ConP", "Simulation"))
  ACC_eff=summarySE(Dat, measurevar="Accuracypl", groupvars= c("Congruency", "ConP"))
  RT_plot=summarySE(Dat, measurevar="LogRT", groupvars= c("Congruency", "ConP", "Simulation"))
  RT_eff=summarySE(Dat, measurevar="LogRT", groupvars= c("Congruency", "ConP"))

  Accuracy_plots[[i]]<-ggplot(data = ACC_plot, aes(y=Accuracypl, x=ConP, color=Congruency, fill=Congruency))+
    geom_violin(alpha=0.5, position = position_identity())+
    geom_point(size=0.25)+
    geom_line(data=ACC_eff, aes(x=ConP, y=Accuracypl, color=Congruency, group=Congruency), size=2)+
    scale_color_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
    scale_fill_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
    scale_y_continuous(limits = c(50, 100))+
    theme_classic()+
    theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
    #ggtitle("Accuracy Gratton effect")+
    scale_x_discrete(labels=c("1"="Congruent", "2"="Incongruent"))+
    labs(x="")+
    labs(y="")+
    labs(color="Congruency N", fill="Congruency N")
  if (i>6){
    Accuracy_plots[[i]]<-Accuracy_plots[[i]]+labs(x="Congruency N-1")
  }
  if ((i-1)%%3==0){
    Accuracy_plots[[i]]<-Accuracy_plots[[i]]+labs(y="Accuracy %")
  }
  if (i==7){
    Accuracy_plots[[i]]<-Accuracy_plots[[i]]+labs(x="Congruency N-1")+
    labs(y="Accuracy %")
  }
 
  RT_plots[[i]]<-ggplot(data = RT_plot, aes(y=LogRT, x=ConP, color=Congruency, fill=Congruency))+
    geom_violin(alpha=0.5, position = position_identity())+
    geom_point(size=0.25)+
    geom_line(data=RT_eff, aes(y=LogRT, x=ConP, color=Congruency, group=Congruency), size=2)+
    scale_color_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
    scale_fill_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
    scale_x_discrete(labels=c("1"="Congruent", "2"="Incongruent"))+
    scale_y_continuous(limits = c(5.25, 6.5))+
    theme_classic()+
    theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
    labs(x="")+
    labs(y="")+
    labs(color="Congruency N", fill="Congruency N")
  if (i>6){
    RT_plots[[i]]<-RT_plots[[i]]+labs(x="Congruency N-1")
  }
  if ((i-1)%%3==0){
    RT_plots[[i]]<-RT_plots[[i]]+labs(y="LogRT")
  }
  if (i==7){
    RT_plots[[i]]<-RT_plots[[i]]+labs(x="Congruency N-1")+
      labs(y="LogRT")
  }
  
  #########################################################
  # Power data
  #########################################################
  
  Power_stats[[i]]<-lmer(Baselined_power~(1|Simulation)+Congruency*ConP, data=Dat)
  
  Power_plot=summarySE(Dat, measurevar="Baselined_power", groupvars= c("Congruency", "ConP", "Simulation"))
  Power_eff=summarySE(Dat, measurevar="Baselined_power", groupvars= c("Congruency", "ConP"))
  
  Power_plots[[i]]<-ggplot(data = Power_plot, aes(y=Baselined_power, x=ConP, color=Congruency, fill=Congruency))+
    geom_violin(alpha=0.5, position = position_identity())+
    geom_point(size=0.25)+
    geom_line(data=Power_eff, aes(x=ConP, y=Baselined_power, color=Congruency, group=Congruency), size=2)+
    scale_color_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
    scale_fill_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
    theme_classic()+
    theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
    #ggtitle("Baselined reactive control")+
    scale_x_discrete(labels=c("1"="Congruent", "2"="Incongruent"))+
    scale_y_continuous(limits = c(-0.25, 2))+
    labs(x="Congruency N-1")+
    labs(y="baselined trial power (dB)")+
    labs(color="Congruency N", fill= "Congruency N")
  
  Power_stats_2[[i]]<-lmer(MFC_power_Trial~(1|Simulation)+Congruency*ConP, data=Dat)
  
  Power_plot_Trial=summarySE(Dat, measurevar="MFC_power_Trial", groupvars= c("Congruency", "ConP", "Simulation"))
  Power_eff_Trial=summarySE(Dat, measurevar="MFC_power_Trial", groupvars= c("Congruency", "ConP"))
  
  Power_plots_2[[i]]<-ggplot(data = Power_plot_Trial, aes(y=MFC_power_Trial, x=ConP, color=Congruency, fill=Congruency))+
    geom_violin(alpha=0.5, position = position_identity())+
    geom_point(size=0.25)+
    geom_line(data=Power_eff_Trial, aes(x=ConP, y=MFC_power_Trial, color=Congruency, group=Congruency), size=2)+
    scale_color_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
    scale_fill_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
    theme_classic()+
    theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
    #ggtitle("Reactive Control")+
    scale_x_discrete(labels=c("1"="Congruent", "2"="Incongruent"))+
    labs(x="Congruency N-1")+
    labs(y="unbaselined trial power (dB)")+
    labs(color="Congruency N", fill= "Congruency N")
  
  Power_stats_3[[i]]<-lmer(MFC_power_ITI~(1|Simulation)+Congruency*ConP, data=Dat)
  
  Power_plot_ITI=summarySE(Dat, measurevar="MFC_power_ITI", groupvars= c("Congruency", "ConP", "Simulation"))
  Power_eff_ITI=summarySE(Dat, measurevar="MFC_power_ITI", groupvars= c("Congruency", "ConP"))
  
  Power_plots_3[[i]]<-ggplot(data = Power_plot_ITI, aes(y=MFC_power_ITI, x=ConP, color=Congruency, fill=Congruency))+
    geom_violin(alpha=0.5, position = position_identity())+
    geom_point(size=0.25)+
    geom_line(data=Power_eff_ITI, aes(x=ConP, y=MFC_power_ITI, color=Congruency, group=Congruency), size=2)+
    scale_color_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
    scale_fill_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
    theme_classic()+
    theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
    #ggtitle("Proactive control")+
    scale_x_discrete(labels=c("1"="Congruent", "2"="Incongruent"))+
    labs(x="Congruency N-1")+
    labs(y="unbaselined ITI power (dB)")+
    labs(color="Congruency N", fill= "Congruency N")
  
  #########################################################
  # Sync data
  #########################################################
  
  Sync_stats[[i]]<-lmer(MeanSyncTrial~ (1|Simulation)+Congruency*ConP, data=Dat)
  
  Sync_plot=summarySE(Dat, measurevar="MeanSyncTrial", groupvars= c("Congruency", "ConP", "Simulation"))
  Sync_eff=summarySE(Dat, measurevar="MeanSyncTrial", groupvars= c("Congruency", "ConP"))
  
  Sync_plots[[i]]<-ggplot(data = Sync_plot, aes(y=MeanSyncTrial, x=ConP, color=Congruency, fill=Congruency))+
    geom_violin(alpha=0.5, position = position_identity())+
    geom_point(size=0.25)+
    geom_line(data=Sync_eff, aes(x=ConP, y=MeanSyncTrial, color=Congruency, group=Congruency), size=2)+
    scale_color_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
    scale_fill_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
    theme_classic()+
    theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
    #ggtitle("Neural synchrony prediction")+
    scale_x_discrete(labels=c("1"="Congruent", "2"="Incongruent"))+
    labs(x="Congruency N-1")+
    labs(y="Mean Sync")+
    labs(color="Congruency N", fill= "Congruency N")
  
  #########################################################
  # Neural behavioral link
  #########################################################
  
  Power_RT_stats[[i]]<-lmer(LogRT~(1|Simulation)+Baselined_power+Baselined_power:Congruency, data=Dat)
  
  RT_Power_con=summarySE(Dat, measurevar="LogRT", groupvars= c("Baselined_power", "Congruency"))
  RT_Power_eff<-ggpredict(Power_RT_stats[[i]], c("Baselined_power[all]", "Congruency"))
  
  Power_RT_plots[[i]]<-ggplot(data = RT_Power_con, aes(y=LogRT, x=Baselined_power, color=Congruency))+
    geom_point(size=0.01, alpha =0.2)+
    geom_line(data=RT_Power_eff, aes(y=predicted, x=x, color= group), size=2)+
    scale_color_manual(values=c("lightblue", "red"), labels=c("1"="Congruent", "2"="Incongruent"))+
    scale_x_continuous(limits=c(-2,4))+
    theme_classic()+
    theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
    #ggtitle("Baselined reactive control")+
    labs(x="baselined trial power (dB)")+
    labs(y="")+
    labs(color="Congruency N")
  
  Power_accuracy_stats[[i]]<-glmer(Accuracy~(1|Simulation)+Baselined_power+Baselined_power:Congruency, data=Dat, family = binomial(link = "logit"))
  
  Powerbins = cut(Dat$Baselined_power, breaks=seq(-2,4, by=0.2))
  
  Accuracy_power_con=summarySE(Dat, measurevar="Accuracypl", groupvars= c("Powerbins", "Congruency"))
  levels(Accuracy_power_con$Powerbins)<-seq(-2,3.8, by=0.2)
  Accuracy_power_con$Powerbins<-as.numeric(paste(Accuracy_power_con$Powerbins))
  Accuracy_power_con[is.na(Accuracy_power_con$Powerbins),1]<-4
  
  ACCPower_eff<-ggpredict(Power_accuracy_stats[[i]], c("Baselined_power[all]", "Congruency"))
  ACCPower_eff$predicted[ACCPower_eff$group==1]<-1
  
  Power_accuracy_plots[[i]]<-ggplot(data = Accuracy_power_con, aes(y=Accuracypl, x=Powerbins, color=Congruency))+
    geom_point(size=2)+
    geom_errorbar(aes(ymin=Accuracypl-ci, ymax=Accuracypl+ci), width=0)+
    geom_line(data=ACCPower_eff, aes(y=predicted*100, x=x, color= group), size=2, alpha=0.5)+
    scale_color_manual(values=c("lightblue", "red"), labels=c("1"="Congruent", "2"="Incongruent"))+
    scale_x_continuous(limits=c(-2,4))+
    scale_y_continuous(limits=c(60,100))+
    theme_classic()+
    theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
    ggtitle("Baselined power")+
    labs(x="")+
    labs(y="")+
    labs(color="Congruency N")
  
  Power_RT_stats_2[[i]]<-lmer(LogRT~(1|Simulation)+MFC_power_Trial+MFC_power_Trial:Congruency, data=Dat)

  RT_PowerTrial_con=summarySE(Dat, measurevar="LogRT", groupvars= c("MFC_power_Trial", "Congruency"))
  RTPowerTrial_eff<-ggpredict(Power_RT_stats_2[[i]], c("MFC_power_Trial[all]", "Congruency"))
  
  Power_RT_plots_2[[i]]<-ggplot(data = RT_PowerTrial_con, aes(y=LogRT, x=MFC_power_Trial, color=Congruency))+
    geom_point(size=0.01, alpha = 0.2)+
    geom_line(data=RTPowerTrial_eff, aes(y=predicted, x=x, color= group), size=2)+
    scale_color_manual(values=c("lightblue", "red"), labels=c("1"="Congruent", "2"="Incongruent"))+
    scale_x_continuous(limits=c(-8,4))+
    theme_classic()+
    theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
    #ggtitle("Reactive control")+
    labs(x="unbaselined trial power (dB)")+
    labs(y="")+
    labs(color="Congruency N")
  
  print('acc2')
  Power_accuracy_stats_2[[i]]<-glmer(Accuracy~(1|Simulation)+MFC_power_Trial+MFC_power_Trial:Congruency, data=Dat, family = binomial(link = "logit"))
  
  PowerbinsTrial = cut(Dat$MFC_power_Trial, breaks=seq(-8,4, by=1))
  
  Accuracy_powerTrial_con=summarySE(Dat, measurevar="Accuracypl", groupvars= c("PowerbinsTrial", "Congruency"))
  levels(Accuracy_powerTrial_con$PowerbinsTrial)<-seq(-8,3, by=1)
  Accuracy_powerTrial_con$PowerbinsTrial<-as.numeric(paste(Accuracy_powerTrial_con$PowerbinsTrial))
  Accuracy_powerTrial_con[is.na(Accuracy_powerTrial_con$PowerbinsTrial),1]<-4
  
  ACCPowerTrial_eff<-ggpredict(Power_accuracy_stats_2[[i]], c("MFC_power_Trial[all]", "Congruency"))
  ACCPowerTrial_eff$predicted[ACCPowerTrial_eff$group==1]<-1
  
  Power_accuracy_plots_2[[i]]<-ggplot(data = Accuracy_powerTrial_con, aes(y=Accuracypl, x=PowerbinsTrial, color=Congruency))+
    geom_point(size=2)+
    geom_errorbar(aes(ymin=Accuracypl-ci, ymax=Accuracypl+ci), width=0)+
    geom_line(data=ACCPowerTrial_eff, aes(y=predicted*100, x=x, color= group), size=2, alpha=0.5)+
    scale_color_manual(values=c("lightblue", "red"), labels=c("1"="Congruent", "2"="Incongruent"))+
    scale_x_continuous(limits=c(-8,4))+
    scale_y_continuous(limits=c(60,100))+
    theme_classic()+
    theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
    ggtitle("Reactive power")+
    labs(x="")+
    labs(y="")+
    labs(color="Congruency N")
  
  Power_RT_stats_3[[i]]<-lmer(LogRT~(1|Simulation)+MFC_power_ITI+MFC_power_ITI:Congruency, data=Dat)
  
  RT_PowerITI_con=summarySE(Dat, measurevar="LogRT", groupvars= c("MFC_power_ITI", "Congruency"))
  RTPowerITI_eff = effect("MFC_power_ITI:Congruency", Power_RT_stats_3[[i]], xlevels=list(MFC_power_ITI=seq(-8,4, by=0.1)))
  
  x.fit <- unlist(RTPowerITI_eff$x.all)
  x <- data.frame(lower = RTPowerITI_eff$lower, upper = RTPowerITI_eff$upper, fit = RTPowerITI_eff$fit)
  x$MFC_power_ITI<-RTPowerITI_eff$x$MFC_power_ITI
  x$Congruency<-RTPowerITI_eff$x$Congruency
  x$Congruency<-as.factor(x$Congruency)
  
  Power_RT_plots_3[[i]]<-ggplot(data = RT_PowerITI_con, aes(y=LogRT, x=MFC_power_ITI, color=Congruency))+
    geom_point(size=0.01, alpha =0.2)+
    geom_line(data=x, aes(y=fit, x=MFC_power_ITI, color= Congruency), size=2)+
    geom_ribbon(data= x, aes(y=fit, x=MFC_power_ITI, ymin = lower, ymax = upper, fill=Congruency), alpha=0.5, colour = NA)+
    scale_color_manual(values=c("lightblue", "red"), labels=c("1"="Congruent", "2"="Incongruent"))+
    scale_fill_manual(values=c("lightblue", "red"), labels=c("1"="Congruent", "2"="Incongruent"))+
    scale_x_continuous(limits=c(-8,4))+
    theme_classic()+
    theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
    #ggtitle("Proactive control")+
    labs(x="unbaselined ITI power (dB)")+
    labs(y="")+
    labs(color="Congruency N")+
    labs(fill="Congruency N")
  
  print('acc3')
  if (i==2){
    Power_accuracy_stats_3[[i]]<-glmer(Accuracy~(1|Simulation)+MFC_power_ITI+MFC_power_ITI:Congruency, data=Dat)
  }else{
    Power_accuracy_stats_3[[i]]<-glmer(Accuracy~(1|Simulation)+MFC_power_ITI+MFC_power_ITI:Congruency, data=Dat, family = binomial(link = "logit"))
  }
  
  PowerbinsITI = cut(Dat$MFC_power_ITI, breaks=seq(-8,4, by=1))
  
  Accuracy_powerITI_con=summarySE(Dat, measurevar="Accuracypl", groupvars= c("PowerbinsITI", "Congruency"))
  levels(Accuracy_powerITI_con$PowerbinsITI)<-seq(-8,3, by=1)
  Accuracy_powerITI_con$PowerbinsITI<-as.numeric(paste(Accuracy_powerITI_con$PowerbinsITI))
  Accuracy_powerITI_con[is.na(Accuracy_powerITI_con$PowerbinsITI),1]<-4
  
  ACCPowerITI_eff<-ggpredict(Power_accuracy_stats_3[[i]], c("MFC_power_ITI[all]", "Congruency"))
  ACCPowerITI_eff$predicted[ACCPowerITI_eff$group==1]<-1
  
  Power_accuracy_plots_3[[i]]<-ggplot(data = Accuracy_powerITI_con, aes(y=Accuracypl, x=PowerbinsITI, color=Congruency))+
    geom_point(size=2)+
    geom_errorbar(aes(ymin=Accuracypl-ci, ymax=Accuracypl+ci), width=0)+
    geom_line(data=ACCPowerITI_eff, aes(y=predicted*100, x=x, color= group), size=2, alpha=0.5)+
    scale_color_manual(values=c("lightblue", "red"), labels=c("1"="Congruent", "2"="Incongruent"))+
    scale_x_continuous(limits=c(-8,4))+
    scale_y_continuous(limits=c(60,100))+
    theme_classic()+
    theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
    ggtitle("Proactive power")+
    labs(x="")+
    labs(y="")+
    labs(color="Congruency N")
  
  Sync_RT_stats[[i]]<-lmer(LogRT~(1|Simulation)+MeanSyncTrial+MeanSyncTrial:Congruency, data=Dat)
  
  Sync_RT_stats_bis[[i]]<-lmer(LogRT~(1|Simulation)+ MeanSyncTrial+ I(MeanSyncTrial^2), data=Dat[Dat$Congruency==1,] )
  Con_data<-coef(Sync_RT_stats_bis[[i]])$Simulation
  
  Sync_RT_stats_bis[[i+length(model_list)]]<-lmer(LogRT~(1|Simulation)+ MeanSyncTrial+ I(MeanSyncTrial^2), data=Dat[Dat$Congruency==2,] )
  InCon_data<-coef(Sync_RT_stats_bis[[i+length(model_list)]])$Simulation
  
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
  
  Sync_RT_plots[[i]]<-ggplot(data = RT_sync_con, aes(y=LogRT, x=MeanSyncTrial, color=Congruency))+
    geom_point(size=0.01, alpha=0.25)+
    geom_line(data=RT_sync_eff, aes(y=fit, x=Sync, color=Congruency), size=2)+
    scale_color_manual(values=c("lightblue", "red"), labels=c("1"="Congruent", "2"="Incongruent"))+
    scale_x_continuous(limits=c(0,1))+
    theme_classic()+
    theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
    #ggtitle("Synchrony")+
    labs(x="Mean Sync")+
    labs(y="LogRT")+
    labs(color="Congruency N")
  
  Sync_accuracy_stats[[i]]<-glmer(Accuracy~(1|Simulation)+MeanSyncTrial+MeanSyncTrial:Congruency, data=Dat, family = binomial(link = "logit"))
  
  I<-rep(c(100), times=30)
  Con_data<-as.data.frame(I)
  Con_data$MeanSyncTrial<-rep(c(0), times=30)
  Con_data$MeanSyncTrial2<-rep(c(0), times=30)
  names(Con_data)<-c("(Intercept)", "MeanSyncTrial", "I(MeanSyncTrial^2)")
  
  Aggregated_data=summarySE(Dat, measurevar="Accuracypl", groupvars= c("MeanSyncTrial", "Congruency","Simulation"))
  Sync_accuracy_stats_bis[[i+length(model_list)]]<-lmer(Accuracypl~(1|Simulation)+ MeanSyncTrial+ I(MeanSyncTrial^2), data=Aggregated_data[Aggregated_data$Congruency==2,])
  InCon_data<-coef(Sync_accuracy_stats_bis[[i+length(model_list)]])$Simulation
  
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
  
  Sync_accuracy_plots[[i]]<-ggplot(data = Accuracy_sync_con, aes(y=Accuracypl, x=Syncbins, color=Congruency))+
    geom_point(size=2)+
    geom_errorbar(aes(ymin=Accuracypl-ci, ymax=Accuracypl+ci), width=0)+
    geom_line(data=Accuracy_sync_eff, aes(y=fit, x=Sync, color= Congruency), size=2, alpha=0.5)+
    scale_color_manual(values=c("lightblue", "red"), labels=c("1"="Congruent", "2"="Incongruent"))+
    scale_x_continuous(limits=c(0,1))+
    scale_y_continuous(limits=c(60,100))+
    theme_classic()+
    theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
    ggtitle("Neural synchrony")+
    labs(x="")+
    labs(y="Accuracy%")+
    labs(color="Congruency N")

}

Con_Em<-as.factor(rep(c(1,2), each=2))
ConP_Em<-as.factor(rep(c(1,2), times=2))
Mean<-10*log10(c(56,62, 156, 115)/100)
  
Empirical_power_data<-data.frame(Con_Em, ConP_Em, Mean)
Power_fig_Empirical<-ggplot(data = Empirical_power_data, aes(y=Mean, x=ConP_Em, color=Con_Em, fill =Con_Em, group=Con_Em))+
  geom_line(size=2)+
  scale_color_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
  scale_fill_manual(values=c("lightblue", "red"),labels=c("1"="Congruent", "2"="Incongruent"))+
  theme_classic()+
  theme(legend.position = "none", text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  #ggtitle("Empirical data")+
  scale_x_discrete(labels=c("1"="Congruent", "2"="Incongruent"))+
  labs(x="Congruency N-1")+
  labs(y="baselined trial power (dB)")+
  labs(color="Congruency N", fill= "Congruency N")

setwd("/Volumes/backupdisc/Adaptive_Control/Figures/")
Proactive <- ggplot() + annotate(geom = 'text', x=1, y=1, label="bold(Proactive)", angle = 90, parse = TRUE) + theme_void() 
Reactive <- ggplot() + annotate(geom = 'text', x=1, y=1, label="bold(Reactive)", angle = 90, parse = TRUE) + theme_void() 
Both <- ggplot() + annotate(geom = 'text', x=1, y=1, label="bold(Both)",angle = 90, parse = TRUE) + theme_void() 
Spatial <- ggplot() + annotate(geom = 'text', x=1, y=1, label="bold(Selectivity)", parse = TRUE) + theme_void() 
Temporal<- ggplot() + annotate(geom = 'text', x=1, y=1, label="bold(Intensity)", parse = TRUE) + theme_void() 
Spatiotemporal<-ggplot() + annotate(geom = 'text', x=1, y=1, label="bold(Both)", parse = TRUE) + theme_void() 

base_layout <- "
#aaabbbccc
dggghhhiii
dggghhhiii
ejjjkkklll
ejjjkkklll
fmmmnnnooo
fmmmnnnooo
"

selected_layout <- "
#aaaabbbb
ceeeeffff
ceeeeffff
ceeeeffff
dgggghhhh
dgggghhhh
dgggghhhh
dgggghhhh
"

selected_layout2 <- "
#aaabbbccc
dfffggghhh
dfffggghhh
eiiijjjkkk
eiiijjjkkk
"

selected_layout3 <- "
#aaabbb####
dfffggg#ccc
dfffggg#hhh
eiiijjj#hhh
eiiijjj####
"

#RTplotlist <- list(a = Temporal, b = Spatial, c = Spatiotemporal, d = Proactive, e= Reactive, f = Both, g=RT_plots[[1]], h=RT_plots[[2]], i=RT_plots[[3]], j=RT_plots[[4]], k=RT_plots[[5]],l=RT_plots[[6]],m=RT_plots[[7]],n=RT_plots[[8]],o=RT_plots[[9]])
#RT_all<-wrap_plots(RTplotlist, guides = 'collect', design = base_layout)

RTplotlist <- list(a = Temporal, b = Spatial, c = Spatiotemporal, d = Proactive, e= Both, f=RT_plots[[1]], g=RT_plots[[2]], h=RT_plots[[3]],i=RT_plots[[7]],j=RT_plots[[8]],k=RT_plots[[9]])
RT_all<-wrap_plots(RTplotlist, guides = 'collect', design = selected_layout2)

Accuracy_plotlist <- list(a = Temporal, b = Spatial, c = Spatiotemporal, d = Proactive, e= Reactive, f = Both, g=Accuracy_plots[[1]], h=Accuracy_plots[[2]], i=Accuracy_plots[[3]], j=Accuracy_plots[[4]], k=Accuracy_plots[[5]],l=Accuracy_plots[[6]],m=Accuracy_plots[[7]],n=Accuracy_plots[[8]],o=Accuracy_plots[[9]])
Accuracy_all<-wrap_plots(Accuracy_plotlist, guides = 'collect', design = base_layout)

Power_plotlist <- list(a = Spatial, b = Spatiotemporal, c = Proactive, d = Both, e=Power_plots[[2]], f=Power_plots[[3]], g=Power_plots[[8]], h=Power_plots[[9]])
Power_all<-wrap_plots(Power_plotlist, guides = 'collect', design = selected_layout)

Power_plotlist2 <- list(a = Temporal, b = Spatial, c = Spatiotemporal, d = Proactive, e=Both, f=Power_plots[[1]], g=Power_plots[[2]], h=Power_plots[[3]], i=Power_plots[[7]], j=Power_plots[[8]],k=Power_plots[[9]])
Power_all2<-wrap_plots(Power_plotlist2, guides = 'collect', design = selected_layout2)

RT_all
ggsave(filename= "RT.tiff", RT_all, width=17, height=10, units="cm", dpi=300)

Accuracy_all
ggsave(filename= "Accuracy.tiff", Accuracy_all, width=17, height=15, units="cm", dpi=300)

Power_all
ggsave(filename= "Power_comparison.tiff", Power_all, width=12, height=10, units="cm", dpi=300)

Power_all2
ggsave(filename= "Power_wider_comparison.tiff", Power_all2, width=17, height=10, units="cm", dpi=300)

Proactived <- ggplot() + annotate(geom = 'text', x=1, y=1, label="paste(bold(Proactive),\" \", bold(power))", parse = TRUE) + theme_void() 
Sum <- ggplot() + annotate(geom = 'text', x=1, y=1, label="paste(bold(Reactive), \" \", bold(power))", parse = TRUE) + theme_void() 
Baseline <- ggplot() + annotate(geom = 'text', x=1, y=1, label="paste(bold(Baselined),\" \",  bold(power))", parse = TRUE) + theme_void() 
Synchrony <- ggplot() + annotate(geom = 'text', x=1, y=1, label="bold(Synchrony)", parse = TRUE) + theme_void() 
Empirical <- ggplot() + annotate(geom = 'text', x=1, y=1, label="paste(bold(Empirical),\" \",  bold(data))", parse = TRUE) + theme_void() 

P_layout <- "
aaaabbbbccc
eeeeffffggg
eeeeffffggg
eeeeffffggg
"

Mechanism_list<-list(a = Proactived, b = Sum, c = Synchrony, e=Power_plots_3[[9]], f=Power_plots_2[[9]], g=Sync_plots[[9]])
Mechanisms<-wrap_plots(Mechanism_list, guides = 'collect', design = P_layout)

Power_plotlist3 <- list(a = Spatial, b = Spatiotemporal, c = Empirical, d = Proactive, e=Both, f=Power_plots[[2]], g=Power_plots[[3]], h=Power_fig_Empirical, i=Power_plots[[8]], j=Power_plots[[9]])
Power_all3<-wrap_plots(Power_plotlist3, guides = 'collect', design = selected_layout3)

Mechanisms
ggsave(filename= "Mechanisms.tiff", Mechanisms, width=17, height=5, units="cm", dpi=300)

Power_all3
ggsave(filename= "Power_figure.tiff", Power_all3, width=17, height=10, units="cm", dpi=300)

Sync_plots[[9]]
#ggsave(filename= "Sync_data.tiff", Sync_plots[[9]], width=7.5, height=6, units="cm", dpi=300)


Neural_behavioral_figure<-ggarrange(Power_accuracy_plots[[9]], Power_accuracy_plots_3[[9]], Power_accuracy_plots_2[[9]], Sync_accuracy_plots[[9]], Power_RT_plots[[9]], Power_RT_plots_3[[9]], Power_RT_plots_2[[9]], Sync_RT_plots[[9]], nrow = 2, ncol=4, labels = NULL, common.legend = TRUE)
Neural_behavioral_figure
ggsave(filename= "Neural_link.tiff", Neural_behavioral_figure, width=17, height=12, units="cm", dpi=300)

Remove_percentage = (Removed/(30*600*9))*100
print(Remove_percentage)

RT_x<-matrix(NA,nrow=9, ncol=3)
RT_p<-matrix(NA,nrow=9, ncol=3)

ACC_x<-matrix(NA,nrow=9, ncol=3)
ACC_p<-matrix(NA,nrow=9, ncol=3)

Power_x<-matrix(NA,nrow=9, ncol=3)
Power_p<-matrix(NA,nrow=9, ncol=3)

for (i in c(1:9)){
  RT_x[i,]<-Anova(RT_stats[[i]])$Chisq
  RT_p[i,]<-Anova(RT_stats[[i]])$'Pr(>Chisq)'
  
  ACC_x[i,]<-Anova(Accuracy_stats[[i]])$Chisq
  ACC_p[i,]<-Anova(Accuracy_stats[[i]])$'Pr(>Chisq)'
  
  Power_x[i,]<-Anova(Power_stats[[i]])$Chisq
  Power_p[i,]<-Anova(Power_stats[[i]])$'Pr(>Chisq)'
}
                    
max(ACC_p[,1])
max(ACC_p[c(1:3,7:9),2])
max(ACC_p[c(1:3,7:9),3])

min(ACC_x[,1])
min(ACC_x[c(1:3,7:9),2])
min(ACC_x[c(1:3,7:9),3])

max(RT_p[,1])
max(RT_p[c(1:2,5,7:9),2])
max(RT_p[c(1:3,7:9),3])

min(RT_x[,1])
min(RT_x[c(1:2,5,7:9),2])
min(RT_x[c(1:3,7:9),3])

Anova(Power_stats[[9]])
Anova(Power_stats[[3]])
Anova(Power_stats[[8]])

Anova(Sync_stats[[9]])

Anova(Sync_RT_stats[[9]])
Anova(Sync_accuracy_stats[[9]])

Anova(Sync_RT_stats_bis[[9]])
Anova(Sync_RT_stats_bis[[18]])

Anova(Sync_accuracy_stats_bis[[9]])
Anova(Sync_accuracy_stats_bis[[18]])

Anova(Power_RT_stats[[9]])
Anova(Power_accuracy_stats[[9]])

Anova(Power_RT_stats_3[[9]])
Anova(Power_accuracy_stats_3[[9]])

Anova(Power_RT_stats_2[[9]])
Anova(Power_accuracy_stats_2[[9]])

library(wesanderson)
pal <- wes_palette("Zissou1", 100, type = "continuous")

C <- data.frame(c(scale(Power_x[,3]), scale(RT_x[,3]), scale(ACC_x[,3])))
names(C)<-"Statistic"
C$Model<-rep(1:9,3)#rep(c("ProIntense", "ProSelect", "ProBoth", "ReaIntense", "ReaSelect","ReaBoth","BothIntense", "BothSelect", "BothBoth"),3)
C$Data<-rep(1:3,each=9)#rep(c("Accuracy", "RT", "Power"), each=9)

Con_effect<-ggplot(data = C, aes(x = Model, y=Data, fill = Statistic))+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(-.75,.75), oob=squish)+
  theme_classic()+
  theme(legend.position="top", legend.title = element_text(size = 8, family="Times"), legend.key.height=unit(.2,"cm"), text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  scale_x_continuous(breaks=c(1:9), labels=c("Proactive\nIntensity", "Proactive\nSelectivity", "Proactive\nBoth", "Reactive\nIntensity", "Reactive\nSelectivity", "Reactive\nBoth","Both\nIntensity", "Both\nSelectivity", "Both\nBoth"))+
  scale_y_continuous(breaks=c(1:3), labels=c("Power", "RT", "Accuracy"))+
  labs(fill=expression("Z-scored\nStatistic"))

ggsave(filename= "Vandenberg.tiff", Con_effect, width=12, height=4, units="cm", dpi=300)


