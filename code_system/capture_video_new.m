%% A script that would save 3 seconds of input (rgb and depth) as an AVI
% video with no compression. The output files are located in the local
% folder with the names:
% rgb.avi for the RGB image. (RGB Colormap).
% depth.avi for the Depth image (8-bit GrayScale).
%
close all;
clear all;
clc

global BUTTON_CLICKED;

BUTTON_CLICKED = 0;

addpath('Mex'); 
SAMPLE_XML_PATH='Config/SamplesConfig.xml';

% Start the Kinect Process
KinectHandles=mxNiCreateContext(SAMPLE_XML_PATH);
mxNiChangeDepthViewPoint(KinectHandles); % For correspondence between depth and color

imageAVI= avifile('rgb.avi', 'COMPRESSION', 'None');   % Create a new AVI file
depthAVI= avifile('depth.avi', 'COMPRESSION', 'None');   % Create a new AVI file

prompt = {'Enter your name:', 'Enter your serial id:'};
dlg_title = 'Input for registration process';
num_lines = 1;
answer = inputdlg(prompt, dlg_title, num_lines); 
name_user = answer{1}; % Name of the user.
user_id = answer{2}; % ID of the user.


temp = 0;
f_name = num2str(user_id);
mkdir(f_name);

cd(f_name);
file = ['@' f_name] % Name of the mat file, to store the details.
save(file, 'name_user', 'user_id'); % Storing the given details.
cd 'C:\Users\athira\Desktop\Kinect_Softwares\knect_matlab';

fprintf('Acquiring video for the registration \n');



f1 = figure('ButtonDownFcn', @clicker);
I=mxNiPhoto(KinectHandles); I=permute(I,[3 2 1]); I=flipdim(I,2);
D=mxNiDepth(KinectHandles); D=permute(D,[2 1]); D=flipdim(D,2);

subplot(1,2,1),h1=imshow(I);  colormap(jet);
subplot(1,2,2),h2=imshow(D,[0 9000]); 

% t = timer('TimerFcn', 'cond = 0;','StartDelay',100);
% start(t)
% cond = 1;


while(1)
    F = im2frame(I);                    % Convert I to a movie frame
    
    a = double(D)/double(max(D(:)));
    a = uint8(a*255);
    FF = im2frame(a, gray(256));
    
    
    imageAVI = addframe(imageAVI,F);  % Add the frame to the AVI file
    depthAVI = addframe(depthAVI, FF);
        
    I=mxNiPhoto(KinectHandles); I=permute(I,[3 2 1]);I=flipdim(I,2);
    D=mxNiDepth(KinectHandles); D=permute(D,[2 1]); D=flipdim(D,2);
        
    mxNiUpdateContext(KinectHandles);
        
    set(h1,'CDATA',I);
    set(h2,'CDATA',D);
    drawnow;
    
    if (BUTTON_CLICKED == 1)
        
        break;
        
    end
    
end

imageAVI = close(imageAVI);         % Close the AVI file
depthAVI = close(depthAVI);

% Stop the Kinect Process
mxNiDeleteContext(KinectHandles);
% stop(t); delete(t);

% close all;

%% Read the frames
% 
% f_name
% vid='rgb.avi';
% readFrames_rgb( vid );
% vid='depth.avi';
% readFrames_depth( vid );

%% copy the video and frames to the subfolder

cd(f_name);
copyfile('C:\Users\athira\Desktop\Kinect_Softwares\knect_matlab\rgb.avi','rgb.avi')
copyfile('C:\Users\athira\Desktop\Kinect_Softwares\knect_matlab\depth.avi','depth.avi')
% movefile('C:\Users\athira\Desktop\Kinect_Softwares\knect_matlab\frame*')
% movefile('C:\Users\athira\Desktop\Kinect_Softwares\knect_matlab\rgbframe*')
%   
% msgbox('Done with video capturing ! Proceed to pcl_frames.m for resizing and allinging the pointclouds... ');
 

