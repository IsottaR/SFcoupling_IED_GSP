function new_val=change_range_SDI(original_val,NewMin,NewMax,saturate)

%original_val = log(SDI)
new_val_temp=nan(size(original_val));

%saturate the signal if you want and cap it to -1.5 and +1.5
if saturate
    thr=1;
    CC2new=original_val;
    CC2new(find(original_val>thr))=0;
    CC2new(find(original_val>thr))=max(CC2new);
    CC2new(find(original_val<-thr))=0;
    CC2new(find(original_val<-thr))=min(CC2new);
    original_val=CC2new;
end

%look for negative values 
I_negative=find(original_val<0);

if ~isempty(I_negative)
    %redistribute the negative values between -1 and OldMax (close to zero) 
    CC2new_negative=original_val(I_negative);
    OldMax=max(CC2new_negative);
    OldMin=min(CC2new_negative);
    OldRange = (OldMax - OldMin)  ;
    NewRange = (OldMax - NewMin)  ;
    new_val_temp(I_negative) = (((CC2new_negative - OldMin) * NewRange) / OldRange) + NewMin;
    
    %redistribute the positive values between OldMin (close to zero) and 1
    I_positive=find(original_val>=0);
    CC2new_positive=original_val(I_positive);
    OldMax=max(CC2new_positive);
    OldMin=min(CC2new_positive);
    OldRange = (OldMax - OldMin)  ;
    NewRange = (NewMax - OldMin)  ;
    new_val_temp(I_positive) = (((CC2new_positive - OldMin) * NewRange) / OldRange) + OldMin;
    
    new_val=new_val_temp;
else
    
    CC2new=original_val;
    OldMax=max(CC2new);
    OldMin=min(CC2new);
    OldRange = (OldMax - OldMin)  ;
    NewRange = (NewMax - NewMin)  ;
    new_val = (((CC2new - OldMin) * NewRange) / OldRange) + NewMin;
end