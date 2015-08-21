clear all
close all
% Script that prepares the data
% Data was preprocessed with pipeline quite similar to what Power et al did
% in 2014. We take unsmoothed data.
cfg.toolboxpath = '/triton/becs/scratch/braindata/shared/toolboxes/hyperclassification-tools';
cfg.dataroot = '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test';
cfg.convthresh = 0.8;
cfg.downsamp = 1;
cfg.nruns = 4;
cfg.ntask = 4;
cfg.TR = 2.5;
cfg.dsampfolder = 'downsampled';
cfg.infile = 'bramila/epi_STD_mask_detrend_motreg_HPF.nii';
%% Always have the actor first
subjects = {
'TouchActV5'
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
for s = 1:length(subjects)
    cfg.masks = {sprintf('%s/%s/masks/painloc_thr2.nii',cfg.dataroot,subjects{s})
    '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/combined_loc_mask.nii';
    '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/fsl/ROIvalidation/FrontalPole.nii';
    '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/ACC.nii';
    '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/aINS.nii';
    '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/Amy.nii';
    '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/COMBINED.nii';
    '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/INS.nii';
    '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/ParaCC.nii';
    '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/pINS.nii';
    '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/S1.nii';
    '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/S2.nii';
    '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/Thalamus.nii'};    
    cfg.subject = subjects{s};
    cfg.temppath = sprintf('%s/%s/%s',cfg.dataroot,cfg.dsampfolder,cfg.subject);
    %% Make regressor of type regressor.run%i
    % Make sure its not convolved
    if s == 1 % if actor
        NTR = 395;
    else
        NTR = 415;
    end
    for r = 1:cfg.nruns
        loadedrun = load(sprintf('%s/%s/run%i.csv',cfg.dataroot,cfg.subject,r-1));
        regtemp=zeros(NTR,3);
        for k=1:length(loadedrun) % then we go through each trial        
            type=loadedrun(k,3); % get the type of trial
            regtemp(loadedrun(k,1)+1:loadedrun(k,1)+loadedrun(k,2),type)=1;
        end
        cfg.regressor.(sprintf('run%i',r)) = regtemp;
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
    dlmwrite(filename,'#SBATCH --mem-per-cpu=5000','-append','delimiter','');
    dlmwrite(filename,['cd ' cfg.toolboxpath],'-append','delimiter','');
    dlmwrite(filename,'module load fsl','-append','delimiter','');
    dlmwrite(filename,'source $FSLDIR/etc/fslconf/fsl.sh','-append','delimiter','');
    dlmwrite(filename,'module load matlab','-append','delimiter','');
    dlmwrite(filename,'module load R','-append','delimiter','');
    %command
    dlmwrite(filename,sprintf('matlab -nosplash -nodisplay -nojvm -nodesktop -r "HyperPrepareData(''%s/cfg.mat'');"',cfg.temppath),'-append','delimiter','');
    unix(['sbatch ' filename]);
end
