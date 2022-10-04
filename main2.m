%Script 2/2, to do the analyses described in the following paragraphs:

% - 2.6.3 --> calculate SDI and threshold it vs surrogates --> Fig 4
% - 2.6.4 --. Fig 5

%% STEP 2 - SDI vs surrogates, SDI in clusters

clear; clc; close all
restoredefaultpath
addpath('functions')

load('data\results\data_GSP1')
load('data\results\clust_permutest')
load('data\results\struct_data')

%new structure for the results
data_GSP2=rmfield(data_GSP1,'step1');

%% ------- the following lines do the folowing: -------------
% - calculate a randomized matrix of 1 and -1 (PHI) to generate surrogates
%   for SDI analyses
% - load the PHI matrix used for the analyses in the paper

%load matrix to randomize GFT traces
% for n=1:1000
%     clearvars PHIdiag
%     %randomize sign of Fourier coefficients
%     PHIdiag=round(rand(118,1));
%     PHIdiag(PHIdiag==0)=-1;
%     PHI(n,:,:)=diag(PHIdiag);
% end
load('data\PHI')

%% PARAGRAPH 2.6.3

% -------------------------- EMPIRICAL SDI --------------------------------
for p=1:size(data_GSP1,2)
    
    %data of the current subject
    data_sub=data_GSP1(p).step1;
    
    %------------ get SDI on 400 ms epoch ----------------------
    [~,~,N_c,N_d,~]=filter_signal_with_harmonics(struct_data.U,data_sub.zX_RS,data_sub.Vlow,data_sub.Vhigh);
    
    %average coupling and decoupling across epochs and then get SDI
    GSP_SDI.SDI=mean(N_d,2)./mean(N_c,2); 
    
    %------------ SDI on clusters ------------------------------
    for clust=1:size(clust_permutest.clusters,2)
        clear N_c N_d
        % filter the EEG signal and get emipirical individual SDI
        [~,~,N_c,N_d,~]=filter_signal_with_harmonics(struct_data.U,data_sub.zX_RS(:,clust_permutest.clusters{1,clust},:),data_sub.Vlow,data_sub.Vhigh);
        
        %average coupling and decoupling across epochs and then get SDI
        eval(['GSP_SDI.SDIc',num2str(clust),'=mean(N_d,2)./mean(N_c,2);']); 
    end
    
    GSP_SDI.roiLabel=data_GSP1(p).step1.roiLabel
    data_GSP2(p).step2=GSP_SDI;
    clear GSP_SDI
end
save('data\results\data_GSP2','data_GSP2')

% -------------------------- SURROGATE SDI -------------------------------- 
%this script takes very long. Load surrogates already computed instead

% surrogateSDI              
load('data\results\data_GSP2_surr')

% --------------------------------STATS -----------------------------------
%(threshold SDI comparing it with the surrogates SDI)

pat{1,1}=find(strcmp({data_GSP2_surr.lat},'Rtle'));
pat{1,2}=find(strcmp({data_GSP2_surr.lat},'Ltle'));
labels={'Rtle','Ltle'};

for lat=1: size(pat,2)

    for p=1:length(pat{1,lat})
         idx=pat{1,lat}(p);

        % load SDI from surrogates and convert to log(SDI)
        SDI_surr(:,:,p)=log(data_GSP2_surr(idx).step2.SDIsurr(:,1:19));
        
        % load empirical SDI and convert to log(SDI)
        SDI_all_pat(:,p)=log(data_GSP2(idx).step2.SDI);
    end
    
    %------------ Find significant SDI
    mean_SDI=mean(SDI_all_pat,2); %empirical AVERAGE SDI
    
    %find threshold for max
    for s=1:size(SDI_surr,3)
        max_SDI_surr(:,s)=max(SDI_surr(:,:,s)')';
    end
    
    %find threshold for min
    for s=1:size(SDI_surr,3)
        min_SDI_surr(:,s)=min(SDI_surr(:,:,s)')';
    end
    
    %------------ select significant SDI for each subject, across surrogates
    %individual thr, first screening
    for s=1:size(SDI_all_pat,2) %for each subject, I threshold the ratio based on individual ratio's surrogate distribution
        SDI_thr_max(:,s)=SDI_all_pat(:,s)>max_SDI_surr(:,s);
        SDI_thr_min(:,s)=SDI_all_pat(:,s)<min_SDI_surr(:,s);
        detect_max=sum(SDI_thr_max'); %amounts of detection per region
        detect_min=sum(SDI_thr_min');
    end
    
    %%for every region, test across subjects 0.05, correcting for the number of
    %%tests (regions), 0.05/118
    x=0:1:100;
    y=binocdf(x,100,0.05,'upper');
    
    THRsubjects=x(min(find(y<0.05/size(mean_SDI,1))));
    THRsubjects=floor(size(SDI_all_pat,2)/100*THRsubjects)+1;

    cnt=1;
    for thr=THRsubjects:size(pat{1,lat},2)
        
        SDI_sig_higher=detect_max>thr;
        SDI_sig_lower=detect_min>thr;
        
        %create mask for further stats between clusters (script C4)
        SDI_sig=zeros(size(mean_SDI,1),1);
        SDI_sig(find(SDI_sig_higher==1))=1;
        SDI_sig(find(SDI_sig_lower==1))=-1;
        
        %store stats results for later plot
        surr_thresh(cnt).threshold=thr;
        surr_thresh(cnt).mean_SDI=mean_SDI;
        surr_thresh(cnt).SDI_sig=SDI_sig;

        cnt=cnt+1;
    end
    save(['data\results\SDI_surr_thresh_',char(labels(lat))],'surr_thresh')
end

clear SDI_all_pat SDI SDI_sig_higher SDI_sig_lower SDI_sig SDI_thr_max SDI_thr_min

%% visualize results
plotFig4

%% PARAGRAPH 2.6.4
plotFig5



