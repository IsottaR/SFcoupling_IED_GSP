
%new structure for the results
data_GSP2_surr=rmfield(data_GSP1,'step1');
for p=1:size(data_GSP1,2)
    for n=1:size(PHI,1)
        data_sub=data_GSP1(p).step1;
        zX_RS_curr=data_sub.zX_RS;
        
        XrandS=zeros(size(zX_RS_curr,1),size(zX_RS_curr,2),size(zX_RS_curr,3));
        %reconstruct the data randomizing the GFT weights
        PHI_curr=squeeze(PHI(n,:,:));
        for ep=1:size(zX_RS_curr,3)
            XrandS(:,:,ep)=struct_data.U*PHI_curr*struct_data.U'*zX_RS_curr(:,:,ep); % X_hat=M'X, normally reconstructed signal would be Xrecon=M*X_hat=MM'X, instead of M, M*PHI is V with randomized signs
        end
        
        %% SDI on whole epoch ([.3 -.7 s])
        [~,~,N_c,N_d,~]=filter_signal_with_harmonics(struct_data.U,XrandS,data_sub.Vlow,data_sub.Vhigh);
        
        clear SDI
        %average coupling and decoupling across epochs and then get SDI
        SDIsurr(:,n)=mean(N_d,2)./mean(N_c,2); %empirical AVERAGE SDI
    end
    %average coupling and decoupling across epochs and then get SDI
    GSP_SDI.SDIsurr=SDIsurr;
    
    data_GSP2_surr(p).step2=GSP_SDI;
end

save(fullfile(datapath,'results\data_GSP2_surr'),'data_GSP2_surr')
