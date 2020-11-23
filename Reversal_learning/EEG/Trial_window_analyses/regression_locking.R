library(R.matlab)
library(lmerTest) 
library(car)
library(effects)
library(ggplot2)
library(Rmisc)
library(ggpubr)
library(scales)

###############################################
# Loading in data and preparing it for analyses
###############################################
Figure_folder="/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/Figures/"
# loading in
setwd("/Volumes/Harde ploate/EEG_reversal_learning/Simulated_data/Task simulations")

#EEG data
Data<-read.table('Switch_data_conservative.txt', header = F, sep = ";")
Data<-as.data.frame(t(Data))
tr<-rep(seq(-15,15),27)

Data<-Data[1:837,]
Data[,6]<-tr
names(Data)[1:6]<-c("Model_power", "Theta_power","Delta_power","Alpha_power", "Alpha_extra","trial")

Tpower_baseline=-2.3397
Dpower_baseline=-1.2009
Apower_baseline=-3.5842

setwd("/Volumes/Harde ploate/EEG_reversal_learning/model_fitting/RW_data")

RW_data<-read.delim('RW_output.csv', header=TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)
setwd("/Volumes/Harde ploate/EEG_reversal_learning/model_fitting/Hybrid_data")
Hybrid_data<-read.delim('Hybrid_output.csv', header=TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)
setwd("/Volumes/Harde ploate/EEG_reversal_learning/model_fitting/Sync_data")
State_data<-read.delim('Sync_output.csv', header=TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)

Weight_AIC_dat<-matrix(nrow=27, ncol=12)
Weight_AIC_dat[,1:3]<-cbind(RW_data$AIC, Hybrid_data$AIC, Sync_data$AIC)
Weight_AIC_dat[,4:6]<-Weight_AIC_dat[,1:3]-cbind(apply(Weight_AIC_dat[,1:3], 1, FUN=min),apply(Weight_AIC_dat[,1:3], 1, FUN=min),apply(Weight_AIC_dat[,1:3], 1, FUN=min)) 

Weight_AIC_dat[,7:9]<-exp(-1/2*Weight_AIC_dat[,4:6])
Weight_AIC_dat[,10:12]<-Weight_AIC_dat[,7:9]/apply(Weight_AIC_dat[,7:9], 1, FUN=sum)

Weight_AIC_dat<-as.data.frame(Weight_AIC_dat)
names(Weight_AIC_dat)<-c("RW_AIC","H_AIC","S_AIC","Delta_RW_AIC", "Delta_H_AIC", "Delta_S_AIC", "Exp_RW_AIC","Exp_H_AIC","Exp_S_AIC","RW_wAIC","H_wAIC","S_wAIC")

Data$wAIC<-rep(Weight_AIC_dat$S_wAIC, each=31)
Data$ppnr<-rep(seq(1,27), each=31)

regression_Tpower<-lm(Theta_power~1+Model_power, data=Data)
regression_Dpower<-lm(Delta_power~1+Model_power, data=Data)
regression_Apower<-lm(Alpha_power~1+Model_power, data=Data)

regression_Tpower2<-lm(Theta_power~1+Model_power+Model_power:wAIC, data=Data)
regression_Dpower2<-lm(Delta_power~1+Model_power+Model_power:wAIC, data=Data)
regression_Apower2<-lm(Alpha_power~1+Model_power+Model_power:wAIC, data=Data)

anova(regression_Tpower, regression_Tpower2)
anova(regression_Dpower, regression_Dpower2)
anova(regression_Apower, regression_Apower2)

Tpower=summarySE(data=Data, measurevar="Theta_power", groupvars="trial", conf.interval = .9984)
Dpower=summarySE(data=Data, measurevar="Delta_power", groupvars="trial", conf.interval = .9984)
Apower=summarySE(data=Data, measurevar="Alpha_power", groupvars="trial", conf.interval = .9984)
Apower_extra=summarySE(data=Data, measurevar="Alpha_extra", groupvars="trial", conf.interval = .9984, na.rm = TRUE)

Anova(regression_Tpower)
# Anova Table (Type II tests)
# 
# Response: Theta_power
# Sum Sq  Df F value    Pr(>F)    
# Model_power   28.29   1  20.508 6.801e-06 ***
#   Residuals   1151.84 835                      
# ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

summary(regression_Tpower)
# Call:
#   lm(formula = Theta_power ~ 1 + Model_power, data = Data)
# 
# Residuals:
#   Min      1Q  Median      3Q     Max 
# -4.3812 -0.7336  0.0129  0.7422  5.5547 
# 
# Coefficients:
#   Estimate Std. Error t value Pr(>|t|)    
# (Intercept) -2.48376    0.08766 -28.333  < 2e-16 ***
#   Model_power  0.30901    0.06823   4.529  6.8e-06 ***
#   ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Residual standard error: 1.175 on 835 degrees of freedom
# Multiple R-squared:  0.02397,	Adjusted R-squared:  0.0228 
# F-statistic: 20.51 on 1 and 835 DF,  p-value: 6.801e-06

Anova(regression_Dpower)
# Anova Table (Type II tests)
# 
# Response: Delta_power
# Sum Sq  Df F value   Pr(>F)   
# Model_power    9.19   1  7.3554 0.006824 **
#   Residuals   1043.48 835                    
# ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

summary(regression_Dpower)
# Call:
#   lm(formula = Delta_power ~ 1 + Model_power, data = Data)
# 
# Residuals:
#   Min      1Q  Median      3Q     Max 
# -3.2663 -0.7577 -0.0186  0.6520  3.5050 
# 
# Coefficients:
#   Estimate Std. Error t value Pr(>|t|)    
# (Intercept) -1.01291    0.08344 -12.140  < 2e-16 ***
#   Model_power -0.17614    0.06495  -2.712  0.00682 ** 
#   ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Residual standard error: 1.118 on 835 degrees of freedom
# Multiple R-squared:  0.008732,	Adjusted R-squared:  0.007545 
# F-statistic: 7.355 on 1 and 835 DF,  p-value: 0.006824

Anova(regression_Apower)
# Anova Table (Type II tests)
# 
# Response: Alpha_power
# Sum Sq  Df F value    Pr(>F)    
# Model_power  125.4   1  32.716 1.485e-08 ***
#   Residuals   3199.5 835                      
# ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

summary(regression_Apower)
# Call:
#   lm(formula = Alpha_power ~ 1 + Model_power, data = Data)
# 
# Residuals:
#   Min      1Q  Median      3Q     Max 
# -6.7816 -0.9356  0.3148  1.3030  4.1508 
# 
# Coefficients:
#   Estimate Std. Error t value Pr(>|t|)    
# (Intercept)  -2.9636     0.1461  -20.28  < 2e-16 ***
#   Model_power  -0.6505     0.1137   -5.72 1.49e-08 ***
#   ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Residual standard error: 1.957 on 835 degrees of freedom
# Multiple R-squared:  0.0377,	Adjusted R-squared:  0.03655 
# F-statistic: 32.72 on 1 and 835 DF,  p-value: 1.485e-08


Tpower_fig<-ggplot()+
  geom_line(aes(x=Tpower$trial,y=Tpower$Theta_power), colour='black', size=1.5)+
  geom_errorbar(aes(x=Tpower$trial,ymin=Tpower$Theta_power-Tpower$ci, ymax=Tpower$Theta_power+Tpower$ci), width = 0.2)+
  geom_line(aes(x=Data$trial, y=regression_Tpower$coefficients[1]+ regression_Tpower$coefficients[2]*Data$Model_power),colour='red', size=1.5,alpha=0.5)+
  #geom_line(aes(x=Data$trial, y=regression_Tpower2$coefficients[1]+ regression_Tpower2$coefficients[2]*Data$Model_power+regression_Tpower2$coefficients[3]*Data$Model_power*0.1),colour='red', size=1.5,alpha=0.3)+
  #geom_line(aes(x=Data$trial, y=regression_Tpower2$coefficients[1]+ regression_Tpower2$coefficients[2]*Data$Model_power+regression_Tpower2$coefficients[3]*Data$Model_power*0.4),colour='blue', size=1.5,alpha=0.3)+
  #geom_line(aes(x=Data$trial, y=regression_Tpower2$coefficients[1]+ regression_Tpower2$coefficients[2]*Data$Model_power+regression_Tpower2$coefficients[3]*Data$Model_power*0.7),colour='darkgreen', size=1.5,alpha=0.3)+
  geom_hline(yintercept = Tpower_baseline, colour="blue", size=1, linetype="dashed")+
  geom_vline(xintercept = 0, colour="grey", size=1, linetype="dotted")+
  theme_classic()+
  ggtitle("Theta cluster")+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  labs(y="Power (dB)")+
  labs(x="Trial to rule switch")

Dpower_fig<-ggplot()+
  geom_line(aes(x=Dpower$trial,y=Dpower$Delta_power), colour='black', size=1.5)+
  geom_errorbar(aes(x=Dpower$trial,ymin=Dpower$Delta_power-Dpower$ci, ymax=Dpower$Delta_power+Dpower$ci), width = 0.2)+
  geom_line(aes(x=Data$trial, y=regression_Dpower$coefficients[1]+ regression_Dpower$coefficients[2]*Data$Model_power),colour='red', size=1.5,alpha=0.5)+
  #geom_line(aes(x=Data$trial, y=regression_Dpower2$coefficients[1]+ regression_Dpower2$coefficients[2]*Data$Model_power+regression_Dpower2$coefficients[3]*Data$Model_power*0.1),colour='red', size=1.5,alpha=0.3)+
  #geom_line(aes(x=Data$trial, y=regression_Dpower2$coefficients[1]+ regression_Dpower2$coefficients[2]*Data$Model_power+regression_Dpower2$coefficients[3]*Data$Model_power*0.4),colour='blue', size=1.5,alpha=0.3)+
  #geom_line(aes(x=Data$trial, y=regression_Dpower2$coefficients[1]+ regression_Dpower2$coefficients[2]*Data$Model_power+regression_Dpower2$coefficients[3]*Data$Model_power*0.7),colour='darkgreen', size=1.5,alpha=0.3)+
  geom_hline(yintercept = Dpower_baseline, colour="blue", size=1, linetype="dashed")+
  geom_vline(xintercept = 0, colour="grey", size=1, linetype="dotted")+
  theme_classic()+
  ggtitle("Delta cluster")+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  labs(y="Power (dB)")+
  labs(x="Trial to rule switch")

Apower_fig<-ggplot()+
  geom_line(aes(x=Apower$trial,y=Apower$Alpha_power), colour='black', size=1.5)+
  geom_errorbar(aes(x=Apower$trial,ymin=Apower$Alpha_power-Apower$ci, ymax=Apower$Alpha_power+Apower$ci), width = 0.2)+
  geom_line(aes(x=Data$trial, y=regression_Apower$coefficients[1]+ regression_Apower$coefficients[2]*Data$Model_power),colour='red', size=1.5,alpha=0.5)+
  #geom_line(aes(x=Data$trial, y=regression_Apower2$coefficients[1]+ regression_Apower2$coefficients[2]*Data$Model_power+regression_Apower2$coefficients[3]*Data$Model_power*0.1),colour='red', size=1.5,alpha=0.3)+
  #geom_line(aes(x=Data$trial, y=regression_Apower2$coefficients[1]+ regression_Apower2$coefficients[2]*Data$Model_power+regression_Apower2$coefficients[3]*Data$Model_power*0.4),colour='blue', size=1.5,alpha=0.3)+
  #geom_line(aes(x=Data$trial, y=regression_Apower2$coefficients[1]+ regression_Apower2$coefficients[2]*Data$Model_power+regression_Apower2$coefficients[3]*Data$Model_power*0.7),colour='darkgreen', size=1.5,alpha=0.3)+
  geom_hline(yintercept = Apower_baseline, colour="blue", size=1, linetype="dashed")+
  geom_vline(xintercept = 0, colour="grey", size=1, linetype="dotted")+
  theme_classic()+
  ggtitle("Alpha cluster")+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  labs(y="Power (dB)")+
  labs(x="Trial to rule switch")

Apower_extra_fig<-ggplot()+
  geom_line(aes(x=Apower_extra$trial,y=Apower_extra$Alpha_extra), colour='black', size=1.5)+
  geom_errorbar(aes(x=Apower_extra$trial,ymin=Apower_extra$Alpha_extra-Apower_extra$ci, ymax=Apower_extra$Alpha_extra+Apower_extra$ci), width = 0.2)+
  geom_hline(yintercept = Apower_baseline, colour="blue", size=1, linetype="dashed")+
  geom_vline(xintercept = 0, colour="grey", size=1, linetype="dotted")+
  theme_classic()+
  ggtitle("Alpha to indicated switch")+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  labs(y="Power (dB)")+
  labs(x="Trial to indication")

Power_figure<-ggarrange(Tpower_fig, Dpower_fig, Apower_fig, Apower_extra_fig,  labels="AUTO",font.label=list(size=8, face="bold", family="Times"),  ncol=2, nrow = 2)

Power_figure

ggsave(filename= paste(Figure_folder, "Locked_power_regressions.tiff"), Power_figure, width=8.5, height=8.5, units="cm", dpi=300)

Theta_aic<-lm(Theta_power~1+wAIC, data=Data[Data$trial==0,])
Anova(Theta_aic)
summary(Theta_aic)
Delta_aic<-lm(Delta_power~1+wAIC, data=Data[Data$trial==0,])
Anova(Delta_aic)
summary(Delta_aic)
Alpha_extra_aic<-lm(Alpha_extra~1+wAIC, data=Data[Data$trial==0,])

summary(Alpha_extra_aic)
Alpha_aic<-lm(Alpha_power~1+wAIC, data=Data[Data$trial==1,])
Anova(Alpha_aic)
summary(Alpha_aic)

low_aic_data<-Data[Data$wAIC<.2,]
middle_aic_data<-Data[Data$wAIC>.2,]
middle_aic_data<-middle_aic_data[middle_aic_data$wAIC<.5,]
high_aic_data<-Data[Data$wAIC>.5,]

Apower_low_aic=summarySE(data=low_aic_data, measurevar="Alpha_power", groupvars="trial", conf.interval = .9984)
Apower_extra_low_aic=summarySE(data=low_aic_data, measurevar="Alpha_extra", groupvars="trial", conf.interval = .9984, na.rm = TRUE)

Apower_middle_aic=summarySE(data=middle_aic_data, measurevar="Alpha_power", groupvars="trial", conf.interval = .9984)
Apower_extra_middle_aic=summarySE(data=middle_aic_data, measurevar="Alpha_extra", groupvars="trial", conf.interval = .9984, na.rm = TRUE)

Apower_high_aic=summarySE(data=high_aic_data, measurevar="Alpha_power", groupvars="trial", conf.interval = .9984)
Apower_extra_high_aic=summarySE(data=high_aic_data, measurevar="Alpha_extra", groupvars="trial", conf.interval = .9984, na.rm = TRUE)

cols<-c("line1"="red","line2"="blue", "line3"="lightgreen")
Apower_aic_fig<-ggplot()+
  geom_line(aes(x=Apower_low_aic$trial,y=Apower_low_aic$Alpha_power, colour="line1"), size=1)+
  geom_line(aes(x=Apower_middle_aic$trial,y=Apower_middle_aic$Alpha_power, colour="line2"), size=1)+
  geom_line(aes(x=Apower_high_aic$trial,y=Apower_high_aic$Alpha_power, colour="line3"), size=1)+
  geom_hline(yintercept = Apower_baseline, colour="black", size=1, linetype="dashed")+
  geom_vline(xintercept = 0, colour="grey", size=1, linetype="dotted")+
  theme_classic()+
  scale_colour_manual(name = 'wAIC', values =cols, labels = c('0.1','0.4','0.7'), guide=guide_legend())+
  #geom_errorbar(aes(x=Apower_low_aic$trial,ymin=Apower_low_aic$Alpha_power-Apower_low_aic$ci, ymax=Apower_low_aic$Alpha_power+Apower_low_aic$ci), width = 0.2, colour="red")+
  #geom_errorbar(aes(x=Apower_middle_aic$trial,ymin=Apower_middle_aic$Alpha_power-Apower_middle_aic$ci, ymax=Apower_middle_aic$Alpha_power+Apower_middle_aic$ci), width = 0.2, colour="blue")+
  #geom_errorbar(aes(x=Apower_high_aic$trial,ymin=Apower_high_aic$Alpha_power-Apower_high_aic$ci, ymax=Apower_high_aic$Alpha_power+Apower_high_aic$ci), width = 0.2, colour="darkgreen")+
  ggtitle("Alpha cluster")+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  labs(y="Power (dB)")+
  labs(x="Trial to rule switch")

Apower_aic_extra_fig<-ggplot()+
  geom_line(aes(x=Apower_extra_low_aic$trial,y=Apower_extra_low_aic$Alpha_extra, colour='line1'), size=1)+
  #geom_errorbar(aes(x=Apower_extra_low_aic$trial,ymin=Apower_extra_low_aic$Alpha_extra-Apower_extra_low_aic$ci, ymax=Apower_extra_low_aic$Alpha_extra+Apower_extra_low_aic$ci), width = 0.2, colour="red")+
  geom_line(aes(x=Apower_middle_aic$trial,y=Apower_extra_middle_aic$Alpha_extra, colour='line2'), size=1)+
  #geom_errorbar(aes(x=Apower_extra_middle_aic$trial,ymin=Apower_extra_middle_aic$Alpha_extra-Apower_extra_middle_aic$ci, ymax=Apower_extra_middle_aic$Alpha_extra+Apower_extra_middle_aic$ci), width = 0.2, colour="blue")+
  geom_line(aes(x=Apower_extra_high_aic$trial,y=Apower_extra_high_aic$Alpha_extra, colour='line3'), size=1)+
  #geom_errorbar(aes(x=Apower_extra_high_aic$trial,ymin=Apower_extra_high_aic$Alpha_extra-Apower_extra_high_aic$ci, ymax=Apower_extra_high_aic$Alpha_extra+Apower_extra_high_aic$ci), width = 0.2, colour="darkgreen")+
  scale_colour_manual(name = 'wAIC', values =cols, labels = c('0.1','0.4','0.7'), guide=guide_legend())+
  geom_hline(yintercept = Apower_baseline, colour="black", size=1, linetype="dashed")+
  geom_vline(xintercept = 0, colour="grey", size=1, linetype="dotted")+
  theme_classic()+
  ggtitle("Alpha to indicated switch")+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  labs(y="Power (dB)")+
  labs(x="Trial to indication")

AIC_figure<-ggarrange( Apower_aic_fig, Apower_aic_extra_fig,  labels="AUTO",font.label=list(size=8, face="bold", family="Times"),  ncol=2, nrow = 1, common.legend = TRUE)

AIC_figure

ggsave(filename= paste(Figure_folder, "Locked_power_extra.tiff"), AIC_figure, width=8.5, height=4, units="cm", dpi=300)


