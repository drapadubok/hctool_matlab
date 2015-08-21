clear all
close all
addpath(genpath('/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/MVLA'));
addpath('/triton/becs/scratch/braindata/shared/toolboxes/cbrewer');
addpath('/triton/becs/scratch/braindata/shared/toolboxes/NIFTI');
addpath('/triton/becs/scratch/braindata/shared/toolboxes/spm8_masking_removed/')
addpath('/triton/becs/scratch/braindata/shared/toolboxes/export_fig');
dataroot = '/triton/becs/scratch/braindata/shared/GraspHyperScan';
% token names
tokennames = {
'grasp';
'OverlapLocalizer';
'CingularCortex';
'FrontalPole';
'TemporalCortex';
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
% 'Surro';
};
%% Hyper
clear meanacc
clear confmat
clear mean_acc_mask
for s = 1:length(receivers)
    if s < 12
        sender = senders{1};
    else
        sender = senders{2};
    end
    subject = receivers{s};    
    for t = 1:length(tokennames)
        load(sprintf('%s/hyper/%s/%s/%s/results.mat',dataroot,tokennames{t},sender,subject));
        % mean accuracy
        meanacc(t,s) = retval.accuracy; % lambdarate if doing CV
    end
end
%% Crossval
clear outmean
for t = 1:length(tokennames)
    for s = 1:length(receivers)
        tempacc = squeeze(meanacc(t,:,:));
        tempacc(s,:) = [];
        outmean(s,:) = squeeze(mean(tempacc,1));
    end
end
M = max(outmean);
%% Calculate the average rate for each 15-subject group, separately for each scale. Then choose the best scale for each group, and just check if it is the same for all groups.
ch = 0.25;
for t = 1:length(tokennames)
    acc = meanacc(t,:);
    df = length(acc)-1;
    macc = mean(acc);
    CI = [mean(acc)+tinv(0.025,df)*std(acc)/4 , mean(acc)+tinv(0.975,df)*std(acc)/4];
end    










