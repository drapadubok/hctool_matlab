function [permlabels, n_per_run] = PermShuffle(labels, nruns, nperm, shuffle_group)
% Returns the set of permutations
% Make array to fill with permutation schemes
permlabels = zeros(length(labels),nperm);
if shuffle_group == 0
    % If no grouping, just shuffle the hell out of everything runwise
    n_per_run = length(labels) / nruns;
    for p = 1:nperm
        for r = 1:nruns
            templabels = labels((1:n_per_run) + (r-1)*n_per_run);
            [~, idx] = sort(rand([1 n_per_run]));
            permlabels((1:n_per_run) + (r-1)*n_per_run,p) = templabels(idx);
        end
    end
elseif shuffle_group == 1
    % If grouped, shuffle the trial labels, not individual time points
    labels = labels(1:3:end);
    n_per_run = length(labels) / nruns;
    permlabels2 = zeros(length(labels),nperm);
    for p = 1:nperm
        for r = 1:nruns
            templabels = labels((1:n_per_run) + (r-1)*n_per_run);
            [~, idx] = sort(rand([1 n_per_run]));
            permlabels2((1:n_per_run) + (r-1)*n_per_run,p) = templabels(idx);
        end
        for i = 1:length(labels)
            permlabels((1:3) + (i-1)*3,p) = [permlabels2(i,p),permlabels2(i,p),permlabels2(i,p)];
        end
    end
    n_per_run = n_per_run*3; % return usable one
end


