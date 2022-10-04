function plot_FH_HF_content(LF,HF,t,color1,color2)


[rgb_c,obj,avg_all_Max2plot]=plot_std(LF',t,3,color1);
hold on
[rgb_c,obj,avg_all_Max2plot]=plot_std(HF',t,3,color2);
hold on
% legend('LF','HF');