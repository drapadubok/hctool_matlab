clear all
close all
%     cname{1} = 'Brush foot ME';
%     cname{2} = 'Brush hand ME';
%     cname{3} = 'Needle foot ME';
%     cname{4} = 'Needle hand ME';
dataroot = '/triton/becs/scratch/braindata/shared/TouchHyperScan';
analysisfolder = 'hyperclassification-test';
addpath('/triton/becs/scratch/braindata/shared/toolboxes/NIFTI');
addpath(genpath('/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test'));
addpath(genpath('/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/MVLA'));
% subjects
subjects = {
};
% mask = '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/virtual_lesion4mm.nii';
mask = '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/whole_GM4mm.nii';
maskname = 'whole_GM';
ncond = 4;
for s = 1:length(subjects)
    subject = subjects{s};
    load(sprintf('%s/hyperclass_test/within/%s/%s/results.mat',dataroot,maskname,subject));
    impmap{s} = getMVLAweight(retval.probs,mask,ncond);
end
for c = 1:ncond
    m1 = fixOriginator(impmap{1}{c},load_nii(mask));
    save_nii(m1,sprintf('%s/hyperclass_test/s1_beta%i.nii',dataroot,c));
    % upsample
    upsample2mm4mm(sprintf('%s/hyperclass_test/s1_beta%i.nii',dataroot,c),sprintf('%s/hyperclass_test/s1_beta%i_2mm.nii',dataroot,c))
end
% 
% 
% %% From glmnet
% clear all
% close all
% addpath('/triton/becs/scratch/braindata/shared/toolboxes/NIFTI');
% dataroot = '/triton/becs/scratch/braindata/shared/TouchHyperScan';
% msk = load_nii('/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/whole_GM4mm.nii');
% IDx = find(msk.img);
% load('/triton/becs/scratch/braindata/shared/TouchHyperScan/Bayes/within/whole_GM/TouchActV5/clsfier_alpha0.00_ungrouped_nocv.mat')
% 
% for c = 1:4
%     cfsA = zscore(full(coefs.(num2str(c))(2:end)));
%     temp = zeros(116380,1);
%     temp(IDx) = cfsA;
%     msk.img = reshape(temp,46,55,46);
%     save_nii(msk,sprintf('%s/Bayes/actorImp_c%i.nii',dataroot,c));
%     upsample2mm4mm(sprintf('%s/Bayes/actorImp_c%i.nii',dataroot,c),sprintf('%s/Bayes/actorImp_c%i2mm.nii',dataroot,c))
% end






