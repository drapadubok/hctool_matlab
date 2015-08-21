clear all
close all
addpath('/triton/becs/scratch/braindata/shared/toolboxes/NIFTI');
addpath('/triton/becs/scratch/braindata/shared/toolboxes/hyperclassification-tools/');
dataroot = '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test';
senders = {'TouchActV5'};
receivers = {
'obs3july'
'obs4july'
'obs7july'
'obs10july'
'obs15july'
'obs15may'
'obs16july'
'obs16may'
'obs22may'
'obs23june1'
'obs23june2'
'obs25july'
};
ncond = 4;
% token = 'Whole';
% mask = load_nii('/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/whole_GM4mm.nii');
token = 'combined_localizer';
mask = load_nii('/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/combined_loc_mask4mm.nii');
% token = 'CerebSMAS2InsulaACC';
% mask = load_nii('/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/maskFromFSL/CerebSMAS2InsulaACC4mm.nii');
maskidx = find(mask.img);
P1 = cell(length(receivers),1);
betas = zeros(length(maskidx),length(receivers),ncond);
outmat = zeros(length(maskidx),length(receivers),ncond);
for s = 1:length(receivers)
    sender = senders{1};
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
meanoutmat = squeeze(mean(outmat,2));
meanbetas = squeeze(mean(betas,2));
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
end





