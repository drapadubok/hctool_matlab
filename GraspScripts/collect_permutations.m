clear all
close all
dataroot = '/triton/becs/scratch/braindata/shared/GraspHyperScan';
addpath(genpath('/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/Permutations'));
addpath(genpath('/triton/becs/scratch/braindata/shared/toolboxes/bramila'))
%% Within permutation
subjects = {
'Sonya_Actor';
'Fanny_Actor';
'Sonya_Observer';
'Sonya_Observer_2';
'Sonya_Observer_3';
'Sonya_Observer_4';
'Sonya_Observer_5';
'Sonya_Observer_6';
'Sonya_Observer_7';
'Sonya_Observer_8';
'Sonya_Observer_9';
'Sonya_Observer_10';
'Sonya_Observer_11';            
'Fanny_Observer';
'Fanny_Observer_1';
'Fanny_Observer_2';
'Fanny_Observer_3'
};
clear within
clear within_perm
for s = 1:length(subjects)
    masks = { 
        '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/LOC.nii';
        '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/MOTOR.nii';
        sprintf('/triton/becs/scratch/braindata/shared/GraspHyperScan/%s/masks/motorloc_V1.nii',subjects{s});
        sprintf('/triton/becs/scratch/braindata/shared/GraspHyperScan/%s/masks/obsloc_contrast_V1.nii',subjects{s});
        '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/fsl/ROIvalidation/cingulum/cingularROI.nii';
        '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/fsl/ROIvalidation/temporal/temporalROI.nii';
        '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/fsl/ROIvalidation/FrontalPole.nii';
        '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/ns/grasp.nii';
    };
    for m = 1:length(masks)
        [pathstr,name,~] = fileparts(masks{m});
        temp=load(sprintf('%s/within/%s/%s/perms2.mat',dataroot,name,subjects{s}));
        within_perm(s,m,:) = temp.rate;
        load(sprintf('%s/within/%s/%s/results.mat',dataroot,name,subjects{s}));
        within(s,m) = retval.accuracy;
    end
end
within_perm_vals = prctile(within_perm,95,3);
%% Grasp vs ACC
data = cat(1,within(:,5),within(:,8))';
design = cat(1,ones(size(within(:,5))),ones(size(within(:,8)))*2)';
stats = bramila_ttest2_np(data,design,1000);
stats.tvals
%% Grasp vs TC
data = cat(1,within(:,6),within(:,8))';
design = cat(1,ones(size(within(:,6))),ones(size(within(:,8)))*2)';
stats = bramila_ttest2_np(data,design,1000);
stats.tvals
%% Grasp vs FP
data = cat(1,within(:,7),within(:,8))';
design = cat(1,ones(size(within(:,7))),ones(size(within(:,8)))*2)';
stats = bramila_ttest2_np(data,design,1000);
stats.tvals


%% Between permutation
% tokennames
tokennames = {
% 'MOTOR';
% 'LOC';
'grasp';
'CingularCortex';
'FrontalPole';
'TemporalCortex';
'OverlapLocalizer';
};
senders = {
'Sonya_Actor';
'Fanny_Actor'
};
receivers = {
'Sonya_Observer';
'Sonya_Observer_2';
'Sonya_Observer_3';
'Sonya_Observer_4';
'Sonya_Observer_5';
'Sonya_Observer_6';
'Sonya_Observer_7';
'Sonya_Observer_8';
'Sonya_Observer_9';
'Sonya_Observer_10';
'Sonya_Observer_11';
'Fanny_Observer';
'Fanny_Observer_1';
'Fanny_Observer_2';
'Fanny_Observer_3';
};
clear between
clear between_perm
for s = 1:length(receivers)
    if s < 12
        sender = senders{1};
    else
        sender = senders{2};
    end
    for t = 1:length(tokennames)
        temp = load(sprintf('%s/between/%s/%s/%s/perms2.mat',dataroot,tokennames{t},sender,receivers{s}));
        between_perm(s,t,:) = temp.rate;
        load(sprintf('%s/between/%s/%s/%s/results.mat',dataroot,tokennames{t},sender,receivers{s}));
        between(s,t) = retval.accuracy;
    end
end
between_permval = prctile(between_perm,95,3);
for m = 1:length(tokennames)
    m=1;
    m=2;
    m=3;
    m=4;
    m=5;
    data = cat(1,between_permval(:,m),between(:,m))';
    design = cat(1,ones(size(between_permval(:,m))),ones(size(between(:,m)))*2)';
    stats = bramila_ttest2_np(data,design,1000);
    es = mes(data(design==1),data(design==2),'hedgesg','nBoot',10000);
    es.hedgesg
    stats.tvals
%     sprintf('Mask %s , T: %i, Effect: %i',tokennames{m},stats.tvals,es.hedgesg)
end

%% Hyperclassification
clear hyper
clear hyper_perm
for s = 1:length(receivers)
    if s < 12
        sender = senders{1};
    else
        sender = senders{2};
    end
    for t = 1:length(tokennames)
        temp=load(sprintf('%s/hyper/%s/%s/%s/perms2.mat',dataroot,tokennames{t},sender,receivers{s}));
        hyper_perm(s,t,:) = temp.rate;
        load(sprintf('%s/hyper/%s/%s/%s/results.mat',dataroot,tokennames{t},sender,receivers{s}));
        hyper(s,t) = retval.accuracy;
    end
end
hyper_permval = prctile(hyper_perm,95,3);

%% ACC
data = cat(1,hyper(:,2),hyper_permval(:,2))';
design = cat(1,ones(size(hyper_permval(:,2))),ones(size(hyper_permval(:,2)))*2)';
stats = bramila_ttest2_np(data,design,1000);
stats.tvals
%% TC
data = cat(1,hyper(:,3),hyper_permval(:,3))';
design = cat(1,ones(size(hyper_permval(:,3))),ones(size(hyper_permval(:,3)))*2)';
stats = bramila_ttest2_np(data,design,1000);
stats.tvals
%% FP
data = cat(1,hyper(:,4),hyper_permval(:,4))';
design = cat(1,ones(size(hyper_permval(:,4))),ones(size(hyper_permval(:,4)))*2)';
stats = bramila_ttest2_np(data,design,1000);
stats.tvals








