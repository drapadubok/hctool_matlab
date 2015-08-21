clear all
close all
addpath(genpath('/triton/becs/scratch/braindata/shared/toolboxes/hyperclassification-tools'));
cfg.dsampfolder = 'downsampled';
cfg.dataroot = '/triton/becs/scratch/braindata/shared/GraspHyperScan';
senders = {
'Sonya_Actor';
'Fanny_Actor'
};
receivers = {
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
%% Token variants, define what kind of mask combinations you want to try
if ~exist(sprintf('%s/Tokens',cfg.dataroot),'dir');
    mkdir(sprintf('%s/Tokens',cfg.dataroot));
end
for s = 1:length(receivers)
    if s < 12
        cfg.sender = senders{1};
    else
        cfg.sender = senders{2};
    end
    cfg.receiver = receivers{s};
    %% Uri
    cfg.tokenname = 'MOTOR';
    cfg.maskorder_sender = {'MOTOR'}; cfg.maskorder_receiver = {'MOTOR'};
    HyperCreateToken(cfg);
    cfg.tokenname = 'LOC';
    cfg.maskorder_sender = {'LOC'}; cfg.maskorder_receiver = {'LOC'};
    HyperCreateToken(cfg);
    %% Whole
    cfg.tokenname = 'Whole';
    cfg.maskorder_sender = {'whole_GM'}; cfg.maskorder_receiver = {'whole_GM'};
    HyperCreateToken(cfg);
    %% Main analysis
    cfg.tokenname = 'grasp';
    cfg.maskorder_sender = {'grasp'}; cfg.maskorder_receiver = {'grasp'};
    HyperCreateToken(cfg);
    %% Localizers
    cfg.tokenname = 'Motor-to-Observation_Combined_thresholded';
    cfg.maskorder_sender = {'mlocthr'}; cfg.maskorder_receiver = {'oloccthr'};
    HyperCreateToken(cfg);
    cfg.tokenname = 'Motor-to-Observation_V1';
    cfg.maskorder_sender = {'motorloc_V1'}; cfg.maskorder_receiver = {'obsloc_contrast_V1'};
    HyperCreateToken(cfg);
    cfg.tokenname = 'OverlapLocalizer';
    cfg.maskorder_sender = {'loc_overlap2_clu'}; cfg.maskorder_receiver = {'loc_overlap2_clu'};
    HyperCreateToken(cfg);
    %% Validation ROIs
    cfg.tokenname = 'CingularCortex';
    cfg.maskorder_sender = {'cingularROI'}; cfg.maskorder_receiver = {'cingularROI'};
    HyperCreateToken(cfg);
    cfg.tokenname = 'FrontalPole';
    cfg.maskorder_sender = {'FrontalPole'}; cfg.maskorder_receiver = {'FrontalPole'};
    HyperCreateToken(cfg);
    cfg.tokenname = 'TemporalCortex';
    cfg.maskorder_sender = {'temporalROI'}; cfg.maskorder_receiver = {'temporalROI'};
    HyperCreateToken(cfg);
    %% Other
    %% Localizer based virtual lesion + Broca's area
    % Full
    cfg.tokenname = 'virtual_lesion';
    cfg.maskorder_sender = {'virtual_lesion'}; cfg.maskorder_receiver = {'virtual_lesion'};
    HyperCreateToken(cfg);
    % Separate
    cfg.tokenname = 'alLOC';
    cfg.maskorder_sender = {'alLOC'}; cfg.maskorder_receiver = {'alLOC'};
    HyperCreateToken(cfg);
    cfg.tokenname = 'arLOC';
    cfg.maskorder_sender = {'arLOC'}; cfg.maskorder_receiver = {'arLOC'};
    HyperCreateToken(cfg);
    cfg.tokenname = 'rSMG';
    cfg.maskorder_sender = {'rSMG'}; cfg.maskorder_receiver = {'rSMG'};
    HyperCreateToken(cfg);
    cfg.tokenname = 'srLOC';
    cfg.maskorder_sender = {'srLOC'}; cfg.maskorder_receiver = {'srLOC'};
    HyperCreateToken(cfg);
    cfg.tokenname = 'slLOC';
    cfg.maskorder_sender = {'slLOC'}; cfg.maskorder_receiver = {'slLOC'};
    HyperCreateToken(cfg);
    cfg.tokenname = 'lSPL';
    cfg.maskorder_sender = {'lSPL'}; cfg.maskorder_receiver = {'lSPL'};
    HyperCreateToken(cfg);
    cfg.tokenname = 'rSPL';
    cfg.maskorder_sender = {'rSPL'}; cfg.maskorder_receiver = {'rSPL'};
    HyperCreateToken(cfg);
    cfg.tokenname = 'rPrecentral';
    cfg.maskorder_sender = {'rPrecentral'}; cfg.maskorder_receiver = {'rPrecentral'};
    HyperCreateToken(cfg);
    cfg.tokenname = 'lPrecentral';
    cfg.maskorder_sender = {'lPrecentral'}; cfg.maskorder_receiver = {'lPrecentral'};
    HyperCreateToken(cfg);
    cfg.tokenname = 'lBroca';
    cfg.maskorder_sender = {'lBroca'}; cfg.maskorder_receiver = {'lBroca'};
    HyperCreateToken(cfg);
    cfg.tokenname = 'rBroca';
    cfg.maskorder_sender = {'rBroca'}; cfg.maskorder_receiver = {'rBroca'};
    HyperCreateToken(cfg);
    % Together
    cfg.tokenname = 'without_alLOC';
    cfg.maskorder_sender = {'arLOC','rSMG','srLOC','slLOC','lSPL','rSPL','rPrecentral','lPrecentral','lBroca','rBroca'}; cfg.maskorder_receiver = {'arLOC','rSMG','srLOC','slLOC','lSPL','rSPL','rPrecentral','lPrecentral','lBroca','rBroca'};
    HyperCreateToken(cfg);
    cfg.tokenname = 'without_arLOC';
    cfg.maskorder_sender = {'alLOC','rSMG','srLOC','slLOC','lSPL','rSPL','rPrecentral','lPrecentral','lBroca','rBroca'}; cfg.maskorder_receiver = {'alLOC','rSMG','srLOC','slLOC','lSPL','rSPL','rPrecentral','lPrecentral','lBroca','rBroca'};
    HyperCreateToken(cfg);
    cfg.tokenname = 'without_rSMG';
    cfg.maskorder_sender = {'alLOC','arLOC','srLOC','slLOC','lSPL','rSPL','rPrecentral','lPrecentral','lBroca','rBroca'}; cfg.maskorder_receiver = {'alLOC','arLOC','srLOC','slLOC','lSPL','rSPL','rPrecentral','lPrecentral','lBroca','rBroca'};
    HyperCreateToken(cfg);
    cfg.tokenname = 'without_srLOC';
    cfg.maskorder_sender = {'alLOC','arLOC','rSMG','slLOC','lSPL','rSPL','rPrecentral','lPrecentral','lBroca','rBroca'}; cfg.maskorder_receiver = {'alLOC','arLOC','rSMG','slLOC','lSPL','rSPL','rPrecentral','lPrecentral','lBroca','rBroca'};
    HyperCreateToken(cfg);
    cfg.tokenname = 'without_slLOC';
    cfg.maskorder_sender = {'alLOC','arLOC','rSMG','srLOC','lSPL','rSPL','rPrecentral','lPrecentral','lBroca','rBroca'}; cfg.maskorder_receiver = {'alLOC','arLOC','rSMG','srLOC','lSPL','rSPL','rPrecentral','lPrecentral','lBroca','rBroca'};
    HyperCreateToken(cfg);
    cfg.tokenname = 'without_lSPL';
    cfg.maskorder_sender = {'alLOC','arLOC','rSMG','srLOC','slLOC','rSPL','rPrecentral','lPrecentral','lBroca','rBroca'}; cfg.maskorder_receiver = {'alLOC','arLOC','rSMG','srLOC','slLOC','rSPL','rPrecentral','lPrecentral','lBroca','rBroca'};
    HyperCreateToken(cfg);
    cfg.tokenname = 'without_rSPL';
    cfg.maskorder_sender = {'alLOC','arLOC','rSMG','srLOC','slLOC','lSPL','rPrecentral','lPrecentral','lBroca','rBroca'}; cfg.maskorder_receiver = {'alLOC','arLOC','rSMG','srLOC','slLOC','lSPL','rPrecentral','lPrecentral','lBroca','rBroca'};
    HyperCreateToken(cfg);
    cfg.tokenname = 'without_rPrecentral';
    cfg.maskorder_sender = {'alLOC','arLOC','rSMG','srLOC','slLOC','lSPL','rSPL','lPrecentral','lBroca','rBroca'}; cfg.maskorder_receiver = {'alLOC','arLOC','rSMG','srLOC','slLOC','lSPL','rSPL','lPrecentral','lBroca','rBroca'};
    HyperCreateToken(cfg);
    cfg.tokenname = 'without_lPrecentral';
    cfg.maskorder_sender = {'alLOC','arLOC','rSMG','srLOC','slLOC','lSPL','rSPL','rPrecentral','lBroca','rBroca'}; cfg.maskorder_receiver = {'alLOC','arLOC','rSMG','srLOC','slLOC','lSPL','rSPL','rPrecentral','lBroca','rBroca'};
    HyperCreateToken(cfg);
    cfg.tokenname = 'without_lBroca';
    cfg.maskorder_sender = {'alLOC','arLOC','rSMG','srLOC','slLOC','lSPL','rSPL','rPrecentral','lPrecentral','rBroca'}; cfg.maskorder_receiver = {'alLOC','arLOC','rSMG','srLOC','slLOC','lSPL','rSPL','rPrecentral','lPrecentral','rBroca'};
    HyperCreateToken(cfg);
    cfg.tokenname = 'without_rBroca';
    cfg.maskorder_sender = {'alLOC','arLOC','rSMG','srLOC','slLOC','lSPL','rSPL','rPrecentral','lPrecentral','lBroca'}; cfg.maskorder_receiver = {'alLOC','arLOC','rSMG','srLOC','slLOC','lSPL','rSPL','rPrecentral','lPrecentral','lBroca'};
    HyperCreateToken(cfg);
end
