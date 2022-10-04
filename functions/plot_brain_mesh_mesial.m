function fig=plot_brain_mesh_mesial(ROI_patch,rgb,fig_name)

fig=figure('Name',fig_name)
%plot left
ax(1) = subplot(2,2,1);
p(:,1) = arrayfun(@(ROI_patch) patch(ROI_patch, 'EdgeColor', 'None', 'FaceColor', 0.6*[1 1 1]), ROI_patch(end/2+1:end));
view([180 0])

%plot right
ax(2) = subplot(2,2,2);
p(:,2) = arrayfun(@(ROI_patch) patch(ROI_patch, 'EdgeColor', 'None', 'FaceColor', 0.6*[1 1 1]), ROI_patch(1:end/2));
view([0 0])

%plot from top
ax(3) = subplot(2,2,3);
p(:,3) = arrayfun(@(ROI_patch) patch(ROI_patch, 'EdgeColor', 'None', 'FaceColor', 0.6*[1 1 1]), ROI_patch(end/2+1:end));
% view([180 0])
view([0 0 ])

%plot from bottom
ax(4) = subplot(2,2,4);
p(:,4) = arrayfun(@(ROI_patch) patch(ROI_patch, 'EdgeColor', 'None', 'FaceColor', 0.6*[1 1 1]), ROI_patch(1:end/2));
view([-180 0 ])

axis(ax(1:end), 'vis3d', 'equal', 'off')
material(ax(1:end), 'dull')
arrayfun(@(axx) camlight(axx, 'headlight'), ax(1:end));


n_ROIs=length(ROI_patch);
for id_ROI = 1:n_ROIs
    
    idx_rgb=id_ROI;
    
    if id_ROI <= n_ROIs/2 %right
        [p(id_ROI,2 ).FaceColor] =rgb(idx_rgb,:);
        [p(id_ROI,4 ).FaceColor] =rgb(idx_rgb,:);
        
        %         [p_top(id_ROI,1 ).FaceColor] = rgb(idx_rgb,:);
        %         [p_bottom(id_ROI,1 ).FaceColor] = rgb(idx_rgb,:);
    else %left
        [p(id_ROI-n_ROIs/2,1).FaceColor] = rgb(idx_rgb,:);
        [p(id_ROI-n_ROIs/2,3).FaceColor] = rgb(idx_rgb,:);
        
        %         [p_top(id_ROI,1 ).FaceColor] = rgb(idx_rgb,:);
        %         [p_bottom(id_ROI,1 ).FaceColor] = rgb(idx_rgb,:);
    end
end
drawnow
% cmap=colormap(brewermap(256,colormap_label));
% c=colorbar
