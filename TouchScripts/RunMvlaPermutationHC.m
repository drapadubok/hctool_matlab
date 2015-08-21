clear all
close all
% tokennames
tokennames = {
% 'painloc_thr2';
% 'combined_loc_mask';
% 'FrontalPole';
'ACC';
'aINS';
'Amy';
% 'COMBINED';
'INS';
'ParaCC';
'pINS';
'S1';
'S2';
'Thalamus';
};
% subjects
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
};

% params
cfg.convthresh = 0.8;
cfg.nruns = 4;
cfg.ntask = 4;
cfg.TR = 2.5;
cfg.K = 50;
cfg.downsamp = 1;
cfg.dsampfolder = 'downsampled';
cfg.dataroot = '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test';
toolboxpath = '/triton/becs/scratch/braindata/shared/toolboxes/hyperclassification-tools';
% cfg.lambda = logspace(-2,2,7);

%% CHECK THAT THIS IS CORRECT LAMBDA
cfg.lambda = 1;
shuffle_group = 1;
njobs = 10; % how many jobs in array

for t = 1:length(tokennames)
    cfg.token = tokennames{t};
    for s = 1:length(receivers)
        cfg.sender = senders{1}; 
        cfg.receiver = receivers{s};
        if ~exist(sprintf('%s/hyper/%s/%s/%s/perms',cfg.dataroot,cfg.token,cfg.sender,cfg.receiver),'dir');
            mkdir(sprintf('%s/hyper/%s/%s/%s/perms',cfg.dataroot,cfg.token,cfg.sender,cfg.receiver));
        end
        save(sprintf('%s/hyper/%s/%s/%s/permcfg',cfg.dataroot,cfg.token,cfg.sender,cfg.receiver),'cfg');
        
        % job filename
        filename = sprintf('%s/hyper/%s/%s/%s/permjob',cfg.dataroot,cfg.token,cfg.sender,cfg.receiver);
        % log filename
        logfile = sprintf('%s/hyper/%s/%s/%s/permlogfile',cfg.dataroot,cfg.token,cfg.sender,cfg.receiver);
        %load the modules
        dlmwrite(filename, '#!/bin/sh', '');
        % Handle the long jobs
        dlmwrite(filename, '#SBATCH -p batch','-append','delimiter','');
        dlmwrite(filename, '#SBATCH -t 2-23:00:00','-append','delimiter','');
        dlmwrite(filename, ['#SBATCH -o "' logfile '"'],'-append','delimiter','');
        dlmwrite(filename, '#SBATCH --mem-per-cpu=8000','-append','delimiter','');
        dlmwrite(filename, sprintf('#SBATCH --array=0-%i',njobs-1),'-append','delimiter','');
        dlmwrite(filename, ['cd ' toolboxpath],'-append','delimiter','');
        dlmwrite(filename, 'module load R/3.1.0-mkl','-append','delimiter','');
        %command
        dlmwrite(filename,sprintf('matlab -nosplash -nodisplay -nojvm -nodesktop -r "mvlaPermutation(''%s/hyper/%s/%s/%s/permcfg'',%i,''hyper'',$SLURM_ARRAY_TASK_ID);"',cfg.dataroot,cfg.token,cfg.sender,cfg.receiver,shuffle_group),'-append','delimiter','');
        unix(['sbatch ' filename]);
        
    end
end

