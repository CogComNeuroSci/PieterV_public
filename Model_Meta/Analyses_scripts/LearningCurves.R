# clear console and load libraries
cat("\014")
rm(list = ls())

library(Rmisc)
library(ggplot2)
library(ggpubr)
library(car)
library(Rmisc)
library(lmerTest) 
library(cowplot)

#set variable names
Models<- c("RW", "ALR" , "Mod", "ALR_mod", "Higher_mod", "Full")
new_modelnames <- c("Flat", "ALR", "Sets", "Sets_ALR", "Sets_learning", "Full")
nModels = length(Models)

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
Fitfolder = "/Users/pieter/Desktop/Model_study/Fitted_data/"
setwd(Fitfolder)
Data<-read.csv(" all_data.csv", header = TRUE)

#Make sure that variables are coded correctly
Data$Reward<-as.numeric(Data$Reward)
Data$Mod<-as.factor(Data$Mod)
Data$ALR<-as.factor(Data$ALR)
Data$High<-as.factor(Data$High)
Data$Subject<-as.factor(Data$Subject)

#Get AIC data
Data_AIC <- Data[Data$Measure=="AIC",]
AIC_aggregate<-aggregate(Data_AIC$Outcome, by = list(Data_AIC$Dataset, Data_AIC$Model), FUN = mean)
colnames(AIC_aggregate) <-c("Dataset", "Model", "Value")

Plot_data = list()
plot_id = 0

for (ds in datasets){
  
  plot_id = plot_id +1
  Homefolder = paste(Fitfolder , ds, "/", sep ="")
  
  setwd(Homefolder)
  
  Model_weights <- AIC_aggregate[AIC_aggregate$Dataset==ds,]
  Best_model = Model_weights$Model[which.max(Model_weights$Value)]
  Worst_model = Model_weights$Model[which.min(Model_weights$Value)]
  
  print(ds)
  print(Best_model)
  print(Worst_model)
  
  BM_id = which(Models %in% Best_model)
  WM_id = which(Models %in% Worst_model)
  
  #Reading in and combining data
  BM_fitdata <- read.delim(paste("Fit_data_", Models[BM_id], ".csv", sep = ""), header = TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE) 
  WM_fitdata <- read.delim(paste("Fit_data_", Models[WM_id], ".csv", sep = ""), header = TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE) 
  
  #Removing subjects that were below chance level
  if (ds =="Xia"){
    BM_fitdata <- BM_fitdata[!(BM_fitdata$Subject %in% below_chance_xia), ]
  }
  if (ds =="Verbeke"){
    BM_fitdata <- BM_fitdata[!(BM_fitdata$Subject %in% below_chance_Verbeke), ]
  }
  if (ds =="Goris/Stable"){
    BM_fitdata <- BM_fitdata[!(BM_fitdata$Subject %in% below_chance_goris_stable), ]
    BM_fitdata <- BM_fitdata[BM_fitdata$Subject %in% stable_starters_goris, ]
  }
  if (ds =="Goris/Volatile"){
    BM_fitdata <- BM_fitdata[!(BM_fitdata$Subject %in% below_chance_goris_volatile), ]
    BM_fitdata <- BM_fitdata[BM_fitdata$Subject %in% volatile_starters_goris, ]
  }
  if (ds =="Mukherjee"){
    BM_fitdata <- BM_fitdata[!(BM_fitdata$Subject %in% below_chance_Mukherjee), ]
    pplist_mukherjee = unique(BM_fitdata$Subject)
  }
  
  pplist = unique(BM_fitdata$Subject)
  
  #Get model parameter and fit data for each subject and each model
  for (p in pplist){
    if (p == pplist[1]){
      BM_Data<-read.delim(paste("Data_subject_", p, "_", BM_id-1,".csv", sep = ""), header = TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)
      WM_Data<-read.delim(paste("Data_subject_", p, "_", WM_id-1,".csv", sep = ""), header = TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)
      Average_accuracy <-mean((BM_Data$Response == BM_Data$CorResp)*1)
      
      BM_Data$acc <- (BM_Data$Response == BM_Data$CorResp)*1
      WM_Data$acc <- (WM_Data$Response == WM_Data$CorResp)*1
      
      BM_Data$macc <- Average_accuracy
      WM_Data$macc <- Average_accuracy
      
      if (ds =="Goris/Stable"){
        BM_Data$Rule <- 0
      }
      
      lt = 0
      for (t in 1:nrow(BM_Data)){
        if (t==1){
          lt = 0
        }else if (BM_Data$Rule[t]!=BM_Data$Rule[t-1]){
          lt = 0
        }else{
          lt = lt+1  
        }
        BM_Data$lid[t] = lt
        WM_Data$lid[t] = lt
        if (BM_Data$acc[t] ==1){
          BM_Data$corlik[t] = BM_Data$Response_likelihood[t]
          WM_Data$corlik[t] = WM_Data$Response_likelihood[t]
        }else{
          BM_Data$corlik[t] = 1 - BM_Data$Response_likelihood[t]
          WM_Data$corlik[t] = 1 - WM_Data$Response_likelihood[t]
        }
        BM_Data$RSS[t] = (BM_Data$acc[t] - BM_Data$corlik[t])^2
        WM_Data$RSS[t] = (WM_Data$acc[t] - WM_Data$corlik[t])^2
        
        BM_Data$TSS[t] = (BM_Data$acc[t] - BM_Data$macc[t])^2
        WM_Data$TSS[t] = (WM_Data$acc[t] - WM_Data$macc[t])^2
      }
      
    }else{
      BM_d<-read.delim(paste("Data_subject_", p, "_", BM_id-1,".csv", sep = ""), header = TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)
      WM_d<-read.delim(paste("Data_subject_", p, "_", WM_id-1,".csv", sep = ""), header = TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)
    
      #Sometimes there was for some reason one column to much at the start, hence we remove it
      if (length(BM_d)>12){
        BM_d <- BM_d[,c(1,3:13)]
      }
      if (length(WM_d)>12){
        WM_d <- WM_d[,c(1,3:13)]
      }
      
      Accuracy<-(BM_d$Response == BM_d$CorResp)*1
      
      BM_d$acc <- Accuracy
      WM_d$acc <- Accuracy
      
      BM_d$macc <- mean(Accuracy)
      WM_d$macc <- mean(Accuracy)
      
      if (ds =="Goris/Stable"){
        BM_d$Rule <- 0
      }
      
      lt = 0
      for (t in 1:nrow(BM_d)){
        if (t==1){
          lt = 0
        }else if (BM_d$Rule[t]!=BM_d$Rule[t-1]){
          lt = 0
        }else{
          lt = lt+1  
        }
        BM_d$lid[t] = lt
        WM_d$lid[t] = lt
        
        if (BM_d$acc[t] ==1){
          BM_d$corlik[t] = BM_d$Response_likelihood[t]
          WM_d$corlik[t] = WM_d$Response_likelihood[t]
        }else{
          BM_d$corlik[t] = 1 - BM_d$Response_likelihood[t]
          WM_d$corlik[t] = 1 - WM_d$Response_likelihood[t]
        }
        BM_d$RSS[t] = (BM_d$acc[t] - BM_d$corlik[t])^2
        WM_d$RSS[t] = (WM_d$acc[t] - WM_d$corlik[t])^2
        
        BM_d$TSS[t] = (BM_d$acc[t] - BM_d$macc[t])^2
        WM_d$TSS[t] = (WM_d$acc[t] - WM_d$macc[t])^2
      }
      
      Average_accuracy <- rbind(Average_accuracy, mean(Accuracy))
      BM_Data <-rbind(BM_Data, BM_d)
      WM_Data <-rbind(WM_Data, WM_d)
    }
  } 
  
  print(mean(Average_accuracy))
  
  #extract data from behavior, the best fitting model and the worst fitting model for plotting
  Behavior_plot = summarySE(data = BM_Data[BM_Data$lid<30, ], measurevar = "acc", groupvar = "lid", na.rm = TRUE)
  Best_model_plot = summarySE(data = BM_Data[BM_Data$lid<30, ], measurevar = "corlik", groupvar = "lid", na.rm = TRUE)
  Worst_model_plot = summarySE(data = WM_Data[BM_Data$lid<30, ], measurevar = "corlik", groupvar = "lid", na.rm = TRUE)
  
  Plot_data[[plot_id]] <- cbind(Behavior_plot[, c(1,2,3,6)], Best_model_plot[, c(3,6)], Worst_model_plot[, c(3,6)])
  colnames(Plot_data[[plot_id]]) <- c("Trial", "Subjects", "Accuracy", "Accuracy_CI", "Lik_BM", "CI_BM", "Lik_WM", "CI_WM")
  print(plot_id)

}

#Plot everything
plot_list = list()
for (plots in 1:length(datasets)){
  if (plots == 8){
    plot <- ggplot(data = Plot_data[[plots]])+
      geom_pointrange(aes(y=Accuracy, x = Trial, ymin = Accuracy - Accuracy_CI, ymax =  Accuracy + Accuracy_CI, color = "Behavioural data"), size = .5)+
      geom_line(aes(y=Lik_BM, x = Trial, color = "Best fitting model"))+
      geom_ribbon(aes(ymin=Lik_BM - CI_BM, ymax= Lik_BM + CI_BM, x = Trial), fill = "red", alpha = .5)+
      #geom_line(aes(y=Lik_WM, x = Trial, color = "Worst fitting model"))+
      #geom_ribbon(aes(ymin=Lik_WM - CI_WM, ymax= Lik_WM + CI_WM, x = Trial), fill = "blue" , alpha = .5)+
      theme_classic()+
      ggtitle(paste(datasets[plots], ds_labels[plots]))+
      xlab("Trials")+
      scale_color_manual(name = "", values = c("Best fitting model" = "red","Behavioural data" = "black")) +
      #scale_color_manual(name = "", values = c("Best fitting model" = "red", "Worst fitting model" = "blue", "Behavioural data" = "black")) +
      ylab("P(a[optimal])")+
      theme(text = element_text(size=8),plot.title = element_text(size = 8, face = "italic", hjust=0.5, family="Times"))
  }else if (plots %in% c(1,4)){
    plot <- ggplot(data = Plot_data[[plots]])+
      geom_pointrange(aes(y=Accuracy, x = Trial, ymin = Accuracy - Accuracy_CI, ymax =  Accuracy + Accuracy_CI, color = "Behavioural data"), size = .5)+
      geom_line(aes(y=Lik_BM, x = Trial, color = "Best fitting model"))+
      geom_ribbon(aes(ymin=Lik_BM - CI_BM, ymax= Lik_BM + CI_BM, x = Trial), fill = "red", alpha = .5)+
      #geom_line(aes(y=Lik_WM, x = Trial, color = "Worst fitting model"))+
      #geom_ribbon(aes(ymin=Lik_WM - CI_WM, ymax= Lik_WM + CI_WM, x = Trial), fill = "blue" , alpha = .5)+
      theme_classic()+
      ggtitle(paste(datasets[plots], ds_labels[plots]))+
      xlab("Trials")+
      scale_color_manual(name = "", values = c("Best fitting model" = "red","Behavioural data" = "black")) +
      #scale_color_manual(name = "", values = c("Best fitting model" = "red", "Worst fitting model" = "blue", "Behavioural data" = "black")) +
      ylab("P(a[optimal])")+
      theme(text = element_text(size=8),plot.title = element_text(size = 8, face = "italic", hjust=0.5, family="Times"), legend.position = "None" )
  }else{
    plot <- ggplot(data = Plot_data[[plots]])+
      geom_pointrange(aes(y=Accuracy, x = Trial, ymin = Accuracy - Accuracy_CI, ymax =  Accuracy + Accuracy_CI, color = "Behavioural data"), size = .5)+
      geom_line(aes(y=Lik_BM, x = Trial, color = "Best fitting model"))+
      geom_ribbon(aes(ymin=Lik_BM - CI_BM, ymax= Lik_BM + CI_BM, x = Trial), fill = "red", alpha = .5)+
      #geom_line(aes(y=Lik_WM, x = Trial, color = "Worst fitting model"))+
      #geom_ribbon(aes(ymin=Lik_WM - CI_WM, ymax= Lik_WM + CI_WM, x = Trial), fill = "blue" , alpha = .5)+
      theme_classic()+
      ggtitle(paste(datasets[plots], ds_labels[plots]))+
      xlab("Trials")+
      scale_color_manual(name = "", values = c("Best fitting model" = "red","Behavioural data" = "black")) +
      #scale_color_manual(name = "", values = c("Best fitting model" = "red", "Worst fitting model" = "blue", "Behavioural data" = "black")) +
      ylab("")+
      theme(text = element_text(size=8),plot.title = element_text(size = 8, face = "italic", hjust=0.5, family="Times"), legend.position = "None" )
    }

  plot_list[[plots]] = plot
}

setwd("/Users/pieter/Desktop/Model_Study/Analyses_results/")
final_curve_plot <- ggarrange(plot_list[[1]], plot_list[[2]], plot_list[[3]],plot_list[[4]],plot_list[[5]],plot_list[[6]],plot_list[[7]],plot_list[[8]],plot_list[[9]],plot_list[[10]], common.legend = TRUE)
ggsave("Learning_curves.jpg", final_curve_plot, device = "jpeg", width = 19, height = 15, units = "cm", dpi = 300)

## Dynamics,fit for supplementary materials
dataset = "Mukherjee"
setwd("/Users/pieter/Desktop/Model_study/Fitted_data/Mukherjee")

for (i in 1:length(Models)){
  Fit_dat <- read.delim(paste("Fit_Data_",Models[i],".csv", sep = ""), header = TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)
  Fit_dat[order(Fit_dat$LogLik), c(3,9)]
  for (p in pplist_mukherjee){
    if (i == 1 && p == pplist_mukherjee[1]){
      Dynamic_data<-read.delim(paste("Data_subject_", p, "_", i-1,".csv", sep = ""), header = TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)
      Dynamic_data$Model <- new_modelnames [i]
      Dynamic_data$Subject <- p
      Dynamic_data$Perc <- round(((64 - which(Fit_dat[order(Fit_dat$LogLik), c(3,9)] == p))/64)*100)
      if (Dynamic_data$CorResp[1] ==1){
        Dynamic_data$CorResp <- -1*Dynamic_data$CorResp +1
        Dynamic_data$Response <- -1*Dynamic_data$Response +1
      }
      Dynamic_data$Response <- Dynamic_data$Response
      Dynamic_data$CorResp <- Dynamic_data$CorResp
    }else{
      d <- read.delim(paste("Data_subject_", p, "_", i-1,".csv", sep = ""), header = TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)
      d$Model <- new_modelnames[i]
      d$Subject <-p
      d$Perc <- ceiling((which(Fit_dat[order(Fit_dat$LogLik), c(3,9)] == p)/64)*100)
      
      if (d$CorResp[1] ==1){
        d$CorResp <- -1*d$CorResp +1
        d$Response <- -1*d$Response +1
      }
      
      d$Response <- d$Response #+i*2
      d$CorResp <- d$CorResp #+i*2
      Dynamic_data <- rbind(Dynamic_data, d )
    }
  }
}

dynamics_list = list()
cond <- c(4,50,100)
subs <- c(37, 46, 29)
ppex <- c("worst", "median", "best")
plotcount = 0
for (j in 1:length(Models)){
  dat <- Dynamic_data[Dynamic_data$Model == new_modelnames[j],]
  cond <-c(min(dat$Perc), 50, max(dat$Perc))
  for (i in 1:3){
    plotcount = plotcount +1
    datperc<- dat[dat$Subject == subs[i],]
    datperc$pred_response[datperc$Response ==1] <- datperc$Response_likelihood[datperc$Response ==1]
    datperc$pred_response[datperc$Response ==0] <- 1-datperc$Response_likelihood[datperc$Response ==0] 
    
    if (j==6){
      if (i==1){
        pl <- ggplot(data = datperc, aes(y = Response, x = X))+
          geom_vline(xintercept = 30, colour = "grey", size = 1)+
          geom_vline(xintercept = 60, colour = "grey", size = 1)+
          geom_point( colour = "black", shape = 4, size =1)+
          geom_line(aes(y = pred_response), colour = "red", alpha = .5, size = 1)+
          scale_y_continuous(breaks = 0:1, labels = c("Left", "Right"))+
          theme_classic()+
          ggtitle(paste(new_modelnames[j], "model\non", ppex[i], "performing participant"))+
          xlab("Trial")+
          ylab("Response")+
          theme(text = element_text(size=8),plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))
      }else{
        pl <- ggplot(data = datperc, aes(y = Response, x = X))+
          geom_vline(xintercept = 30, colour = "grey", size = 1)+
          geom_vline(xintercept = 60, colour = "grey", size = 1)+
          geom_point( colour = "black", shape = 4, size =1)+
          geom_line(aes(y = pred_response), colour = "red", alpha = .5, size = 1)+
          scale_y_continuous(breaks = 0:1, labels = c("Left", "Right"))+
          theme_classic()+
          ggtitle(paste(new_modelnames[j], "model\non", ppex[i], "performing participant"))+
          xlab("Trial")+
          ylab("")+
          theme(text = element_text(size=8),plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))
      }
    }else {
      if (i==1){
        pl <- ggplot(data = datperc, aes(y = Response, x = X))+
          geom_vline(xintercept = 30, colour = "grey", size = 1)+
          geom_vline(xintercept = 60, colour = "grey", size = 1)+
          geom_point( colour = "black", shape = 4, size =1)+
          geom_line(aes(y = pred_response), colour = "red", alpha = .5, size = 1)+
          scale_y_continuous(breaks = 0:1, labels = c("Left", "Right"))+
          theme_classic()+
          ggtitle(paste(new_modelnames[j], "model\non", ppex[i], "performing participant"))+
          xlab("")+
          ylab("Response")+
          theme(text = element_text(size=8),plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))
      }else{
        pl <- ggplot(data = datperc, aes(y = Response, x = X))+
          geom_vline(xintercept = 30, colour = "grey", size = 1)+
          geom_vline(xintercept = 60, colour = "grey", size = 1)+
          geom_point( colour = "black", shape = 4, size =1)+
          geom_line(aes(y = pred_response), colour = "red", alpha = .5, size = 1)+
          scale_y_continuous(breaks = 0:1, labels = c("Left", "Right"))+
          theme_classic()+
          ggtitle(paste(new_modelnames[j], "model\non", ppex[i], "performing participant"))+
          xlab("")+
          ylab("")+
          theme(text = element_text(size=8),plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))
      }
    }

    dynamics_list[[plotcount]] <- pl
  }
}

setwd("/Users/pieter/Desktop/Model_Study/Analyses_results/")
Dynamic_plot<- ggarrange(dynamics_list[[1]], dynamics_list[[2]], dynamics_list[[3]], dynamics_list[[4]], dynamics_list[[5]], dynamics_list[[6]], dynamics_list[[7]], dynamics_list[[8]], dynamics_list[[9]], dynamics_list[[10]], dynamics_list[[11]], dynamics_list[[12]], dynamics_list[[13]], dynamics_list[[14]], dynamics_list[[15]], dynamics_list[[16]], dynamics_list[[17]], dynamics_list[[18]], ncol = 3, nrow = 6, labels = "AUTO")
ggsave("Dynamics_fit.jpg", Dynamic_plot, device = "jpeg", width = 17, height = 20, units = "cm", dpi = 300)

## Dynamics performance
setwd("/Users/pieter/Desktop/Model_study/Optimize_models/Mukherjee")

for (i in 1:length(Models)){
  for (p in pplist_mukherjee){
    if (i == 1 && p == pplist_mukherjee[1]){
      Dynamic_data<-read.delim(paste("Data_subject_", p, "_", i-1,".csv", sep = ""), header = TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)
      Dynamic_data$Model <- new_modelnames [i]
      Dynamic_data$Subject <- p
      Dynamic_data$ACC <- mean((Dynamic_data$Response == Dynamic_data$CorResp)*1)
      if (Dynamic_data$CorResp[1] ==1){
        Dynamic_data$CorResp <- -1*Dynamic_data$CorResp +1
        Dynamic_data$Response <- -1*Dynamic_data$Response +1
        Dynamic_data$ResponseLL <- 1-Dynamic_data$Response_likelihood
        Dynamic_data$Rule <- -1*Dynamic_data$Rule +1
      }else{
        Dynamic_data$Response <- Dynamic_data$Response
        Dynamic_data$ResponseLL <- 1-Dynamic_data$Response_likelihood
        Dynamic_data$CorResp <- Dynamic_data$CorResp
      }
    }else{
      d <- read.delim(paste("Data_subject_", p, "_", i-1,".csv", sep = ""), header = TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)
      d$Model <- new_modelnames[i]
      d$Subject <-p
      d$ACC <- mean((d$Response == d$CorResp)*1)
      
      if (d$CorResp[1] ==1){
        d$CorResp <- -1*d$CorResp +1
        d$Response <- -1*d$Response +1
        d$ResponseLL <- d$Response_likelihood
        d$Rule <- -1*d$Rule +1
      }else{
        d$Response <- d$Response #+i*2
        d$ResponseLL <- 1-d$Response_likelihood
        d$CorResp <- d$CorResp #+i*2
      }
      Dynamic_data <- rbind(Dynamic_data, d )
    }
  }
}

dynamics_list_performance = list()
cond <- c(4,50,100)
ppex <- c("worst", "median", "best")
plotcount = 0
for (j in 1:length(Models)){
  dat <- Dynamic_data[Dynamic_data$Model == new_modelnames[j],]
  cond <-c(min(dat$ACC), median(dat$ACC), max(dat$ACC))
  print(cond)
  for (i in 1:3){
    plotcount = plotcount +1
    datperc <- dat[dat$ACC == cond[i],]
    if (nrow(datperc) ==0){
      dat$min_i <- abs(cond[i] - dat$ACC)
      datperc<- dat[dat$min_i == min(dat$min_i),]
    }
    if (nrow(datperc) >90){
      datperc <- datperc[1:90,]
    }
    print(nrow(datperc))
    
    if (j==6){
      if (i==1){
        pl <- ggplot(data = datperc, aes(y = ResponseLL, x = X))+
          geom_vline(xintercept = 30, colour = "grey", size = 1)+
          geom_vline(xintercept = 60, colour = "grey", size = 1)+
          geom_point( colour = "red", shape = 4, size =1)+
          geom_line(aes(y = Rule), colour = "blue", alpha = .5, size = 1)+
          scale_y_continuous(breaks = 0:1, labels = c("Left", "Right"))+
          theme_classic()+
          ggtitle(paste(new_modelnames[j], "model", ppex[i], "performance"))+
          xlab("Trial")+
          ylab("Response")+
          theme(text = element_text(size=8),plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))
      }else{
        pl <- ggplot(data = datperc, aes(y = ResponseLL, x = X))+
          geom_vline(xintercept = 30, colour = "grey", size = 1)+
          geom_vline(xintercept = 60, colour = "grey", size = 1)+
          geom_point( colour = "red", shape = 4, size =1)+
          geom_line(aes(y = Rule), colour = "blue", alpha = .5, size = 1)+
          scale_y_continuous(breaks = 0:1, labels = c("Left", "Right"))+
          theme_classic()+
          ggtitle(paste(new_modelnames[j], "model", ppex[i], "performance"))+
          xlab("Trial")+
          ylab("")+
          theme(text = element_text(size=8),plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))
      }
    }else {
      if (i==1){
        pl <- ggplot(data = datperc, aes(y = ResponseLL, x = X))+
          geom_vline(xintercept = 30, colour = "grey", size = 1)+
          geom_vline(xintercept = 60, colour = "grey", size = 1)+
          geom_point( colour = "red", shape = 4, size =1)+
          geom_line(aes(y = Rule), colour = "blue", alpha = .5, size = 1)+
          scale_y_continuous(breaks = 0:1, labels = c("Left", "Right"))+
          theme_classic()+
          ggtitle(paste(new_modelnames[j], "model", ppex[i], "performance"))+
          xlab("")+
          ylab("Response")+
          theme(text = element_text(size=8),plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))
      }else{
        pl <- ggplot(data = datperc, aes(y = ResponseLL, x = X))+
          geom_vline(xintercept = 30, colour = "grey", size = 1)+
          geom_vline(xintercept = 60, colour = "grey", size = 1)+
          geom_point( colour = "red", shape = 4, size =1)+
          geom_line(aes(y = Rule), colour = "blue", alpha = .5, size = 1)+
          scale_y_continuous(breaks = 0:1, labels = c("Left", "Right"))+
          theme_classic()+
          ggtitle(paste(new_modelnames[j], "model", ppex[i], "performance"))+
          xlab("")+
          ylab("")+
          theme(text = element_text(size=8),plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))
      }
    }
    
    dynamics_list_performance[[plotcount]] <- pl
  }
}

## here, we make the plot with descriptive analyses for the paper
setwd("/Users/pieter/Desktop/Model_Study/Analyses_results/")
Dynamic_plot<- ggarrange(dynamics_list_performance[[1]], dynamics_list_performance[[2]], dynamics_list_performance[[3]], dynamics_list_performance[[4]], dynamics_list_performance[[5]], dynamics_list_performance[[6]], dynamics_list_performance[[7]], dynamics_list_performance[[8]], dynamics_list_performance[[9]], dynamics_list_performance[[10]], dynamics_list_performance[[11]], dynamics_list_performance[[12]], dynamics_list_performance[[13]], dynamics_list_performance[[14]], dynamics_list_performance[[15]], dynamics_list_performance[[16]], dynamics_list_performance[[17]], dynamics_list_performance[[18]], ncol = 3, nrow = 6, labels = "AUTO")
ggsave("Dynamics_performance.jpg", Dynamic_plot, device = "jpeg", width = 17, height = 20, units = "cm", dpi = 300)

# setting variables for datasets
datasets <-c("Huycke", "Xia", "Goris/Stable", "Online","Goris/Volatile", "Verbeke", "Liu", "Mukherjee", "Hein", "Cohen")
Prew<- c(100, 80, 70, 100, 90, 80, 85, 70, 74, 66)
Vol<- c("Stable", "Stable", "Stable", "Reversal","Reversal", "Reversal", "Reversal", "Reversal", "Stepwise", "Stepwise")
Models <- c("RW", "ALR" , "Mod", "ALR_mod", "Higher_mod", "Full")
nModels = length(Models)
resultcolumns <-c("Dataset", "Subject", "Reward", "Volatility", "Trials", "Model", "ALR", "Mod", "High", "Measure", "Outcome", "Lr", "Temp", "Hybrid", "Cum", "Hlr")

#For the Goris dataset, these are the subjects that started in our condition of interest
stable_starters_goris <- c(5, 7, 9, 10, 13, 18, 21, 24, 25, 27, 30, 31, 32, 33, 44, 46, 47, 49, 50, 51, 53, 63, 66, 72, 73, 78, 85, 87, 95, 98, 105, 107, 109, 113, 116, 119, 129, 132, 134, 135, 136, 138, 140, 143)
volatile_starters_goris <- c(3, 4, 8, 11, 12, 16, 19, 23, 26, 29, 34, 36, 37, 40, 42, 52, 54, 55, 56, 61, 62, 64, 68, 69, 70, 71, 74, 75, 79, 80, 82, 83, 86, 92, 93, 94, 96, 97, 102, 106, 110, 112, 114, 117, 120, 121, 122, 124, 125, 126, 127, 128, 130, 139, 141, 142)

#For each dataset, we define the subjects that performed below chance level
below_chance_xia<-c(42, 59, 71)
below_chance_Verbeke<-c(4, 8, 17)
below_chance_goris_stable<-c(12, 13, 18, 19, 20, 22, 26, 30, 37, 40, 43, 52, 55, 59, 67, 69, 78, 80, 84, 85, 91, 93, 96, 99, 112, 117, 118, 120, 128, 131, 134, 139, 142)
below_chance_goris_volatile<-c(4, 17, 19, 24, 26, 30, 41, 49, 52, 55, 59, 65, 75, 81, 95, 99, 105, 113, 140, 142)
below_chance_Mukherjee<-c(5, 7, 25, 40, 41, 50)

#folder where results are
resultsfolder = "/Users/pieter/Desktop/Model_study/Fitted_data/"

x=0
for (ds in datasets){
  
  x=x+1
  Homefolder = paste(resultsfolder , ds, "/", sep ="")
  
  setwd(Homefolder)
  #Reading in and combining data
  for (i in Models){
    if (i == Models[1]){
      Data<-read.delim(paste("Fit_data_", i, ".csv", sep = ""), header = TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)
    }else{
      d <- read.delim(paste("Fit_data_", i, ".csv", sep = ""), header = TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)
      Data <- rbind(Data, d )
    }
  }
  #Removing subjects that were below chance level
  if (ds =="Xia"){
    Data <- Data[!(Data$Subject %in% below_chance_xia), ]
  }
  if (ds =="Verbeke"){
    Data <- Data[!(Data$Subject %in% below_chance_Verbeke), ]
  }
  if (ds =="Goris/Stable"){
    Data <- Data[!(Data$Subject %in% below_chance_goris_stable), ]
    Data <- Data[Data$Subject %in% stable_starters_goris, ]
  }
  if (ds =="Goris/Volatile"){
    Data <- Data[!(Data$Subject %in% below_chance_goris_volatile), ]
    Data <- Data[Data$Subject %in% volatile_starters_goris, ]
  }
  if (ds =="Mukherjee"){
    Data <- Data[!(Data$Subject %in% below_chance_Mukherjee), ]
  }
  
  pplist = unique(Data$Subject)
  
  #Get model parameter and fit data for each subject and each model
  for (p in pplist){
    print(p)
    if (p == pplist[1]){
      RW_Data<-read.delim(paste("Data_subject_", p, "_0.csv", sep = ""), header = TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)
      Average_accuracy <-mean((RW_Data$Response == RW_Data$CorResp)*1)
    }else{
      RW_d<-read.delim(paste("Data_subject_", p, "_0.csv", sep = ""), header = TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)
      
      #Sometimes there was for some reason one column to much at the start, hence we remove it
      if (length(RW_d)>12){
        RW_d <- RW_d[,c(1,3:13)]
      }
      #Get accuracy and model data
      Accuracy<-(RW_d$Response == RW_d$CorResp)*1
      Average_accuracy <- rbind(Average_accuracy, mean(Accuracy))
    }
  }
  Average_accuracy <- data.frame(cbind(rep(ds, each = length(pplist)),pplist+x*100, Average_accuracy), row.names = NULL)
  colnames(Average_accuracy) <-c("Dataset", "Subject", "MeanAccuracy")
  Average_accuracy$Prew <- Prew[x]
  Average_accuracy$Structure <- Vol[x]
  
  if (ds == datasets[1]){
    all_accuracy <- Average_accuracy
  }else{
    all_accuracy <- rbind(all_accuracy, Average_accuracy)
  }
}

all_accuracy$MeanAccuracy<-as.numeric(as.character(all_accuracy$MeanAccuracy))*100
all_accuracy <- data.frame(all_accuracy)
names(all_accuracy$Dataset) <- "NULL"

averages <- aggregate(all_accuracy$MeanAccuracy, list(all_accuracy$Dataset, all_accuracy$Prew, all_accuracy$Structure), FUN = mean)
colnames(averages) <- c("Dataset", "Prew", "Structure", "Accuracy")

library(dplyr)
alpha <- 0.05
#Summarize accuracy 
ds <-
  all_accuracy %>% 
  group_by(Dataset) %>% 
  summarize(mean = mean(MeanAccuracy),
            lower = (mean(MeanAccuracy) - qt(1- alpha/2, (dplyr::n() - 1))*sd(MeanAccuracy)/sqrt(dplyr::n())),
            upper = (mean(MeanAccuracy) + qt(1- alpha/2, (dplyr::n() - 1))*sd(MeanAccuracy)/sqrt(dplyr::n())))

ds$baseline <- Prew
ds$Dataset <- factor(ds$Dataset, levels=c("Huycke", "Xia", "Goris/Stable", "Online","Goris/Volatile", "Liu", "Verbeke", "Mukherjee", "Hein", "Cohen"))

#Make plot
descriptive_plot<-ggplot(ds, aes(y=mean, x = Dataset))+ 
  geom_bar( width = .5, size =1.5, position = position_dodge2(.25), stat ="identity", fill = "blue")+
  geom_errorbar(aes(ymin=lower, ymax = upper), width = .2, size =1.5, position = position_dodge2(.25))+
  annotate("rect", xmin = 0.8, xmax = 3.2, ymin = 50, ymax = 105, alpha = .15) +
  annotate("rect", xmin = 3.8, xmax = 8.2, ymin = 50, ymax = 105, alpha = .15) +
  annotate("rect", xmin = 8.8, xmax = 10.2, ymin = 50, ymax = 105, alpha = .15) +
  annotate("text", x = 2, y = 105, label = "Stable", size = 2.5) +
  annotate("text", x = 6, y = 105, label = "Reversal", size = 2.5) +
  annotate("text", x = 9.5, y = 105, label = "Stepwise", size = 2.5) +
  ylab(expression('P(a'['optimal']*')'))+
  coord_cartesian(ylim=c(55, 105))+
  xlab("Dataset")+
  theme_classic()+
  theme(text = element_text(size=8),plot.title = element_text(size = 8, face = "italic", hjust=0.5), axis.text.x = element_text(angle = 67.5, hjust = 1))

mixed_reg <-lmer(MeanAccuracy ~ (1|Dataset) + Structure*Prew, all_accuracy)
summary(mixed_reg)
Anova(mixed_reg)

regression <-lm(Accuracy ~ Structure*Prew, averages)
summary(regression) 
Anova(regression)

Descriptive_plot <- ggdraw() +
  draw_plot(descriptive_plot, x = 0, y = 0.58, width = .35, height = .42) +
  draw_plot(plot_list[[1]], x = .345, y = 0.66, width = .23, height = .3) +
  draw_plot(plot_list[[2]], x = .5675, y = 0.66, width = .22, height = .3) +
  draw_plot(plot_list[[3]], x = .78, y = 0.66, width = .22, height = .3) +
  draw_plot(plot_list[[4]], x = .055, y = 0.3, width = .23, height = .3) +
  draw_plot(plot_list[[5]], x = .32, y = 0.3, width = .22, height = .3) +
  draw_plot(plot_list[[6]], x = .56, y = 0.3, width = .22, height = .3) +
  draw_plot(plot_list[[7]], x = .78, y = 0.3, width = .22, height = .3) +
  draw_plot(plot_list[[8]], x = .075, y = 0, width = .43, height = .3) +
  draw_plot(plot_list[[9]], x = .56, y = 0, width = .22, height = .3) +
  draw_plot(plot_list[[10]], x = .78, y = 0, width = .22, height = .3) +
  draw_plot_label(label = c("A","B","C", "D", "E","F","G", "H", "I", "J", "K"), x=c(0,0.35, 0.575, 0.8, .075, 0.34, 0.575, .8, 0.075, 0.575, 0.8),y=c(.975,.95, .95, .95, .6, .6, .6, .6, .3, .3, .3), size = 8,fontface="bold")

setwd("/Users/pieter/Desktop/Model_Study/Analyses_results/")
ggsave("Full_descriptive_plot.jpg", Descriptive_plot, device = "jpeg", width = 17, height = 12, units = "cm", dpi = 300)
