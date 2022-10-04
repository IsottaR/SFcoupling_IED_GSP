function BD_norm_diff =get_surrogate_BD(U,zX_RS)

% - Project the functional data (IEDs epochs of source reconstructed EEG)
%   on the harmonics of the surrogates and split the connectum spectrum in
%   Vlow and Vhigh
% - Reconstruct the coupled (X_c) and decoupled (X_d) part of the ROI time series
% - Calculate the L2 norm over ROIs (c_norm, d_norm) and normalise it by
%   the total power (X_c_norm, X_d_norm)
% - average the norm (and the normalised one) across the epochs
% - calculate BD at each timepoint as the difference between LF and HF
%   content

%% split harmonics in high and low
[~,~,Vlow, Vhigh]=get_cut_off_freq(U,zX_RS);

%% get the part of the signal the is COUPLED and DECOUPLED from the structure
% filter the EEG signal and get emipirical individual SDI
[X_c,X_d,~,~,~]=filter_signal_with_harmonics(U,zX_RS,Vlow,Vhigh);

%% LF/HF content
% calculate power in time for normalization
power_in_time=zeros(size(zX_RS,3),size(zX_RS,2));
for ep=1:size(power_in_time,1)
    for t=1:size(zX_RS,2)
        power_in_time(ep,t)=norm(zX_RS(:,t,ep));
    end
end
power_in_time=(power_in_time)';

% normalize backprojected time series
for ep=1:size(zX_RS,3)
    for t=1:size(zX_RS,2)
  
        %normalize by the norm of the power of the original signal
        X_c_norm(t,ep)=((norm(squeeze(X_c(:,t,ep))))/power_in_time(t,ep));
        X_d_norm(t,ep)=((norm(squeeze(X_d(:,t,ep))))/power_in_time(t,ep));
    end
end

%% BD as difference between LF and HF content at each time point, averaged across trl
%get Broadcasting Direction, normalised by total power
BD_norm_diff=(mean(X_d_norm,2)-mean(X_c_norm,2))';
