clear X_c X_d X_c_norm X_d_norm Vlow Vhigh zX_RS BD cut_off_freq X_RS xl NN PSD

%define the time vector
t=time_w(1):1/data_sub.fsample:time_w(2)-1/data_sub.fsample;

%% --------------------------- STATS --------------------------------------
%cluster based permutation test
[clusters, p_values, t_sums, permutation_distribution ]=permutest( c_avg_timeseries_norm', d_avg_timeseries_norm',...
    'true', .05, 2000, 'true' );

%keep only significant clusters
clusters=clusters(p_values<.05); 

%store stats results
clust_permutest.clusters=clusters;
clust_permutest.p_values=p_values(p_values<.05);
%% ----------------------- plot results --------------------------------
figure
plot_FH_HF_content(c_avg_timeseries_norm',d_avg_timeseries_norm',t,[0 204 255]/255,[204 0 0]/255)
hold on
for c=1:size(clusters,2)
    plot(t(clusters{1,c}(1:end)),.78*ones(1,length(clusters{1,c})),'k','LineWidth',2)
    hold on
end

%plot average IED start
xl=xline(0.4607,'--','IED onset')
xl.LabelVerticalAlignment = 'bottom';
hold on
%plot average IED midrise
xl=xline( 0.4836,'--','IED midrise')
xl.LabelVerticalAlignment = 'bottom';
hold on
%plot average IED peak
xl=xline(0.5042,'-.','IED peak')
xl.LabelVerticalAlignment = 'bottom';
hold off
ylim([.6 .8])
box off
xlabel('Time [s]')
ylabel('Power [a.u.]')


