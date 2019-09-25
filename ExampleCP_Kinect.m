addpath('Mex')
SAMPLE_XML_PATH='Config/SamplesConfig.xml';

% % Start the Kinect Process
% filename='Example/SkelShort.oni';
% KinectHandles=mxNiCreateContext(SAMPLE_XML_PATH,filename);
% 
% To use the Kinect hardware use :
KinectHandles=mxNiCreateContext(SAMPLE_XML_PATH);
mxNiChangeDepthViewPoint(KinectHandles);

% figure;
I=mxNiPhoto(KinectHandles); I=permute(I,[3 2 1]);
D=mxNiDepth(KinectHandles); D=permute(D,[2 1]);

% subplot(1,2,1),h1=imshow(I); 
% subplot(1,2,2),h2=imshow(D,[0 9000]); colormap('jet');


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


% figure,
% J=mxNiInfrared(KinectHandles); J=permute(J,[2 1]);
% h=imshow(J,[0 256]);
% 
% Start to Capture
% CaptureHandle=mxNiStartCapture(KinectHandles,'TestCapture.oni');

% Capture 10 Frames
for i=1:500
    
    figure(1),
    
    I=mxNiPhoto(KinectHandles); I=permute(I,[3 2 1]);
    
    D=mxNiDepth(KinectHandles); D=permute(D,[2 1]);
   
    
     if hit == 1
            
            fprintf('Acquiring images for the registration \n');
            hit = 0;
            
            temp = temp + 1;
            if temp == 5
                
                warndlg('5 Images for this user has already been registered','!! Message !!');
                return;
            
            end
               
            cd(f_name);
            
            filename_I = [f_name num2str(temp) 'I' '.tif'];
            filename_D = [f_name num2str(temp) 'D' '.png'];
            
            imwrite(I, filename_I); % Saving colored images.
            imwrite(D, filename_D,'png');  % Saving depth images.
            
%               imwrite(reshape(imgdata.palm.template, [128 128 3]), filename);
            
%             imwrite(reshape(imgdata.palm.template, [128 128 3]), filename);
            
            cd 'C:\Users\athira\Desktop\Kinect_Softwares\knect_matlab';
      end

                
%     else
%         
% %         fprintf('Hand is not present\n');
        subplot(1,2,1),imshow(I);
        subplot(1,2,2),imshow(D,[0 9000]);colormap('jet');
       
      
% %         hold on; plot([contour_error(:,2); contour_error(1,2)], [contour_error(:,1); contour_error(1,1)], 'b', 'LineWidth', 2); 
%         
%     end

%     hold on; plot([roipoints(:, 2); roipoints(1,2)], [roipoints(:, 1); roipoints(1,1)], 'r-', 'LineWidth', 2);
    mxNiUpdateContext(KinectHandles);
            
   
   
end



% Stop the Kinect Process
mxNiDeleteContext(KinectHandles);

 