function retval = extractSpatialPrior(sprior,idx)
% sprior - distances calculated over bigger mask
% idx - indices of smaller mask
% returns the subset of full distance matrix
mfull = '/triton/becs/scratch/braindata/shared/GraspHyperScan/Bayes/masks/MNI152_T1_4mm_brain.nii';
mfull = load_nii(mfull);
% sprior = SpatialPrior(mfull.img);
% save('sprior','sprior','-v7.3')
idxfull = find(mfull.img);
t = ismember(idxfull,idx);
retval = sprior(t,t);