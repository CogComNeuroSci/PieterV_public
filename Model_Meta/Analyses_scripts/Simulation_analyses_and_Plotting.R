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
Models <- c("RW", "Mod" , "ALR", "ALRMod", "HigherMod", "Full")
Models2 <- c("RW", "ALR" , "Mod", "ALRMod", "HigherMod", "Full")
Models3<- c("RW", "ALR" , "Mod", "ALR_mod", "Higher_mod", "Full")
RNN_models <-c("RW", "ALR" , "Mod", "ALRMod", "HigherMod", "Full", "GRU network", "Human subjects")
RNN_modelnames <-  c("Flat", "ALR", "Sets", "Sets_ALR", "Sets_learning", "Full", "GRU network", "Human subjects")
new_modelnames <- c("Flat", "ALR", "Sets", "Sets_ALR", "Sets_learning", "Full")
nModels = length(Models)
resultcolumns <-c("Dataset", "Subject", "Prew", "Label", "Structure", "Model", "ALR", "Mod", "High", "CRew", "Accuracy", "Lr", "Temp", "Hybrid", "Cum", "Hlr")

#setting variables for datasets
datasets <-c("Huycke", "Xia", "Goris/Stable", "Online","Goris/Volatile", "Liu", "Verbeke", "Mukherjee", "Hein", "Cohen")
Prew_ds<- c(100, 80, 70, 100, 90, 85, 80, 70, 74, 66)
Vol_ds<- c("Stable", "Stable", "Stable", "Reversal","Reversal", "Reversal", "Reversal", "Reversal", "Stepwise", "Stepwise")
ds_labels <-c()
for (x in 1:length(datasets)){
  ds_labels[x]<-paste(Vol_ds[x] , "_", Prew_ds[x], "%",sep ="")
}

#For the Goris dataset, these are the subjects that started in our condition of interest
stable_starters_goris <- c(5, 7, 9, 10, 13, 18, 21, 24, 25, 27, 30, 31, 32, 33, 44, 46, 47, 49, 50, 51, 53, 63, 66, 72, 73, 78, 85, 87, 95, 98, 105, 107, 109, 113, 116, 119, 129, 132, 134, 135, 136, 138, 140, 143)
volatile_starters_goris <- c(3, 4, 8, 11, 12, 16, 19, 23, 26, 29, 34, 36, 37, 40, 42, 52, 54, 55, 56, 61, 62, 64, 68, 69, 70, 71, 74, 75, 79, 80, 82, 83, 86, 92, 93, 94, 96, 97, 102, 106, 110, 112, 114, 117, 120, 121, 122, 124, 125, 126, 127, 128, 130, 139, 141, 142)

#For each dataset, we define the subjects that performed below chance level
below_chance_xia<-c(42, 59, 71)
below_chance_Verbeke<-c(4, 8, 17)
below_chance_goris_stable<-c(12, 13, 18, 19, 20, 22, 26, 30, 37, 40, 43, 52, 55, 59, 67, 69, 78, 80, 84, 85, 91, 93, 96, 99, 112, 117, 118, 120, 128, 131, 134, 139, 142)
below_chance_goris_volatile<-c(4, 17, 19, 24, 26, 30, 41, 49, 52, 55, 59, 65, 75, 81, 95, 99, 105, 113, 140, 142)
below_chance_Mukherjee<-c(5, 7, 25, 40, 41, 50)

#set directory
resultsfolder = "/Users/pieter/Desktop/Model_study/Optimize_models/"
setwd(resultsfolder)

dsid = 0

for (ds in datasets){
  
  dsid = dsid+1
  
  Homefolder = paste(resultsfolder , ds, "/", sep ="")
  setwd(Homefolder)
  
  Behfolder = paste("/Users/pieter/Desktop/Model_study/Fitted_data/" , ds, "/", sep ="")
  
  #Read in and combine data
  for (i in Models3){
    if (i == Models3[1]){
      Par_opt_Data<-read.delim(paste("Opt_data_", i, ".csv", sep = ""), header = TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)
    }else{
      d <- read.delim(paste("Opt_data_", i, ".csv", sep = ""), header = TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)
      Par_opt_Data <- rbind(Par_opt_Data, d )
    }
  }
  RNN_Data <-read.delim(paste("GRU_results.csv", sep = ""), header = TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)
  
  #Remove subjects that scored below chance level
  if (ds =="Xia"){
    Par_opt_Data <- Par_opt_Data[!(Par_opt_Data$Subject %in% below_chance_xia), ]
    RNN_Data <- RNN_Data[!(RNN_Data$Subject %in% below_chance_xia), ]
  }
  if (ds =="Verbeke"){
    Par_opt_Data <- Par_opt_Data[!(Par_opt_Data$Subject %in% below_chance_Verbeke), ]
    RNN_Data <- RNN_Data[!(RNN_Data$Subject %in% below_chance_Verbeke), ]
  }
  if (ds =="Goris/Stable"){
    Par_opt_Data <- Par_opt_Data[!(Par_opt_Data$Subject %in% below_chance_goris_stable), ]
    RNN_Data <- RNN_Data[!(RNN_Data$Subject %in% below_chance_goris_stable), ]
    Par_opt_Data <- Par_opt_Data[Par_opt_Data$Subject %in% stable_starters_goris, ]
    RNN_Data <- RNN_Data[RNN_Data$Subject %in% stable_starters_goris, ]
  }
  if (ds =="Goris/Volatile"){
    Par_opt_Data <- Par_opt_Data[!(Par_opt_Data$Subject %in% below_chance_goris_volatile), ]
    RNN_Data <- RNN_Data[!(RNN_Data$Subject %in% below_chance_goris_volatile), ]
    Par_opt_Data <- Par_opt_Data[Par_opt_Data$Subject %in% volatile_starters_goris, ]
    RNN_Data <- RNN_Data[RNN_Data$Subject %in% volatile_starters_goris, ]
  }
  if (ds =="Mukherjee"){
    Par_opt_Data <- Par_opt_Data[!(Par_opt_Data$Subject %in% below_chance_Mukherjee), ]
    RNN_Data <- RNN_Data[!(RNN_Data$Subject %in% below_chance_Mukherjee), ]
  }
  
  pplist <- unique(Par_opt_Data$Subject)
  
  df_RNN = data.frame(matrix(nrow = length(pplist), ncol = length(resultcolumns))) 
  colnames(df_RNN) <- resultcolumns
  df_RNN$Dataset <- ds
  df_RNN$Subject <- RNN_Data$Subject + 1000*dsid
  df_RNN$Prew <- Prew_ds[dsid]
  df_RNN$Label <- ds_labels[dsid]
  df_RNN$Structure <- Vol_ds[dsid]
  df_RNN$Model <- "GRU network"
  df_RNN$ALR <- 0
  df_RNN$Mod <- 0
  df_RNN$High <- 0
  df_RNN$CRew <- RNN_Data$Cumulated_Reward
  df_RNN$Accuracy <- RNN_Data$Accuracy *100
  df_RNN$Lr <- 0
  df_RNN$Temp <- 0
  df_RNN$Hybrid <- 0
  df_RNN$Cum <- 0
  df_RNN$Hlr <- 0
  
  df_Beh = data.frame(matrix(nrow = length(pplist), ncol = length(resultcolumns))) 
  colnames(df_Beh) <- resultcolumns
  df_Beh$Dataset <- ds
  df_Beh$Subject <- RNN_Data$Subject + 1000*dsid
  df_Beh$Prew <- Prew_ds[dsid]
  df_Beh$Label <- ds_labels[dsid]
  df_Beh$Structure <- Vol_ds[dsid]
  df_Beh$Model <- "Human subjects"
  df_Beh$ALR <- 0
  df_Beh$Mod <- 0
  df_Beh$High <- 0
  df_Beh$Lr <- 0
  df_Beh$Temp <- 0
  df_Beh$Hybrid <- 0
  df_Beh$Cum <- 0
  df_Beh$Hlr <- 0
  
  setwd(Behfolder)
  sid = 0
  for (p in pplist){
    sid = sid +1
    Behdat <- read.delim(paste("Data_subject_", p, "_0.csv", sep = ""), header = TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)
    df_Beh$CRew[sid] <- sum(Behdat$Reward)
    df_Beh$Accuracy[sid] <- mean(Behdat$Response == Behdat$CorResp) * 100
  }
  setwd(Homefolder)
  df = data.frame(matrix(nrow = length(pplist)*nModels, ncol = length(resultcolumns))) 
  colnames(df) <- resultcolumns
  dfid = 0
  for (i in 1:length(Models3)){
    for (p in pplist){
      dfid = dfid +1
      dat <- read.delim(paste("Data_subject_", p, "_", i-1 ,".csv", sep = ""), header = TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)
      
      df$Dataset[dfid] <- ds
      df$Subject[dfid] <- p + 1000*dsid
      df$Prew[dfid] <- Prew_ds[dsid]
      df$Label[dfid] <- ds_labels[dsid]
      df$Structure[dfid] <- Vol_ds[dsid]
      df$Model[dfid] <- Models2[i]
      if (i %in% c(2,4,6)){
        df$ALR[dfid] <- 1
      }else{
        df$ALR[dfid] <- 0
      }
      if (i > 2){
        df$Mod[dfid] <- 1
      }else{
        df$Mod[dfid] <- 0
      }
      if (i > 4){
        df$High[dfid] <- 1
      }else{
        df$High[dfid] <- 0
      }
 
      df$CRew[dfid] <- Par_opt_Data$LogLik[dfid]
      df$Accuracy[dfid] <-mean((dat$Response == dat$CorResp)*1)*100
      
      df$Lr[dfid] <-Par_opt_Data$Lr[dfid]
      df$Temp[dfid] <-Par_opt_Data$Temp[dfid]
      df$Hybrid[dfid] <-Par_opt_Data$Hybrid[dfid]
      df$Cum[dfid] <-Par_opt_Data$Cum[dfid]
      df$Hlr[dfid] <-Par_opt_Data$Hlr[dfid]
    }
  }
  
  df <- rbind(df, df_RNN, df_Beh)
  if(dsid == 1){
    all_data <- df
  }else{
    all_data <-rbind(all_data, df)
  }
}

#here, we store all data
RNN_Data <- all_data

#here, we remove the two benchmarks for the analyses and plots that do not use the benchmarks
all_data <- all_data[all_data$Model != "GRU network", ]
all_data <- all_data[all_data$Model != "Human subjects", ]

all_id = 0
all_data$maxAcc<-0
all_data$deltaAcc<-0
all_data$eAcc<-0
all_data$wAcc<-0

RNN_Data$maxAcc<-0
RNN_Data$deltaAcc<-0
RNN_Data$eAcc<-0
RNN_Data$wAcc<-0

for (ds in datasets){
  dat_ds = all_data[all_data$Dataset == ds, ]
  pplist = unique(dat_ds$Subject)

  for (pp in pplist){
    trIDs = which(all_data$Subject == pp)
    all_data$maxAcc[trIDs] <- rep(max(all_data$Accuracy[trIDs]), length(Models))
    all_data$deltaAcc[trIDs] <- all_data$maxAcc[trIDs] - all_data$Accuracy[trIDs]
    all_data$eAcc[trIDs] <- exp((-1/2)*all_data$deltaAcc[trIDs])
    all_data$wAcc[trIDs] <- all_data$eAcc[trIDs] / sum(all_data$eAcc[trIDs])
    
    trIDs = which(RNN_Data$Subject == pp)
    RNN_Data$maxAcc[trIDs] <- rep(max(RNN_Data$Accuracy[trIDs]), length(Models)+2)
    RNN_Data$deltaAcc[trIDs] <- RNN_Data$maxAcc[trIDs] - RNN_Data$Accuracy[trIDs]
    RNN_Data$eAcc[trIDs] <- exp((-1/2)*RNN_Data$deltaAcc[trIDs])
    RNN_Data$wAcc[trIDs] <- RNN_Data$eAcc[trIDs] / sum(RNN_Data$eAcc[trIDs])
  }
}

#Aggregating accuracy for model simulations
Summary_accuracy <- summarySE(data = all_data, "wAcc", groupvars = c("Dataset", "Structure", "Label","Model"), conf.interval = 0.95)
Summary_accuracy$Model <- factor(Summary_accuracy$Model, levels=Models2)
Summary_accuracy$Dataset <- factor(Summary_accuracy$Dataset, levels=rev(datasets))

Summary_accuracy_RNN <- summarySE(data = RNN_Data, "wAcc", groupvars = c("Dataset", "Structure", "Label","Model"), conf.interval = 0.95)
Summary_accuracy_RNN$Model <- factor(Summary_accuracy_RNN$Model, levels=RNN_models)
Summary_accuracy_RNN$Dataset <- factor(Summary_accuracy_RNN$Dataset, levels=rev(datasets))
 
#Color palette for plots
pal <- wes_palette("Zissou1", 100, type = "continuous")

#Divide data over environments
Stable_sims <- Summary_accuracy[Summary_accuracy$Structure=="Stable",]
Reversal_sims <- Summary_accuracy[Summary_accuracy$Structure=="Reversal",]
Stepwise_sims <- Summary_accuracy[Summary_accuracy$Structure=="Stepwise",]

#Make plots
Stable_accsims<-ggplot(data = Stable_sims, aes(x=Model, y=Dataset, fill = wAcc))+
  #geom_contour_fill()+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(0,0.5),oob = squish)+
  scale_x_discrete(labels = c("","","","","",""))+
  #scale_y_continuous(breaks = 1:3, labels= datasets[1:3], sec.axis = sec_axis(~ ., breaks = 1:length(datasets), labels = ds_labels))+
  theme_classic()+
  theme(text = element_text(size=8), plot.title = element_text(size = 10, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 67.5, hjust=1), legend.title = element_text(size = 8), 
        legend.key.size = unit(.33, 'cm'), legend.position = "none" )+
  ggtitle(expression(bold(atop("Weighted performance", "only cognitive models"))))+
  labs(x="")+
  labs(y="")+
  labs(fill="wACC")
 
Reversal_accsims<-ggplot(data = Reversal_sims, aes(x=Model, y=Dataset, fill = wAcc))+
  #geom_contour_fill()+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(0,0.5),oob = squish)+
  theme_classic()+
  scale_x_discrete(labels = c("","","","","",""))+
  theme(text = element_text(size=8), plot.title = element_text(size = 10, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 67.5, hjust=1), legend.title = element_text(size = 8),
        legend.key.size = unit(.33, 'cm'), legend.position = "left", axis.text.y.right = element_blank())+
  ggtitle("")+
  labs(x="")+
  labs(y="Datasets")+
  labs(fill="wACC")

Stepwise_accsims<-ggplot(data = Stepwise_sims, aes(x=Model, y=Dataset, fill = wAcc))+
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
  labs(fill="wACC")

## Now with the benchmarks
#Divide data over environments
Stable_sims_RNN <- Summary_accuracy_RNN[Summary_accuracy_RNN$Structure=="Stable",]
Reversal_sims_RNN <- Summary_accuracy_RNN[Summary_accuracy_RNN$Structure=="Reversal",]
Stepwise_sims_RNN <- Summary_accuracy_RNN[Summary_accuracy_RNN$Structure=="Stepwise",]

#Make plots
Stable_accsims_RNN<-ggplot(data = Stable_sims_RNN, aes(x=Model, y=as.numeric(Dataset), fill = wAcc))+
  #geom_contour_fill()+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(0,0.5),oob = squish)+
  scale_x_discrete(labels = c("","","","","","","", ""))+
  scale_y_continuous(breaks = 1:3, labels= c("","",""), sec.axis = sec_axis(~ ., breaks = 1:length(datasets), labels = rev(ds_labels)))+
  theme_classic()+
  theme(text = element_text(size=8), plot.title = element_text(size = 10, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 67.5, hjust=1), legend.title = element_text(size = 8), 
        legend.key.size = unit(.33, 'cm'), legend.position = "none" )+
  ggtitle(expression(bold(atop("Weighted performance", "with benchmarks"))))+
  labs(x="")+
  labs(y="")+
  labs(fill="wACC")

Reversal_accsims_RNN<-ggplot(data = Reversal_sims_RNN, aes(x=Model, y=as.numeric(Dataset), fill = wAcc))+
  #geom_contour_fill()+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(0,0.5),oob = squish)+
  theme_classic()+
  scale_x_discrete(labels = c("","","","","","","",""))+
  scale_y_continuous(breaks = 4:8, labels= c("","","","",""), sec.axis = sec_axis(~ ., breaks = 1:length(datasets), labels = rev(ds_labels)))+
  theme(text = element_text(size=8), plot.title = element_text(size = 10, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 67.5, hjust=1), legend.title = element_text(size = 8),
        legend.key.size = unit(.33, 'cm'), legend.position = "none")+
  ggtitle("")+
  labs(x="")+
  labs(y="")+
  labs(fill="wACC")

Stepwise_accsims_RNN<-ggplot(data = Stepwise_sims_RNN, aes(x=Model, y=as.numeric(Dataset), fill = wAcc))+
  #geom_contour_fill()+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(0,0.5),oob = squish)+
  theme_classic()+
  scale_x_discrete(labels = RNN_modelnames)+
  scale_y_continuous(breaks = 9:10, labels= c("",""), sec.axis = sec_axis(~ ., breaks = 1:length(datasets), labels = rev(ds_labels)))+
  theme(text = element_text(size=8), plot.title = element_text(size = 10, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 67.5, hjust=1), legend.title = element_text(size = 8),
        legend.key.size = unit(.33, 'cm'), legend.position = "none")+
  ggtitle("")+
  labs(x="Model")+
  labs(y="")+
  labs(fill="wACC")

Performance_grids<-ggdraw() +
  draw_plot(Stepwise_accsims, x = 0.15, y = 0.01, width = .375, height = .375) +
  draw_plot(Reversal_accsims, x = 0, y = 0.31, width = .525, height = .4) +
  draw_plot(Stable_accsims, x = 0.11, y = 0.64, width = .415, height = .36) +
  draw_plot(Stepwise_accsims_RNN, x = .525, y = .0, width = .46, height = .375) +
  draw_plot(Reversal_accsims_RNN, x = .525, y = .31, width = .475, height = .4) +
  draw_plot(Stable_accsims_RNN, x = .525, y = .64, width = .465, height = .36) +
  draw_plot_label(label = c("A","B"), x=c(0.175,0.53),y=c(.975,.975), size = 10,fontface="bold")

setwd("/Users/pieter/Desktop/Model_Study/Analyses_results/")
ggsave("Optimality_models.jpg", Performance_grids, device = "jpeg", width = 15, height = 12, units = "cm", dpi = 300)

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
AIC_aggregate$Dataset <- factor(AIC_aggregate$Dataset, levels=rev(datasets))

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
  scale_y_continuous(breaks = 8:10, labels = c("", "", ""))+
  theme(text = element_text(size=8), plot.title = element_text(size = 10, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 67.5, hjust=1), legend.title = element_text(size = 8), 
        legend.key.size = unit(.33, 'cm'), legend.position = "none" )+
  ggtitle("Model fit\n\n as wAIC")+
  labs(x="")+
  labs(y="")+
  labs(fill="Measure")

AIC_raster_reversal<-ggplot(data = Reversal_AIC, aes(x=Model, y=as.numeric(Dataset), fill=Value))+
  #geom_contour_fill()+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(0,0.5), oob=squish)+
  scale_x_discrete(labels = c("","","","","",""))+
  theme_classic()+
  scale_y_continuous(breaks = 3:7, labels = c("", "", "", "",""))+
  theme(text = element_text(size=8), plot.title = element_text(size = 10, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 67.5, hjust=1), legend.title = element_text(size = 8), 
        legend.key.size = unit(.33, 'cm'), legend.position = "none" )+
  ggtitle("")+
  labs(x="")+
  labs(y="")+
  labs(fill="Measure")

AIC_raster_stepwise<-ggplot(data = Stepwise_AIC, aes(x=Model, y=as.numeric(Dataset), fill=Value))+
  #geom_contour_fill()+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(0,0.5), oob=squish)+
  scale_x_discrete(labels = new_modelnames)+
  theme_classic()+
  scale_y_continuous(breaks = 1:2, labels= c("",""))+
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
  ggtitle("Model fit\n as wAIC")+
  labs(x="Model")+
  labs(y="Datasets")+
  labs(fill="Measure")

#Combine plots and save
Model_grids<-ggdraw() +
  draw_plot(Stepwise_accsims, x = 0.145, y = 0, width = .385, height = .375) +
  draw_plot(Reversal_accsims, x = 0, y = 0.3, width = .53, height = .425) +
  draw_plot(Stable_accsims, x = 0.11, y = 0.635, width = .42, height = .365) +
  draw_plot(AIC_raster_stepwise, x = .55, y = .0, width = .44, height = .375) +
  draw_plot(AIC_raster_reversal, x = .55, y = .3, width = .45, height = .425) +
  draw_plot(AIC_raster_stable, x = .55, y = .635, width = .435, height = .365) +
  draw_plot_label(label = c("A","B"), x=c(0.15,0.6),y=c(.975,.975), size = 10,fontface="bold")

ggsave("Grid_models.jpg", Model_grids, device = "jpeg", width = 15, height = 10, units = "cm", dpi = 300)

#Regression on simulated data
feature_ACC <-lmer(wAcc ~ (1|Dataset) + Structure*Mod*ALR*High, all_data)
summary(feature_ACC)
Anova(feature_ACC)

#Specific t-tests
ALR_aggregate <- aggregate(wAcc~Subject*ALR, FUN = mean, data = all_data)
t.test(ALR_aggregate$wAcc~ALR_aggregate$ALR, paired = TRUE)

ALR_aggregate <- aggregate(wAcc~Subject*ALR, FUN = mean, data = all_data[all_data$Structure=="Stable",])
t.test(ALR_aggregate$wAcc~ALR_aggregate$ALR, paired = TRUE)

ALR_aggregate <- aggregate(wAcc~Subject*ALR, FUN = mean, data = all_data[all_data$Structure=="Reversal",])
t.test(ALR_aggregate$wAcc~ALR_aggregate$ALR, paired = TRUE)

ALR_aggregate <- aggregate(wAcc~Subject*ALR, FUN = mean, data = all_data[all_data$Structure=="Stepwise",])
t.test(ALR_aggregate$wAcc~ALR_aggregate$ALR, paired = TRUE)

Mod_aggregate <- aggregate(wAcc~Subject*Mod, FUN = mean, data = all_data)
t.test(Mod_aggregate$wAcc~Mod_aggregate$Mod, paired = TRUE)

Mod_aggregate <- aggregate(wAcc~Subject*Mod, FUN = mean, data = all_data[all_data$Structure=="Stable",])
t.test(Mod_aggregate$wAcc~Mod_aggregate$Mod, paired = TRUE)

Mod_aggregate <- aggregate(wAcc~Subject*Mod, FUN = mean, data = all_data[all_data$Structure=="Reversal",])
t.test(Mod_aggregate$wAcc~Mod_aggregate$Mod, paired = TRUE)

Mod_aggregate <- aggregate(wAcc~Subject*Mod, FUN = mean, data = all_data[all_data$Structure=="Stepwise",])
t.test(Mod_aggregate$wAcc~Mod_aggregate$Mod, paired = TRUE)

High_aggregate <- aggregate(wAcc~Subject*High, FUN = mean, data = all_data)
t.test(High_aggregate$wAcc~High_aggregate$High, paired = TRUE)

High_aggregate <- aggregate(wAcc~Subject*High, FUN = mean, data = all_data[all_data$Structure=="Stable",])
t.test(High_aggregate$wAcc~High_aggregate$High, paired = TRUE)

High_aggregate <- aggregate(wAcc~Subject*High, FUN = mean, data = all_data[all_data$Structure=="Reversal",])
t.test(High_aggregate$wAcc~High_aggregate$High)

High_aggregate <- aggregate(wAcc~Subject*High, FUN = mean, data = all_data[all_data$Structure=="Stepwise",])
t.test(High_aggregate$wAcc~High_aggregate$High, paired = TRUE)

#Summarize data per model feature and environment
IEVolMod <- summarySE(data = all_data, "wAcc", groupvars = c("Mod", "Structure"), conf.interval = 0.95)
IEVolMod$Mod <- as.factor(IEVolMod$Mod)
IEVolMod$Structure <- factor(IEVolMod$Structure, levels=c("Stable", "Reversal", "Stepwise"))

IEVolALR <- summarySE(data = all_data, "wAcc", groupvars = c("ALR", "Structure"), conf.interval = 0.95)
IEVolALR$ALR <- as.factor(IEVolALR$ALR)
IEVolALR$Structure <- factor(IEVolMod$Structure, levels=c("Stable", "Reversal", "Stepwise"))

IEVolHigh <- summarySE(data = all_data, "wAcc", groupvars = c("High", "Structure"), conf.interval = 0.95)
IEVolHigh$High <- as.factor(IEVolHigh$High)
IEVolHigh$Structure <- factor(IEVolMod$Structure, levels=c("Stable", "Reversal", "Stepwise"))
 
#Make plots
VolMod_plot <- ggplot(IEVolMod, aes(y=wAcc, x = Structure, colour = Mod, group = Mod))+ 
  geom_point(size = 2,position = position_dodge2(.2))+
  geom_errorbar(aes(ymin=wAcc-ci, ymax = wAcc+ci), width = .1, size =1, position = position_dodge(.2))+
  ggtitle("")+
  coord_cartesian(ylim = c(0, 0.35))+
  ylab("Multiple rule sets")+
  xlab("")+
  scale_colour_discrete(name = "Feature present", labels=c("0" = "No", "1" = "Yes"))+
  theme_classic()+
  theme(text = element_text(size=8),plot.title = element_text(size = 8, face = "bold", hjust=0.5), axis.title.y=element_text(face="italic"), axis.text.x = element_text(angle = 45, hjust=1))

VolALR_plot <- ggplot(IEVolALR, aes(y=wAcc, x = Structure, colour = ALR, group = ALR))+ 
  geom_point(size = 2, position = position_dodge2(.2))+
  geom_errorbar(aes(ymin=wAcc-ci, ymax = wAcc+ci), width = .1, size =1, position = position_dodge(.2))+
  ggtitle(expression(bold(atop("Model performance", "as wACC"))))+ #weighted P(a"["optimal"]*")"
  coord_cartesian(ylim = c(0, 0.35))+
  ylab("Adaptive learning rate")+
  xlab("")+
  scale_colour_discrete(name = "Feature present", labels=c("0" = "No", "1" = "Yes"))+
  theme_classic()+
  theme(text = element_text(size=8),plot.title = element_text(size = 8, face = "bold", hjust=0.5), axis.title.y=element_text(face="italic"), axis.text.x = element_text(angle = 45, hjust=1))
 
VolHigh_plot <- ggplot(IEVolHigh, aes(y=wAcc, x = Structure, colour = High, group = High))+ 
  geom_point(size = 2, position = position_dodge2(.2))+
  geom_errorbar(aes(ymin=wAcc-ci, ymax = wAcc+ci), width = .1, size =1, position = position_dodge(.2))+
  ggtitle("")+
  coord_cartesian(ylim = c(0, 0.35))+
  ylab("Hierarchical learning")+
  xlab("Environments")+
  scale_colour_discrete(name = "Feature present", labels=c("0" = "No", "1" = "Yes"))+
  theme_classic()+
  theme(text = element_text(size=8),plot.title = element_text(size = 8, face = "bold", hjust=0.5), axis.title.y=element_text(face="italic"), axis.text.x = element_text(angle = 45, hjust=1))

#Now, we do this regression for model fit
feature_AIC <-lmer(Outcome ~ (1|Dataset) + Volatility*Mod*ALR*High, Data_AIC)
summary(feature_AIC)
Anova(feature_AIC)

Data_AIC$Stim <- 4
Data_AIC$Stim[Data_AIC$Dataset == "Huycke"] <- 36
Data_AIC$Stim[Data_AIC$Dataset == "Online"] <- 2
Data_AIC$Stim[Data_AIC$Dataset == "Verbeke"] <- 2
Data_AIC$Stim[Data_AIC$Dataset == "Mukherjee"] <- 1
Data_AIC$Stim[Data_AIC$Dataset == "Hein"] <- 1
Data_AIC$Stim[Data_AIC$Dataset == "Cohen"] <- 1

Data_AIC$Money<-1
Data_AIC$Money[Data_AIC$Dataset == "Xia"]<-0
Data_AIC$Money[Data_AIC$Dataset == "Huycke"]<-0
Data_AIC$Money[Data_AIC$Dataset == "Liu"]<-0

#Check alternative models
reward <- lmer(Outcome ~ (1|Dataset) + Reward*Mod*ALR*High, Data_AIC)
Anova(reward)

Trials <- lmer(Outcome ~ (1|Dataset) + Trials*Mod*ALR*High, Data_AIC)
Anova(Trials)

Stim <- lmer(Outcome ~ (1|Dataset) + Stim*Mod*ALR*High, Data_AIC)
Anova(Stim)

Money <- lmer(Outcome ~ (1|Dataset) + Money*Mod*ALR*High, Data_AIC)
Anova(Money)

#see which model is best
combined1<-lmer(Outcome ~ (1|Dataset) + Volatility*Reward*Mod*ALR*High, Data_AIC)
combined2<-lmer(Outcome ~ (1|Dataset) + Volatility*Stim*Mod*ALR*High, Data_AIC)
combined3<-lmer(Outcome ~ (1|Dataset) + Volatility*Trials*Mod*ALR*High, Data_AIC)
anova(feature_AIC, combined1)
anova(feature_AIC, combined2)
anova(feature_AIC, combined3)

anova(combined1, combined3)
anova(combined1, combined2)
anova(combined2, combined3)

Anova(combined1)

anova(feature_AIC, reward)
anova(feature_AIC, Trials)
anova(feature_AIC, Stim)
anova(feature_AIC, Money)

#Again specific contrasts
ALR_aggregate <- aggregate(Outcome~Subject*ALR, FUN = mean, data = Data_AIC)
t.test(ALR_aggregate$Outcome~ALR_aggregate$ALR, paired = TRUE)

ALR_aggregate <- aggregate(Outcome~Subject*ALR, FUN = mean, data = Data_AIC[Data_AIC$Volatility=="Stable",])
t.test(ALR_aggregate$Outcome~ALR_aggregate$ALR, paired = TRUE)

ALR_aggregate <- aggregate(Outcome~Subject*ALR, FUN = mean, data = Data_AIC[Data_AIC$Volatility=="Reversal",])
t.test(ALR_aggregate$Outcome~ALR_aggregate$ALR, paired = TRUE)

ALR_aggregate <- aggregate(Outcome~Subject*ALR, FUN = mean, data = Data_AIC[Data_AIC$Volatility=="Stepwise",])
t.test(ALR_aggregate$Outcome~ALR_aggregate$ALR, paired = TRUE)

Mod_aggregate <- aggregate(Outcome~Subject*Mod, FUN = mean, data = Data_AIC)
t.test(Mod_aggregate$Outcome~Mod_aggregate$Mod, paired = TRUE)

Mod_aggregate <- aggregate(Outcome~Subject*Mod, FUN = mean, data = Data_AIC[Data_AIC$Volatility=="Stable",])
t.test(Mod_aggregate$Outcome~Mod_aggregate$Mod)

Mod_aggregate <- aggregate(Outcome~Subject*Mod, FUN = mean, data = Data_AIC[Data_AIC$Volatility=="Reversal",])
t.test(Mod_aggregate$Outcome~Mod_aggregate$Mod, paired = TRUE)

Mod_aggregate <- aggregate(Outcome~Subject*Mod, FUN = mean, data = Data_AIC[Data_AIC$Volatility=="Stepwise",])
t.test(Mod_aggregate$Outcome~Mod_aggregate$Mod, paired = TRUE)

High_aggregate <- aggregate(Outcome~Subject*High, FUN = mean, data = Data_AIC)
t.test(High_aggregate$Outcome~High_aggregate$High, paired = TRUE)

High_aggregate <- aggregate(Outcome~Subject*High, FUN = mean, data = Data_AIC[Data_AIC$Volatility=="Stable",])
t.test(High_aggregate$Outcome~High_aggregate$High, paired = TRUE)

High_aggregate <- aggregate(Outcome~Subject*High, FUN = mean, data = Data_AIC[Data_AIC$Volatility=="Reversal",])
t.test(High_aggregate$Outcome~High_aggregate$High, paired = TRUE)

High_aggregate <- aggregate(Outcome~Subject*High, FUN = mean, data = Data_AIC[Data_AIC$Volatility=="Stepwise",])
t.test(High_aggregate$Outcome~High_aggregate$High, paired = TRUE)

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
  theme_classic()+
  theme(text = element_text(size=8),plot.title = element_text(size = 8, face = "italic", hjust=0.5, family="Times"), axis.text.x = element_text(angle = 45, hjust=1))

VolALR_plotAIC <- ggplot(AIC_IEVolALR, aes(y=Outcome, x = Volatility, colour = ALR, group = ALR))+ 
  geom_point(size = 2, position = position_dodge2(.2))+
  geom_errorbar(aes(ymin=Outcome-ci, ymax = Outcome+ci), width = .1, size =1, position = position_dodge(.2))+
  ggtitle("Model fit\n\n as wAIC")+
  coord_cartesian(ylim = c(0, 0.35))+
  ylab("")+
  xlab("")+
  scale_colour_discrete(name = "Feature present", labels=c("0" = "No", "1" = "Yes"))+
  theme_classic()+
  theme(text = element_text(size=8),plot.title = element_text(size = 8, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 45, hjust=1))

VolHigh_plotAIC <- ggplot(AIC_IEVolHigh, aes(y=Outcome, x = Volatility, colour = High, group = High))+ 
  geom_point(size = 2, position = position_dodge2(.2))+
  geom_errorbar(aes(ymin=Outcome-ci, ymax = Outcome+ci), width = .1, size =1, position = position_dodge(.2))+
  ylab("")+
  coord_cartesian(ylim = c(0, 0.35))+
  ylab("")+
  xlab("Environments")+
  scale_colour_discrete(name = "Feature present", labels=c("0" = "No", "1" = "Yes"))+
  theme_classic()+
  theme(text = element_text(size=8),plot.title = element_text(size = 8, face = "italic", hjust=0.5, family="Times"), axis.text.x = element_text(angle = 45, hjust=1))

#Combine plots and save
Feature_plot <- ggarrange(VolALR_plot, VolALR_plotAIC, VolMod_plot, VolMod_plotAIC, VolHigh_plot, VolHigh_plotAIC, ncol = 2, nrow = 3, common.legend = TRUE, heights=c(1,1), widths=c(1, 1, 1), labels = c("A", "B", "C","D", "E", "F"))
ggsave("Feature_Volatility.jpg", Feature_plot, device = "jpeg", width = 12, height = 15, units = "cm", dpi = 300)

#Now, make plots for model parameters (optimal in terms of reward accumulation)
#This plot is shown in the supplementary materials

#Flat model
Data_RW <- all_data[all_data$Model=="RW",]
RW_aggregate<-aggregate(cbind(Lr, Temp)~Dataset, FUN = mean, data = Data_RW)
RW_aggregate <- melt(RW_aggregate, id.vars = c("Dataset"), variable.name = "Parameter")
RW_aggregate$Dataset <- factor(RW_aggregate$Dataset, levels=datasets)

RW_raster<-ggplot(data = RW_aggregate, aes(y=as.numeric(Dataset), x=Parameter, fill = value))+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(0,1), oob=squish)+
  theme_classic()+
  scale_y_continuous(breaks = 1:length(datasets), labels= datasets, sec.axis = sec_axis(~ ., breaks = 1:length(datasets), labels = ds_labels))+
  theme(text = element_text(size=8), plot.title = element_text(size = 8, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1), legend.title = element_text(size = 8), 
        legend.key.size = unit(.33, 'cm'), legend.position = "left", axis.text.y.right = element_blank())+
  ggtitle("RW model")+
  labs(x="Parameter")+
  labs(y="Datasets")+
  labs(fill="Optimised\nparameter values")

#ALR model
Data_ALR <- all_data[all_data$Model=="ALR",]
ALR_aggregate<-aggregate(cbind(Lr, Temp, Hybrid)~Dataset, FUN = mean, data = Data_ALR)
ALR_aggregate <- melt(ALR_aggregate, id.vars = c("Dataset"), variable.name = "Parameter")
ALR_aggregate$Dataset <- factor(ALR_aggregate$Dataset, levels=datasets)

ALR_raster<-ggplot(data = ALR_aggregate, aes(y=as.numeric(Dataset), x=Parameter, fill = value))+
  #geom_contour_fill()+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(0,1), oob=squish)+
  theme_classic()+
  scale_y_continuous(breaks = 1:length(datasets), labels= datasets, sec.axis = sec_axis(~ ., breaks = 1:length(datasets), labels = ds_labels))+
  theme(text = element_text(size=8), plot.title = element_text(size = 8, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1), legend.title = element_text(size = 8), 
        legend.key.size = unit(.33, 'cm'), legend.position = "none",axis.text.y.right = element_blank(), axis.text.y.left = element_blank())+
  ggtitle("ALR model")+
  labs(x="Parameter")+
  labs(y="")+
  labs(fill="Optimised\nparameter values")

#Sets model
Data_Mod <- all_data[all_data$Model=="Mod",]
Mod_aggregate<-aggregate(cbind(Lr, Temp, Cum)~Dataset, FUN = mean, data = Data_Mod)
Mod_aggregate <- melt(Mod_aggregate, id.vars = c("Dataset"), variable.name = "Parameter")
Mod_aggregate$Dataset <- factor(Mod_aggregate$Dataset, levels=datasets)

Mod_raster<-ggplot(data = Mod_aggregate, aes(y=as.numeric(Dataset), x=Parameter, fill = value))+
  #geom_contour_fill()+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(0,1), oob=squish)+
  theme_classic()+
  scale_y_continuous(breaks = 1:length(datasets), labels= datasets, sec.axis = sec_axis(~ ., breaks = 1:length(datasets), labels = ds_labels))+
  theme(text = element_text(size=8), plot.title = element_text(size = 8, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1), legend.title = element_text(size = 8), 
        legend.key.size = unit(.33, 'cm'), legend.position = "none", axis.text.y.left = element_blank())+
  ggtitle("Sets model")+
  labs(x="Parameter")+
  labs(y="")+
  labs(fill="Optimised\nparameter values")

#Sets_ALR model
Data_ALRMod <- all_data[all_data$Model=="ALRMod",]
ALRMod_aggregate<-aggregate(cbind(Lr, Temp, Hybrid, Cum)~Dataset, FUN = mean, data = Data_ALRMod)
ALRMod_aggregate <- melt(ALRMod_aggregate, id.vars = c("Dataset"), variable.name = "Parameter")
ALRMod_aggregate$Dataset <- factor(ALRMod_aggregate$Dataset, levels=datasets)

ALRMod_raster<-ggplot(data = ALRMod_aggregate, aes(y=as.numeric(Dataset), x=Parameter, fill = value))+
  #geom_contour_fill()+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(0,1), oob=squish)+
  theme_classic()+
  scale_y_continuous(breaks = 1:length(datasets), labels= datasets, sec.axis = sec_axis(~ ., breaks = 1:length(datasets), labels = ds_labels))+
  theme(text = element_text(size=8), plot.title = element_text(size = 8, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1), legend.title = element_text(size = 8), 
        legend.key.size = unit(.33, 'cm'), legend.position = "none", axis.text.y.right = element_blank())+
  ggtitle("Sets_ALR model")+
  labs(x="Parameter")+
  labs(y="Datasets")+
  labs(fill="Optimised\nparameter values")

#Sets_Learning model
Data_HigherMod <- all_data[all_data$Model=="HigherMod",]
HigherMod_aggregate<-aggregate(cbind(Lr, Temp, Cum, Hlr)~Dataset, FUN = mean, data = Data_HigherMod)
HigherMod_aggregate <- melt(HigherMod_aggregate, id.vars = c("Dataset"), variable.name = "Parameter")
HigherMod_aggregate$Dataset <- factor(HigherMod_aggregate$Dataset, levels=datasets)

HigherMod_raster<-ggplot(data = HigherMod_aggregate, aes(y=as.numeric(Dataset), x=Parameter, fill = value))+
  #geom_contour_fill()+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(0,1), oob=squish)+
  theme_classic()+
  scale_y_continuous(breaks = 1:length(datasets), labels= datasets, sec.axis = sec_axis(~ ., breaks = 1:length(datasets), labels = ds_labels))+
  theme(text = element_text(size=8), plot.title = element_text(size = 8, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1), legend.title = element_text(size = 8), 
        legend.key.size = unit(.33, 'cm'), legend.position = "none", axis.text.y.right = element_blank(), axis.text.y.left = element_blank())+
  ggtitle("Sets_learning model")+
  labs(x="Parameter")+
  labs(y="")+
  labs(fill="Optimised\nparameter values")

#Full model
Data_Full <- all_data[all_data$Model=="Full",]
Full_aggregate<-aggregate(cbind(Lr, Temp, Hybrid, Cum, Hlr)~Dataset, FUN = mean, data = Data_Full)
Full_aggregate <- melt(Full_aggregate, id.vars = c("Dataset"), variable.name = "Parameter")
Full_aggregate$Dataset <- factor(Full_aggregate$Dataset, levels=datasets)

Full_raster<-ggplot(data = Full_aggregate, aes(y=as.numeric(Dataset), x=Parameter, fill = value))+
  #geom_contour_fill()+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(0,1), oob=squish)+
  theme_classic()+
  scale_y_continuous(breaks = 1:length(datasets), labels= datasets, sec.axis = sec_axis(~ ., breaks = 1:length(datasets), labels = ds_labels))+
  theme(text = element_text(size=8), plot.title = element_text(size = 8, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1), legend.title = element_text(size = 8), 
        legend.key.size = unit(.33, 'cm'), legend.position = "none", axis.text.y.left = element_blank())+
  ggtitle("Full model")+
  labs(x="Parameter")+
  labs(y="")+
  labs(fill="Optimised\nparameter values")

#Combine plots and save
Parameter_grids<-ggdraw() +
  draw_plot(RW_raster, x = 0, y = .5, width = .41, height = .45) +
  draw_plot(ALR_raster, x = .45, y = .5, width = .2, height = .45) +
  draw_plot(Mod_raster, x = .7, y = .5, width = .3, height = .45) +
  draw_plot(ALRMod_raster, x = 0, y = 0, width = .325, height = .45) +
  draw_plot(HigherMod_raster, x = .355, y = 0, width = .23, height = .45) +
  draw_plot(Full_raster, x = .625, y = 0, width = .375, height = .45) #+
#draw_plot_label(label = c("A","B","C","D"), x=c(0,0,0.275,0),y=c(1,0.66,0.66,0.25), size = 12,fontface="bold", family="Times")

Parameter_grids
ggsave("Parameter_optim.jpg", Parameter_grids, device = "jpeg", width = 15, height = 10, units = "cm", dpi = 300)

#Now, we do the same for the fitted parameters

#Flat model
Data_RW <- Data_AIC[Data_AIC$Model=="RW",]
RW_aggregate_2<-aggregate(cbind(Lr, Temp)~Dataset, FUN = mean, data = Data_RW)
colnames(RW_aggregate_2)<-c("Dataset", "Lr", "Temp")
RW_aggregate_2 <- melt(RW_aggregate_2, id.vars = c("Dataset"), variable.name = "Parameter")
RW_aggregate_2$Dataset <- factor(RW_aggregate_2$Dataset, levels=datasets)

RW_raster_2<-ggplot(data = RW_aggregate_2, aes(y=as.numeric(Dataset), x=Parameter, fill = value))+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(0,1), oob=squish)+
  theme_classic()+
  scale_y_continuous(breaks = 1:length(datasets), labels= datasets, sec.axis = sec_axis(~ ., breaks = 1:length(datasets), labels = ds_labels))+
  theme(text = element_text(size=8), plot.title = element_text(size = 8, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1), legend.title = element_text(size = 8), 
        legend.key.size = unit(.33, 'cm'), legend.position = "left", axis.text.y.right = element_blank())+
  ggtitle("RW model")+
  labs(x="Parameter")+
  labs(y="Datasets")+
  labs(fill="Fitted\nparameter values")

#ALR model
Data_ALR <- Data_AIC[Data_AIC$Model=="ALR",]
ALR_aggregate_2<-aggregate(cbind(Lr, Temp, Hybrid)~Dataset, FUN = mean, data = Data_ALR)
colnames(ALR_aggregate_2)<-c("Dataset", "Lr", "Temp", "Hybrid")
ALR_aggregate_2 <- melt(ALR_aggregate_2, id.vars = c("Dataset"), variable.name = "Parameter")
ALR_aggregate_2$Dataset <- factor(ALR_aggregate_2$Dataset, levels=datasets)

ALR_raster_2<-ggplot(data = ALR_aggregate_2, aes(y=as.numeric(Dataset), x=Parameter, fill = value))+
  #geom_contour_fill()+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(0,1), oob=squish)+
  theme_classic()+
  scale_y_continuous(breaks = 1:length(datasets), labels= datasets, sec.axis = sec_axis(~ ., breaks = 1:length(datasets), labels = ds_labels))+
  theme(text = element_text(size=8), plot.title = element_text(size = 8, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1), legend.title = element_text(size = 8), 
        legend.key.size = unit(.33, 'cm'), legend.position = "none",axis.text.y.right = element_blank(), axis.text.y.left = element_blank())+
  ggtitle("ALR model")+
  labs(x="Parameter")+
  labs(y="")+
  labs(fill="Fitted\nparameter values")

#Sets model
Data_Mod <- Data_AIC[Data_AIC$Model=="Mod",]
Mod_aggregate_2<-aggregate(cbind(Lr, Temp, Cum)~Dataset, FUN = mean, data = Data_Mod)
colnames(Mod_aggregate_2)<-c("Dataset", "Lr", "Temp", "Cum")
Mod_aggregate_2 <- melt(Mod_aggregate_2, id.vars = c("Dataset"), variable.name = "Parameter")
Mod_aggregate_2$Dataset <- factor(Mod_aggregate_2$Dataset, levels=datasets)

Mod_raster_2<-ggplot(data = Mod_aggregate_2, aes(y=as.numeric(Dataset), x=Parameter, fill = value))+
  #geom_contour_fill()+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(0,1), oob=squish)+
  theme_classic()+
  scale_y_continuous(breaks = 1:length(datasets), labels= datasets, sec.axis = sec_axis(~ ., breaks = 1:length(datasets), labels = ds_labels))+
  theme(text = element_text(size=8), plot.title = element_text(size = 8, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1), legend.title = element_text(size = 8), 
        legend.key.size = unit(.33, 'cm'), legend.position = "none", axis.text.y.left = element_blank())+
  ggtitle("Sets model")+
  labs(x="Parameter")+
  labs(y="")+
  labs(fill="Fitted\nparameter values")

#Sets_ALR model
Data_ALR_Mod <- Data_AIC[Data_AIC$Model=="ALR_mod",]
ALR_Mod_aggregate_2<-aggregate(cbind(Lr, Temp, Hybrid, Cum)~Dataset, FUN = mean, data = Data_ALR_Mod)
colnames(ALR_Mod_aggregate_2)<-c("Dataset", "Lr", "Temp", "Hybrid", "Cum")
ALR_Mod_aggregate_2 <- melt(ALR_Mod_aggregate_2, id.vars = c("Dataset"), variable.name = "Parameter")
ALR_Mod_aggregate_2$Dataset <- factor(ALR_Mod_aggregate_2$Dataset, levels=datasets)

ALR_Mod_raster_2<-ggplot(data = ALR_Mod_aggregate_2, aes(y=as.numeric(Dataset), x=Parameter, fill = value))+
  #geom_contour_fill()+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(0,1), oob=squish)+
  theme_classic()+
  scale_y_continuous(breaks = 1:length(datasets), labels= datasets, sec.axis = sec_axis(~ ., breaks = 1:length(datasets), labels = ds_labels))+
  theme(text = element_text(size=8), plot.title = element_text(size = 8, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1), legend.title = element_text(size = 8), 
        legend.key.size = unit(.33, 'cm'), legend.position = "none", axis.text.y.right = element_blank())+
  ggtitle("Sets_ALR model")+
  labs(x="Parameter")+
  labs(y="Datasets")+
  labs(fill="Fitted\nparameter values")

#Sets_Learning model
Data_Higher_Mod <- Data_AIC[Data_AIC$Model=="Higher_mod",]
Higher_Mod_aggregate_2<-aggregate(cbind(Lr, Temp, Cum, Hlr)~Dataset, FUN = mean, data = Data_Higher_Mod)
colnames(Higher_Mod_aggregate_2)<-c("Dataset", "Lr", "Temp", "Cum", "Hlr")
Higher_Mod_aggregate_2 <- melt(Higher_Mod_aggregate_2, id.vars = c("Dataset"), variable.name = "Parameter")
Higher_Mod_aggregate_2$Dataset <- factor(Higher_Mod_aggregate_2$Dataset, levels=datasets)

Higher_Mod_raster_2<-ggplot(data = Higher_Mod_aggregate_2, aes(y=as.numeric(Dataset), x=Parameter, fill = value))+
  #geom_contour_fill()+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(0,1), oob=squish)+
  theme_classic()+
  scale_y_continuous(breaks = 1:length(datasets), labels= datasets, sec.axis = sec_axis(~ ., breaks = 1:length(datasets), labels = ds_labels))+
  theme(text = element_text(size=8), plot.title = element_text(size = 8, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1), legend.title = element_text(size = 8), 
        legend.key.size = unit(.33, 'cm'), legend.position = "none", axis.text.y.right = element_blank(), axis.text.y.left = element_blank())+
  ggtitle("Sets_learning model")+
  labs(x="Parameter")+
  labs(y="")+
  labs(fill="Fitted\nparameter values")

#Full model
Data_Full <- Data_AIC[Data_AIC$Model=="Full",]
Full_aggregate_2<-aggregate(cbind(Lr, Temp, Hybrid, Cum, Hlr)~Dataset, FUN = mean, data = Data_Full)
colnames(Full_aggregate_2)<-c("Dataset", "Lr", "Temp", "Hybrid", "Cum", "Hlr")
Full_aggregate_2 <- melt(Full_aggregate_2, id.vars = c("Dataset"), variable.name = "Parameter")
Full_aggregate_2$Dataset <- factor(Full_aggregate_2$Dataset, levels=datasets)

Full_raster_2<-ggplot(data = Full_aggregate_2, aes(y=as.numeric(Dataset), x=Parameter, fill = value))+
  #geom_contour_fill()+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(0,1), oob=squish)+
  theme_classic()+
  scale_y_continuous(breaks = 1:length(datasets), labels= datasets, sec.axis = sec_axis(~ ., breaks = 1:length(datasets), labels = ds_labels))+
  theme(text = element_text(size=8), plot.title = element_text(size = 8, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1), legend.title = element_text(size = 8), 
        legend.key.size = unit(.33, 'cm'), legend.position = "none", axis.text.y.left = element_blank())+
  ggtitle("Full model")+
  labs(x="Parameter")+
  labs(y="")+
  labs(fill="Fitted\nparameter values")

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

#Aggregate data for BIC
BIC_aggregate<-aggregate(Data_BIC$Outcome, by = list(Data_BIC$Dataset, Data_BIC$Model), FUN = mean)
colnames(BIC_aggregate) <-c("Dataset", "Model", "Value")
BIC_aggregate$Model <- factor(BIC_aggregate$Model, levels=Models3)
BIC_aggregate$Dataset <- factor(BIC_aggregate$Dataset, levels=rev(datasets))

#Divide data per environment
Stable_BIC<-rbind(BIC_aggregate[(BIC_aggregate$Dataset == "Huycke"), ], BIC_aggregate[(BIC_aggregate$Dataset == "Xia"), ], BIC_aggregate[(BIC_aggregate$Dataset == "Goris/Stable"), ])
Reversal_BIC<-rbind(BIC_aggregate[(BIC_aggregate$Dataset == "Online"), ], BIC_aggregate[(BIC_aggregate$Dataset == "Goris/Volatile"), ], BIC_aggregate[(BIC_aggregate$Dataset == "Liu"), ], BIC_aggregate[(BIC_aggregate$Dataset == "Verbeke"), ], BIC_aggregate[(BIC_aggregate$Dataset == "Mukherjee"), ])
Stepwise_BIC<-rbind(BIC_aggregate[(BIC_aggregate$Dataset == "Hein"), ], BIC_aggregate[(BIC_aggregate$Dataset == "Cohen"), ])

#Make plots
BIC_raster_stable<-ggplot(data = Stable_BIC, aes(x=Model, y=as.numeric(Dataset), fill=Value))+
  #geom_contour_fill()+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(0,0.5), oob=squish)+
  scale_x_discrete(labels = c("","","","","",""))+
  theme_classic()+
  scale_y_continuous(breaks = 8:10, labels = c("", "", ""), sec.axis = sec_axis(~ ., breaks = 8:10, labels = rev(ds_labels[1:3])))+
  theme(text = element_text(size=8), plot.title = element_text(size = 10, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 67.5, hjust=1), legend.title = element_text(size = 8), 
        legend.key.size = unit(.33, 'cm'), legend.position = "none" )+
  ggtitle("Model fit\n\n as wBIC")+
  labs(x="")+
  labs(y="")+
  labs(fill="Measure")

BIC_raster_reversal<-ggplot(data = Reversal_BIC, aes(x=Model, y=as.numeric(Dataset), fill=Value))+
  #geom_contour_fill()+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(0,0.5), oob=squish)+
  scale_x_discrete(labels = c("","","","","",""))+
  theme_classic()+
  scale_y_continuous(breaks = 3:7, labels = c("", "", "", "",""), sec.axis = sec_axis(~ ., breaks = 3:7, labels = rev(ds_labels[4:8])))+
  theme(text = element_text(size=8), plot.title = element_text(size = 10, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 67.5, hjust=1), legend.title = element_text(size = 8), 
        legend.key.size = unit(.33, 'cm'), legend.position = "none" )+
  ggtitle("")+
  labs(x="")+
  labs(y="")+
  labs(fill="Measure")

BIC_raster_stepwise<-ggplot(data = Stepwise_BIC, aes(x=Model, y=as.numeric(Dataset), fill=Value))+
  #geom_contour_fill()+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(0,0.5), oob=squish)+
  scale_x_discrete(labels = new_modelnames)+
  theme_classic()+
  scale_y_continuous(breaks = 1:2, labels = c("", ""), sec.axis = sec_axis(~ ., breaks = 1:2, labels = rev(ds_labels[9:10])))+
  theme(text = element_text(size=8), plot.title = element_text(size = 10, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 67.5, hjust=1), legend.title = element_text(size = 8), 
        legend.key.size = unit(.33, 'cm'), legend.position = "none" )+
  ggtitle("")+
  labs(x="Model")+
  labs(y="")+
  labs(fill="Measure")

#This is a combined plot
BIC_raster_full<-ggplot(data = BIC_aggregate, aes(x=Model, y=as.numeric(Dataset), fill=Value))+
  #geom_contour_fill()+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(0,0.5), oob=squish)+
  scale_x_discrete(labels = new_modelnames)+
  theme_classic()+
  scale_y_continuous(breaks = 1:length(datasets), labels= datasets, sec.axis = sec_axis(~ ., breaks = 1:length(datasets), labels = ds_labels))+
  theme(text = element_text(size=8), plot.title = element_text(size = 10, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 67.5, hjust=1), legend.title = element_text(size = 8), 
        legend.key.size = unit(.33, 'cm'), legend.position = "none" )+
  ggtitle("Model fit\n as wBIC")+
  labs(x="Model")+
  labs(y="Datasets")+
  labs(fill="Measure")

#Now, we do this regression for model fit
feature_BIC <-lmer(Outcome ~ (1|Dataset) + Volatility*Mod*ALR*High, Data_BIC)
summary(feature_BIC)
Anova(feature_BIC)

#again specific t-tests
ALR_aggregate <- aggregate(Outcome~Subject*ALR, FUN = mean, data = Data_BIC)
t.test(ALR_aggregate$Outcome~ALR_aggregate$ALR, paired = TRUE)

ALR_aggregate <- aggregate(Outcome~Subject*ALR, FUN = mean, data = Data_BIC[Data_BIC$Volatility=="Stable",])
t.test(ALR_aggregate$Outcome~ALR_aggregate$ALR, paired = TRUE)

ALR_aggregate <- aggregate(Outcome~Subject*ALR, FUN = mean, data = Data_BIC[Data_BIC$Volatility=="Reversal",])
t.test(ALR_aggregate$Outcome~ALR_aggregate$ALR, paired = TRUE)

ALR_aggregate <- aggregate(Outcome~Subject*ALR, FUN = mean, data = Data_BIC[Data_BIC$Volatility=="Stepwise",])
t.test(ALR_aggregate$Outcome~ALR_aggregate$ALR, paired = TRUE)

Mod_aggregate <- aggregate(Outcome~Subject*Mod, FUN = mean, data = Data_BIC)
t.test(Mod_aggregate$Outcome~Mod_aggregate$Mod, paired = TRUE)

Mod_aggregate <- aggregate(Outcome~Subject*Mod, FUN = mean, data = Data_BIC[Data_BIC$Volatility=="Stable",])
t.test(Mod_aggregate$Outcome~Mod_aggregate$Mod, paired = TRUE)

Mod_aggregate <- aggregate(Outcome~Subject*Mod, FUN = mean, data = Data_BIC[Data_BIC$Volatility=="Reversal",])
t.test(Mod_aggregate$Outcome~Mod_aggregate$Mod, paired = TRUE)

Mod_aggregate <- aggregate(Outcome~Subject*Mod, FUN = mean, data = Data_BIC[Data_BIC$Volatility=="Stepwise",])
t.test(Mod_aggregate$Outcome~Mod_aggregate$Mod, paired = TRUE)

High_aggregate <- aggregate(Outcome~Subject*High, FUN = mean, data = Data_BIC)
t.test(High_aggregate$Outcome~High_aggregate$High, paired = TRUE)

High_aggregate <- aggregate(Outcome~Subject*High, FUN = mean, data = Data_BIC[Data_BIC$Volatility=="Stable",])
t.test(High_aggregate$Outcome~High_aggregate$High, paired = TRUE)

High_aggregate <- aggregate(Outcome~Subject*High, FUN = mean, data = Data_BIC[Data_BIC$Volatility=="Reversal",])
t.test(High_aggregate$Outcome~High_aggregate$High, paired = TRUE)

High_aggregate <- aggregate(Outcome~Subject*High, FUN = mean, data = Data_BIC[Data_BIC$Volatility=="Stepwise",])
t.test(High_aggregate$Outcome~High_aggregate$High, paired = TRUE)

#Summarize data per model feature and environment
BIC_IEVolMod <- summarySE(data = Data_BIC, "Outcome", groupvars = c("Mod", "Volatility"), conf.interval = 0.95)
BIC_IEVolMod$Volatility <- factor(BIC_IEVolMod$Volatility, levels=c("Stable", "Reversal", "Stepwise"))
BIC_IEVolALR <- summarySE(data = Data_BIC, "Outcome", groupvars = c("ALR", "Volatility"), conf.interval = 0.95)
BIC_IEVolALR$Volatility <- factor(BIC_IEVolALR$Volatility, levels=c("Stable", "Reversal", "Stepwise"))
BIC_IEVolHigh <- summarySE(data = Data_BIC, "Outcome", groupvars = c("High", "Volatility"), conf.interval = 0.95)
BIC_IEVolHigh$Volatility <- factor(BIC_IEVolHigh$Volatility, levels=c("Stable", "Reversal", "Stepwise"))

#Make plots
VolMod_plotBIC <- ggplot(BIC_IEVolMod, aes(y=Outcome, x = Volatility, colour = Mod, group = Mod))+ 
  geom_point(size = 2, position = position_dodge2(.2))+
  geom_errorbar(aes(ymin=Outcome-ci, ymax = Outcome+ci), width = .1, size =1, position = position_dodge(.2))+
  ggtitle("")+
  coord_cartesian(ylim = c(0, 0.4))+
  ylab("")+
  xlab("")+
  scale_colour_discrete(name = "Feature present", labels=c("0" = "No", "1" = "Yes"))+
  theme_classic()+
  theme(text = element_text(size=8),plot.title = element_text(size = 8, face = "italic", hjust=0.5, family="Times"), axis.text.x = element_text(angle = 45, hjust=1))

VolALR_plotBIC <- ggplot(BIC_IEVolALR, aes(y=Outcome, x = Volatility, colour = ALR, group = ALR))+ 
  geom_point(size = 2, position = position_dodge2(.2))+
  geom_errorbar(aes(ymin=Outcome-ci, ymax = Outcome+ci), width = .1, size =1, position = position_dodge(.2))+
  ggtitle("Model fit\n\n as wBIC")+
  coord_cartesian(ylim = c(0, 0.4))+
  ylab("")+
  xlab("")+
  scale_colour_discrete(name = "Feature present", labels=c("0" = "No", "1" = "Yes"))+
  theme_classic()+
  theme(text = element_text(size=8),plot.title = element_text(size = 8, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 45, hjust=1))

VolHigh_plotBIC <- ggplot(BIC_IEVolHigh, aes(y=Outcome, x = Volatility, colour = High, group = High))+ 
  geom_point(size = 2, position = position_dodge2(.2))+
  geom_errorbar(aes(ymin=Outcome-ci, ymax = Outcome+ci), width = .1, size =1, position = position_dodge(.2))+
  ylab("")+
  coord_cartesian(ylim = c(0, 0.4))+
  ylab("")+
  xlab("Environments")+
  scale_colour_discrete(name = "Feature present", labels=c("0" = "No", "1" = "Yes"))+
  theme_classic()+
  theme(text = element_text(size=8),plot.title = element_text(size = 8, face = "italic", hjust=0.5, family="Times"), axis.text.x = element_text(angle = 45, hjust=1))

#Aggregate data for LL
LL_aggregate<-aggregate(Data_LL$Outcome, by = list(Data_LL$Dataset, Data_LL$Model), FUN = mean)
colnames(LL_aggregate) <-c("Dataset", "Model", "Value")
LL_aggregate$Model <- factor(LL_aggregate$Model, levels=Models3)
LL_aggregate$Dataset <- factor(LL_aggregate$Dataset, levels=rev(datasets))

#Divide data per environment
Stable_LL<-rbind(LL_aggregate[(LL_aggregate$Dataset == "Huycke"), ], LL_aggregate[(LL_aggregate$Dataset == "Xia"), ], LL_aggregate[(LL_aggregate$Dataset == "Goris/Stable"), ])
Reversal_LL<-rbind(LL_aggregate[(LL_aggregate$Dataset == "Online"), ], LL_aggregate[(LL_aggregate$Dataset == "Goris/Volatile"), ], LL_aggregate[(LL_aggregate$Dataset == "Liu"), ], LL_aggregate[(LL_aggregate$Dataset == "Verbeke"), ], LL_aggregate[(LL_aggregate$Dataset == "Mukherjee"), ])
Stepwise_LL<-rbind(LL_aggregate[(LL_aggregate$Dataset == "Hein"), ], LL_aggregate[(LL_aggregate$Dataset == "Cohen"), ])

#Make plots
LL_raster_stable<-ggplot(data = Stable_LL, aes(x=Model, y=as.numeric(Dataset), fill=Value))+
  #geom_contour_fill()+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(0,0.5), oob=squish)+
  scale_x_discrete(labels = c("","","","","",""))+
  theme_classic()+
  scale_y_continuous(breaks = 8:10, labels= rev(datasets[1:3]))+
  theme(text = element_text(size=8), plot.title = element_text(size = 10, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 67.5, hjust=1), legend.title = element_text(size = 8), 
        legend.key.size = unit(.33, 'cm'), legend.position = "none" )+
  ggtitle("Model fit\n\n as wLL")+
  labs(x="")+
  labs(y="")+
  labs(fill="Measure")

LL_raster_reversal<-ggplot(data = Reversal_LL, aes(x=Model, y=as.numeric(Dataset), fill=Value))+
  #geom_contour_fill()+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(0,0.5), oob=squish)+
  scale_x_discrete(labels = c("","","","","",""))+
  theme_classic()+
  scale_y_continuous(breaks = 3:7, labels= rev(datasets[4:8]))+
  theme(text = element_text(size=8), plot.title = element_text(size = 10, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 67.5, hjust=1), legend.title = element_text(size = 8), 
        legend.key.size = unit(.33, 'cm'), legend.position = "left" )+
  ggtitle("")+
  labs(x="")+
  labs(y="")+
  labs(fill="Measure")

LL_raster_stepwise<-ggplot(data = Stepwise_LL, aes(x=Model, y=as.numeric(Dataset), fill=Value))+
  #geom_contour_fill()+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(0,0.5), oob=squish)+
  scale_x_discrete(labels = new_modelnames)+
  theme_classic()+
  scale_y_continuous(breaks = 1:2, labels= rev(datasets[9:10]))+
  theme(text = element_text(size=8), plot.title = element_text(size = 10, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 67.5, hjust=1), legend.title = element_text(size = 8), 
        legend.key.size = unit(.33, 'cm'), legend.position = "none" )+
  ggtitle("")+
  labs(x="Model")+
  labs(y="")+
  labs(fill="Measure")

#This is a combined plot
LL_raster_full<-ggplot(data = LL_aggregate, aes(x=Model, y=as.numeric(Dataset), fill=Value))+
  #geom_contour_fill()+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(0,0.5), oob=squish)+
  scale_x_discrete(labels = new_modelnames)+
  theme_classic()+
  scale_y_continuous(breaks = 1:length(datasets), labels= datasets, sec.axis = sec_axis(~ ., breaks = 1:length(datasets), labels = ds_labels))+
  theme(text = element_text(size=8), plot.title = element_text(size = 10, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 67.5, hjust=1), legend.title = element_text(size = 8), 
        legend.key.size = unit(.33, 'cm'), legend.position = "none" )+
  ggtitle("Model fit\n as wLL")+
  labs(x="Model")+
  labs(y="Datasets")+
  labs(fill="Measure")

#Now, we do this regression for model fit
feature_LL <-lmer(Outcome ~ (1|Dataset) + Volatility*Mod*ALR*High, Data_LL)
summary(feature_LL)
Anova(feature_LL)

#specific t-tests
ALR_aggregate <- aggregate(Outcome~Subject*ALR, FUN = mean, data = Data_LL)
t.test(ALR_aggregate$Outcome~ALR_aggregate$ALR, paired = TRUE)

ALR_aggregate <- aggregate(Outcome~Subject*ALR, FUN = mean, data = Data_LL[Data_LL$Volatility=="Stable",])
t.test(ALR_aggregate$Outcome~ALR_aggregate$ALR, paired = TRUE)

ALR_aggregate <- aggregate(Outcome~Subject*ALR, FUN = mean, data = Data_LL[Data_LL$Volatility=="Reversal",])
t.test(ALR_aggregate$Outcome~ALR_aggregate$ALR, paired = TRUE)

ALR_aggregate <- aggregate(Outcome~Subject*ALR, FUN = mean, data = Data_LL[Data_LL$Volatility=="Stepwise",])
t.test(ALR_aggregate$Outcome~ALR_aggregate$ALR, paired = TRUE)

Mod_aggregate <- aggregate(Outcome~Subject*Mod, FUN = mean, data = Data_LL)
t.test(Mod_aggregate$Outcome~Mod_aggregate$Mod, paired = TRUE)

Mod_aggregate <- aggregate(Outcome~Subject*Mod, FUN = mean, data = Data_LL[Data_LL$Volatility=="Stable",])
t.test(Mod_aggregate$Outcome~Mod_aggregate$Mod, paired = TRUE)

Mod_aggregate <- aggregate(Outcome~Subject*Mod, FUN = mean, data = Data_LL[Data_LL$Volatility=="Reversal",])
t.test(Mod_aggregate$Outcome~Mod_aggregate$Mod, paired = TRUE)

Mod_aggregate <- aggregate(Outcome~Subject*Mod, FUN = mean, data = Data_LL[Data_LL$Volatility=="Stepwise",])
t.test(Mod_aggregate$Outcome~Mod_aggregate$Mod, paired = TRUE)

High_aggregate <- aggregate(Outcome~Subject*High, FUN = mean, data = Data_LL)
t.test(High_aggregate$Outcome~High_aggregate$High, paired = TRUE)

High_aggregate <- aggregate(Outcome~Subject*High, FUN = mean, data = Data_LL[Data_LL$Volatility=="Stable",])
t.test(High_aggregate$Outcome~High_aggregate$High, paired = TRUE)

High_aggregate <- aggregate(Outcome~Subject*High, FUN = mean, data = Data_LL[Data_LL$Volatility=="Reversal",])
t.test(High_aggregate$Outcome~High_aggregate$High, paired = TRUE)

High_aggregate <- aggregate(Outcome~Subject*High, FUN = mean, data = Data_LL[Data_LL$Volatility=="Stepwise",])
t.test(High_aggregate$Outcome~High_aggregate$High, paired = TRUE)


#Summarize data per model feature and environment
LL_IEVolMod <- summarySE(data = Data_LL, "Outcome", groupvars = c("Mod", "Volatility"), conf.interval = 0.95)
LL_IEVolMod$Volatility <- factor(LL_IEVolMod$Volatility, levels=c("Stable", "Reversal", "Stepwise"))
LL_IEVolALR <- summarySE(data = Data_LL, "Outcome", groupvars = c("ALR", "Volatility"), conf.interval = 0.95)
LL_IEVolALR$Volatility <- factor(LL_IEVolALR$Volatility, levels=c("Stable", "Reversal", "Stepwise"))
LL_IEVolHigh <- summarySE(data = Data_LL, "Outcome", groupvars = c("High", "Volatility"), conf.interval = 0.95)
LL_IEVolHigh$Volatility <- factor(LL_IEVolHigh$Volatility, levels=c("Stable", "Reversal", "Stepwise"))

#Make plots
VolMod_plotLL <- ggplot(LL_IEVolMod, aes(y=Outcome, x = Volatility, colour = Mod, group = Mod))+ 
  geom_point(size = 2, position = position_dodge2(.2))+
  geom_errorbar(aes(ymin=Outcome-ci, ymax = Outcome+ci), width = .1, size =1, position = position_dodge(.2))+
  ggtitle("")+
  coord_cartesian(ylim = c(0, 0.4))+
  ylab("Multiple rule sets")+
  xlab("")+
  scale_colour_discrete(name = "Feature present", labels=c("0" = "No", "1" = "Yes"))+
  theme_classic()+
  theme(text = element_text(size=8),plot.title = element_text(size = 8, face = "italic", hjust=0.5, family="Times"), axis.text.x = element_text(angle = 45, hjust=1))

VolALR_plotLL <- ggplot(LL_IEVolALR, aes(y=Outcome, x = Volatility, colour = ALR, group = ALR))+ 
  geom_point(size = 2, position = position_dodge2(.2))+
  geom_errorbar(aes(ymin=Outcome-ci, ymax = Outcome+ci), width = .1, size =1, position = position_dodge(.2))+
  ggtitle("Model fit\n\n as wLL")+
  coord_cartesian(ylim = c(0, 0.4))+
  ylab("Adaptive learning rate")+
  xlab("")+
  scale_colour_discrete(name = "Feature present", labels=c("0" = "No", "1" = "Yes"))+
  theme_classic()+
  theme(text = element_text(size=8),plot.title = element_text(size = 8, face = "bold", hjust=0.5), axis.text.x = element_text(angle = 45, hjust=1))

VolHigh_plotLL <- ggplot(LL_IEVolHigh, aes(y=Outcome, x = Volatility, colour = High, group = High))+ 
  geom_point(size = 2, position = position_dodge2(.2))+
  geom_errorbar(aes(ymin=Outcome-ci, ymax = Outcome+ci), width = .1, size =1, position = position_dodge(.2))+
  ylab("Hierarchical learning")+
  coord_cartesian(ylim = c(0, 0.4))+
  xlab("Environments")+
  scale_colour_discrete(name = "Feature present", labels=c("0" = "No", "1" = "Yes"))+
  theme_classic()+
  theme(text = element_text(size=8),plot.title = element_text(size = 8, face = "italic", hjust=0.5, family="Times"), axis.text.x = element_text(angle = 45, hjust=1))

Model_grids_big<-ggdraw() +
  draw_plot(LL_raster_stepwise, x = .17, y = .0, width = .26, height = .375) +
  draw_plot(LL_raster_reversal, x = 0, y = .29, width = .43, height = .415) +
  draw_plot(LL_raster_stable, x = .135, y = .62, width = .295, height = .38) +
  draw_plot(AIC_raster_stepwise, x = .43, y = .0, width = .22, height = .375) +
  draw_plot(AIC_raster_reversal, x = .43, y = .295, width = .22, height = .415) +
  draw_plot(AIC_raster_stable, x = .43, y = .62, width = .22, height = .38) +
  draw_plot(BIC_raster_stepwise, x = .65, y = .0, width = .34, height = .375) +
  draw_plot(BIC_raster_reversal, x = .65, y = .295, width = .35, height = .415) +
  draw_plot(BIC_raster_stable, x = .65, y = .62, width = .34, height = .38) +
  draw_plot_label(label = c("A","B", "C"), x=c(0.2,0.45,.675),y=c(.975,.975,.975), size = 10,fontface="bold")

ggsave("Grid_fit_all.jpg", Model_grids_big, device = "jpeg", width = 15, height = 10, units = "cm", dpi = 300)

Feature_plot_bis <- ggarrange(VolALR_plotLL, VolALR_plotBIC, VolMod_plotLL, VolMod_plotBIC, VolHigh_plotLL, VolHigh_plotBIC, ncol = 2, nrow = 3, common.legend = TRUE, heights=c(1,1), widths=c(1, 1, 1), labels = c("A", "B", "C","D", "E", "F"))
ggsave("Feature_Volatility_bis.jpg", Feature_plot_bis, device = "jpeg", width = 12, height = 15, units = "cm", dpi = 300)

