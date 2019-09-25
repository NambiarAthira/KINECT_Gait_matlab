% Global variable TAKE_SNAPSHOT is modified in the clicker function
% (clicker.m). Each time the user clicks on the grey border of the figure,
% the function clicker is executed and sets TAKE_SNAPSHOT to 1.
global TAKE_SNAPSHOT;

TAKE_SNAPSHOT = 0;
snapshots_taken = 0;
snapshots_required = 15;

root_folder = '.';
user_name = [];
user_id = [];
handness = [];


if (exist('last_registration_info.mat','file'))
    load('last_registration_info.mat');
end

root_folder = uigetdir(root_folder,'Select database folder');

prompt = {'Enter user ID:','Name:','Left or right hand? (L/R):'};
dlg_title = 'New user';
num_lines = 1;
def = {num2str(user_id),user_name,handness};
answer = inputdlg(prompt,dlg_title,num_lines,def);

if (~isempty(answer))
    user_id = str2num(answer{1});
    
    user_name = answer{2};
    % Replace spaces with underscores
    user_name(ismember(user_name,' ')) = '_';
    
    handness = upper(answer{3});
    
    if (handness == 'L')
                    
        full_handness = 'left';
                    
    end
    if (handness == 'R')
        
        full_handness = 'right';
        
    end
                    
end

if (~isempty(user_id))
   
    prompt = {'Is this format OK?'};
    dlg_title = 'New user';
    num_lines = 1;
    def = {sprintf('%.4d_%s',user_id,handness)};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    
    if (~isempty(answer))
        folder_format = answer{1};
        image_folder = [root_folder filesep 'images' filesep folder_format];
        roi_folder = [root_folder filesep 'ROI' filesep folder_format];
        mkdir(image_folder);
        mkdir(roi_folder);
        
        save('last_registration_info.mat','root_folder','user_name','user_id','handness');
    end
    
end

load('logitech-camera-parameters.mat','vid');
preview(vid);

pause(1);

f1 = figure('ButtonDownFcn', @clicker);

update_coeff = 0.05;
background_update_threshold = 3000;

struct_ele = strel('disk', 2);

previous_frame = [];
templates = [];

for z=1:1000

    im = getsnapshot(vid);
    
    if (isempty(previous_frame))
        ycbcr_img = rgb2ycbcr(im);
        ycbcr_backg = double(ycbcr_img);
        previous_frame = ycbcr_img;
        continue;
    end
    
    [foreground ycbcr_img] = background_subtraction_ycbcr(im, ycbcr_backg, struct_ele);

    clf;
    imshow(foreground);
    
    imgdata = preprocessImage_RT(foreground);
    error = imgdata.errorid;
    
    if (~error)
        
        fprintf('Found Hand!\n');
        
        [imgdata roipoints] = palmprintImage_RT(foreground,imgdata);
        
        error_palm = imgdata.palm.error;
        
        if (~error_palm)
           
            bad_roi = (imgdata.palm.template == 0);
            
            if (sum(bad_roi) == 0 && TAKE_SNAPSHOT)
                
                snapshots_taken = snapshots_taken + 1;
                
                fprintf('Snapshots taken: %d\n',snapshots_taken);
                
                templates = [templates; imgdata.palm.template];

                snapshot_name = [folder_format '_' sprintf('%.2d',snapshots_taken) '_' full_handness '.tif'];
                
                imwrite(reshape(imgdata.palm.template,[128 128]),[roi_folder filesep snapshot_name],'tif');
                imwrite(im,[image_folder filesep snapshot_name],'tif');
                
                figure,imshow(reshape(imgdata.palm.template,[128 128]));
                
                TAKE_SNAPSHOT = 0;
                
            end
            
        end
        
%         contour = imgdata.pre.contour;
        contour = imgdata.pre.contour/imgdata.pre.ratio;
        fp = imgdata.pre.points;
        
        figure(f1);
        hold on;
        plot([contour(:,2); contour(1,2)], [contour(:,1); contour(1,1)], 'r', 'LineWidth', 2);
        plot(contour(fp(1), 2), contour(fp(1), 1), 'd', 'MarkerFaceColor', 'y', 'MarkerSize', 6.5);
        plot(contour(fp(3), 2), contour(fp(3), 1), 's', 'MarkerFaceColor', 'g', 'MarkerSize', 6);
        plot(contour(fp(7), 2), contour(fp(7), 1), 's', 'MarkerFaceColor', 'g', 'MarkerSize', 6);
        plot(contour(fp(9), 2), contour(fp(9), 1), 'd', 'MarkerFaceColor', 'y', 'MarkerSize', 6.5);
        plot([roipoints(:, 2); roipoints(1,2)], [roipoints(:, 1); roipoints(1,1)], 'b-', 'LineWidth', 2);
        hold off;
        
    %let's see if there are any moving objects
    else
        
        binary = frame_difference_ycbcr(ycbcr_img, previous_frame);

        differences = sum(sum(binary));

        if (differences < background_update_threshold)

            ycbcr_backg = background_update(ycbcr_backg,ycbcr_img,update_coeff);

        end
        
    end
    
    drawnow;
    
    previous_frame = ycbcr_img;
    
    if (snapshots_taken == snapshots_required)
        
        fprintf('Acquired all images!\n');
        
        copyfile('unknown.jpg',[image_folder filesep '@' sprintf('%.4d',user_id) '_' user_name '_' full_handness '.jpg']);
        copyfile('unknown.jpg',[roi_folder filesep '@' sprintf('%.4d',user_id) '_' user_name '_' full_handness '.jpg']);
        
        register_templates(templates,user_name,full_handness);
        
        fprintf('Registration complete!\n');
        
        break;
        
    end

end

