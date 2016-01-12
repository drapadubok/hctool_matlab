function HyperPrepareData(cfgpath)
% Function that preprocesses data for hyperclassification
% Filenames and regressor path are partly hardcoded, need to adjust depending on preprocessing
% pipeline
% load cfg
load(cfgpath);
addpath('/triton/becs/scratch/braindata/shared/toolboxes/NIFTI');
addpath(genpath('/triton/becs/scratch/braindata/shared/BML_utilities'));
addpath(genpath(cfg.toolboxpath));
%% Downsample data from sender and receiver
for r = 1:cfg.nruns
    % Make folders
    if ~exist(sprintf('%s/run%i',cfg.temppath,r),'dir');
        mkdir(sprintf('%s/run%i',cfg.temppath,r));
    end
    inputpath = sprintf('%s/%s/run%i/%s',cfg.dataroot,cfg.subject,r,cfg.infile);
    outputpath = sprintf('%s/run%i/epi4mm.nii',cfg.temppath,r);
    downsampler(inputpath,outputpath)
end
%% Process regressor
% Regressor of type:
% regressor.run%i with ncolumns == ntask
% produces three types of label vectors and number of TRs for each run with
% suggested regressors (necessary due to common mistakes in this stage)
% load('/triton/becs/scratch/braindata/shared/GraspHyperScan/regressorObserver.mat'); % basic regressor
cfg = HyperTaskModel(cfg);
tosave = cfg.dL2;
save(sprintf('%s/%s/%s/dL2.mat',cfg.dataroot,cfg.dsampfolder,cfg.subject),'tosave'); % in case you would want them beforehand
%% Masking
for m = 1:length(cfg.masks)
    disp(m)
    [dT,name] = MaskData(cfg.masks{m},cfg);
    save(sprintf('%s/%s_data4mm.mat',cfg.temppath,name),'dT','-v7.3');
end
exit;
