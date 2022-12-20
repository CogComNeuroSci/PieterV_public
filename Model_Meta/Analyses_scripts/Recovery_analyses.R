#clear console, environment and plots
cat("\014")
rm(list = ls())

library(ggplot2)
library(ggpubr)
library(wesanderson)
library(scales)

# setting folder
Homefolder = "/Users/pieter/Desktop/Model_study/"
Endfolder = "/Users/pieter/Desktop/Model_Study/Analyses_results/"

#Define model labels
Models <- c("RW", "ALR", "Error", "ALR_Error", "Learning", "Full")
new_labels <- c("RW", "ALR", "Hierarchical","Hierarchical_ALR", "Hierarchical_learning", "Full")
All <- c("True","RW", "ALR", "Hierarchical","Hierarchical_ALR", "Hierarchical_learning", "Full")

#Make dataframes and lists
nModels = length(Models)
datalen<-1080

modelrecovery_plots <- list()

colors <- c("True" = "red", "Estimated" = "lightblue")

Parameters<- data.frame(matrix(vector(),nModels*datalen*2,7))
names(Parameters) <-c("Model", "Type", "Lr", "Temp", "Hybrid", "Cum", "Hlr")

AICWeights <- data.frame(matrix(vector(),nModels*nModels*datalen,3))
names(AICWeights) <-c("Sim_model","Fit_model", "wAIC")

for (i in seq(nModels)){
  #For each model load in the true data and the parameters as fitted by each model
  print(Models[i])
  setwd(paste(Homefolder,Models[i],"_sims", sep =""))
  
  True<-read.delim("Truth_data.csv", header = TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)
  RW<-read.delim("RW_data.csv", header = TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)
  Error<-read.delim("Error_data.csv", header = TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)
  ALR<-read.delim("ALR_data.csv", header = TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)
  ALRError<-read.delim("ALRError_data.csv", header = TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)
  Learning<-read.delim("Learning_data.csv", header = TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)
  Full<-read.delim("Full_data.csv", header = TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)
  
  #Now, compute model evidence for each model
  AIC <- data.frame(matrix(vector(), nrow = datalen, ncol = nModels))
  names(AIC)<-Models
  
  AIC$RW <- 2*2 - 2* RW$LogL
  AIC$ALR <- 2*3 - 2* ALR$LogL
  AIC$Error <- 2*3 - 2* Error$LogL
  AIC$ALR_Error <- 2*4 - 2* ALRError$LogL
  AIC$Learning <- 2*4 - 2* Learning$LogL
  AIC$Full <- 2*5 - 2* Full$LogL
  
  #Only consider data where fitting has converged
  success_id <- rowSums(is.na(AIC))==0
  print(datalen - sum(success_id))
  
  AIC <- AIC[success_id,]
  True<-True[success_id,]
  RW<-RW[success_id,]
  ALR<-ALR[success_id,]
  Error<-Error[success_id,]
  ALRError<-ALRError[success_id,]
  Learning<-Learning[success_id,]
  Full<-Full[success_id,]
  
  #Compute weighted AIC value
  AIC$min <- apply(AIC, 1, FUN = min)
  
  datalen1 <- length(AIC$min)
  
  AIC$dRW <- AIC$RW - AIC$min
  AIC$dALR <- AIC$ALR - AIC$min
  AIC$dError <- AIC$Error - AIC$min
  AIC$dALR_Error <- AIC$ALR_Error - AIC$min
  AIC$dLearning <- AIC$Learning - AIC$min
  AIC$dFull <- AIC$Full - AIC$min
  
  totalsum<-rowSums(exp((-1/2)*AIC[,8:13]))
  
  start = (i-1)*nModels*datalen
  AICWeights[seq(start,i*nModels*datalen),1]<-new_labels[i]
  
  for (j in seq(nModels)){
    AICWeights[seq(start+(j-1)*datalen+1,start+j*datalen),2] <- new_labels[j]
    dat = exp((-1/2)*AIC[,j+7])
    AICWeights[seq(start+(j-1)*datalen+1,start+(j-1)*datalen+datalen1),3] <- dat / totalsum
  }
  
  #Store parameters (true and fitted)
  #Different models have different parameters (hence, if else statements)
  Parameters[seq((i-1)*2*datalen+1,(i-1)*2*datalen+datalen),2] <- "True"
  Parameters[seq((i-1)*2*datalen+1,(i-1)*2*datalen+datalen1), 3] <- True$Lr
  Parameters[seq((i-1)*2*datalen+1,(i-1)*2*datalen+datalen1), 4] <- True$Temp
  if (i %in% c(2, 4, 6)){
    Parameters[seq((i-1)*2*datalen+1,(i-1)*2*datalen+datalen1), 5] <- True$Hybrid
  }
  if (i %in% seq(3,6)){
    Parameters[seq((i-1)*2*datalen+1,(i-1)*2*datalen+datalen1), 6] <- True$Cumul
  }
  if (i %in% seq(4,6)){
    Parameters[seq((i-1)*2*datalen+1,(i-1)*2*datalen+datalen1), 7] <- True$Hlr
  }
  
  if (i ==1){
    Parameters[seq((i-1)*2*datalen+1,i*2*datalen), 1]<-new_labels[i]
    Parameters[seq((i-1)*2*datalen+datalen+1,(i-1)*2*datalen+datalen+datalen1), 2] <- "Estimated"
    Parameters[seq((i-1)*2*datalen+datalen+1,(i-1)*2*datalen+datalen+datalen1), 3] <- RW$Lr
    Parameters[seq((i-1)*2*datalen+datalen+1,(i-1)*2*datalen+datalen+datalen1), 4] <- RW$Temp
  }
  if (i ==2){
    Parameters[seq((i-1)*2*datalen+1,i*2*datalen), 1]<-new_labels[i]
    Parameters[seq((i-1)*2*datalen+datalen+1,(i-1)*2*datalen+datalen+datalen1), 2] <- "Estimated"
    Parameters[seq((i-1)*2*datalen+datalen+1,(i-1)*2*datalen+datalen+datalen1), 3] <- ALR$Lr
    Parameters[seq((i-1)*2*datalen+datalen+1,(i-1)*2*datalen+datalen+datalen1), 4] <- ALR$Temp
    Parameters[seq((i-1)*2*datalen+datalen+1,(i-1)*2*datalen+datalen+datalen1), 5] <- ALR$Hybrid
  }
  if (i ==3){
    Parameters[seq((i-1)*2*datalen+1,i*2*datalen), 1]<-new_labels[i]
    Parameters[seq((i-1)*2*datalen+datalen+1,(i-1)*2*datalen+datalen+datalen1), 2] <- "Estimated"
    Parameters[seq((i-1)*2*datalen+datalen+1,(i-1)*2*datalen+datalen+datalen1), 3] <- Error$Lr
    Parameters[seq((i-1)*2*datalen+datalen+1,(i-1)*2*datalen+datalen+datalen1), 4] <- Error$Temp
    Parameters[seq((i-1)*2*datalen+datalen+1,(i-1)*2*datalen+datalen+datalen1), 6] <- Error$Cumul
  }
  if (i ==4){
    Parameters[seq((i-1)*2*datalen+1,i*2*datalen), 1]<-new_labels[i]
    Parameters[seq((i-1)*2*datalen+datalen+1,(i-1)*2*datalen+datalen+datalen1), 2] <- "Estimated"
    Parameters[seq((i-1)*2*datalen+datalen+1,(i-1)*2*datalen+datalen+datalen1), 3] <- ALRError$Lr
    Parameters[seq((i-1)*2*datalen+datalen+1,(i-1)*2*datalen+datalen+datalen1), 4] <- ALRError$Temp
    Parameters[seq((i-1)*2*datalen+datalen+1,(i-1)*2*datalen+datalen+datalen1), 5] <- ALRError$Hybrid
    Parameters[seq((i-1)*2*datalen+datalen+1,(i-1)*2*datalen+datalen+datalen1), 6] <- ALRError$Cumul
  }
  if (i ==5){
    Parameters[seq((i-1)*2*datalen+1,i*2*datalen), 1]<-new_labels[i]
    Parameters[seq((i-1)*2*datalen+datalen+1,(i-1)*2*datalen+datalen+datalen1), 2] <- "Estimated"
    Parameters[seq((i-1)*2*datalen+datalen+1,(i-1)*2*datalen+datalen+datalen1), 3] <- Learning$Lr
    Parameters[seq((i-1)*2*datalen+datalen+1,(i-1)*2*datalen+datalen+datalen1), 4] <- Learning$Temp
    Parameters[seq((i-1)*2*datalen+datalen+1,(i-1)*2*datalen+datalen+datalen1), 6] <- Learning$Cumul
    Parameters[seq((i-1)*2*datalen+datalen+1,(i-1)*2*datalen+datalen+datalen1), 7] <- Learning$Hlr
  }
  if (i ==6){
    Parameters[seq((i-1)*2*datalen+1,i*2*datalen), 1]<-new_labels[i]
    Parameters[seq((i-1)*2*datalen+datalen+1,i*2*datalen), 2] <- "Estimated"
    Parameters[seq((i-1)*2*datalen+datalen+1,(i-1)*2*datalen+datalen+datalen1), 3] <- Full$Lr
    Parameters[seq((i-1)*2*datalen+datalen+1,(i-1)*2*datalen+datalen+datalen1), 4] <- Full$Temp
    Parameters[seq((i-1)*2*datalen+datalen+1,(i-1)*2*datalen+datalen+datalen1), 5] <- Full$Hybrid
    Parameters[seq((i-1)*2*datalen+datalen+1,(i-1)*2*datalen+datalen+datalen1), 6] <- Full$Cumul
    Parameters[seq((i-1)*2*datalen+datalen+1,(i-1)*2*datalen+datalen+datalen1), 7] <- Full$Hlr
  }
 
}

#Aggregate AIC weights over simulations
AICWeights<-AICWeights[!(is.na(AICWeights$wAIC)),]
aggregated_Weights <- aggregate( wAIC ~ Sim_model + Fit_model, data = AICWeights, FUN = mean)
aggregated_Weights$Sim_model <- factor(aggregated_Weights$Sim_model, levels=new_labels)
aggregated_Weights$Fit_model <- factor(aggregated_Weights$Fit_model, levels=new_labels)

#Color palette for plotting
pal <- wes_palette("Zissou1", 100, type = "continuous")

#Make model recovery raster
AIC_raster<-ggplot(data = aggregated_Weights, aes(y=Sim_model, x=Fit_model, fill = wAIC))+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(0,.75), oob = scales::squish)+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"), axis.text.x = element_text(angle = 67.5, hjust=1), legend.title = element_text(size = 8), 
        legend.key.size = unit(.33, 'cm'))+
  ggtitle("Model recovery")+
  labs(x="Simulated model")+
  labs(y="Fitted model")+
  labs(fill="AIC weights")

ggsave("Model_recovery.jpg", AIC_raster, device = "jpeg", width = 10, height = 7.5, units = "cm", dpi = 300, path = Endfolder)

#Make plot of how the estimated parameter distributions relate to the actual parameter distributions
Parameters<-Parameters[!(is.na(Parameters$Lr)),]
Parameters$Model <- factor(Parameters$Model, levels=new_labels)

Lr_plot<-ggplot(data= Parameters, aes(fill=Type, y=Lr, x=Model)) + 
  geom_violin(position = position_dodge(.25), alpha = .5) +
  scale_fill_manual(values = c("red", "lightblue")) +
  theme_classic()  +
  theme(text = element_text(size=8, family="Times"),plot.title = element_text(size = 8, face = "italic", hjust=0.5, family="Times"), axis.text.x = element_text(angle = 67.5, hjust=1))+
  ggtitle("Learning rate recovery")+
  xlab("Model") +
  ylab("Learning rate") +
  labs(fill =" ")+
  ylim(0,1.1)

Temp_plot<-ggplot(data= Parameters, aes(fill=Type, y=Temp, x=Model)) + 
  geom_violin(position = position_dodge(.25), alpha = .5) +
  scale_fill_manual(values = c("red", "lightblue")) +
  theme_classic()  +
  theme(text = element_text(size=8, family="Times"),plot.title = element_text(size = 8, face = "italic", hjust=0.5, family="Times"), axis.text.x = element_text(angle = 67.5, hjust=1))+
  ggtitle("Temperature recovery")+
  xlab("Model") +
  ylab("Temperature") +
  labs(fill =" ")+
  ylim(0,1.1)

Hybrid_plot<-ggplot(data= Parameters, aes(fill=Type, y=Hybrid, x=Model)) + 
  geom_violin(position = position_dodge(.25), alpha = .5) +
  scale_fill_manual(values = c("red", "lightblue")) +
  theme_classic()  +
  theme(text = element_text(size=8, family="Times"),plot.title = element_text(size = 8, face = "italic", hjust=0.5, family="Times"), axis.text.x = element_text(angle = 67.5, hjust=1))+
  ggtitle("Hybrid recovery")+
  xlab("Model") +
  ylab("Hybrid") +
  labs(fill =" ")+
  ylim(0,1.1)

Cum_plot<-ggplot(data= Parameters, aes(fill=Type, y=Cum, x=Model)) + 
  geom_violin(position = position_dodge(.25), alpha = .5) +
  scale_fill_manual(values = c("red", "lightblue")) +
  theme_classic()  +
  theme(text = element_text(size=8, family="Times"),plot.title = element_text(size = 8, face = "italic", hjust=0.5, family="Times"), axis.text.x = element_text(angle = 67.5, hjust=1))+
  ggtitle("Cumulation recovery")+
  xlab("Model") +
  ylab("Cumulation parameter") +
  labs(fill =" ")+
  ylim(0,1.1)

Hlr_plot<-ggplot(data= Parameters, aes(fill=Type, y=Hlr, x=Model)) + 
  geom_violin(position = position_dodge(.25), alpha = .5) +
  scale_fill_manual(values = c("red", "lightblue")) +
  theme_classic()  +
  theme(text = element_text(size=8, family="Times"),plot.title = element_text(size = 8, face = "italic", hjust=0.5, family="Times"), axis.text.x = element_text(angle = 67.5, hjust=1))+
  ggtitle("Higher learning rate recovery")+
  xlab("Model") +
  ylab("Higher learning rate") +
  labs(fill =" ")+
  ylim(0,1.1)

Distributions_recovery_plot <- ggarrange(Lr_plot, Temp_plot, Hybrid_plot, Cum_plot, Hlr_plot, common.legend = TRUE)
ggsave("Parameter_distributions_recovery.jpg", Distributions_recovery_plot, device = "jpeg", width = 15, height = 12, units = "cm", dpi = 300, path = Endfolder)

#Now we compute the actual recovery as the correlation between true and estimated parameters
Recovery<- data.frame(matrix(vector(),nModels*5,3))
names(Recovery) <-c("Model", "Parameter", "Recovery")

for (i in seq(nModels)){
  dat <- Parameters[Parameters$Model == new_labels[i],]
  Recovery[seq((i-1)*5+1, i*5),1] <- new_labels[i]
  
  Recovery[(i-1)*5+1,2] <- "Lr"
  Recovery[(i-1)*5+1,3] <- round(cor(dat$Lr[dat$Type=="True"], dat$Lr[dat$Type=="Estimated"]),3)
  
  Recovery[(i-1)*5+2,2] <- "Temp"
  Recovery[(i-1)*5+2,3] <- round(cor(dat$Temp[dat$Type=="True"], dat$Temp[dat$Type=="Estimated"]),3)
  
  Recovery[(i-1)*5+3,2] <- "Hybrid"
  Recovery[(i-1)*5+3,3] <- round(cor(dat$Hybrid[dat$Type=="True"], dat$Hybrid[dat$Type=="Estimated"]),3)
  
  Recovery[(i-1)*5+4,2] <- "Cum"
  Recovery[(i-1)*5+4,3] <- round(cor(dat$Cum[dat$Type=="True"], dat$Cum[dat$Type=="Estimated"]),3)
  
  Recovery[(i-1)*5+5,2] <- "Hlr"
  Recovery[(i-1)*5+5,3] <- round(cor(dat$Hlr[dat$Type=="True"], dat$Hlr[dat$Type=="Estimated"]),3)
}

#This is also presented in a heatmap plot
Recovery$Model <- factor(Recovery$Model, levels=new_labels)
Recovery$Parameter <- factor(Recovery$Parameter, levels=c("Lr", "Temp", "Hybrid", "Cum", "Hlr"))

Recovery_raster<-ggplot(data = Recovery, aes(y=Parameter, x=Model, fill = Recovery))+
  geom_raster()+
  scale_fill_gradientn(colours=pal, space="Lab",limits=c(0,.75), oob=squish, na.value = "white")+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"), axis.text.x = element_text(angle = 67.5, hjust=1), legend.title = element_text(size = 8), 
        legend.key.size = unit(.33, 'cm'))+
  ggtitle("Parameter recovery")+
  labs(x="Simulated model")+
  labs(y="Parameter")+
  labs(fill="Recovery\nas corr[True, est])")

ggsave("Parameter_recovery.jpg", Recovery_raster, device = "jpeg",  width = 10, height = 7.5, units = "cm", dpi = 300, path = Endfolder)

#Both recovery plots are combined in one figure
recovery_both<- ggarrange(Recovery_raster, AIC_raster,labels = c( "A", "B"))
ggsave("Recovery_both.jpg", recovery_both, device ="jpeg", width = 17, height = 8.5, units ="cm", dpi=300, path =Endfolder )

