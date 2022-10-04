
%% ---------------------- COMPACTNESS ANALYSES ----------------------------
%count number of harmonics needed to represent 80% of the total power in C1
%and C2
for p=1:size(func_data,2)
    clearvars -except data_GSP1 struct_data p func_data clusters N_heaviest_harm clust_permutest t datapath

    data_sub=data_GSP1(p).step1;

        %project ROI signal to harmonic space
    for ep=1:size(data_sub.zX_RS,3)
        X_hat_L(:,:,ep)=struct_data.U'*data_sub.zX_RS(:,:,ep);
    end
    
    for c=1:size(clusters,2) 
           
        %-------get energy (PSD) of each harmonics over time (for the specific cluster)
        zX_RS_current=data_sub.zX_RS(:,clusters{1, c},:); %current zscored time series
        
        % PSD of each harmonics over the cluster
        [PSD,~,~, ~]=get_cut_off_freq(struct_data.U,zX_RS_current);
        
        %average energy over epochs
        meanPSD=mean(PSD')';

        %--------sort harmonics that have the highest abs weight
        [sorted_weights,sorted_harmonic_ID]=sort(meanPSD,'descend');
        
        %--------sort the signal (in harmonics space) with the heaviest harmonics
        current_signal=X_hat_L(sorted_harmonic_ID,clusters{1, c},:);
        
        % get cumulative power for the SC harmonics
        for h=1:size(struct_data.U,1)
            clear P
            for ep=1:size(current_signal,3)
                for tp=1:size(current_signal,2)
                    %norm over ROIs
                    P(tp,ep)=norm(squeeze(current_signal(1:h,tp,ep)));
                end
            end
            %get power reconstructing the signal with h harmonics (average across time and epochs)
            full_power_GFT(h)=mean(mean(P,1));
        end
        
        %total power (using all harmonics)
        power_all_harm=full_power_GFT(end);

        %percentage of the power 
        pow_perc=0.8*power_all_harm;
        
        %number of the heaviest harmonics necessary to reconstruct 80% of the power
        N_heaviest_harm(p,c)=find(full_power_GFT>=pow_perc,1);
    end
end


%% ------------------------ STATS and plot --------------------------------
%Wilcoxon signed rank test
p_val = signrank(N_heaviest_harm(:,1),N_heaviest_harm(:,2));

% plot results
fig=figure
boxplot([N_heaviest_harm(:,1) N_heaviest_harm(:,2)],'Labels',{'C1','C2'})
hold on
for p=1:size(func_data,2)
    pos_x1=1+(rand(1)-0.5)/10; %randomize position along x-axis
    scatter(pos_x1,N_heaviest_harm(p,1),25,'MarkerEdgeColor',[201 198 187]/255,'MarkerFaceColor',[201 198 187]/255);
    %plot the value of the second group
    pos_x2=2+(rand(1)-0.5)/10; %randomize position along x-axis
    hold on
    scatter(pos_x2,N_heaviest_harm(p,2),25,'MarkerEdgeColor',[201 198 187]/255,'MarkerFaceColor',[201 198 187]/255);
    plot([pos_x1 pos_x2],[N_heaviest_harm(p,1) N_heaviest_harm(p,2)],'Color',[201 198 187]/255);
end
ylabel(['N_{80%}'])
title(['p val = ', num2str(p_val)])
box off
