function runSvdPca(dbpath)

%% Initializate environment and variables
global EIGENVALUES;
EIGENVALUES = 64;
info(['SVD-PCA analysis, k=' int2str(EIGENVALUES)], 2);

%% Load pre-calculated data
if loadData(dbpath) && checkVersion(dbpath); return; end

%% Run Principal Component Analysis on palmprint data
debug('Palmprint', 3);

% Run SVD-PCA to project train data vectors
matfile = [dbpath, filesep, 'db-data.mat'];
load(matfile, 'gait_trainData');
[gait_trainP V me] = doSvdPca(gait_trainData);
clear gait_trainData;

% Run SVD-PCA to project test data vectors
load(matfile, 'gait_testData');
gait_testP = doSvdPcaProj(gait_testData, V, me); %#ok<NASGU>
clear gait_testData; clear V; clear me; clear matfile;

%% Save data for future use
matfile = [dbpath, filesep, 'db-svdpca.mat'];
save(matfile, 'gait_trainP', 'gait_testP');

%% Run Principal Component Analysis on fingers data
% Run SVD-PCA to project train data vectors
% matfile = [dbpath, filesep, 'db-data.mat'];
% load(matfile, 'fingers_trainData');
% load(matfile, 'fingers_testData');
% fingers_trainP = [];
% fingers_testP = [];
% for i = 1:5, % for each finger
%     debug(['Fingers, i=' int2str(i)], 3);
%     fingerData = squeeze(fingers_trainData(:, i, :)); %#ok<COLND>
%     [trainP V me] = doSvdPca(fingerData);
%     fingers_trainP(:,:,i) = trainP; %#ok<AGROW>
% 
%     % Run SVD-PCA to project test data vectors
%     fingerData = squeeze(fingers_testData(:, i, :)); %#ok<COLND>
%     testP = doSvdPcaProj(fingerData, V, me); %#ok<NASGU>
%     fingers_testP(:,:,i) = testP; %#ok<AGROW>
% end
% clear fingers_trainData; clear fingers_testData; clear trainP; clear testP;
% clear V; clear me; clear matfile;

%% Save data for future use
% matfile = [dbpath, filesep, 'db-svdpca.mat'];
% save(matfile, '-append', 'fingers_trainP', 'fingers_testP');



%% --- Project data vectors using Principal Component Analysis.
%--------------------------------------------------------------------------
function [P V me] = doSvdPca(data)

global EIGENVALUES;

[N D] = size(data); %#ok<NASGU>
me = mean(data, 1);
data = double(data) - ones(N,1)*me; % mean subtracted data

k = EIGENVALUES; % number of singular values to find
[U S V] = svds(data, k); % singular value decompostion

P = data*V; % project the data using eigen vectors


%% --- Projects data vectors into given principal space.
%--------------------------------------------------------------------------
function P = doSvdPcaProj(data, V, me)

[N D] = size(data); %#ok<NASGU>
data = double(data) - ones(N,1)*me; % mean subtracted data

P = data*V; % project the data using eigen vectors


%% --- Load previously save data.
%--------------------------------------------------------------------------
function isOk = loadData(dbpath)

global TEMPLATE_SIZE;

% Get database template size
matfile = [dbpath, filesep, 'db-data.mat'];
load(matfile, 'gait_trainData');
templateSize = sqrt(size(gait_trainData, 2));
clear gait_trainData;

isOk = 0;

global FORCE; if FORCE == 1, return; end

% Try to load pre-calculated .mat file, if one exists
matfile = [dbpath, filesep, 'db-svdpca.mat'];
if exist(matfile, 'file'),
    previous_state = warning('off', 'MATLAB:load:variableNotFound');
    load(matfile, 'gait_trainP', 'gait_testP', 'fingers_trainP', 'fingers_testP');
    warning(previous_state);

    if exist('gait_trainP', 'var') && exist('gait_testP', 'var') && ...
       exist('fingers_trainP', 'var') && exist('fingers_testP', 'var') && ...
       (templateSize == TEMPLATE_SIZE),
        isOk = 1;
    end
end