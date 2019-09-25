function [ frame ] = readFrames_rgb( vid )
% vid='rgb.avi'
readerobj = mmreader(vid);
mplay(vid)
% vidFrames = read(readerobj);
numFrames = get(readerobj,'numberOfFrames')

for k = 1 : numFrames
    mov(k).cdata = read(readerobj,k);
    mov(k).colormap = [];
    %imshow(mov(k).cdata);
    imagename=strcat(int2str(k), '.png');
    imwrite(mov(k).cdata, strcat('rgbframe',imagename));
    %extractComponents(mov(k).cdata);
end
end




% 
% vid='depth.avi'
% readerobj = mmreader(vid);
% % mplay(vid);
% vidFrames = read(readerobj);
% numFrames = get(readerobj, 'numberOfFrames');
% 
% for k = 1 : numFrames
% mov(k).cdata = vidFrames(:,:,k);
% %mov(k).cdata = read(readerobj,k);
% mov(k).colormap = [];
% %imshow(mov(k).cdata);
% imagename=strcat(int2str(k), '.png');
% imwrite(mov(k).cdata, strcat('ammu',imagename));
% %extractComponents(mov(k).cdata);
% 
% end
% 
