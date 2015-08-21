clear all
close all

% subjects
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
'Fanny_Observer_3';
'Surro';
};

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

for s = 1:length(subjects)
    cfg.subject = subjects{s};
    % Load regressor
    load(sprintf('%s/regressorActor.mat',cfg.dataroot));
    for r = 1:cfg.nruns
        cfg.regressor.(sprintf('run%i',r)) = regressor.(sprintf('run%i',r));
    end
    % masks, maybe use best one?
    masks = {
        '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/LOC.nii';
        '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/MOTOR.nii';
        '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/fsl/ROIvalidation/cingulum/cingularROI.nii';
        '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/fsl/ROIvalidation/temporal/temporalROI.nii';
        '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/fsl/ROIvalidation/FrontalPole.nii';
        sprintf('/triton/becs/scratch/braindata/shared/GraspHyperScan/%s/masks/motorloc_V1.nii',cfg.subject);
        sprintf('/triton/becs/scratch/braindata/shared/GraspHyperScan/%s/masks/obsloc_contrast_V1.nii',cfg.subject);
        '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/ns/grasp.nii';
        '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/loc_overlap2_clu.nii'
    };
    for m = 1:length(masks)
        cfg.maskpath = masks{m};
        [pathstr,name,~] = fileparts(masks{m});
        if ~exist(sprintf('%s/within/%s/%s/perms',cfg.dataroot,name,cfg.subject),'dir');
            mkdir(sprintf('%s/within/%s/%s/perms',cfg.dataroot,name,cfg.subject));
        end
        save(sprintf('%s/within/%s/%s/permcfg',cfg.dataroot,name,cfg.subject),'cfg');
        % job filename
        filename = sprintf('%s/within/%s/%s/permjob',cfg.dataroot,name,cfg.subject);
        % log filename
        logfile = sprintf('%s/within/%s/%s/permlogfile',cfg.dataroot,name,cfg.subject);
        %load the modules
        dlmwrite(filename, '#!/bin/sh', '');
        % Handle the long jobs
        dlmwrite(filename, '#SBATCH -p short','-append','delimiter','');
        dlmwrite(filename, '#SBATCH -t 04:00:00','-append','delimiter','');            
        dlmwrite(filename, ['#SBATCH -o "' logfile '"'],'-append','delimiter','');
        dlmwrite(filename, '#SBATCH --mem-per-cpu=10000','-append','delimiter','');
        dlmwrite(filename, sprintf('#SBATCH --array=0-%i',njobs-1),'-append','delimiter','');
        dlmwrite(filename, ['cd ' toolboxpath],'-append','delimiter','');
        %command
        dlmwrite(filename,sprintf('matlab -nosplash -nodisplay -nojvm -nodesktop -r "mvlaPermutation(''%s/within/%s/%s/permcfg'',%i,''within'',$SLURM_ARRAY_TASK_ID);"',cfg.dataroot,name,cfg.subject,shuffle_group),'-append','delimiter','');
        unix(sprintf('sbatch %s',filename));
    end
end
        


        



