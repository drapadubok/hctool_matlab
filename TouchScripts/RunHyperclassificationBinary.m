clear all
close all
% subjects
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
% params
cfg.convthresh = 0.8;
cfg.nruns = 4;
cfg.ntask = 2;
cfg.TR = 2.5;
cfg.K = 50;
cfg.downsamp = 1;
cfg.dsampfolder = 'downsampled';
cfg.dataroot = '/triton/becs/scratch/braindata/shared/TouchHyperScan/hyperclass_test';
toolboxpath = '/triton/becs/scratch/braindata/shared/toolboxes/hyperclassification-tools';
% cfg.lambda = logspace(-2,2,7);
cfg.lambda = 1;
% masks
tokennames = {
% 'painloc_thr2_bin';
% 'combined_loc_mask_bin';
% 'FrontalPole_bin';
% 'ACC_bin';
% 'aINS_bin';
% 'Amy_bin';
% 'COMBINED_bin';
% 'INS_bin';
% 'ParaCC_bin';
% 'pINS_bin';
% 'S1_bin';
% 'S2_bin';
% 'Thalamus_bin';
'Whole_bin';
% % 'painloc_thr2_bin';
% 'pain_pAgF_bin';
% 'tactile_bin';
% 'somatotopic_bin';
% 'painful_bin';
% 'FrontalPole_bin'
};
for t = 1:length(tokennames)
    cfg.token = tokennames{t};
    for s = 1:length(receivers)
        cfg.sender = senders{1}; 
        cfg.receiver = receivers{s};
        NTR = 415; % we take only receivers
        for r = 1:cfg.nruns
            loadedrun = load(sprintf('%s/%s/run%i.csv',cfg.dataroot,cfg.receiver,r-1));
            regtemp=zeros(NTR,cfg.ntask);
            for k=1:length(loadedrun) % then we go through each trial        
                type=loadedrun(k,3); % get the type of trial
                if type == 1 || type == 2
                    type = 1;
                else
                    type = 2;
                end
                regtemp(loadedrun(k,1)+1:loadedrun(k,1)+loadedrun(k,2),type)=1;
            end
            cfg.regressor.(sprintf('run%i',r)) = regtemp;
        end
        if ~exist(sprintf('%s/hyper/%s/%s/%s',cfg.dataroot,cfg.token,cfg.sender,cfg.receiver),'dir');
            mkdir(sprintf('%s/hyper/%s/%s/%s',cfg.dataroot,cfg.token,cfg.sender,cfg.receiver));
        end
        save(sprintf('%s/hyper/%s/%s/%s/cfgbin',cfg.dataroot,cfg.token,cfg.sender,cfg.receiver),'cfg');
        % job filename
        filename = sprintf('%s/hyper/%s/%s/%s/jobbin',cfg.dataroot,cfg.token,cfg.sender,cfg.receiver);
        % log filename
        logfile = sprintf('%s/hyper/%s/%s/%s/logfilebin',cfg.dataroot,cfg.token,cfg.sender,cfg.receiver);
        %load the modules
        dlmwrite(filename, '#!/bin/sh', '');
        % Handle the long jobs
        dlmwrite(filename, '#SBATCH -p batch','-append','delimiter','');
        dlmwrite(filename, '#SBATCH -t 23:00:00','-append','delimiter','');            
        dlmwrite(filename, ['#SBATCH -o "' logfile '"'],'-append','delimiter','');
        dlmwrite(filename, '#SBATCH --mem-per-cpu=10000','-append','delimiter','');
        dlmwrite(filename, ['cd ' toolboxpath],'-append','delimiter','');
        dlmwrite(filename, 'module load R','-append','delimiter','');
        %command
%         dlmwrite(filename,sprintf('Rscript bcca.r "%s/hyper/%s/%s/%s/cfgbin.mat"',cfg.dataroot,cfg.token,cfg.sender,cfg.receiver),'-append','delimiter','');
        dlmwrite(filename,sprintf('Rscript bcca_final.r "%s/hyper/%s/%s/%s/cfgbin.mat"',cfg.dataroot,cfg.token,cfg.sender,cfg.receiver),'-append','delimiter','');
        unix(['sbatch ' filename]);
    end
end




