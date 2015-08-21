%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MVLA 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
addpath(genpath('/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/MVLA'));
addpath('/triton/becs/scratch/braindata/shared/toolboxes/cbrewer');
addpath('/triton/becs/scratch/braindata/shared/toolboxes/NIFTI');
addpath('/triton/becs/scratch/braindata/shared/toolboxes/spm8_masking_removed/')
addpath('/triton/becs/scratch/braindata/shared/toolboxes/export_fig');
dataroot = '/triton/becs/scratch/braindata/shared/GraspHyperScan';
%% Within
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
% Main results for Observer
clear meanacc
clear confmat
for s = 1:length(receivers)
    subject = receivers{s};
    load(sprintf('%s/%s/dL2.mat',dataroot,subject)); % dL2
    true_labels = tosave;
    masks = {
    '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/fsl/ROIvalidation/cingulum/cingularROI.nii';
    '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/fsl/ROIvalidation/temporal/temporalROI.nii';
    '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/fsl/ROIvalidation/FrontalPole.nii';
%     '/triton/becs/scratch/braindata/shared/GraspHyperScan/SomeMasksFromJulich/whole_GM.nii';
    '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/ns/grasp.nii';
%     '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/ns/mirrormask.nii';
%     '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/alLOC.nii';
%     '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/arLOC.nii';
%     '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/lBroca.nii';
%     '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/rBroca.nii';
%     '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/lPrecentral.nii';
%     '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/rPrecentral.nii';
%     '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/lSPL.nii';
%     '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/rSPL.nii';
%     '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/rSMG.nii';
%     '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/slLOC.nii';
%     '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/srLOC.nii';
%     '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/virtual_lesion.nii';
    sprintf('/triton/becs/scratch/braindata/shared/GraspHyperScan/%s/masks/motorloc_V1.nii',subject);
    sprintf('/triton/becs/scratch/braindata/shared/GraspHyperScan/%s/masks/obsloc_contrast_V1.nii',subject);
%     sprintf('/triton/becs/scratch/braindata/shared/GraspHyperScan/%s/masks/obsloc_maineffect_V1.nii',subject);
    '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/loc_overlap2_clu.nii'
    };
    for t = 1:length(masks)
        [pathstr,name,~] = fileparts(masks{t});
        load(sprintf('%s/within/%s/%s/results.mat',dataroot,name,subject));
        % mean accuracy
        meanacc(t,s) = retval.accuracy;
        % confmat
        [~,predicted_labels] = max(retval.preds,[],2);
        nclass = max(true_labels);
        for i = 1:nclass
            for j = 1:nclass
                C(i,j) = sum((predicted_labels==j).*(true_labels==i))/sum(true_labels==1); % we assume equal number of timepoints per class
            end
        end
        confmat(t,s,:,:) = C;
    end
end
% Confmats for each mask in observer
clear mconfmat
map=jet(256);% map=cbrewer('seq','Reds',9*2);
for t = 1:length(masks)
    [pathstr,name,~] = fileparts(masks{t});
    mconfmat(:,:,t) = squeeze(mean(squeeze(confmat(t,:,:,:)),1)); % mean over subjects
    figure('Visible','off');
    imagesc(mconfmat(:,:,t));
    set(gca,'clim',[0 0.7]); % threshold taken as max of mconfmat
    title(name);
%     colormap(map);
    colormap('jet');
    imwrite(permute(repmat(map,[1 1 2]),[1 3 2]),sprintf('%s/within/%s/colorbar_%s.png',dataroot,name,name));
    set(gca,'xtick',[],'ytick',[]);
    % make the bar
    axis image
    im = getframe(gca);
    imwrite(im.cdata,sprintf('%s/within/%s/confmat_%s.png',dataroot,name,name))
end
close all
%
% Mean accuracies and CIs for each mask
mean_acc_mask = mean(meanacc,2);
sem_acc_mask = std(meanacc,[],2)/sqrt(length(receivers));
sem95 = sem_acc_mask*1.96; % 95% confidence interval
% Acc2save = [mean_acc_mask'; sem95'];
% csvwrite('/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/MVLA/observer_within_mask_acc.csv',Acc2save);
% for table
for m = 1:length(masks)
    [pathstr,name,~] = fileparts(masks{m});
    withintable{1,m} = name;
    withintable{2,m} = mean_acc_mask(m,1);
    withintable{3,m} = sem95(m,1);    
end
% For Actor
clear meanacc
clear confmat
for s = 1:length(senders)
    subject = senders{s};
    masks = {
    '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/fsl/ROIvalidation/cingulum/cingularROI.nii';
    '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/fsl/ROIvalidation/temporal/temporalROI.nii';
    '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/fsl/ROIvalidation/FrontalPole.nii';
%     '/triton/becs/scratch/braindata/shared/GraspHyperScan/SomeMasksFromJulich/whole_GM.nii';
%     '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/ns/grasp.nii';
%     sprintf('/triton/becs/scratch/braindata/shared/GraspHyperScan/%s/masks/motorloc_V1.nii',subject);
%     sprintf('/triton/becs/scratch/braindata/shared/GraspHyperScan/%s/masks/obsloc_contrast_V1.nii',subject);
%     sprintf('/triton/becs/scratch/braindata/shared/GraspHyperScan/%s/masks/obsloc_maineffect_V1.nii',subject);
%     '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/localizer/loc_overlap2_clu.nii'        
    };
    for t = 1:length(masks)
        [pathstr,name,~] = fileparts(masks{t});
        load(sprintf('%s/within/%s/%s/results.mat',dataroot,name,subject));
        % mean accuracy
        meanacc(t,s) = retval.accuracy;
        % confmat
        [~,predicted_labels] = max(retval.preds,[],2);
        nclass = max(true_labels);
        for i = 1:nclass
            for j = 1:nclass
                C(i,j) = sum((predicted_labels==j).*(true_labels==i))/sum(true_labels==1); % we assume equal number of timepoints per class
            end
        end
        confmat(t,s,:,:) = C;        
    end
end
% Mean accuracies and CIs for each mask
mean_acc_mask = mean(meanacc,2);
sem_acc_mask = std(meanacc,[],2)/sqrt(length(senders));
sem95 = sem_acc_mask*1.96; % 95% confidence interval
% Acc2save = [mean_acc_mask'; sem95'];
% csvwrite('/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/MVLA/actor_within_mask_acc.csv',Acc2save);
% for table
for m = 1:length(masks)
    withintable{4,m} = mean_acc_mask(m);
    withintable{5,m} = sem95(m);
end
save('/triton/becs/scratch/braindata/shared/GraspHyperScan/within_accuracy.mat','withintable');
