clear all
close all
dataroot = '/triton/becs/scratch/braindata/shared/TouchHyperScan';
addpath('/triton/becs/scratch/braindata/shared/toolboxes/NIFTI');
addpath(genpath('/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/MVLA'));
% subjects
subjects = {
'Sonya_Actor';
'Fanny_Actor';
};
mask = '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/whole_GM4mm.nii';
maskname = 'whole_GM';
ncond = 4;
for s = 1:length(subjects)
    subject = subjects{s};
    load(sprintf('%s/Bayes/MVLA/within/%s/%s/results.mat',dataroot,maskname,subject));
    impmap{s} = getMVLAweight(retval.probs,mask,ncond);
end
for c = 1:ncond
    m1 = fixOriginator(make_nii(impmap{1}{c}),load_nii(mask));
    m2 = fixOriginator(make_nii(impmap{2}{c}),load_nii(mask));
    save_nii(m1,sprintf('%s/Bayes/MVLA/pics/sonya_actor_beta%i.nii',dataroot,c));
    save_nii(m2,sprintf('%s/Bayes/MVLA/pics/fanny_actor_beta%i.nii',dataroot,c));
    temp = sign(impmap{1}{c}+impmap{2}{c});
    m3 = make_nii(temp);
    m3 = fixOriginator(m3,load_nii(mask));
    save_nii(m3,sprintf('%s/Bayes/MVLA/pics/actors_mean_beta%i.nii',dataroot,c));
    % upsample
    upsample2mm4mm(sprintf('%s/Bayes/MVLA/pics/sonya_actor_beta%i.nii',dataroot,c),sprintf('%s/Bayes/MVLA/pics/sonya_actor_beta%i_2mm.nii',dataroot,c))
    upsample2mm4mm(sprintf('%s/Bayes/MVLA/pics/fanny_actor_beta%i.nii',dataroot,c),sprintf('%s/Bayes/MVLA/pics/fanny_actor_beta%i_2mm.nii',dataroot,c))
    upsample2mm4mm(sprintf('%s/Bayes/MVLA/pics/actors_mean_beta%i.nii',dataroot,c),sprintf('%s/Bayes/MVLA/pics/actors_mean_beta%i_2mm.nii',dataroot,c))
end
