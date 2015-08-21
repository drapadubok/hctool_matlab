clear all
close all
dataroot = '/triton/becs/scratch/braindata/shared/GraspHyperScan';
% tokennames
tokennames = {    
% 'Motor-to-Observation_Combined_thresholded';
% 'Whole'
'grasp';
'CingularCortex';
'FrontalPole';
'TemporalCortex';
'OverlapLocalizer';
% 'virtual_lesion';
};
% subjects
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
'Surro';
};
% params
cfg.convthresh = 0.6;
cfg.nruns = 5;
cfg.ntask = 4;
cfg.TR = 2;
cfg.downsamp = 1;
cfg.dsampfolder = 'downsampled';
cfg.dataroot = '/triton/becs/scratch/braindata/shared/GraspHyperScan';
toolboxpath = '/triton/becs/scratch/braindata/shared/toolboxes/hyperclassification-tools';
% cfg.lambda = logspace(-2,2,7);
cfg.lambda = 0.2154;

for t = 1:length(tokennames)
    cfg.token = tokennames{t};
    for s = 1:length(receivers)
        if s < 12
            cfg.sender = senders{1};
        else
            cfg.sender = senders{2};
        end
        cfg.receiver = receivers{s};
        if ~exist(sprintf('%s/between/%s/%s/%s',cfg.dataroot,cfg.token,cfg.sender,cfg.receiver),'dir');
            mkdir(sprintf('%s/between/%s/%s/%s',cfg.dataroot,cfg.token,cfg.sender,cfg.receiver));
        end
        save(sprintf('%s/between/%s/%s/%s/betweencfg',cfg.dataroot,cfg.token,cfg.sender,cfg.receiver),'cfg');
        % job filename
        filename = sprintf('%s/between/%s/%s/%s/betweenjob',cfg.dataroot,cfg.token,cfg.sender,cfg.receiver);
        % log filename
        logfile = sprintf('%s/between/%s/%s/%s/betweenlogfile',cfg.dataroot,cfg.token,cfg.sender,cfg.receiver);
        %load the modules
        dlmwrite(filename, '#!/bin/sh', '');
        % Handle the long jobs
        dlmwrite(filename, '#SBATCH -p batch','-append','delimiter','');
        dlmwrite(filename, '#SBATCH -t 23:00:00','-append','delimiter','');            
        dlmwrite(filename, ['#SBATCH -o "' logfile '"'],'-append','delimiter','');
        dlmwrite(filename, '#SBATCH --mem-per-cpu=30000','-append','delimiter','');
        dlmwrite(filename, ['cd ' toolboxpath],'-append','delimiter','');
        dlmwrite(filename, 'module load R/3.1.0-mkl','-append','delimiter','');
        %command
        dlmwrite(filename,sprintf('matlab -nosplash -nodisplay -nojvm -nodesktop -r "mvlaBetween_final(''%s/between/%s/%s/%s/betweencfg'');"',cfg.dataroot,cfg.token,cfg.sender,cfg.receiver),'-append','delimiter','');
        unix(['sbatch ' filename]);
    end
end
