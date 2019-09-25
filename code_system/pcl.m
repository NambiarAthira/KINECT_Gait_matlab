function [h vari mat sph silhouette]=pcl(k,resizedmatrix,xx,yy,dist,ref_centIndex,X00,Y00)
fontSize=10;
%3D point cloud 

% grayImage=final;
% 
% %Get the resized image with centroid
% % ref=imread(referenceFrame);
% 
% % J=sort(ref(ref~=0));
% % threshold=J(1)+width;
% % b = ref; b (b==0) = 255; b = b<threshold; 
% % refImage=(double(ref).*b);
% % [xx yy]=[centre_x centre_y]
% ref_centindex=refImage(xx,yy)
% 
% ratio=centindex/ref_centindex;
% % figure,
% resizedmatrix=imresize_old(grayImage,ratio);
% % imshow(resizedmatrix);hold on,
% % title('Resized Image with centroid', 'FontSize', fontSize);
[row,col]= size(resizedmatrix);
paddedmatrix = padarray(resizedmatrix,[480-size(resizedmatrix,1) 640-size(resizedmatrix,2)],'post');
% % plot(X00,Y00,'-m*');


%% Figure3
% Allign the resized image centroid with the standard reference centroid

dx =xx-X00 ;
dy =yy-Y00 ;
paddedmatrix = circshift(paddedmatrix,[dy dx]);
% x_new=X00+dx;
% y_new=Y00+dy;
% 
% % plot(x_new,y_new,'-r*');
% paddedmatrix=zeros(size(resizedmatrix)+[dy dx]);
% paddedmatrix(end-size(resizedmatrix,1)+1:end, end-size(resizedmatrix,2)+1:end)=resizedmatrix;
% dist=ref_centindex-centindex;
Z=paddedmatrix+(paddedmatrix>0)*dist;
Z(Z>(ref_centIndex+25))=0;
silhouette=Z;
% z = padarray(Z,[480-size(Z,1) 640-size(Z,2)],'post');
figure,
imshow(silhouette),hold on,
[X00 Y00]=cent(Z);
plot(X00,Y00,'-r*');
saveas(gcf, ['silhouette' num2str(k) '.fig'])
close
%  title('Image after resizing and alligning', 'FontSize', fontSize);


%Label each blob so we can make measurements of it
[labeledImage numberOfBlobs] = bwlabel(Z, 8);
% Get all the blob properties.
blobMeasurements = regionprops(labeledImage, 'BoundingBox','Area');
allBlobAreas = [blobMeasurements.Area];
for k = 1 :numberOfBlobs
boundingBox = blobMeasurements(k).BoundingBox;	 % Get box.
aspectRatio(k) = boundingBox(3) / boundingBox(4);
end

% Find the biggest binary blob and plot the bounding box
[r,c] = find(allBlobAreas==max(allBlobAreas(:))); 
s=blobMeasurements(c).BoundingBox;
x1 = s(1);
y1 = s(2);
x2 = x1 + s(3) - 1;
y2 = y1 + s(4) - 1;
verticesX = [x1 x2 x2 x1 x1];
verticesY = [y1 y1 y2 y2 y1];
% plot(verticesX, verticesY, 'r-', 'LineWidth', 2);

[X,Y]=meshgrid(1:640,1:480);
p=reshape(X,1,(size(X,1)*size(X,2)));
q=reshape(Y,1,(size(Y,1)*size(Y,2)));
r=reshape(Z,1,(size(Z,1)*size(Z,2)));
mat=[p' q' r'];
[THETA,PHI,R] = cart2sph(p',q',r');
sph=[R THETA PHI];

% height=y2-y1;
% wth=x2-x1;


%% Figure4
% Generate the point cloud (3D) of the image (2D)
%Intrinsics of the depth(IR)cameras
cx  = 319.5 ;    %(cx,cy): Optical center, pixels
cy  = 239.5 ;
fx  = 525.0 ;    % (fx,fy): Focal distance, pixels
fy  = 525.0 ;

n=size(Z,1)*size(Z,2);


[y,x] = meshgrid(1:size(Z,2),1:size(Z,1));
a=(x-cx).*Z/fx ;
X=reshape(a,1,n);
% X=a;
% X(X==0)=[];
b=(y-cy).*Z/fy;
Y=reshape(b,1,n);
% Y=b;
% Y(Y==0)=[];
Z=reshape(Z,1,n);
% Z=z;
Z_new=Z(Z>0);
% Z(Z==0)=[];
vari=var(Z_new,1);
% vari_min=min(vari);
% Centroid
% x0=(X00-cx).*centindex/fx ;
% y0=(Y00-cy).*centindex/fy ;

figure,
h=plot3(X,Y,Z,'.'),hold on, axis square ,
% set(gca,'XLim',[-70 15],'YLim',[-20 60]);
set(gca,'XLim',[-80 0],'YLim',[-20 60],'ZLim',[0 250]);
% set(gca,'XLim',[],'YLim',[])
view(90,90) 
grid on;
% axis off;
% set(gca,'ydir','reverse')
% set(gca, 'xlim',[-20 -15], 'ylim',[-20 40], 'zlim',[0 80]),
 axis square 
% rotate(h,[1 0 0],90)
% xx;
% yy;
end
