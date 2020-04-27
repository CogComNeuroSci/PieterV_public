#clear console, environment and plots
cat("\014")
rm(list = ls())

#load libraries
library(ggplot2)
library(Rmisc)
library(yarrr)
library(scales)
library(ggpubr)
library(lmerTest)
library(car)
library(effects)

#define folders
Sync_fit_folder="/Volumes/Harde ploate/model_fitting/Sync_data"
RW_fit_folder="/Volumes/Harde ploate/model_fitting/RW_data"
Hybrid_fit_folder="/Volumes/Harde ploate/model_fitting/Hybrid_data"
Figure_folder="/Volumes/Harde ploate/EEG_reversal_learning/Behavioral_data/figures/"
PLV_folder="/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/PLV_data/"
Power_folder="/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/Scripts/Cluster_analyses/TF/Feedback_period"
#define number of participants and number of trials
Tr=480

pp=27

setwd(RW_fit_folder)
RW_data<-read.delim('RW_output.csv', header=TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)

setwd(Hybrid_fit_folder)
Hybrid_data<-read.delim('Hybrid_output.csv', header=TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)

Sync_data<-read.delim('Sync_output.csv', header=TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)

Weight_AIC_dat<-matrix(nrow=27, ncol=12)
Weight_AIC_dat[,1:3]<-cbind(RW_data$AIC, Hybrid_data$AIC, State_data$AIC)
Weight_AIC_dat[,4:6]<-Weight_AIC_dat[,1:3]-cbind(apply(Weight_AIC_dat[,1:3], 1, FUN=min),apply(Weight_AIC_dat[,1:3], 1, FUN=min),apply(Weight_AIC_dat[,1:3], 1, FUN=min)) 

Weight_AIC_dat[,7:9]<-exp(-1/2*Weight_AIC_dat[,4:6])
Weight_AIC_dat[,10:12]<-Weight_AIC_dat[,7:9]/apply(Weight_AIC_dat[,7:9], 1, FUN=sum)

Weight_AIC_dat<-as.data.frame(Weight_AIC_dat)
names(Weight_AIC_dat)<-c("Q_AIC","H_AIC","S_AIC","Delta_Q_AIC", "Delta_H_AIC", "Delta_S_AIC", "Exp_Q_AIC","Exp_H_AIC","Exp_S_AIC","Q_wAIC","H_wAIC","S_wAIC")

setwd(PLV_folder)
PLV_data<-read.table('PLV_data_individual.txt', header = F, sep = ";")
PLV_data<-as.data.frame(t(PLV_data))
PLV_data<-PLV_data[1:27,]
names(PLV_data)<-c("Theta_contra_post_plv", "Theta_ipsi_post_plv","Theta_contra_front_plv","Theta_ipsi_front_plv","Delta_contra_plv", "Delta_ipsi_plv")

setwd(Power_folder)
Power_data<-read.table('Power_data_individual.txt', header = F, sep = ";")
Power_data<-as.data.frame(t(Power_data))
Power_data<-Power_data[1:27,]
names(Power_data)<-c("Theta_pow", "Delta_pow", "Alpha_pow")

Dat_all<-cbind(Weight_AIC_dat$S_wAIC, PLV_data, Power_data)
names(Dat_all)[1]<-"wAIC"

cor.test(Dat_all$wAIC, Dat_all$Theta_contra_post_plv, method="spearman")
# Spearman's rank correlation rho
# 
# data:  Dat_all$wAIC and Dat_all$Theta_contra_post_plv
# S = 3846, p-value = 0.3837
# alternative hypothesis: true rho is not equal to 0
# sample estimates:
#        rho 
# -0.1739927 

Correlation_PLV_thetacontrapost<-ggplot(Dat_all, aes(y=Theta_contra_post_plv, x=wAIC))+
  geom_point()+
  geom_smooth(method=lm)+
  labs(x="wAIC")+
  labs(y="PLV contrast")+
  ggtitle('Spearman rho = -0.174, p=0.383')+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"),plot.title = element_text(size = 8, face = "italic", hjust=0.5, family="Times"))

Correlation_PLV_thetacontrapost

cor.test(Dat_all$wAIC, Dat_all$Theta_ipsi_post_plv, method="spearman")
# Spearman's rank correlation rho
# 
# data:  Dat_all$wAIC and Dat_all$Theta_ipsi_post_plv
# S = 4092, p-value = 0.2094
# alternative hypothesis: true rho is not equal to 0
# sample estimates:
#        rho 
# -0.2490842 

Correlation_PLV_thetaipsipost<-ggplot(Dat_all, aes(y=Theta_contra_post_plv, x=wAIC))+
  geom_point()+
  geom_smooth(method=lm)+
  labs(x="wAIC")+
  labs(y="PLV contrast")+
  ggtitle('Spearman rho = -0.25, p=0.21')+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"),plot.title = element_text(size = 8, face = "italic", hjust=0.5, family="Times"))

Correlation_PLV_thetaipsipost

cor.test(Dat_all$wAIC, Dat_all$Theta_contra_front_plv, method="spearman")
# Spearman's rank correlation rho
# 
# data:  Dat_all$wAIC and Dat_all$Theta_contra_front_plv
# S = 3538, p-value = 0.6908
# alternative hypothesis: true rho is not equal to 0
# sample estimates:
#         rho 
# -0.07997558 

cor.test(Dat_all$wAIC, Dat_all$Theta_ipsi_front_plv, method="spearman")
# Spearman's rank correlation rho
# 
# data:  Dat_all$wAIC and Dat_all$Theta_ipsi_front_plv
# S = 3734, p-value = 0.4851
# alternative hypothesis: true rho is not equal to 0
# sample estimates:
#        rho 
# -0.1398046

cor.test(Dat_all$wAIC, Dat_all$Delta_contra_plv, method="spearman")
# Spearman's rank correlation rho
# 
# data:  Dat_all$wAIC and Dat_all$Delta_contra_plv
# S = 3778, p-value = 0.4437
# alternative hypothesis: true rho is not equal to 0
# sample estimates:
#        rho 
# -0.1532357  

cor.test(Dat_all$wAIC, Dat_all$Delta_ipsi_plv, method="spearman")
# Spearman's rank correlation rho
# 
# data:  Dat_all$wAIC and Dat_all$Delta_ipsi_plv
# S = 3646, p-value = 0.5734
# alternative hypothesis: true rho is not equal to 0
# sample estimates:
#        rho 
# -0.1129426 

cor.test(Dat_all$wAIC, Dat_all$Theta_pow, method="spearman")
# Spearman's rank correlation rho
# 
# data:  Dat_all$wAIC and Dat_all$Theta_pow
# S = 3220, p-value = 0.9333
# alternative hypothesis: true rho is not equal to 0
# sample estimates:
#        rho 
# 0.01709402  

Correlation_Pow_theta<-ggplot(Dat_all, aes(y=Theta_pow, x=wAIC))+
  geom_point()+
  geom_smooth(method=lm)+
  labs(x="wAIC")+
  labs(y="Power contrast")+
  ggtitle('Spearman rho = 0.017, p=0.933')+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"),plot.title = element_text(size = 8, face = "italic", hjust=0.5, family="Times"))

Correlation_Pow_theta

cor.test(Dat_all$wAIC, Dat_all$Delta_pow, method="spearman")
# Spearman's rank correlation rho
# 
# data:  Dat_all$wAIC and Dat_all$Delta_pow
# S = 2956, p-value = 0.6267
# alternative hypothesis: true rho is not equal to 0
# sample estimates:
#       rho 
# 0.0976801 

cor.test(Dat_all$wAIC, Dat_all$Alpha_pow, method="spearman")
# Spearman's rank correlation rho
# 
# data:  Dat_all$wAIC and Dat_all$Alpha_pow
# S = 2838, p-value = 0.5045
# alternative hypothesis: true rho is not equal to 0
# sample estimates:
#       rho 
# 0.1336996  


