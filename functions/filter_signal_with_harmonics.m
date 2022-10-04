function [X_c,X_d,N_c,N_d,SDI]=filter_signal_with_harmonics(sc,data,Vlow,Vhigh)

%sc = harmonics of the structural connectome [ROI x HARM]
%Vlow = low freq harmonics [ROI x HARM]
%Vhigh = high freq harmonics [ROI x HARM]

%% compute ESI HF/LF portions
for ep=1:size(data,3)
    X_hat(:,:,ep)=sc'*data(:,:,ep);
    X_c(:,:,ep)=Vlow*X_hat(:,:,ep);
    X_d(:,:,ep)=Vhigh*X_hat(:,:,ep);
    % norms  of the weights over time
    for r=1:size(data,1)
        
        N_c(r,ep)=norm(X_c(r,:,ep));
        N_d(r,ep)=norm(X_d(r,:,ep));
    end
end

%% STRUCTURAL DECOUPLING INDEX
SDI=N_d./N_c; %emipirical individual SDI
