function [D_sph]=sphericalDensity(k,sph,nBins1_sph,nBins2_sph,nBins3_sph)

% open frame64.fig
% %myFigStruct = load('frame60.fig','-MAT')
% get(get(gca,'Children'))
% x = get(get(gca,'Children'),'XData')
% y = get(get(gca,'Children'),'YData')
% z = get(get(gca,'Children'),'ZData')
% figure,plot3(x,y,z,'.'),hold on,grid on;axis square,
% set(gca,'XLim',[-80 0],'YLim',[-20 60],'ZLim',[0 250])
% view(90,90);

% for k=starting:ending
% load frame66.mat
% disp('Contents of workspace after loading file:')
% whos
% end
r=find(sph(:,3)==0);
sph(r,:)=[];
sph;
ro=sph(:,1);
theta=sph(:,2);
phi=sph(:,3);
% plot3(x,y,z,'.');
% hold on,grid on;axis square,
% set(gca,'XLim',[0 640],'YLim',[0 480],'ZLim',[0 250]);
% view(0,-90);


% nBins1_sph=510;
% nBins2_sph=24;
% nBins3_sph=12;

ro_Bins=linspace(0,500,nBins1_sph);
theta_Bins=linspace(0,2*pi,nBins2_sph);
phi_Bins=linspace(0,pi,nBins3_sph);

D_sph=zeros(nBins1_sph,nBins2_sph,nBins3_sph);

for i=1:numel(ro)
    roi=find((ro(i)>ro_Bins),1,'last');
    thetai=find((theta(i)>theta_Bins),1,'last');
    phii=find((phi(i)>phi_Bins),1,'last');
    D_sph(roi,thetai,phii)=D_sph(roi,thetai,phii)+1;
end
D_sph;

end