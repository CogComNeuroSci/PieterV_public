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
library(cowplot)
library(grid)
library(gridExtra)

#define folders
Data_folder="/Volumes/Harde ploate/EEG_reversal_learning/Behavioral_data/Data"
RW_fit_folder="/Volumes/Harde ploate/EEG_reversal_learning/model_fitting/RW_data"
Hybrid_fit_folder="/Volumes/Harde ploate/EEG_reversal_learning/model_fitting/Hybrid_data"
Sync_fit_folder="/Volumes/Harde ploate/EEG_reversal_learning/model_fitting/Sync_data"
Sync_bis_folder="/Volumes/Harde ploate/EEG_reversal_learning/model_fitting/Sync_data/bis"
Figure_folder="/Volumes/Harde ploate/EEG_reversal_learning/Behavioral_data/figures/"
setwd(Data_folder)

#define number of participants and number of trials
Tr=480

pplist<-c(3:10,12,14:34) #there were technical problems for subjects 1, 2, 11 and 13

pp=length(pplist)

# read data
for (p in pplist){
  filename= sprintf("Probabilistic_Reversal_task_subject_%s_Session_0_data.tsv",p)
  Single_Data<-read.delim(filename, header = TRUE, sep = "\t", quote = "\"",dec = ".", fill = TRUE)
  if (p==3){
    Data<-Single_Data
  }
  else{
    Data<-rbind(Data, Single_Data)
  }
}

#first look at data
Data[1:10,]
Data=Data[,c(5:16, 26, 28)]# use only relevant variables
start_situation<-Data[Data$Tr==0,]

#standardize data for plotting
Data$corr<-Data$corr*100
Data$RT<-Data$RT*1000

# look at mean performance for each participant
means=aggregate(Data[,9:10], list(Data$ppnr),mean)
colnames(means)<-c("ppnr","RT","corr")

#boxplot
jpeg(paste(Figure_folder,"box_plots.jpeg"), width=14, height= 7, units="cm",pointsize=8, res=300)
par(mfrow=c(1,2))
boxplot(means$corr, main="Total task accuracy", ylab="Accuracy %")
stripchart(means$corr, vertical=TRUE, add=TRUE, method="stack", col='red', pch=19)
boxplot(means$RT, main="Mean RT", ylab="RT (ms)")
stripchart(means$RT, vertical=TRUE, add=TRUE, method="stack", col='red', pch=19)
dev.off()

#remove participants that score too low
empty_vec <- c()
for (sj in c(1:pp)){   
  if (means$corr[sj]<67){
    empty_vec <- c(empty_vec,sj)
  }
}

#update participant list
count=0
for (x in empty_vec){
  Data<-Data[!(Data$ppnr ==pplist[x-count]),]
  pplist<-pplist[!pplist %in% pplist[x-count]]
  count=count+1
}

pp=length(pplist)

#read data from model estimations
#Sync model
setwd(Sync_fit_folder)
for (p in pplist){
  filename= sprintf('Behavioral_data_subject_%s_Sync.csv',p)
  Single_Data_model<-read.delim(filename, header = TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)
  if (p==3){
    Data_model<-Single_Data_model
  }
  else{
    Data_model<-rbind(Data_model, Single_Data_model)
  }
}

Data$Sync_likelihood<-Data_model$Response_likelihood

Sync_data<-read.delim('Sync_output.csv', header=TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)

#Hybrid model
setwd(Hybrid_fit_folder)
for (p in pplist){
  filename= sprintf('Behavioral_data_subject_%s_Hybrid.csv',p)
  Single_Data_model<-read.delim(filename, header = TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)
  if (p==3){
    Data_model<-Single_Data_model
  }
  else{
    Data_model<-rbind(Data_model, Single_Data_model)
  }
}

Data$Hybrid_likelihood<-Data_model$Response_likelihood

Hybrid_data<-read.delim('Hybrid_output.csv', header=TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)

#RW model
setwd(RW_fit_folder)
for (p in pplist){
  filename= sprintf('Behavioral_data_subject_%s_RW.csv',p)
  Single_Data_model<-read.delim(filename, header = TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)
  if (p==3){
    Data_model<-Single_Data_model
  }
  else{
    Data_model<-rbind(Data_model, Single_Data_model)
  }
}

Data$RW_likelihood<-Data_model$Response_likelihood

RW_data<-read.delim('RW_output.csv', header=TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)

#The sync model that accounted for both types of prediction errors as a control
setwd(Sync_bis_folder)

Sync_bis_data<-read.delim('Sync_output_0.csv', header=TRUE, sep = ",", quote = "\"",dec = ".", fill = TRUE)
Sync_bis_data<-Sync_bis_data[,c(2,8)]

# We compare it to the original sync model via weighted aic
Sync_bis_data$AIC_original<-Sync_data$AIC
#determine minimum aic
Sync_bis_data$min_AIC<-apply(Sync_bis_data[,2:3], 1, FUN=min)
#check delta AIC for both models
Sync_bis_data$delta<-exp((-1/2)*(Sync_bis_data$AIC-Sync_bis_data$min_AIC))
Sync_bis_data$delta_original<-exp((-1/2)*(Sync_bis_data$AIC_original-Sync_bis_data$min_AIC))
#compute weighted AIC for both models
Sync_bis_data$wAIC<-Sync_bis_data$delta/(Sync_bis_data$delta+Sync_bis_data$delta_original)
Sync_bis_data$wAIC_original<-Sync_bis_data$delta_original/(Sync_bis_data$delta+Sync_bis_data$delta_original)
# Original sync model explains data best if we look at mean wAIC
mean(Sync_bis_data$wAIC)
#0.2262788
mean(Sync_bis_data$wAIC_original)
#0.7737212

#decode some extra variables
for (data in c(1:(Tr*pp))){
  if (Data$Tr[data]>239 && Data$Tr[data]<255){
    Data$jump_detect[data]=0
  }
  #Based on likelihood of given response, we compute the likelihood of the correct response
  if (Data$corr[data]==0){
    Data$weight[data]=1-Data$weight[data]
    Data$RW_corr_likelihood[data]=1-Data$RW_likelihood[data]
    Data$H_corr_likelihood[data]=1-Data$Hybrid_likelihood[data]
    Data$S_corr_likelihood[data]=1-Data$Sync_likelihood[data]
  }else{
    Data$RW_corr_likelihood[data]=Data$RW_likelihood[data]
    Data$H_corr_likelihood[data]=Data$Hybrid_likelihood[data]
    Data$S_corr_likelihood[data]=Data$Sync_likelihood[data]
  }
  if (Data$Switch_pass[data]<10){
    Data$switch_relative[data]=Data$Switch_pass[data]
    Data$switch_coding[data]=Data$corr[data]/100
    Data$cond[data]=0
  }else {
    Data$cond[data]=1
    Data$switch_relative[data]=NA
    Data$switch_coding[data]=NA
  }
  if (Data$Switch_pass[data]==0 & Data$Tr[data]>10){
    id1=data-5
    id2=data-1
    Data$switch_relative[id1:id2]=seq(-5,-1)
    Data$switch_coding[id1:id2]=((Data$corr[id1:id2]/100)-1)*-1
  }
  if (Data$corr[data]==100){
    Data$rule_behavior[data]=Data$rule[data]
  }
  else{
    if (Data$rule[data]==1){
      Data$rule_behavior[data]=0
    }
    else{
      Data$rule_behavior[data]=1
    }
  }
  if (Data$Tr[data]>0){
    Data$corrP[data]=Data$corr[data-1]/100
    Data$RTP[data]=Data$RT[data-1]
    Data$FBP[data]=Data$FB[data-1]
    if (!is.na(Data$jump_detect[data-1]) & Data$jump_detect[data-1]>0){
      Data$DetectP[data]=Data$jump_detect[data-1]
      Data$pressP[data]=1
    }else {
      Data$DetectP[data]=0
      Data$pressP[data]=0
    }
    if (Data$rule_behavior[data-1]!=Data$rule_behavior[data]){
      Data$Switch_made[data]=1
    } else {
      Data$Switch_made[data]=0
    }
  }
}

#make plots of subject behavior
out <- split( Data , f = Data$ppnr )
jpeg(paste(Figure_folder,"rule_behavior.jpeg"), width=21, height = 14, units ="cm", pointsize=8, res=300)
par(mfrow=c(2,2))
for (s in seq(6 , pp, by=6)){
  x<-out[[s]]
  a=x$rule_behavior~x$Tr
  plot_title= sprintf('Responses subject %s',x$ppnr[1])
  plot(a, main=plot_title, xlab='Trial', ylab='Rule', col='blue',yaxt="n",lwd=1)
  axis(2, at=c(0,1))

  lines(x$rule~x$Tr, col='black',lwd=2)
  switchtrials<-x$Switch_pass==0
  thresholdtrials<-x$jump_detect>0
  for (t in c(1:Tr)){
    if (is.na(thresholdtrials[t])){

    }
    else{
      if (thresholdtrials[t]){
        abline( v=t, col='red',lwd=2)
      }
    }
  }
}
legend(-150, 1.5, legend=c("Behavior", "Rule", "Switch press"), col=c("blue","black", "red"),  lty=c(0,1,1), pch=c(1,NA,NA), box.lty=0, lwd=2, xpd="NA")
dev.off()

#eliminate late trials and the first trial
Data_nolates<-Data[!(Data$RT>1000),]
Data_nolates<-Data_nolates[!(Data_nolates$Tr==0),]
Data_nolates<-Data_nolates[!(Data_nolates$Break_pass==0),]
Data_nolates<-Data_nolates[!(Data_nolates$RTP>1000),] #also where previous trial was too late

means_after=aggregate(Data_nolates[,9:10], list(Data_nolates$ppnr),mean)
colnames(means_after)<-c("ppnr","RT","corr")

#boxplot again
jpeg(paste(Figure_folder,"box_plots_after.jpeg"), width=14, height= 7, units="cm",pointsize=8, res=300)
par(mfrow=c(1,2))
boxplot(means_after$corr, main="Total task accuracy", ylab="Accuracy %")
stripchart(means_after$corr, vertical=TRUE, add=TRUE, method="stack", col='red', pch=19)
boxplot(means_after$RT, main="Mean RT", ylab="RT (ms)")
stripchart(means_after$RT, vertical=TRUE, add=TRUE, method="stack", col='red', pch=19)
dev.off()

#pirateplot
pirateplot(corr~ppnr, data=Data_nolates)
pirateplot(RT~ppnr, data=Data_nolates, main="RT per participant")
dev.off()

#define which variables are factors
Data_nolates$Block<-as.factor(Data_nolates$Block)
Data_nolates$rule<-as.factor(Data_nolates$rule)
Data_nolates$Grating<-as.factor(Data_nolates$Grating)
Data_nolates$FB<-as.factor(Data_nolates$FB)
Data_nolates$jump_detect<-as.factor(Data_nolates$jump_detect)
Data_nolates$cond<-as.factor(Data_nolates$cond)
Data_nolates$rule_behavior<-as.factor(Data_nolates$rule_behavior)
Data_nolates$corrP<-as.factor(Data_nolates$corrP)
Data_nolates$FBP<-as.factor(Data_nolates$FBP)
Data_nolates$DetectP<-as.factor(Data_nolates$DetectP)
Data_nolates$pressP<-as.factor(Data_nolates$pressP)
Data_nolates$Switch_made<-as.factor(Data_nolates$Switch_made)

# Look at RT distribution: not normal so we use logRT
densityplot(~RT,data=Data_nolates)
Data_nolates$logRT<-log(Data_nolates$RT)
densityplot(~logRT,data=Data_nolates)

mean_logRT<-aggregate(Data_nolates$logRT, list(Data_nolates$ppnr),mean)
names(mean_logRT)<-c("ppnr", "RT")

# Look at when participant made and detected most switches
Data$Switch_made<-as.factor(Data$Switch_made)
Data$jump_detect<-as.factor(Data$jump_detect)
Data$pressP<-as.factor(Data$pressP)
densityPlot(Switch_pass~Switch_made,data=Data)
densityPlot(Switch_pass~pressP,data=Data)

# look at switch indications
Switches<-Data[complete.cases(Data[,1:14]),]
Switches$jump_detect<-as.numeric(Switches$jump_detect)-1
Switches<-Switches[Switches$jump_detect>0,]

count<-table(Switches$jump_detect,Switches$ppnr)

#make plot
jpeg(paste(Figure_folder,"switch_presses.jpeg"), width=21, height= 14, units="cm",pointsize=8, res=300)
barplot(count, xlab="Participants", ylab="Counts", legend.text = c("correct", "too late","too early"),    args.legend=list(x=20,y=15, bty = "n"), col = c("red","blue","black"), main="Switch presses", beside=TRUE)
abline(h=7, col='lightgreen',lwd=2, lty=2)
dev.off()

#compare blocks with and without switch indication
means_perblock=aggregate(Data_nolates[,c(9,10,31)], list(Data_nolates$ppnr,Data_nolates$Block),mean)
colnames(means_perblock)<-c("ppnr","Block","RT","corr","logRT")

#check for differences with a t-test
t.test(means_perblock$logRT~means_perblock$Block, paired= TRUE)
# Paired t-test
# 
# data:  means_perblock$logRT by means_perblock$Block
# t = -1.2902, df = 26, p-value = 0.2083
# alternative hypothesis: true difference in means is not equal to 0
# 95 percent confidence interval:
#   -0.033102120  0.007572367
# sample estimates:
#   mean of the differences 
# -0.01276488 

t.test(means_perblock$corr~means_perblock$Block, paired= TRUE)

# Paired t-test
# 
# data:  means_perblock$corr by means_perblock$Block
# t = 0.029067, df = 26, p-value = 0.977
# alternative hypothesis: true difference in means is not equal to 0
# 95 percent confidence interval:
#   -2.806226  2.886729
# sample estimates:
#   mean of the differences 
# 0.04025179 

# make seperate datasets per block
block1=Data_nolates[Data_nolates$Block==0,]
block2=Data_nolates[Data_nolates$Block==1,]

#plot differences for RT and accuracy
blockaccuracy_fig<-summarySE(data = Data_nolates, measurevar = "corr", groupvars = "Block")

block_fig<- ggplot(blockaccuracy_fig, aes(x=Block, y=corr))+
            geom_bar(stat="identity", fill="red", width = 0.5)+
            geom_errorbar(aes(ymin=corr-ci, ymax=corr+ci), width = 0.2)+
            theme_classic()+
            ggtitle("Accuracy per block")+
            theme(axis.text = element_text(size=12, family="Times"), plot.title = element_text(size = 18, face = "bold", hjust=0.5, family="Times"))+
            labs(x="Block")+
            labs(y="Accuracy %")+
            scale_x_discrete(labels=c("0"="With indication", "1"="Without indication"))+
            scale_y_continuous(limits =c(50,100), oob=rescale_none)

blockrt_fig<-summarySE(data = Data_nolates, measurevar = "logRT", groupvars = "Block")

block_fig2<- ggplot(blockrt_fig, aes(x=Block, y=logRT))+
              geom_bar(stat="identity", fill="red", width=0.5)+
              geom_errorbar(aes(ymin=logRT-ci, ymax=logRT+ci), width =0.2)+
              theme_classic()+
              ggtitle("RT per block")+
              theme(axis.text = element_text(size=12, family="Times"), plot.title = element_text(size = 18, face = "bold", hjust=0.5, family="Times"))+
              labs(x="Block")+
              labs(y="logRT")+
              scale_x_discrete(labels=c("0"="With indication", "1"="Without indication"))+
              scale_y_continuous(limits =c(6,6.5), oob=rescale_none)

figure<-ggarrange(block_fig, block_fig2, labels="AUTO", nrow=2)

figure

ggsave(filename= paste(Figure_folder, "Block_fig.jpeg"), figure, width=10, height=14, units="cm", dpi=300)

#new variables that indicate how long ago the participant indicated a switch
block1<-block1[!is.na(block1[,19]),]
block1[block1$DetectP==3,19]<-2

block1$sinceDetect<-0
block1$jump_detect<-as.numeric(block1$jump_detect)-1
for (x in c(2:length(block1$Block))){
  if (block1$jump_detect[x]>0){
    block1$sinceDetect[x]<-0
  }else{
    block1$sinceDetect[x]<-block1$sinceDetect[x-1]+1
  }
}

#only for correct indications here
block1$sinceDetect_extra<-0
for (x in c(2:length(block1$Block))){
  if (block1$jump_detect[x]==1){
    block1$sinceDetect_extra[x]<-0
  }else{
    block1$sinceDetect_extra[x]<-block1$sinceDetect_extra[x-1]+1
  }
}

# check evolution after switch press for RT and accuracy
fig_ind_extra_RT<-summarySE(block1, measurevar="RT", groupvars=c("sinceDetect_extra"))
fig_ind_extra_RT<-na.omit(fig_ind_extra_RT)

Press_RT_fig<- ggplot(fig_ind_extra_RT, aes(x=sinceDetect_extra, y=RT)) +
                geom_ribbon(aes(ymin=RT-ci, ymax=RT+ci), alpha=0.5)+
                geom_line()+
                geom_point()+
                theme_classic()+
                labs(x="Trial after switch press")+
                labs(y="RT(ms)")+
                ggtitle("RT after indication of switch")+
                theme(axis.text = element_text(size=12, family="Times"), plot.title = element_text(size = 14, face = "bold", hjust=0.5, family="Times"))+
                scale_y_continuous(limits =c(450,650), oob=rescale_none)+
                scale_x_continuous(limits =c(0,15), oob=rescale_none)

fig_ind_extra_accuracy<-summarySE(block1, measurevar="corr", groupvars=c("sinceDetect_extra"))
fig_ind_extra_accuracy<-na.omit(fig_ind_extra_accuracy)

Press_accuracy_fig<-  ggplot(fig_ind_extra_accuracy, aes(x=sinceDetect_extra, y=corr)) +
                      geom_ribbon(aes(ymin=corr-ci, ymax=corr+ci), alpha=0.5)+
                      geom_line()+
                      geom_point()+
                      theme_classic()+
                      labs(x="Trial after switch press")+
                      labs(y="Accuracy %")+
                      ggtitle("Accuracy after indication of switch")+
                      theme(axis.text = element_text(size=12, family="Times"), plot.title = element_text(size = 14, face = "bold", hjust=0.5, family="Times"))+
                      scale_y_continuous(limits =c(0,100), oob=rescale_none)+
                      scale_x_continuous(limits =c(0,15), oob=rescale_none)

figure<-ggarrange(Press_RT_fig, Press_accuracy_fig, labels="AUTO", nrow=2)

figure

ggsave(filename= paste(Figure_folder, "Press_fig.jpeg"), figure, width=10, height=14, units="cm", dpi=300)

#retransform accuracy
Data_nolates$corr2<-Data_nolates$corr/100

#Aggregate accuracy depending on rule switch
corr_dat<-aggregate( x= Data_nolates$corr2, by=list(Data_nolates$ppnr,Data_nolates$Switch_pass ), FUN="mean")
names(corr_dat)[1:3]<-c("ppnr", "Switch_pass","corr2")
corr_mean_dat<-summarySE(data = corr_dat, measurevar = "corr2", groupvars=c("Switch_pass"))
corr_mean_dat<-corr_mean_dat[corr_mean_dat$Switch_pass<31,]

#Aggregate likelihood of correct response for Qlearn model depending on rule switch
RW_lik_dat<-aggregate( x= Data_nolates$RW_corr_likelihood, by=list(Data_nolates$ppnr,Data_nolates$Switch_pass ), FUN="mean")
names(RW_lik_dat)[1:3]<-c("ppnr", "Switch_pass","RW_lik")
RW_lik_mean_dat<-summarySE(data = RW_lik_dat, measurevar = "RW_lik", groupvars=c("Switch_pass"))

#Aggregate likelihood of correct response for Hybrid model depending on rule switch
H_lik_dat<-aggregate( x= Data_nolates$H_corr_likelihood, by=list(Data_nolates$ppnr,Data_nolates$Switch_pass ), FUN="mean")
names(H_lik_dat)[1:3]<-c("ppnr", "Switch_pass","H_lik")
H_lik_mean_dat<-summarySE(data = H_lik_dat, measurevar = "H_lik", groupvars=c("Switch_pass"))

#Aggregate likelihood of correct response for Sync model depending on rule switch
S_lik_dat<-aggregate( x= Data_nolates$S_corr_likelihood, by=list(Data_nolates$ppnr,Data_nolates$Switch_pass ), FUN="mean")
names(S_lik_dat)[1:3]<-c("ppnr", "Switch_pass","S_lik")
S_lik_mean_dat<-summarySE(data = S_lik_dat, measurevar = "S_lik", groupvars=c("Switch_pass"))

#Comparative plot for RWlearn model
RW_lik_figure<-ggplot()+
  geom_point(aes(x=corr_mean_dat$Switch_pass, y=corr_mean_dat$corr2))+
  geom_errorbar(aes(x=corr_mean_dat$Switch_pass, ymin=corr_mean_dat$corr2-corr_mean_dat$ci, ymax=corr_mean_dat$corr2+corr_mean_dat$ci), width=.2)+
  geom_line(aes(x=RW_lik_mean_dat$Switch_pass, y=RW_lik_mean_dat$RW_lik), size=2, color="red")+
  geom_ribbon(aes(x=RW_lik_mean_dat$Switch_pass, ymin=RW_lik_mean_dat$RW_lik-RW_lik_mean_dat$ci, ymax= RW_lik_mean_dat$RW_lik+RW_lik_mean_dat$ci),alpha=0.5, fill="red")+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  ggtitle("RW Model")+
  labs(y="Accuracy/ L(correct) %")+
  labs(x="Trial to rule switch")+
  scale_x_continuous(limits=c(0,30), oob=rescale_none)+
  scale_y_continuous(limits =c(0,1), oob=rescale_none, labels = c("0", "25", "50", "75", "100"))

#Comparative plot for Hybrid model
H_lik_figure<-ggplot()+
  geom_point(aes(x=corr_mean_dat$Switch_pass, y=corr_mean_dat$corr2))+
  geom_errorbar(aes(x=corr_mean_dat$Switch_pass, ymin=corr_mean_dat$corr2-corr_mean_dat$ci, ymax=corr_mean_dat$corr2+corr_mean_dat$ci), width=.2)+
  geom_line(aes(x=H_lik_mean_dat$Switch_pass, y=H_lik_mean_dat$H_lik), size=2, color="red")+
  geom_ribbon(aes(x=H_lik_mean_dat$Switch_pass, ymin=H_lik_mean_dat$H_lik-H_lik_mean_dat$ci, ymax= H_lik_mean_dat$H_lik+H_lik_mean_dat$ci),alpha=0.5, fill="red")+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  ggtitle("ALR Model")+
  labs(y="Accuracy/ L(correct) %")+
  labs(x="Trial to rule switch")+
  scale_x_continuous(limits=c(0,30), oob=rescale_none)+
  scale_y_continuous(limits =c(0,1), oob=rescale_none, labels = c("0", "25", "50", "75", "100"))

#Comparative plot for Sync model
S_lik_figure<-ggplot()+
  geom_point(aes(x=corr_mean_dat$Switch_pass, y=corr_mean_dat$corr2))+
  geom_errorbar(aes(x=corr_mean_dat$Switch_pass, ymin=corr_mean_dat$corr2-corr_mean_dat$ci, ymax=corr_mean_dat$corr2+corr_mean_dat$ci), width=.2)+
  geom_line(aes(x=S_lik_mean_dat$Switch_pass, y=S_lik_mean_dat$S_lik), size=2, color="red")+
  geom_ribbon(aes(x=S_lik_mean_dat$Switch_pass, ymin=S_lik_mean_dat$S_lik-S_lik_mean_dat$ci, ymax= S_lik_mean_dat$S_lik+S_lik_mean_dat$ci),alpha=0.5, fill="red")+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  ggtitle("bSync Model")+
  labs(y="Accuracy/ L(correct) %")+
  labs(x="Trial to rule switch")+
  scale_x_continuous(limits=c(0,30), oob=rescale_none)+
  scale_y_continuous(limits =c(0,1), oob=rescale_none, labels = c("0", "25", "50", "75", "100"))

#make figure
Lik_figure<-ggarrange(RW_lik_figure, H_lik_figure, S_lik_figure, ncol=3)

Lik_figure

#Compare model fit metrics
#LogLikelihood
RW_mean_LL<-mean_ci(RW_data$LogLik, ci=0.95)
H_mean_LL<-mean_ci(Hybrid_data$LogLik, ci=0.95)
S_mean_LL<-mean_ci(Sync_data$LogLik, ci=0.95)

t.test(Sync_data$LogLik, Hybrid_data$LogLik, paired = TRUE)
# Paired t-test
# 
# data:  Sync_data$LogLik and Hybrid_data$LogLik
# t = 13.731, df = 26, p-value = 2.002e-13
# alternative hypothesis: true difference in means is not equal to 0
# 95 percent confidence interval:
#   2.522959 3.411346
# sample estimates:
#   mean of the differences 
# 2.967153 
t.test(Sync_data$LogLik, RW_data$LogLik, paired = TRUE)
# Paired t-test
# 
# data:  Sync_data$LogLik and RW_data$LogLik
# t = 8.1942, df = 26, p-value = 1.125e-08
# alternative hypothesis: true difference in means is not equal to 0
# 95 percent confidence interval:
#   1.298867 2.168720
# sample estimates:
#   mean of the differences 
# 1.733794

LL_dat<-rbind(S_mean_LL, H_mean_LL, RW_mean_LL)
colnames(LL_dat)<-c("Measure", "Min", "Max")

#AIC
RW_mean_AIC<-mean_ci(RW_data$AIC, ci=0.95)
H_mean_AIC<-mean_ci(Hybrid_data$AIC, ci=0.95)
S_mean_AIC<-mean_ci(Sync_data$AIC, ci=0.95)

t.test(Hybrid_data$AIC, RW_data$AIC, paired = TRUE)
t.test(Sync_data$AIC, RW_data$AIC, paired = TRUE)

AIC_dat<-rbind(S_mean_AIC, H_mean_AIC, RW_mean_AIC)
colnames(AIC_dat)<-c("Measure", "Min", "Max")

#BIC
RW_mean_BIC<-mean_ci(RW_data$BIC, ci=0.95)
H_mean_BIC<-mean_ci(Hybrid_data$BIC, ci=0.95)
S_mean_BIC<-mean_ci(Sync_data$BIC, ci=0.95)

t.test(Hybrid_data$BIC, RW_data$BIC, paired = TRUE)
t.test(Sync_data$BIC, RW_data$BIC, paired = TRUE)

BIC_dat<-rbind(S_mean_BIC, H_mean_BIC, RW_mean_BIC)
colnames(BIC_dat)<-c("Measure", "Min", "Max")

Weight_AIC_dat<-matrix(nrow=27, ncol=12)
Weight_AIC_dat[,1:3]<-cbind(Sync_data$AIC, Hybrid_data$AIC, RW_data$AIC)
Weight_AIC_dat[,4:6]<-Weight_AIC_dat[,1:3]-cbind(apply(Weight_AIC_dat[,1:3], 1, FUN=min),apply(Weight_AIC_dat[,1:3], 1, FUN=min),apply(Weight_AIC_dat[,1:3], 1, FUN=min)) 

Weight_AIC_dat[,7:9]<-exp(-1/2*Weight_AIC_dat[,4:6])
Weight_AIC_dat[,10:12]<-Weight_AIC_dat[,7:9]/apply(Weight_AIC_dat[,7:9], 1, FUN=sum)

Weight_AIC_dat<-as.data.frame(Weight_AIC_dat)
names(Weight_AIC_dat)<-c("S_AIC","H_AIC","RW_AIC","Delta_S_AIC", "Delta_H_AIC", "Delta_RW_AIC", "Exp_S_AIC","Exp_H_AIC","Exp_RW_AIC","S_wAIC","H_wAIC","RW_wAIC")

t.test(Weight_AIC_dat$S_wAIC, Weight_AIC_dat$H_wAIC, paired = TRUE)
t.test(Weight_AIC_dat$S_wAIC, Weight_AIC_dat$RW_wAIC, paired = TRUE)

RW_mean_wAIC<-mean_ci(Weight_AIC_dat$RW_wAIC, ci=0.95)
H_mean_wAIC<-mean_ci(Weight_AIC_dat$H_wAIC, ci=0.95)
S_mean_wAIC<-mean_ci(Weight_AIC_dat$S_wAIC, ci=0.95)
wAIC_dat<-rbind(S_mean_wAIC, H_mean_wAIC, RW_mean_wAIC)
colnames(wAIC_dat)<-c("Measure", "Min", "Max")

#combine
Model_dat<-rbind(-LL_dat, AIC_dat, wAIC_dat, BIC_dat)
Model_dat<-cbind(Model_dat,rep(1:4, each=3), rep(1:3, times=4))
names(Model_dat)[4:5]<-c("Type","Model")
Model_dat$Type<-as.factor(Model_dat$Type)
Model_dat$Model<-as.factor(Model_dat$Model)

#make it in plots
LL_fig<-ggplot(data=Model_dat[Model_dat$Type==1,], aes(x=Model, y=Measure))+
                  geom_bar(stat="identity", position=position_dodge(), color="black", fill="darkblue",alpha=0.5)+
                  geom_errorbar(aes(ymin=Min, ymax=Max), width=.2, position=position_dodge(.9))+
                  labs(y="-LogLikelihood")+
                  labs(x="Model")+
                  scale_x_discrete(labels=c("1"="bSync", "2"= "ALR", "3"= "RW"))+
                  scale_y_continuous(limits =c(205,210), oob=rescale_none)+
                  theme_classic()+
                  theme(text = element_text(size=8, family="Times"))

AIC_fig<-ggplot(data=Model_dat[Model_dat$Type==2,], aes(x=Model, y=Measure))+
  geom_bar(stat="identity", position=position_dodge(), color="black", fill="darkblue",alpha=0.5)+
  geom_errorbar(aes(ymin=Min, ymax=Max), width=.2, position=position_dodge(.9))+
  labs(y="AIC")+
  labs(x="Model")+
  scale_x_discrete(labels=c("1"="bSync", "2"= "ALR", "3"= "RW"))+
  scale_y_continuous(limits =c(415,430), oob=rescale_none)+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"))

wAIC_fig<-ggplot(data=Model_dat[Model_dat$Type==3,], aes(x=Model, y=Measure))+
  geom_bar(stat="identity", position=position_dodge(), color="black", fill="darkblue",alpha=0.5)+
  geom_errorbar(aes(ymin=Min, ymax=Max), width=.2, position=position_dodge(.9))+
  labs(y="wAIC")+
  labs(x="Model")+
  scale_x_discrete(labels=c("1"="bSync", "2"= "ALR", "3"= "RW"))+
  scale_y_continuous(limits =c(0,1), oob=rescale_none)+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"))

cor.test(Weight_AIC_dat$S_wAIC,Sync_data$Cumulation, method="spearman")
cor.test(Weight_AIC_dat$S_wAIC,Sync_data$Learning.low, method="spearman")
cor.test(Weight_AIC_dat$S_wAIC,Sync_data$Learning.high, method="spearman")
cor.test(Weight_AIC_dat$S_wAIC,Sync_data$Temperature, method="spearman")
cor.test(Weight_AIC_dat$S_wAIC,means_after$cor, method="spearman")
cor.test(Weight_AIC_dat$S_wAIC,mean_logRT$RT, method="spearman")

cor.test(Weight_AIC_dat$RW_wAIC,RW_data$Learning.rate)
cor.test(Weight_AIC_dat$RW_wAIC,RW_data$Temperature)

cor.test(Weight_AIC_dat$H_wAIC,Hybrid_data$Learning.rate)
cor.test(Weight_AIC_dat$H_wAIC,Hybrid_data$Temperature)
cor.test(Weight_AIC_dat$H_wAIC,Hybrid_data$Decrease)

Correlation_plotCumulation<-ggplot(Sync_data,aes(y=Sync_data$Cumulation, x=Weight_AIC_dat$S_wAIC))+
  geom_point()+
  geom_smooth(method=lm)+
  labs(x="wAIC bSync")+
  labs(y="Cumulation")+
  ggtitle('p < .001')+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"),plot.title = element_text(size = 8, face = "italic", hjust=0.5, family="Times"))

Correlation_plotLearningLow<-ggplot(Sync_data,aes(y=Sync_data$Learning.low, x=Weight_AIC_dat$S_wAIC))+
  geom_point()+
  geom_smooth(method=lm)+
  labs(x="wAIC bSync")+
  labs(y="Mapping learnrate")+
  ggtitle('p = .468')+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"),plot.title = element_text(size = 8, face = "italic", hjust=0.5, family="Times"))

Correlation_plotLearningHigh<-ggplot(Sync_data,aes(y=Sync_data$Learning.high, x=Weight_AIC_dat$S_wAIC))+
  geom_point()+
  geom_smooth(method=lm)+
  labs(x="wAIC bSync")+
  labs(y="Switch learnrate")+
  ggtitle('p < .001')+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"),plot.title = element_text(size = 8, face = "italic", hjust=0.5, family="Times"))

Correlation_plotTemperature<-ggplot(Sync_data,aes(y=Sync_data$Temperature, x=Weight_AIC_dat$S_wAIC))+
  geom_point()+
  geom_smooth(method=lm)+
  labs(x="wAIC bSync")+
  labs(y="Temperature")+
  ggtitle('p = .008')+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"),plot.title = element_text(size = 8, face = "italic", hjust=0.5, family="Times"))

Correlation_plotaccuracy<-ggplot(Sync_data,aes(y=means_after$corr, x=Weight_AIC_dat$S_wAIC))+
  geom_point()+
  geom_smooth(method=lm)+
  labs(x="wAIC bSync")+
  labs(y="Accuracy")+
  ggtitle('p = .007')+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"),plot.title = element_text(size = 8, face = "italic", hjust=0.5, family="Times"))

extra_wAIC<-as.data.frame(Weight_AIC_dat[,10])
names(extra_wAIC)<-c("wAIC")
extra_wAIC$group<-0
extra_wAIC$ppnr<-seq(1,27)
extra_wAIC[extra_wAIC$wAIC<.2,2]<-1
extra_wAIC[extra_wAIC$wAIC>.2,2]<-2
extra_wAIC[extra_wAIC$wAIC>.5,2]<-3

RW_lik_dat$Group<-NA
H_lik_dat$Group<-NA
S_lik_dat$Group<-NA
RW_lik_dat$Group[1:(31*27)]<-rep(extra_wAIC$group,31)
H_lik_dat$Group[1:(31*27)]<-rep(extra_wAIC$group,31)
S_lik_dat$Group[1:(31*27)]<-rep(extra_wAIC$group,31)
RW_lik_mean_dat_bis<-summarySE(data = RW_lik_dat, measurevar = "RW_lik", groupvars=c("Switch_pass","Group"))
H_lik_mean_dat_bis<-summarySE(data = H_lik_dat, measurevar = "H_lik", groupvars=c("Switch_pass","Group"))
S_lik_mean_dat_bis<-summarySE(data = S_lik_dat, measurevar = "S_lik", groupvars=c("Switch_pass","Group"))
RW_lik_mean_dat_bis$Group<-as.factor(RW_lik_mean_dat_bis$Group)
H_lik_mean_dat_bis$Group<-as.factor(H_lik_mean_dat_bis$Group)
S_lik_mean_dat_bis$Group<-as.factor(S_lik_mean_dat_bis$Group)

extra_wAIC<-extra_wAIC[order(extra_wAIC$wAIC),]
extra_wAIC$group<-as.factor(extra_wAIC$group)

Group_plot<-ggplot(extra_wAIC, aes(y=wAIC, x=group, color=group, fill=group))+
            geom_point(size=0.5)+
            geom_violin(alpha=0.5)+
            labs(y="wAIC bSync")+
            labs(x="group")+
            ggtitle('wAIC groups')+
            theme_classic()+
            theme(text = element_text(size=8, family="Times"),plot.title = element_text(size = 8, face = "italic", hjust=0.5, family="Times"), legend.position = "bottom")+
            scale_colour_manual(values=c("red", "blue","lightgreen"),name = 'wAIC groups', labels = c('0.1','0.4','0.7'))+
            scale_fill_manual(values=c("red", "blue","lightgreen"),name = 'wAIC groups', labels = c('0.1','0.4','0.7'))+
            scale_x_discrete(labels=c('1'='0.1', '2'='0.4', '3'='0.7'))+
            scale_y_continuous(limits = c(0,0.8))#+
            #guides(fill= FALSE, color=FALSE)

Group_plot

Correlation_figure<- ggarrange(Correlation_plotLearningLow,Correlation_plotTemperature, Correlation_plotLearningHigh, Correlation_plotCumulation, Correlation_plotaccuracy, ncol=3, nrow=2)

Comparison_figure<-ggarrange(LL_fig, wAIC_fig, Correlation_figure, ncol=3, widths=c(0.7,0.7,1), labels=c("C","","D"), font.label = list(size=12, face="bold", family="Times"))
Comparison_figure

#Plot distributions of parameters
#RW learn model
RW_learningrate<-ggplot(data=RW_data, aes(x=Learning.rate))+
                geom_density(color="black", fill="darkblue",alpha=0.5)+
                theme_classic()+
                theme(text = element_text(size=8, family="Times"))+
                labs(y="")+
                labs(x="Mapping Learnrate")+
                scale_x_continuous(breaks=seq(0.8,0.85, 0.05))

RW_Temperature<-ggplot(data=RW_data, aes(x=Temperature))+
  geom_density(color="black", fill="darkblue",alpha=0.5)+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"))+
  labs(y="")+
  labs(x="Temperature")+
  scale_x_continuous(breaks=seq(0.4,0.42, 0.02))

RW_param_figure<-ggarrange(RW_learningrate, RW_Temperature, ncol=2, nrow=2)
RW_param_figure<-annotate_figure(RW_param_figure, top=text_grob("RW model", size=8, face="bold", family="Times"))

#Hybrid model
H_Learningrate<-ggplot(data=Hybrid_data, aes(x=Learning.rate))+
  geom_density(color="black", fill="darkblue",alpha=0.5)+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"))+
  labs(y="")+
  labs(x="Mapping Learnrate")+
  scale_x_continuous(breaks=seq(0.2,1, 0.4))

H_Temperature<-ggplot(data=Hybrid_data, aes(x=Temperature))+
  geom_density(color="black", fill="darkblue",alpha=0.5)+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"))+
  labs(y="")+
  labs(x="Temperature")+
  scale_x_continuous(breaks=seq(0.35,0.37, 0.02))

H_Decrease<-ggplot(data=Hybrid_data, aes(x=Decrease))+
  geom_density(color="black", fill="darkblue",alpha=0.5)+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"))+
  labs(y="")+
  labs(x="Hybrid")+
  scale_x_continuous(breaks=seq(0.85,0.9, 0.05))

H_param_figure<-ggarrange(H_Learningrate, H_Temperature, H_Decrease, ncol=2, nrow=2)
H_param_figure<-annotate_figure(H_param_figure, top=text_grob("ALR model", size=8, face="bold", family="Times"))

#Sync model
S_Learningrate1<-ggplot(data=Sync_data, aes(x=Learning.low))+
  geom_density(color="black", fill="darkblue",alpha=0.5)+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"))+
  labs(y="")+
  labs(x="Mapping Learnrate")+
  scale_x_continuous(breaks=seq(0.8,0.9, 0.05))

S_Temperature<-ggplot(data=Sync_data, aes(x=Temperature))+
  geom_density(color="black", fill="darkblue",alpha=0.5)+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"))+
  labs(y="")+
  labs(x="Temperature")+
  scale_x_continuous(breaks=seq(0.38,0.42, 0.02))

S_Cumulation<-ggplot(data=Sync_data, aes(x=Cumulation))+
  geom_density(color="black", fill="darkblue",alpha=0.5)+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"))+
  labs(y="")+
  labs(x="Cumulation")+
  scale_x_continuous(breaks=seq(0,0.75, 0.25))

S_Learningrate2<-ggplot(data=Sync_data, aes(x=Learning.high))+
  geom_density(color="black", fill="darkblue",alpha=0.5)+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"))+
  labs(y="")+
  labs(x="Switch Learnrate")+
  scale_x_continuous(breaks=seq(0,0.8, 0.4))

S_param_figure<-ggarrange(S_Learningrate1, S_Temperature,S_Learningrate2, S_Cumulation, ncol=2, nrow=2)
S_param_figure<-annotate_figure(S_param_figure, top=text_grob("bSync model", size=8, face="bold", family="Times"))

#complete parameter figure
Parameter_figure<-ggarrange(S_param_figure, H_param_figure, RW_param_figure, ncol=3)
Parameter_figure

table1<-rbind(cbind(round(mean(RW_data$LogLik),digits=2), round(sd(RW_data$LogLik),digits = 2)),cbind(round(mean(Hybrid_data$LogLik), digits=2), round(sd(Hybrid_data$LogLik), digits=2)), cbind(round(mean(Sync_data$LogLik), digits=2), round(sd(Sync_data$LogLik), digits=2)) )
table2<-rbind(cbind(round(mean(RW_data$AIC), digits=2), round(sd(RW_data$AIC), digits=2)),cbind(round(mean(Hybrid_data$AIC), digits=2), round(sd(Hybrid_data$AIC), digits=2)), cbind(round(mean(Sync_data$AIC), digits=2), round(sd(Sync_data$AIC), digits=2)) )
table3<-rbind(cbind(round(mean(Weight_AIC_dat$RW_wAIC), digits=2), round(sd(Weight_AIC_dat$RW_wAIC), digits=2)),cbind(round(mean(Weight_AIC_dat$H_wAIC), digits=2), round(sd(Weight_AIC_dat$H_wAIC), digits=2)), cbind(round(mean(Weight_AIC_dat$S_wAIC), digits=2), round(sd(Weight_AIC_dat$S_wAIC), digits=2)) )
ModelLabels<-c("RW", "ALR", "bSync")
tabletot<-cbind(ModelLabels,table1, table2, table3)
tabletot<-as.data.frame(tabletot)
names(tabletot)<-c("Model","Mean LL", "std LL", "Mean AIC", "std AIC", "Mean wAIC", "std wAIC")
g<-tableGrob(tabletot, theme=ttheme_minimal(base_size = 8,base_family = "Times"), rows = NULL)
grid.draw(g)
g2<-ggtexttable(tabletot, rows = NULL, theme = ttheme("minimal",base_size = 8))

g2

#Total figure
Total_figure<-ggdraw() +
       draw_plot(RW_lik_figure, x = 0, y = .41, width = .33, height = .25) +
       draw_plot(H_lik_figure, x = .33, y = .41, width = .33, height = .25) +
       draw_plot(S_lik_figure, x = .66, y = .41, width = .33, height = .25) +
       draw_plot(RW_param_figure, x = 0, y = .66, width = .33, height = .33) +
       draw_plot(H_param_figure, x = .33, y = .66, width = .33, height = .33) +
       draw_plot(S_param_figure, x = .66, y = .66, width = .33, height = .33) +
       #draw_grob(tableGrob(tabletot, theme=ttheme_minimal(base_size = 8,base_family = "Times"), rows = NULL), x=0, y=0.04, width=0.6, height=0.33)+
       draw_plot(Group_plot, x = 0, y = .04, width = .25, height = .25) +
       draw_plot(Correlation_figure, x = 0.3, y = 0, width = .7, height = .41) +
       draw_plot_label(label = c("A","B","C","D"), x=c(0,0,0,0.275),y=c(1,0.66,0.38,0.38), size = 12,fontface="bold", family="Times")

Total_figure

ggsave(filename= paste(Figure_folder, "Model_comparison.tiff"), Total_figure, width=17.5, height=19, units="cm", dpi=300)

# Analyse RTs as well
fit_logRT<-lmer(logRT~(1|ppnr)+Switch_pass, data=Data_nolates[Data_nolates$Switch_pass<31,])

summary(fit_logRT)
Anova(fit_logRT)

ef_logRT<-effect("Switch_pass", fit_logRT,  xlevels=list(Switch_pass=seq(0,30)))
plot_logRT<-as.data.frame(ef_logRT)

logRT_mean_dat<-summarySE(data = Data_nolates, measurevar = "logRT", groupvars=c("Switch_pass"))
logRT_mean_dat<-logRT_mean_dat[logRT_mean_dat$Switch_pass<31,]

logRT_figure<-ggplot(data=plot_logRT, aes(x=Switch_pass, y= fit) )+
  geom_point(aes(x=logRT_mean_dat$Switch_pass, y=logRT_mean_dat$logRT))+
  geom_errorbar(aes(x=logRT_mean_dat$Switch_pass, ymin=logRT_mean_dat$logRT-logRT_mean_dat$ci, ymax=logRT_mean_dat$logRT+logRT_mean_dat$ci), width=.2)+
  geom_line(size=2, color="red")+
  geom_ribbon(aes(ymin=lower, ymax=upper),alpha=0.5, fill="red")+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  labs(y="Log RT")+
  labs(x="Trial to rule switch")+
  scale_x_continuous(limits=c(0,30), oob=rescale_none)+
  scale_y_continuous(limits =c(6,6.5), oob=rescale_none)

logRT_figure

ggsave(filename= paste(Figure_folder, "RT.jpeg"), logRT_figure, width=5, height=5, units="cm", dpi=300)

Sync_a<-Sync_data[Sync_data$Cumulation<median(Sync_data$Cumulation),]
Sync_b<-Sync_data[Sync_data$Cumulation>=median(Sync_data$Cumulation),]

max(Sync_data$LogLik)
median(Sync_a$Cumulation)

t.test(Sync_a$LogLik, Sync_b$LogLik)
S_A_LL<-mean_ci(Sync_a$LogLik)
S_B_LL<-mean_ci(Sync_b$LogLik)

t.test(Sync_a$AIC, Sync_b$AIC)
S_A_AIC<-mean_ci(Sync_a$AIC)
S_B_AIC<-mean_ci(Sync_b$AIC)

RWLearn_a<-RW_data[Sync_data$Cumulation<median(Sync_data$Cumulation),]
RWLearn_b<-RW_data[Sync_data$Cumulation>=median(Sync_data$Cumulation),]

RW_A_LL<-mean_ci(RWLearn_a$LogLik)
RW_B_LL<-mean_ci(RWLearn_b$LogLik)

t.test(RWLearn_a$AIC, RWLearn_b$AIC)
RW_A_AIC<-mean_ci(RWLearn_a$AIC)
RW_B_AIC<-mean_ci(RWLearn_b$AIC)

t.test(Sync_data$AIC, RW_data$AIC, paired=TRUE)
t.test(Sync_a$AIC, RWLearn_a$AIC, paired=TRUE)
t.test(Sync_b$AIC, RWLearn_b$AIC, paired=TRUE)

t.test(Sync_data$LogLik, RW_data$LogLik, paired=TRUE)
t.test(Sync_a$LogLik, RWLearn_a$LogLik, paired=TRUE)
t.test(Sync_b$LogLik, RWLearn_b$LogLik, paired=TRUE)

Weight_AIC_dat_a<-Weight_AIC_dat[Sync_data$Cumulation<median(Sync_data$Cumulation),10:12]
Weight_AIC_dat_b<-Weight_AIC_dat[Sync_data$Cumulation>=median(Sync_data$Cumulation),10:12]
t.test(Weight_AIC_dat_a$RW_wAIC, Weight_AIC_dat_b$RW_wAIC)
t.test(Weight_AIC_dat_a$H_wAIC, Weight_AIC_dat_b$H_wAIC)
t.test(Weight_AIC_dat_a$S_wAIC, Weight_AIC_dat_b$S_wAIC)

Split_dataset<-rbind(-RW_A_LL, -RW_B_LL, -S_A_LL, -S_B_LL, RW_A_AIC, RW_B_AIC, S_A_AIC, S_B_AIC )
Group<-as.factor(rep(1:2, times=4))
Type<-as.factor(rep(1:2, each=4))
M<-as.factor(rep(rep(1:2,each=2),times=2))
Split_dataset<-cbind(Split_dataset, Group, Type, M)
colnames(Split_dataset)<-c("Measure", "Min", "Max", "Group", "Type", "Model")

LL_bis<-ggplot(data=Split_dataset[Split_dataset$Type==1,], aes(x=Model, y=Measure, fill=Group))+
  geom_bar(stat="identity", position=position_dodge(), color="black", alpha=0.5)+
  geom_errorbar(aes(ymin=Min, ymax=Max), width=.2, position=position_dodge(0.9))+
  labs(y="-LogLikelihood")+
  labs(x="Model")+
  scale_fill_manual(labels=c("1"= "Low Cumulation", "2" = "High Cumulation"),values=c("1"="black", "2"="grey"))+
  scale_x_discrete(labels=c("1"="RW", "2"= "Sync"))+
  scale_y_continuous(limits =c(200,210), oob=rescale_none)+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"))

LL_bis

AIC_bis<-ggplot(data=Split_dataset[Split_dataset$Type==2,], aes(x=Model, y=Measure, fill=Group))+
  geom_bar(stat="identity", position=position_dodge(), color="black", alpha=0.5)+
  geom_errorbar(aes(ymin=Min, ymax=Max), width=.2, position=position_dodge(0.9))+
  labs(y="AIC")+
  labs(x="Model")+
  scale_fill_manual(labels=c("1"= "Low Cumulation", "2" = "High Cumulation"),values=c("1"="black", "2"="grey"))+
  scale_x_discrete(labels=c("1"="RW", "2"= "Sync"))+
  scale_y_continuous(limits =c(415,425), oob=rescale_none)+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"))

AIC_bis

means_cor_a<-means_after[Sync_data$Cumulation<median(Sync_data$Cumulation),3]
means_cor_b<-means_after[Sync_data$Cumulation>=median(Sync_data$Cumulation),3]

t.test(means_cor_a, means_cor_b)

bis_figure<-ggarrange(LL_bis, AIC_bis, ncol=2, common.legend = TRUE)


All_figure<-ggarrange(bis_figure, Correlation_figure, nrow=2)
ggsave(filename= paste(Figure_folder, "Split_model.jpeg"), All_figure, width=10, height=10, units="cm", dpi=300)

ggsave(filename= paste(Figure_folder, "Groups.jpeg"), Group_plot, width=5, height =5, units ="cm", dpi=300)

#Comparative plot for RWlearn model
RW_lik_figure_bis<-ggplot()+
  geom_point(aes(x=corr_mean_dat$Switch_pass, y=corr_mean_dat$corr2))+
  geom_errorbar(aes(x=corr_mean_dat$Switch_pass, ymin=corr_mean_dat$corr2-corr_mean_dat$ci, ymax=corr_mean_dat$corr2+corr_mean_dat$ci), width=.2)+
  geom_line(aes(x=RW_lik_mean_dat_bis$Switch_pass, y=RW_lik_mean_dat_bis$RW_lik, color=RW_lik_mean_dat_bis$Group), size=2)+
  geom_ribbon(aes(x=RW_lik_mean_dat_bis$Switch_pass, ymin=RW_lik_mean_dat_bis$RW_lik-RW_lik_mean_dat_bis$ci, ymax= RW_lik_mean_dat_bis$RW_lik+RW_lik_mean_dat_bis$ci, fill=RW_lik_mean_dat_bis$Group),alpha=0.5)+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  ggtitle("RW Model")+
  labs(y="Accuracy/ L(correct) %")+
  labs(x="Trial to rule switch")+
  scale_colour_manual(values=c("red", "blue","lightgreen"),name = 'wAIC groups', labels = c('0.1','0.4','0.7'))+
  scale_fill_manual(values=c("red", "blue","lightgreen"))+
  guides(fill= FALSE, color=FALSE)+
  scale_x_continuous(limits=c(0,30), oob=rescale_none)+
  scale_y_continuous(limits =c(0,1), oob=rescale_none, labels = c("0", "25", "50", "75", "100"))

#Comparative plot for Hybrid model
H_lik_figure_bis<-ggplot()+
  geom_point(aes(x=corr_mean_dat$Switch_pass, y=corr_mean_dat$corr2))+
  geom_errorbar(aes(x=corr_mean_dat$Switch_pass, ymin=corr_mean_dat$corr2-corr_mean_dat$ci, ymax=corr_mean_dat$corr2+corr_mean_dat$ci), width=.2)+
  geom_line(aes(x=H_lik_mean_dat_bis$Switch_pass, y=H_lik_mean_dat_bis$H_lik, color=H_lik_mean_dat_bis$Group), size=2)+
  geom_ribbon(aes(x=H_lik_mean_dat_bis$Switch_pass, ymin=H_lik_mean_dat_bis$H_lik-H_lik_mean_dat_bis$ci, ymax= H_lik_mean_dat_bis$H_lik+H_lik_mean_dat_bis$ci, fill=H_lik_mean_dat_bis$Group),alpha=0.5)+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  ggtitle("ALR Model")+
  labs(y="Accuracy/ L(correct) %")+
  labs(x="Trial to rule switch")+
  scale_colour_manual(values=c("red", "blue","lightgreen"),name = 'wAIC groups', labels = c('0.1','0.4','0.7'))+
  scale_fill_manual(values=c("red", "blue","lightgreen"))+
  guides(fill= FALSE, color=FALSE)+
  scale_x_continuous(limits=c(0,30), oob=rescale_none)+
  scale_y_continuous(limits =c(0,1), oob=rescale_none, labels = c("0", "25", "50", "75", "100"))

#Comparative plot for Sync model
S_lik_figure_bis<-ggplot()+
  geom_point(aes(x=corr_mean_dat$Switch_pass, y=corr_mean_dat$corr2))+
  geom_errorbar(aes(x=corr_mean_dat$Switch_pass, ymin=corr_mean_dat$corr2-corr_mean_dat$ci, ymax=corr_mean_dat$corr2+corr_mean_dat$ci), width=.2)+
  geom_line(aes(x=S_lik_mean_dat_bis$Switch_pass, y=S_lik_mean_dat_bis$S_lik, color=S_lik_mean_dat_bis$Group), size=2)+
  geom_ribbon(aes(x=S_lik_mean_dat_bis$Switch_pass, ymin=S_lik_mean_dat_bis$S_lik-S_lik_mean_dat_bis$ci, ymax= S_lik_mean_dat_bis$S_lik+S_lik_mean_dat_bis$ci, fill=S_lik_mean_dat_bis$Group),alpha=0.5)+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  ggtitle("bSync Model")+
  labs(y="Accuracy/ L(correct) %")+
  labs(x="Trial to rule switch")+
  scale_colour_manual(values=c("red", "blue","lightgreen"),name = 'wAIC groups', labels = c('0.1','0.4','0.7'))+
  scale_fill_manual(values=c("red", "blue","lightgreen"))+
  guides(fill= FALSE, color=FALSE)+
  scale_x_continuous(limits=c(0,30), oob=rescale_none)+
  scale_y_continuous(limits =c(0,1), oob=rescale_none, labels = c("0", "25", "50", "75", "100"))

#make figure
Lik_figure_bis<-ggarrange(RW_lik_figure_bis, H_lik_figure_bis, S_lik_figure_bis, ncol=3)

Lik_figure_bis
ggsave(filename= paste(Figure_folder, "Split_fit_figure.jpeg"), Lik_figure_bis, width=15, height=6, units="cm", dpi=300)

Total_figure_bis<-ggdraw() +
  draw_plot(RW_lik_figure_bis, x = 0, y = .41, width = .33, height = .25) +
  draw_plot(H_lik_figure_bis, x = .33, y = .41, width = .33, height = .25) +
  draw_plot(S_lik_figure_bis, x = .66, y = .41, width = .33, height = .25) +
  draw_plot(RW_param_figure, x = 0, y = .66, width = .33, height = .33) +
  draw_plot(H_param_figure, x = .33, y = .66, width = .33, height = .33) +
  draw_plot(S_param_figure, x = .66, y = .66, width = .33, height = .33) +
  draw_grob(tableGrob(tabletot, theme=ttheme_minimal(base_size = 8,base_family = "Times"), rows = NULL), x=0, y=0.04, width=0.6, height=0.33)+
  #draw_plot(LL_fig, x = 0, y = .075, width = .25, height = .25) +
  #draw_plot(wAIC_fig, x = .25, y = .075, width = .25, height = .25) +
  draw_plot(Correlation_figure, x = 0.6, y = 0, width = .4, height = .41) +
  draw_plot_label(label = c("A","B","C","D"), x=c(0,0,0,0.57),y=c(1,0.66,0.38,0.41), size = 12,fontface="bold", family="Times")

Total_figure

ggsave(filename= paste(Figure_folder, "Model_comparison.tiff"), Total_figure, width=17.5, height=19, units="cm", dpi=300)


#Comparative plot for RWlearn model
RW_lik_figure_bis<-ggplot()+
  geom_point(aes(x=corr_mean_dat$Switch_pass, y=corr_mean_dat$corr2))+
  geom_errorbar(aes(x=corr_mean_dat$Switch_pass, ymin=corr_mean_dat$corr2-corr_mean_dat$ci, ymax=corr_mean_dat$corr2+corr_mean_dat$ci), width=.2)+
  geom_line(aes(x=RW_lik_mean_dat_bis$Switch_pass, y=RW_lik_mean_dat_bis$RW_lik, color=RW_lik_mean_dat_bis$Group), size=2)+
  geom_ribbon(aes(x=RW_lik_mean_dat_bis$Switch_pass, ymin=RW_lik_mean_dat_bis$RW_lik-RW_lik_mean_dat_bis$ci, ymax= RW_lik_mean_dat_bis$RW_lik+RW_lik_mean_dat_bis$ci, fill=RW_lik_mean_dat_bis$Group),alpha=0.5)+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  ggtitle("RW Model")+
  labs(y="Accuracy/ L(correct) %")+
  labs(x="Trial to rule switch")+
  scale_colour_manual(values=c("red", "blue","lightgreen"),name = 'wAIC groups', labels = c('0.1','0.4','0.7'))+
  scale_fill_manual(values=c("red", "blue","lightgreen"))+
  guides(fill= FALSE, color=FALSE)+
  scale_x_continuous(limits=c(0,30), oob=rescale_none)+
  scale_y_continuous(limits =c(0,1), oob=rescale_none, labels = c("0", "25", "50", "75", "100"))

#Comparative plot for Hybrid model
H_lik_figure_bis<-ggplot()+
  geom_point(aes(x=corr_mean_dat$Switch_pass, y=corr_mean_dat$corr2))+
  geom_errorbar(aes(x=corr_mean_dat$Switch_pass, ymin=corr_mean_dat$corr2-corr_mean_dat$ci, ymax=corr_mean_dat$corr2+corr_mean_dat$ci), width=.2)+
  geom_line(aes(x=H_lik_mean_dat_bis$Switch_pass, y=H_lik_mean_dat_bis$H_lik, color=H_lik_mean_dat_bis$Group), size=2)+
  geom_ribbon(aes(x=H_lik_mean_dat_bis$Switch_pass, ymin=H_lik_mean_dat_bis$H_lik-H_lik_mean_dat_bis$ci, ymax= H_lik_mean_dat_bis$H_lik+H_lik_mean_dat_bis$ci, fill=H_lik_mean_dat_bis$Group),alpha=0.5)+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  ggtitle("ALR Model")+
  labs(y="Accuracy/ L(correct) %")+
  labs(x="Trial to rule switch")+
  scale_colour_manual(values=c("red", "blue","lightgreen"),name = 'wAIC groups', labels = c('0.1','0.4','0.7'))+
  scale_fill_manual(values=c("red", "blue","lightgreen"))+
  guides(fill= FALSE, color=FALSE)+
  scale_x_continuous(limits=c(0,30), oob=rescale_none)+
  scale_y_continuous(limits =c(0,1), oob=rescale_none, labels = c("0", "25", "50", "75", "100"))

#Comparative plot for Sync model
S_lik_figure_bis<-ggplot()+
  geom_point(aes(x=corr_mean_dat$Switch_pass, y=corr_mean_dat$corr2))+
  geom_errorbar(aes(x=corr_mean_dat$Switch_pass, ymin=corr_mean_dat$corr2-corr_mean_dat$ci, ymax=corr_mean_dat$corr2+corr_mean_dat$ci), width=.2)+
  geom_line(aes(x=S_lik_mean_dat_bis$Switch_pass, y=S_lik_mean_dat_bis$S_lik, color=S_lik_mean_dat_bis$Group), size=2)+
  geom_ribbon(aes(x=S_lik_mean_dat_bis$Switch_pass, ymin=S_lik_mean_dat_bis$S_lik-S_lik_mean_dat_bis$ci, ymax= S_lik_mean_dat_bis$S_lik+S_lik_mean_dat_bis$ci, fill=S_lik_mean_dat_bis$Group),alpha=0.5)+
  theme_classic()+
  theme(text = element_text(size=8, family="Times"), plot.title = element_text(size = 8, face = "bold", hjust=0.5, family="Times"))+
  ggtitle("bSync Model")+
  labs(y="Accuracy/ L(correct) %")+
  labs(x="Trial to rule switch")+
  scale_colour_manual(values=c("red", "blue","lightgreen"),name = 'wAIC groups', labels = c('0.1','0.4','0.7'))+
  scale_fill_manual(values=c("red", "blue","lightgreen"))+
  guides(fill= FALSE, color=FALSE)+
  scale_x_continuous(limits=c(0,30), oob=rescale_none)+
  scale_y_continuous(limits =c(0,1), oob=rescale_none, labels = c("0", "25", "50", "75", "100"))

#make figure
Lik_figure_bis<-ggarrange(RW_lik_figure_bis, H_lik_figure_bis, S_lik_figure_bis, ncol=3)

Lik_figure_bis
ggsave(filename= paste(Figure_folder, "Split_fit_figure.jpeg"), Lik_figure_bis, width=15, height=6, units="cm", dpi=300)

#Total figure
Total_figure_bis<-ggdraw() +
  draw_plot(RW_lik_figure_bis, x = 0, y = 0, width = .33, height = .25) +
  draw_plot(H_lik_figure_bis, x = .33, y = 0, width = .33, height = .25) +
  draw_plot(S_lik_figure_bis, x = .66, y = 0, width = .33, height = .25) +
  draw_plot(RW_param_figure, x = 0, y = .66, width = .33, height = .33) +
  draw_plot(H_param_figure, x = .33, y = .66, width = .33, height = .33) +
  draw_plot(S_param_figure, x = .66, y = .66, width = .33, height = .33) +
  #draw_grob(tableGrob(tabletot, theme=ttheme_minimal(base_size = 8,base_family = "Times"), rows = NULL), x=0, y=0.04, width=0.6, height=0.33)+
  draw_plot(Group_plot, x = 0, y = .3, width = .25, height = .33) +
  draw_plot(Correlation_figure, x = 0.3, y = 0.25, width = .7, height = .41) +
  draw_plot_label(label = c("A","B","C","D"), x=c(0,0,0.275,0),y=c(1,0.66,0.66,0.25), size = 12,fontface="bold", family="Times")

Total_figure_bis

ggsave(filename= paste(Figure_folder, "Model_comparison_bis.tiff"), Total_figure_bis, width=17.5, height=19, units="cm", dpi=300)




