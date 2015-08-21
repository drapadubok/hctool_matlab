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
'Whole_bin';
'painloc_thr2_bin';
'pain_pAgF_bin';
'tactile_bin';
'somatotopic_bin';
'painful_bin';
'FrontalPole_bin'
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
    %% This one just for the binary
%     NTR = 415; % we take only receivers
%     cfg.nruns = 4;
%     cfg.ntask = 2;
%     cfg.TR = 2.5;
%     for r = 1:cfg.nruns
%         loadedrun = load(sprintf('%s/%s/run%i.csv',dataroot,subject,r-1));
%         regtemp=zeros(NTR,cfg.ntask);
%         for k=1:length(loadedrun) % then we go through each trial        
%             type=loadedrun(k,3); % get the type of trial
%             if type == 1 || type == 2
%                 type = 1;
%             else
%                 type = 2;
%             end
%             regtemp(loadedrun(k,1)+1:loadedrun(k,1)+loadedrun(k,2),type)=1;
%         end
%         cfg.regressor.(sprintf('run%i',r)) = regtemp;
%     end
%     cfg = HyperTaskModel(cfg);
%     true_labels = cfg.dL2;
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
% Confmats for each mask in observer
map=cbrewer('seq','Reds',9*2);
for t = 1:length(tokennames)
    [pathstr,name,~] = fileparts(tokennames{t});
    mconfmat(:,:,t) = squeeze(mean(squeeze(confmat(t,:,:,:)),1)); % mean over subjects
    figure('Visible','off');
    imagesc(mconfmat(:,:,t)); 
    set(gca,'clim',[0 1]);
    title(name);
    colormap(map);
    colorbar;
    set(gca,'xtick',[],'ytick',[]);
    axis image
    im = getframe(gca);
    imwrite(im.cdata,sprintf('%s/hyper/%s/confmat_%s.png',dataroot,name,name))
    % make the bar
    h=colorbar;
    set(h,'xtick',[],'ytick',[])
    im=getframe(h);
    imwrite(im.cdata,sprintf('%s/hyper/%s/colorbar_%s.png',dataroot,name,name))
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
save('/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test/hyper_accuracy_binary.mat','hypertable');
