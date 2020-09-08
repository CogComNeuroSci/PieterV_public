library(R.matlab)
library(lmerTest) 
library(car)
library(effects)
library(ggplot2)
library(Rmisc)
library(ggpubr)
library(gridExtra)
library(scales)

###############################################
# Loading in data and preparing it for analyses
###############################################
# loading in
setwd("/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/lme_data/")

#EEG data
cluster_data<-read.table('cluster_data.txt', header = F, sep = ";")
cluster_data<-t(cluster_data)

cluster_data<-cluster_data[1:12960,]

model_data<-read.table('model_data.txt', header = F, sep = ";")
model_data<-t(model_data)

model_data<-model_data[1:12960,]

setwd("/Volumes/Harde ploate/model_fitting/Sync_data")

pplist<-c(3, 5:7, 9:10,12,14:16, 18:34) #there were technical problems for subjects 1, 2, 11 and 13 and behavioral problems for 4, 8, 17

#Behavioral data
for (p in pplist){
  filename= sprintf("Behavioral_data_subject_%s_Sync.csv",p)
  Single_Data<-read.delim(filename, header = TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)
  if (p==3){
    Data<-Single_Data
  }
  else{
    Data<-rbind(Data, Single_Data)
  }
}

Sync_data<-read.delim('Sync_output.csv', header=TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)

setwd("/Volumes/Harde ploate/model_fitting/RW_data")

RW_data<-read.delim('RW_output.csv', header=TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)

setwd("/Volumes/Harde ploate/model_fitting/Hybrid_data")
Hybrid_data<-read.delim('Hybrid_output.csv', header=TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)


Weight_AIC_dat<-matrix(nrow=27, ncol=12)
Weight_AIC_dat[,1:3]<-cbind(RW_data$AIC, Hybrid_data$AIC, Sync_data$AIC)
Weight_AIC_dat[,4:6]<-Weight_AIC_dat[,1:3]-cbind(apply(Weight_AIC_dat[,1:3], 1, FUN=min),apply(Weight_AIC_dat[,1:3], 1, FUN=min),apply(Weight_AIC_dat[,1:3], 1, FUN=min)) 

Weight_AIC_dat[,7:9]<-exp(-1/2*Weight_AIC_dat[,4:6])
Weight_AIC_dat[,10:12]<-Weight_AIC_dat[,7:9]/apply(Weight_AIC_dat[,7:9], 1, FUN=sum)

Weight_AIC_dat<-as.data.frame(Weight_AIC_dat)
names(Weight_AIC_dat)<-c("RW_AIC","H_AIC","S_AIC","Delta_RW_AIC", "Delta_H_AIC", "Delta_S_AIC", "Exp_RW_AIC","Exp_H_AIC","Exp_S_AIC","RW_wAIC","H_wAIC","S_wAIC")

# Combine in one dataframe
All_data<-cbind(Data, cluster_data, model_data, rep(Weight_AIC_dat$S_wAIC, each=480))
names(All_data)[11:13]<-c("Theta", "Delta", "Alpha")
names(All_data)[14:15]<-c("Theta_model", "Pe_model")
names(All_data)[16]<-c("wAIC")
names(All_data)[1]<-c("Trial")

setwd("/Volumes/Harde ploate/EEG_reversal_learning/Behavioral_data/Indices")
RT_data<-read.delim('RT.csv', header = F, sep = ",")
All_data$RT<-RT_data
colnames(All_data)[17]<-c("RT")
All_data$ppnr<-rep(1:27, each=480)
Data_nolates<-All_data[!(All_data$RT>1000),]
Data_clean<-na.omit(Data_nolates)

#Check distributions of power
densityplot(~Theta |as.factor(ppnr),data=Data_clean)
densityplot(~Alpha |as.factor(ppnr),data=Data_clean)
densityplot(~Delta |as.factor(ppnr),data=Data_clean)
densityplot(~Theta_model |as.factor(ppnr),data=All_data)
densityplot(~log(Theta_model) |as.factor(ppnr),data=All_data) #also not when we logtransform: data is bimodal

#all except the model data seem normal, so we can use Z-scores for these
Data_clean$ZTheta <- (Data_clean$Theta - mean(Data_clean$Theta)) / sd(Data_clean$Theta)
Data_clean$ZAlpha <- (Data_clean$Alpha - mean(Data_clean$Alpha)) / sd(Data_clean$Alpha)
Data_clean$ZDelta <- (Data_clean$Delta - mean(Data_clean$Delta)) / sd(Data_clean$Delta)
Data_clean$ZModel <- (log(Data_clean$Theta_model) - mean(log(Data_clean$Theta_model)) / sd(log(Data_clean$Theta_model)))

#Check distribution of z-scores
densityplot(~ZTheta |as.factor(ppnr),data=Data_clean)
densityplot(~ZAlpha |as.factor(ppnr),data=Data_clean)
densityplot(~ZDelta |as.factor(ppnr),data=Data_clean)
densityplot(~ZModel |as.factor(ppnr),data=Data_clean)

Data_clean$Reward<-as.factor(Data_clean$Reward)
Data_clean$wAIC<-as.numeric(Data_clean$wAIC)

########################
# Theta cluster analyses
########################
# Make models
fit_theta=lmer(ZTheta ~ (1 |ppnr) + PE_estimate, Data_clean)
fit_theta_2=lmer(ZTheta ~ (1 |ppnr) + PE_estimate + PE_estimate:Reward, Data_clean)
fit_theta_3=lmer(ZTheta ~ (1 |ppnr) + PE_estimate + PE_estimate:Reward + PE_estimate:Reward:wAIC, Data_clean)
anova(fit_theta, fit_theta_2)
# Data: Data_clean
# Models:
#   fit_theta: ZTheta ~ (1 | ppnr) + PE_estimate
# fit_theta_2: ZTheta ~ (1 | ppnr) + PE_estimate + PE_estimate:Reward
# Df   AIC   BIC logLik deviance  Chisq Chi Df Pr(>Chisq)    
# fit_theta    4 32315 32344 -16153    32307                             
# fit_theta_2  5 32207 32244 -16098    32197 109.67      1  < 2.2e-16 ***
#   ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

anova(fit_theta_2, fit_theta_3)
# Data: Data_clean
# Models:
#   fit_theta_2: ZTheta ~ (1 | ppnr) + PE_estimate + PE_estimate:Reward
# fit_theta_3: ZTheta ~ (1 | ppnr) + PE_estimate + PE_estimate:Reward + PE_estimate:Reward:wAIC
# Df   AIC   BIC logLik deviance  Chisq Chi Df Pr(>Chisq)    
# fit_theta_2  5 32207 32244 -16098    32197                             
# fit_theta_3  7 32190 32242 -16088    32176 20.743      2  3.132e-05 ***
#   ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Anova(fit_theta_3)
# Analysis of Deviance Table (Type II Wald chisquare tests)
# 
# Response: ZTheta
# Chisq Df Pr(>Chisq)    
# PE_estimate             1299.142  1  < 2.2e-16 ***
#   PE_estimate:Reward       110.384  1  < 2.2e-16 ***
#   PE_estimate:Reward:wAIC   20.899  2  2.896e-05 ***
#   ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

summary(fit_theta_3)
# Linear mixed model fit by REML. t-tests use Satterthwaite's method ['lmerModLmerTest']
# Formula: ZTheta ~ (1 | ppnr) + PE_estimate + PE_estimate:Reward + PE_estimate:Reward:wAIC
#    Data: Data_clean
# 
# REML criterion at convergence: 32192.9
# 
# Scaled residuals: 
#     Min      1Q  Median      3Q     Max 
# -4.0822 -0.6903 -0.0370  0.6571  3.7135 
# 
# Random effects:
#  Groups   Name        Variance Std.Dev.
#  ppnr     (Intercept) 0.05494  0.2344  
#  Residual             0.85220  0.9231  
# Number of obs: 11983, groups:  ppnr, 27
# 
# Fixed effects:
#                            Estimate Std. Error         df t value Pr(>|t|)    
# (Intercept)                -0.24063    0.05617   48.88076  -4.284 8.57e-05 ***
# PE_estimate                -0.79376    0.07977 2648.16489  -9.950  < 2e-16 ***
# PE_estimate:Reward1         0.65184    0.13911 1432.76149   4.686 3.05e-06 ***
# PE_estimate:Reward0:wAIC   -0.89148    0.22198  533.56831  -4.016 6.77e-05 ***
# PE_estimate:Reward1:wAIC    0.43510    0.24560  403.71373   1.772   0.0772 .  
# ---
# Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Correlation of Fixed Effects:
#             (Intr) PE_stm PE_s:R1 PE_:R0
# PE_estimate -0.016                      
# PE_stmt:Rw1  0.012 -0.888               
# PE_s:R0:AIC  0.362 -0.769  0.711        
# PE_s:R1:AIC -0.405  0.451 -0.652  -0.781

##############################
#Theta cluster plot
##############################
eff = effect("PE_estimate:Reward:wAIC", fit_theta_3, xlevels=list(PE_estimate=seq(-1,1, by=0.1), wAIC=c(0.1,0.4,0.7)))

x.fit <- unlist(eff$x.all)
x <- data.frame(lower = eff$lower, upper = eff$upper, fit = eff$fit)
x$PE<-eff$x$PE_estimate
x$Reward<-eff$x$Reward
x$wAIC<-eff$x$wAIC
x$wAIC<-as.factor(x$wAIC)

mean_df<-cbind(unique(x[x$Reward==0,4]), aggregate(x[x$Reward==0,3], list(x[x$Reward==0,4]), mean)$x)

Theta_norew_plot <- ggplot(x[x$Reward==0,], aes(x = PE, y = fit, colour=wAIC, fill=wAIC)) +
                    theme_classic() +
                    geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.5, colour=NA)+
                    geom_line(size = 1) +
                    #geom_abline(intercept=mean_df[11,2], slope=mean_df[11,2]-mean_df[1,2], size=2, color="black")+
                    ggtitle("Unrewarded trials")+
                    theme(  legend.title = element_text(size = 8, family = "Times"), legend.text = element_text(size = 8, family="Times"),axis.text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
                    labs(x="")+
                    labs(y="")+
                    scale_x_continuous(limits=c(-1,0))+
                    scale_y_continuous(limits =c(-0.5,1.25), oob=rescale_none)+
                    scale_colour_manual(values=c("red", "blue","darkgreen"))+
                    scale_fill_manual(values=c("red", "blue","darkgreen"))
                    #geom_point(data = Data_clean[Data_clean$Reward==0,], aes(x = PE_estimate, y = ZTheta), shape = 1, col = "blue", size = 2) +
                    

mean_df<-cbind(unique(x[x$Reward==1,4]), aggregate(x[x$Reward==1,3], list(x[x$Reward==1,4]), mean)$x)

Theta_rew_plot <- ggplot(x[x$Reward==1,], aes(x = PE, y = fit, colour=wAIC, fill=wAIC)) +
  theme_classic() +
  geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.5, colour=NA)+
  geom_line(size = 1) +
  #geom_abline(intercept=mean_df[11,2], slope=mean_df[11,2]-mean_df[1,2], size=2, color="black")+
  ggtitle("Rewarded trials")+
  theme(axis.text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  labs(x="")+
  labs(y="")+
  scale_x_continuous(limits=c(0,1))+
  scale_y_continuous(limits =c(-0.5,1.25), oob=rescale_none)+
  scale_colour_manual(values=c("red", "blue","darkgreen"))+
  scale_fill_manual(values=c("red", "blue","darkgreen"))
  #geom_point(data = Data_clean[Data_clean$Reward==0,], aes(x = PE_estimate, y = ZTheta), shape = 1, col = "blue", size = 2) +

Theta_fig<-ggarrange(Theta_norew_plot, Theta_rew_plot, ncol=2, common.legend = TRUE, legend="right" )

Theta_fig<-annotate_figure(Theta_fig, top=text_grob("Theta cluster", size=10, face="bold", family="Times"))

Theta_fig
########################
# Alpha cluster analyses
########################

# Make models
fit_alpha=lmer(ZAlpha ~ (1 |ppnr) + PE_estimate, Data_clean)
fit_alpha_2=lmer(ZAlpha ~ (1 |ppnr) + PE_estimate + PE_estimate:Reward, Data_clean)
fit_alpha_3=lmer(ZAlpha ~ (1 |ppnr) + PE_estimate + PE_estimate:Reward + PE_estimate:Reward:wAIC, Data_clean)
anova(fit_alpha, fit_alpha_2)
# Data: Data_clean
# Models:
#   fit_alpha: ZAlpha ~ (1 | ppnr) + PE_estimate
# fit_alpha_2: ZAlpha ~ (1 | ppnr) + PE_estimate + PE_estimate:Reward
# Df   AIC   BIC logLik deviance Chisq Chi Df Pr(>Chisq)    
# fit_alpha    4 31792 31822 -15892    31784                            
# fit_alpha_2  5 31570 31607 -15780    31560 224.1      1  < 2.2e-16 ***
#   ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

anova(fit_alpha_2, fit_alpha_3)
# Data: Data_clean
# Models:
#   fit_alpha_2: ZAlpha ~ (1 | ppnr) + PE_estimate + PE_estimate:Reward
# fit_alpha_3: ZAlpha ~ (1 | ppnr) + PE_estimate + PE_estimate:Reward + PE_estimate:Reward:wAIC
# Df   AIC   BIC logLik deviance  Chisq Chi Df Pr(>Chisq)
# fit_alpha_2  5 31570 31607 -15780    31560                         
# fit_alpha_3  7 31574 31625 -15780    31560 0.3458      2     0.8412

Anova(fit_alpha_3)
# Analysis of Deviance Table (Type II Wald chisquare tests)
# 
# Response: ZAlpha
# Chisq Df Pr(>Chisq)    
# PE_estimate             142.0932  1     <2e-16 ***
#   PE_estimate:Reward      226.1958  1     <2e-16 ***
#   PE_estimate:Reward:wAIC   0.3647  2     0.8333    
# ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

summary(fit_alpha_3)
# Linear mixed model fit by REML. t-tests use Satterthwaite's method ['lmerModLmerTest']
# Formula: ZAlpha ~ (1 | ppnr) + PE_estimate + PE_estimate:Reward + PE_estimate:Reward:wAIC
#    Data: Data_clean
# 
# REML criterion at convergence: 31575
# 
# Scaled residuals: 
#     Min      1Q  Median      3Q     Max 
# -3.6431 -0.6757 -0.0081  0.6560  3.9754 
# 
# Random effects:
#  Groups   Name        Variance Std.Dev.
#  ppnr     (Intercept) 0.1778   0.4217  
#  Residual             0.8073   0.8985  
# Number of obs: 11983, groups:  ppnr, 27
# 
# Fixed effects:
#                            Estimate Std. Error         df t value Pr(>|t|)    
# (Intercept)                 0.32503    0.08812   33.52832   3.689 0.000794 ***
# PE_estimate                 0.85013    0.08050 7652.02545  10.561  < 2e-16 ***
# PE_estimate:Reward1        -1.37573    0.14249 5611.28486  -9.655  < 2e-16 ***
# PE_estimate:Reward0:wAIC    0.01809    0.23493 3025.91310   0.077 0.938628    
# PE_estimate:Reward1:wAIC   -0.10749    0.26300 2502.72459  -0.409 0.682791    
# ---
# Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Correlation of Fixed Effects:
#             (Intr) PE_stm PE_s:R1 PE_:R0
# PE_estimate -0.042                      
# PE_stmt:Rw1  0.045 -0.896               
# PE_s:R0:AIC  0.255 -0.786  0.744        
# PE_s:R1:AIC -0.280  0.505 -0.693  -0.816

##############################
#Alpha cluster plot
##############################
eff = effect("PE_estimate:Reward:wAIC", fit_alpha_3, xlevels=list(PE_estimate=seq(-1,1, by=0.1), wAIC=c(0.1,0.4,0.7)))

x.fit <- unlist(eff$x.all)
x <- data.frame(lower = eff$lower, upper = eff$upper, fit = eff$fit)
x$PE<-eff$x$PE_estimate
x$Reward<-eff$x$Reward
x$wAIC<-eff$x$wAIC
x$wAIC<-as.factor(x$wAIC)

mean_df<-cbind(unique(x[x$Reward==0,4]), aggregate(x[x$Reward==0,3], list(x[x$Reward==0,4]), mean)$x)

Alpha_norew_plot <- ggplot(x[x$Reward==0,], aes(x = PE, y = fit, colour=wAIC, fill=wAIC)) +
  theme_classic() +
  geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.5, colour=NA)+
  geom_line(size = 1) +
  #geom_abline(intercept=mean_df[11,2], slope=mean_df[11,2]-mean_df[1,2], size=2, color="black")+
  ggtitle("Unrewarded trials")+
  theme(  legend.title = element_text(size = 8, family = "Times"), legend.text = element_text(size = 8, family="Times"),axis.text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  labs(x="PE")+
  labs(y="")+
  scale_x_continuous(limits=c(-1,0))+
  scale_y_continuous(limits =c(-0.5,1.25), oob=rescale_none)+
  scale_colour_manual(values=c("red", "blue","darkgreen"))+
  scale_fill_manual(values=c("red", "blue","darkgreen"))
  #geom_point(data = Data_clean[Data_clean$Reward==0,], aes(x = PE_estimate, y = ZTheta), shape = 1, col = "blue", size = 2) +

mean_df<-cbind(unique(x[x$Reward==1,4]), aggregate(x[x$Reward==1,3], list(x[x$Reward==1,4]), mean)$x)

Alpha_rew_plot <- ggplot(x[x$Reward==1,], aes(x = PE, y = fit, colour=wAIC, fill=wAIC)) +
  theme_classic() +
  geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.5, colour=NA)+
  geom_line(size = 1) +
  #geom_abline(intercept=mean_df[11,2], slope=mean_df[11,2]-mean_df[1,2], size=2, color="black")+
  ggtitle("Rewarded trials")+
  theme(  legend.title = element_text(size = 8, family = "Times"), legend.text = element_text(size = 8, family="Times"),axis.text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  labs(x="PE")+
  labs(y="")+
  scale_x_continuous(limits=c(0,1))+
  scale_y_continuous(limits =c(-0.5,1.25), oob=rescale_none)+
  scale_colour_manual(values=c("red", "blue","darkgreen"))+
  scale_fill_manual(values=c("red", "blue","darkgreen"))
  #geom_point(data = Data_clean[Data_clean$Reward==0,], aes(x = PE_estimate, y = ZTheta), shape = 1, col = "blue", size = 2) +

Alpha_fig<-ggarrange(Alpha_norew_plot, Alpha_rew_plot, ncol=2, common.legend = TRUE, legend="right")

Alpha_fig<-annotate_figure(Alpha_fig, top=text_grob("Alpha cluster", size=10, face="bold", family="Times"))

Alpha_fig

########################
# Delta cluster analyses
########################

# Make models
fit_delta=lmer(ZDelta ~ (1 |ppnr) + PE_estimate, Data_clean)
fit_delta_2=lmer(ZDelta ~ (1 |ppnr) + PE_estimate + PE_estimate:Reward, Data_clean)
fit_delta_3=lmer(ZDelta ~ (1 |ppnr) + PE_estimate + PE_estimate:Reward + PE_estimate:Reward:wAIC, Data_clean)
anova(fit_delta, fit_delta_2)
# refitting model(s) with ML (instead of REML)
# Data: Data_clean
# Models:
#   fit_delta: ZDelta ~ (1 | ppnr) + PE_estimate
# fit_delta_2: ZDelta ~ (1 | ppnr) + PE_estimate + PE_estimate:Reward
# Df   AIC   BIC logLik deviance  Chisq Chi Df Pr(>Chisq)  
# fit_delta    4 32676 32705 -16334    32668                           
# fit_delta_2  5 32674 32711 -16332    32664 3.4868      1    0.06186 .
# ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

anova(fit_delta_2, fit_delta_3)
# refitting model(s) with ML (instead of REML)
# Data: Data_clean
# Models:
#   fit_delta_2: ZDelta ~ (1 | ppnr) + PE_estimate + PE_estimate:Reward
# fit_delta_3: ZDelta ~ (1 | ppnr) + PE_estimate + PE_estimate:Reward + PE_estimate:Reward:wAIC
# Df   AIC   BIC logLik deviance  Chisq Chi Df Pr(>Chisq)  
# fit_delta_2  5 32674 32711 -16332    32664                           
# fit_delta_3  7 32673 32724 -16329    32659 5.7861      2    0.05541 .
# ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Anova(fit_delta_3)
# Analysis of Deviance Table (Type II Wald chisquare tests)
# 
# Response: ZDelta
# Chisq Df Pr(>Chisq)    
# PE_estimate             580.1187  1    < 2e-16 ***
#   PE_estimate:Reward        3.4885  1    0.06180 .  
# PE_estimate:Reward:wAIC   5.8343  2    0.05409 .  
# ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

summary(fit_delta_3)
# Linear mixed model fit by REML. t-tests use Satterthwaite's method ['lmerModLmerTest']
# Formula: ZDelta ~ (1 | ppnr) + PE_estimate + PE_estimate:Reward + PE_estimate:Reward:wAIC
#    Data: Data_clean
# 
# REML criterion at convergence: 32674.7
# 
# Scaled residuals: 
#     Min      1Q  Median      3Q     Max 
# -3.3915 -0.6933  0.0086  0.7009  4.0453 
# 
# Random effects:
#  Groups   Name        Variance Std.Dev.
#  ppnr     (Intercept) 0.07499  0.2739  
#  Residual             0.88668  0.9416  
# Number of obs: 11983, groups:  ppnr, 27
# 
# Fixed effects:
#                            Estimate Std. Error         df t value Pr(>|t|)    
# (Intercept)                -0.14236    0.06309   45.54560  -2.256   0.0289 *  
# PE_estimate                 0.45315    0.08224 3458.53291   5.510 3.85e-08 ***
# PE_estimate:Reward1        -0.06552    0.14408 1975.21119  -0.455   0.6493    
# PE_estimate:Reward0:wAIC   -0.49764    0.23230  788.18796  -2.142   0.0325 *  
# PE_estimate:Reward1:wAIC    0.61358    0.25800  608.16215   2.378   0.0177 *  
# ---
# Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Correlation of Fixed Effects:
#             (Intr) PE_stm PE_s:R1 PE_:R0
# PE_estimate -0.028                      
# PE_stmt:Rw1  0.027 -0.891               
# PE_s:R0:AIC  0.342 -0.774  0.721        
# PE_s:R1:AIC -0.381  0.468 -0.665  -0.792

##############################
#Delta cluster plot
##############################
eff = effect("PE_estimate:Reward:wAIC", fit_delta_3, xlevels=list(PE_estimate=seq(-1,1, by=0.1), wAIC=c(0.1,0.4,0.7)))

x.fit <- unlist(eff$x.all)
x <- data.frame(lower = eff$lower, upper = eff$upper, fit = eff$fit)
x$PE<-eff$x$PE_estimate
x$Reward<-eff$x$Reward
x$wAIC<-eff$x$wAIC
x$wAIC<-as.factor(x$wAIC)

mean_df<-cbind(unique(x[x$Reward==0,4]), aggregate(x[x$Reward==0,3], list(x[x$Reward==0,4]), mean)$x)

Delta_norew_plot <- ggplot(x[x$Reward==0,], aes(x = PE, y = fit, colour=wAIC, fill=wAIC)) +
  theme_classic() +
  geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.5, colour=NA)+
  geom_line(size = 1) +
  #geom_abline(intercept=mean_df[11,2], slope=mean_df[11,2]-mean_df[1,2], size=2, color="black")+
  ggtitle("Unrewarded trials")+
  theme(axis.text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  labs(x="PE")+
  labs(y="Power (Z-score)")+
  scale_x_continuous(limits=c(-1,0))+
  scale_y_continuous(limits =c(-0.5,1.25), oob=rescale_none)+
  scale_colour_manual(values=c("red", "blue","darkgreen"))+
  scale_fill_manual(values=c("red", "blue","darkgreen"))
  #geom_point(data = Data_clean[Data_clean$Reward==0,], aes(x = PE_estimate, y = ZTheta), shape = 1, col = "blue", size = 2) +
  
mean_df<-cbind(unique(x[x$Reward==1,4]), aggregate(x[x$Reward==1,3], list(x[x$Reward==1,4]), mean)$x)

Delta_rew_plot <- ggplot(x[x$Reward==1,], aes(x = PE, y = fit, colour=wAIC, fill=wAIC)) +
  theme_classic() +
  geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.5, colour=NA)+
  geom_line(size = 1) +
  #geom_abline(intercept=mean_df[11,2], slope=mean_df[11,2]-mean_df[1,2], size=2, color="black")+
  ggtitle("Rewarded trials")+
  theme(axis.text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  labs(x="PE")+
  labs(y="")+
  scale_x_continuous(limits=c(0,1))+
  scale_y_continuous(limits =c(-0.5,1.25), oob=rescale_none)+
  scale_colour_manual(values=c("red", "blue","darkgreen"))+
  scale_fill_manual(values=c("red", "blue","darkgreen"))
  #geom_point(data = Data_clean[Data_clean$Reward==0,], aes(x = PE_estimate, y = ZTheta), shape = 1, col = "blue", size = 2) +
  
Delta_fig<-ggarrange(Delta_norew_plot, Delta_rew_plot, ncol=2, common.legend = TRUE, legend="none")

Delta_fig<-annotate_figure(Delta_fig, top=text_grob("Delta cluster", size=10, face="bold", family="Times"))

Delta_fig

########################
# Model cluster analyses
########################
# Make models
Data_clean$Reward_model<-0
Data_clean$Reward_model[Data_clean$Pe_model>0]<-1
Data_clean$Reward_model<-as.factor(Data_clean$Reward_model)

fit_model=lm(ZModel ~ Pe_model, Data_clean)                   
fit_model_2=lm(ZModel ~ Pe_model + Pe_model:Reward_model, Data_clean)
anova(fit_model, fit_model_2)
# Analysis of Variance Table
# 
# Model 1: ZModel ~ Pe_model
# Model 2: ZModel ~ Pe_model + Pe_model:Reward_model
# Res.Df     RSS Df Sum of Sq     F    Pr(>F)    
# 1  11981 1421.84                                 
# 2  11980  499.34  1     922.5 22133 < 2.2e-16 ***
#   ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Anova(fit_model_2)
# Anova Table (Type II tests)
# 
# Response: ZModel
# Sum Sq    Df F value    Pr(>F)    
# Pe_model              30967.3     1  742962 < 2.2e-16 ***
#   Pe_model:Reward_model   922.5     1   22133 < 2.2e-16 ***
#   Residuals               499.3 11980                      
# ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

summary(fit_model_2)
# Call:
# lm(formula = ZModel ~ Pe_model + Pe_model:Reward_model, data = Data_clean)
# 
# Residuals:
#   Min       1Q   Median       3Q      Max 
# -1.64084 -0.06895 -0.01173  0.05015  1.11490 
# 
# Coefficients:
#   Estimate Std. Error t value Pr(>|t|)    
# (Intercept)            -1.434902   0.006988  -205.3   <2e-16 ***
#   Pe_model               -4.992200   0.011635  -429.1   <2e-16 ***
#   Pe_model:Reward_model1  4.476707   0.030091   148.8   <2e-16 ***
# Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Residual standard error: 0.2042 on 11980 degrees of freedom
# Multiple R-squared:  0.9846,	Adjusted R-squared:  0.9846 
# F-statistic: 3.825e+05 on 2 and 11980 DF,  p-value: < 2.2e-16

##############################
#Model cluster plot
##############################
eff = effect("Pe_model:Reward_model", fit_model_2, xlevels=list(Pe_model=seq(-1,1, by=0.1)))

x <- data.frame( fit = eff$fit)
x$PE<-rep(eff$variables$Pe_model$levels, times=2)
x$Reward<-rep(0:1,each=length(seq(-1,1, by=0.1)))

Model_norew_plot <- ggplot(x[x$Reward==0,], aes(x = PE, y = fit)) +
  theme_classic() +
  geom_line(size = 1, color="blue") +
  theme(axis.text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  ggtitle("Unrewarded trials")+
  labs(x="")+
  labs(y="Power (Z-score)")+
  scale_x_continuous(limits=c(-1,0))+
  scale_y_continuous(limits =c(-3,4), oob=rescale_none)
  #geom_point(data = Data_clean[Data_clean$Reward==0,], aes(x = PE_estimate, y = ZTheta), shape = 1, col = "blue", size = 2) +

Model_rew_plot <- ggplot(x[x$Reward==1,], aes(x = PE, y = fit)) +
  theme_classic() +
  geom_line(size = 1, color="blue") +
  theme(axis.text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  ggtitle("Rewarded trials")+
  labs(x="")+
  labs(y="")+
  scale_x_continuous(limits=c(0,1))+
  scale_y_continuous(limits =c(-3,4), oob=rescale_none)
  #geom_point(data = Data_clean[Data_clean$Reward==0,], aes(x = PE_estimate, y = ZTheta), shape = 1, col = "blue", size = 2) +

Model_fig<-ggarrange(Model_norew_plot, Model_rew_plot, ncol=2 )

Model_fig<-annotate_figure(Model_fig, top=text_grob("Model cluster", size=10, face="bold", family="Times"))

Model_fig

Total_figure<-ggarrange(Model_fig, Theta_fig, Delta_fig, Alpha_fig, labels="AUTO", font.label = list(size=12, face="bold", family="Times"), ncol=2, nrow=2, widths=c(0.85,1))

Total_figure

Figure_folder="/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/Figures/Power_cluster"
ggsave(filename= paste(Figure_folder, "PE_regression.tiff"), Total_figure, width=17.5, height=10, units="cm", dpi=300)

