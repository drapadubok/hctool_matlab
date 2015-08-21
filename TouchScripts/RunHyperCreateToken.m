clear all
close all
addpath(genpath('/triton/becs/scratch/braindata/shared/toolboxes/hyperclassification-tools'));
cfg.dsampfolder = 'downsampled';
cfg.dataroot = '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test';
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
% 'newone'
};
%% Token variants, define what kind of mask combinations you want to try
if ~exist(sprintf('%s/%s/Tokens',cfg.dataroot),'dir');
    mkdir(sprintf('%s/%s/Tokens',cfg.dataroot));
end
for s = 1:length(receivers)    
    cfg.sender = senders{1};
    cfg.receiver = receivers{s};
    %% Final
    cfg.tokenname = 'painloc_thr2';
    cfg.maskorder_sender = {'painloc_thr2'}; cfg.maskorder_receiver = {'painloc_thr2'};
    HyperCreateToken(cfg);
    
    cfg.tokenname = 'combined_loc_mask';
    cfg.maskorder_sender = {'combined_loc_mask'}; cfg.maskorder_receiver = {'combined_loc_mask'};
    HyperCreateToken(cfg);
    
    cfg.tokenname = 'FrontalPole';
    cfg.maskorder_sender = {'FrontalPole'}; cfg.maskorder_receiver = {'FrontalPole'};
    HyperCreateToken(cfg);
    
    cfg.tokenname = 'ACC';
    cfg.maskorder_sender = {'ACC'}; cfg.maskorder_receiver = {'ACC'};
    HyperCreateToken(cfg);
    
    cfg.tokenname = 'aINS';
    cfg.maskorder_sender = {'aINS'}; cfg.maskorder_receiver = {'aINS'};
    HyperCreateToken(cfg);
    
    cfg.tokenname = 'Amy';
    cfg.maskorder_sender = {'Amy'}; cfg.maskorder_receiver = {'Amy'};
    HyperCreateToken(cfg);
    
    cfg.tokenname = 'COMBINED';
    cfg.maskorder_sender = {'COMBINED'}; cfg.maskorder_receiver = {'COMBINED'};
    HyperCreateToken(cfg);
    
    cfg.tokenname = 'INS';
    cfg.maskorder_sender = {'INS'}; cfg.maskorder_receiver = {'INS'};
    HyperCreateToken(cfg);
    
    cfg.tokenname = 'ParaCC';
    cfg.maskorder_sender = {'ParaCC'}; cfg.maskorder_receiver = {'ParaCC'};
    HyperCreateToken(cfg);
    
    cfg.tokenname = 'pINS';
    cfg.maskorder_sender = {'pINS'}; cfg.maskorder_receiver = {'pINS'};
    HyperCreateToken(cfg);
    
    cfg.tokenname = 'S1';
    cfg.maskorder_sender = {'S1'}; cfg.maskorder_receiver = {'S1'};
    HyperCreateToken(cfg);
    
    cfg.tokenname = 'S2';
    cfg.maskorder_sender = {'S2'}; cfg.maskorder_receiver = {'S2'};
    HyperCreateToken(cfg);
    
    cfg.tokenname = 'Thalamus';
    cfg.maskorder_sender = {'Thalamus'}; cfg.maskorder_receiver = {'Thalamus'};
    HyperCreateToken(cfg);
    
     
    %% Some more from Dima
%     cfg.tokenname = 'aACC';
%     cfg.maskorder_sender = {'aACC'}; cfg.maskorder_receiver = {'aACC'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'ACC';
%     cfg.maskorder_sender = {'ACC'}; cfg.maskorder_receiver = {'ACC'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'lCereb';
%     cfg.maskorder_sender = {'lCereb'}; cfg.maskorder_receiver = {'lCereb'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'rCereb';
%     cfg.maskorder_sender = {'rCereb'}; cfg.maskorder_receiver = {'rCereb'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'mACC';
%     cfg.maskorder_sender = {'mACC'}; cfg.maskorder_receiver = {'mACC'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'virtual_lesion';
%     cfg.maskorder_sender = {'virtual_lesion'}; cfg.maskorder_receiver = {'virtual_lesion'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'lIns';
%     cfg.maskorder_sender = {'lIns'}; cfg.maskorder_receiver = {'lIns'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'lIns2';
%     cfg.maskorder_sender = {'lIns2'}; cfg.maskorder_receiver = {'lIns2'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'rIns';
%     cfg.maskorder_sender = {'rIns'}; cfg.maskorder_receiver = {'rIns'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'rIns2';
%     cfg.maskorder_sender = {'rIns2'}; cfg.maskorder_receiver = {'rIns2'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'lS2';
%     cfg.maskorder_sender = {'lS2'}; cfg.maskorder_receiver = {'lS2'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'rS2';
%     cfg.maskorder_sender = {'rS2'}; cfg.maskorder_receiver = {'rS2'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'SMA';
%     cfg.maskorder_sender = {'SMA'}; cfg.maskorder_receiver = {'SMA'};
%     HyperCreateToken(cfg);
    %% Virtual lesion approach
%     cfg.tokenname = 'without_aACC';
%     cfg.maskorder_sender = {'ACC','lCereb','rCereb','mACC','lIns','lIns2','rIns','rIns2','lS2','rS2','SMA'}; cfg.maskorder_receiver = {'ACC','lCereb','rCereb','mACC','lIns','lIns2','rIns','rIns2','lS2','rS2','SMA'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'without_ACC';
%     cfg.maskorder_sender = {'aACC','lCereb','rCereb','mACC','lIns','lIns2','rIns','rIns2','lS2','rS2','SMA'}; cfg.maskorder_receiver = {'aACC','lCereb','rCereb','mACC','lIns','lIns2','rIns','rIns2','lS2','rS2','SMA'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'without_lCereb';
%     cfg.maskorder_sender = {'aACC','ACC','rCereb','mACC','lIns','lIns2','rIns','rIns2','lS2','rS2','SMA'}; cfg.maskorder_receiver = {'aACC','ACC','rCereb','mACC','lIns','lIns2','rIns','rIns2','lS2','rS2','SMA'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'without_rCereb';
%     cfg.maskorder_sender = {'aACC','ACC','lCereb','mACC','lIns','lIns2','rIns','rIns2','lS2','rS2','SMA'}; cfg.maskorder_receiver = {'aACC','ACC','lCereb','mACC','lIns','lIns2','rIns','rIns2','lS2','rS2','SMA'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'without_mACC';
%     cfg.maskorder_sender = {'aACC','ACC','lCereb','rCereb','lIns','lIns2','rIns','rIns2','lS2','rS2','SMA'}; cfg.maskorder_receiver = {'aACC','ACC','lCereb','rCereb','lIns','lIns2','rIns','rIns2','lS2','rS2','SMA'};
%     HyperCreateToken(cfg);    
%     cfg.tokenname = 'without_wholeACC';
%     cfg.maskorder_sender = {'lCereb','rCereb','lIns','lIns2','rIns','rIns2','lS2','rS2','SMA'}; cfg.maskorder_receiver = {'lCereb','rCereb','lIns','lIns2','rIns','rIns2','lS2','rS2','SMA'};
%     HyperCreateToken(cfg);    
%     cfg.tokenname = 'without_lIns';
%     cfg.maskorder_sender = {'aACC','ACC','lCereb','rCereb','mACC','rIns','rIns2','lS2','rS2','SMA'}; cfg.maskorder_receiver = {'aACC','ACC','lCereb','rCereb','mACC','rIns','rIns2','lS2','rS2','SMA'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'without_rIns';
%     cfg.maskorder_sender = {'aACC','ACC','lCereb','rCereb','mACC','lIns','lIns2','lS2','rS2','SMA'}; cfg.maskorder_receiver = {'aACC','ACC','lCereb','rCereb','mACC','lIns','lIns2','lS2','rS2','SMA'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'without_bothIns';
%     cfg.maskorder_sender = {'aACC','ACC','lCereb','rCereb','mACC','lS2','rS2','SMA'}; cfg.maskorder_receiver = {'aACC','ACC','lCereb','rCereb','mACC','lS2','rS2','SMA'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'without_lS2';
%     cfg.maskorder_sender = {'aACC','ACC','lCereb','rCereb','mACC','lIns','lIns2','rIns','rIns2','rS2','SMA'}; cfg.maskorder_receiver = {'aACC','ACC','lCereb','rCereb','mACC','lIns','lIns2','rIns','rIns2','rS2','SMA'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'without_rS2';
%     cfg.maskorder_sender = {'aACC','ACC','lCereb','rCereb','mACC','lIns','lIns2','rIns','rIns2','lS2','SMA'}; cfg.maskorder_receiver = {'aACC','ACC','lCereb','rCereb','mACC','lIns','lIns2','rIns','rIns2','lS2','SMA'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'without_SMA';
%     cfg.maskorder_sender = {'aACC','ACC','lCereb','rCereb','mACC','lIns','lIns2','rIns','rIns2','lS2','rS2'}; cfg.maskorder_receiver = {'aACC','ACC','lCereb','rCereb','mACC','lIns','lIns2','rIns','rIns2','lS2','rS2'};
%     HyperCreateToken(cfg);    
    %%
    %

    %
%     cfg.tokenname = 'SMAb';
%     cfg.maskorder_sender = {'SMAb'}; cfg.maskorder_receiver = {'SMAb'};
%     HyperCreateToken(cfg);
    %
%       cfg.tokenname = 'somatoInsulaACC';
%     cfg.maskorder_sender = {'somatoInsulaACC'}; cfg.maskorder_receiver = {'somatoInsulaACC'};
%     HyperCreateToken(cfg);
%     %
%        cfg.tokenname = 'InsularCxb';
%     cfg.maskorder_sender = {'InsularCxb'}; cfg.maskorder_receiver = {'InsularCxb'};
%     HyperCreateToken(cfg);
    %
%        cfg.tokenname = 'CingulateGyrus_antdivb';
%     cfg.maskorder_sender = {'CingulateGyrus_antdivb'}; cfg.maskorder_receiver = {'CingulateGyrus_antdivb'};
%     HyperCreateToken(cfg);
%     %
%        cfg.tokenname = 'CerebInsulaACC';
%     cfg.maskorder_sender = {'CerebInsulaACC'}; cfg.maskorder_receiver = {'CerebInsulaACC'};
%     HyperCreateToken(cfg);
%     %
%      cfg.tokenname = 'CerebSMAS2InsulaACC';
%     cfg.maskorder_sender = {'CerebSMAS2InsulaACC'}; cfg.maskorder_receiver = {'CerebSMAS2InsulaACC'};
%     HyperCreateToken(cfg);
    %      
%     cfg.tokenname = 'empathy_pAgF';
%     cfg.maskorder_sender = {'empathy_pAgF_z_FDR_0.01'}; cfg.maskorder_receiver = {'empathy_pAgF_z_FDR_0.01'};
%     HyperCreateToken(cfg);
%     %
%     cfg.tokenname = 'empathy_pFgA';
%     cfg.maskorder_sender = {'empathy_pFgA_z_FDR_0.01'}; cfg.maskorder_receiver = {'empathy_pFgA_z_FDR_0.01'};
%     HyperCreateToken(cfg);
%     %
%     cfg.tokenname = 'pain_pAgF';
%     cfg.maskorder_sender = {'pain_pAgF_z_FDR_0.01'}; cfg.maskorder_receiver = {'pain_pAgF_z_FDR_0.01'};
%     HyperCreateToken(cfg);
%     %
%     cfg.tokenname = 'pain_pFgA';
%     cfg.maskorder_sender = {'pain_pFgA_z_FDR_0.01'}; cfg.maskorder_receiver = {'pain_pFgA_z_FDR_0.01'};
%     HyperCreateToken(cfg);
%     %
%     cfg.tokenname = 'Touch_pAgF';
%     cfg.maskorder_sender = {'Touch_pAgF_z_FDR_0.01'}; cfg.maskorder_receiver = {'Touch_pAgF_z_FDR_0.01'};
%     HyperCreateToken(cfg);
%     %
%     cfg.tokenname = 'Touch_pFgA';
%     cfg.maskorder_sender = {'/Touch_pFgA_z_FDR_0.01'}; cfg.maskorder_receiver = {'/Touch_pFgA_z_FDR_0.01'};
%     HyperCreateToken(cfg);
%     %%
%     cfg.tokenname = 'combined_localizer';
%     cfg.maskorder_sender = {'combined_loc_mask'}; cfg.maskorder_receiver = {'combined_loc_mask'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'tactile';
%     cfg.maskorder_sender = {'tactile_pAgF_z_FDR_0.05'}; cfg.maskorder_receiver = {'tactile_pAgF_z_FDR_0.05'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'somatotopic';
%     cfg.maskorder_sender = {'somatotopic_pAgF_z_FDR_0.05'}; cfg.maskorder_receiver = {'somatotopic_pAgF_z_FDR_0.05'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'aon50';
%     cfg.maskorder_sender = {'aon50'}; cfg.maskorder_receiver = {'aon50'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'prim_somatosens';
%     cfg.maskorder_sender = {'prim_somatosens'}; cfg.maskorder_receiver = {'prim_somatosens'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'sec_somatosens';
%     cfg.maskorder_sender = {'second_somatosens'}; cfg.maskorder_receiver = {'second_somatosens'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'prim_sec_somatosens';
%     cfg.maskorder_sender = {'prim_somatosens','second_somatosens'}; cfg.maskorder_receiver = {'prim_somatosens','second_somatosens'};
%     HyperCreateToken(cfg);    
%     %% Whole
%     cfg.tokenname = 'Whole';
%     cfg.maskorder_sender = {'whole_GM'}; cfg.maskorder_receiver = {'whole_GM'};
%     HyperCreateToken(cfg);
%     %%
%     cfg.tokenname = 'MOTOR';
%     cfg.maskorder_sender = {'MOTOR'}; cfg.maskorder_receiver = {'MOTOR'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'LOC';
%     cfg.maskorder_sender = {'LOC'}; cfg.maskorder_receiver = {'LOC'};
%     HyperCreateToken(cfg);    
%     %% Main analysis
%     cfg.tokenname = 'mirrormask';
%     cfg.maskorder_sender = {'mirrormask'}; cfg.maskorder_receiver = {'mirrormask'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'painful';
%     cfg.maskorder_sender = {'painful_pAgF_z_FDR_0.05'}; cfg.maskorder_receiver = {'painful_pAgF_z_FDR_0.05'};
%     HyperCreateToken(cfg);
%     %% Validation ROIs
%     cfg.tokenname = 'CingularCortex';
%     cfg.maskorder_sender = {'cingularROI'}; cfg.maskorder_receiver = {'cingularROI'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'FrontalPole';
%     cfg.maskorder_sender = {'FrontalPole'}; cfg.maskorder_receiver = {'FrontalPole'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'TemporalCortex';
%     cfg.maskorder_sender = {'temporalROI'}; cfg.maskorder_receiver = {'temporalROI'};
%     HyperCreateToken(cfg);
%     %% Other
%     %% Localizer based virtual lesion + Broca's area
%     % Full
%     cfg.tokenname = 'virtual_lesion';
%     cfg.maskorder_sender = {'virtual_lesion'}; cfg.maskorder_receiver = {'virtual_lesion'};
%     HyperCreateToken(cfg);
%     % Separate
%     cfg.tokenname = 'alLOC';
%     cfg.maskorder_sender = {'alLOC'}; cfg.maskorder_receiver = {'alLOC'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'arLOC';
%     cfg.maskorder_sender = {'arLOC'}; cfg.maskorder_receiver = {'arLOC'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'rSMG';
%     cfg.maskorder_sender = {'rSMG'}; cfg.maskorder_receiver = {'rSMG'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'srLOC';
%     cfg.maskorder_sender = {'srLOC'}; cfg.maskorder_receiver = {'srLOC'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'slLOC';
%     cfg.maskorder_sender = {'slLOC'}; cfg.maskorder_receiver = {'slLOC'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'lSPL';
%     cfg.maskorder_sender = {'lSPL'}; cfg.maskorder_receiver = {'lSPL'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'rSPL';
%     cfg.maskorder_sender = {'rSPL'}; cfg.maskorder_receiver = {'rSPL'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'rPrecentral';
%     cfg.maskorder_sender = {'rPrecentral'}; cfg.maskorder_receiver = {'rPrecentral'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'lPrecentral';
%     cfg.maskorder_sender = {'lPrecentral'}; cfg.maskorder_receiver = {'lPrecentral'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'lBroca';
%     cfg.maskorder_sender = {'lBroca'}; cfg.maskorder_receiver = {'lBroca'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'rBroca';
%     cfg.maskorder_sender = {'rBroca'}; cfg.maskorder_receiver = {'rBroca'};
%     HyperCreateToken(cfg);
%     % Together
%     cfg.tokenname = 'without_alLOC';
%     cfg.maskorder_sender = {'arLOC','rSMG','srLOC','slLOC','lSPL','rSPL','rPrecentral','lPrecentral','lBroca','rBroca'}; cfg.maskorder_receiver = {'arLOC','rSMG','srLOC','slLOC','lSPL','rSPL','rPrecentral','lPrecentral','lBroca','rBroca'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'without_arLOC';
%     cfg.maskorder_sender = {'alLOC','rSMG','srLOC','slLOC','lSPL','rSPL','rPrecentral','lPrecentral','lBroca','rBroca'}; cfg.maskorder_receiver = {'alLOC','rSMG','srLOC','slLOC','lSPL','rSPL','rPrecentral','lPrecentral','lBroca','rBroca'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'without_rSMG';
%     cfg.maskorder_sender = {'alLOC','arLOC','srLOC','slLOC','lSPL','rSPL','rPrecentral','lPrecentral','lBroca','rBroca'}; cfg.maskorder_receiver = {'alLOC','arLOC','srLOC','slLOC','lSPL','rSPL','rPrecentral','lPrecentral','lBroca','rBroca'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'without_srLOC';
%     cfg.maskorder_sender = {'alLOC','arLOC','rSMG','slLOC','lSPL','rSPL','rPrecentral','lPrecentral','lBroca','rBroca'}; cfg.maskorder_receiver = {'alLOC','arLOC','rSMG','slLOC','lSPL','rSPL','rPrecentral','lPrecentral','lBroca','rBroca'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'without_slLOC';
%     cfg.maskorder_sender = {'alLOC','arLOC','rSMG','srLOC','lSPL','rSPL','rPrecentral','lPrecentral','lBroca','rBroca'}; cfg.maskorder_receiver = {'alLOC','arLOC','rSMG','srLOC','lSPL','rSPL','rPrecentral','lPrecentral','lBroca','rBroca'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'without_lSPL';
%     cfg.maskorder_sender = {'alLOC','arLOC','rSMG','srLOC','slLOC','rSPL','rPrecentral','lPrecentral','lBroca','rBroca'}; cfg.maskorder_receiver = {'alLOC','arLOC','rSMG','srLOC','slLOC','rSPL','rPrecentral','lPrecentral','lBroca','rBroca'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'without_rSPL';
%     cfg.maskorder_sender = {'alLOC','arLOC','rSMG','srLOC','slLOC','lSPL','rPrecentral','lPrecentral','lBroca','rBroca'}; cfg.maskorder_receiver = {'alLOC','arLOC','rSMG','srLOC','slLOC','lSPL','rPrecentral','lPrecentral','lBroca','rBroca'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'without_rPrecentral';
%     cfg.maskorder_sender = {'alLOC','arLOC','rSMG','srLOC','slLOC','lSPL','rSPL','lPrecentral','lBroca','rBroca'}; cfg.maskorder_receiver = {'alLOC','arLOC','rSMG','srLOC','slLOC','lSPL','rSPL','lPrecentral','lBroca','rBroca'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'without_lPrecentral';
%     cfg.maskorder_sender = {'alLOC','arLOC','rSMG','srLOC','slLOC','lSPL','rSPL','rPrecentral','lBroca','rBroca'}; cfg.maskorder_receiver = {'alLOC','arLOC','rSMG','srLOC','slLOC','lSPL','rSPL','rPrecentral','lBroca','rBroca'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'without_lBroca';
%     cfg.maskorder_sender = {'alLOC','arLOC','rSMG','srLOC','slLOC','lSPL','rSPL','rPrecentral','lPrecentral','rBroca'}; cfg.maskorder_receiver = {'alLOC','arLOC','rSMG','srLOC','slLOC','lSPL','rSPL','rPrecentral','lPrecentral','rBroca'};
%     HyperCreateToken(cfg);
%     cfg.tokenname = 'without_rBroca';
%     cfg.maskorder_sender = {'alLOC','arLOC','rSMG','srLOC','slLOC','lSPL','rSPL','rPrecentral','lPrecentral','lBroca'}; cfg.maskorder_receiver = {'alLOC','arLOC','rSMG','srLOC','slLOC','lSPL','rSPL','rPrecentral','lPrecentral','lBroca'};
%     HyperCreateToken(cfg);
end
