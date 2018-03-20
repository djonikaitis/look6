%% Calculate data limits in the figure

% Field names
f1_name = cell(1);
f1_name{1} = 'ylim';
f1_name{2} = 'xlim';

% if X-Y limits dont exist, calculate them
for k = 1:2
    
    dummy_val = [-5, 5]; % Dummy axis setup in case of code failur
    
    % Select data
    tmin = [];
    tmax = [];
    if k==1
        if isfield (plot_set, 'ebars_lower_y') && isfield (plot_set, 'ebars_upper_y')
            tmin = plot_set.ebars_lower_y;
            tmax = plot_set.ebars_upper_y;
        elseif isfield (plot_set, 'mat_y')
            tmin = plot_set.mat_y;
            tmax = plot_set.mat_y;
        end
    elseif k==2
        if isfield (plot_set, 'ebars_lower_x') && isfield (plot_set, 'ebars_upper_x')
            tmin = plot_set.ebars_lower_x;
            tmax = plot_set.ebars_upper_x;
        elseif isfield (plot_set, 'mat_x')
            tmin = plot_set.mat_x;
            tmax = plot_set.mat_x;
        end
    end
    
    % If no data exists, quit
    if isempty(tmin) || isempty(tmax)
        plot_set.(f1_name{k}) = dummy_val;
        fprintf('No data exists, using defaults for "%s" (not based on any data)\n', (f1_name{k}))
    end
    
    % If data exists, find min and max values
    if ~isempty(tmin) && ~isempty(tmax)
        
        [m,n,o] = size(tmin);
        
        % Get min and max
        a = reshape(tmin, m*n*o, 1, 1);
        h0_min = min(a);
        a = reshape(tmax, m*n*o, 1, 1);
        h0_max = max(a);
        
        
        % If data exists, then calculate axis limits
        if ~isempty(h0_min) && ~isempty(h0_max) && h0_min ~= h0_max && ~isnan(h0_min) && ~isnan(h0_max)
            
            if isfield (plot_set, 'legend')
                val1_min = 0.0;
                val1_max = 0.0;
            else
                val1_min = 0.0;
                val1_max = 0.0;
            end
            plot_set.(f1_name{k})(1) = h0_min - ((h0_max - h0_min) * val1_min);
            plot_set.(f1_name{k})(2) = h0_max + ((h0_max - h0_min) * val1_max);
            fprintf('No values for %s provided, calculated based on data\n', (f1_name{k}))
            
        else
            % In case finding min and max failed, quit
            plot_set.(f1_name{k}) = dummy_val;
            fprintf('Failed to find min and max for "%s" calculations, using defaults (not based on any data)\n', (f1_name{k}))
        end
        
        % If for some reason values are equal
        if plot_set.(f1_name{k})(1) == plot_set.(f1_name{k})(2)
            plot_set.(f1_name{k}) = dummy_val;
            fprintf('Failed to find min and max for "%s" calculations, using defaults (not based on any data)\n', (f1_name{k}))
        end
        
    end
    
end