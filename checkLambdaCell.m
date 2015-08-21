function [objs,preds,lambda] = checkLambdaCell(objs,preds,lambda)
% Remove failed lambdas in MVLA
emptyCells = find(cellfun(@isempty,objs));
if ~isempty(emptyCells)
    for j = length(emptyCells):-1:1
        lambda(emptyCells(j)) = [];
        objs(emptyCells(j)) = [];
        preds{emptyCells(j)} = [];
    end
    preds = preds(~cellfun('isempty',preds));
end