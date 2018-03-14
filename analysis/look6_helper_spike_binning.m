% Calculate spiking rates
%
% Inputs necessary:
% plot_bins_start/end;
% t1_spike;
% t1_evt;

function y = look6_helper_spike_binning (t1_spike, t1_evt, plot_bins_start, plot_bins_end)
        
mat1_ini = NaN(size(plot_bins_start,1), size(plot_bins_start, 2));

for tid = 1:size(mat1_ini,1)
    for j = 1:size(plot_bins_start, 2)
        
        % If bin start/end exist
        if ~isnan(t1_evt(tid)) && ...
                ~isnan(plot_bins_start(tid,j)) && ~isnan(plot_bins_end(tid,j)) && ...
                plot_bins_start(tid,j) < plot_bins_end(tid,j)
            
            % Index
            index = t1_spike >= t1_evt(tid) + plot_bins_start(tid,j) & ...
                t1_spike <= t1_evt(tid) + plot_bins_end(tid,j);
            
            % Save data
            if sum(index)==0
                mat1_ini(tid,j)=0; % Save as zero spikes
            elseif sum(index)>0
                mat1_ini(tid,j)=sum(index); % Save spikes counts
            end
        end
        
    end
end

% Convert to HZ
b_length = plot_bins_end - plot_bins_start;
mat1_ini = mat1_ini.*(1000./b_length);

y = mat1_ini;