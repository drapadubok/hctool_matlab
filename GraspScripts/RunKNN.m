clear all
close all
addpath('/triton/becs/scratch/braindata/shared/toolboxes/NIFTI');
addpath(genpath('/triton/becs/scratch/braindata/shared/BML_utilities'));
toolboxpath = '/triton/becs/scratch/braindata/shared/toolboxes/hyperclassification-tools';
addpath(toolboxpath);
% Script that prepares the data
% Data was preprocessed with pipeline quite similar to what Power et al did
% in 2014. We take unsmoothed data.
cfg.dataroot = '/triton/becs/scratch/braindata/shared/GraspHyperScan';
cfg.convthresh = 0.6;
cfg.downsamp = 1;
cfg.nruns = 5;
cfg.varntr = 0;
cfg.ntask = 4;
cfg.TR = 2;
cfg.TRk = 3; % how many timepoints in one trial
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
Ks = 1:6:4*6*5;
% Ks = 13;
cfg.token = 'grasp';
cfg.maskfile = '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/ns/grasp.nii';
% cfg.token = 'Whole';
% cfg.maskfile = '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/whole_GM.nii';
for k = 1:length(Ks);
    cfg.K = Ks(k);
    for s = 1:length(receivers)
        load(sprintf('%s/regressorActor.mat',cfg.dataroot));
        for r = 1:cfg.nruns
            cfg.regressor.(sprintf('run%i',r)) = regressor.(sprintf('run%i',r));        
        end
        cfg = HyperTaskModel(cfg);
        if s < 12
            cfg.sender = senders{1};
        else
            cfg.sender = senders{2};
        end
        cfg.receiver = receivers{s};
        save(sprintf('%s/hyper/%s/%s/%s/knncfg_%i',cfg.dataroot,cfg.token,cfg.sender,cfg.receiver,cfg.K),'cfg');
        % job filename
        filename = sprintf('%s/hyper/%s/%s/%s/knnjob',cfg.dataroot,cfg.token,cfg.sender,cfg.receiver);
        % log filename
        logfile = sprintf('%s/hyper/%s/%s/%s/knnlog',cfg.dataroot,cfg.token,cfg.sender,cfg.receiver);   
        %load the modules
        dlmwrite(filename, '#!/bin/sh', '');
        % Handle the long jobs
        dlmwrite(filename, '#SBATCH -p short','-append','delimiter','');
        dlmwrite(filename, '#SBATCH -t 4:00:00','-append','delimiter','');
        dlmwrite(filename,'#SBATCH --qos=short','-append','delimiter','');
        dlmwrite(filename, ['#SBATCH -o "' logfile '"'],'-append','delimiter','');
        dlmwrite(filename, '#SBATCH --mem-per-cpu=45000','-append','delimiter','');
        dlmwrite(filename, ['cd ' toolboxpath],'-append','delimiter','');
        dlmwrite(filename,'module load matlab','-append','delimiter','');
        %command
        dlmwrite(filename,sprintf('matlab -nosplash -nodisplay -nojvm -nodesktop -r "KNN(''%s/hyper/%s/%s/%s/knncfg_%i.mat'');"',cfg.dataroot,cfg.token,cfg.sender,cfg.receiver,cfg.K),'-append','delimiter','');
        unix(['sbatch ' filename]);
    end
end


