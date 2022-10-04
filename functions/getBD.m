function [BD,X_c_norm,X_d_norm] = getBD(zX_RS,X_c,X_d)

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
    
    %get Broadcasting Direction BD
    BD=(mean(X_d_norm,2)-mean(X_c_norm,2))'; %BDnorm

  
   