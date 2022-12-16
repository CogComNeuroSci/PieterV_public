#clear console, environment and plots
cat("\014")
rm(list = ls())

library(ggplot2)
library(ggpubr)
library(car)
library(Rmisc)

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
  
  if (ds == datasets[1]){
    all_accuracy <- Average_accuracy
  }else{
    all_accuracy <- rbind(all_accuracy, Average_accuracy)
  }
}

all_accuracy$MeanAccuracy<-as.numeric(as.character(all_accuracy$MeanAccuracy))
all_accuracy <- data.frame(all_accuracy)
names(all_accuracy$Dataset) <- "NULL"

library(dplyr)
alpha <- 0.05
#Summarize accuracy 
ds <-
  all_accuracy %>% 
  group_by(Dataset) %>% 
  summarize(mean = mean(MeanAccuracy)*100,
            lower = 100* (mean(MeanAccuracy) - qt(1- alpha/2, (dplyr::n() - 1))*sd(MeanAccuracy)/sqrt(dplyr::n())),
            upper = 100*(mean(MeanAccuracy) + qt(1- alpha/2, (dplyr::n() - 1))*sd(MeanAccuracy)/sqrt(dplyr::n())))

ds$baseline <- Prew
ds$Dataset <- factor(ds$Dataset, levels=c("Huycke", "Xia", "Goris/Stable", "Online","Goris/Volatile", "Liu", "Verbeke", "Mukherjee", "Hein", "Cohen"))

#Make plot
descriptive_plot<-ggplot(ds, aes(y=mean, x = Dataset))+ 
  geom_bar( width = .5, size =1.5, position = position_dodge2(.25), stat ="identity", fill = "blue")+
  geom_errorbar(aes(ymin=lower, ymax = upper), width = .2, size =1.5, position = position_dodge2(.25))+
  annotate("rect", xmin = 0.8, xmax = 3.2, ymin = 50, ymax = 105, alpha = .15) +
  annotate("rect", xmin = 3.8, xmax = 8.2, ymin = 50, ymax = 105, alpha = .15) +
  annotate("rect", xmin = 8.8, xmax = 10.2, ymin = 50, ymax = 105, alpha = .15) +
  annotate("text", x = 2, y = 105, label = "Stable", size = 3) +
  annotate("text", x = 6, y = 105, label = "Reversal", size = 3) +
  annotate("text", x = 9.5, y = 105, label = "Stepwise", size = 3) +
  ylab(expression('P(a'['optimal']*')'))+
  coord_cartesian(ylim=c(55, 105))+
  xlab("Dataset")+
  theme_minimal()+
  theme(text = element_text(size=8),plot.title = element_text(size = 8, face = "italic", hjust=0.5), axis.text.x = element_text(angle = 67.5, hjust = 1))

setwd("/Users/pieter/Desktop/Model_Study/Analyses_results/")
ggsave("Descriptive.jpg", descriptive_plot, device = "jpeg", width = 7.5, height = 6, units = "cm", dpi = 300)

    