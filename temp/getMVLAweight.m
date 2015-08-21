function impmaps = getMVLAweight(probs,mask,ncond)
addpath('/triton/becs/scratch/braindata/shared/toolboxes/NIFTI');
% How to get both positive and negative weights from MVLA
mask = load_nii(mask);
midx = find(mask.img);
[x,y,z] = size(mask.img);
impmaps = cell(ncond,1);
for c = 1:ncond
    % Old version
%     probvec = probs{c};
%     negvec = probvec;
%     posvec = probvec;
%     negvec(negvec>=0.5) = 0;
%     posvec(posvec<=0.5) = 0;
%     negvec = negvec*-1;
%     % to make it slightly easier to look at, drop 0.5
%     posvec(find(posvec>=0.5)) = posvec(find(posvec>=0.5)) - 0.5;
%     negvec(find(negvec<0)) = negvec(find(negvec<0)) + 0.5;
%     temp = zeros(numel(mask.img),1);
%     probvec = posvec + -negvec; % combine back
%     temp(midx) = probvec;
%     mask.img = reshape(temp,x,y,z);
%     impmaps{c} = mask;
    % New version
    probvec = probs{c};
    probvec(probvec<=0.5) = 0;
    % binarize
    temp = zeros(numel(mask.img),1);
    temp(midx) = sign(probvec);
    impmaps{c} = reshape(temp,x,y,z);
end