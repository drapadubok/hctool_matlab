clear all
close all
addpath(genpath('/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/MVLA'));
addpath('/triton/becs/scratch/braindata/shared/toolboxes/cbrewer');
addpath('/triton/becs/scratch/braindata/shared/toolboxes/NIFTI');
addpath('/triton/becs/scratch/braindata/shared/toolboxes/spm8_masking_removed/')
addpath('/triton/becs/scratch/braindata/shared/toolboxes/export_fig');
dataroot = '/triton/becs/scratch/braindata/shared/GraspHyperScan';
% token names
tokennames = {
% 'MOTOR';
% 'LOC';
% 'virtual_lesion';
% 'alLOC';
% 'arLOC';
% 'rSMG';
% 'srLOC';
% 'slLOC';
% 'lSPL';
% 'rSPL';
% 'rPrecentral';
% 'lPrecentral';
% 'lBroca';
% 'rBroca';
% 'without_alLOC';
% 'without_arLOC';
% 'without_rSMG';
% 'without_srLOC';
% 'without_slLOC';
% 'without_lSPL';
% 'without_rSPL';
% 'without_rPrecentral';
% 'without_lPrecentral';
% 'without_lBroca';
% 'without_rBroca';
% 'CingularCortex';
% 'FrontalPole';
% 'TemporalCortex';
% 'Whole';
% 'grasp';
% 'Motor-to-Observation_Combined_thresholded';
% 'Motor-to-Observation_V1';
'OverlapLocalizer';
};
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
%% Hyper
clear meanacc
clear confmat
clear mean_acc_mask
for s = 1:length(receivers)
    if s < 12
        sender = senders{1};
    else
        sender = senders{2};
    end
    subject = receivers{s};
    load(sprintf('%s/%s/dL2.mat',dataroot,subject)); % dL2
    true_labels = tosave;
    for t = 1:length(tokennames)
        load(sprintf('%s/hyper/%s/%s/%s/results.mat',dataroot,tokennames{t},sender,subject));
        % mean accuracy
        meanacc(t,s) = retval.accuracy;
        % mlpp
        mlpp(t,s) = retval.mlpp;
        % confmat
        [~,predicted_labels] = max(retval.preds{retval.lambda},[],2);
        nclass = max(true_labels);
        for i = 1:nclass
            for j = 1:nclass
                C(i,j) = sum((predicted_labels==j).*(true_labels==i))/sum(true_labels==1);
            end
        end
        confmat(t,s,:,:) = C;
    end
end
% Confmats for each mask in observer
clear mconfmat
map=jet(256);%cbrewer('seq','Reds',9*2);
for t = 1:length(tokennames)
    [pathstr,name,~] = fileparts(tokennames{t});
    mconfmat(:,:,t) = squeeze(mean(squeeze(confmat(t,:,:,:)),1)); % mean over subjects
    figure('Visible','off');
    imagesc(mconfmat(:,:,t));
    set(gca,'clim',[0 0.7]);
    title(name);
%     colormap(map);
    colormap('jet');
    set(gca,'xtick',[],'ytick',[]);
    axis image
    im = getframe(gca);
    imwrite(im.cdata,sprintf('%s/hyper/%s/confmat_%s.png',dataroot,name,name))
    imwrite(permute(repmat(map,[1 1 2]),[1 3 2]),sprintf('%s/hyper/%s/colorbar_%s.png',dataroot,name,name));
end
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
%% Between
clear meanacc
clear confmat
clear mean_acc_mask
for s = 1:length(receivers)
    if s < 12
        sender = senders{1};
    else
        sender = senders{2};
    end
    subject = receivers{s};
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
mean_acc_mask = mean(meanacc,2);
sem_acc_mask = std(meanacc,[],2)/sqrt(length(receivers));
sem95 = sem_acc_mask*1.96; % 95% confidence interval
for m = 1:length(tokennames)
    [pathstr,name,~] = fileparts(tokennames{m});
    hypertable{4,m} = mean_acc_mask(m,1);
    hypertable{5,m} = sem95(m,1);
end
save('/triton/becs/scratch/braindata/shared/GraspHyperScan/hyper_accuracy.mat','hypertable');
