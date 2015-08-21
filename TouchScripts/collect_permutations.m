clear all
close all
dataroot = '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test';
addpath(genpath('/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/Permutations'));
addpath(genpath('/triton/becs/scratch/braindata/shared/toolboxes/bramila'))
%% Within permutation
subjects = {
'TouchActV5'
'obs3july'
'obs4july'
'obs7july'
'obs10july'
'obs15july'
'obs15may'
'obs16july'
'obs16may'
'obs22may'
'obs23june1'
'obs23june2'
'obs25july'
};
clear within
clear within_perm
for s = 1:length(subjects)
    masks = { 
%         sprintf('%s/%s/masks/painloc_thr2.nii',dataroot,subjects{s})
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/combined_loc_mask.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/fsl/ROIvalidation/FrontalPole.nii';
        '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/ACC.nii';
        '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/aINS.nii';
        '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/Amy.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/COMBINED.nii';
        '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/INS.nii';
        '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/ParaCC.nii';
        '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/pINS.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/S1.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/S2.nii';
        '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/Thalamus.nii';
    };
    for m = 1:length(masks)
        [pathstr,name,~] = fileparts(masks{m});
        temp = [];
        for p = 1:10
            pt = load(sprintf('%s/within/%s/%s/perms/%i.mat',dataroot,name,subjects{s},p-1));
            temp=cat(1,temp,pt.rate);            
        end
        within_perm(s,m,:) = temp;
        load(sprintf('%s/within/%s/%s/results.mat',dataroot,name,subjects{s}));
        within(s,m) = retval.accuracy;
    end
end
within_perm_vals = prctile(within_perm,95,3);
%% Grasp vs ACC
% data = cat(1,within(:,5),within(:,8))';
% design = cat(1,ones(size(within(:,5))),ones(size(within(:,8)))*2)';
% stats = bramila_ttest2_np(data,design,1000);
% stats.tvals
%% Grasp vs TC
% data = cat(1,within(:,6),within(:,8))';
% design = cat(1,ones(size(within(:,6))),ones(size(within(:,8)))*2)';
% stats = bramila_ttest2_np(data,design,1000);
% stats.tvals
%% Grasp vs FP
% data = cat(1,within(:,7),within(:,8))';
% design = cat(1,ones(size(within(:,7))),ones(size(within(:,8)))*2)';
% stats = bramila_ttest2_np(data,design,1000);
% stats.tvals


%% Between permutation
% tokennames
tokennames = {
'combined_loc_mask';
'FrontalPole';
'COMBINED';
};
senders = {
'TouchActV5'
};
receivers = {
'obs3july'
'obs4july'
'obs7july'
'obs10july'
'obs15july'
'obs15may'
'obs16july'
'obs16may'
'obs22may'
'obs23june1'
'obs23june2'
'obs25july'
};
clear between
clear between_perm
for s = 1:length(receivers)
    sender = senders{1};
    for t = 1:length(tokennames)
        temp = [];
        for p = 1:10
            pt = load(sprintf('%s/between/%s/%s/%s/perms/%i.mat',dataroot,tokennames{t},sender,receivers{s},p-1));
            temp = cat(1,temp,pt.rate);
        end
        between_perm(s,t,:) = temp;
        load(sprintf('%s/between/%s/%s/%s/results.mat',dataroot,tokennames{t},sender,receivers{s}));
        between(s,t) = retval.accuracy;
    end
end
between_permval = prctile(between_perm,95,3);
mean(between_permval,1)
for m = 1:length(tokennames)    
    data = cat(1,between_permval(:,m),between(:,m))';
    design = cat(1,ones(size(between_permval(:,m))),ones(size(between(:,m)))*2)';
    stats = bramila_ttest2_np(data,design,1000);
    es = mes(data(design==1),data(design==2),'hedgesg','nBoot',10000);
    sprintf('Mask %s , T: %i, Effect: %i',tokennames{m},stats.tvals,es.hedgesg)
%     sprintf('Mask %s , pval: %i, %i',tokennames{m},stats.pvals(1),stats.pvals(2))
end

%% Hyperclassification
clear hyper
clear hyper_perm
for s = 1:length(receivers)
    sender = senders{1};
    for t = 1:length(tokennames)
        temp = [];
        for p = 1:10
            pt = load(sprintf('%s/hyper/%s/%s/%s/perms/%i.mat',dataroot,tokennames{t},sender,receivers{s},p-1));
            temp = cat(1,temp,pt.rate);
        end
        hyper_perm(s,t,:) = temp;
        load(sprintf('%s/hyper/%s/%s/%s/results.mat',dataroot,tokennames{t},sender,receivers{s}));
        hyper(s,t) = retval.accuracy;
    end
end
hyper_permval = prctile(hyper_perm,95,3);
mean(hyper_permval,1)

%% ACC
% data = cat(1,hyper(:,2),hyper_permval(:,2))';
% design = cat(1,ones(size(hyper_permval(:,2))),ones(size(hyper_permval(:,2)))*2)';
% stats = bramila_ttest2_np(data,design,1000);
% stats.tvals
%% TC
% data = cat(1,hyper(:,3),hyper_permval(:,3))';
% design = cat(1,ones(size(hyper_permval(:,3))),ones(size(hyper_permval(:,3)))*2)';
% stats = bramila_ttest2_np(data,design,1000);
% stats.tvals
%% FP
% data = cat(1,hyper(:,4),hyper_permval(:,4))';
% design = cat(1,ones(size(hyper_permval(:,4))),ones(size(hyper_permval(:,4)))*2)';
% stats = bramila_ttest2_np(data,design,1000);
% stats.tvals








