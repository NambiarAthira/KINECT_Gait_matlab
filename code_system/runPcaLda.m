function runPcaLda(dbpath)

doPcaLda(dbpath);

%% --- PCA-LDA.
%--------------------------------------------------------------------------
function doPcaLda(dbpath)

global EIGENVALUES;
EIGENVALUES = 14;
info(['PCA-LDA analysis, k=' int2str(EIGENVALUES)], 1);

debug('Palmprint', 2);

%% Run Principal Component Analysis on palmprint data
% Run PCA to project train data vectors
matfile = [dbpath, filesep, 'db-data.mat'];
load(matfile, 'gait_trainData');
[PCA_gait_trainP V me] = doSvdPca(gait_trainData);
clear gait_trainData;

% Run PCA to project test data vectors
load(matfile, 'gait_testData');
PCA_gait_testP = doSvdPcaProj(gait_testData, V, me); 
clear gait_testData; clear V; clear me; clear matfile;

%% Run Linear Discriminant Analysis on palmprint data
% Load train labels
matfile = [dbpath, filesep, 'db-labels.mat'];
load(matfile, 'trainLabels');

% Run LDA to project PCA train data vectors
[gait_trainP V] = doLda(PCA_gait_trainP, trainLabels);
clear gait_trainData; clear trainLabels;

% Run LDA to project PCA test data vectors
gait_testP = doLdaProj(PCA_gait_testP, V); %#ok<NASGU>
clear gait_testData; clear V; clear PCA_gait_trainP; clear PCA_gait_testP;

%% Save data for future use
matfile = [dbpath, filesep, 'db-pcalda.mat'];
save(matfile, 'gait_trainP', 'gait_testP');
clear matfile;

%% Matching
% info('PCA-LDA matching', 1);
% debug('Palmprint', 2);
% [palmDistances_l1, palmDistances_l2, palmDistances_cos] = doClassify(palm_trainP, palm_testP);
% matfile_results = [dbpath, filesep, 'db-pcalda-results.mat'];
% save(matfile_results, 'palmDistances_l1', 'palmDistances_l2', 'palmDistances_cos');
% clear palm_trainP; clear palm_testP; clear matfile_results;
% 
% %% Classification
% info('PCA-LDA classification', 1);
% debug('Palmprint', 2);
% [palmRates_l1, palmRates_l2, palmRates_cos] = doDecision(dbpath, palmDistances_l1, palmDistances_l2, palmDistances_cos); %#ok<NASGU>
% matfile_rates = [dbpath, filesep, 'db-pcalda-rates.mat'];
% clear palmDistances_l1; clear palmDistances_l2; clear palmDistances_cos;
% 
% save(matfile_rates, 'palmRates_l1', 'palmRates_l2', 'palmRates_cos');
% clear palmRates_l1; clear palmRates_l2; clear palmRates_cos;
% 
% 
% 

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
    debug(['real k=' int2str(k)], 3);
end
V  = V(:,flipud(idx(1:k)));

P = double(data)*V; % project the data using eigen vectors



%% --- Projects data vectors into given principal space.
%--------------------------------------------------------------------------
function P = doLdaProj(data, V)

P = double(data)*V; % project the data using eigen vectors



%% --- Try to classify test set in train set.
%--------------------------------------------------------------------------
function [distances_l1, distances_l2, distances_cos] = doClassify(train, test)

% preallocate for speed
distances_l1 = zeros(size(test,1), size(train,1));
distances_l2 = zeros(size(test,1), size(train,1));
distances_cos = zeros(size(test,1), size(train,1));

for i = 1:size(test,1),
    for j = 1:size(train,1),
        distances_l1(i, j) = manhattan(test(i, :), train(j, :));
        distances_l2(i, j) = euclidean(test(i, :), train(j, :));
        distances_cos(i, j) = cosine(test(i, :), train(j, :));
    end
end



%% --- Decide on imposter/genuine user using thresholds.
%--------------------------------------------------------------------------
function [rates_l1, rates_l2, rates_cos] = doDecision(dbpath, distances_l1, distances_l2, distances_cos)

% Load labels
matfile = [dbpath, filesep, 'db-labels.mat'];
load(matfile, 'trainLabels', 'testLabels');

[far, frr, thresh, eer, eer_thresh, max_rate, max_thresh, pos] = doCalcRates(distances_l1, trainLabels, testLabels);
rates_l1.far = far; rates_l1.frr = frr; rates_l1.thresh = thresh;
rates_l1.eer = eer; rates_l1.eer_thresh = eer_thresh;
rates_l1.max_rate = max_rate; rates_l1.max_thresh = max_thresh;
rates_cos.max_far = far(pos); rates_cos.max_frr = frr(pos);
info(['Manhattan(L1) -> Max: ' num2str(max_rate) '%%, FAR: ' num2str(far(pos)) ...
      '%%, FRR: ' num2str(frr(pos)) '%%, EER: ' num2str(eer) '%%'], 4);

[far, frr, thresh, eer, eer_thresh, max_rate, max_thresh, pos] = doCalcRates(distances_l2, trainLabels, testLabels);
rates_l2.far = far; rates_l2.frr = frr; rates_l2.thresh = thresh;
rates_l2.eer = eer; rates_l2.eer_thresh = eer_thresh;
rates_l2.max_rate = max_rate; rates_l2.max_thresh = max_thresh;
rates_cos.max_far = far(pos); rates_cos.max_frr = frr(pos);
info(['Euclidean(L2) -> Max: ' num2str(max_rate) '%%, FAR: ' num2str(far(pos)) ...
      '%%, FRR: ' num2str(frr(pos)) '%%, EER: ' num2str(eer) '%%'], 4);

[far, frr, thresh, eer, eer_thresh, max_rate, max_thresh, pos] = doCalcRates(distances_cos, trainLabels, testLabels);
rates_cos.far = far; rates_cos.frr = frr; rates_cos.thresh = thresh;
rates_cos.eer = eer; rates_cos.eer_thresh = eer_thresh;
rates_cos.max_rate = max_rate; rates_cos.max_thresh = max_thresh;
rates_cos.max_far = far(pos); rates_cos.max_frr = frr(pos);
info(['Cosine -> Max: ' num2str(max_rate) '%%, FAR: ' num2str(far(pos)) ...
      '%%, FRR: ' num2str(frr(pos)) '%%, EER: ' num2str(eer) '%%'], 4);



%% --- Show performance rates.
%--------------------------------------------------------------------------
function [far, frr, thresh, eer, eer_thresh, max_rate, max_thresh, pos] = doCalcRates(distances, trainLabels, testLabels)

total_users = size(testLabels, 2);

thresh_min = min(min(distances));
thresh_max = max(max(distances));

far = [];
frr = [];
max_correct = [];
thresh = [];

steps = 100;

for i = thresh_min:(thresh_max-thresh_min)/steps:thresh_max,

    correct_match = 0;
    false_acceptance = 0;
    correct_rejection = 0;
    false_rejection = 0;

    for j = 1:size(testLabels,2),
        [value, idx] = min(distances(j,:));
        correct = strcmp(trainLabels(idx), testLabels(j));
        below_thresh = (value <= i);
        labelidx = strmatch(testLabels(j), trainLabels, 'exact');

        if below_thresh && correct,
            % Correct Match
            correct_match = correct_match + 1;
        elseif below_thresh && ~correct,
            % False Acceptance
            false_acceptance = false_acceptance + 1;
        elseif ~below_thresh && isempty(labelidx),
            % Correct Rejection
            correct_rejection = correct_rejection + 1;
        elseif ~below_thresh && ~isempty(labelidx)
            % False Rejection
            false_rejection = false_rejection + 1;
        end
    end

    far = [far 100*false_acceptance/total_users]; %#ok<AGROW>
    frr = [frr 100*false_rejection/total_users]; %#ok<AGROW>
    max_correct = [max_correct 100*(correct_match+correct_rejection)/total_users]; %#ok<AGROW>
    thresh = [thresh i]; %#ok<AGROW>
end

% Find EER
pos = find(far == frr, 1, 'first');
if isempty(pos),
    % Find intersection to approximate EER value and its threshold
    x1 = find(far < frr, 1, 'last');
    x2 = find(far > frr, 1, 'first');
    y1 = far(x1); y2 = far(x2);
    y3 = frr(x1); y4 = frr(x2);
    x3 = x1; x4 = x2;

    a = x1*y2-x2*y1;
    b = x3*y4-x4*y3;
    denom = (x1-x2)*(y3-y4)-(x3-x4)*(y1-y2);

    eer = (a*(y3-y4)-b*(y1-y2))/denom; % y
    x = (a*(x3-x4)-b*(x1-x2))/denom; % x
    eer_thresh = (x-x1)*(thresh(x2)-thresh(x1)) + thresh(x1);

else
    eer = far(pos);
    eer_thresh = thresh(pos);
end

% Find Max Correct Rate
max_rate = max(max_correct);
pos = find(max_correct == max_rate, 1, 'first');
max_thresh = thresh(pos);

% figure; plot(thresh, far, 'Color','b','LineWidth',4);
% hold on; plot(thresh, frr, 'Color','r','LineWidth',4);
% hold on; plot(thresh, max_correct, 'Color','g','LineWidth',4);
% title('Performance Measures', 'FontName', 'Verdana', 'FontWeight', 'bold');
% xlabel('Threshold', 'FontName', 'Verdana');
% ylabel('%', 'FontName', 'Verdana');
% legend('FAR','FRR', 'Correct Authentications');
% text(eer_thresh, eer, ['\leftarrowEER=' num2str(eer, '%0.2f') '% (thresh=' num2str(eer_thresh, '%0.2f') ')']);
% text(max_thresh, max_rate, ['\leftarrowMax=' num2str(max_rate, '%0.2f') '% (thresh=' num2str(max_thresh, '%0.2f') ')']);
% axis([min(thresh) max(thresh) 0 100]);
