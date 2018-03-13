% Calculate spiking rates
%
% Inputs necessary:
% plot_bins_start/end;
% t1_spike;
% t1_evt;
        
mat1_ini = NaN(size(S.START,1), size(plot_bins_start, 2));

for tid = 1:size(mat1_ini,1)
    for j = 1:size(plot_bins_start, 2)
        
        % If bin start/end exist
        if ~isnan(t1_evt(tid)) && ...
                ~isnan(plot_bins_start(tid,j)) && ~isnan(plot_bins_end(tid,j)) 
            
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