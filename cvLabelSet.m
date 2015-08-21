function [x,xt,y,yt] = cvLabelSet(labels,data,c,cv,n_per_run)
% labels - all labels for all timepoints Tx1
% data - data TxV, dO
% c - category 
% cv - cv fold
% n_per_run - how many samples in one cv
% Returns data and labels parsed for one vs all
% Also groups them [1;2]
%% 
% selector labels
train_sel = ones(size(labels));
test_sel = zeros(size(labels));
train_sel((1:n_per_run) + (cv-1)*n_per_run) = 0;
test_sel((1:n_per_run) + (cv-1)*n_per_run) = 1;
% handle labels to get one vs all class
ltemp = find(labels==c); % find indices of class of interest
otemp = find(labels~=c); % find all other
% assign new labels
ytemp = zeros(size(labels));
ytemp(ltemp) = 1;
ytemp(otemp) = 2;
% tricky part, assign to x: first the data corresponding to first class and
% training set, then data corresponding to second class and training sey
% x = [data((ytemp == 1&train_sel==1),:); data((ytemp == 2&train_sel==1),:)];
% xt = [data((ytemp == 1&test_sel==1),:); data((ytemp == 2&test_sel==1),:)];
% y = [ones(length(find(ytemp == 1&train_sel==1)),1); ones(length(find(ytemp == 2&train_sel==1)),1).*2];
% yt = [ones(length(find(ytemp == 1&test_sel==1)),1); ones(length(find(ytemp == 2&test_sel==1)),1).*2];
% 
x = data(find(train_sel),:);
xt = data(find(test_sel),:);
y = ytemp(find(train_sel));
yt = ytemp(find(test_sel));
