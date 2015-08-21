function downsampler(inputpath,outputpath)
% wrapper to downsample data
setenv('FSLOUTPUTTYPE','NIFTI')
system(sprintf('fslmaths %s -subsamp2 %s',inputpath,outputpath));