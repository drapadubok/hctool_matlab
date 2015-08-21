clear all
close all
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
addpath('/triton/becs/scratch/braindata/shared/toolboxes/NIFTI');
addpath(genpath('/triton/becs/scratch/braindata/shared/toolboxes/bramila'));
addpath('/triton/becs/scratch/braindata/shared/toolboxes/hyperclassification-tools');
dataroot = '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test';
% token = 'Whole';
% mask = '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/whole_GM4mm.nii';
% token = 'combined_localizer';
% mask = '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/combined_loc_mask4mm.nii';
token = 'COMBINED';
mask = '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/COMBINED4mm.nii';
%% Mean acc over all K-values
clear AP
clear AO
Ks = 1:6:4*6*4;
for k = 1:length(Ks);
    K = Ks(k);
    for s = 1:length(receivers)        
        sender = senders{1};
        receiver = receivers{s};
        try
            load(sprintf('%s/hyper/%s/%s/%s/knnresult_%i.mat',dataroot,token,sender,receiver,K));
        catch
            k
            s
        end
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
    tempAO = squeeze(AO(:,:,:,:,k)); tempAO = reshape(tempAO,[],length(receivers)); tempAO = tempAO(midx,:);
    tempAP = squeeze(AP(:,:,:,:,k)); tempAP = reshape(tempAP,[],length(receivers)); tempAP = tempAP(midx,:);
    data = cat(2,tempAO,tempAP);
    design = cat(1,ones(size(tempAO,2),1),ones(size(tempAP,2),1)*2)';
    stats = bramila_ttest2_np(data,design,2000);
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
knum = sum(abs(sign(outmap)),2); % if lower than halp - drop
knum_mask = sign(knum);
knum_mask(find(knum<length(Ks)/2)) = 0; % this is mask for the mean difference
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
save('/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/knnpermutations_whole.mat','tmap','pmap','outmap','knum_brain','knum_mask','difference','-v7.3');
MNI = '/triton/becs/scratch/braindata/DSmirnov/HarvardOxford/MNI152_T1_2mm_brain_mask.nii';
diffimg = fixOriginator(make_nii(difference),load_nii(MNI));
diffimg.hdr.dime.pixdim = [1 4 4 4 1 1 1 1];
save_nii(diffimg,sprintf('%s/hyper/%s/knn_diffimg_kmean_permuted.nii',dataroot,token));
upsample2mm4mm(sprintf('%s/hyper/%s/knn_diffimg_kmean_permuted.nii',dataroot,token),sprintf('%s/hyper/%s/knn_diffimg2mm_kmean_permuted.nii',dataroot,token));
% 
% 
% 
% %% visualize
% for s = 1:length(receivers)
%     sender = senders{1};   
%     receiver = receivers{s};    
%     load(sprintf('%s/hyper/%s/%s/%s/knnresult.mat',dataroot,token,sender,receiver));
%     AP(:,:,:,s) = accuracyAP;
%     AO(:,:,:,s) = accuracyAO;
% end
% AP = mean(AP,4);
% AO = mean(AO,4);
% difference = AP - AO;
% mask = '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/whole_GM4mm.nii';
% % mask = '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/ns/grasp.nii';
% MNI = '/triton/becs/scratch/braindata/DSmirnov/HarvardOxford/MNI152_T1_2mm_brain_mask.nii';
% diffimg = fixOriginator(make_nii(difference),load_nii(MNI));
% diffimg.hdr.dime.pixdim = [1 4 4 4 1 1 1 1];
% save_nii(diffimg,sprintf('%s/hyper/knn_diffimg.nii',dataroot));
% upsample2mm4mm(sprintf('%s/hyper/knn_diffimg.nii',dataroot),sprintf('%s/hyper/knn_diffimg2mm.nii',dataroot));