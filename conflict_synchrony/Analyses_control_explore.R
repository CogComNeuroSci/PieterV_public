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

# setting folder
setwd("/Users/pieter/Documents/MATLAB/ta")

#########################################################
# Loading and manipulating data
#########################################################
Trials=600
Gamma=seq(0.125,0.875,by=0.125)
Theta=seq(0,1,by=0.125)
Beta=seq(2.5,20,by=2.5)
Eta=seq(0,1,by=0.125)

Dat<-read.table('Data_control_pars_tres.txt', header = F, sep = "")
Sims=length(Dat[,1])/600

Dat[2:length(Dat[,1]),9]<-Dat[1:length(Dat[,1])-1,8]
names(Dat)<-c("Simulation", "Gamma", "Theta", "Beta", "Eta", "Accuracy", "RT", "Congruency", "ConP")

Dat$Simulation<-rep(seq(1,Sims),each=Trials)

Aggregated_data<-Dat[seq(1, length(Dat[,1]), by=Trials),1:5]

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
  Aggregated_data[i,8]<-RT_result[1,3]
  Aggregated_data[i,9]<-RT_result[3,3]
  
  ACCmodel<-glm(Accuracy/100~ Congruency*ConP, data=Data, family = binomial)
  
  ACC_result<-Anova(ACCmodel)
  Aggregated_data[i,10]<-ACC_result[1,1]
  Aggregated_data[i,11]<-ACC_result[3,1]
}

names(Aggregated_data)<-c("Simulation", "Gamma","Theta", "Beta", "Eta","Accuracy", "RT", "RT_Con", "RT_Grat", "ACC_Con", "ACC_Grat")
Aggregated_data$ES<-(scale(Aggregated_data$Accuracy)-scale(Aggregated_data$RT))/2
Aggregated_data$ES_Con<-(scale(Aggregated_data$ACC_Con)+scale(Aggregated_data$RT_Con))/2
Aggregated_data$ES_Grat<-(scale(Aggregated_data$ACC_Con)+scale(Aggregated_data$RT_Grat))/2

Gamma_Theta_data<-aggregate(.~Gamma:Theta, data=Aggregated_data, FUN=mean)
pal <- wes_palette("Zissou1", 100, type = "continuous")

Acc_GT<-ggplot(data = Gamma_Theta_data, aes(x=Gamma, y=Theta, fill=V10))+
  geom_raster(interpolate = TRUE)+
  scale_fill_gradientn(colours=pal, space="Lab", limits=c(-0.5,0.5), oob=squish)+
  geom_vline(xintercept=0.25, linetype="longdash")+
  geom_hline(yintercept=0.75, linetype="longdash")+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  labs(x=expression(gamma))+
  labs(y=expression(theta))+
  labs(fill="Efficiency")

AccCon_GT<-ggplot(data = Gamma_Theta_data, aes(x=Gamma, y=Theta, fill=V11))+
  geom_raster(interpolate = TRUE)+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(-1,1), oob=squish)+
  geom_vline(xintercept=0.25, linetype="longdash")+
  geom_hline(yintercept=0.75, linetype="longdash")+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  labs(x=expression(gamma))+
  labs(y=expression(theta))+
  labs(fill=expression("Statistic"))

AccGrat_GT<-ggplot(data = Gamma_Theta_data, aes(x=Gamma, y=Theta, fill=V12))+
  geom_raster(interpolate = TRUE)+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(-1,1), oob=squish)+
  geom_vline(xintercept=0.25, linetype="longdash")+
  geom_hline(yintercept=0.75, linetype="longdash")+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  labs(x=expression(gamma))+
  labs(y=expression(theta))+
  labs(fill=expression("Statistic"))

Gamma_Beta_data<-aggregate(.~Gamma:Beta, data=Aggregated_data, FUN=mean)

Acc_GB<-ggplot(data = Gamma_Beta_data, aes(x=Gamma, y=Beta, fill=V10))+
  geom_raster(interpolate = TRUE)+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(-0.5,0.5), oob=squish)+
  geom_vline(xintercept=0.25, linetype="longdash")+
  geom_hline(yintercept=10, linetype="longdash")+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  labs(x=expression(gamma))+
  labs(y=expression(beta))+
  labs(fill="Efficiency")

AccCon_GB<-ggplot(data = Gamma_Beta_data, aes(x=Gamma, y=Beta, fill=V11))+
  geom_raster(interpolate = TRUE)+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(-1,1), oob=squish)+
  geom_vline(xintercept=0.25, linetype="longdash")+
  geom_hline(yintercept=10, linetype="longdash")+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  labs(x=expression(gamma))+
  labs(y=expression(beta))+
  labs(fill=expression("Statistic"))

AccGrat_GB<-ggplot(data = Gamma_Beta_data, aes(x=Gamma, y=Beta, fill=V12), oob=squish)+
  geom_raster(interpolate = TRUE)+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(-1,1))+
  geom_vline(xintercept=0.25, linetype="longdash")+
  geom_hline(yintercept=10, linetype="longdash")+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  labs(x=expression(gamma))+
  labs(y=expression(beta))+
  labs(fill=expression("Statistic"))

Gamma_Eta_data<-aggregate(.~Gamma:Eta, data=Aggregated_data, FUN=mean)

Acc_GE<-ggplot(data = Gamma_Eta_data, aes(x=Gamma, y=Eta, fill=V10))+
  geom_raster(interpolate = TRUE)+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(-0.5,0.5), oob=squish)+
  geom_vline(xintercept=0.25, linetype="longdash")+
  geom_hline(yintercept=0.25, linetype="longdash")+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  labs(x=expression(gamma))+
  labs(y=expression(eta))+
  labs(fill="Efficiency")

AccCon_GE<-ggplot(data = Gamma_Eta_data, aes(x=Gamma, y=Eta, fill=V11))+
  geom_raster(interpolate = TRUE)+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(-1,1), oob=squish)+
  geom_vline(xintercept=0.25, linetype="longdash")+
  geom_hline(yintercept=0.25, linetype="longdash")+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  labs(x=expression(gamma))+
  labs(y=expression(eta))+
  labs(fill=expression("Statistic"))

AccGrat_GE<-ggplot(data = Gamma_Eta_data, aes(x=Gamma, y=Eta, fill=V12))+
  geom_raster(interpolate = TRUE)+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(-1,1), oob=squish)+
  geom_vline(xintercept=0.25, linetype="longdash")+
  geom_hline(yintercept=0.25, linetype="longdash")+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  labs(x=expression(gamma))+
  labs(y=expression(eta))+
  labs(fill=expression("Statistic"))

Theta_Beta_data<-aggregate(.~Theta:Beta, data=Aggregated_data, FUN=mean)

Acc_TB<-ggplot(data = Theta_Beta_data, aes(x=Theta, y=Beta, fill=V10))+
  geom_raster(interpolate = TRUE)+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(-0.5,0.5), oob=squish)+
  geom_vline(xintercept=0.75, linetype="longdash")+
  geom_hline(yintercept=10, linetype="longdash")+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  labs(x=expression(theta))+
  labs(y=expression(beta))+
  labs(fill="Efficiency")

AccCon_TB<-ggplot(data = Theta_Beta_data, aes(x=Theta, y=Beta, fill=V11))+
  geom_raster(interpolate = TRUE)+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(-1,1), oob=squish)+
  geom_vline(xintercept=0.75, linetype="longdash")+
  geom_hline(yintercept=10, linetype="longdash")+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  labs(x=expression(theta))+
  labs(y=expression(beta))+
  labs(fill=expression("Statistic"))

AccGrat_TB<-ggplot(data = Theta_Beta_data, aes(x=Theta, y=Beta, fill=V12))+
  geom_raster(interpolate = TRUE)+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(-1,1), oob=squish)+
  geom_vline(xintercept=0.75, linetype="longdash")+
  geom_hline(yintercept=10, linetype="longdash")+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  labs(x=expression(theta))+
  labs(y=expression(beta))+
  labs(fill=expression("Statistic"))

Theta_Eta_data<-aggregate(.~Theta:Eta, data=Aggregated_data, FUN=mean)

Acc_TE<-ggplot(data = Theta_Eta_data, aes(x=Theta, y=Eta, fill=V10))+
  geom_raster(interpolate = TRUE)+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(-0.5,0.5), oob=squish)+
  geom_vline(xintercept=0.75, linetype="longdash")+
  geom_hline(yintercept=0.1, linetype="longdash")+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  labs(x=expression(theta))+
  labs(y=expression(eta))+
  labs(fill="Efficiency")

AccCon_TE<-ggplot(data = Theta_Eta_data, aes(x=Theta, y=Eta, fill=V11))+
  geom_raster(interpolate = TRUE)+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(-1,1), oob=squish)+
  geom_vline(xintercept=0.75, linetype="longdash")+
  geom_hline(yintercept=0.1, linetype="longdash")+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  labs(x=expression(theta))+
  labs(y=expression(eta))+
  labs(fill=expression("Statistic"))

AccGrat_TE<-ggplot(data = Theta_Eta_data, aes(x=Theta, y=Eta, fill=V12))+
  geom_raster(interpolate = TRUE)+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(-1,1), oob=squish)+
  geom_vline(xintercept=0.75, linetype="longdash")+
  geom_hline(yintercept=0.1, linetype="longdash")+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  labs(x=expression(theta))+
  labs(y=expression(eta))+
  labs(fill=expression("Statistic"))

Beta_Eta_data<-aggregate(.~Beta:Eta, data=Aggregated_data, FUN=mean)

Acc_BE<-ggplot(data = Beta_Eta_data, aes(x=Beta, y=Eta, fill=V10))+
  geom_raster(interpolate = TRUE)+
  scale_fill_gradientn(colours=pal, space="Lab", limits=c(-0.5,0.5), oob=squish)+
  geom_vline(xintercept=10, linetype="longdash")+
  geom_hline(yintercept=0.25, linetype="longdash")+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  labs(x=expression(beta))+
  labs(y=expression(eta))+
  labs(fill="Efficiency")

AccCon_BE<-ggplot(data = Beta_Eta_data, aes(x=Beta, y=Eta, fill=V11))+
  geom_raster(interpolate = TRUE)+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(-1,1), oob=squish)+
  geom_vline(xintercept=10, linetype="longdash")+
  geom_hline(yintercept=0.25, linetype="longdash")+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  labs(x=expression(beta))+
  labs(y=expression(eta))+
  labs(fill=expression("Statistic"))

AccGrat_BE<-ggplot(data = Beta_Eta_data, aes(x=Beta, y=Eta, fill=V12))+
  geom_raster(interpolate = TRUE)+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(-1,1), oob=squish)+
  geom_vline(xintercept=10, linetype="longdash")+
  geom_hline(yintercept=0.25, linetype="longdash")+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  labs(x=expression(beta))+
  labs(y=expression(eta))+
  labs(fill=expression("Statistic"))

ACC_all<-ggarrange(Acc_GT, Acc_GB, Acc_GE, Acc_TB, Acc_TE, Acc_BE, nrow=6, common.legend = TRUE)
ACC_all<-annotate_figure(ACC_all, top = text_grob("Efficiency", face = "bold", size = 10, family="Times"))

ACC_con<-ggarrange(AccCon_GT, AccCon_GB, AccCon_GE, AccCon_TB, AccCon_TE, AccCon_BE, nrow=6, common.legend = TRUE)
ACC_con<-annotate_figure(ACC_con, top = text_grob("Congruency-effect", face = "bold", size = 10, family="Times"))

ACC_grat<-ggarrange(AccGrat_GT, AccGrat_GB, AccGrat_GE, AccGrat_TB, AccGrat_TE, AccGrat_BE, nrow=6, common.legend = TRUE)
ACC_grat<-annotate_figure(ACC_grat, top = text_grob("Conflict-adaptation-effect", face = "bold", size = 10, family="Times"))

ACC_figure_Control<-ggarrange(ACC_all, ACC_con, ACC_grat, ncol=3)
ACC_figure_Control

ggsave(filename= "ES_Control.tiff", ACC_figure_Control, width=15, height=25, units="cm", dpi=300)
ggsave(filename= "ES_Control.png", ACC_figure_Control, width=15, height=25, units="cm", dpi=300)








