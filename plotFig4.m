%% VISUALIZE THE RESULTS

lateralization={'Rtle','Ltle'};
threshold=5;%retain ROI significant in at leats 6/9 patients
% threshold=2;%retain ROI significant in at leats 3/9 patients

%load ROI patch
load(fullfile('data\ROIpatch.mat'))

for lat=1: length(lateralization)
    
    load(['data\results\SDI_surr_thresh_',char(lateralization(lat))])
    thr=find([surr_thresh.threshold]==threshold);
    
    % plot coupled and decoupled ROIs
    amplitude2plot=change_range_SDI(surr_thresh(thr).mean_SDI,-1,1,0);%convert SDI to new range (-1 1)
    rgb = vals2colormap2(reshape(amplitude2plot,1,size(amplitude2plot,1)*size(amplitude2plot,2)),flipud(brewermap(256,'RdYlBu')));
    
    %plot only the ROIs that are significant with this threshold
    rgb(find(surr_thresh(thr).SDI_sig==0),:)=repmat([221 221 221]/255,length(find(surr_thresh(thr).SDI_sig==0)),1);%show in grey the ROIs that ar enot significant
    
    %plot
    fig=plot_brain_mesh_mesial(ROI_patch,rgb,[char(lateralization(lat)),' threshold ',num2str(threshold+1)])
    
end



