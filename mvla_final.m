function mvla_final(cfgpath)
load(cfgpath);
addpath(genpath('/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/MVLA'));
addpath(genpath('/triton/becs/scratch/braindata/shared/toolboxes/hyperclassification-tools'));
addpath(genpath('/triton/becs/scratch/braindata/shared/BML_utilities'));
addpath('/triton/becs/scratch/braindata/shared/toolboxes/NIFTI');
% scales
lambda = cfg.lambda;
% labels
cfg = HyperTaskModel(cfg);
% number of classes
n_per_run = length(cfg.dL2)/cfg.nruns; 
labels = cfg.dL2;
%% Prepare the data for this subject and this mask
[data,name] = MaskData(cfg.maskpath,cfg);
disp('Data preparation finished');
%% Acquire the best scale in cross-validation framework
for cv = 1:cfg.nruns
    for c = 1:cfg.ntask % for each task/condition
        clear f
        f = ft_mv_blogreg('scale', lambda);
        % prepare data
        % category of interest is always 1, other are always 2
        [x,xt,y,yt] = cvLabelSet(labels,data,c,cv,n_per_run);
        f = f.train(x,y);
        %% Collect results
        yp = f.test(xt); % test the model using the run left out
        % preds has a column for each class
        preds((1:n_per_run) + (cv-1)*n_per_run,c) = yp(:,1); % save the probabilities for this class, for this cv
    end
end
%% Assess the results
preds_normalized = preds./repmat(sum(preds,2),1,cfg.ntask); % so that they sum to 1
[~,maxclass] = max(preds_normalized,[],2);
% classification accuracy
success = (maxclass == labels);
rate = mean(success);
% mlpp
% probrightclass - probability assigned to the correct class
for i = 1:length(labels)
    probrightclass(i,1) = preds_normalized(i,labels(i));
end
info = mean(log(probrightclass));
% save outputs at this stage
retval.preds = preds;
retval.accuracy = rate;
retval.lambda = lambda;
retval.mlpp = info;
%% For pictures
for c = 1:cfg.ntask
    clear f
    f = ft_mv_blogreg('scale', lambda);
    % take all data
    x = data;
    % make proper labels
    y = zeros(size(labels));
    y(labels==c) = 1;
    y(labels~=c) = 2;
    f = f.train(x,y);
    probs{c} = 1-normcdf(0,f.Gauss.m(1:end-1),sqrt(f.Gauss.diagC(1:end-1))); % impmap, calculate without crossval
    weights{c} = f.Gauss.m(1:end-1);
end
% save outputs for picture
retval.probs = probs;
retval.weights = weights;
save(sprintf('%s/within/%s/%s/results.mat',cfg.dataroot,name,cfg.subject),'retval','-v7.3');
exit;





