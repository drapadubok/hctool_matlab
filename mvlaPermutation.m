function mvlaPermutation(cfgpath,shuffle_group,analysis_type,op)

sprintf('Running job from array with ID %i',op)

load(cfgpath);
addpath(genpath('/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/MVLA'));
addpath(genpath('/triton/becs/scratch/braindata/shared/toolboxes/hyperclassification-tools'));
addpath(genpath('/triton/becs/scratch/braindata/shared/BML_utilities'));
addpath('/triton/becs/scratch/braindata/shared/toolboxes/NIFTI');

%% Select correct type of analysis and corresponding labels
switch(analysis_type)
    case 'hyper'
        nperm = 10;
        load(sprintf('%s/%s/dL2.mat',cfg.dataroot,cfg.receiver));
        labels = tosave;
        data_actor = load(sprintf('%s/Tokens/%s/%s_4mm.mat',cfg.dataroot,cfg.token,cfg.sender)); data_actor = data_actor.dO;
        data_observer = load(sprintf('%s/hyper/%s/%s/%s/data.mat',cfg.dataroot,cfg.token,cfg.sender,cfg.receiver)); data_observer = data_observer.fullmaskprojection;
    case 'within'
        nperm = 10;
        cfg = HyperTaskModel(cfg);
        labels = cfg.dL2;
        [data,name] = MaskData(cfg.maskpath,cfg);
    case 'between'
        nperm = 10;
        load(sprintf('%s/%s/dL2.mat',cfg.dataroot,cfg.receiver));
        labels = tosave;
        data_actor = load(sprintf('%s/Tokens/%s/%s_4mm.mat',cfg.dataroot,cfg.token,cfg.sender)); data_actor = data_actor.dO;
        data_observer = load(sprintf('%s/Tokens/%s/%s_4mm.mat',cfg.dataroot,cfg.token,cfg.receiver)); data_observer = data_observer.dO;
    case 'hyper_cca'
        nperm = 1;
        load(sprintf('%s/%s/dL2.mat',cfg.dataroot,cfg.receiver));
        labels = tosave;
        data_actor = load(sprintf('%s/Tokens/%s/%s_4mm.mat',cfg.dataroot,cfg.token,cfg.sender)); data_actor = data_actor.dO;
        data_observer = load(sprintf('%s/hyper/%s/%s/%s/perms/dataPerm%i.mat',cfg.dataroot,cfg.token,cfg.sender,cfg.receiver,op)); data_observer = data_observer.fullmaskprojection;
end

%% Permutation, can a randomly trained classifier distinguish between our classes well enough
[status, seed] = system('od /dev/urandom --read-bytes=4 -tu | awk ''{print $2}''');
disp([status, seed]);
seed=str2double(seed);
rng(seed);

[permlabels, n_per_run] = PermShuffle(labels, cfg.nruns, nperm, shuffle_group);
rate = zeros(nperm,1);

%% Now back to the business
for p = 1:nperm
    for cv = 1:cfg.nruns
        for c = 1:cfg.ntask % for each task/condition
            clear f
            f = ft_mv_blogreg('scale', cfg.lambda);
            % prepare data
            % category of interest is always 1, other are always 2
            if strcmp(analysis_type,'between')||strcmp(analysis_type,'hyper')
                [x,xt,y,~] = HypercvLabelSet(permlabels(:,p),data_actor,data_observer,c,cv,n_per_run);
            else
                [x,xt,y,~] = cvLabelSet(permlabels(:,p),data,c,cv,n_per_run);
            end
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
    success = (maxclass == permlabels(:,p));
    rate(p,1) = mean(success);
    % save outputs at this stage
end
if strcmp(analysis_type,'between')||strcmp(analysis_type,'hyper')
    save(sprintf('%s/%s/%s/%s/%s/perms/%i.mat',cfg.dataroot,analysis_type,cfg.token,cfg.sender,cfg.receiver,op),'rate','permlabels','-v7.3');
elseif strcmp(analysis_type,'hyper_cca')
    save(sprintf('%s/%s/%s/%s/%s/perms_cca/%i.mat',cfg.dataroot,analysis_type,cfg.token,cfg.sender,cfg.receiver,op),'rate','permlabels','-v7.3');    
else    
    save(sprintf('%s/within/%s/%s/perms/%i.mat',cfg.dataroot,name,cfg.subject,op),'rate','permlabels','-v7.3');
end