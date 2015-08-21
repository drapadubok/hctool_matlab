clear all
close all
addpath(genpath('/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/MVLA'));
addpath('/triton/becs/scratch/braindata/shared/toolboxes/cbrewer');
addpath('/triton/becs/scratch/braindata/shared/toolboxes/NIFTI');
addpath('/triton/becs/scratch/braindata/shared/toolboxes/spm8_masking_removed/')
addpath('/triton/becs/scratch/braindata/shared/toolboxes/export_fig');
dataroot = '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test';
% token names
tokennames = {
'painloc_thr2';
'combined_loc_mask';
'FrontalPole';
'ACC';
'aINS';
'Amy';
'COMBINED';
'INS';
'ParaCC';
'pINS';
'S1';
'S2';
'Thalamus';
% 'aACC';
% 'ACC';
% 'lCereb';
% 'rCereb';
% 'mACC';
% 'lIns';
% 'lIns2';
% 'rIns';
% 'rIns2';
% 'lS2';
% 'rS2';
% 'SMA';
% 'without_aACC';
% 'without_ACC';
% 'without_lCereb';
% 'without_rCereb';
% 'without_mACC';
% 'without_wholeACC';
% 'without_lIns';
% 'without_rIns';
% 'without_bothIns';
% 'without_lS2';
% 'without_rS2';
% 'without_SMA';
% 'virtual_lesion';
% 'painloc_thr2_bin';
% 'painloc_thr2';
% 'somatoInsulaACC'
% 'InsularCxb'
% 'CingulateGyrus_antdivb'
% 'CerebInsulaACC'
% 'CerebSMAS2InsulaACC'
% 'SMAb';
% 'empathy_pAgF';
% 'empathy_pFgA';
% 'pain_pAgF';
% 'pain_pFgA';
% 'combined_localizer';
% 'tactile';
% 'somatotopic';
% 'aon50';
% 'prim_somatosens';
% 'sec_somatosens';
% 'prim_sec_somatosens';
% 'painful';
% 'MOTOR';
% 'LOC';
% 'CingularCortex';
% 'FrontalPole';
% 'TemporalCortex';
% 'mirrormask';
% 'Whole';
};
sender = 'TouchActV5';
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
%% Hyper
clear meanacc
clear confmat
clear mean_acc_mask
for s = 1:length(receivers)
    subject = receivers{s};    
    %% This one for normal cls
    load(sprintf('%s/%s/dL2.mat',dataroot,subject)); % dL2
    true_labels = tosave;
    for t = 1:length(tokennames)
%         try
            load(sprintf('%s/hyper/%s/%s/%s/results.mat',dataroot,tokennames{t},sender,subject));
%         catch
%             t
%             s            
%         end
        % mean accuracy
        meanacc(t,s) = retval.accuracy;
        % mlpp
        mlpp(t,s) = retval.mlpp;
        % confmat
        [~,predicted_labels] = max(retval.preds,[],2);
        nclass = max(true_labels);
        for i = 1:nclass
            for j = 1:nclass
                C(i,j) = sum((predicted_labels==j).*(true_labels==i))/sum(true_labels==1);
            end
        end
        confmat(t,s,:,:) = C;
    end
end
% Confmats
clear mconfmat
map=jet(256);%map=cbrewer('seq','Reds',9*2);
for t = 1:length(tokennames)
    maxLim=0.75;
    [pathstr,name,~] = fileparts(tokennames{t});
    mconfmat(:,:,t) = squeeze(mean(squeeze(confmat(t,:,:,:)),1)); % mean over subjects    
    imwrite(permute(repmat(map,[1 1 2]),[1 3 2]),sprintf('%s/hyper/%s/colorbar_%s.png',dataroot,name,name));
    imwrite(reshape(map(1+round((mconfmat(:,:,t)/maxLim)*(length(map)-1)),:),4,4,3),sprintf('%s/hyper/%s/confmat_%s.png',dataroot,name,name));    
end
max(mconfmat(:))
close all
% Mean accuracies and CIs for each mask
mean_acc_mask = mean(meanacc,2);
sem_acc_mask = std(meanacc,[],2)/sqrt(length(receivers));
sem95 = sem_acc_mask*1.96; % 95% confidence interval
% for table
for m = 1:length(tokennames)
    [pathstr,name,~] = fileparts(tokennames{m});
    hypertable{1,m} = name;
    hypertable{2,m} = mean_acc_mask(m,1);
    hypertable{3,m} = sem95(m,1);
end
save('/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/hyper_accuracy.mat','hypertable');
%% Between
clear meanacc
clear confmat
clear mean_acc_mask
for s = 1:length(receivers)
    subject = receivers{s};    
    %% This one for normal cls
    load(sprintf('%s/%s/dL2.mat',dataroot,subject)); % dL2
    true_labels = tosave;
    for t = 1:length(tokennames)
        load(sprintf('%s/between/%s/%s/%s/results.mat',dataroot,tokennames{t},sender,subject));
        % mean accuracy
        meanacc(t,s) = retval.accuracy;
        % mlpp
        mlpp(t,s) = retval.mlpp;
        % confmat
        [~,predicted_labels] = max(retval.preds,[],2);
        nclass = max(true_labels);
        for i = 1:nclass
            for j = 1:nclass
                C(i,j) = sum((predicted_labels==j).*(true_labels==i))/sum(true_labels==1);
            end
        end
        confmat(t,s,:,:) = C;
    end
end
% Mean accuracies and CIs for each mask
mean_acc_mask = mean(meanacc,2);
sem_acc_mask = std(meanacc,[],2)/sqrt(length(receivers));
sem95 = sem_acc_mask*1.96; % 95% confidence interval
% for table
for m = 1:length(tokennames)
    [pathstr,name,~] = fileparts(tokennames{m});
    between{1,m} = name;
    between{2,m} = mean_acc_mask(m,1);
    between{3,m} = sem95(m,1);    
    % CI
    macc = mean(meanacc(m,:)); 
    stdacc = std(meanacc(m,:));
    df = length(receivers)-1; % df - number of subjects minus one
    CI(m,:) = [macc+tinv(0.025,df)*stdacc/4 , macc+tinv(0.975,df)*stdacc/4];
end
save('/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/between_accuracy.mat','between');
