function [dT,name] = MaskData(maskfile,cfg)
addpath('/triton/becs/scratch/braindata/shared/toolboxes/NIFTI');
%% downsample the mask
[pathstr,name,~] = fileparts(maskfile);
if cfg.downsamp
    setenv('FSLOUTPUTTYPE','NIFTI')
    outputpath = [pathstr '/' name '4mm.nii'];
    if exist(outputpath,'file') == 0 % if it doesn't exist, downsample it
        system(sprintf('fslmaths %s -subsamp2 %s',maskfile,outputpath));
    end
else
    outputpath = maskfile;
end
%% Prep the mask
mask = load_nii(outputpath); % load 4mm mask
mask.img = sign(mask.img);
maskidx = find(mask.img);
%% load the data, mask it, drop labelless, zscore
% make sure there is equal NTR for all runs
if length(unique(cfg.NTR)) > 1
    error('Your regressors included different number of TRs for different runs')
end
datatemp = [];
dT = [];
for r = 1:cfg.nruns
    if cfg.downsamp
        temp4mm = load_nii(sprintf('%s/%s/%s/run%i/epi4mm.nii',cfg.dataroot,cfg.dsampfolder,cfg.subject,r));
        temp4mm.img(:,:,:,cfg.NTR(r)+1:end) = [];
        datatemp{r} = reshape(temp4mm.img,[],size(temp4mm.img,4));
    else
        % hardcoded name
        temp = load_nii(sprintf('%s/%s/run%i/epi_preprocessed.nii',cfg.dataroot,cfg.subject,r));
        temp.img(:,:,:,cfg.NTR(r)+1:end) = [];
        datatemp{r} = reshape(temp.img,[],size(temp.img,4));
    end
    % Sender
    datatemp{r} = datatemp{r}(maskidx,:); % mask
    datatemp{r} = datatemp{r}(:,find(cfg.dL3{r})); % drop labelless
    datatemp{r} = zscore(datatemp{r}'); % zscore
    dT = [dT; datatemp{r}];
end
