function [final Z verticesX verticesY]=bsub (testdepthFrame,testrgbFrame,backgroundFrame,width)

tole=25;
% width=15;


a=imread(testrgbFrame);        % frame including human body
b=imread(backgroundFrame);     % background image

a=rgb2gray(a);
b=rgb2gray(b);

a=imadjust(a, stretchlim(a), [0 1]);
b=imadjust(b, stretchlim(b), [0 1]);

diff=b-a;                     % Difference of RGB images
% imshow(diff); title('difference of RGB image')  % difference of RGB images

% % Grayscale and BW conversion
im=diff   ;         % grayscale of difference of RGB image
level = graythresh(im);       % calculate the smart threshold level using Otsu's method 
d = im2bw(im,level)   ;       % RGB difference image is thresholded and BW image is plotted
% imshow(d), title('Thresholded BW image'),hold on,

% Morphological operations
se = strel('diamond',8);
bw2 = imdilate(d,se);           % Binary dilation is carried out on thresholded image  
BWfill = imfill(bw2, 'holes');  % Fill the image regions and holes inside
BWnobord = imclearborder(BWfill, 1);  % Clears the image border
% imshow(BWnobord), title('Dilated'),hold on,

%Label each blob so we can make measurements of it
[labeledImage numberOfBlobs] = bwlabel(BWnobord, 8);
% Get all the blob properties.
blobMeasurements = regionprops(labeledImage, 'BoundingBox','Area');
allBlobAreas = [blobMeasurements.Area];
for k = 1 :numberOfBlobs
boundingBox = blobMeasurements(k).BoundingBox;	 % Get box.
aspectRatio(k) = boundingBox(3) / boundingBox(4);
% fprintf('For blob #%d, area = %d, aspect ratio = %.2f\n', ...
% k, allBlobAreas(k), aspectRatio(k));
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


% Generate the depth image
% imshow(testdepthFrame);title('depthImage')
i=imread(testdepthFrame);
I=i(:,:,1);
% plot(verticesX, verticesY, 'r-', 'LineWidth', 2);

% the bounding box covering the human body in the depth image ...!
% med=mode(mode(double(I(y1:y2,x1:x2))))
human_box=((double(I(y1:y2,x1:x2)))).*BWnobord(y1:y2,x1:x2);
human_point=mode(human_box(human_box~=0));
med=human_point;

max_threshold=med+width;
min_threshold=med-width;
human = I; 
human = human<max_threshold & human>min_threshold;
human(:,1:x1-tole)=0;
human(:,x2+tole:end)=0;
human(1:y1-3*tole,:)=0;
human(y2+tole:end,:)=0;
human_depth=(double(I).*human);
% imshow(human_depth);hold on;
% plot(verticesX_new, verticesY_new, 'm-', 'LineWidth', 2);
% title('Depth silhouette ')

% Final human silhouette extracted from both depth image and RGB image
Z=human_depth;
final=Z.*BWnobord;
% imshow(final),hold on,
% title(' Final human silhouette extracted')



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end











