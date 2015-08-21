function [accuracy,results] = perspective_kNN_classification(corMat,K,groups)

%Simple kNN-classification for ISC matrices.
%--------------------------------------------------------------------------
%Randomly reorders group labels and classifies each subject. Permutation
%distribution entries are average accuracies over subjects.
%
%Inputs:
%corMat     Brain volumes of the upper triangle entries of corr matrices
%Ks         The k-values to be used
%groups     Number of groups or vector giving vector IDs
%
%V.1e-420
%17.1.2014 Juha Lahnakoski
x=size(corMat,4);
N=(.5+sqrt(.5^2+x*2));
results=zeros(size(corMat,1),size(corMat,2),size(corMat,3),N);
for sub=1:N
    fprintf('Classifying subject %i...',sub);
    subs=1:N';
    subs(sub)=[];
    grps=groups;
    grps(sub)=[];
    mask=false(N);
    mask(sub,:)=true;
    mask(:,sub)=true;
    
    [~,idx]=sort(corMat(:,:,:,mask(triu(true(N),1))),4,'descend');
    results(:,:,:,sub)=mode(grps(idx(:,:,:,1:K)),4)==permute(repmat(groups(sub),[1 size(corMat,1),size(corMat,2),size(corMat,3)]),[2 3 4 1]);
    fprintf('done\n');
end;
accuracy=sum(results,4)/N;
end