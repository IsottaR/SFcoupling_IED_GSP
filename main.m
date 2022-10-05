%% ------------------------------------------------------------------------
%                             START FIRST PART
%              GSP, integration/segregation, compactness, BD
% -------------------------------------------------------------------------

%Script 1/2, to do the analyses described in the following paragraphs:

% - 2.5 
% - 2.6.1 --> Fig 3; Fig S2
% - 2.6.2 --> Fig S3

clear; clc;close all

addpath('functions')

%initialise variables
time_w=[.3 .7]; %time window for analyses, in sec

%get path where data are (store them in folder above SFcoupling_IED_GSP)
[datapath,name,ext] = fileparts(pwd);

%load data
load(fullfile(datapath,'data\func_data'))
load(fullfile(datapath,'data\struct_data'))

% decompose SC
[U,LambdaL] = laplacian_decomposition(struct_data.SC  );
struct_data.U=U;
struct_data.eigenvalues=LambdaL;

%new structure for the results
data_GSP1=rmfield(func_data,'ROI_traces');

%% PARAGRAPH 2.5
for p=1:size(func_data,2)
    clearvars -except data_GSP1 c_avg_timeseries_norm d_avg_timeseries_norm func_data p time_w struct_data datapath
    data_sub=func_data(p).ROI_traces;

    %------- define cut-off frequency for each subject on the 400 ms around the IED
    for ep=1:size(data_sub.trial,2)
        X_RS(:,:,ep)=data_sub.trial{1,ep}(:,time_w(1)*data_sub.fsample:time_w(2)*data_sub.fsample-1);
    end
    
    zX_RS=zscore(X_RS,0,2);%z-score over time
    
    [PSD,NN,Vlow, Vhigh]=get_cut_off_freq(struct_data.U,zX_RS); %split harmonics in high and low frequency and get PSD

    %------- get the part of the signal that is COUPLED and DECOUPLED from the structure
    [X_c,X_d,~,~,~]=filter_signal_with_harmonics(struct_data.U,zX_RS,Vlow,Vhigh);
    
    %------- normalise X_c and X_d and get Broadcasting Direction
    [BD,X_c_norm,X_d_norm] = getBD(zX_RS,X_c,X_d);
    
    %------- store info for future analyses
    GSP.zX_RS=zX_RS;
    GSP.cut_off_freq=NN; %cut-off freq
    GSP.Vlow=Vlow; %LF harmonics
    GSP.Vhigh=Vhigh; %HF hamronics
    GSP.X_c=X_c; %signal coupled to the struct
    GSP.X_d=X_d; %signal decoupled from the struct
    GSP.BD=BD; %broadcasting direction
    GSP.X_c_norm=X_c_norm; %signal coupled to the structure, normalised
    GSP.X_d_norm=X_d_norm; %signal decoupled from the structure, normalised
    GSP.roiLabel=func_data(p).ROI_traces.label;
    
    data_GSP1(p).step1=GSP;
    
    %average across trials for final stats and plot
    c_avg_timeseries_norm(p,:)=mean(X_c_norm,2);
    d_avg_timeseries_norm(p,:)=mean(X_d_norm,2);
end

%% PARAGRAPH 2.6.1
plotFig3 %do cluster-based permutation test and plot figure 3
plotFigS2  % compactness on clusters

%% PARAGRAPH 2.6.2
plotFigS3 %do broadcasting direction (BD) nalyses and plot results

%% ------------------------------------------------------------------------
%                             END FIRST PART
% -------------------------------------------------------------------------



%% ------------------------------------------------------------------------
%                           START SECOND PART
%                    SDI vs surrogates, SDI in clusters
% ------------------------------------------------------------------------

%Script 2/2, to do the analyses described in the following paragraphs:

% - 2.6.3 --> calculate SDI and threshold it vs surrogates --> Fig 4
% - 2.6.4 --. Fig 5

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
load(fullfile(datapath,'data\PHI'))

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

% -------------------------- SURROGATE SDI -------------------------------- 
%this script takes very long. Load surrogates already computed instead

% surrogateSDI              
load(fullfile(datapath,'data\results\data_GSP2_surr'))

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
    eval(['SDI_surr_thresh_',char(labels(lat)),'=surr_thresh;']);
end

clear SDI_all_pat SDI SDI_sig_higher SDI_sig_lower SDI_sig SDI_thr_max SDI_thr_min

%% visualize results
plotFig4

%% PARAGRAPH 2.6.4
plotFig5



