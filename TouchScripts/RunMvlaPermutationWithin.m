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
cfg.convthresh = 0.8;

shuffle_group = 1; % try with groupwise shuffling first
njobs = 10; % how many jobs in array

%% CHECK THAT LAMBDA IS CORRECT
cfg.lambda = 1;

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
%         sprintf('%s/%s/masks/painloc_thr2.nii',cfg.dataroot,subjects{s})
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/combined_loc_mask.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/fsl/ROIvalidation/FrontalPole.nii';
        '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/ACC.nii';
        '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/aINS.nii';
        '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/Amy.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/COMBINED.nii';
        '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/INS.nii';
        '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/ParaCC.nii';
        '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/pINS.nii';
        '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/S1.nii';
        '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/S2.nii';
        '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/Thalamus.nii';
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
        dlmwrite(filename, '#SBATCH -p batch','-append','delimiter','');
        dlmwrite(filename, '#SBATCH -t 23:00:00','-append','delimiter','');            
        dlmwrite(filename, ['#SBATCH -o "' logfile '"'],'-append','delimiter','');
        dlmwrite(filename, '#SBATCH --mem-per-cpu=8000','-append','delimiter','');
        dlmwrite(filename, sprintf('#SBATCH --array=0-%i',njobs-1),'-append','delimiter','');
        dlmwrite(filename, ['cd ' toolboxpath],'-append','delimiter','');
        %command
        dlmwrite(filename,sprintf('matlab -nosplash -nodisplay -nojvm -nodesktop -r "mvlaPermutation(''%s/within/%s/%s/permcfg'',%i,''within'',$SLURM_ARRAY_TASK_ID);"',cfg.dataroot,name,cfg.subject,shuffle_group),'-append','delimiter','');
        unix(sprintf('sbatch %s',filename));  
    end
end
        


        



