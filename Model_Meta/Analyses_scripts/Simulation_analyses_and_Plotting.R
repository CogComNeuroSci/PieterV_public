#clear console, environment and plots
cat("\014")
rm(list = ls())

library(ggplot2)
library(ggpubr)
library(Rmisc)
library(reshape2)
library(wesanderson)
library(cowplot)
library(scales)
library(lmerTest) 
library(car)

# setting variables for models
Prew<- c(1, .7)
Vol<- c("Stable", "Reversal", "Stepwise")
Models <- c("RW", "Mod" , "ALR", "ALRMod", "HigherMod", "Full")
Models2 <- c("RW", "ALR" , "Mod", "ALRMod", "HigherMod", "Full")
Models3<- c("RW", "ALR" , "Mod", "ALR_mod", "Higher_mod", "Full")
new_modelnames <- c("Flat", "ALR", "Hierarchical", "Hierarchical_ALR", "Hierarchical_learning", "Full")
nModels = length(Models)
resultcolumns <-c("Simulation", "Prew", "Structure", "Model", "ALR", "Mod", "High", "CRew", "Accuracy", "Lr", "Temp", "Hybrid", "Cum", "Hlr")
simulations = 50

#setting variables for datasets
datasets <-c("Huycke", "Xia", "Goris/Stable", "Online","Goris/Volatile", "Liu", "Verbeke", "Mukherjee", "Cohen", "Hein")
Prew_ds<- c(100, 80, 70, 100, 90, 85, 80, 70, 66, 74)
Vol_ds<- c("Stable", "Stable", "Stable", "Reversal","Reversal", "Reversal", "Reversal", "Reversal", "Stepwise", "Stepwise")
ds_labels <-c()
for (x in 1:length(datasets)){
  ds_labels[x]<-paste(Vol_ds[x] , "_", Prew_ds[x], "%",sep ="")
}

#set directory
resultsfolder = "/Users/pieter/Desktop/Model_study/Optimize_models/"
setwd(resultsfolder)

#Making empty dataframe to store data
df = data.frame(matrix(nrow = simulations*nModels*length(Vol)*length(Prew), ncol = length(resultcolumns))) 
colnames(df) = resultcolumns
wid = 0

#Read in and combine data for model simulations
for (M in 1:nModels){
  mid = 100*(M-1)
  mname = Models[M]
  #This file contains the optimal parameters
  Outputfile = paste("Optimization_output_", mname, ".csv", sep = "")
  optdat <- read.delim(Outputfile, header = TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)
  
  for (V in Vol){
    for (P in Prew){
      for (s in 1:simulations){
        wid = wid+1
        df$Simulation[wid] <- s
        df$Prew[wid] <- P
        df$Structure[wid] <- V
        df$Model[wid] <- mname
        if ((M==2) | (M ==4) | (M==6)){
          df$ALR[wid] <- 1
        }else{
          df$ALR[wid] <- 0
        }
        if (M >2){
          df$Mod[wid] <- 1
        }else{
          df$Mod[wid] <- 0
        }
        if (M >4){
          df$High[wid] <- 1
        }else{
          df$High[wid] <- 0
        }
        
        id = mid + (s-1)
        #This is the file with actual simulated data
        Data<-read.delim(paste("Data_", V, "_", P, "_Simulation", id,".csv", sep = ""), header = TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)
        df$CRew[wid] <-sum(Data$Reward)
        df$Accuracy[wid] <- mean(Data$Response == Data$CorResp)
        
        df$Lr[wid]<-optdat[optdat$Structure==V & optdat$Prew ==P,]$Lr
        df$Temp[wid]<-optdat[optdat$Structure==V & optdat$Prew ==P,]$Temp
        df$Hybrid[wid]<-optdat[optdat$Structure==V & optdat$Prew ==P,]$Hybrid
        df$Cum[wid]<-optdat[optdat$Structure==V & optdat$Prew ==P,]$Cumulation
        df$Hlr[wid]<-optdat[optdat$Structure==V & optdat$Prew ==P,]$Hlr
      }
    }
  }
}

#For Stepwise, it is two times the same data so we remove one set
df <- df[!(df$Structure =="Stepwise" & df$Prew ==1),]

#Defining labels for the environments and transforming accuracy to percentage
df$ds<-paste(df$Structure, "_", df$Prew*100, "%", sep="")
df$Accuracy <- df$Accuracy*100

#Aggregating accuracy for model simulations
Summary_accuracy <- summarySE(data = df, "Accuracy", groupvars = c("Model", "ds", "Structure"), conf.interval = 0.95)
Summary_accuracy$Model <- factor(Summary_accuracy$Model, levels=Models2)
Summary_accuracy$ds <- factor(Summary_accuracy$ds, levels=c("Stable_100%", "Stable_70%", "Reversal_100%", "Reversal_70%", "Stepwise_70%"))

#Computing the weighted measure of accuracy
Summary_accuracy$maxAcc<-0
Summary_accuracy$deltaAcc<-0
Summary_accuracy$eAcc<-0
Summary_accuracy$wAcc<-0

for (i in df$ds){
  Summary_accuracy[Summary_accuracy$ds == i,]$maxAcc <- max(Summary_accuracy[Summary_accuracy$ds == i,]$Accuracy)
  Summary_accuracy[Summary_accuracy$ds == i,]$deltaAcc <- Summary_accuracy[Summary_accuracy$ds == i,]$maxAcc- Summary_accuracy[Summary_accuracy$ds == i,]$Accuracy
  Summary_accuracy[Summary_accuracy$ds == i,]$eAcc <- exp((-1/2)*Summary_accuracy[Summary_accuracy$ds == i,]$deltaAcc)
  Summary_accuracy[Summary_accuracy$ds == i,]$wAcc <- Summary_accuracy[Summary_accuracy$ds == i,]$eAcc /sum(Summary_accuracy[Summary_accuracy$ds == i,]$eAcc)
}

#Color palette for plots
pal <- wes_palette("Zissou1", 100, type = "continuous")

#Divide data over environments
Stable_sims <- Summary_accuracy[Summary_accuracy$Structure=="Stable",]
Reversal_sims <- Summary_accuracy[Summary_accuracy$Structure=="Reversal",]
Stepwise_sims <- Summary_accuracy[Summary_accuracy$Structure=="Stepwise",]

#Make plots
Stable_accsims<-ggplot(data = Stable_sims, aes(x=Model, y=ds, fill = wAcc))+
  #geom_contour_fill()+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(0,0.5),oob = squish)+
  theme_classic()+
  scale_x_discrete(labels = c("","","","","",""))+
  theme(text = element_text(size=8), plot.title = element_text(size = 10, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 67.5, hjust=1), legend.title = element_text(size = 8), 
        legend.key.size = unit(.33, 'cm'), legend.position = "none", axis.text.y.right = element_blank())+
  ggtitle(expression(bold(atop("Model performance", "as weighted P(a"["optimal"]*")"))))+
  labs(x="")+
  labs(y="")+
  labs(fill="Measure")

Reversal_accsims<-ggplot(data = Reversal_sims, aes(x=Model, y=ds, fill = wAcc))+
  #geom_contour_fill()+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(0,0.5),oob = squish)+
  theme_classic()+
  scale_x_discrete(labels = c("","","","","",""))+
  theme(text = element_text(size=8), plot.title = element_text(size = 10, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 67.5, hjust=1), legend.title = element_text(size = 8), 
        legend.key.size = unit(.33, 'cm'), legend.position = "left", axis.text.y.right = element_blank())+
  ggtitle("")+
  labs(x="")+
  labs(y="Environments")+
  labs(fill="Measure")

Stepwise_accsims<-ggplot(data = Stepwise_sims, aes(x=Model, y=ds, fill = wAcc))+
  #geom_contour_fill()+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(0,0.5),oob = squish)+
  theme_classic()+
  scale_x_discrete(labels = new_modelnames)+
  theme(text = element_text(size=8), plot.title = element_text(size = 10, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 67.5, hjust=1), legend.title = element_text(size = 8), 
        legend.key.size = unit(.33, 'cm'), legend.position = "none", axis.text.y.right = element_blank())+
  ggtitle("")+
  labs(x="Model")+
  labs(y="")+
  labs(fill="Measure")

#This is a combined plot
Accuracy_sims<-ggplot(data = Summary_accuracy, aes(x=Model, y=ds, fill = wAcc))+
  #geom_contour_fill()+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(0,0.5),oob = squish)+
  theme_classic()+
  scale_x_discrete(labels = new_modelnames)+
  theme(text = element_text(size=8), plot.title = element_text(size = 10, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 67.5, hjust=1), legend.title = element_text(size = 8), 
        legend.key.size = unit(.33, 'cm'), legend.position = "none", axis.text.y.right = element_blank())+
  ggtitle(expression(bold(atop("Model performance", "as weighted P(a"["optimal"]*")"))))+
  labs(x="Model")+
  labs(y="Environments")+
  labs(fill="Measure")

#Also read in the data from model fitting
setwd("/Users/pieter/Desktop/Model_Study/Fitted_data/")
Data<-read.csv(" all_data.csv", header = TRUE)

setwd("/Users/pieter/Desktop/Model_Study/Analyses_results/")
#Make sure that variables are coded correctly
Data$Reward<-as.numeric(Data$Reward)
Data$Mod<-as.factor(Data$Mod)
Data$ALR<-as.factor(Data$ALR)
Data$High<-as.factor(Data$High)
Data$Subject<-as.factor(Data$Subject)

#Extract data for LL, AIC and BIC. In the paper we use AIC but model evidence did not differ that much (qualitatively) for AIC or BIC
Data_LL <- Data[Data$Measure=="LL",]
Data_AIC <- Data[Data$Measure=="AIC",]
Data_BIC <- Data[Data$Measure=="BIC",]

#Aggregate data for AIC
AIC_aggregate<-aggregate(Data_AIC$Outcome, by = list(Data_AIC$Dataset, Data_AIC$Model), FUN = mean)
colnames(AIC_aggregate) <-c("Dataset", "Model", "Value")
AIC_aggregate$Model <- factor(AIC_aggregate$Model, levels=Models3)
AIC_aggregate$Dataset <- factor(AIC_aggregate$Dataset, levels=datasets)

#Divide data per environment
Stable_AIC<-rbind(AIC_aggregate[(AIC_aggregate$Dataset == "Huycke"), ], AIC_aggregate[(AIC_aggregate$Dataset == "Xia"), ], AIC_aggregate[(AIC_aggregate$Dataset == "Goris/Stable"), ])
Reversal_AIC<-rbind(AIC_aggregate[(AIC_aggregate$Dataset == "Online"), ], AIC_aggregate[(AIC_aggregate$Dataset == "Goris/Volatile"), ], AIC_aggregate[(AIC_aggregate$Dataset == "Liu"), ], AIC_aggregate[(AIC_aggregate$Dataset == "Verbeke"), ], AIC_aggregate[(AIC_aggregate$Dataset == "Mukherjee"), ])
Stepwise_AIC<-rbind(AIC_aggregate[(AIC_aggregate$Dataset == "Hein"), ], AIC_aggregate[(AIC_aggregate$Dataset == "Cohen"), ])

#Make plots
AIC_raster_stable<-ggplot(data = Stable_AIC, aes(x=Model, y=as.numeric(Dataset), fill=Value))+
  #geom_contour_fill()+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(0,0.5), oob=squish)+
  scale_x_discrete(labels = c("","","","","",""))+
  theme_classic()+
  scale_y_continuous(breaks = 1:3, labels= datasets[1:3], sec.axis = sec_axis(~ ., breaks = 1:length(datasets), labels = ds_labels))+
  theme(text = element_text(size=8), plot.title = element_text(size = 10, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 67.5, hjust=1), legend.title = element_text(size = 8), 
        legend.key.size = unit(.33, 'cm'), legend.position = "none" )+
  ggtitle("Model fit\n\n as weighted AIC")+
  labs(x="")+
  labs(y="")+
  labs(fill="Measure")

AIC_raster_reversal<-ggplot(data = Reversal_AIC, aes(x=Model, y=as.numeric(Dataset), fill=Value))+
  #geom_contour_fill()+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(0,0.5), oob=squish)+
  scale_x_discrete(labels = c("","","","","",""))+
  theme_classic()+
  scale_y_continuous(breaks = 4:8, labels= datasets[4:8], sec.axis = sec_axis(~ ., breaks = 1:length(datasets), labels = ds_labels))+
  theme(text = element_text(size=8), plot.title = element_text(size = 10, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 67.5, hjust=1), legend.title = element_text(size = 8), 
        legend.key.size = unit(.33, 'cm'), legend.position = "none" )+
  ggtitle("")+
  labs(x="")+
  labs(y="Datasets")+
  labs(fill="Measure")

AIC_raster_stepwise<-ggplot(data = Stepwise_AIC, aes(x=Model, y=as.numeric(Dataset), fill=Value))+
  #geom_contour_fill()+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(0,0.5), oob=squish)+
  scale_x_discrete(labels = new_modelnames)+
  theme_classic()+
  scale_y_continuous(breaks = 9:10, labels= datasets[9:10], sec.axis = sec_axis(~ ., breaks = 1:length(datasets), labels = ds_labels))+
  theme(text = element_text(size=8), plot.title = element_text(size = 10, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 67.5, hjust=1), legend.title = element_text(size = 8), 
        legend.key.size = unit(.33, 'cm'), legend.position = "none" )+
  ggtitle("")+
  labs(x="Model")+
  labs(y="")+
  labs(fill="Measure")

#This is a combined plot
AIC_raster_full<-ggplot(data = AIC_aggregate, aes(x=Model, y=as.numeric(Dataset), fill=Value))+
  #geom_contour_fill()+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(0,0.5), oob=squish)+
  scale_x_discrete(labels = new_modelnames)+
  theme_classic()+
  scale_y_continuous(breaks = 1:length(datasets), labels= datasets, sec.axis = sec_axis(~ ., breaks = 1:length(datasets), labels = ds_labels))+
  theme(text = element_text(size=8), plot.title = element_text(size = 10, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 67.5, hjust=1), legend.title = element_text(size = 8), 
        legend.key.size = unit(.33, 'cm'), legend.position = "none" )+
  ggtitle("Model fit\n as weighted AIC")+
  labs(x="Model")+
  labs(y="Datasets")+
  labs(fill="Measure")

#Combine plots and save
Model_grids<-ggdraw() +
  draw_plot(Stepwise_accsims, x = 0.13, y = 0, width = .385, height = .39) +
  draw_plot(Reversal_accsims, x = 0, y = 0.425, width = .53, height = .23) +
  draw_plot(Stable_accsims, x = 0.14, y = 0.675, width = .395, height = .305) +
  draw_plot(AIC_raster_stepwise, x = .59, y = .0, width = .405, height = .43) +
  draw_plot(AIC_raster_reversal, x = .55, y = .36, width = .45, height = .385) +
  draw_plot(AIC_raster_stable, x = .555, y = .66, width = .435, height = .34) +
  draw_plot_label(label = c("A","B"), x=c(0.15,0.6),y=c(.975,.975), size = 10,fontface="bold")

ggsave("Grid_models.jpg", Model_grids, device = "jpeg", width = 15, height = 10, units = "cm", dpi = 300)

#Adding some variables related to model features in order to the accuracy data of model simulations so we can do the regression
Summary_accuracy$Mod<-0
Summary_accuracy$ALR<-0
Summary_accuracy$High<-0

Summary_accuracy[Summary_accuracy$Model=="Mod",]$Mod<-1

Summary_accuracy[Summary_accuracy$Model=="ALR",]$ALR<-1

Summary_accuracy[Summary_accuracy$Model=="HigherMod",]$Mod<-1
Summary_accuracy[Summary_accuracy$Model=="HigherMod",]$High<-1

Summary_accuracy[Summary_accuracy$Model=="ALRMod",]$Mod<-1
Summary_accuracy[Summary_accuracy$Model=="ALRMod",]$ALR<-1

Summary_accuracy[Summary_accuracy$Model=="Full",]$Mod<-1
Summary_accuracy[Summary_accuracy$Model=="Full",]$ALR<-1
Summary_accuracy[Summary_accuracy$Model=="Full",]$High<-1

#Regression on simulated data
feature_regression <-aov(wAcc ~  Structure*Mod*ALR*High, Summary_accuracy)
summary(feature_regression)

#Summarize data per model feature and environment
IEVolMod <- summarySE(data = Summary_accuracy, "wAcc", groupvars = c("Mod", "Structure"), conf.interval = 0.95)
IEVolMod$Mod <- as.factor(IEVolMod$Mod)
IEVolMod$Structure <- factor(IEVolMod$Structure, levels=c("Stable", "Reversal", "Stepwise"))

IEVolALR <- summarySE(data = Summary_accuracy, "wAcc", groupvars = c("ALR", "Structure"), conf.interval = 0.95)
IEVolALR$ALR <- as.factor(IEVolALR$ALR)
IEVolALR$Structure <- factor(IEVolMod$Structure, levels=c("Stable", "Reversal", "Stepwise"))

IEVolHigh <- summarySE(data = Summary_accuracy, "wAcc", groupvars = c("High", "Structure"), conf.interval = 0.95)
IEVolHigh$High <- as.factor(IEVolHigh$High)
IEVolHigh$Structure <- factor(IEVolMod$Structure, levels=c("Stable", "Reversal", "Stepwise"))

#Make plots
VolMod_plot <- ggplot(IEVolMod, aes(y=wAcc, x = Structure, colour = Mod, group = Mod))+ 
  geom_point(size = 2,position = position_dodge2(.2))+
  ggtitle("")+
  coord_cartesian(ylim = c(0, 0.6))+
  ylab("Hierarchical architecture")+
  xlab("")+
  scale_colour_discrete(name = "Feature present", labels=c("0" = "No", "1" = "Yes"))+
  theme_minimal()+
  theme(text = element_text(size=8),plot.title = element_text(size = 8, face = "bold", hjust=0.5), axis.title.y=element_text(face="italic"), axis.text.x = element_text(angle = 45, hjust=0.5))

VolALR_plot <- ggplot(IEVolALR, aes(y=wAcc, x = Structure, colour = ALR, group = ALR))+ 
  geom_point(size = 2, position = position_dodge2(.2))+
  ggtitle(expression(bold(atop("Model performance", "as weighted P(a"["optimal"]*")"))))+
  coord_cartesian(ylim = c(0, 0.6))+
  ylab("Adaptive learning rate")+
  xlab("")+
  scale_colour_discrete(name = "Feature present", labels=c("0" = "No", "1" = "Yes"))+
  theme_minimal()+
  theme(text = element_text(size=8),plot.title = element_text(size = 8, face = "bold", hjust=0.5), axis.title.y=element_text(face="italic"), axis.text.x = element_text(angle = 45, hjust=0.5))

VolHigh_plot <- ggplot(IEVolHigh, aes(y=wAcc, x = Structure, colour = High, group = High))+ 
  geom_point(size = 2, position = position_dodge2(.2))+
  ggtitle("")+
  coord_cartesian(ylim = c(0, 0.6))+
  ylab("Hierarchical learning")+
  xlab("Environments")+
  scale_colour_discrete(name = "Feature present", labels=c("0" = "No", "1" = "Yes"))+
  theme_minimal()+
  theme(text = element_text(size=8),plot.title = element_text(size = 8, face = "bold", hjust=0.5), axis.title.y=element_text(face="italic"), axis.text.x = element_text(angle = 45, hjust=0.5))

#Now, we do this regression for model fit
feature_AIC <-lmer(Outcome ~ (1|Dataset) + Volatility*Mod*ALR*High, Data_AIC)
summary(feature_AIC)
Anova(feature_AIC)

#Summarize data per model feature and environment
AIC_IEVolMod <- summarySE(data = Data_AIC, "Outcome", groupvars = c("Mod", "Volatility"), conf.interval = 0.95)
AIC_IEVolMod$Volatility <- factor(AIC_IEVolMod$Volatility, levels=c("Stable", "Reversal", "Stepwise"))
AIC_IEVolALR <- summarySE(data = Data_AIC, "Outcome", groupvars = c("ALR", "Volatility"), conf.interval = 0.95)
AIC_IEVolALR$Volatility <- factor(AIC_IEVolALR$Volatility, levels=c("Stable", "Reversal", "Stepwise"))
AIC_IEVolHigh <- summarySE(data = Data_AIC, "Outcome", groupvars = c("High", "Volatility"), conf.interval = 0.95)
AIC_IEVolHigh$Volatility <- factor(AIC_IEVolHigh$Volatility, levels=c("Stable", "Reversal", "Stepwise"))

#Make plots
VolMod_plotAIC <- ggplot(AIC_IEVolMod, aes(y=Outcome, x = Volatility, colour = Mod, group = Mod))+ 
  geom_point(size = 2, position = position_dodge2(.2))+
  geom_errorbar(aes(ymin=Outcome-ci, ymax = Outcome+ci), width = .1, size =1, position = position_dodge(.2))+
  ggtitle("")+
  coord_cartesian(ylim = c(0, 0.35))+
  ylab("")+
  xlab("")+
  scale_colour_discrete(name = "Feature present", labels=c("0" = "No", "1" = "Yes"))+
  theme_minimal()+
  theme(text = element_text(size=8),plot.title = element_text(size = 8, face = "italic", hjust=0.5, family="Times"), axis.text.x = element_text(angle = 45, hjust=0.5))

VolALR_plotAIC <- ggplot(AIC_IEVolALR, aes(y=Outcome, x = Volatility, colour = ALR, group = ALR))+ 
  geom_point(size = 2, position = position_dodge2(.2))+
  geom_errorbar(aes(ymin=Outcome-ci, ymax = Outcome+ci), width = .1, size =1, position = position_dodge(.2))+
  ggtitle("Model fit\n\n as weighted AIC")+
  coord_cartesian(ylim = c(0, 0.35))+
  ylab("")+
  xlab("")+
  scale_colour_discrete(name = "Feature present", labels=c("0" = "No", "1" = "Yes"))+
  theme_minimal()+
  theme(text = element_text(size=8),plot.title = element_text(size = 8, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 45, hjust=0.5))

VolHigh_plotAIC <- ggplot(AIC_IEVolHigh, aes(y=Outcome, x = Volatility, colour = High, group = High))+ 
  geom_point(size = 2, position = position_dodge2(.2))+
  geom_errorbar(aes(ymin=Outcome-ci, ymax = Outcome+ci), width = .1, size =1, position = position_dodge(.2))+
  ylab("")+
  coord_cartesian(ylim = c(0, 0.35))+
  ylab("")+
  xlab("Environments")+
  scale_colour_discrete(name = "Feature present", labels=c("0" = "No", "1" = "Yes"))+
  theme_minimal()+
  theme(text = element_text(size=8),plot.title = element_text(size = 8, face = "italic", hjust=0.5, family="Times"), axis.text.x = element_text(angle = 45, hjust=0.5))

#Combine plots and save
Feature_plot <- ggarrange(VolALR_plot, VolALR_plotAIC, VolMod_plot, VolMod_plotAIC, VolHigh_plot, VolHigh_plotAIC, ncol = 2, nrow = 3, common.legend = TRUE, heights=c(1,1), widths=c(1, 1, 1), labels = c("A", "B", "C","D", "E", "F"),font.label = list(size = 10))
ggsave("Feature_Volatility.jpg", Feature_plot, device = "jpeg", width = 12, height = 15, units = "cm", dpi = 300)

#Now, make plots for model parameters (optimal in terms of reward accumulation)
#This plot is shown in the supplementary materials

#Flat model
Data_RW <- df[df$Model=="RW",]
RW_aggregate<-aggregate(cbind(Lr, Temp)~ds, FUN = mean, data = Data_RW)
RW_aggregate$ds <- factor(RW_aggregate$ds, levels=c("Stable_100%", "Stable_70%", "Reversal_100%", "Reversal_70%", "Stepwise_70%"))
RW_aggregate <- melt(RW_aggregate, id.vars = c("ds"), variable.name = "Parameter")

RW_raster<-ggplot(data = RW_aggregate, aes(y=ds, x=Parameter, fill = value))+
  #geom_contour_fill()+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(0,1))+
  theme_classic()+
  theme(text = element_text(size=8), plot.title = element_text(size = 8, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1), legend.title = element_text(size = 8), 
        legend.key.size = unit(.33, 'cm'), legend.position = "left", axis.text.y.right = element_blank())+
  ggtitle("RW model")+
  labs(x="Parameter")+
  labs(y="Environments")+
  labs(fill="Optimised\nparameter values")

#ALR model
Data_ALR <- df[df$Model=="ALR",]
ALR_aggregate<-aggregate(cbind(Lr, Temp, Hybrid)~ds, FUN = mean, data = Data_ALR)
ALR_aggregate$ds <- factor(ALR_aggregate$ds, levels=c("Stable_100%", "Stable_70%", "Reversal_100%", "Reversal_70%", "Stepwise_70%"))
ALR_aggregate <- melt(ALR_aggregate, id.vars = c("ds"), variable.name = "Parameter")

ALR_raster<-ggplot(data = ALR_aggregate, aes(y=ds, x=Parameter, fill = value))+
  #geom_contour_fill()+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(0,1))+
  theme_classic()+
  theme(text = element_text(size=8), plot.title = element_text(size = 8, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1), legend.title = element_text(size = 8), 
        legend.key.size = unit(.33, 'cm'), legend.position = "none", axis.text.y.left = element_blank())+
  ggtitle("ALR model")+
  labs(x="Parameter")+
  labs(y="")+
  labs(fill="Optimised\nparameter values")

#Sets model
Data_Mod <- df[df$Model=="Mod",]
Mod_aggregate<-aggregate(cbind(Lr, Temp, Cum)~ds, FUN = mean, data = Data_Mod)
Mod_aggregate$ds <- factor(Mod_aggregate$ds, levels=c("Stable_100%", "Stable_70%", "Reversal_100%", "Reversal_70%", "Stepwise_70%"))
Mod_aggregate <- melt(Mod_aggregate, id.vars = c("ds"), variable.name = "Parameter")

Mod_raster<-ggplot(data = Mod_aggregate, aes(y=ds, x=Parameter, fill = value))+
  #geom_contour_fill()+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(0,1))+
  theme_classic()+
  theme(text = element_text(size=8), plot.title = element_text(size = 8, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1), legend.title = element_text(size = 8), 
        legend.key.size = unit(.33, 'cm'), legend.position = "none", axis.text.y.left = element_blank())+
  ggtitle("Hierarchical model")+
  labs(x="Parameter")+
  labs(y="")+
  labs(fill="Optimised\nparameter values")

#Hierarchical_ALR model
Data_ALRMod <- df[df$Model=="ALRMod",]
ALRMod_aggregate<-aggregate(cbind(Lr, Temp, Hybrid, Cum)~ds, FUN = mean, data = Data_ALRMod)
ALRMod_aggregate$ds <- factor(ALRMod_aggregate$ds, levels=c("Stable_100%", "Stable_70%", "Reversal_100%", "Reversal_70%", "Stepwise_70%"))
ALRMod_aggregate <- melt(ALRMod_aggregate, id.vars = c("ds"), variable.name = "Parameter")

ALRMod_raster<-ggplot(data = ALRMod_aggregate, aes(y=ds, x=Parameter, fill = value))+
  #geom_contour_fill()+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(0,1))+
  theme_classic()+
  theme(text = element_text(size=8), plot.title = element_text(size = 8, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1), legend.title = element_text(size = 8), 
        legend.key.size = unit(.33, 'cm'), legend.position = "none", axis.text.y.right = element_blank())+
  ggtitle("Hierarchical_ALR model")+
  labs(x="Parameter")+
  labs(y="Environments")+
  labs(fill="Optimised\nparameter values")

#Hierarchical_Learning model
Data_HigherMod <- df[df$Model=="HigherMod",]
HigherMod_aggregate<-aggregate(cbind(Lr, Temp, Cum, Hlr)~ds, FUN = mean, data = Data_HigherMod)
HigherMod_aggregate$ds <- factor(HigherMod_aggregate$ds, levels=c("Stable_100%", "Stable_70%", "Reversal_100%", "Reversal_70%", "Stepwise_70%"))
HigherMod_aggregate <- melt(HigherMod_aggregate, id.vars = c("ds"), variable.name = "Parameter")

HigherMod_raster<-ggplot(data = HigherMod_aggregate, aes(y=ds, x=Parameter, fill = value))+
  #geom_contour_fill()+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(0,1))+
  theme_classic()+
  theme(text = element_text(size=8), plot.title = element_text(size = 8, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1), legend.title = element_text(size = 8), 
        legend.key.size = unit(.33, 'cm'), legend.position = "none", axis.text.y.left = element_blank())+
  ggtitle("Hierarchical_learning model")+
  labs(x="Parameter")+
  labs(y="")+
  labs(fill="Optimised\nparameter values")

#Full model
Data_Full <- df[df$Model=="Full",]
Full_aggregate<-aggregate(cbind(Lr, Temp, Hybrid, Cum, Hlr)~ds, FUN = mean, data = Data_Full)
Full_aggregate$ds <- factor(Full_aggregate$ds, levels=c("Stable_100%", "Stable_70%", "Reversal_100%", "Reversal_70%", "Stepwise_70%"))
Full_aggregate <- melt(Full_aggregate, id.vars = c("ds"), variable.name = "Parameter")

Full_raster<-ggplot(data = Full_aggregate, aes(y=ds, x=Parameter, fill = value))+
  #geom_contour_fill()+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(0,1))+
  theme_classic()+
  theme(text = element_text(size=8), plot.title = element_text(size = 8, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1), legend.title = element_text(size = 8), 
        legend.key.size = unit(.33, 'cm'), legend.position = "none", axis.text.y.left = element_blank())+
  ggtitle("Full model")+
  labs(x="Parameter")+
  labs(y="")+
  labs(fill="Optimised\nparameter values")

#Combine plots and save
Parameter_grids<-ggdraw() +
  draw_plot(RW_raster, x = 0, y = .5, width = .5, height = .45) +
  draw_plot(ALR_raster, x = .55, y = .5, width = .2, height = .45) +
  draw_plot(Mod_raster, x = .8, y = .5, width = .2, height = .45) +
  draw_plot(ALRMod_raster, x = 0, y = 0, width = .4, height = .45) +
  draw_plot(HigherMod_raster, x = .425, y = 0, width = .275, height = .45) +
  draw_plot(Full_raster, x = .725, y = 0, width = .275, height = .45) #+
#draw_plot_label(label = c("A","B","C","D"), x=c(0,0,0.275,0),y=c(1,0.66,0.66,0.25), size = 12,fontface="bold", family="Times")

Parameter_grids
ggsave("Parameter_optim.jpg", Parameter_grids, device = "jpeg", width = 15, height = 10, units = "cm", dpi = 300)

#Now, we do the same for the fitted parameters

#Flat model
Data_RW <- Data_AIC[Data_AIC$Model=="RW",]
Data_RW$Lr <-scale(Data_RW$Lr)
Data_RW$Temp <-scale(Data_RW$Temp)
RW_aggregate_2<-aggregate(cbind(Lr, Temp)~Dataset, FUN = mean, data = Data_RW)
colnames(RW_aggregate_2)<-c("Dataset", "Lr", "Temp")
RW_aggregate_2 <- melt(RW_aggregate_2, id.vars = c("Dataset"), variable.name = "Parameter")
RW_aggregate_2$Dataset <- factor(RW_aggregate_2$Dataset, levels=datasets)

RW_raster_2<-ggplot(data = RW_aggregate_2, aes(y=as.numeric(Dataset), x=Parameter, fill = value))+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(-1,1), oob=squish)+
  theme_classic()+
  scale_y_continuous(breaks = 1:length(datasets), labels= datasets, sec.axis = sec_axis(~ ., breaks = 1:length(datasets), labels = ds_labels))+
  theme(text = element_text(size=8), plot.title = element_text(size = 8, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1), legend.title = element_text(size = 8), 
        legend.key.size = unit(.33, 'cm'), legend.position = "left", axis.text.y.right = element_blank())+
  ggtitle("RW model")+
  labs(x="Parameter")+
  labs(y="Datasets")+
  labs(fill="Z-scored\nestimations")

#ALR model
Data_ALR <- Data_AIC[Data_AIC$Model=="ALR",]
Data_ALR$Lr <-scale(Data_ALR$Lr)
Data_ALR$Temp <-scale(Data_ALR$Temp)
Data_ALR$Hybrid <-scale(Data_ALR$Hybrid)
ALR_aggregate_2<-aggregate(cbind(Lr, Temp, Hybrid)~Dataset, FUN = mean, data = Data_ALR)
colnames(ALR_aggregate_2)<-c("Dataset", "Lr", "Temp", "Hybrid")
ALR_aggregate_2 <- melt(ALR_aggregate_2, id.vars = c("Dataset"), variable.name = "Parameter")
ALR_aggregate_2$Dataset <- factor(ALR_aggregate_2$Dataset, levels=datasets)

ALR_raster_2<-ggplot(data = ALR_aggregate_2, aes(y=as.numeric(Dataset), x=Parameter, fill = value))+
  #geom_contour_fill()+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(-1,1), oob=squish)+
  theme_classic()+
  scale_y_continuous(breaks = 1:length(datasets), labels= datasets, sec.axis = sec_axis(~ ., breaks = 1:length(datasets), labels = ds_labels))+
  theme(text = element_text(size=8), plot.title = element_text(size = 8, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1), legend.title = element_text(size = 8), 
        legend.key.size = unit(.33, 'cm'), legend.position = "none",axis.text.y.right = element_blank(), axis.text.y.left = element_blank())+
  ggtitle("ALR model")+
  labs(x="Parameter")+
  labs(y="")+
  labs(fill="Z-scored estimations")

#Hierarchical model
Data_Mod <- Data_AIC[Data_AIC$Model=="Mod",]
Data_Mod$Lr <-scale(Data_Mod$Lr)
Data_Mod$Temp <-scale(Data_Mod$Temp)
Data_Mod$Cum <-scale(Data_Mod$Cum)
Mod_aggregate_2<-aggregate(cbind(Lr, Temp, Cum)~Dataset, FUN = mean, data = Data_Mod)
colnames(Mod_aggregate_2)<-c("Dataset", "Lr", "Temp", "Cum")
Mod_aggregate_2 <- melt(Mod_aggregate_2, id.vars = c("Dataset"), variable.name = "Parameter")
Mod_aggregate_2$Dataset <- factor(Mod_aggregate_2$Dataset, levels=datasets)

Mod_raster_2<-ggplot(data = Mod_aggregate_2, aes(y=as.numeric(Dataset), x=Parameter, fill = value))+
  #geom_contour_fill()+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(-1,1), oob=squish)+
  theme_classic()+
  scale_y_continuous(breaks = 1:length(datasets), labels= datasets, sec.axis = sec_axis(~ ., breaks = 1:length(datasets), labels = ds_labels))+
  theme(text = element_text(size=8), plot.title = element_text(size = 8, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1), legend.title = element_text(size = 8), 
        legend.key.size = unit(.33, 'cm'), legend.position = "none", axis.text.y.left = element_blank())+
  ggtitle("Hierarchical model")+
  labs(x="Parameter")+
  labs(y="")+
  labs(fill="Z-scored estimations")

#Hierarchical_ALR model
Data_ALR_Mod <- Data_AIC[Data_AIC$Model=="ALR_mod",]
Data_ALR_Mod$Lr <-scale(Data_ALR_Mod$Lr)
Data_ALR_Mod$Temp <-scale(Data_ALR_Mod$Temp)
Data_ALR_Mod$Hybrid <-scale(Data_ALR_Mod$Hybrid)
Data_ALR_Mod$Cum <-scale(Data_ALR_Mod$Cum)
ALR_Mod_aggregate_2<-aggregate(cbind(Lr, Temp, Hybrid, Cum)~Dataset, FUN = mean, data = Data_ALR_Mod)
colnames(ALR_Mod_aggregate_2)<-c("Dataset", "Lr", "Temp", "Hybrid", "Cum")
ALR_Mod_aggregate_2 <- melt(ALR_Mod_aggregate_2, id.vars = c("Dataset"), variable.name = "Parameter")
ALR_Mod_aggregate_2$Dataset <- factor(ALR_Mod_aggregate_2$Dataset, levels=datasets)

ALR_Mod_raster_2<-ggplot(data = ALR_Mod_aggregate_2, aes(y=as.numeric(Dataset), x=Parameter, fill = value))+
  #geom_contour_fill()+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(-1,1), oob=squish)+
  theme_classic()+
  scale_y_continuous(breaks = 1:length(datasets), labels= datasets, sec.axis = sec_axis(~ ., breaks = 1:length(datasets), labels = ds_labels))+
  theme(text = element_text(size=8), plot.title = element_text(size = 8, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1), legend.title = element_text(size = 8), 
        legend.key.size = unit(.33, 'cm'), legend.position = "none", axis.text.y.right = element_blank())+
  ggtitle("Hierarchical_ALR model")+
  labs(x="Parameter")+
  labs(y="Datasets")+
  labs(fill="Z-scored estimations")

#Hierarchical_Learning model
Data_Higher_Mod <- Data_AIC[Data_AIC$Model=="Higher_mod",]
Data_Higher_Mod$Lr <-scale(Data_Higher_Mod$Lr)
Data_Higher_Mod$Temp <-scale(Data_Higher_Mod$Temp)
Data_Higher_Mod$Hlr <-scale(Data_Higher_Mod$Hlr)
Data_Higher_Mod$Cum <-scale(Data_Higher_Mod$Cum)
Higher_Mod_aggregate_2<-aggregate(cbind(Lr, Temp, Cum, Hlr)~Dataset, FUN = mean, data = Data_Higher_Mod)
colnames(Higher_Mod_aggregate_2)<-c("Dataset", "Lr", "Temp", "Cum", "Hlr")
Higher_Mod_aggregate_2 <- melt(Higher_Mod_aggregate_2, id.vars = c("Dataset"), variable.name = "Parameter")
Higher_Mod_aggregate_2$Dataset <- factor(Higher_Mod_aggregate_2$Dataset, levels=datasets)

Higher_Mod_raster_2<-ggplot(data = Higher_Mod_aggregate_2, aes(y=as.numeric(Dataset), x=Parameter, fill = value))+
  #geom_contour_fill()+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(-1,1), oob=squish)+
  theme_classic()+
  scale_y_continuous(breaks = 1:length(datasets), labels= datasets, sec.axis = sec_axis(~ ., breaks = 1:length(datasets), labels = ds_labels))+
  theme(text = element_text(size=8), plot.title = element_text(size = 8, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1), legend.title = element_text(size = 8), 
        legend.key.size = unit(.33, 'cm'), legend.position = "none", axis.text.y.right = element_blank(), axis.text.y.left = element_blank())+
  ggtitle("Hierarchical_learning model")+
  labs(x="Parameter")+
  labs(y="")+
  labs(fill="Z-scored estimations")

#Full model
Data_Full <- Data_AIC[Data_AIC$Model=="Full",]
Data_Full$Lr <-scale(Data_Full$Lr)
Data_Full$Temp <-scale(Data_Full$Temp)
Data_Full$Hybrid <-scale(Data_Full$Hybrid)
Data_Full$Cum <-scale(Data_Full$Cum)
Data_Full$Hlr <-scale(Data_Full$Hlr)
Full_aggregate_2<-aggregate(cbind(Lr, Temp, Hybrid, Cum, Hlr)~Dataset, FUN = mean, data = Data_Full)
colnames(Full_aggregate_2)<-c("Dataset", "Lr", "Temp", "Hybrid", "Cum", "Hlr")
Full_aggregate_2 <- melt(Full_aggregate_2, id.vars = c("Dataset"), variable.name = "Parameter")
Full_aggregate_2$Dataset <- factor(Full_aggregate_2$Dataset, levels=datasets)

Full_raster_2<-ggplot(data = Full_aggregate_2, aes(y=as.numeric(Dataset), x=Parameter, fill = value))+
  #geom_contour_fill()+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(-1,1), oob=squish)+
  theme_classic()+
  scale_y_continuous(breaks = 1:length(datasets), labels= datasets, sec.axis = sec_axis(~ ., breaks = 1:length(datasets), labels = ds_labels))+
  theme(text = element_text(size=8), plot.title = element_text(size = 8, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1), legend.title = element_text(size = 8), 
        legend.key.size = unit(.33, 'cm'), legend.position = "none", axis.text.y.left = element_blank())+
  ggtitle("Full model")+
  labs(x="Parameter")+
  labs(y="")+
  labs(fill="Z-scored estimations")

#Combine plots
Parameter_grids_2<-ggdraw() +
  draw_plot(RW_raster_2, x = 0, y = .5, width = .41, height = .45) +
  draw_plot(ALR_raster_2, x = .45, y = .5, width = .2, height = .45) +
  draw_plot(Mod_raster_2, x = .7, y = .5, width = .3, height = .45) +
  draw_plot(ALR_Mod_raster_2, x = 0, y = 0, width = .325, height = .45) +
  draw_plot(Higher_Mod_raster_2, x = .355, y = 0, width = .23, height = .45) +
  draw_plot(Full_raster_2, x = .625, y = 0, width = .375, height = .45) #+
#draw_plot_label(label = c("A","B","C","D"), x=c(0,0,0.275,0),y=c(1,0.66,0.66,0.25), size = 12,fontface="bold")

Parameter_grids_2
ggsave("Parameter_grids.jpg", Parameter_grids_2, device = "jpeg", width = 17.5, height = 12, units = "cm", dpi = 300)

