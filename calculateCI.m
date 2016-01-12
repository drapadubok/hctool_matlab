function ci = calculateCI(accuracy_rate, prc)
% Input - 1-D vector of accuracies and %
% handle percent
if prc > 1 || prc < 0
    error('Prc has to be between 0 and 1')
end
tail_b = (1 - prc)/2;
tail_t = 1 - tail_b;
ci_low = mean(accuracy_rate)+tinv(tail_b,length(accuracy_rate)-1)*std(accuracy_rate)/4;
ci_high = mean(accuracy_rate)+tinv(tail_t,length(accuracy_rate)-1)*std(accuracy_rate)/4;
ci = [ci_low, ci_high];

