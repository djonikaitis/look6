
%% Initialize parameters


if ~isfield(plot_set, 'font_size_label')
    if isfield(settings, 'font_size_label')
        plot_set.font_size_label = settings.font_size_label;
    else
        plot_set.font_size_label = 10;
    end
end

if ~isfield(plot_set, 'font_size_figure')
    if isfield(settings, 'font_size_figure')
        plot_set.font_size_figure = settings.font_size_figure;
    else
        plot_set.font_size_figure = 8;
    end
end


%% Make sure size of all variables is equal

if strcmp (plot_set.helper_part, 'size check')
    
    % Check X & Y data size
    if isfield (plot_set, 'mat_y')
        
        [m1, n1, o1] = size(plot_set.mat_y);
        [m2, n2, o2] = size(plot_set.mat_x);
        
        if m1~=m2 || n1~=n2 || o1~=o2
            error ('mat_x and mat_y matrix size mismatch')
        end
        
    end
    
    % Y error bar size
    if isfield (plot_set, 'ebars_lower_y') && isfield (plot_set, 'ebars_upper_y')
        
        [m1, n1, o1] = size(plot_set.ebars_lower_y);
        [m2, n2, o2] = size(plot_set.ebars_upper_y);
        
        if m1~=m2 || n1~=n2 || o1~=o2
            error ('ebars_lower_y and ebars_upper_y size mismatch')
        end
        
    end
    
    % X error bar size
    if isfield (plot_set, 'ebars_lower_x') && isfield (plot_set, 'ebars_upper_x')
        
        [m1, n1, o1] = size(plot_set.ebars_lower_x);
        [m2, n2, o2] = size(plot_set.ebars_upper_x);
        
        if m1~=m2 || n1~=n2 || o1~=o2
            error ('ebars_lower_x and ebars_upper_x size mismatch')
        end
        
    end
    
    % X and Y error bar size
    if isfield (plot_set, 'ebars_lower_x') && isfield (plot_set, 'ebars_lower_y')
        
        [m1, n1, o1] = size(plot_set.ebars_lower_x);
        [m2, n2, o2] = size(plot_set.ebars_lower_y);
        
        if m1~=m2 || n1~=n2 || o1~=o2
            error ('ebars_x and ebars_y size mismatch')
        end
        
    end
    
    % Y data and Y-bar data size
    if isfield (plot_set, 'mat_y') && isfield (plot_set, 'ebars_lower_y')
        
        [m1, n1, o1] = size(plot_set.mat_y);
        [m2, n2, o2] = size(plot_set.ebars_lower_y);
        
        if m1~=m2 || n1~=n2 || o1~=o2
            error ('mat_y and ebars_y size mismatch')
        end
        
    end
    
end

%% Remove NaN values

% plot_set.mat_remove_nan is output matrix for it

if strcmp (plot_set.helper_part, 'remove nan')
    
    if ~isfield (plot_set, 'plot_remove_nan')
        plot_set.plot_remove_nan = 1;
    end
    
    if isfield (plot_set, 'mat_y') || isfield (plot_set, 'ebars_lower_y')
        
        if isfield (plot_set, 'mat_y')
            f_name = 'mat_y';
        elseif ~isfield (plot_set, 'mat_y') && isfield (plot_set, 'ebars_lower_y')
            f_name = 'ebars_lower_y';
        end
        
        % Remove NaN values for each row separately
        [m,n,o] = size(plot_set.(f_name));
        plot_set.mat_remove_nan = NaN(m, n, o);
        
        for m1 = 1:m
            for o1 = 1:o
                temp1 = plot_set.(f_name)(m1,:,o1);
                plot_set.mat_remove_nan(m1,:,o1) = isnan(temp1);
            end
        end
        
    else
        fprintf('No data exists, thus no NaNs are removed')
    end
    
end


%% Calculate X and Y axis limits


% Part 1 - find data limits
if strcmp (plot_set.helper_part, 'calculate data limits')
    
    % Field names
    f1_name = cell(1);
    f1_name{1} = 'y_data_lim';
    f1_name{2} = 'x_data_lim';
    
    % if X-Y limits dont exist, calculate them
    for k = 1:2
        if ~isfield(plot_set, f1_name{k})
            
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
                
                [m,n,o] = size(plot_set.mat_remove_nan);
                
                % Remove nan values from data
                t1 = plot_set.mat_remove_nan;
                ind = reshape(t1, m*n*o, 1, 1);
                
                % Get min and max
                a = reshape(tmin, m*n*o, 1, 1);
                a(ind==1) = [];
                h0_min = min(a);
                a = reshape(tmax, m*n*o, 1, 1);
                a(ind==1) = [];
                h0_max = max(a);
                
                % If data exists, then calculate axis limits
                if ~isempty(h0_min) && ~isempty(h0_max) && h0_min ~= h0_max && ~isnan(h0_min) && ~isnan(h0_max)
                    plot_set.(f1_name{k})(1) = h0_min;
                    plot_set.(f1_name{k})(2) = h0_max;
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
    end
    
end

% Part 2 - add axis limits
if strcmp (plot_set.helper_part, 'calculate axis limits')
    
    % Field names
    f1_name = cell(1);  f1_name_input = cell(1);
    f1_name{1} = 'ylim';
    f1_name{2} = 'xlim';
    f1_name_input{1} = 'y_data_lim';
    f1_name_input{2} = 'x_data_lim';
    
    % if X-Y limits dont exist, calculate them
    for k = 1:2
        if ~isfield(plot_set, f1_name{k})
            
            if k==1
                if isfield(plot_set, 'val1_min_y')
                    val1_min = plot_set.val1_min_y;
                    val1_max = plot_set.val1_max_y;
                else
                    val1_min = 0;
                    val1_max = 0;
                end
            elseif k==2
                if isfield(plot_set, 'val1_min_x')
                    val1_min = plot_set.val1_min_x;
                    val1_max = plot_set.val1_max_x;
                else
                    val1_min = 0;
                    val1_max = 0;
                end
            end
            
            % Select data
            h0_min = plot_set.(f1_name_input{k})(1);
            h0_max = plot_set.(f1_name_input{k})(2);
            
            % Calculate limits
            plot_set.(f1_name{k})(1) = h0_min - ((h0_max - h0_min) * val1_min);
            plot_set.(f1_name{k})(2) = h0_max + ((h0_max - h0_min) * val1_max);
            fprintf('No values for %s provided, calculated based on data\n', (f1_name{k}))
            
        end
    end
end

%% Calculate X and Y ticks

if strcmp (plot_set.helper_part, 'calculate axis limits')
    
    % Field names
    f1_name = cell(1); f1_name_lim = cell(1);
    f1_name{1} = 'ytick';
    f1_name{2} = 'xtick';
    f1_name_lim{1} = 'ylim';
    f1_name_lim{2} = 'xlim';
    
    % if X-Y limits dont exist, calculate them
    for k = 1:2
        
        if isfield (plot_set, f1_name{k}) && ~isempty(plot_set.(f1_name{k}))
        else
            
            fprintf('No values for "%s" provided, calculating one based on the range of data used\n', f1_name{k})
            
            tmin = plot_set.(f1_name_lim{k})(1);
            tmax = plot_set.(f1_name_lim{k})(2);
            
            % Select number of tick values
            a = (tmax-tmin)/3;
            b = [0.01, 0.02, 0.05, 0.1, 0.5, 1, 2, 5, 10, 20, 25, 50, 100, 200, 250, 500, 1000, 2000, 2500, 5000, 10000];
            c = b(a>=b);
            if ~isempty(c)
                step1 = c(end);
            else
                step1 = a;
            end
            
            % Set ticks
            ps_tick = [-step1*1000:step1:step1*1000];
            plot_set.(f1_name{k}) = ps_tick;
            
        end
    end
    
end



%% Calculate colors to be used

if strcmp (plot_set.helper_part, 'calculate colors')
    
    if isfield (plot_set, 'mat_y') || isfield(plot_set, 'ebars_lower_y')
        
        if isfield (plot_set, 'mat_y')
            f_name = 'mat_y';
        elseif ~isfield (plot_set, 'mat_y') && isfield (plot_set, 'ebars_lower_y')
            f_name = 'ebars_lower_y';
        end
        
        %===============
        % It's a single color
        if isfield(plot_set, 'data_color') && ~isempty(plot_set.data_color)
            if numel(plot_set.data_color)==1 % If theres only one color value
                ind = plot_set.data_color;
                plot_set.main_color = settings.color1(ind,:);
                plot_set.shade_color = settings.face_color1(ind,:);
            elseif sum(sum(plot_set.data_color<=1)) == numel(plot_set.data_color)
                if size(plot_set.(f_name),plot_set.color_dim) == size(plot_set.data_color,1) % Only if appropriate number of colors is specified
                    plot_set.main_color = plot_set.data_color;
                end
            elseif sum(plot_set.data_color>=1) == numel(plot_set.data_color) % Very likely to refer to indexes
                if size(plot_set.(f_name),plot_set.color_dim) == numel(plot_set.data_color) % Only if appropriate number of colors is specified
                    ind = plot_set.data_color;
                    plot_set.main_color = settings.color1(ind,:);
                    plot_set.shade_color = settings.face_color1(ind,:);
                end
            end
        end
        
        %=================
        % Color range and default colors
        if ~isfield (plot_set, 'main_color')
            
            % How many color values to calculate
            if isfield (plot_set, 'data_color_min') && isfield (plot_set, 'data_color_max') && numel(plot_set.data_color_min)==1 && numel(plot_set.data_color_max)==1
                col_min = settings.color1 (plot_set.data_color_min,:);
                col_max = settings.color1 (plot_set.data_color_max,:);
                n = size(plot_set.(f_name),plot_set.color_dim);
            elseif isfield (plot_set, 'data_color_min') && isfield (plot_set, 'data_color_max') && numel(plot_set.data_color_min)==3 && numel(plot_set.data_color_max)==3
                col_min = plot_set.data_color_min;
                col_max = plot_set.data_color_max;
                n = size(plot_set.(f_name),plot_set.color_dim);
            else % Initialize some backup colors
                fprintf('Color values either are not specified correctly, or are missing. Will use default colors\n')
                col_min = [0.2, 0.2, 0.2];
                col_max = [0.99, 0.3, 0.3];
                n = size(plot_set.(f_name),plot_set.color_dim);
            end
            
            % Other location colors are calculated as a range
            plot_set.main_color = [];
            if n>1
                d1 = col_max-col_min;
                stepsz = 1/(n-1);
                for i=1:n
                    plot_set.main_color(i,:)=col_min + (d1*stepsz)*(i-1);
                end
            else
                plot_set.main_color(1,:)=col_min;
            end
        end
        
        % Add shade color in case it doesnt exist
        if ~isfield (plot_set, 'shade_color')
            plot_set.shade_color = [];
            for i = 1:size(plot_set.main_color,1)
                d1 = 1 - plot_set.main_color(i,:);
                plot_set.shade_color(i,:) = plot_set.main_color(i,:) + d1.*0.6;
            end
        end
        
    end
    
    % Color in case y data undefined
    
    if ~isfield (plot_set, 'mat_y') &&  ~isfield (plot_set, 'ebars_lower_y')
        
        % Data_color exists
        if isfield(plot_set, 'data_color') && ~isempty(plot_set.data_color)
            if sum(sum(plot_set.data_color<=1)) == numel(plot_set.data_color)
                plot_set.main_color = plot_set.data_color;
            elseif sum(plot_set.data_color>=1) == numel(plot_set.data_color) % Very likely to refer to indexes
                ind = plot_set.data_color;
                plot_set.main_color = settings.color1(ind,:);
                plot_set.shade_color = settings.face_color1(ind,:);
            end
        else
            fprintf('No data exists and no color values are specified. Will use default colors\n')
            plot_set.main_color = [0.2, 0.2, 0.2];
        end
        
        % Add shade color in case it doesnt exist
        if ~isfield (plot_set, 'shade_color')
            plot_set.shade_color = [];
            for i = 1:size(plot_set.main_color,1)
                d1 = 1 - plot_set.main_color(i,:);
                plot_set.shade_color(i,:) = plot_set.main_color(i,:) + d1.*0.6;
            end
        end
        
    end
    
end

%% Other settings

if strcmp (plot_set.helper_part, 'general setup')
    
    % Font size
    hfig = gca;
    set (hfig, 'FontSize', plot_set.font_size_figure);
    
    % Y tick
    if isfield (plot_set, 'ytick')
        if ischar (plot_set.ytick)
            if strcmp(plot_set.ytick, 'none')
                hfig.YTick = plot_set.ylim(2)*1000;
            end
        else
            hfig.YTick = plot_set.ytick;
        end
    end
    
    % X tick
    if isfield (plot_set, 'xtick') && ~isfield(plot_set, 'xtick_label')
        if ischar (plot_set.xtick)
            if strcmp(plot_set.xtick, 'none')
                hfig.XTick = plot_set.xlim(2)*1000;
            end
        else
            hfig.XTick = plot_set.xtick;
        end
    end
    
    % X-tick label
    if isfield (plot_set, 'xtick_label') && isfield(plot_set, 'mat_x')
        
        % Find x-tick marks
        temp1 = plot_set.mat_x;
        c1 = [];
        for j = 1:size(temp1, 3)
            c1(j) = nanmean(temp1(:,:,j));
        end
        
        hfig.XTick = c1;
        set(hfig,'XTickLabel', plot_set.xtick_label,'FontSize', plot_set.font_size_label)
    end
    
    % Y lim
    if isfield (plot_set, 'ylim')
        hfig.YLim = plot_set.ylim;
    end
    
    %  X lim
    if isfield (plot_set, 'xlim')
        hfig.XLim = plot_set.xlim;
    end
    
    % X axis label
    if isfield (plot_set, 'xlabel') && ~isfield(plot_set, 'xtick_label')
        xlabel (plot_set.xlabel, 'FontSize', plot_set.font_size_label);
    end
    
    % Y axis label
    if isfield (plot_set, 'ylabel')
        ylabel (plot_set.ylabel, 'FontSize', plot_set.font_size_label);
    end
    
    % Figure title
    if isfield (plot_set, 'figure_title')
        if isfield (plot_set, 'figure_title_color')
            if numel(plot_set.figure_title_color)==1
                ind = plot_set.data_color;
                plot_set.title_color = settings.color1(ind,:);
            elseif numel(plot_set.figure_title_color)==3
                plot_set.title_color = plot_set.data_color;
            end
            title (plot_set.figure_title, 'FontSize', plot_set.font_size_label, 'Color', plot_set.title_color);
        else
            title (plot_set.figure_title, 'FontSize', plot_set.font_size_label)
        end
    end
    
end


