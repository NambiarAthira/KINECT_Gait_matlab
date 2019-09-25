function runLda(dbpath)

global TEMPLATE_SIZE;
 TEMPLATE_SIZE = 40;
% if (TEMPLATE_SIZE == 128) || (TEMPLATE_SIZE == 256), return; end

%% Initializate environment and variables
global EIGENVALUES;
 EIGENVALUES = 1600;
% info(['LDA analysis, k=' int2str(EIGENVALUES)], 2);

%% Load pre-calculated data
% if loadData(dbpath) && checkVersion(dbpath); return; end

%% Run Linear Discriminant Analysis on palmprint data
% debug('Palmprint', 3);

% Load train labels
matfile = [dbpath, filesep, 'db-labels.mat'];
load(matfile, 'trainLabels');

% Run LDA to project train data vectors
matfile = [dbpath, filesep, 'db-data.mat'];
load(matfile, 'gait_trainData');
[gait_trainP V] = doLda(gait_trainData, trainLabels);
clear gait_trainData;

% Run LDA to project test data vectors
load(matfile, 'gait_testData');
gait_testP = doLdaProj(gait_testData, V);
clear gait_testData; clear V; clear matfile;

%% Save data for future use
matfile = [dbpath, filesep, 'db-lda.mat'];
save(matfile, 'gait_trainP', 'gait_testP');

%% Run Linear Discriminant Analysis on fingers data
% Run LDA to project train data vectors
% matfile = [dbpath, filesep, 'db-data.mat'];
% load(matfile, 'fingers_trainData');
% load(matfile, 'fingers_testData');
% fingers_trainP = [];
% fingers_testP = [];
% for i = 1:5, % for each finger
%     debug(['Fingers, i=' int2str(i)], 3);
%     fingerData = squeeze(fingers_trainData(:, i, :)); 
%     [trainP V] = doLda(fingerData, trainLabels);
%     fingers_trainP(:,:,i) = trainP; %#ok<AGROW>
% 
%     % Run LDA to project test data vectors
%     fingerData = squeeze(fingers_testData(:, i, :)); 
%     testP = doLdaProj(fingerData, V); 
%     fingers_testP(:,:,i) = testP; %#ok<AGROW>
% end
% clear fingers_trainData; clear fingers_testData; clear trainP; clear testP;
% clear V; clear me; clear matfile;
% 
% %% Save data for future use
% matfile = [dbpath, filesep, 'db-lda.mat'];
% save(matfile, '-append', 'fingers_trainP', 'fingers_testP');



%% --- Project data vectors using Linear Discriminant Analysis.
%--------------------------------------------------------------------------
function [P V] = doLda(data, labels)

global EIGENVALUES;

templateSize = size(data,2);
Sw = zeros(templateSize, templateSize); % preallocate within class scatter matrix
Sb = zeros(templateSize, templateSize); % preallocate between class scatter matrix

me = mean(data, 1); % total mean

classLabels = unique(labels); % TODO: Sould optimize 'unique', but...
for i = 1:length(classLabels),
    idx = strmatch(classLabels(i), labels); % TODO: Sould optimize 'strmatch', but...
%     idx = classLabels(i) == labels;
    classData = data(idx, :);
    classMe = mean(classData, 1); % class mean

    [N D] = size(classData); %#ok<NASGU>
    classData = double(classData) - ones(N,1)*classMe; % mean subtracted class data
    classScatter = classData'*classData;

    Sw = Sw + classScatter;

    deviation = classMe - me;
    Sb = Sb + i*deviation'*deviation;
end

[V S] = eig(Sb, Sw); % calculate eigenvalues
s = diag(S);
[y,ind] = sort(abs(s));
idx = flipud(ind);
k = EIGENVALUES; % number of highest eigenvectors to use
k = min(k, length(idx));
if k ~= EIGENVALUES,
    debug(['real k=' int2str(k)], 4);
end
V  = V(:,flipud(idx(1:k)));

P = double(data)*V; % project the data using eigen vectors



%% --- Projects data vectors into given principal space.
%--------------------------------------------------------------------------
function P = doLdaProj(data, V)

P = double(data)*V; % project the data using eigen vectors


%% --- Load previously save data.
%--------------------------------------------------------------------------
function isOk = loadData(dbpath)

global TEMPLATE_SIZE;

% Get database template size
matfile = [dbpath, filesep, 'db-data-16x16.mat'];
load(matfile, 'palm_trainData');
templateSize = sqrt(size(palm_trainData, 2));
clear palm_trainData;

isOk = 0;

global FORCE; if FORCE == 1, return; end

% Try to load pre-calculated .mat file, if one exists
matfile = [dbpath, filesep, 'db-lda.mat'];
if exist(matfile, 'file'),
    previous_state = warning('off', 'MATLAB:load:variableNotFound');
    load(matfile, 'palm_trainP', 'palm_testP');
    warning(previous_state);

    if exist('palm_trainP', 'var') && exist('palm_testP', 'var') && ...
       (templateSize == TEMPLATE_SIZE),
        isOk = 1;
    end
end