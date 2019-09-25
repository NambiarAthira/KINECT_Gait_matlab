%% A script that would take a snapshot using the Kinect and save the RGB
% and the depth images in the local folder as rgb.png, depth.png.
% Output:
% rgb.png for the RGB image. (RGB Colormap).
% depth.png for the Depth image (8-bit GrayScale).
% A figure displaying both images.
%
% Author: MOHAMMED, Sinan.
% Supervised by: Prof. Thierry Pun &  Juan Gomez.
% University of Geneva.

addpath('Mex'); 
SAMPLE_XML_PATH='Config/SamplesConfig.xml';

% Start the Kinect Process
KinectHandles=mxNiCreateContext(SAMPLE_XML_PATH);

figure;
I=mxNiPhoto(KinectHandles);
I=permute(I,[3 2 1]);
% I=flipdim(I,2)
D=mxNiDepth(KinectHandles); 
D=permute(D,[2 1]);
% D=flipdim(D,2)

imwrite(I, 'rgb.png', 'png');
imwrite(D, 'depth.png', 'png');

subplot(1,2,1),h1=imshow(I);
subplot(1,2,2),h2=imshow(D,[0 9000]); colormap('jet');

% Stop the Kinect Process
mxNiDeleteContext(KinectHandles);