
function [D]= pclDensity(k,mat,nBins1,nBins2,nBins3)

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
r=find(mat(:,3)==0);
mat(r,:)=[];
mat;
x=mat(:,1);
y=mat(:,2);
z=mat(:,3);
% plot3(x,y,z,'.');
% hold on,grid on;axis square,
% set(gca,'XLim',[0 640],'YLim',[0 480],'ZLim',[0 250]);
% view(0,-90);


% nBins1=80;
% nBins2=60;
% nBins3=50;

xBins=linspace(0,640,nBins1);
yBins=linspace(0,480,nBins2);
zBins=linspace(0,300,nBins3);

D=zeros(nBins1,nBins2,nBins3);

for i=1:numel(x)
    xi=find((x(i)>xBins),1,'last');
    yi=find((y(i)>yBins),1,'last');
    zi=find((z(i)>zBins),1,'last');
    D(xi,yi,zi)=D(xi,yi,zi)+1;
end
D ;

end