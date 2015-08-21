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
dataroot = '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test';
%% Within
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
% Main results for Observer
clear meanacc
clear confmat
for s = 1:length(receivers)
    subject = receivers{s};
    load(sprintf('%s/%s/dL2.mat',dataroot,subject)); % dL2
    true_labels = tosave;
    masks = {    
        sprintf('%s/%s/masks/painloc_thr2.nii',dataroot,subject)
        '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/combined_loc_mask.nii';
        '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/fsl/ROIvalidation/FrontalPole.nii';
        '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/ACC.nii';
        '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/aINS.nii';
        '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/Amy.nii';
        '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/COMBINED.nii';
        '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/INS.nii';
        '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/ParaCC.nii';
        '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/pINS.nii';
        '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/S1.nii';
        '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/S2.nii';
        '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/Thalamus.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/aACC.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/ACC.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/lCereb.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/lIns.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/lIns2.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/lS2.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/mACC.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/rCereb.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/rIns.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/rIns2.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/rS2.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/SMA.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/virtual_lesion.nii';        
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/maskFromFSL/SMAb.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/maskFromFSL/somatoInsulaACC.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/maskFromFSL/InsularCxb.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/maskFromFSL/CingulateGyrus_antdivb.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/maskFromFSL/CerebInsulaACC.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/maskFromFSL/CerebSMAS2InsulaACC.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/LOC.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/MOTOR.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/fsl/ROIvalidation/cingulum/cingularROI.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/fsl/ROIvalidation/temporal/temporalROI.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/fsl/ROIvalidation/FrontalPole.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/SomeMasksFromJulich/whole_GM.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/SomeMasksFromJulich/Cerebellum.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/SomeMasksFromJulich/premotor.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/SomeMasksFromJulich/prim_motor.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/SomeMasksFromJulich/prim_somatosens.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/SomeMasksFromJulich/second_somatosens.nii';   
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/SomeMasksFromJulich/summask.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/SomeMasksFromJulich/summask_nocereb.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/SomeMasksFromJulich/AON_dummy/thr50/aon50.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/SomeMasksFromJulich/neurosynth/somatotopic_pAgF_z_FDR_0.05.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/SomeMasksFromJulich/neurosynth/somatotopic_pFgA_z_FDR_0.05.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/SomeMasksFromJulich/neurosynth/tactile_pAgF_z_FDR_0.05.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/SomeMasksFromJulich/neurosynth/tactile_pFgA_z_FDR_0.05.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/ns/mirrormask.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/SomeMasksFromJulich/neurosynth/painful_pAgF_z_FDR_0.05.nii'
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/empathy_pAgF_z_FDR_0.01.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/empathy_pFgA_z_FDR_0.01.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/pain_pAgF_z_FDR_0.01.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/pain_pFgA_z_FDR_0.01.nii';
%         sprintf('%s/%s/masks/painloc_thr2.nii',dataroot,subject);
    };
    for t = 1:length(masks)
        [pathstr,name,~] = fileparts(masks{t});
        mask = load_nii(sprintf('%s/%s4mm.nii',pathstr,name));
        maskidx = find(mask.img);
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
map=jet(256);%map=cbrewer('seq','Reds',9*2);
for t = 1:length(masks)
    maxLim=0.75;
    [pathstr,name,~] = fileparts(masks{t});
    mconfmat(:,:,t) = squeeze(mean(squeeze(confmat(t,:,:,:)),1)); % mean over subjects
    imwrite(permute(repmat(map,[1 1 2]),[1 3 2]),sprintf('%s/within/%s/colorbar_%s.png',dataroot,name,name));
    imwrite(reshape(map(1+round((mconfmat(:,:,t)/maxLim)*(length(map)-1)),:),4,4,3),sprintf('%s/within/%s/confmat_%s.png',dataroot,name,name));    
end
max(mconfmat); % for colorbar
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
        sprintf('%s/%s/masks/painloc_thr2.nii',dataroot,subject)
        '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/combined_loc_mask.nii';
        '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/fsl/ROIvalidation/FrontalPole.nii';
        '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/ACC.nii';
        '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/aINS.nii';
        '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/Amy.nii';
        '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/COMBINED.nii';
        '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/INS.nii';
        '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/ParaCC.nii';
        '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/pINS.nii';
        '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/S1.nii';
        '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/S2.nii';
        '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks_Dima/complete/Thalamus.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/aACC.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/ACC.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/lCereb.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/lIns.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/lIns2.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/lS2.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/mACC.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/rCereb.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/rIns.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/rIns2.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/rS2.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/SMA.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/virtual_lesion.nii';        
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/maskFromFSL/SMAb.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/maskFromFSL/somatoInsulaACC.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/maskFromFSL/InsularCxb.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/maskFromFSL/CingulateGyrus_antdivb.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/maskFromFSL/CerebInsulaACC.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/maskFromFSL/CerebSMAS2InsulaACC.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/LOC.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/MOTOR.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/fsl/ROIvalidation/cingulum/cingularROI.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/fsl/ROIvalidation/temporal/temporalROI.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/fsl/ROIvalidation/FrontalPole.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/SomeMasksFromJulich/whole_GM.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/SomeMasksFromJulich/Cerebellum.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/SomeMasksFromJulich/premotor.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/SomeMasksFromJulich/prim_motor.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/SomeMasksFromJulich/prim_somatosens.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/SomeMasksFromJulich/second_somatosens.nii';   
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/SomeMasksFromJulich/summask.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/SomeMasksFromJulich/summask_nocereb.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/SomeMasksFromJulich/AON_dummy/thr50/aon50.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/SomeMasksFromJulich/neurosynth/somatotopic_pAgF_z_FDR_0.05.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/SomeMasksFromJulich/neurosynth/somatotopic_pFgA_z_FDR_0.05.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/SomeMasksFromJulich/neurosynth/tactile_pAgF_z_FDR_0.05.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/SomeMasksFromJulich/neurosynth/tactile_pFgA_z_FDR_0.05.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/ns/mirrormask.nii';
%         '/triton/becs/scratch/braindata/shared/GraspHyperScan/SomeMasksFromJulich/neurosynth/painful_pAgF_z_FDR_0.05.nii'
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/empathy_pAgF_z_FDR_0.01.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/empathy_pFgA_z_FDR_0.01.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/pain_pAgF_z_FDR_0.01.nii';
%         '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/masks/pain_pFgA_z_FDR_0.01.nii';    
%         sprintf('%s/%s/masks/painloc_thr2.nii',dataroot,subject);
    };
    for t = 1:length(masks)
        [pathstr,name,~] = fileparts(masks{t});
        mask = load_nii(sprintf('%s/%s4mm.nii',pathstr,name));
        maskidx = find(mask.img);
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
save('/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/within_accuracy.mat','withintable');
