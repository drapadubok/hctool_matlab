clear all
close all
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
addpath('/triton/becs/scratch/braindata/shared/toolboxes/NIFTI');
addpath('/triton/becs/scratch/braindata/shared/toolboxes/hyperclassification-tools');
addpath('/triton/becs/scratch/braindata/shared/toolboxes/bramila');
addpath(genpath('/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/Permutations'));
dataroot = '/triton/becs/scratch/braindata/shared/GraspHyperScan';
token = 'grasp';
mask = '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/ns/grasp4mm.nii';
% token = 'Whole';
% mask = '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/whole_GM4mm.nii';
%% Mean acc over all K-values
clear AP
clear AO
Ks = 1:6:4*6*5;
for k = 1:length(Ks);
    K = Ks(k);
    for s = 1:length(receivers)
        if s < 12
            sender = senders{1};
        else
            sender = senders{2};
        end
        receiver = receivers{s};
        load(sprintf('%s/hyper/%s/%s/%s/knnresult_%i.mat',dataroot,token,sender,receiver,K));
        AP(:,:,:,s,k) = accuracyAP;
        AO(:,:,:,s,k) = accuracyAO;
    end
end
%% Permutation threshold
% For each value of K we test what is the threshold
msk = load_nii(mask);
midx = find(msk.img);
for k = 1:length(Ks);
    K = Ks(k);
    disp(k);
    % take specific K and mask out the irrelevant voxels
    tempAO = squeeze(AO(:,:,:,:,k)); tempAO = reshape(tempAO,[],15); tempAO = tempAO(midx,:);
    tempAP = squeeze(AP(:,:,:,:,k)); tempAP = reshape(tempAP,[],15); tempAP = tempAP(midx,:);
    data = cat(2,tempAO,tempAP);
    design = cat(1,ones(size(tempAO,2),1),ones(size(tempAP,2),1)*2)';
    stats = bramila_ttest2_np(data,design,5000);
    pvals_corrected=mafdr(stats.pvals(:,2),'BHFDR','true');
    tmap(:,k) = stats.tvals;
    pmap(:,k) = pvals_corrected;
end
%% Collect the thresholded map
clear outmap
for k = 1:length(Ks);
    K = Ks(k);
    disp(k);
    outmap(:,k) = tmap(:,k).*(pmap(:,k)<0.01);
end
knum = sum(abs(sign(outmap)),2); % if lower than 10 - drop
knum_mask = sign(knum);
knum_mask(find(knum<10)) = 0; % this is mask for the mean difference
%% get it into brain mask
knum_brain = zeros(numel(msk.img),1);
knum_brain(midx) = knum_mask;
AP = mean(AP,5); % over K
AO = mean(AO,5);
AP = mean(AP,4); % over S
AO = mean(AO,4);
difference = AP - AO; % negative where it decreased, this needs to be thresholded
difference = reshape(difference,[],1);
difference = difference.*knum_brain;
difference = reshape(difference,46,55,46);
save('/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/knnpermutations_whole.mat','tmap','pmap','outmap','knum_brain','knum_mask','difference','-v7.3');
MNI = '/triton/becs/scratch/braindata/DSmirnov/HarvardOxford/MNI152_T1_2mm_brain_mask.nii';
diffimg = fixOriginator(make_nii(difference),load_nii(MNI));
diffimg.hdr.dime.pixdim = [1 4 4 4 1 1 1 1];
save_nii(diffimg,sprintf('%s/hyper/%s/knn_diffimg_kmean_permuted.nii',dataroot,token));
upsample2mm4mm(sprintf('%s/hyper/%s/knn_diffimg_kmean_permuted.nii',dataroot,token),sprintf('%s/hyper/%s/knn_diffimg2mm_kmean_permuted.nii',dataroot,token));


