function upsample2mm4mm(input,output)
setenv('FSLOUTPUTTYPE','NIFTI')
dlmwrite('/triton/becs/scratch/braindata/shared/GraspHyperScan/eyemat.mat',eye(4),' ');
transmat = '/triton/becs/scratch/braindata/shared/GraspHyperScan/eyemat.mat';
% transmat = '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/4mm_2mm.mat';
refimg = '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/MNI152_T1_2mm_brain_mask.nii';
cmd = sprintf('flirt -in %s -applyxfm -init %s -out %s -paddingsize 0.0 -interp trilinear -ref %s',input,transmat,output,refimg);
system(cmd)