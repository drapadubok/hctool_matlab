function KNN(cfgpath)
load(cfgpath);
addpath('/triton/becs/scratch/braindata/shared/toolboxes/NIFTI');
addpath(genpath('/triton/becs/scratch/braindata/shared/BML_utilities'));
addpath('/triton/becs/scratch/braindata/shared/toolboxes/hyperclassification-tools');
%% hardcoded mask
[XX,YY,ZZ]=ndgrid(1:46,1:55,1:46);
[pathstr,name,~] = fileparts(cfg.maskfile);
outputpath = [pathstr '/' name '4mm.nii'];
mask = load_nii(outputpath); % load 4mm mask
mask = sign(mask.img);
midx = find(mask);
dA = [];
dO = [];
% Labels
labels = load(sprintf('%s/%s/dL2.mat',cfg.dataroot,cfg.sender)); labels = labels.tosave;
n_per_run = length(labels)/cfg.nruns;
for r = 1:cfg.nruns
    % Actor
    clear temp4mm
    temp4mm = load_nii(sprintf('%s/downsampled/%s/run%i/epi4mm.nii',cfg.dataroot,cfg.sender,r)); % load data    
    if cfg.varntr % if size is different
        temp4mm.img(:,:,:,cfg.NTR_b(r)+1:end) = []; % drop end
        temp4mm = temp4mm.img(:,:,:,find(cfg.dL3_b{r})); % drop labelless
    else
        temp4mm.img(:,:,:,cfg.NTR(r)+1:end) = []; % drop end
        temp4mm = temp4mm.img(:,:,:,find(cfg.dL3{r})); % drop labelless
    end
    temp4mm = zscore(temp4mm,[],4); % zscore
    temp4mm = reshape(temp4mm,[],n_per_run);
    temp4mm = temp4mm(midx,:);
    dA = cat(3,dA,temp4mm);
    % Observer
    clear temp4mm
    temp4mm = load_nii(sprintf('%s/downsampled/%s/run%i/epi4mm.nii',cfg.dataroot,cfg.receiver,r)); % load data
    temp4mm.img(:,:,:,cfg.NTR(r)+1:end) = []; % drop end
    temp4mm = temp4mm.img(:,:,:,find(cfg.dL3{r})); % drop labelless
    temp4mm = zscore(temp4mm,[],4); % zscore
    temp4mm = reshape(temp4mm,[],n_per_run);
    temp4mm = temp4mm(midx,:);
    dO = cat(3,dO,temp4mm);
end
% Projection
clear dP
temp4mm = load(sprintf('%s/%s/%s_corrtest.mat',cfg.dataroot,cfg.receiver,cfg.token)); temp4mm = temp4mm.storedProj;
group = [];
for r = 1:cfg.nruns
    dP(:,1:n_per_run,r) = temp4mm((1:n_per_run)+(r-1)*n_per_run,:)';
    lbls(:,r) = labels((1:n_per_run)+(r-1)*n_per_run);
    for k = 1:n_per_run/cfg.TRk
        tmp(k,:) = lbls((k-1)*cfg.TRk+(1:cfg.TRk),r);
    end
    group = [group;tmp(:,1)];
end
% Split trials
clear ddP
clear ddO
clear ddA
for k=1:n_per_run/cfg.TRk
    ddP(:,1:cfg.TRk,k,:)=dP(:,(k-1)*cfg.TRk+(1:cfg.TRk),:);
    ddO(:,1:cfg.TRk,k,:)=dO(:,(k-1)*cfg.TRk+(1:cfg.TRk),:);
    ddA(:,1:cfg.TRk,k,:)=dA(:,(k-1)*cfg.TRk+(1:cfg.TRk),:);
end
%% Neighborhoods and correlations
% Take a small neighborhood 
clear cmatAO
clear cmatAP
for v = 1:length(midx)
    [x,y,z] = ind2sub([46,55,46],midx(v));
    msk = sqrt((XX-x).^2+(YY-y).^2+(ZZ-z).^2)<=1.5;
    msk = msk.*mask; % drop out of brain voxels
    tidx = find(msk(logical(mask)));
    if length(find(tidx)) > 0
%     [x,y,z]=ind2sub([46 55 46],midx(tidx));
        % group - labels for each trial for each run
        % take small number of voxels x timepoints x trials and calculate
        % ISC matrix for each trial (120 = 24 per run x 5 runs)
        tempA = squeeze(reshape(ddA(tidx,:,:,:),[],length(group)));
        tempO = squeeze(reshape(ddO(tidx,:,:,:),[],length(group)));
        tempP = squeeze(reshape(ddP(tidx,:,:,:),[],length(group)));
        cmatAO(:,:,v) = corr([tempA, tempO]);
        cmatAP(:,:,v) = corr([tempA, tempP]);
    else
        disp(v);
    end
end
% prepare the matrices for classifier (between-subject)
% First Actor and Observer
clear temp
clear tmsk
temp = reshape(cmatAO(length(group)+1:end,length(group)+1:end,:),[],size(cmatAO,3)); % take intersubject part of matrix
temp = temp(find(triu(ones(length(group)),1)),:); % take only upper triangle
tmsk = zeros(46*55*46,size(temp,1)); % get them all to 3D space
tmsk(midx,:) = temp';
tmsk = reshape(tmsk,46,55,46,size(temp,1));
[accuracyAO,resultsAO] = perspective_kNN_classification(tmsk,cfg.K,group);
% Second Actor and Observer, hyperaligned
clear temp
clear tmsk
temp = reshape(cmatAP(length(group)+1:end,length(group)+1:end,:),[],size(cmatAP,3));
temp = temp(find(triu(ones(length(group)),1)),:);
tmsk = zeros(46*55*46,size(temp,1));
tmsk(midx,:) = temp';
tmsk = reshape(tmsk,46,55,46,size(temp,1));
[accuracyAP,resultsAP] = perspective_kNN_classification(tmsk,cfg.K,group);
save(sprintf('%s/hyper/%s/%s/%s/knnresult_%i.mat',cfg.dataroot,cfg.token,cfg.sender,cfg.receiver,cfg.K),'accuracyAO','resultsAO','accuracyAP','resultsAP','-v7.3');


