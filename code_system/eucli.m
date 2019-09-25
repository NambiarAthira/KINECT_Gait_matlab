for i=1:20
for j=1:4
euc_distances(j,i) = euclidean(mu(j,:),P(i,:));
end
end
save('euc_distances_pca.mat','euc_distances')
% 
% for i=1:20
% for j=1:4
% euc_distances(j,i) = euclidean(gait_trainP(j,:),gait_testP(i,:));
% end
% end
% save('euc_distances_pca.mat','euc_distances')

euc_distances
[~,ii] = min(euc_distances);
position_pq = [1:size(euc_distances,2);ii]