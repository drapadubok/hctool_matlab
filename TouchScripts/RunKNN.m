clear all
close all
addpath('/triton/becs/scratch/braindata/shared/toolboxes/NIFTI');
addpath(genpath('/triton/becs/scratch/braindata/shared/BML_utilities'));
toolboxpath = '/triton/becs/scratch/braindata/shared/toolboxes/hyperclassification-tools';
addpath(toolboxpath);
% Script that prepares the data
% Data was preprocessed with pipeline quite similar to what Power et al did
% in 2014. We take unsmoothed data.
cfg.dataroot = '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test';
cfg.convthresh = 0.8;
cfg.downsamp = 1;
cfg.nruns = 4;
cfg.varntr = 1;
cfg.ntask = 4;
cfg.TR = 2.5;
cfg.TRk = 6; % how many timepoints in one trial
senders = {'TouchActV5'};
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
Ks = 1:6:4*6*4;

cfg.token = 'COMBINED';
cfg.maskfile = '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/COMBINED.nii';
% cfg.token = 'combined_loc_mask';
% cfg.maskfile = '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/combined_loc_mask.nii';
% cfg.token = 'Whole';
% cfg.maskfile = '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/whole_GM.nii';
for k = 1:length(Ks);
    cfg.K = Ks(k);
    for s = 1:length(receivers)
        cfg.sender = senders{1};   
        cfg.receiver = receivers{s};
        %%
        NTR = 395;
        for r = 1:cfg.nruns
            loadedrun = load(sprintf('%s/%s/run%i.csv',cfg.dataroot,cfg.sender,r-1));
            regtemp=zeros(NTR,3);
            for j=1:length(loadedrun) % then we go through each trial        
                type=loadedrun(j,3); % get the type of trial
                regtemp(loadedrun(j,1)+1:loadedrun(j,1)+loadedrun(j,2),type)=1;
            end
            cfg.regressor.(sprintf('run%i',r)) = regtemp;
        end
        cfgtmp = HyperTaskModel(cfg); % get actors numbers
        %%
        NTR = 415;
        for r = 1:cfg.nruns
            loadedrun = load(sprintf('%s/%s/run%i.csv',cfg.dataroot,cfg.sender,r-1));
            regtemp=zeros(NTR,3);
            for j=1:length(loadedrun) % then we go through each trial        
                type=loadedrun(j,3); % get the type of trial
                regtemp(loadedrun(j,1)+1:loadedrun(j,1)+loadedrun(j,2),type)=1;
            end
            cfg.regressor.(sprintf('run%i',r)) = regtemp;
        end
        cfg = HyperTaskModel(cfg); % get actors numbers
        cfg.dL3_b = cfgtmp.dL3;
        cfg.NTR_b = cfgtmp.NTR;
        %%
        save(sprintf('%s/hyper/%s/%s/%s/knncfg_%i',cfg.dataroot,cfg.token,cfg.sender,cfg.receiver,cfg.K),'cfg');
        % job filename
        filename = sprintf('%s/hyper/%s/%s/%s/knnjob',cfg.dataroot,cfg.token,cfg.sender,cfg.receiver);
        % log filename
        logfile = sprintf('%s/hyper/%s/%s/%s/knnlog',cfg.dataroot,cfg.token,cfg.sender,cfg.receiver);   
        %load the modules
        dlmwrite(filename, '#!/bin/sh', '');
        % Handle the long jobs
        dlmwrite(filename, '#SBATCH -p batch','-append','delimiter','');
        dlmwrite(filename, '#SBATCH -t 23:00:00','-append','delimiter','');
        dlmwrite(filename, ['#SBATCH -o "' logfile '"'],'-append','delimiter','');
        dlmwrite(filename, '#SBATCH --mem-per-cpu=20000','-append','delimiter','');
        dlmwrite(filename, ['cd ' toolboxpath],'-append','delimiter','');
        dlmwrite(filename,'module load matlab','-append','delimiter','');
        %command
        dlmwrite(filename,sprintf('matlab -nosplash -nodisplay -nojvm -nodesktop -r "KNN(''%s/hyper/%s/%s/%s/knncfg_%i.mat'');"',cfg.dataroot,cfg.token,cfg.sender,cfg.receiver,cfg.K),'-append','delimiter','');
        unix(['sbatch ' filename]);
    end
end
