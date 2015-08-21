function cfg = HyperTaskModel(cfg)
addpath(genpath('/triton/becs/scratch/braindata/shared/BML_utilities'));
% Given the regressor of type regressor.run%i with ncolumns == ntask,
% With 0 for rest and 1 for task.
% produces three types of label vectors and number of TRs 
if isfield(cfg,'convthresh')
    convthresh = cfg.convthresh;
else
    convthresh = 0.8;
end
dL1 = []; % column for each task
dL2 = []; % one column, task encoded by number
dL3 = []; % cell with zeros
NTR = zeros(cfg.nruns,1);
for r = 1:cfg.nruns
    clear conds_conv
    for i=1:cfg.ntask % for each condition
        % convolution with hrf is done one run at a time
        convreg = conv(twoGammaHRF(cfg.TR),cfg.regressor.(sprintf('run%i',r))(:,i));
        % the zero-padding is removed
        conds_conv(:,i) = convreg(1:size(cfg.regressor.run1,1));
        % the values are normalized
        conds_conv(:,i) = conds_conv(:,i)/max(conds_conv(:,i));
        % binarization with threshold value 0.6
        for k=1:size(conds_conv,1)
            if conds_conv(k,i) >= convthresh
                conds_conv(k,i) = 1;
            else
                conds_conv(k,i) = 0;
            end
        end
    end
    NTR(r,1) = size(conds_conv,1);
    dL3{r} = sum(conds_conv,2);
    conds_conv(~any(conds_conv,2),:) = [];
    dL1 = [dL1; conds_conv];
end
for i = 1:cfg.ntask
    dL2(:,i) = dL1(:,i)*i;
end
dL2 = sum(dL2,2);
cfg.dL1 = dL1;
cfg.dL2 = dL2;
cfg.dL3 = dL3;
cfg.NTR = NTR;
