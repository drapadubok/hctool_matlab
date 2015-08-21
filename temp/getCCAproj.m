function [P1,P2] = getCCAproj(cca)
% Operators to predict data in other subject's space
% See page 991 of Klami et al 2013
% If x1 is actor, and x2 is observer, then:
% px1|x2 = P1*x2, px1 being x2 in x1 space (observer in actor space)
% px2|x1 = P2*x1, px2 being x1 in x2 space (actor in observer space)
% P1
iS = (eye(size(cca.WW{2},1)) + cca.tau(2) * cca.WW{2});
[v_e,d_e] = eig(iS);
P1 = cca.tau(2) * cca.W{1} * ((v_e * diag(1./diag(d_e)) * v_e') * cca.W{2}');
% P2
iS = (eye(size(cca.WW{1},1)) + cca.tau(1) * cca.WW{1});
[v_e,d_e] = eig(iS);
P2 = cca.tau(1) * cca.W{2} * ((v_e * diag(1./diag(d_e)) * v_e') * cca.W{1}');
