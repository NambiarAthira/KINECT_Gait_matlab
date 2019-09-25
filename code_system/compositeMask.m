function [silhouette]=compositeMask(final,verticesX,verticesY,testrgbFrame,backgroundFrame)

%[final X0 Y0 centIndex verticesX verticesY]=bsub4 (testdepthFrame,testrgbFrame,backgroundFrame,width)
%figure,set(gcf, 'Position', get(0,'Screensize'));

final=final>0;                              % Final is the output from the function bsub- human silhouette in RGB space
final(:,1:verticesX(1))=0;
final(:,verticesX(2):end)=0;
final(1:verticesY(1),:)=0;
final(verticesY(3):end,:)=0;

% subplot(1,3,1)
% imshow(final),hold on,
% plot(verticesX, verticesY, 'r-', 'LineWidth', 2);
% plot(X0,Y0,'-m*');
% title(' Human mask generated by background subtracton')

mid=round((((verticesY(3)-verticesY(1))*2/3))+verticesY(1));
weight1=ones(size(final));
weight1(mid+1:end,:)=0;

final=final.*weight1;


[outim]=chromaticity(testrgbFrame,backgroundFrame);  % human silhouette in chromaticity space
outim(:,1:verticesX(1))=0;
outim(:,verticesX(2):end)=0;
outim(1:verticesY(1),:)=0;
outim(verticesY(3):end,:)=0;

% imshow(outim),hold on,
% plot(X0,Y0,'-m*');
% plot(verticesX, verticesY, 'r-', 'LineWidth', 2);
% title(' Human chromaticity mask ')
% 
weight2=ones(size(outim));
weight2(1:mid-1,:)=0;

outim=outim.*weight2;



silhouette=final+outim;                             % Combine human silhouettes in RGB space and chromaticity space
% silhouette=final2.*silhouette;
% subplot(1,3,3)

% The centroid of the silhouette image
end