clear all
close all
addpath('/triton/becs/scratch/braindata/shared/toolboxes/NIFTI');
addpath(genpath('/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/MVLA'));
addpath(genpath('/triton/becs/scratch/braindata/shared/BML_utilities'));
addpath(genpath('/triton/becs/scratch/braindata/shared/toolboxes/hyperclassification-tools'));
dataroot = '/triton/becs/scratch/braindata/shared/GraspHyperScan';
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% sender =  
senders = {
'Sonya_Actor';
'Fanny_Actor';
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
};
nrun = 5;
maskname = 'grasp';
fullmask = load_nii('/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/ns/grasp4mm.nii');
% maskname = 'Whole';
% fullmask = load_nii('/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/whole_GM4mm.nii');
fidx = find(fullmask.img); % fullmask indices
% Observers
for s = 1:length(receivers)
    if s == 1
        cfg.sender = senders{1};
        dataActor = load(sprintf('%s/Tokens/%s/%s_4mm.mat',dataroot,maskname,cfg.sender));
        dataActor = dataActor.dO;
    elseif s == 12
        cfg.sender = senders{2};
        dataActor = load(sprintf('%s/Tokens/%s/%s_4mm.mat',dataroot,maskname,cfg.sender));
        dataActor = dataActor.dO;
    end
    cfg.receiver = receivers{s};
    storedO = [];
    storedProj = [];
    load(sprintf('%s/%s/dL2.mat',dataroot,receivers{s}));
    labels = tosave;
    n_per_run = length(labels)/nrun;
    % Load data
    sprintf('Processing pair %i',s)
    dataObserver = load(sprintf('%s/Tokens/%s/%s_4mm.mat',dataroot,maskname,receivers{s}));
    dO = dataObserver.dO;
    for r = 1:nrun % CV framework
        % Leave one run out
        train_sel = ones(size(labels));
        test_sel = zeros(size(labels));
        train_sel((1:n_per_run) + (r-1)*n_per_run) = 0;
        test_sel((1:n_per_run) + (r-1)*n_per_run) = 1;
        % We take data in test selector, as that is the one left out
        tdO = dO(find(test_sel),:);
        % Take transformation
        cca = load(sprintf('%s/hyper/%s/%s/%s/ccafit_K50_cvi%i_4mm.mat',dataroot,maskname,sender,receivers{s},r));
        [P1,P2] = getCCAproj(cca);
        % Transform run left out
        for i = 1:size(tdO,1)
            ptdO(i,:) = P1 * tdO(i,:)';
        end
        % Store
        storedO = [storedO; tdO];
        storedProj = [storedProj; ptdO];
    end
    save(sprintf('%s/%s/%s_corrtest.mat',dataroot,receivers{s},maskname),'storedO','storedProj','-v7.3');
end




