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
cfg.infile = 'epi_STD_mask_detrend_fullreg.nii';
%% Always have the actor first
subjects = {
'Surro'
};
for s = 1:length(subjects)
    
    addpath('/triton/becs/scratch/braindata/shared/toolboxes/NIFTI');
    addpath(genpath('/triton/becs/scratch/braindata/shared/BML_utilities'));
    addpath(genpath(cfg.toolboxpath));
    
    cfg.subject = subjects{s};
    cfg.masks = {
%     '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/LOC.nii';
%     '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/MOTOR.nii';
%     '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/fsl/ROIvalidation/cingulum/cingularROI.nii';
%     '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/fsl/ROIvalidation/temporal/temporalROI.nii';
%     '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/fsl/ROIvalidation/FrontalPole.nii';
%     '/triton/becs/scratch/braindata/shared/GraspHyperScan/SomeMasksFromJulich/whole_GM.nii';
%     '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/ns/grasp.nii';
%     '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/alLOC.nii';
%     '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/arLOC.nii';
%     '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/lBroca.nii';
%     '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/rBroca.nii';
%     '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/lPrecentral.nii';
%     '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/rPrecentral.nii';
%     '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/lSPL.nii';
%     '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/rSPL.nii';
%     '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/rSMG.nii';
%     '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/slLOC.nii';
%     '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/srLOC.nii';
%     '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/virtual_lesion.nii';
%     '/triton/becs/scratch/braindata/shared/GraspHyperScan/Sonya_Actor/masks/motorloc_V1.nii';
%     '/triton/becs/scratch/braindata/shared/GraspHyperScan/Sonya_Actor/masks/obsloc_contrast_V1.nii';
%     '/triton/becs/scratch/braindata/shared/GraspHyperScan/Sonya_Actor/masks/obsloc_maineffect_V1.nii';
%     '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/loc_overlap2_clu.nii'
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
    %% Process regressor
    % Regressor of type:
    % regressor.run%i with ncolumns == ntask
    % produces three types of label vectors and number of TRs for each run with
    % suggested regressors (necessary due to common mistakes in this stage)
    % load('/triton/becs/scratch/braindata/shared/GraspHyperScan/regressorObserver.mat'); % basic regressor
    cfg = HyperTaskModel(cfg);
    tosave = cfg.dL2;
    if ~exist(sprintf('%s/%s',cfg.dataroot,cfg.subject))
        mkdir(sprintf('%s/%s',cfg.dataroot,cfg.subject));        
    end
    save(sprintf('%s/%s/dL2.mat',cfg.dataroot,cfg.subject),'tosave'); % in case you would want them beforehand
    %% Masking
    for m = 1:length(cfg.masks)
        [dT,name] = MaskData(cfg.masks{m},cfg);
        save(sprintf('%s/%s_data4mm.mat',cfg.temppath,name),'dT','-v7.3');
    end

end
