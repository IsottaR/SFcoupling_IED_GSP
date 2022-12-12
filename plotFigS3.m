%% ------- the following lines do the folowing: -------------
% - create the degree-preserving surrogate SC (W0)
% - decompose W0 and extract the surrogate harmonics (U0)
% - load U0 already computed instead

% % create the degree-preserving surrogate SC (W0)
% for n=1:1000
%     % get surrogates SC
%     W0(n,:,:) = null_model_und_sign(num,10);
% end
%save(fullfile(datapath,'data\SC_surrogates'),'W0')
 

% %decompose W0 and extract the surrogate harmonics (U0)
% for n=1:1000
%     clear U Lambda
%     % GSP:Laplacian
%     [U,Lambda] = laplacian_decomposition(squeeze(W0(n,:,:)));
%     U0(n,:,:)=U;
%     LambdaL0(n,:)=Lambda;
% end
% save(fullfile(datapath,'data\CIAO'),'U0')

% Loading SURROGATES HARMONICS U0
load(fullfile(datapath,'data\SC_surrogates_harmonics'))

%% -------- the following lines do the following: -------------
% - calculate the surr BD (BD of the functional data decomposed on the surrogate
%   harmonics (N=1000))
% - load the ones already calculated, as the script takes too long

% BD_surr=rmfield(data_GSP1,'step1');
% 
% for p=1:size(func_data,2)
%     clear surrBD_single_subj_norm_diff
%     data_sub=data_GSP1(p).step1;
% 
%     %get the BD of the empirical functional data on the surrogates SC
%     for w=1:size(U0,1)
%         [surrBD_single_subj_norm_diff(w,:)]=get_surrogate_BD(squeeze(U0(w,:,:)),data_sub.zX_RS);
%     end
%     
%     %store 
%     BD_surr(p).BD=surrBD_single_subj_norm_diff;
% end
%%store
% save(fullfile(datapath,'data\results\BD_surr'),'BD_surr')

% Loading SURROGATES BD 
load(fullfile(datapath,'data\results\BD_surr'))

%% organize the surrogate and the empirical BD and prepare for plot
for p=1:size(func_data,2)
  
    %load and store surrogate BD from all patients
    surrBDnorm(:,:,p)=BD_surr(p).BD;

    %load and store empirical BD from all patients
    BDnorm(p,:)=data_GSP1(p).step1.BD;
end

%% STATS 
sig_pval=-1*ones(size(func_data,2),size(BDnorm,2));
sig_pvalp=ones(size(func_data,2),size(BDnorm,2));

for p=1:size(func_data,2)
    for tp=1:size(BDnorm,2)
        
        val=BDnorm(p,tp); %empirical value to compare with null distribution 
        null_dist=squeeze(surrBDnorm(:,tp,p));%null distribution 
        
        %percentage of sample greater than observed value
        bigger_vals=length(find(null_dist>val))/length(null_dist);
        
        %percentage of sample smaller than observed value
        smaller_vals=length(find(null_dist<val))/length(null_dist);
        
        if bigger_vals<=.025 %it's significant, more segregation
            sig_pval(p,tp)=bigger_vals;
        elseif smaller_vals<=.025%it's significant, more integration
            sig_pval(p,tp)=smaller_vals;
        end
     
        if val>=0
            sig_pvalp(p,tp)=-1+bigger_vals;
        else
            sig_pvalp(p,tp)=1-smaller_vals;
        end
    end
    
end

%% Figure S3a)
startIEDtime_point=find(t>=0.4607,1);%startIEDtime_avg
halfIEDtime_point=find(t>=0.4836,1);%halfIEDtime_avg
endIEDtime_point=find(t>=0.5042,1);%endIEDtime_avg

%reorder the subjects
subj_order=[10 12 14 4 5 8 11 9 6 1 2 13 15 3 16 7 17];


figure;
imagesc(sig_pvalp(subj_order,:))
colormap(brewermap(256,'RdYlBu'))
box off
hold on
xt = get(gca, 'XTick');                                             % Original 'XTick' Values
xtlbl = round([0.3:0.1:0.7],2);                     % New 'XTickLabel' Vector
set(gca, 'XTick',[1 25 50 75 100], 'XTickLabel',xtlbl, 'XTickLabelRotation',0)
xlabel('Time [s]')
ylabel('Subject')
colorbar
hold on
line([startIEDtime_point,startIEDtime_point], [size(sig_pvalp,1)+1,0], 'Color', 'w','LineStyle','-.','LineWidth',1);
hold on
line([halfIEDtime_point,halfIEDtime_point], [size(sig_pvalp,1)+1,0], 'Color', 'w','LineStyle','-.','LineWidth',1);
hold on
line([endIEDtime_point,endIEDtime_point], [size(sig_pvalp,1)+1,0], 'Color', 'w','LineStyle','-.','LineWidth',1);
hold off

%% Figure S3b)

figure;
%imagesc(sig_mask(subj_order,:))
sig_pvalp(sig_pvalp<0.95 & sig_pvalp>-0.95)=0; %threshold the matrix at 2.5%
imagesc(sig_pvalp(subj_order,:))
colormap(brewermap(256,'RdYlBu'))
box off
hold on
xt = get(gca, 'XTick');                                           
xtlbl = round([0.3:0.1:0.7],2);                    
set(gca, 'XTick',[1 25 50 75 100], 'XTickLabel',xtlbl, 'XTickLabelRotation',0)
xlabel('Time [s]')
ylabel('Subject')
hold on
line([startIEDtime_point,startIEDtime_point], [size(sig_pvalp,1)+1,0], 'Color', 'w','LineStyle','-.','LineWidth',1);
hold on
line([halfIEDtime_point,halfIEDtime_point], [size(sig_pvalp,1)+1,0], 'Color', 'w','LineStyle','-.','LineWidth',1);
hold on
line([endIEDtime_point,endIEDtime_point], [size(sig_pvalp,1)+1,0], 'Color', 'w','LineStyle','-.','LineWidth',1);
hold off


