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
% 'Surro';
};

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

for s = 1:length(subjects)
    cfg.subject = subjects{s};
    load(sprintf('%s/regressorActor.mat',cfg.dataroot));
    for r = 1:cfg.nruns
        cfg.regressor.(sprintf('run%i',r)) = regressor.(sprintf('run%i',r));        
    end
    % masks
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
        if ~exist(sprintf('%s/within/%s/%s',cfg.dataroot,name,cfg.subject),'dir');
            mkdir(sprintf('%s/within/%s/%s',cfg.dataroot,name,cfg.subject));
        end
        save(sprintf('%s/within/%s/%s/cfg',cfg.dataroot,name,cfg.subject),'cfg');
        % job filename
        filename = sprintf('%s/within/%s/%s/job',cfg.dataroot,name,cfg.subject);
        % log filename
        logfile = sprintf('%s/within/%s/%s/logfile',cfg.dataroot,name,cfg.subject);
        %load the modules
        dlmwrite(filename, '#!/bin/sh', '');
        % Handle the long jobs
        dlmwrite(filename, '#SBATCH -p batch','-append','delimiter','');
        dlmwrite(filename, '#SBATCH -t 23:00:00','-append','delimiter','');            
        dlmwrite(filename, ['#SBATCH -o "' logfile '"'],'-append','delimiter','');
        dlmwrite(filename, '#SBATCH --mem-per-cpu=30000','-append','delimiter','');
        dlmwrite(filename, ['cd ' toolboxpath],'-append','delimiter','');
        %command
        dlmwrite(filename,sprintf('matlab -nosplash -nodisplay -nojvm -nodesktop -r "mvla_final(''%s/within/%s/%s/cfg'');"',cfg.dataroot,name,cfg.subject),'-append','delimiter','');
        unix(['sbatch ' filename]);
    end
end
        


        




