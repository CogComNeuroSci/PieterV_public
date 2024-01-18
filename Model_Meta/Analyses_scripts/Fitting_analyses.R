#clear console, environment and plots
cat("\014")
rm(list = ls())

library(ggplot2)
library(ggpubr)

# setting variables for datasets
datasets <-c("Huycke", "Xia", "Goris/Stable", "Online","Goris/Volatile", "Liu", "Verbeke", "Mukherjee", "Hein", "Cohen")
Prew<- c(100, 80, 70, 100, 90, 85, 80, 70, 74, 66)
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

#set folder
resultsfolder = "/Users/pieter/Desktop/Model_study/Fitted_data/"

for (ds in datasets){

  Homefolder = paste(resultsfolder , ds, "/", sep ="")

  setwd(Homefolder)

  #Read in and combine data
  for (i in Models){
    if (i == Models[1]){
      Data<-read.delim(paste("Fit_data_", i, ".csv", sep = ""), header = TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)
    }else{
      d <- read.delim(paste("Fit_data_", i, ".csv", sep = ""), header = TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)
      Data <- rbind(Data, d )
    }
  }
  
  #Remove subjects that scored below chance level
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
  
  #Plot for each dataset the distributions of parameters
  Lr_plot <- ggplot(Data, aes(y=Lr, x = Model))+ 
    geom_violin(fill = "red", color="black", size = 0, alpha = .5)+
    geom_dotplot(binaxis='y', binwidth = .01, stackdir='center', dotsize=1, position = position_dodge(), alpha = .75)+
    stat_summary(fun=median, geom="point", shape=23, size= 2, stroke =2, position =position_dodge(.9), fill = "red", color="black")+
    xlab('Model')+
    ylab('Learning rate')+
    ggtitle("Learning rate estimation")+
    ylim(c(-.05,1.05))+
    scale_x_discrete(labels=Models)+
    theme_classic()+
    theme(text = element_text(size=12),plot.title = element_text(size = 12, face = "italic", hjust=0.5))

  Temp_plot <- ggplot(Data, aes(y=Temp, x = Model))+ 
    geom_violin(fill = "red", color="black", size = 0, alpha = .5)+
    geom_dotplot(binaxis='y', binwidth = .01, stackdir='center', dotsize=1, position = position_dodge(), alpha = .75)+
    stat_summary(fun=median, geom="point", shape=23, size= 2, stroke =2, position =position_dodge(.9), fill = "red", color="black")+
    xlab('Model')+
    ylab('Temperature')+
    ggtitle("Temperature estimation")+
    ylim(c(-.05,1.05))+
    scale_x_discrete(labels=Models)+
    theme_classic()+
    theme(text = element_text(size=12),plot.title = element_text(size = 12, face = "italic", hjust=0.5))

  Hybrid_plot <- ggplot(Data, aes(y=Hybrid, x = Model))+ 
    geom_violin(fill = "red", color="black", size = 0, alpha = .5)+
    geom_dotplot(binaxis='y', binwidth = .01, stackdir='center', dotsize=1, position = position_dodge(), alpha = .75)+
    stat_summary(fun=median, geom="point", shape=23, size= 2, stroke =2, position =position_dodge(.9), fill = "red", color="black")+
    xlab('Model')+
    ylab('Hybrid')+
    ggtitle("Hybrid estimation")+
    ylim(c(-.05,1.05))+
    scale_x_discrete(labels=Models)+
    theme_classic()+
    theme(text = element_text(size=12),plot.title = element_text(size = 12, face = "italic", hjust=0.5,))

  Cumul_plot <- ggplot(Data, aes(y=Cum, x = Model))+ 
    geom_violin(fill = "red", color="black", size = 0, alpha = .5)+
    geom_dotplot(binaxis='y', binwidth = .01, stackdir='center', dotsize=1, position = position_dodge(), alpha = .75)+
    stat_summary(fun=median, geom="point", shape=23, size= 2, stroke =2, position =position_dodge(.9), fill = "red", color="black")+
    xlab('Model')+
    ylab('Cumulation')+
    ggtitle("Cumulation parameter estimation")+
    ylim(c(-.05,1.05))+
    scale_x_discrete(labels=Models)+
    theme_classic()+
    theme(text = element_text(size=12),plot.title = element_text(size = 12, face = "italic", hjust=0.5))

  Hlr_plot <- ggplot(Data, aes(y=Hlr, x = Model))+ 
    geom_violin(fill = "red", color="black", size = 0, alpha = .5)+
    geom_dotplot(binaxis='y', binwidth = .01, stackdir='center', dotsize=1, position = position_dodge(), alpha = .75)+
    stat_summary(fun=median, geom="point", shape=23, size= 2, stroke =2, position =position_dodge(.9), fill = "red", color="black")+
    xlab('Model')+
    ylab('Higher learning rate')+
    ggtitle("Higher learning rate estimation")+
    ylim(c(-.05,1.05))+
    scale_x_discrete(labels=Models)+
    theme_classic()+
    theme(text = element_text(size=12),plot.title = element_text(size = 12, face = "italic", hjust=0.5))

  #Combine these parameter distribution plots and save
  Parameters_plot <- ggarrange(Lr_plot, Temp_plot, Hybrid_plot, Cumul_plot, Hlr_plot, ncol = 3, nrow = 2)
  ggsave("Fitted_parameters.jpg", Parameters_plot, device = "jpeg", width = 25, height = 15, units = "cm", dpi = 300, path = Homefolder)

  #Make empty dataframes for LL, AIC and BIC but also explained variance
  subj = length(pplist)
  LL <- data.frame(matrix(vector(), nrow = subj, ncol = nModels + 2))
  names(LL)<-c("Subject", "Min", "RW", "ALR",  "Mod", "ALR_mod", "Higher_mod", "Full")
  
  AIC <- data.frame(matrix(vector(), nrow = subj, ncol = nModels + 2))
  names(AIC)<-c("Subject", "Min", "RW", "ALR",  "Mod", "ALR_mod", "Higher_mod", "Full")

  BIC <- data.frame(matrix(vector(), nrow = subj, ncol = nModels + 2))
  names(BIC)<-c("Subject", "Min", "RW", "ALR", "Mod", "ALR_mod", "Higher_mod", "Full")
  
  Variance_explained <- data.frame(matrix(vector(), nrow = subj, ncol = nModels + 3))
  names(Variance_explained)<-c("Subject", "Dataset", "Lower_bound", "RW", "ALR", "Mod", "ALR_mod", "Higher_mod", "Full")

  #Fill in a lot of that dataframe
  id <- which (datasets == ds)
  results <- data.frame(matrix(ncol = length(resultcolumns), nrow = subj * 3* nModels))
  colnames(results) <- resultcolumns
  results$Dataset<- ds
  results$Subject<- rep(seq(subj)+1000*id, 3*nModels)
  results$Reward<- Prew[id]
  results$Volatility <- Vol[id]
  results$Model<-rep(Models, each = subj)
  results$ALR <-0
  results$ALR[results$Model == "ALR"]<-1
  results$ALR[results$Model == "ALR_mod"]<-1
  results$ALR[results$Model == "Full"]<-1
  results$Mod <-0
  results$Mod[results$Model == "Mod"]<-1
  results$Mod[results$Model == "ALR_mod"]<-1
  results$Mod[results$Model == "Higher_mod"]<-1
  results$Mod[results$Model == "Full"]<-1
  results$High <-0
  results$High[results$Model == "Higher_mod"]<-1
  results$High[results$Model == "Full"]<-1
  results$Measure<-rep(c("LL", "AIC", "BIC"), each = subj*nModels)
  results[,12:16] <- Data[,4:8]
  
  for (j in seq(subj)){
    LL$Subject[j]<- j
    AIC$Subject[j]<-j
    BIC$Subject[j]<-j
    Variance_explained$Subject[j] <- j
  
    Likdat <- Data$LogLik[Data$Subject==pplist[j]]
    subdat <- read.delim(paste("Data_Subject_", pplist[j], "_0.csv", sep=""), header = TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)
    Ndat <- nrow(subdat)
    n<- log(Ndat)
    results$Trials[results$Subject == j+1000*id] <- Ndat
    
    LL[j,3:8] <- -Likdat
    Variance_explained[j, 4:9] <- Likdat
    Variance_explained$Lower_bound[j] <- Ndat*log(.5)
    Variance_explained$Dataset[j] <- ds
  
    #Compute AIC from log likelihood
    AIC$RW[j] <- 4 - (2*Likdat[1])
    AIC$ALR[j] <- 6 - (2*Likdat[2])
    AIC$Mod[j] <- 6 - (2*Likdat[3])
    AIC$ALR_mod[j] <- 8 - (2*Likdat[4])
    AIC$Higher_mod[j] <- 8 - (2*Likdat[5])
    AIC$Full[j] <- 10 - (2*Likdat[6])
  
    #Compute BIC from log likelihood
    BIC$RW[j] <- 2*n - (2*Likdat[1])
    BIC$ALR[j] <- 3*n - (2*Likdat[2])
    BIC$Mod[j] <- 3*n - (2*Likdat[3])
    BIC$ALR_mod[j] <- 4*n - (2*Likdat[4])
    BIC$Higher_mod[j] <- 4*n - (2*Likdat[5])
    BIC$Full[j] <- 5*n - (2*Likdat[6])
  }
  
  #Compute weighted measures by determining the distance of model fit from the most optimal (min) model fit and performing an exponential transformations
  LL$Min  <- apply(LL[,3:8], 1, FUN = min)
  AIC$Min <- apply(AIC[,3:8], 1, FUN = min)
  BIC$Min <- apply(BIC[,3:8], 1, FUN = min)
  
  LL$dRW <- LL$RW - LL$Min
  LL$dALR <- LL$ALR - LL$Min
  LL$dMod <- LL$Mod - LL$Min
  LL$dALR_mod <- LL$ALR_mod - LL$Min
  LL$dHigher_mod <- LL$Higher_mod - LL$Min
  LL$dFull <- LL$Full - LL$Min

  AIC$dRW <- AIC$RW - AIC$Min
  AIC$dALR <- AIC$ALR - AIC$Min
  AIC$dMod <- AIC$Mod - AIC$Min
  AIC$dALR_mod <- AIC$ALR_mod - AIC$Min
  AIC$dHigher_mod <- AIC$Higher_mod - AIC$Min
  AIC$dFull <- AIC$Full - AIC$Min

  BIC$dRW <- BIC$RW - BIC$Min
  BIC$dALR <- BIC$ALR - BIC$Min
  BIC$dMod <- BIC$Mod - BIC$Min
  BIC$dALR_mod <- BIC$ALR_mod - BIC$Min
  BIC$dHigher_mod <- BIC$Higher_mod - BIC$Min
  BIC$dFull <- BIC$Full - BIC$Min
  
  LL$eRW <- exp((-1/2)*LL$dRW)
  LL$eALR <- exp((-1/2)*LL$dALR)
  LL$eMod <- exp((-1/2)*LL$dMod)
  LL$eALR_mod <- exp((-1/2)*LL$dALR_mod)
  LL$eHigher_mod <- exp((-1/2)*LL$dHigher_mod)
  LL$eFull <- exp((-1/2)*LL$dFull)

  AIC$eRW <- exp((-1/2)*AIC$dRW)
  AIC$eALR <- exp((-1/2)*AIC$dALR)
  AIC$eMod <- exp((-1/2)*AIC$dMod)
  AIC$eALR_mod <- exp((-1/2)*AIC$dALR_mod)
  AIC$eHigher_mod <- exp((-1/2)*AIC$dHigher_mod)
  AIC$eFull <- exp((-1/2)*AIC$dFull)

  BIC$eRW <- exp((-1/2)*BIC$dRW)
  BIC$eALR <- exp((-1/2)*BIC$dALR)
  BIC$eMod <- exp((-1/2)*BIC$dMod)
  BIC$eALR_mod <- exp((-1/2)*BIC$dALR_mod)
  BIC$eHigher_mod <- exp((-1/2)*BIC$dHigher_mod)
  BIC$eFull <- exp((-1/2)*BIC$dFull)

  LL$Sum <- rowSums(LL[,15:20])
  AIC$Sum <- rowSums(AIC[,15:20])
  BIC$Sum <- rowSums(BIC[,15:20])
  
  Variance_explained$eRW <- (abs(Variance_explained$Lower_bound) - abs(Variance_explained$RW)) / abs(Variance_explained$Lower_bound)
  Variance_explained$eALR <- (abs(Variance_explained$Lower_bound) - abs(Variance_explained$ALR)) / abs(Variance_explained$Lower_bound)
  Variance_explained$eMod <- (abs(Variance_explained$Lower_bound) - abs(Variance_explained$Mod)) / abs(Variance_explained$Lower_bound)
  Variance_explained$eALR_mod <- (abs(Variance_explained$Lower_bound) - abs(Variance_explained$ALR_mod)) / abs(Variance_explained$Lower_bound)
  Variance_explained$eHigher_mod <- (abs(Variance_explained$Lower_bound) - abs(Variance_explained$Higher_mod)) / abs(Variance_explained$Lower_bound)
  Variance_explained$eFull <- (abs(Variance_explained$Lower_bound) - abs(Variance_explained$Full)) / abs(Variance_explained$Lower_bound)
  
  #Add these weighted measures to the dataframes
  for (i in seq(nModels)){
    for (j in seq(subj)){
      Data$wLL[(i-1)*subj+j]<- LL[j, 14+i]/LL[j,21]
      Data$wAIC[(i-1)*subj+j]<- AIC[j, 14+i]/AIC[j,21]
      Data$wBIC[(i-1)*subj+j]<- BIC[j, 14+i]/BIC[j,21]
    }
  }
  
  results$Outcome[results$Measure == "LL"] <- Data$wLL
  results$Outcome[results$Measure == "AIC"] <- Data$wAIC
  results$Outcome[results$Measure == "BIC"] <- Data$wBIC
  
  #Make plots for each dataset of weighted AIC and BIC 
  wAIC_plot <- ggplot(Data, aes(y=wAIC, x = Model))+ 
    geom_violin(fill = "red", color="black", size = 0, alpha = .5)+
    geom_dotplot(binaxis='y', binwidth = .01, stackdir='center', dotsize=1, position = position_dodge(), alpha = .75)+
    stat_summary(fun=median, geom="point", shape=23, size= 1, stroke =2, position =position_dodge(.9), fill = "red", color="black")+
    xlab('Model')+
    ylab('AIC Weights')+
    ggtitle("Weighted model fit")+
    ylim(c(-.05,1.05))+
    scale_x_discrete(labels=Models)+
    theme_classic()+
    theme(text = element_text(size=12),plot.title = element_text(size = 12, face = "italic", hjust=0.5))

  wBIC_plot <- ggplot(Data, aes(y=wBIC, x = Model))+ 
    geom_violin(fill = "red", color="black", size = 0, alpha = .5)+
    geom_dotplot(binaxis='y', binwidth = .01, stackdir='center', dotsize=1, position = position_dodge(), alpha = .75)+
    stat_summary(fun=median, geom="point", shape=23, size= 1, stroke =2, position =position_dodge(.9), fill = "red", color="black")+
    xlab('Model')+
    ylab('BIC Weights')+
    ylim(c(-.05,1.05))+
    scale_x_discrete(labels=Models)+
    theme_classic()+
    theme(text = element_text(size=12),plot.title = element_text(size = 12, face = "italic", hjust=0.5))

  #Extract what was the winning model across subjects for AIC and BIC 
  for (z in pplist){
    Data$winner[Data$Subject==z]<-Models[order(Data$wAIC[Data$Subject ==z])[nModels]]
    Data$winnerBIC[Data$Subject==z]<-Models[order(Data$wBIC[Data$Subject ==z])[nModels]]
  }

  Data$winner <- factor(Data$winner,levels = Models)
  Data$winnerBIC <- factor(Data$winnerBIC,levels = Models)

  #Plot the distribution across subjects for best fitting model
  Winner_plot <- ggplot(Data[1:subj,], aes(x = winner)) + 
    geom_bar(aes(y = (..count..)/sum(..count..)), color = "black", size = 1, fill = "red")+
    xlab('Winning model')+
    ylab('Proportion of subjects')+
    ggtitle(sprintf("Best fitting model over subjects (N = %s)",subj))+
    theme_classic()+
    theme(text = element_text(size=12),plot.title = element_text(size = 12, face = "italic", hjust=0.5))

  Winner_plot_BIC <- ggplot(Data[1:subj,], aes(x = winnerBIC)) + 
    geom_bar(aes(y = (..count..)/sum(..count..)), color = "black", size = 1, fill = "red")+
    xlab('Winning model')+
    ylab('Proportion of subjects')+
    theme_classic()+
    theme(text = element_text(size=12),plot.title = element_text(size = 12, face = "italic", hjust=0.5))

  Fitted_plot <- ggarrange(wAIC_plot, Winner_plot, wBIC_plot, Winner_plot_BIC, ncol = 2, nrow = 2)
  ggsave("Fit.jpg", Fitted_plot, device = "jpeg", width = 17.5, height = 8, units = "cm", dpi = 300, path = Homefolder)
  
  summary<- aggregate(cbind(wLL, wAIC, wBIC)~Model, data = Data, FUN = mean)
  summary$AICwinner <-x <-as.data.frame(table(Data$winner))[,2]/6/subj
  summary$BICwinner <-x <-as.data.frame(table(Data$winnerBIC))[,2]/6/subj

  #Print for each dataset a summary of the evidence for each model under AIC and BIC
  print(ds)
  print(summary)
  
  #Store everything in a dataframe and save it
  if (id ==1){
    all_data <-results
    explained_variance <- Variance_explained
  }else{
    all_data <- rbind(all_data,results)
    explained_variance <- rbind(explained_variance,Variance_explained)
  }
}
write.csv(all_data, paste(resultsfolder, "all_data.csv"), row.names = FALSE)

d <- aggregate(.~ Dataset, data = explained_variance, FUN = mean)

d$max <- apply(d[,10:15], 1, FUN = max)*100
d$min <- apply(d[,10:15], 1, FUN = min)*100
d$diff <- d$max-d$min

