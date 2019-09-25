
close all;
clear all;
clc

%% @@@@@@@@@  PARAMETERS  @@@@@@@@@@@

% Reference plane and the reference centroid for each and every frame 
REF_POSITION=230;                                        % reference depth positon
REF_FRAME = 240;                                         % reference frame number 
BACK_FRAME= 9999;                                         % background frame number
Ref_Centre_X= 320;                                       % reference centroid x coordinate
Ref_Centre_Y= 240;                                       % reference centroid y coordinate
referenceFrame = sprintf('frame%d.png', REF_FRAME);      % reference depth frame
referencergbFrame=sprintf('rgbframe%d.png', REF_FRAME);  % reference rgb frame
backgroundFrame=sprintf('rgbframe%d.png', BACK_FRAME);   % background rgb frame 
width=30;                                                % standard width of a person in the reference position

%%%%%% feature extraction parameters 

%Point Cloud Density binning of the 3D cartesian co-ordinate system:
nBins1=80;                                               % no of bins along x axis 
nBins2=60;                                               % no of bins along y axis 
nBins3=60;                                               % no of bins along z axis 
nBins1_sph=510;
nBins2_sph=24*5;
nBins3_sph=12*5;
Density=zeros(nBins1,nBins2,nBins3);                     % Density matrix  initialization
Density_sph=zeros(nBins1_sph,nBins2_sph,nBins3_sph);

%% @@@@@@@@@@@@  ACQUIRE IMAGE FRAMES FOR PROCESSING @@@@@@@@@@@@@@@@@@

cd 'F:\PHD\codes\knect_matlab\CODE_SYSTEM\DB3\1\1_1';
addpath(genpath('F:\PHD\codes\knect_matlab\CODE_SYSTEM'))

pwd;
depth_imagefiles = dir('frame*.png');                   % get list of depth .png files in this directory
% [depth_imagefiles index]=qsort(depth_imagefiles,@compfunc);       % Sort in the descending order
noOfDepthFrames = length(depth_imagefiles);             % Number of depth files found
rgb_imagefiles = dir('rgbframe*.png');                  % Get list of rgb .png files in this directory
% [rgb_imagefiles index]=qsort(rgb_imagefiles,@compfunc);       % Sort in the descending order
noOfRgbFrames = length(rgb_imagefiles);                 % Number of rgb files found

%% @@@@@@@@@@@ PROCESS THE REFERENCE IMAGE @@@@@@@@@@@@@

% First, process the reference image
[final Z verticesX verticesY]=bsub(referenceFrame,referencergbFrame,backgroundFrame,width); % background subtraction
% [final Z verticesX verticesY]=bsub2 (referenceFrame,referencergbFrame,backgroundFrame,width); % background subtraction
[silhouette]=compositeMask(final,verticesX,verticesY,referencergbFrame,backgroundFrame);      % composite mask generation
Z_silhouette=Z.*silhouette;                                                                   % obtain the depth silhouette
[x y]=cent(Z_silhouette);                                                                     % centroid of the depth silhouette
ref_centIndex=Z_silhouette(y,x);

% Create the refImage from depth silhouette according to the standard size and positioning(REF_POSITION& Ref_centre).
ratio=ref_centIndex/REF_POSITION;                                                              % ratio of the depth silhouette centroid and that of the standard depth                
dist=REF_POSITION-ref_centIndex;                                                               % distance between the depth silhouette centroid and that of the standard depth   
resizedmatrix=imresize_old(Z_silhouette,ratio);                                                % depth silhouette is resized to the size of standard silhouette
[X00 Y00]=cent(resizedmatrix);
xshift=Ref_Centre_X-X00;
yshift=Ref_Centre_Y-Y00;
silhouette = circshift(resizedmatrix,[yshift xshift]);                                         % centroid of the depth silhouette is shifted to the standard reference centroid (Ref_Centre_X,Ref_Centre_Y)
[X0 Y0]=cent(silhouette);
Z=silhouette+(silhouette>0)*dist;                                                             % depth silhouette is shifted to the standard reference depth (REF_POSITION)
refImage = padarray(Z,[480-size(Z,1) 640-size(Z,2)],'post');                                  % pad zero array in order to make the image size as 480*640.


centIndex=refImage(Y0,X0);                                                                     % centroid index of the new depth silhouette
centre_x= X0;
centre_y= Y0 ;                                                                                 % reference Image frame silhouette for all the rest of image frames in this directory
ref_centIndex=refImage(centre_y,centre_x);


% imshow(silhouette),hold on,
% plot(centre_x,centre_y,'-m*');
% title(' Human silhouette extracted '); 

%%  @@@@@@@@@@@ PROCESS THE IMAGE FRAMES IN THE CURRENT DIRECTORY @@@@@@@@@@@@@

% Read gait frames in the current directory.  &&&&&&&&&&&&&&&&&&&&&&&&&&&&   ( NB :Keep the backgroundFrame as the last frame!!!)

for k =1:(noOfDepthFrames-1)

   testdepthFrame=depth_imagefiles(k).name;                                                     %Read the k'th depth frame
   testrgbFrame=rgb_imagefiles(k).name;                                                         %Read the corresponding k'th rgb frame
   [final Z verticesX verticesY] = bsub (testdepthFrame,testrgbFrame,backgroundFrame,width);   % background subtraction
   %[final Z verticesX verticesY] = bsub2 (testdepthFrame,testrgbFrame,backgroundFrame,width);   % background subtraction
   [silhouette]=compositeMask(final,verticesX,verticesY,testrgbFrame,backgroundFrame);          % composite mask generation
   silhouette=Z.*silhouette;                                                                    % obtain the depth silhouette
   [X0 Y0]=cent(silhouette);                                                                    % centroid of the depth silhouette
   
    centIndex=silhouette(Y0,X0);                                                                % centroid index of the k'th frame silhouette
    ratio=centIndex/ref_centIndex;                           
    dist=ref_centIndex-centIndex;                                                               % calculate the ratio and distances between the k'th frame silhouette and reference silhouette in order to do resizing.
  
    resizedmatrix=imresize_old(silhouette,ratio);                                               % k'th frame silhouette is resized to the size of reference silhouette
    [X00 Y00]=cent(resizedmatrix);
          
    [h{k} vari{k} mat sph]=pcl(k,resizedmatrix,centre_x,centre_y,dist,ref_centIndex,X00,Y00);       % point cloud generation for k'th frame silhouette
    file_name =[ 'frame' num2str(k)];
    save(file_name,'mat');                                                                      % the 3D silhouette info (x,y,z) is stored in .mat format 480*640*3 for cartesian co-ordinate system
        
    file_name =[ 'spherical' num2str(k)];
    save(file_name,'sph');                                                                      % the 3D silhouette info (ro,theta,phi) is stored in .mat format for spherical co-ordinate system

    p(k) = get(gca, 'Children');
    saveas(h{k}, ['frame' num2str(k) '.fig'])                                                   % 3D Kinect point cloud is stored in .fig format
     close
end
   
%%  @@@@@@@@@@@@ GAIT CYCLE EVALUATION @@@@@@@@@@@@@@@@@@@@@@@@@

vari=cell2mat(vari)                                                                             %Variance of human point cloud for each frame (gets a waveform corresponding to the gait)

[max]=filterr(vari)                                                                             % smoothens the wave using 'moving average filter'
prompt = {'Enter the no of gait cycles to be considered:'};                                     % Choose the appropriate no of gait cycles for feature description (1 gait cycle is the period among 3 consecutive peaks)
answer = inputdlg(prompt); 
answer=str2double(answer);
starting=max(length(max)-2*answer)                                                              % Gait period frame beginning
ending=max(length(max))                                                                         % Gait period frame ending
            
%             % Plot the voxel 3D human point cloud gait of one cycle 
%             figure, set(gcf,'name','Average point cloud','numbertitle','off')
%             
%             for k=starting:ending
%             new_handle = copyobj(p(k),gca);
%             end
%             
%             view(3),hold on,grid on;axis square,
%             set(gca,'XLim',[-80 0],'YLim',[-20 60],'ZLim',[0 250]);
%             view(90,90);
%             
%             % save the voxel model
%             saveas(new_handle, ['average' '.fig'])
%             close all;
%                                

%%  @@@@@@@@@@@@ POINTCLOUD DENSITY @@@@@@@@@@@@@@@@@@@@@@@@@

for k=starting:ending
 file_name =[ 'frame' num2str(k)];
 load (file_name,'mat');                                                                        % Load the 3D silhouette matrix info for each frame coming under the gait cycle
 file_name =[ 'spherical' num2str(k)];
 load (file_name,'sph'); 
 [D]=pclDensity(k,mat,nBins1,nBins2,nBins3);                                                    % Calculate the point cloud density in each bin in the 3d Cartesian coordinate system
 [D_sph]=sphericalDensity(k,sph,nBins1_sph,nBins2_sph,nBins3_sph);
 Density=Density+D;
 Density_sph=Density_sph+D_sph;
end

save('Density.mat','Density');                                                                  % PointCloud density in each bin over a gait cycle
save('Density_sph.mat','Density_sph');

load Density.mat
load Density_sph.mat

gc=ending-starting+1;                                                                            % length of gait cycle
Den=Density(31:50,21:40,41:55);
% Den=Density(35:44,23:38,43:52);
Den_sph=Density_sph(400:510,8:16,8:12);
siz_Den=size(Den,1)*size(Den,2)*size(Den,3);
siz_Den_sph=size(Den_sph,1)*size(Den_sph,2)*size(Den_sph,3);
D=Den/gc ;                                                                                        % PointCloud density normalized using 'gc'
D_sph=Den_sph/gc;  
D=reshape(D,1,siz_Den);
D_sph=reshape(D_sph,1,siz_Den_sph);
save('D.mat','D');  
save('D_sph.mat','D_sph');
% size(D)
% size(find(D~=0))

