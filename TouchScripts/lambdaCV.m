clear all
close all
addpath(genpath('/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/MVLA'));
addpath('/triton/becs/scratch/braindata/shared/toolboxes/cbrewer');
addpath('/triton/becs/scratch/braindata/shared/toolboxes/NIFTI');
addpath('/triton/becs/scratch/braindata/shared/toolboxes/spm8_masking_removed/')
addpath('/triton/becs/scratch/braindata/shared/toolboxes/export_fig');
dataroot = '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test';
% token names
tokennames = {
'combined_loc_mask';
% 'FrontalPole';
% 'ACC';
% 'aINS';
% 'Amy';
% 'COMBINED';
% 'INS';
% 'ParaCC';
% 'pINS';
% 'S1';
% 'S2';
% 'Thalamus';
};
senders = {'TouchActV5'
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
'TouchActV5' % in case its within
};
%% Hyper
clear meanacc
clear confmat
clear mean_acc_mask
for s = 1:length(receivers)
    sender = senders{1};
    subject = receivers{s};    
    for t = 1:length(tokennames) % I DONT GO THROUGH TOKENS, I TAKE ONE AT A TIME
%         load(sprintf('%s/hyper/%s/%s/%s/results.mat',dataroot,tokennames{t},sender,subject));
        load(sprintf('%s/within/%s/%s/results.mat',dataroot,tokennames{t},subject));
%         load(sprintf('%s/between/%s/%s/%s/results.mat',dataroot,tokennames{t},sender,subject));
        % mean accuracy
        meanacc(s,:) = retval.lambdarate; % lambdarate if doing CV
    end
end
%% Crossval
% We have subjects x lambdas sized matrix of accuracies
% We go through it by leaving one subject out at a time, and checking the average accuracy
clear outmean
for s = 1:length(receivers)
    tempacc = meanacc;
    tempacc(s,:) = [];
    outmean(s,:) = squeeze(mean(tempacc,1));
end
M = max(outmean);
mean(outmean,1)







