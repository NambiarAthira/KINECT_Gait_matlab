close all
clear all
clc

starting=20
ending=30


for k=starting:ending
 file_name =[ 'frame' num2str(k)];
 load (file_name,'mat');                                                                        % Load the 3D silhouette matrix info for each frame coming under the gait cycle
 [w{k}]=silhouette(mat)
 p(k) = get(gca, 'Children');
 saveas(w{k}, ['w' num2str(k) '.fig'])  
end

% Plot the voxel 3D human point cloud gait of one cycle
figure, set(gcf,'name','Average point cloud','numbertitle','off')
            
for k=starting:ending
new_handle = copyobj(p(k),gca);
end
            
view(3),hold on,grid on;axis square,
set(gca,'XLim',[250 450],'YLim',[150 300],'ZLim',[200 300]);
view(180,90) 
                       
% save the voxel model
saveas(new_handle, ['average' '.fig'])
close all;
