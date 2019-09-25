%% A script that would display the input (rgb and depth) of Kinect with the
% edges too.
% The output is a figure of two subplots corresponding to the RGB image and
% the depth image.
%
% Author: MOHAMMED, Sinan.
% Supervised by: Prof. Thierry Pun &  Juan Gomez.
% University of Geneva.

addpath('Mex')
SAMPLE_XML_PATH='Config/SamplesConfig.xml';

% Start the Kinect Process
KinectHandles=mxNiCreateContext(SAMPLE_XML_PATH);

f1 = figure;
I=mxNiPhoto(KinectHandles); I=permute(I,[3 2 1]);
D=mxNiDepth(KinectHandles); D=permute(D,[2 1]);
II = edge(rgb2gray(I), 'canny');
II = uint8(II*255 + double(rgb2gray(I)));
DD = edge(D, 'canny');
DD = DD + double(D/max(D(:)));

subplot(2,2,1),h1=imshow(I);  %colormap(hsv);
subplot(2,2,2),h2=imshow(D,[0 9000]); %colormap(hsv);
subplot(2,2,3),h3 = imshow(II); 
subplot(2,2,4),h4 = imshow(DD,[]);
i = 1; % Frame number.

while(1)
    I=mxNiPhoto(KinectHandles); I=permute(I,[3 2 1]);
    D=mxNiDepth(KinectHandles); D=permute(D,[2 1]);
    II = edge(rgb2gray(I), 'canny');
    II = uint8(II*255 + double(rgb2gray(I)));
    DD = edge(D, 'canny');
    DD = DD + double(D/max(D(:)));

    mxNiUpdateContext(KinectHandles);
    
    set(h1,'CDATA',I); subplot(2,2,1); title(['RGB Image, Frame No.: ',num2str(i)]);
    set(h2,'CDATA',D); subplot(2,2,2); title(['Depth Image, Frame No.: ',num2str(i)]);
    set(h3, 'CDATA', II);
    set(h4, 'CDATA', DD);
    
    drawnow;
    i = i + 1;
end

% Stop the Kinect Process
mxNiDeleteContext(KinectHandles);