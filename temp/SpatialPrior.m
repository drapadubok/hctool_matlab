function sprior = SpatialPrior(maskimage)
% For a given mask, acquire distances between voxels
idx=find(maskimage);
sprior = zeros(length(idx));
for i = 1:length(idx)
    [v1x,v1y,v1z] = ind2sub(size(maskimage),idx(i));
    for j = i+1:length(idx)
        [v2x,v2y,v2z] = ind2sub(size(maskimage),idx(j));
        sprior(i,j) = sqrt((v1x-v2x)^2+(v1y-v2y)^2+(v1z-v2z)^2);
        sprior(j,i) = sprior(i,j);
    end
end