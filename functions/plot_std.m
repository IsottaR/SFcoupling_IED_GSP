function [rgb_c,obj,avg_all_Max2plot]=plot_std(data_avg,t,lambda,rgb_in)
% Plots with tsd of timecourse data
% data_avg = data NxT N=# subj T=timepoints
% t = timecourse
% lambda = lambda*std

if ~iscell(data_avg)
   
%     S = lambda*std(data_avg,[],1)/sqrt(size(data_avg,1));
        S = std(data_avg,[],1);

    avg_subj=mean(data_avg,1);
    upper=avg_subj+S;
    lower=avg_subj-S;
    if nargin<=3
        rgb=rand(1,3);
    else
        rgb=rgb_in;
    end
    obj=plot(t,avg_subj,'b','LineWidth',2,'Color',rgb);
    hold on
    plot(t,upper,'LineWidth',0.5,'Color','w','LineStyle','none');
    plot(t,lower,'LineWidth',0.5,'Color','w','LineStyle','none');
%     plot(t,upper,'r','LineWidth',0.5,'Color',rgb);
%     plot(t,lower,'r','LineWidth',0.5,'Color',rgb);
    x2 = [t, fliplr(t)];
    inBetween = [lower, fliplr(upper)];
    fillhandle=fill(x2, inBetween, rgb);
    set(fillhandle,'FaceAlpha',.4,'EdgeAlpha',0);
    avg_all_Max2plot=avg_subj;
    rgb_c=rgb;

else
   
    for i=1:length(data_avg)

        S = lambda*std(data_avg{i},[],1)/sqrt(size(data_avg{i},1));
        avg_subj=mean(data_avg{i},1);
        upper=avg_subj+S;
        lower=avg_subj-S;
        if nargin<=3
            rgb=rand(1,3);
        else
            rgb=rgb_in(i,:);
        end
        obj{i}=plot(t,avg_subj,'LineWidth',2,'Color',rgb);
        hold on
        %uncomment if you do not want edges on std min error plot
%         plot(t,upper,'LineWidth',0.5,'Color','w','LineStyle','none');
%         plot(t,lower,'LineWidth',0.5,'Color','w','LineStyle','none');
        plot(t,upper,'LineWidth',0.5,'Color',rgb);
        plot(t,lower,'LineWidth',0.5,'Color',rgb);
        x2 = [t, fliplr(t)];
        inBetween = [lower, fliplr(upper)];
        fillhandle=fill(x2, inBetween,rgb);
        set(fillhandle,'FaceAlpha',0.4,'EdgeAlpha',0);
        rgb_c(i,:)=rgb;
        avg_all_Max2plot{i}=avg_subj+S;
    end
   
end

end
