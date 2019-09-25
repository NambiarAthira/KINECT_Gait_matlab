function [x,y]=cent(image)
[row col]= find(logical(image~=0));
pixels=[row col];
y=floor(mean(pixels(:,1)))
x=floor(mean(pixels(:,2)))
end