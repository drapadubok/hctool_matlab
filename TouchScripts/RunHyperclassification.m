clear all
close all
% subjects
senders = {'TouchActV5'};
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
cfg.lambda = 1;
% masks
tokennames = {
% 'painloc_thr2';
% 'combined_loc_mask';
% 'FrontalPole';
% 'ACC';
% 'aINS';
% 'Amy';
% 'COMBINED';
% 'INS';
% 'ParaCC';
% 'pINS';
% 'S1';
% 'S2';
% 'Thalamus';
%     'aACC';
%     'ACC';
%     'lCereb';
%     'rCereb';
%     'mACC';
%     'lIns';
%     'lIns2';
%     'rIns';
%     'rIns2';
%     'lS2';
%     'rS2';
%     'SMA';   
%     'without_aACC';
%     'without_ACC';
%     'without_lCereb';
%     'without_rCereb';
%     'without_mACC';
%     'without_wholeACC';
%     'without_lIns';
%     'without_rIns';
%     'without_bothIns';
%     'without_lS2';
%     'without_rS2';
%     'without_SMA';
%     'virtual_lesion';  
% 'painloc_thr2';
% 'SMAb';
% 'somatoInsulaACC';
% 'InsularCxb';
% 'CingulateGyrus_antdivb';
% 'CerebInsulaACC';
% 'CerebSMAS2InsulaACC';
% 'empathy_pAgF';
% 'empathy_pFgA';
% 'pain_pAgF'; 
% 'pain_pFgA';
% 'Touch_pAgF';
% 'Touch_pFgA';
% 'combined_localizer';
% 'tactile';
% 'somatotopic';
% 'aon50';
% 'prim_somatosens';
% 'sec_somatosens';
% 'prim_sec_somatosens';
% 'painful';
% 'MOTOR';
% 'LOC';
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
% 'mirrormask';
'Whole';
};
for t = 1:length(tokennames)
    cfg.token = tokennames{t};
    for s = 1:length(receivers)
        cfg.sender = senders{1}; 
        cfg.receiver = receivers{s};
        if ~exist(sprintf('%s/hyper/%s/%s/%s',cfg.dataroot,cfg.token,cfg.sender,cfg.receiver),'dir');
            mkdir(sprintf('%s/hyper/%s/%s/%s',cfg.dataroot,cfg.token,cfg.sender,cfg.receiver));
        end
        save(sprintf('%s/hyper/%s/%s/%s/cfg',cfg.dataroot,cfg.token,cfg.sender,cfg.receiver),'cfg');
        % job filename
        filename = fullfile(cfg.dataroot,'hyper',cfg.token,cfg.sender,cfg.receiver,'job');
        % log filename
        logfile = fullfile(cfg.dataroot,'hyper',cfg.token,cfg.sender,cfg.receiver,'logfile');
        %load the modules
        dlmwrite(filename, '#!/bin/sh', '');
        % Handle the long jobs
        dlmwrite(filename, '#SBATCH -p batch','-append','delimiter','');
        dlmwrite(filename, '#SBATCH -t 23:00:00','-append','delimiter','');            
        dlmwrite(filename, ['#SBATCH -o "' logfile '"'],'-append','delimiter','');
        dlmwrite(filename, '#SBATCH --mem-per-cpu=10000','-append','delimiter','');
        dlmwrite(filename, ['cd ' toolboxpath],'-append','delimiter','');
        dlmwrite(filename, 'module load R','-append','delimiter','');
        %command
%         dlmwrite(filename,sprintf('Rscript bcca.r "%s/hyper/%s/%s/%s/cfg.mat"',cfg.dataroot,cfg.token,cfg.sender,cfg.receiver),'-append','delimiter','');
        dlmwrite(filename,sprintf('Rscript bcca_final.r "%s/hyper/%s/%s/%s/cfg.mat"',cfg.dataroot,cfg.token,cfg.sender,cfg.receiver),'-append','delimiter','');
        unix(['sbatch ' filename]);
    end
end




