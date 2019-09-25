% Receveis the path to a .mat file, which must include hand geometry
% features, i.e., gait_trainData and gait_testData

function [cumulative_rank,cum_rank] = gait_cumulative(dbpath)

load([dbpath filesep 'db-svdpca.mat']);
load([dbpath filesep 'db-labels.mat']);

% gait_train = gait_trainData;
% gait_test = gait_testData;

gait_train = gait_trainP;
gait_test = gait_testP;

num_users = size(gait_train,1);

cumulative_rank = zeros(num_users,1);

for z=1:size(gait_test,1)

    gait_rcv = gait_test(z,:);

    scores = zeros(num_users,1);

    tic;

    for i=1:num_users
    
        scores(i) = euclidean(gait_train(i,:),gait_rcv);
        
    end
    
    toc;
    
    [~, ind] = sort(scores);
    
    for i=1:length(ind)
       
        if (strcmp(trainLabels{ind(i)},testLabels{z}))
        
            cumulative_rank(i) = cumulative_rank(i) + 1;
            break;
            
        end
        
    end
    
end

cum_rank = zeros(num_users,1);

for i=1:length(cumulative_rank)
   
    cum_rank(i) = sum(cumulative_rank(1:i))/size(gait_test,1);
    
end

x = 1:num_users;
cum_rank = cum_rank(1:num_users)*100;

handle = plot(x,cum_rank,'r*');
xlabel('Cumulative Rank');
ylabel('Recognition Rate (%)');

grid