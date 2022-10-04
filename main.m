%Script 1/2, to do the analyses described in the following paragraphs:

% - 2.5 
% - 2.6.1 --> Fig 3; Fig S2
% - 2.6.2 --> Fig S3

%% STEP 1 -GSP, integration/segregation, compactness, BD


clear; clc;close all

addpath('functions')

%initialise variables
time_w=[.3 .7]; %time window for analyses, in sec

%load data
load ('data\func_data')
load ('data\struct_data')

% decompose SC
[U,LambdaL] = laplacian_decomposition(struct_data.SC  );
struct_data.U=U;
struct_data.eigenvalues=LambdaL;

save('data\results\struct_data')
%new structure for the results
data_GSP1=rmfield(func_data,'ROI_traces');

%% PARAGRAPH 2.5
for p=1:size(func_data,2)
    clearvars -except data_GSP1 c_avg_timeseries_norm d_avg_timeseries_norm func_data p time_w struct_data
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

%save step1 results
save('data\results\data_GSP1','data_GSP1')
save('data\results\clust_permutest','clust_permutest')