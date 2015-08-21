clear all
close all
dataroot = '/triton/becs/scratch/braindata/shared/GraspHyperScan';
% tokennames
tokennames = {
% 'grasp';
% 'CingularCortex';
% 'FrontalPole';
% 'TemporalCortex';
% 'OverlapLocalizer';
'MOTOR';
'LOC';
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

cfg.lambda = 0.2154;
shuffle_group = 0;
njobs = 10; % how many jobs in array

for t = 1:length(tokennames)
    cfg.token = tokennames{t};
    for s = 1:length(receivers)
        if s < 12
            cfg.sender = senders{1};
        else
            cfg.sender = senders{2};
        end
        cfg.receiver = receivers{s};
        if ~exist(sprintf('%s/between/%s/%s/%s/perms',cfg.dataroot,cfg.token,cfg.sender,cfg.receiver),'dir');
            mkdir(sprintf('%s/between/%s/%s/%s/perms',cfg.dataroot,cfg.token,cfg.sender,cfg.receiver));
        end
        save(sprintf('%s/between/%s/%s/%s/permcfg',cfg.dataroot,cfg.token,cfg.sender,cfg.receiver),'cfg');
        % job filename
        filename = sprintf('%s/between/%s/%s/%s/permjob',cfg.dataroot,cfg.token,cfg.sender,cfg.receiver);
        % log filename
        logfile = sprintf('%s/between/%s/%s/%s/permlogfile',cfg.dataroot,cfg.token,cfg.sender,cfg.receiver);
        %load the modules
        dlmwrite(filename, '#!/bin/sh', '');
        % Handle the long jobs
        dlmwrite(filename, '#SBATCH -p short','-append','delimiter','');
        dlmwrite(filename, '#SBATCH -t 4:00:00','-append','delimiter','');            
        dlmwrite(filename, ['#SBATCH -o "' logfile '"'],'-append','delimiter','');
        dlmwrite(filename, '#SBATCH --mem-per-cpu=8000','-append','delimiter','');
        dlmwrite(filename, sprintf('#SBATCH --array=0-%i',njobs-1),'-append','delimiter','');
        dlmwrite(filename, ['cd ' toolboxpath],'-append','delimiter','');
        dlmwrite(filename, 'module load R/3.1.0-mkl','-append','delimiter','');
        %command
        dlmwrite(filename,sprintf('matlab -nosplash -nodisplay -nojvm -nodesktop -r "mvlaPermutation(''%s/between/%s/%s/%s/permcfg'',%i,''between'',$SLURM_ARRAY_TASK_ID);"',cfg.dataroot,cfg.token,cfg.sender,cfg.receiver,shuffle_group),'-append','delimiter','');
        unix(sprintf('sbatch %s',filename));
    end
end
