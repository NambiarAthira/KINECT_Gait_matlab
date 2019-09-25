%% A script that would display the input (rgb and depth) of Kinect.
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

f1 = figure;
I=mxNiPhoto(KinectHandles); I=permute(I,[3 2 1]);
D=mxNiDepth(KinectHandles); D=permute(D,[2 1]);

subplot(1,2,1),h1=imshow(I);  colormap(hsv);
subplot(1,2,2),h2=imshow(D,[0 9000]); colormap(hsv);

i = 1; % Frame number.

while(1)
    I=mxNiPhoto(KinectHandles); I=permute(I,[3 2 1]);
    D=mxNiDepth(KinectHandles); D=permute(D,[2 1]);
    mxNiUpdateContext(KinectHandles);
    
    set(h1,'CDATA',I); subplot(1,2,1); title(['RGB Image, Frame No.: ',num2str(i)]);
    set(h2,'CDATA',D); subplot(1,2,2); title(['Depth Image, Frame No.: ',num2str(i)]);
    
    cd(f_name);
    
    filename_I = [f_name num2str(temp) 'I' '.tif'];
    filename_D = [f_name num2str(temp) 'D' '.png'];
            
    drawnow;
    i = i + 1;
end

% Stop the Kinect Process
mxNiDeleteContext(KinectHandles);
