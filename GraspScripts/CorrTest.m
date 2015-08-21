clear all
close all
addpath('/triton/becs/scratch/braindata/shared/toolboxes/NIFTI');
addpath(genpath('/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/MVLA'));
addpath(genpath('/triton/becs/scratch/braindata/shared/BML_utilities'));
addpath(genpath('/triton/becs/scratch/braindata/shared/toolboxes/hyperclassification-tools'));
dataroot = '/triton/becs/scratch/braindata/shared/GraspHyperScan';
%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
% 'Surro';
};
nrun = 5;
% maskname = 'Whole';
% fullmask = load_nii('/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/whole_GM4mm.nii');
maskname = 'grasp';
fullmask = load_nii('/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/ns/grasp4mm.nii');
fidx = find(fullmask.img); % fullmask indices
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Main part
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Actor
storedA = [];
for a = 1:length(senders)
    actor = senders{a};
    dataActor = load(sprintf('%s/Tokens/%s/%s_4mm.mat',dataroot,maskname,actor));
    storedA = cat(3,storedA,dataActor.dO);
end
storedO = []; 
storedProj = []; 
% Observers
for s = 1:length(receivers)
    if s < 12
        actor = senders{1};
    else
        actor = senders{2};
    end
    load(sprintf('%s/%s/dL2.mat',dataroot,receivers{s}));
    labels = tosave;
    n_per_run = length(labels)/nrun;
    % Load data
    sprintf('Processing pair %i',s)
    dataObserver = load(sprintf('%s/Tokens/%s/%s_4mm.mat',dataroot,maskname,receivers{s}));
    tempProj = load(sprintf('%s/hyper/%s/%s/%s/data.mat',dataroot,maskname,actor,receivers{s}));
    % save data
    storedO = cat(3,storedO,dataObserver.dO);
    storedProj = cat(3,storedProj,tempProj.fullmaskprojection);
end
save(sprintf('%s/hyper/%s/corrtest.mat',dataroot,maskname),'storedA','storedO','storedProj','-v7.3');


%% Calculate only the diagonal of the big matrix
rmat = zeros(length(fidx),length(receivers));
pmat = rmat;
proj_rmat = rmat;
proj_pmat = rmat;
load(sprintf('%s/hyper/%s/corrtest.mat',dataroot,maskname));
for s = 1:length(receivers)
    fprintf('Processing subject %i\n',s);
    if s < 12
        actor = storedA(:,:,1);
    else
        actor = storedA(:,:,2);
    end
    
    try
        mean(mean(storedA(:,:,s) == storedO(:,:,s+1)))
    catch
    end
    
    parfor v = 1:length(fidx)
        [rmat(v,s),pmat(v,s)] = corr(actor(:,v),storedO(:,v));
        [proj_rmat(v,s),proj_pmat(v,s)] = corr(actor(:,v),storedProj(:,v));  
    end
end
% Check where nans come from, handle them differently
rmat(isnan(rmat)) = 0;
pmat(isnan(pmat)) = 1;
proj_rmat(isnan(proj_rmat)) = 0;
proj_pmat(isnan(proj_pmat)) = 1;
%% DO FDR
% [pID,pN] = FDR(pmat(:),0.05);
%% Save results
% lets say threshold with p < thr
% thr = 0;
% for s = 1:length(subjects)
%     thrrmat(:,s) = rmat(:,s).*(pmat(:,s) < thr);
%     proj_thrrmat(:,s) = proj_rmat(:,s).*(proj_pmat(:,s) < thr);
% end
% run simple ttest2 to compare the correlation in each voxel before and after
% sample = subjects
for v = 1:length(fidx)
    [~,p,~,stats] = ttest2(tanh(rmat(v,:)),tanh(proj_rmat(v,:)));
    pp(v,1) = p;
    tt(v,1) = stats.tstat;
end
tt(isnan(tt)) = 0;
pp(isnan(pp)) =  1;
temp = zeros(numel(fullmask.img),1);
temp(fidx) = tt;
% Direction, toy example, negative T statistic means second sample was larger (correlation in projection in our case)
% toysample1 = randi(100,100);
% toysample2 = randi(100,100).*2;
% [~,p,~,stats] = ttest2(toysample1(:,1),toysample2(:,1));
m1 = make_nii(reshape(temp,46,55,46));
m1 = fixOriginator(m1,fullmask);
save_nii(m1,sprintf('%s/hyper/%s_ttest_cormat_nothr.nii',dataroot,maskname));
upsample2mm4mm(sprintf('%s/hyper/%s_ttest_cormat_nothr.nii',dataroot,maskname),sprintf('%s/hyper/%s_ttest_cormat_nothr_2mm.nii',dataroot,maskname));
%%%%%%%%%%%%%
%%%%%%%%%%%%%
%% Clusterstats
% These are different metrics.
addpath(genpath('/triton/becs/scratch/braindata/shared/GraspHyperScan/hyperclassification-tools'));
addpath(genpath('/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/clusterstats'));
addpath('/triton/becs/scratch/braindata/shared/toolboxes/NIFTI');
% load reference
mni = load_nii('/triton/becs/scratch/braindata/DSmirnov/HarvardOxford/MNI152_T1_2mm_brain_mask.nii');
% load results
before = load_nii('/triton/becs/scratch/braindata/shared/GraspHyperScan/ISCanalysis/meanISC.nii'); % Pairwise ISC
after = load_nii(sprintf('%s/hyper/%s_ttest_cormat_nothr_2mm.nii',dataroot,maskname)); % tval, difference of pairwise ISC before and after.
% some thresholding
%% Before
maskbefore = before.img;
maskbefore(abs(before.img) < 0.018) = 0; % threshold
maskbefore_clu = abs(sign(clusterit(abs(sign(maskbefore)),0,5,6)));
imgbefore_clu = maskbefore.*maskbefore_clu;
getallstats(imgbefore_clu,-1)
getallstats(imgbefore_clu,1)
% separate the pos and neg
p_img2save = make_nii(imgbefore_clu); p_img2save.img(p_img2save.img < 0.018) = 0;
n_img2save = make_nii(imgbefore_clu); n_img2save.img(n_img2save.img > 0.018) = 0;
save_nii(fixOriginator(p_img2save,mni),'/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/MVLA/pics/pISC_clu.nii')
save_nii(fixOriginator(n_img2save,mni),'/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/MVLA/pics/nISC_clu.nii')
%
%%
maskafter = after.img;
maskafter(abs(after.img) < 3) = 0;
maskafter_clu = abs(sign(clusterit(abs(sign(maskafter)),0,5,6)));
imgafter_clu = maskafter.*maskafter_clu;
getallstats(imgafter_clu,-1)
getallstats(imgafter_clu,1)
% separate the pos and neg
p_img2save = make_nii(imgafter_clu); p_img2save.img(p_img2save.img < 3) = 0;
n_img2save = make_nii(imgafter_clu); n_img2save.img(n_img2save.img > 3) = 0;
save_nii(fixOriginator(p_img2save,mni),sprintf('%s/hyper/%s_pcormat2mm_clu.nii',dataroot,maskname))
save_nii(fixOriginator(n_img2save,mni),sprintf('%s/hyper/%s_ncormat2mm_clu.nii',dataroot,maskname))


