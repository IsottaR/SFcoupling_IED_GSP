%% VISUALIZE THE RESULTS

lateralization={'Rtle','Ltle'};

%load ROI patch
load(fullfile(datapath,'ROIpatch.mat'))

for lat=1: length(lateralization)
        clear surr_thresh

        %select the correct threshold, according to the sample size of the
    %group
    if lat==1
        threshold=6;%retain ROI significant in at leasts 7/9 patients (75%)
        % threshold=2;%retain ROI significant in at leats 3/9 patients
    elseif lat==2
        threshold=5;%retain ROI significant in at leasts 6/8 patients (75%)
        % threshold=2;%retain ROI significant in at leats 3/8 patients
    end
    
    
    eval(['surr_thresh=SDI_surr_thresh_',char(lateralization(lat))]);
    thr=find([surr_thresh.threshold]==threshold);
    
    % plot coupled and decoupled ROIs
    amplitude2plot=change_range_SDI(surr_thresh(thr).mean_SDI,-1,1,0);%convert SDI to new range (-1 1)
    rgb = vals2colormap2(reshape(amplitude2plot,1,size(amplitude2plot,1)*size(amplitude2plot,2)),flipud(brewermap(256,'RdYlBu')));
    
    %plot only the ROIs that are significant with this threshold
    rgb(find(surr_thresh(thr).SDI_sig==0),:)=repmat([221 221 221]/255,length(find(surr_thresh(thr).SDI_sig==0)),1);%show in grey the ROIs that ar enot significant
    
    %plot
    fig=plot_brain_mesh_mesial(ROI_patch,rgb,[char(lateralization(lat)),' threshold ',num2str(threshold+1)])
    
end



