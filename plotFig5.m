%% VISUALIZE THE RESULTS

lateralization={'Rtle','Ltle'};
threshold=5;%retain ROI significant in at leats 6/9 patients
% threshold=2;%retain ROI significant in at leats 3/9 patients

%load ROI patch
load(fullfile(datapath,'data\ROIpatch.mat'))

for lat=1:size(lateralization,2)
    for p=1:size(pat{1,lat},2)
        id_sub=pat{1,lat}(p);
        
        %empirical SDI during cluster C1
        SDI_all_pat_c1{lat}(:,p)=log(data_GSP2(id_sub).step2.SDIc1);
        
        %empirical SDI during cluster C2
        SDI_all_pat_c2{lat}(:,p)=log(data_GSP2(id_sub).step2.SDIc2);
    end
    
    %mask of significant ROI (from comparison with surrogates)
    eval(['surr_thresh=SDI_surr_thresh_',char(lateralization(lat))]);

    %variable to test
    val=SDI_all_pat_c2{lat} -SDI_all_pat_c1{lat};

    %select the correct threshold, according to the sample size of the
    %group
    if lat==1
        threshold=6;%retain ROI significant in at leasts 7/9 patients (75%)
        % threshold=2;%retain ROI significant in at leats 3/9 patients
    elseif lat==2
        threshold=5;%retain ROI significant in at leasts 6/8 patients (75%)
        % threshold=2;%retain ROI significant in at leats 3/8 patients
    end
    
    thr=find([surr_thresh.threshold]==threshold);
    
    pval=ones(size(SDI_all_pat_c1{lat},1),1);

    for r=1:size(SDI_all_pat_c1{lat},1)
        %test only the regions that were significant
        if surr_thresh(thr).SDI_sig(r)==1 %the region is decoupled
        pval(r)= signrank(val(r,:),0,'Tail','right'); %test that SDI increased
        
        elseif surr_thresh(thr).SDI_sig(r)==-1 %the region is coupled
            pval(r)= signrank(val(r,:),0,'Tail','left'); %test that SDI decreased
        else
        end
    end

    
    nROItested=length(find(surr_thresh(thr).SDI_sig~=0));
    idx_sig_ROI=find(pval<0.05/nROItested);

    %% plot the boxplot of each significant brain region

    for roi_idx=1:length(idx_sig_ROI)
        r=idx_sig_ROI(roi_idx);
        clearvars val_C1 val_C2
        
        val_C1=SDI_all_pat_c1{lat}(r,:);
        val_C2=SDI_all_pat_c2{lat}(r,:);
        
        fig=figure('Name',char(lateralization(lat))); boxplot([val_C1 ;val_C2]','Labels',{'C1(segregation)','C2(integration)'})
        title([char(data_GSP2(1).step2.roiLabel(r)),' p = ',num2str(pval(r))]); box off
        
        for subj=1:length(val_C1)
            
            pos_x1=1+(rand(1)-0.5)/10; %randomize position along x-axis
            pos_x2=2+(rand(1)-0.5)/10; %randomize position along x-axis
            
            hold on;scatter(pos_x1,val_C1(subj),25,'MarkerEdgeColor',[201 198 187]/255,'MarkerFaceColor',[201 198 187]/255,'LineWidth',1.5);
            hold on;scatter(pos_x2,val_C2(subj),25,'MarkerEdgeColor',[201 198 187]/255,'MarkerFaceColor',[201 198 187]/255,'LineWidth',1.5);
            hold on;plot([pos_x1 pos_x2],[val_C1(subj) val_C2(subj)],'Color',[201 198 187]/255);
        end
    end
end
