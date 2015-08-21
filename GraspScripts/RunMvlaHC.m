clear all
close all
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
cfg.K = 50;
cfg.downsamp = 1;
cfg.dsampfolder = 'downsampled';
cfg.dataroot = '/triton/becs/scratch/braindata/shared/GraspHyperScan';
toolboxpath = '/triton/becs/scratch/braindata/shared/toolboxes/hyperclassification-tools';
cfg.lambda = logspace(-2,2,7);
% cfg.lambda = 0.2154;
% masks
tokennames = {
% 'MOTOR';
% 'LOC';
% 'virtual_lesion';
% 'alLOC';
% 'arLOC';
% 'rSMG';
% 'srLOC';
% 'slLOC';
% 'lSPL';
% 'rSPL';
% 'rPrecentral';
% 'lPrecentral';
% 'lBroca';
% 'rBroca';
% 'without_alLOC';
% 'without_arLOC';
% 'without_rSMG';
% 'without_srLOC';
% 'without_slLOC';
% 'without_lSPL';
% 'without_rSPL';
% 'without_rPrecentral';
% 'without_lPrecentral';
% 'without_lBroca';
% 'without_rBroca';
% 'CingularCortex';
% 'FrontalPole';
% 'TemporalCortex';
% 'Whole';
% 'grasp';
% 'Motor-to-Observation_Combined_thresholded';
% 'Motor-to-Observation_V1';
'OverlapLocalizer';
};
for t = 1:length(tokennames)
    cfg.token = tokennames{t};
    for s = 1:length(receivers)
        if s < 12
            cfg.sender = senders{1};
        else
            cfg.sender = senders{2};
        end
        cfg.receiver = receivers{s};
        if ~exist(sprintf('%s/hyper/%s/%s/%s',cfg.dataroot,cfg.token,cfg.sender,cfg.receiver),'dir');
            mkdir(sprintf('%s/hyper/%s/%s/%s',cfg.dataroot,cfg.token,cfg.sender,cfg.receiver));
        end
        save(sprintf('%s/hyper/%s/%s/%s/hypercfg',cfg.dataroot,cfg.token,cfg.sender,cfg.receiver),'cfg');
        % job filename
        filename = fullfile(cfg.dataroot,'hyper',cfg.token,cfg.sender,cfg.receiver,'hyperjob');
        % log filename
        logfile = fullfile(cfg.dataroot,'hyper',cfg.token,cfg.sender,cfg.receiver,'hyperlogfile');
        %load the modules
        dlmwrite(filename, '#!/bin/sh', '');
        % Handle the long jobs
        dlmwrite(filename, '#SBATCH -p batch','-append','delimiter','');
        dlmwrite(filename, '#SBATCH -t 23:00:00','-append','delimiter','');            
        dlmwrite(filename, ['#SBATCH -o "' logfile '"'],'-append','delimiter','');
        dlmwrite(filename, '#SBATCH --mem-per-cpu=30000','-append','delimiter','');
        dlmwrite(filename, ['cd ' toolboxpath],'-append','delimiter','');
        dlmwrite(filename, 'module load R','-append','delimiter','');
        %command
        dlmwrite(filename,sprintf('Rscript bcca.r "%s/hyper/%s/%s/%s/hypercfg.mat"',cfg.dataroot,cfg.token,cfg.sender,cfg.receiver),'-append','delimiter','');
        unix(['sbatch ' filename]);
    end
end




