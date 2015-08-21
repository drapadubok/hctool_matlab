clear all
close all
% Script that prepares the data
% Data was preprocessed with pipeline quite similar to what Power et al did
% in 2014. We take unsmoothed data.
cfg.toolboxpath = '/triton/becs/scratch/braindata/shared/toolboxes/hyperclassification-tools';
cfg.dataroot = '/triton/becs/scratch/braindata/shared/GraspHyperScan';
cfg.convthresh = 0.6;
cfg.downsamp = 1;
cfg.nruns = 5;
cfg.ntask = 4;
cfg.TR = 2;
cfg.dsampfolder = 'downsampled';
cfg.infile = 'bramila/bramila/epi_STD_mask_detrend_fullreg.nii';
%% Always have the actor first
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
'Fanny_Observer_3'
};
for s = 1:length(subjects)
    cfg.subject = subjects{s};
    cfg.masks = {
    '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/LOC.nii';
    '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/MOTOR.nii';
    '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/fsl/ROIvalidation/cingulum/cingularROI.nii';
    '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/fsl/ROIvalidation/temporal/temporalROI.nii';
    '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/fsl/ROIvalidation/FrontalPole.nii';
    '/triton/becs/scratch/braindata/shared/GraspHyperScan/SomeMasksFromJulich/whole_GM.nii';
    '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/ns/grasp.nii';
    '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/alLOC.nii';
    '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/arLOC.nii';
    '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/lBroca.nii';
    '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/rBroca.nii';
    '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/lPrecentral.nii';
    '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/rPrecentral.nii';
    '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/lSPL.nii';
    '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/rSPL.nii';
    '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/rSMG.nii';
    '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/slLOC.nii';
    '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/srLOC.nii';
    '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/virtual_lesion.nii';
    sprintf('/triton/becs/scratch/braindata/shared/GraspHyperScan/%s/masks/motorloc_V1.nii',cfg.subject);
    sprintf('/triton/becs/scratch/braindata/shared/GraspHyperScan/%s/masks/obsloc_contrast_V1.nii',cfg.subject);
    sprintf('/triton/becs/scratch/braindata/shared/GraspHyperScan/%s/masks/obsloc_maineffect_V1.nii',cfg.subject);
    '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/loc_overlap2_clu.nii'
    '/triton/becs/scratch/braindata/shared/GraspHyperScan/FIGURES/mlocthr.nii';
    '/triton/becs/scratch/braindata/shared/GraspHyperScan/FIGURES/oloccthr.nii';
    };
    cfg.temppath = sprintf('%s/%s/%s',cfg.dataroot,cfg.dsampfolder,cfg.subject);
    %% Make regressor of type regressor.run%i
    % Make sure its not convolved
    load(sprintf('%s/regressorActor.mat',cfg.dataroot));
    for r = 1:cfg.nruns
        cfg.regressor.(sprintf('run%i',r)) = regressor.(sprintf('run%i',r));        
    end
    % Store job file in receiver folder
    if ~exist(cfg.temppath,'dir');
        mkdir(cfg.temppath);
    end
    save(sprintf('%s/cfg',cfg.temppath),'cfg');
    % job filename
    filename = sprintf('%s/job',cfg.temppath);
    % log filename
    logfile = sprintf('%s/logfile',cfg.temppath);
    %load the modules
    dlmwrite(filename,'#!/bin/sh', '');
    % Handle the long jobs    
    dlmwrite(filename,'#SBATCH -p short','-append','delimiter','');
    dlmwrite(filename,'#SBATCH -t 1:00:00','-append','delimiter','');
    dlmwrite(filename,'#SBATCH --qos=short','-append','delimiter','');
    dlmwrite(filename,['#SBATCH -o "' logfile '"'],'-append','delimiter','');
    dlmwrite(filename,'#SBATCH --mem-per-cpu=30000','-append','delimiter','');
    dlmwrite(filename,['cd ' cfg.toolboxpath],'-append','delimiter','');
    dlmwrite(filename,'module load fsl','-append','delimiter','');
    dlmwrite(filename,'source $FSLDIR/etc/fslconf/fsl.sh','-append','delimiter','');
    dlmwrite(filename,'module load matlab','-append','delimiter','');
    dlmwrite(filename,'module load R','-append','delimiter','');
    %command
    dlmwrite(filename,sprintf('matlab -nosplash -nodisplay -nojvm -nodesktop -r "HyperPrepareData(''%s/cfg.mat'');"',cfg.temppath),'-append','delimiter','');
    unix(['sbatch ' filename]);
end
