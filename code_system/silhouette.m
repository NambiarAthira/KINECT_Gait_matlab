
function [w]=silhouette(mat)

% close all
% clear all
% clc

% load('D:\Kinect_Softwares\knect_matlab\3_11\frame10.mat')
% mat;
z=mat(:,3);
find(z~=0);
index=ans;
mat=mat(index,:)

x=mat(:,1);
y=mat(:,2);
z=mat(:,3);
figure,
w=plot3(x,y,z,'.')
hold on, axis square ,
set(gca,'XLim',[250 450],'YLim',[150 300],'ZLim',[200 300]);
view(180,90) 
grid on;
end