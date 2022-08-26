%Define folders and variables
fprintf('************************************ \n Preparing variables! \n ******************************')
Behavioral_folder   = '/Volumes/Harde ploate/EEG_reversal_learning/Behavioral_data/Indices/';
Power_folder        = '/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/Power_data/';
home_folder         = '/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/';
figfolder           = '/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/Figures/Locking/';

%get channels
load([home_folder 'chanloc'])
chanlocations=chanlocations(1:64);

fronto_posterior_axis=[chanlocations(:).X];
[channels_sorted, indices_sorted]=sort(fronto_posterior_axis,'descend');

frontal_channels=indices_sorted(channels_sorted>0);
posterior_channels=indices_sorted(channels_sorted<0);

%get behavioral indices
load([Behavioral_folder 'Locking_data'])

%other variables
subject_list    = {'pp3', 'pp5', 'pp6', 'pp7', 'pp9', 'pp10', 'pp12', 'pp14', 'pp15', 'pp16', 'pp18', 'pp19', 'pp20', 'pp21', 'pp22', 'pp23', 'pp24', 'pp25','pp26','pp27','pp28','pp29','pp30','pp31','pp32','pp33','pp34'};
num_subjects    = length(subject_list);
num_trials= 480;

frex=logspace(log10(2), log10(48), 25);  
lock_trials     = size(locking_values,2);
lt_trials       = size(lt_values,2);

lock_id=(locking_values>0)+(locking_values<481)==2;
lt_id=(lt_values>0)+(lt_values<481)==2;

%% locking power based on real and subjective rule switch
fprintf('************************************ \n Power locking \n ******************************')
Real_switch_theta_power=NaN(num_subjects,lock_trials);
Subjective_switch_theta_power=NaN(num_subjects,lt_trials);

Real_switch_delta_power=NaN(num_subjects,lock_trials);
Subjective_switch_delta_power=NaN(num_subjects,lt_trials);

Real_switch_alpha_power=NaN(num_subjects,lock_trials);
Subjective_switch_alpha_power=NaN(num_subjects,lt_trials);

%check which trials are not in the relevant time-window, these can function
%as baseline
Remaining=zeros(num_subjects,num_trials);
for s=1:num_subjects
    for t=1:num_trials
        Remaining(s,t)=Remaining(s,t)+ sum((locking_values(s,:)==t)) + sum((lt_values(s,:)==t));
    end;
end;

Remaining=Remaining==0;

load([Power_folder 'cluster_power']);
Remaining_theta_power=NaN(num_subjects, num_trials);
Remaining_alpha_power=NaN(num_subjects, num_trials);
Remaining_delta_power=NaN(num_subjects, num_trials);

%extract locked power for each cluster and each subject
for s= 1:num_subjects
    
    Real_switch_theta_power(s,lock_id(s,:))=theta_cluster_power(s,locking_values(s,lock_id(s,:)));
    Subjective_switch_theta_power(s,lt_id(s,:))=theta_cluster_power(s,lt_values(s,lt_id(s,:)));
    Remaining_theta_power(s, Remaining(s,:))=theta_cluster_power(s, Remaining(s,:));
    
    Real_switch_delta_power(s,lock_id(s,:))=delta_cluster_power(s,locking_values(s,lock_id(s,:)));
    Subjective_switch_delta_power(s,lt_id(s,:))=delta_cluster_power(s,lt_values(s,lt_id(s,:)));
    Remaining_delta_power(s, Remaining(s,:))=delta_cluster_power(s, Remaining(s,:));
    
    Real_switch_alpha_power(s,lock_id(s,:))=alpha_cluster_power(s,locking_values(s,lock_id(s,:)));
    Subjective_switch_alpha_power(s,lt_id(s,:))=alpha_cluster_power(s,lt_values(s,lt_id(s,:)));
    Remaining_alpha_power(s, Remaining(s,:))=alpha_cluster_power(s, Remaining(s,:));
    
end;

save([Power_folder 'Locked_power'], 'Remaining_theta_power','Remaining_delta_power','Remaining_alpha_power','Real_switch_theta_power', 'Subjective_switch_theta_power',  'Real_switch_delta_power', 'Subjective_switch_delta_power', 'Real_switch_alpha_power', 'Subjective_switch_alpha_power' );

%Compute averages and confidence intervals as well as baseline
Real_switch_theta=reshape(Real_switch_theta_power,num_subjects,31,15);
subject_average_theta=squeeze(nanmean(Real_switch_theta,3));
total_average_theta=squeeze(nanmean(subject_average_theta,1));
total_CI_theta=2.95*nanstd(subject_average_theta)./sqrt(num_subjects); %2.95 std equals a tail of 0.0016 % which is equal to 0.05/31 (Bonferonni correction)
Theta_baseline=nanmean(nanmean(Remaining_theta_power,2),1);

Subjective_switch_theta=reshape(Subjective_switch_theta_power,num_subjects,31,8);
Subject_ive_average_theta=squeeze(nanmean(Subjective_switch_theta,3));
total_Sub_average_theta=squeeze(nanmean(Subject_ive_average_theta,1));
Sub_CI_theta=2.95*nanstd(Subject_ive_average_theta)./sqrt(num_subjects);

Real_switch_delta=reshape(Real_switch_delta_power,num_subjects,31,15);
subject_average_delta=squeeze(nanmean(Real_switch_delta,3));
total_average_delta=squeeze(nanmean(subject_average_delta,1));
total_CI_delta=2.95*nanstd(subject_average_delta)./sqrt(num_subjects);
Delta_baseline=nanmean(nanmean(Remaining_delta_power,2),1);

Subjective_switch_delta=reshape(Subjective_switch_delta_power,num_subjects,31,8);
Subject_ive_average_delta=squeeze(nanmean(Subjective_switch_delta,3));
total_Sub_average_delta=squeeze(nanmean(Subject_ive_average_delta,1));
Sub_CI_delta=2.95*nanstd(Subject_ive_average_delta)./sqrt(num_subjects);

Real_switch_alpha=reshape(Real_switch_alpha_power,num_subjects,31,15);
subject_average_alpha=squeeze(nanmean(Real_switch_alpha,3));
total_average_alpha=squeeze(nanmean(subject_average_alpha,1));
total_CI_alpha=2*nanstd(subject_average_alpha)./sqrt(num_subjects);
Alpha_baseline=nanmean(nanmean(Remaining_alpha_power,2),1);

Subjective_switch_alpha=reshape(Subjective_switch_alpha_power,num_subjects,31,8);
Subject_ive_average_alpha=squeeze(nanmean(Subjective_switch_alpha,3));
total_Sub_average_alpha=squeeze(nanmean(Subject_ive_average_alpha,1));
Sub_CI_alpha=2*nanstd(Subject_ive_average_alpha)./sqrt(num_subjects);

%make plots
trials_to_plot=-15:15;

figure(4)
clf;
subplot(2,3,1)
errorbar(trials_to_plot, total_average_theta',total_CI_theta,'color', 'k', 'LineWidth', 2);
hold on
line([0,0],[Theta_baseline-1.5*max(total_CI_theta), Theta_baseline+3*max(total_CI_theta)], 'Color', 'b', 'LineStyle',':', 'LineWidth', 2)
plot(trials_to_plot, ones(1,length(trials_to_plot))*Theta_baseline,'r:', 'LineWidth',2)
significant_top=(total_average_theta-total_CI_theta>Theta_baseline);
plot(trials_to_plot, ((significant_top-(max(total_CI_theta)))*2*Theta_baseline)*-3, 'LineWidth',1.5, 'Linestyle', 'none', 'Marker', '*', 'MarkerSize',6, 'markerEdgeColor','r')
significant_low=(total_average_theta+total_CI_theta<Theta_baseline);
plot(trials_to_plot, ((significant_low-(max(total_CI_theta)))*2*Theta_baseline)*-3, 'LineWidth',1.5, 'Linestyle', 'none', 'Marker', '*', 'MarkerSize',6, 'markerEdgeColor','g')
box off
ylim([Theta_baseline-1.5*max(total_CI_theta), Theta_baseline+3*max(total_CI_theta)])
xlim([-15,15])
xlabel('Trials with respect to actual switch')
ylabel('power (dB)')
title('Theta cluster')

subplot(2,3,2)
errorbar(trials_to_plot, total_average_delta',total_CI_delta,'color', 'k', 'LineWidth', 2);
hold on
line([0,0],[min(total_average_delta-total_CI_delta)-0.2, max(total_average_delta+total_CI_delta)+0.2], 'Color', 'b', 'LineStyle',':', 'LineWidth', 2)
plot(trials_to_plot, ones(1,length(trials_to_plot))*Delta_baseline,'r:', 'LineWidth',2)
significant_top=(total_average_theta-total_CI_theta>Delta_baseline);
plot(trials_to_plot, (significant_top)*max(total_average_delta+total_CI_delta)+0.1, 'LineWidth',1.5, 'Linestyle', 'none', 'Marker', '*', 'MarkerSize',6, 'markerEdgeColor','r')
significant_low=(total_average_delta+total_CI_delta<Delta_baseline);
plot(trials_to_plot, (significant_low)*max(total_average_delta+total_CI_delta)+0.1, 'LineWidth',1.5, 'Linestyle', 'none', 'Marker', '*', 'MarkerSize',6, 'markerEdgeColor','g')
box off
ylim([min(total_average_delta-total_CI_delta)-0.2, max(total_average_delta+total_CI_delta)+0.2])
xlim([-15,15])
xlabel('Trials with respect to actual switch')
title('Delta cluster')

subplot(2,3,3)
errorbar(trials_to_plot, total_average_alpha',total_CI_alpha,'color', 'k', 'LineWidth', 2);
hold on
line([0,0],[min(total_average_alpha-total_CI_alpha)-0.2, max(total_average_alpha+total_CI_alpha)+0.2], 'Color', 'b', 'LineStyle',':', 'LineWidth', 2)
plot(trials_to_plot, ones(1,length(trials_to_plot))*Alpha_baseline,'r:', 'LineWidth',2)
significant_top=(total_average_alpha-total_CI_theta>Alpha_baseline);
plot(trials_to_plot, (significant_top)*max(total_average_delta+total_CI_alpha)+0.1, 'LineWidth',1.5, 'Linestyle', 'none', 'Marker', '*', 'MarkerSize',6, 'markerEdgeColor','r')
significant_low=(total_average_alpha+total_CI_delta<Alpha_baseline);
plot(trials_to_plot, (significant_low)*max(total_average_alpha+total_CI_alpha)+0.1, 'LineWidth',1.5, 'Linestyle', 'none', 'Marker', '*', 'MarkerSize',6, 'markerEdgeColor','g')
box off
ylim([min(total_average_alpha-total_CI_alpha)-0.2, max(total_average_alpha+total_CI_alpha)+0.2])
xlim([-15,15])
xlabel('Trials with respect to actual switch')
title('Alpha cluster')

subplot(2,3,4)
errorbar(trials_to_plot, total_Sub_average_theta',Sub_CI_theta,'color', 'k', 'LineWidth', 2);
hold on
line([0,0],[Theta_baseline-1.5*max(Sub_CI_theta), Theta_baseline+3*max(Sub_CI_theta)], 'Color', 'b', 'LineStyle',':', 'LineWidth', 2)
plot(trials_to_plot, ones(1,length(trials_to_plot))*Theta_baseline,'r:', 'LineWidth',2)
significant_top=(total_Sub_average_theta-Sub_CI_theta>Theta_baseline);
plot(trials_to_plot, ((significant_top-(max(Sub_CI_theta)))*2*Theta_baseline)*0.6, 'LineWidth',1.5, 'Linestyle', 'none', 'Marker', '*', 'MarkerSize',6, 'markerEdgeColor','r')
significant_low=(total_Sub_average_theta+Sub_CI_theta<Theta_baseline);
plot(trials_to_plot, ((significant_low-(max(Sub_CI_theta)))*2*Theta_baseline)*0.6, 'LineWidth',1.5, 'Linestyle', 'none', 'Marker', '*', 'MarkerSize',6, 'markerEdgeColor','r')
box off
ylim([Theta_baseline-1.5*max(Sub_CI_theta), Theta_baseline+3*max(Sub_CI_theta)])
xlim([-15,15])
ylabel('Power (dB)')
xlabel('Trials with respect to subjective switch')

subplot(2,3,5)
errorbar(trials_to_plot, total_Sub_average_delta',Sub_CI_delta,'color', 'k', 'LineWidth', 2);
hold on
line([0,0],[min(total_Sub_average_delta-Sub_CI_delta)-0.2, max(total_Sub_average_delta+Sub_CI_delta)+0.2], 'Color', 'b', 'LineStyle',':', 'LineWidth', 2)
plot(trials_to_plot, ones(1,length(trials_to_plot))*Delta_baseline,'r:', 'LineWidth',2)
significant_top=(total_Sub_average_delta-Sub_CI_delta>Delta_baseline);
plot(trials_to_plot, (significant_top*-1+2)*max(total_Sub_average_delta+Sub_CI_delta)+0.1, 'LineWidth',1.5,'Linestyle', 'none', 'Marker', '*', 'MarkerSize',6, 'markerEdgeColor','r')
significant_low=(total_Sub_average_delta+Sub_CI_delta<Delta_baseline);
plot(trials_to_plot, (significant_low*-1+2)*max(total_Sub_average_delta+Sub_CI_delta)+0.1, 'LineWidth',1.5,'Linestyle', 'none', 'Marker', '*', 'MarkerSize',6, 'markerEdgeColor','g')
box off
ylim([min(total_Sub_average_delta-Sub_CI_delta)-0.2, max(total_Sub_average_delta+Sub_CI_delta)+0.2])
xlim([-15,15])
xlabel('Trials with respect to subjective switch')

subplot(2,3,6)
errorbar(trials_to_plot, total_Sub_average_alpha',Sub_CI_alpha,'color', 'k', 'LineWidth', 2);
hold on
line([0,0],[min(total_Sub_average_alpha-Sub_CI_alpha)-0.2, max(total_Sub_average_alpha+Sub_CI_alpha)+0.2], 'Color', 'b', 'LineStyle',':', 'LineWidth', 2)
plot(trials_to_plot, ones(1,length(trials_to_plot))*Alpha_baseline,'r:', 'LineWidth',2)
significant_top=(total_Sub_average_alpha-Sub_CI_alpha>Alpha_baseline);
plot(trials_to_plot, (significant_top)*max(total_Sub_average_alpha+Sub_CI_alpha)+0.1, 'LineWidth',1.5,'Linestyle', 'none', 'Marker', '*', 'MarkerSize',6, 'markerEdgeColor','r')
significant_low=(total_Sub_average_alpha+Sub_CI_alpha<Alpha_baseline);
plot(trials_to_plot, (significant_low)*max(total_Sub_average_alpha+Sub_CI_alpha)+0.1, 'LineWidth',1.5,'Linestyle', 'none', 'Marker', '*', 'MarkerSize',6, 'markerEdgeColor','g')
box off
ylim([min(total_Sub_average_alpha-Sub_CI_alpha)-0.2, max(total_Sub_average_alpha+Sub_CI_alpha)+0.2])
xlim([-15,15])
xlabel('Trials with respect to subjective switch')
set(gcf,'color','w');
savefig([figfolder 'Cluster_power_locked'])

figure(5)
clf;
subplot(1,3,1)
errorbar(trials_to_plot, total_average_theta',total_CI_theta,'color', 'k', 'LineWidth', 2);
hold on
line([0,0],[min(total_average_theta-total_CI_theta)-0.2, max(total_average_theta+total_CI_theta)+0.2], 'Color', 'b', 'LineStyle','--', 'LineWidth', 2)
plot(trials_to_plot, ones(1,length(trials_to_plot))*Theta_baseline,'r:', 'LineWidth',2)
significant_top=(total_average_theta-total_CI_theta>Theta_baseline);
plot(trials_to_plot, (significant_top)*max(total_average_theta+total_CI_theta)+0.1, 'LineWidth',1.5, 'Linestyle', 'none', 'Marker', '*', 'MarkerSize',6, 'markerEdgeColor','r')
significant_low=(total_average_theta+total_CI_theta<Theta_baseline);
%plot(trials_to_plot, (significant_low)*max(total_average_theta+total_CI_theta)+0.1, 'LineWidth',1.5, 'Linestyle', 'none', 'Marker', '*', 'MarkerSize',6, 'markerEdgeColor','g')
box off
ylim([min(total_average_theta-total_CI_theta)-0.2, max(total_average_theta+total_CI_theta)+0.2])
xlim([-15,15])
xlabel('Trials with respect to rule switch')
ylabel('power (dB)')
title('Theta cluster')
set(gca, 'FontSize',10, 'Fontname', 'Times')

subplot(1,3,2)
errorbar(trials_to_plot, total_average_delta',total_CI_delta,'color', 'k', 'LineWidth', 2);
hold on
line([0,0],[min(total_average_delta-total_CI_delta)-0.2, max(total_average_delta+total_CI_delta)+0.2], 'Color', 'b', 'LineStyle','--', 'LineWidth', 2)
plot(trials_to_plot, ones(1,length(trials_to_plot))*Delta_baseline,'r:', 'LineWidth',2)
significant_top=(total_average_theta-total_CI_theta>Delta_baseline);
plot(trials_to_plot, (significant_top)*max(total_average_delta+total_CI_delta)+0.1, 'LineWidth',1.5, 'Linestyle', 'none', 'Marker', '*', 'MarkerSize',6, 'markerEdgeColor','r')
significant_low=(total_average_delta+total_CI_delta<Delta_baseline);
plot(trials_to_plot, (significant_low)*max(total_average_delta+total_CI_delta)+0.1, 'LineWidth',1.5, 'Linestyle', 'none', 'Marker', '*', 'MarkerSize',6, 'markerEdgeColor','g')
box off
ylim([min(total_average_delta-total_CI_delta)-0.2, max(total_average_delta+total_CI_delta)+0.2])
xlim([-15,15])
xlabel('Trials with respect to rule switch')
title('Delta cluster')
set(gca, 'FontSize',10, 'Fontname', 'Times')

subplot(1,3,3)
errorbar(trials_to_plot, total_average_alpha',total_CI_alpha,'color', 'k', 'LineWidth', 2);
hold on
line([0,0],[min(total_average_alpha-total_CI_alpha)-0.2, max(total_average_alpha+total_CI_alpha)+0.2], 'Color', 'b', 'LineStyle','--', 'LineWidth', 2)
plot(trials_to_plot, ones(1,length(trials_to_plot))*Alpha_baseline,'r:', 'LineWidth',2)
significant_top=(total_average_alpha-total_CI_theta>Alpha_baseline);
plot(trials_to_plot, (significant_top)*max(total_average_delta+total_CI_alpha)+0.1, 'LineWidth',1.5, 'Linestyle', 'none', 'Marker', '*', 'MarkerSize',6, 'markerEdgeColor','r')
significant_low=(total_average_alpha+total_CI_delta<Alpha_baseline);
plot(trials_to_plot, (significant_low)*max(total_average_alpha+total_CI_alpha)+0.1, 'LineWidth',1.5, 'Linestyle', 'none', 'Marker', '*', 'MarkerSize',6, 'markerEdgeColor','g')
box off
ylim([min(total_average_alpha-total_CI_alpha)-0.2, max(total_average_alpha+total_CI_alpha)+0.2])
xlim([-15,15])
xlabel('Trials with respect to rule switch')
title('Alpha cluster')
set(gca, 'FontSize',10, 'Fontname', 'Times')
set(gcf, 'color', 'w')
set(gcf, 'PaperUnits', 'centimeters', 'PaperPosition', [0,0, 21,7])
set(gca, 'FontSize',10, 'Fontname', 'Times')
savefig([figfolder 'Power_switch_lock'])
print([figfolder 'Power_switch_lock.png'],'-dpng','-r600')

figure(6)
clf;
subplot(1,2,1)
errorbar(trials_to_plot, total_average_alpha',total_CI_alpha,'color', 'k', 'LineWidth', 2);
hold on
line([0,0],[min(total_average_alpha-total_CI_alpha)-0.2, max(total_average_alpha+total_CI_alpha)+0.2], 'Color', 'b', 'LineStyle','--', 'LineWidth', 2)
plot(trials_to_plot, ones(1,length(trials_to_plot))*Alpha_baseline,'r:', 'LineWidth',2)
significant_top=(total_average_alpha-total_CI_theta>Alpha_baseline);
plot(trials_to_plot, (significant_top)*max(total_average_delta+total_CI_alpha)+0.1, 'LineWidth',1.5, 'Linestyle', 'none', 'Marker', '*', 'MarkerSize',6, 'markerEdgeColor','r')
significant_low=(total_average_alpha+total_CI_delta<Alpha_baseline);
plot(trials_to_plot, (significant_low)*max(total_average_alpha+total_CI_alpha)+0.1, 'LineWidth',1.5, 'Linestyle', 'none', 'Marker', '*', 'MarkerSize',6, 'markerEdgeColor','g')
box off
ylim([min(total_average_alpha-total_CI_alpha)-0.2, max(total_average_alpha+total_CI_alpha)+0.2])
xlim([-15,15])
xlabel('Trials with respect to actual switch')
ylabel(['Alpha cluster' newline newline 'Power (dB)'])
set(gca, 'FontSize',10, 'Fontname', 'Times')

subplot(1,2,2)
errorbar(trials_to_plot, total_Sub_average_alpha',Sub_CI_alpha,'color', 'k', 'LineWidth', 2);
hold on
line([0,0],[min(total_Sub_average_alpha-Sub_CI_alpha)-0.2, max(total_Sub_average_alpha+Sub_CI_alpha)+0.2], 'Color', 'b', 'LineStyle','--', 'LineWidth', 2)
plot(trials_to_plot, ones(1,length(trials_to_plot))*Alpha_baseline,'r:', 'LineWidth',2)
significant_top=(total_Sub_average_alpha-Sub_CI_alpha>Alpha_baseline);
plot(trials_to_plot, (significant_top)*max(total_Sub_average_alpha+Sub_CI_alpha)+0.1, 'LineWidth',1.5,'Linestyle', 'none', 'Marker', '*', 'MarkerSize',6, 'markerEdgeColor','r')
significant_low=(total_Sub_average_alpha+Sub_CI_alpha<Alpha_baseline);
plot(trials_to_plot, (significant_low)*max(total_Sub_average_alpha+Sub_CI_alpha)+0.1, 'LineWidth',1.5,'Linestyle', 'none', 'Marker', '*', 'MarkerSize',6, 'markerEdgeColor','g')
box off
ylim([min(total_Sub_average_alpha-Sub_CI_alpha)-0.2, max(total_Sub_average_alpha+Sub_CI_alpha)+0.2])
xlim([-15,15])
xlabel('Trials with respect to subjective switch')
set(gca, 'FontSize',10, 'Fontname', 'Times')
set(gcf, 'color', 'w')
set(gcf, 'PaperUnits', 'centimeters', 'PaperPosition', [0,0, 14,7])
savefig([figfolder 'Power_switch_alpha_conservative'])
print([figfolder 'Power_switch_alpha.png'],'-dpng','-r600')
