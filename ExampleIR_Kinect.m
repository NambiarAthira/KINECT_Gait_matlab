addpath('Mex')
SAMPLE_XML_PATH='Config/SamplesIRConfig.xml';

% Start the Kinect Process
KinectHandles=mxNiCreateContext(SAMPLE_XML_PATH);
% mxNiChangeDepthViewPoint(KinectHandles);

% figure;
J=mxNiInfrared(KinectHandles); J=permute(J,[2 1]);
% h=imshow(J,[0 1024]); 

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
file = ['@' f_name]; % Name of the mat file, to store the details.
save(file, 'name_user', 'user_id'); % Storing the given details.
cd 'C:\Users\athira\Desktop\Kinect_Softwares\knect_matlab';

hit = 0;
f1 = figure('ButtonDownFcn','hit=1;');

for i=1:500
    figure(1),
    J=mxNiInfrared(KinectHandles); J=permute(J,[2 1]);
    
     if hit == 1
            
            fprintf('Acquiring images for the registration \n');
            hit = 0;
            
            temp = temp + 1;
            if temp == 5
                
                warndlg('5 IR Images for this user has already been registered','!! Message !!');
                return;
            
            end
               
            cd(f_name);
            
            filename_J = [f_name num2str(temp) 'I' '.tif'];
           
            imwrite(uint8(J), filename_J); % Saving IR images.
           
            
%               imwrite(reshape(imgdata.palm.template, [128 128 3]), filename);
            
%             imwrite(reshape(imgdata.palm.template, [128 128 3]), filename);
            
            cd 'C:\Users\athira\Desktop\Kinect_Softwares\knect_matlab';
     end
     
       imshow(J,[0 1024]);

    mxNiUpdateContext(KinectHandles);
   
end

% Stop the Kinect Process
mxNiDeleteContext(KinectHandles);

%%  In order to find out the difference of two images say, reference and measurement

% I1=(im2double(imread('C:\Users\athira\Desktop\Kinect_Softwares\knect_matlab\4\41I.tif')));
% I2=(im2double(imread('C:\Users\athira\Desktop\Kinect_Softwares\knect_matlab\5\51I.tif')));
% D=I2-I1;
% figure, 
% imshow(I1,[]); title('Measurement');
% figure,imshow(I2,[]); title('Reference');
% figure,imshow(D,[]); title('Difference');
