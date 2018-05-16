% Small routine to calculate plot_bins_mat;
%
% Inputs necessary:
% int_bins - vector/single value
% bin_length - single value
% t_dur - duration of each trial (numel = trial number)

plot_bins_start = NaN(numel(t_dur), numel(int_bins)); % Output matrix
plot_bins_end = NaN(numel(t_dur), numel(int_bins)); % Output matrix

if size(int_bins,1)>1 && size(int_bins,2)==1
    int_bins = int_bins';
end

for tid = 1:numel(t_dur)
    if ~isnan(t_dur(tid))
        ind1 = int_bins + bin_length <= t_dur(tid);
        if sum(~ind1)>0
            a = int_bins(~ind1);
            if a(1) - t_dur(tid) + bin_length <= bin_length/2
                b_start = [int_bins(ind1), a(1)];
                b_end = [int_bins(ind1) + bin_length, t_dur(tid)];
            else
                b_start = int_bins(ind1);
                b_end = int_bins(ind1) + bin_length;
            end
            plot_bins_start(tid,1:numel(b_start)) = b_start;
            plot_bins_end(tid,1:numel(b_end)) = b_end;
        elseif sum(~ind1)==0
            plot_bins_start(tid,:) = int_bins;
            plot_bins_end(tid,:) = int_bins + bin_length;
        end
    end
end

