clear all
close all
dataroot = '/triton/becs/scratch/braindata/shared/GraspHyperScan';
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
clear meanacc
for s = 1:length(subjects)
    masks = {
        '/triton/becs/scratch/braindata/shared/GraspHyperScan/SomeMasksFromJulich/whole_GM.nii';        
        sprintf('/triton/becs/scratch/braindata/shared/GraspHyperScan/%s/masks/motorloc_V1.nii',subjects{s});
        sprintf('/triton/becs/scratch/braindata/shared/GraspHyperScan/%s/masks/obsloc_contrast_V1.nii',subjects{s});
        '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/fsl/ROIvalidation/cingulum/cingularROI.nii';
        '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/fsl/ROIvalidation/temporal/temporalROI.nii';
        '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/fsl/ROIvalidation/FrontalPole.nii';
        '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/ns/grasp.nii';
    };
    for m = 1:length(masks)
        [pathstr,name,~] = fileparts(masks{m});
        temp=load(sprintf('%s/within/perms_mvla_%s_%s.txt',dataroot,name,subjects{s}));
        maskpermwithin(s,m,:) = mean(temp);
        load(sprintf('%s/within/%s/%s/results.mat',dataroot,name,subjects{s}));
        meanacc(s,m) = retval.accuracy;
    end
end
for m = 1:length(masks)
    p(m,1) = ranksum(maskpermwithin(:,m),meanacc(:,m));
end
% use maskpermwithin to compare performance
%% Between permutation
% tokennames
tokennames = {
'Whole'
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
clear meanacc
for s = 1:length(receivers)
    if s < 12
        sender = senders{1};
    else
        sender = senders{2};
    end
    for t = 1:length(tokennames)
        temp=load(sprintf('%s/between/%s/%s/%s/perms.txt',dataroot,tokennames{t},sender,receivers{s}));
        maskpermbetween(s,t,:) = mean(temp);
        load(sprintf('%s/between/%s/%s/%s/results.mat',dataroot,tokennames{t},sender,receivers{s}));
        meanacc(s,t) = retval.accuracy;
    end
end
for t = 1:length(tokennames)
    p(t,1) = ranksum(maskpermbetween(:,t),meanacc(:,t));
end
%% Hyperclassification
tokennames = {
'Motor-to-Observation_Combined_thresholded';
'Motor-to-Observation_V1';
'Whole';
'grasp';
'CingularCortex';
'FrontalPole';
'TemporalCortex';
'OverlapLocalizer'
};
for s = 1:length(receivers)
    if s < 12
        sender = senders{1};
    else
        sender = senders{2};
    end
    for t = 1:length(tokennames)
        temp=load(sprintf('%s/hyper/%s/%s/%s/permsCCAshuffle.txt',dataroot,tokennames{t},sender,receivers{s}));
        maskpermhyper(s,t,:) = mean(temp);
        load(sprintf('%s/hyper/%s/%s/%s/results.mat',dataroot,tokennames{t},sender,receivers{s}));
        meanacc(s,t) = retval.accuracy;
    end
end
for t = 1:length(tokennames)
    p(t,1) = ranksum(maskpermhyper(:,t),meanacc(:,t));
end
%%
%%
%%




















