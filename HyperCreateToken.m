function HyperCreateToken(cfg)
% Hardcoded subjects for now
% load masked in order, concatenate, and save into a folder with tokenname
if ~exist(sprintf('%s/Tokens/%s',cfg.dataroot,cfg.tokenname),'dir');
    mkdir(sprintf('%s/Tokens/%s',cfg.dataroot,cfg.tokenname));
end
% Sender
dO = [];
for i = 1:length(cfg.maskorder_sender) % take each mask in the prespecified order
    clear dT
    load(sprintf('%s/%s/%s/%s_data4mm.mat',cfg.dataroot,cfg.dsampfolder,cfg.sender,cfg.maskorder_sender{i})); % load this mask
    dO = [dO,dT];
end
save(sprintf('%s/Tokens/%s/%s_4mm.mat',cfg.dataroot,cfg.tokenname,cfg.sender),'dO');
% Receiver
dO = [];
for i = 1:length(cfg.maskorder_receiver) % take each mask in the prespecified order
    clear dT
    load(sprintf('%s/%s/%s/%s_data4mm.mat',cfg.dataroot,cfg.dsampfolder,cfg.receiver,cfg.maskorder_receiver{i})); % load this mask
    dO = [dO,dT];
end
save(sprintf('%s/Tokens/%s/%s_4mm.mat',cfg.dataroot,cfg.tokenname,cfg.receiver),'dO');