% *************************************************************************
% [Name]
% mxNiImage
% 
% [Function]
% Get rgb and depth image by Kinect
% 
% [Usage]
% [rgb, depth] = mxNiImage(context, option);
% 
% [Arguments]
% context
% The structure which includes object for acquiring images
% 
% option
% The structure for option 
%     option.adjust_view_point : The flag to adjust the position of the depth image 
%        option.adjust_view_point = true
%        Adjust the position of the depth image
%        option.adjust_view_point = false
%        Get depth image without adjustment the position the depth image
% 
% [Return]
% rgb
% RGB image
% 
% depth
% Depth image
% 
% [Sample]
% sample_niImage.m
% 