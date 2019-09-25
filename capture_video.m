%% A script that would save 3 seconds of input (rgb and depth) as an AVI
% vdieo with no compression. The output files are located in the local
% folder with the names:
% rgb.avi for the RGB image. (RGB Colormap).
% depth.avi for the Depth image (8-bit GrayScale).
%
% Author: MOHAMMED, Sinan.
% Supervised by: Prof. Thierry Pun &  Juan Gomez.
% University of Geneva.
close all;
clear all;
clc

addpath('Mex'); 
SAMPLE_XML_PATH='Config/SamplesConfig.xml';

% Start the Kinect Process
KinectHandles=mxNiCreateContext(SAMPLE_XML_PATH);
mxNiChangeDepthViewPoint(KinectHandles); % For correspondence between depth and color

imageAVI= avifile('rgb.avi', 'COMPRESSION', 'None');   % Create a new AVI file
depthAVI= avifile('depth.avi', 'COMPRESSION', 'None');   % Create a new AVI file

figure;
I=mxNiPhoto(KinectHandles);
I=permute(I,[3 2 1]);I=flipdim(I,2);
D=mxNiDepth(KinectHandles);
D=permute(D,[2 1]);D=flipdim(D,2);
subplot(1,2,1),h1=imshow(I);  colormap(jet);
subplot(1,2,2),h2=imshow(D,[0 9000]); 


t = timer('TimerFcn', 'cond = 0;','StartDelay',10);
start(t)
cond = 1;

while(cond == 1)
    F = im2frame(I);                    % Convert I to a movie frame
    
    a = double(D)/double(max(D(:)));
    a = uint8(a*255);
    FF = im2frame(a, gray(256));
    
    imageAVI = addframe(imageAVI,F);  % Add the frame to the AVI file
    depthAVI = addframe(depthAVI, FF);
    
    I=mxNiPhoto(KinectHandles); I=permute(I,[3 2 1]);
    I=flipdim(I,2);
    D=mxNiDepth(KinectHandles); D=permute(D,[2 1]);
    D=flipdim(D,2);
    mxNiUpdateContext(KinectHandles);
    
    set(h1,'CDATA',I);
    set(h2,'CDATA',D);
    drawnow;
end

imageAVI = close(imageAVI);         % Close the AVI file
depthAVI = close(depthAVI);

% Stop the Kinect Process
mxNiDeleteContext(KinectHandles);
stop(t); delete(t);

% close all;