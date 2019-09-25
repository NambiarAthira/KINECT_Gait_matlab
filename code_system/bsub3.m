% Code to obtain the human silhouette from RGB frame and the Depth frame of
% KINECT camera...

% Author: athira
% Date  : 17/01/2012

%Read the background image  frame(b) and the frame including foreground(a)

close all;
clear all;
clc

cd 'C:\Users\athira\Desktop\Kinect_Softwares\knect_matlab\dataset3new\3_02';

fontSize=10;
% thresh=10
% hori=10
% verti=25
tole=25
width=15

testrgbFrame='rgbframe270.png';
testdepthFrame='frame270.png';
referenceFrame='rgbframe380.png';
backgroundFrame='rgbframe380.png';

a=imread(testrgbFrame);    % frame including human body
b=imread(referenceFrame);  % background image
diff=b-a;                     % Difference of RGB images

figure,
set(gcf, 'Position', get(0,'Screensize'));
subplot(3,3,1)
imshow(diff); title('difference of RGB image') 

subplot(3,3,2),
im=rgb2gray(diff)
% d=im;
level = graythresh(im) 
% d = d>thresh; 
d = im2bw(im,level)
imshow(d);hold on, title('Mask') % binary image (mask) of human

%Label each blob so we can make measurements of it
[labeledImage numberOfBlobs] = bwlabel(d, 8);
% Get all the blob properties.
blobMeasurements = regionprops(labeledImage, 'BoundingBox','Area');
allBlobAreas = [blobMeasurements.Area];
for k = 1 :numberOfBlobs
boundingBox = blobMeasurements(k).BoundingBox;	 % Get box.
aspectRatio(k) = boundingBox(3) / boundingBox(4);
fprintf('For blob #%d, area = %d, aspect ratio = %.2f\n', ...
k, allBlobAreas(k), aspectRatio(k));
end

[r,c] = find(allBlobAreas==max(allBlobAreas(:)));
s=blobMeasurements(c).BoundingBox;
x1 = s(1)
y1 = s(2)
x2 = x1 + s(3) - 1
y2 = y1 + s(4) - 1
verticesX = [x1 x2 x2 x1 x1]
verticesY = [y1 y1 y2 y2 y1]
plot(verticesX, verticesY, 'r-', 'LineWidth', 2);

% Generate the foreground image
subplot(3,3,3)
imshow(testdepthFrame);title('depthImage')
i=imread(testdepthFrame);
I=i(:,:,1);hold on,
plot(verticesX, verticesY, 'r-', 'LineWidth', 2);
med=median(median(I(y1:y2,x1:x2)))

% generate the adapting shifing for the bounding box in order to cover the
% human body in the depth image ...!
hori=double(ceil(10*135/med))
verti=double(ceil(10*75/med))

verticesX_new = [x1 x2 x2 x1 x1]+hori
verticesY_new = [y1 y1 y2 y2 y1]-verti
plot(verticesX_new, verticesY_new, 'm-', 'LineWidth', 2);

%Shift the grayImage in  order to allign both the RGB and depth images of Kinect
%camera.
X=d
xshift=hori
yshift=verti
idx = repmat({':'}, ndims(X), 1);
n = size(X, 1)
idx{1} = [ xshift+1:n 1:xshift ]  % shift left/up/backwards k elements
Y = X(idx{:})
idx = repmat({':'}, ndims(Y), 1);
n = size(Y, 2)
idx{2} = [ n-yshift+1:n 1:n-yshift ]  % shift right/down/forwards k elements
Z = Y(idx{:})

subplot(3,3,4)
imshow(Z),hold on, title(' New mask alligned with depthImage')
plot(verticesX, verticesY, 'r-', 'LineWidth', 2);
plot(verticesX_new, verticesY_new, 'm-', 'LineWidth', 2);


subplot(3,3,5)
max_threshold=med+width;
min_threshold=med-width;
human = I; 
human = human<max_threshold & human>min_threshold;
human(:,1:x1-tole)=0;
human(:,x2+tole:end)=0;
human(1:y1-3*tole,:)=0;
human(y2+tole:end,:)=0;
human_depth=(double(I).*human);
% c=zeros(size(I));
% c(verticesX,verticesY)=ones;
% b=c.*b
%c(verticesX,verticesY)=ones
imshow(human_depth);hold on;
% plot(verticesX_new, verticesY_new, 'm-', 'LineWidth', 2);
title(' silhouette alligned with depthImage')

subplot(3,3,6)
imshow(a),
title(' Original RGB image with human')

%Shift the new  in  order to allign both the RGB and depth images of Kinect
%camera.
subplot(3,3,7)
X=human_depth;
xshift=hori
yshift=verti
idx = repmat({':'}, ndims(X), 1);
n = size(X, 1)
idx{1} = [ n-xshift+1:n 1:n-xshift ] % shift left/up/backwards k elements
Y = X(idx{:})
idx = repmat({':'}, ndims(Y), 1);
n = size(Y, 2)
idx{2} = [ yshift+1:n 1:yshift ]   % shift right/down/forwards k elements
Z = Y(idx{:})
imshow(Z);hold on;
title(' silhouette alligned with RGBImage')


subplot(3,3,8)
grayA=a;
% BW1 = edge(grayA,'prewitt');
% % BW1 = edge(grayA,'sobel');

imshow(grayA);hold on;
plot(verticesX, verticesY, 'r-', 'LineWidth', 2);
title(' Gray image of Original RGB image with human')

subplot(3,3,9)
Z(grayA>70)=0;
ZZ= imfill(Z,'holes');
% seD = strel('disk',1);
% BWfinal = imerode(ZZ,seD);
% BWfinal = imerode(BWfinal,seD);
% imshow(BWfinal), 
imshow(ZZ),
title(' Human silhouette extracted')




% m = zeros(size(grayA,1),size(grayA,2));          %-- create initial mask
% m(y1:y2,x1:x2) = 1;
% 
% grayA = imresize(grayA,.5);  %-- make image smaller 
% m = imresize(m,.5);  %     for fast computation
% 
% seg = localized_seg(grayA, m, 400); %-- Run segmentation
% 
% imshow(seg); title('Global Region-Based Segmentation');
% 
% 
% 

















%%%%%%%%%cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

% EDGE DETECTION

% I=rgb2gray(diff);
% % figure,
% % subplot(3,3,1)
% % imshow(I), title('original image');
% 
% %Detect entire human
% [junk threshold] = edge(im, 'sobel');
% fudgeFactor = .5;
% BWs = edge(I,'sobel', threshold * fudgeFactor);
% % subplot(3,3,2)
% % imshow(BWs), title('binary gradient mask');
% % 
% 
% %Dilate the image
% se90 = strel('line', 3, 90);
% se0 = strel('line', 3, 0);
% BWsdil = imdilate(BWs, [se90 se0]);
% % subplot(3,3,3)
% % imshow(BWsdil), title('dilated gradient mask');
% 
% % Fill interior gaps
% BWdfill = imfill(BWsdil, 'holes');
% % subplot(3,3,4), 
% % imshow(BWdfill);
% % title('binary image with filled holes');
% 
% 
% % Remove connected objects on border
% BWnobord = imclearborder(BWdfill, 4);
% % subplot(3,3,5),  imshow(BWnobord), title('cleared border image');
% 
% 
% % Smoothen the object
% seD = strel('diamond',1);
% BWfinal = imerode(BWnobord,seD);
% BWfinal = imerode(BWfinal,seD);
% subplot(3,3,9), 
% imshow(BWfinal), title('segmented image');
% 
% % Outline the object in original image
% BWoutline = bwperim(BWfinal);
% Segout = I;
% Segout(BWoutline) = 255;
% % subplot(3,3,7), 
% % imshow(Segout), title('outlined original image');
% 
% 
% 
% 
