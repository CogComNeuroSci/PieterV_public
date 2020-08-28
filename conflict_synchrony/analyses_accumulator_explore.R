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
Inhibition=seq(0,0.1,by=0.005)
Treshold=seq(2,40,by=2)
Noise=seq(0,0.5,0.05)

Dat<-read.table('Data_accumulator_pars_tres.txt', header = F, sep = "")
Sims=length(Dat[,1])/600

Dat[2:length(Dat[,1]),8]<-Dat[1:length(Dat[,1])-1,7]
names(Dat)<-c("Simulation", "Inhibition", "Treshold", "Noise", "Accuracy", "RT", "Congruency", "ConP")

Aggregated_data<-Dat[seq(1, length(Dat[,1]), by=Trials),1:4]
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
  Aggregated_data[i,7]<-RT_result[1,3]
  Aggregated_data[i,8]<-RT_result[3,3]
  
  ACCmodel<-glm(Accuracy/100~ Congruency*ConP, data=Data, family = binomial)
  
  ACC_result<-Anova(ACCmodel)
  Aggregated_data[i,9]<-ACC_result[1,1]
  Aggregated_data[i,10]<-ACC_result[3,1]
}

names(Aggregated_data)<-c("Simulation", "Inhibition","Treshold", "Noise", "Accuracy", "RT", "RT_Con", "RT_Grat", "ACC_Con", "ACC_Grat")
Aggregated_data$ES<-(scale(Aggregated_data$Accuracy)-scale(Aggregated_data$RT))/2
Aggregated_data$ES_Con<-(scale(Aggregated_data$ACC_Con)+scale(Aggregated_data$RT_Con))/2
Aggregated_data$ES_Grat<-(scale(Aggregated_data$ACC_Con)+scale(Aggregated_data$RT_Grat))/2

Inhibition_noise_data<-aggregate(.~Inhibition:Noise, data=Aggregated_data, FUN=mean)
pal <- wes_palette("Zissou1", 100, type = "continuous")

Acc_IN<-ggplot(data = Inhibition_noise_data, aes(x=Inhibition, y=Noise, fill=V9))+
  #geom_contour_fill()+
  geom_raster(interpolate = TRUE)+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(-0.5,0.5), oob=squish)+
  geom_vline(xintercept=0.015, linetype="longdash")+
  geom_hline(yintercept=0.1, linetype="longdash")+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  #ggtitle("Accuracy")+
  labs(x="Inhibition")+
  labs(y="Noise")+
  labs(fill="Efficiency")

AccCon_IN<-ggplot(data = Inhibition_noise_data, aes(x=Inhibition, y=Noise, fill=V10))+
  #geom_contour_fill()+
  geom_raster(interpolate = TRUE)+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(-1,1), oob=squish)+
  geom_vline(xintercept=0.015, linetype="longdash")+
  geom_hline(yintercept=0.1, linetype="longdash")+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  #ggtitle("Accuracy")+
  labs(x="Inhibition")+
  labs(y="Noise")+
  labs(fill=expression("Statistic"))

AccGrat_IN<-ggplot(data = Inhibition_noise_data, aes(x=Inhibition, y=Noise, fill=V11))+
  #geom_contour_fill()+
  geom_raster(interpolate = TRUE)+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(-1,1), oob=squish)+
  geom_vline(xintercept=0.015, linetype="longdash")+
  geom_hline(yintercept=0.1, linetype="longdash")+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  #ggtitle("Accuracy")+
  labs(x="Inhibition")+
  labs(y="Noise")+
  labs(fill=expression("Statistic"))

Inhibition_treshold_data<-aggregate(.~Inhibition:Treshold, data=Aggregated_data, FUN=mean)

Acc_IT<-ggplot(data = Inhibition_treshold_data, aes(x=Inhibition, y=Treshold, fill=V9))+
  #geom_contour_fill()+
  geom_raster(interpolate = TRUE)+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(-0.5,0.5), oob=squish)+
  geom_vline(xintercept=0.015, linetype="longdash")+
  geom_hline(yintercept=20, linetype="longdash")+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  #ggtitle("Accuracy")+
  labs(x="Inhibition")+
  labs(y="Threshold")+
  labs(fill="Efficiency")

AccCon_IT<-ggplot(data = Inhibition_treshold_data, aes(x=Inhibition, y=Treshold, fill=V10))+
  #geom_contour_fill()+
  geom_raster(interpolate = TRUE)+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(-1,1), oob=squish)+
  geom_vline(xintercept=0.015, linetype="longdash")+
  geom_hline(yintercept=20, linetype="longdash")+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  #ggtitle("Accuracy")+
  labs(x="Inhibition")+
  labs(y="Threshold")+
  labs(fill=expression("Statistic"))

AccGrat_IT<-ggplot(data = Inhibition_treshold_data, aes(x=Inhibition, y=Treshold, fill=V11))+
  #geom_contour_fill()+
  geom_raster(interpolate = TRUE)+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(-1,1), oob=squish)+
  geom_vline(xintercept=0.015, linetype="longdash")+
  geom_hline(yintercept=20, linetype="longdash")+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  #ggtitle("Accuracy")+
  labs(x="Inhibition")+
  labs(y="Threshold")+
  labs(fill=expression("Statistic"))

Treshold_noise_data<-aggregate(.~Treshold:Noise, data=Aggregated_data, FUN=mean)

Acc_TN<-ggplot(data = Treshold_noise_data, aes(x=Treshold, y=Noise, fill=V9))+
  #geom_contour_fill()+
  geom_raster(interpolate = TRUE)+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(-0.5,0.5), oob=squish)+
  geom_vline(xintercept=20, linetype="longdash")+
  geom_hline(yintercept=0.1, linetype="longdash")+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  #ggtitle("Accuracy")+
  labs(x="Threshold")+
  labs(y="Noise")+
  labs(fill="Efficiency")

AccCon_TN<-ggplot(data = Treshold_noise_data, aes(x=Treshold, y=Noise, fill=V10))+
  #geom_contour_fill()+
  geom_raster(interpolate = TRUE)+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(-1,1), oob=squish)+
  geom_vline(xintercept=20, linetype="longdash")+
  geom_hline(yintercept=0.1, linetype="longdash")+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  #ggtitle("Accuracy")+
  labs(x="Threshold")+
  labs(y="Noise")+
  labs(fill=expression("Statistic"))

AccGrat_TN<-ggplot(data = Treshold_noise_data, aes(x=Treshold, y=Noise, fill=V11))+
  #geom_contour_fill()+
  geom_raster(interpolate = TRUE)+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(-1,1), oob=squish)+
  geom_vline(xintercept=20, linetype="longdash")+
  geom_hline(yintercept=0.1, linetype="longdash")+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  #ggtitle("Accuracy")+
  labs(x="Threshold")+
  labs(y="Noise")+
  labs(fill=expression("Statistic"))

ACC_all_fig<-ggarrange(Acc_IT, Acc_IN, Acc_TN, nrow =3, common.legend = TRUE)
ACC_all_fig<-annotate_figure(ACC_all_fig, top = text_grob("Efficiency", face = "bold", size = 10, family="Times"))

ACC_con_fig<-ggarrange(AccCon_IT, AccCon_IN, AccCon_TN, nrow =3, common.legend = TRUE)
ACC_con_fig<-annotate_figure(ACC_con_fig, top = text_grob("Congruency-effect", face = "bold", size = 10, family="Times"))

ACC_grat_fig<-ggarrange(AccGrat_IT, AccGrat_IN, AccGrat_TN, nrow =3, common.legend = TRUE)
ACC_grat_fig<-annotate_figure(ACC_grat_fig, top = text_grob("Conflict-adaptation-effect", face = "bold", size = 10, family="Times"))

ACC_Integrator_fig<-ggarrange(ACC_all_fig, ACC_con_fig, ACC_grat_fig, ncol=3)
ACC_Integrator_fig

ggsave(filename= "ES_Integrator_tres.tiff", ACC_Integrator_fig, width=15, height=15, units="cm", dpi=300)
ggsave(filename= "ES_Integrator_tres.png", ACC_Integrator_fig, width=15, height=15, units="cm", dpi=300)


