clear all
close all

% subjects
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

cfg.nruns = 4;
cfg.ntask = 4;
cfg.TR = 2.5;
cfg.downsamp = 1;
cfg.dsampfolder = 'downsampled';
cfg.dataroot = '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test';
toolboxpath = '/triton/becs/scratch/braindata/shared/toolboxes/hyperclassification-tools';
% cfg.lambda = logspace(-2,2,7);
cfg.lambda = 1;
cfg.convthresh = 0.8;
for s = 1:length(subjects)
    cfg.subject = subjects{s};
    if s == 1 % 1 =if actor!
        NTR = 395;
    else % if observer
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
    masks = {
%     sprintf('%s/%s/masks/painloc_thr2.nii',cfg.dataroot,subjects{s})
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/combined_loc_mask.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/fsl/ROIvalidation/FrontalPole.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/ACC.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/aINS.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/Amy.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/COMBINED.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/INS.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/ParaCC.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/pINS.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/S1.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/S2.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/Thalamus.nii';

%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/aACC.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/ACC.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/lCereb.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/lIns.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/lIns2.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/lS2.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/mACC.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/rCereb.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/rIns.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/rIns2.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/rS2.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/SMA.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/virtual_lesion.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/maskFromFSL/SMAb.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/maskFromFSL/somatoInsulaACC.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/maskFromFSL/InsularCxb.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/maskFromFSL/CingulateGyrus_antdivb.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/maskFromFSL/CerebInsulaACC.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/maskFromFSL/CerebSMAS2InsulaACC.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/empathy_pAgF_z_FDR_0.01.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/empathy_pFgA_z_FDR_0.01.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/pain_pAgF_z_FDR_0.01.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/pain_pFgA_z_FDR_0.01.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/Touch_pAgF_z_FDR_0.01.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/Touch_pFgA_z_FDR_0.01.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/LOC.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/MOTOR.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/fsl/ROIvalidation/cingulum/cingularROI.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/fsl/ROIvalidation/temporal/temporalROI.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/fsl/ROIvalidation/FrontalPole.nii';
        '/triton/becs/scratch/braindata/shared/GraspHyperScan/SomeMasksFromJulich/whole_GM.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/SomeMasksFromJulich/Cerebellum.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/SomeMasksFromJulich/premotor.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/SomeMasksFromJulich/prim_motor.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/SomeMasksFromJulich/prim_somatosens.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/SomeMasksFromJulich/second_somatosens.nii';   
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/SomeMasksFromJulich/summask.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/SomeMasksFromJulich/summask_nocereb.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/SomeMasksFromJulich/AON_dummy/thr50/aon50.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/SomeMasksFromJulich/neurosynth/somatotopic_pAgF_z_FDR_0.05.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/SomeMasksFromJulich/neurosynth/somatotopic_pFgA_z_FDR_0.05.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/SomeMasksFromJulich/neurosynth/tactile_pAgF_z_FDR_0.05.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/SomeMasksFromJulich/neurosynth/tactile_pFgA_z_FDR_0.05.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/ns/mirrormask.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/SomeMasksFromJulich/neurosynth/painful_pAgF_z_FDR_0.05.nii'
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/alLOC.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/arLOC.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/lBroca.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/lPrecentral.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/lSPL.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/rBroca.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/rPrecentral.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/rSMG.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/rSPL.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/slLOC.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/srLOC.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/virtual_lesion.nii';
   };
%      masks = {sprintf('%s/%s/masks/painloc_thr2.nii',cfg.dataroot,subjects{s})};
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
        dlmwrite(filename, '#SBATCH --mem-per-cpu=10000','-append','delimiter','');
        dlmwrite(filename, ['cd ' toolboxpath],'-append','delimiter','');
        %command
%         dlmwrite(filename,sprintf('matlab -nosplash -nodisplay -nojvm -nodesktop -r "mvla(''%s/within/%s/%s/cfg'');"',cfg.dataroot,name,cfg.subject),'-append','delimiter','');
        dlmwrite(filename,sprintf('matlab -nosplash -nodisplay -nojvm -nodesktop -r "mvla_final(''%s/within/%s/%s/cfg'');"',cfg.dataroot,name,cfg.subject),'-append','delimiter','');
        unix(['sbatch ' filename]);
    end
end
        


        




