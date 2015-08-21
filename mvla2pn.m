function mvla2pn(cfgpath)
load(cfgpath);
addpath(genpath('/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/MVLA'));
addpath(genpath('/triton/becs/scratch/braindata/shared/toolboxes/hyperclassification-tools'));
addpath(genpath('/triton/becs/scratch/braindata/shared/BML_utilities'));
addpath('/triton/becs/scratch/braindata/shared/toolboxes/NIFTI');
% scales
lambda = cfg.lambda;
% labels
if isfield(cfg,'regressor')
    % If there is regressor in cfg, we assume you want labels to be recomputed
    cfg = HyperTaskModel(cfg);
    labels = cfg.dL2;
else
    % If you have labels from within classifier
    load(sprintf('%s/%s/dL2.mat',cfg.dataroot,cfg.receiver));
    labels = tosave;
end
% number of classes
ncond = cfg.ntask;
n_per_run = length(labels)/cfg.nruns; 
%% Load the data
data_actor = load(sprintf('%s/Tokens/%s/%s_4mm.mat',cfg.dataroot,cfg.token,cfg.sender)); data_actor = data_actor.dO;
data_observer = load(sprintf('%s/hyper/%s/%s/%s/data.mat',cfg.dataroot,cfg.token,cfg.sender,cfg.receiver)); data_observer = data_observer.fullmaskprojection;
%% Acquire the best scale in cross-validation framework
preds = cell(length(lambda),1);
for cv = 1:cfg.nruns
    for c = 1:cfg.ntask % for each task/condition
        clear f
        f = ft_mv_blogreg_edit2('scale', lambda);
        clear objs
        % prepare data
        % category of interest is always 1, other are always 2
        [x,xt,y,~] = HypercvLabelSet(labels,data_actor,data_observer,c,cv,n_per_run);
        [~, objs] = f.train(x,y);
        %% if some lambda failed, cleanup
        [objs,preds,lambda] = checkLambdaCell(objs,preds,lambda);
        %% Collect results
        for e = 1:length(lambda)
            f = objs{e}; % take f object for each scale
            yp = f.test(xt); % test the model using the run left out
            % preds has a column for each class
            preds{e}((1:n_per_run) + (cv-1)*n_per_run,c) = yp(:,1); % save the probabilities for this class, for this cv           
        end
    end
end
%% Assess the results
for r = 1:length(preds) % for each scale
    preds_normalized = preds{r}./repmat(sum(preds{r},2),1,ncond); % so that they sum to 1
    [~,maxclass] = max(preds_normalized,[],2);
    % classification accuracy
    success = (maxclass == labels);
    rate(r,1) = mean(success);
    % mlpp
    % probrightclass - probability assigned to the correct class
    for i = 1:length(labels)
        probrightclass(i,1) = preds_normalized(i,labels(i));
    end
    info(r,1) = mean(log(probrightclass));
end
%% find best scale, based on rate
% bestlambdaidx = find(info==max(info)); % keep the one which has better predictive rate
bestlambdaidx = find(rate==max(rate)); 
if length(bestlambdaidx) > 1 % if a draw
    bestlambdaidx = find(info==max(info)); % best based on accuracy
end
if length(bestlambdaidx) > 1
    bestlambdaidx = bestlambdaidx(1); % if still a draw, take just the first one
end
% save outputs at this stage
retval.preds = preds;
retval.accuracy = rate(bestlambdaidx);
retval.lambda = bestlambdaidx;
retval.cls = objs{bestlambdaidx};
retval.mlpp = info(bestlambdaidx);
retval.lamdarate = rate;
retval.lambdamlpp = info;
%% For pictures
% Run model with all the data, no CV
% According to toy example, higher probabilities work towards class 1 vs class 2
% We get importance maps for actor! Use projection to transform them to observer.
% Projection is acquired elsewhere, better to be done without CV
bestlambda = lambda(bestlambdaidx);
for c = 1:ncond
    clear f
    f = ft_mv_blogreg('scale', bestlambda);
    % take all data of actor
    x = data_actor;
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
save(sprintf('%s/hyper/%s/%s/%s/results.mat',cfg.dataroot,cfg.token,cfg.sender,cfg.receiver),'retval','-v7.3');


% %% Execute with the best scale, collect accuracy
% clear preds
% for cv = 1:nruns
%     for c = 1:4
%         clear f
%         f = ft_mv_blogreg('scale',bestlambda);
%         % category of interest is always 1, other are always 2
%         [x,xt,y,yt] = cvLabelSet(labels,data,c,cv,n_per_run);
%         f = f.train(x,y);
%         %% Collect results
%         yp = f.test(xt); % test the model using the run left out
%         % preds - for each timepoint we have a probability of it falling into a certain class
%         preds((1:n_per_run) + (cv-1)*n_per_run,c) = yp(:,1); % save the probabilities for this class.
%     end
% end 
% % probrightclass probability assigned to the correct class
% for i = 1:360
%     probrightclass(i) = preds(i,dL2(i));
% end
%% Toy example to test direction of probs vec
% addpath(genpath('/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/MVLA'));
% lambda = logspace(-6,2,7);
% toyy = [ones(10,1); ones(10,1)*2];
% toyx = ones(20,40);
% toyx(1:10,[3 4 8]) = 2;
% toyx(11:20,[1,5,18]) = 2;
% f = ft_mv_blogreg_edit2('scale', lambda);
% [~, objs] = f.train(toyx,toyy);
% for r = 1:length(lambda)
%     f = objs{r};
%     probs{r} = 1-normcdf(0,f.Gauss.m(1:end-1),sqrt(f.Gauss.diagC(1:end-1))); % impmap, calculate without crossval
% end







