function [PSD,NN,Vlow, Vhigh]=get_cut_off_freq(sc,data)

%% compute CUT-OFF FREQUENCY
for ep=1:size(data,3)
    X_hat_L(:,:,ep)=sc'*data(:,:,ep);
end
%power
pow=abs(X_hat_L).^2;

%mean across time
PSD=squeeze(mean(pow,2));

%mean across subjects/epochs
mPSD=mean(PSD,2);

%total area under the curve
AUCTOT=trapz(mPSD(1:size(sc,1))); %total area under the curve

i=1;
AUC=0;
while AUC<AUCTOT/2
    i=i+1;
    AUC=trapz(mPSD(1:i));
end
NN=i-1; %CUTOFF FREQUENCY : number of low frequency eigenvalues to consider in order to have the same energy as the high freq ones

%% split structural harmonics in high/low frequency

Vlow=zeros(size(sc));
Vhigh=zeros(size(sc));
Vhigh(:,NN+1:end)=sc(:,NN+1:end);%high frequencies= decoupled
Vlow(:,1:NN)=sc(:,1:NN);%low frequencies = coupled

