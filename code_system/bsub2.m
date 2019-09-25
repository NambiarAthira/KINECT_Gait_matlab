% Code to obtain the human silhouette from RGB frame and the Depth frame of
% KINECT camera...

% Author: athira
% Date  : 17/01/2012

close all;
clear all;
clc

tole=25;
width=15;

% Read the image frames   

cd 'C:\Users\athira\Desktop\Kinect_Softwares\knect_matlab\dataset3new\3_01';

testrgbFrame='rgbframe320.png';
testdepthFrame='frame320.png';
referenceFrame='rgbframe380.png';

a=imread(testrgbFrame);       % frame including human body
b=imread(referenceFrame);     % background image

a=rgb2gray(a);
b=rgb2gray(b);

a=imadjust(a, stretchlim(a), [0 1]);
b=imadjust(b, stretchlim(b), [0 1]);

diff=b-a;                     % Difference of RGB images

figure,
set(gcf, 'Position', get(0,'Screensize'));

subplot(3,4,1)
imshow(diff); title('difference of RGB image')  % difference of RGB images

% Grayscale and BW conversion
subplot(3,4,2),
im=diff   ;         % grayscale of difference of RGB image
level = graythresh(im);       % calculate the smart threshold level using Otsu's method 
d = im2bw(im,level)   ;       % RGB difference image is thresholded and BW image is plotted
imshow(d), title('Thresholded BW image'),hold on,

% Morphological operations
subplot(3,4,3),
se = strel('diamond',6);
bw2 = imdilate(d,se);           % Binary dilation is carried out on thresholded image  
BWfill = imfill(bw2, 'holes');  % Fill the image regions and holes inside
BWnobord = imclearborder(BWfill, 1);  % Clears the image border
imshow(BWnobord), title('Dilated'),hold on,

%Label each blob so we can make measurements of it
[labeledImage numberOfBlobs] = bwlabel(BWnobord, 8);
% Get all the blob properties.
blobMeasurements = regionprops(labeledImage, 'BoundingBox','Area');
allBlobAreas = [blobMeasurements.Area];
for k = 1 :numberOfBlobs
boundingBox = blobMeasurements(k).BoundingBox;	 % Get box.
aspectRatio(k) = boundingBox(3) / boundingBox(4);
fprintf('For blob #%d, area = %d, aspect ratio = %.2f\n', ...
k, allBlobAreas(k), aspectRatio(k));
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
plot(verticesX, verticesY, 'r-', 'LineWidth', 2);


% Generate the depth image
subplot(3,4,4)
imshow(testdepthFrame);title('depthImage')
i=imread(testdepthFrame);
I=i(:,:,1);hold on,
plot(verticesX, verticesY, 'r-', 'LineWidth', 2);

% generate the adapting shifing for the bounding box in order to cover the
% human body in the depth image ...!
% med=mode(mode(double(I(y1:y2,x1:x2))))
human_box=((double(I(y1:y2,x1:x2)))).*BWnobord(y1:y2,x1:x2);
human_point=mode(human_box(human_box~=0));
med=human_point;

% hori=double(ceil(10*135/med));
% verti=double(ceil(10*75/med));
% hori=0;
% verti=0;
% 
% verticesX_new = [x1 x2 x2 x1 x1]+hori;
% verticesY_new = [y1 y1 y2 y2 y1]-verti;
% plot(verticesX_new, verticesY_new, 'm-', 'LineWidth', 2); 

%Shift the grayImage in  order to allign both the RGB and depth images of Kinect
%camera.
% X=BWnobord;
% xshift=hori;
% yshift=verti;
% idx = repmat({':'}, ndims(X), 1);
% n = size(X, 1);
% idx{1} = [ xshift+1:n 1:xshift ] ; % shift left/up/backwards k elements
% Y = X(idx{:});
% idx = repmat({':'}, ndims(Y), 1);
% n = size(Y, 2);
% idx{2} = [ n-yshift+1:n 1:n-yshift ];  % shift right/down/forwards k elements
% Z = Y(idx{:});

% subplot(3,4,5)
% imshow(BWnobord),hold on, title(' New mask alligned with depthImage/Foreground RGB silhouette)')
% plot(verticesX, verticesY, 'm-', 'LineWidth', 2);
% plot(verticesX_new, verticesY_new, 'm-', 'LineWidth', 2);


subplot(3,4,5)
max_threshold=med+width;
min_threshold=med-width;
human = I; 
human = human<max_threshold & human>min_threshold;
human(:,1:x1-tole)=0;
human(:,x2+tole:end)=0;
human(1:y1-3*tole,:)=0;
human(y2+tole:end,:)=0;
human_depth=(double(I).*human);
imshow(human_depth);hold on;
plot(verticesX, verticesY, 'r-', 'LineWidth', 2);
title('Depth silhouette ')

%Shift the new  in  order to allign both the RGB and depth images of Kinect
%camera.
subplot(3,4,6)
imshow(a),hold on;
title(' Original RGB image with human');
plot(verticesX, verticesY, 'r-', 'LineWidth', 2);

%Shift the depth silhouette in  order to allign with the RGB image of Kinect
%camera.
subplot(3,4,7)
% X=human_depth;
% xshift=hori;
% yshift=verti;
% idx = repmat({':'}, ndims(X), 1);
% n = size(X, 1);
% idx{1} = [ n-xshift+1:n 1:n-xshift ]; % shift left/up/backwards k elements
% Y = X(idx{:});
% idx = repmat({':'}, ndims(Y), 1);
% n = size(Y, 2);
% idx{2} = [ yshift+1:n 1:yshift ] ;  % shift right/down/forwards k elements
% Z = Y(idx{:});
% imshow(human_depth);hold on;
% title(' depth silhouette alligned with RGBImage')
% plot(verticesX, verticesY, 'r-', 'LineWidth', 2);

%Figure out the final human silhouette by combining both the depth
%silhouette with the foreground silhouette
% subplot(3,4,9)
final=human_depth.*BWnobord;
imshow(final),
title(' Final human silhouette extracted')













