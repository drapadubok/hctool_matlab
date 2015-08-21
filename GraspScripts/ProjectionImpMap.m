clear all
close all
addpath('/triton/becs/scratch/braindata/shared/toolboxes/NIFTI');
addpath('/triton/becs/scratch/braindata/shared/toolboxes/hyperclassification-tools/');
dataroot = '/triton/becs/scratch/braindata/shared/GraspHyperScan';
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
};
ncond = 4;
% mask = load_nii('/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/virtual_lesion4mm.nii');
mask = load_nii('/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/whole_GM4mm.nii');
% mask = load_nii('/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/ns/grasp4mm.nii');
maskidx = find(mask.img);
token = 'Whole';
% token = 'virtual_lesion';
% token = 'grasp';
P1 = cell(length(receivers),1);
betas = zeros(length(maskidx),length(receivers),ncond);
outmat = zeros(length(maskidx),length(receivers),ncond);
for s = 1:length(receivers)
    if s < 12
        sender = senders{1};
    else
        sender = senders{2};
    end
    receiver = receivers{s};    
    %load cca results
    clear cca
    %% Load CCA and calculate projection
    cca = load(sprintf('%s/hyper/%s/%s/%s/ccafit_K50_full_4mm.mat',dataroot,token,sender,receiver));
    iS = (eye(size(cca.WW{2},1)) + cca.tau(2) * cca.WW{2});
    [v_e,d_e] = eig(iS);
    P1{s} = cca.tau(2) * cca.W{1} * ((v_e * diag(1./diag(d_e)) * v_e') * cca.W{2}');        
    %% Project actor's impmaps into observer's space
    % i.e., if x is (m x 1) vector of observer's data (one time point), then
    % (P1 * x) is its corresponding representation in "actor's dataspace"
    cls = load(sprintf('%s/hyper/%s/%s/%s/results.mat',dataroot,token,sender,receiver));
    for c = 1:ncond
        betas(:,s,c) = cls.retval.weights{c};
        projbeta = P1{s}'*betas(:,s,c); % take actor's beta and multiply it by transposed projection
        % to test, use the betas for classification (product with test timepoint, check max, check accuracy)
        outmat(:,s,c) = projbeta;
    end
end
%% Take mean
meanoutmat = squeeze(mean(outmat,2)); % betas in observer space
meanbetas = squeeze(mean(betas,2)); % betas in actor space
meandiff = meanbetas - meanoutmat; % where did the weights 
%% Visualize
for c = 1:ncond
    %% Observers
    tmpmask = zeros(numel(mask.img),1);
    tmpmask(maskidx) = meanoutmat(:,c);
    nii = fixOriginator(make_nii(reshape(tmpmask,46,55,46)),mask);
    nii.hdr.dime.pixdim = [1 4 4 4 1 1 1 1];
    save_nii(nii,sprintf('%s/hyper/%s/O_meanbeta_c%i.nii',dataroot,token,c));
    % upsample
    upsample2mm4mm(sprintf('%s/hyper/%s/O_meanbeta_c%i.nii',dataroot,token,c),sprintf('%s/hyper/%s/O_meanbeta_c%i_2mm.nii',dataroot,token,c))
    %% Actors
    tmpmask = zeros(numel(mask.img),1);
    tmpmask(maskidx) = meanbetas(:,c);
    nii = fixOriginator(make_nii(reshape(tmpmask,46,55,46)),mask);
    nii.hdr.dime.pixdim = [1 4 4 4 1 1 1 1];
    save_nii(nii,sprintf('%s/hyper/%s/A_meanbeta_c%i.nii',dataroot,token,c));
    % upsample
    upsample2mm4mm(sprintf('%s/hyper/%s/A_meanbeta_c%i.nii',dataroot,token,c),sprintf('%s/hyper/%s/A_meanbeta_c%i_2mm.nii',dataroot,token,c))
    %% Difference of the mean of means!
    tmpmask = zeros(numel(mask.img),1);
    tmpmask(maskidx) = meandiff(:,c);
    nii = fixOriginator(make_nii(reshape(tmpmask,46,55,46)),mask);
    nii.hdr.dime.pixdim = [1 4 4 4 1 1 1 1];
    save_nii(nii,sprintf('%s/hyper/%s/diff_meanbeta_c%i.nii',dataroot,token,c));
    % upsample
    upsample2mm4mm(sprintf('%s/hyper/%s/diff_meanbeta_c%i.nii',dataroot,token,c),sprintf('%s/hyper/%s/diff_meanbeta_c%i_2mm.nii',dataroot,token,c))
end







