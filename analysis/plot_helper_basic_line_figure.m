% Plots lines and sets up figure settings
% Options:

% plot_set.plot_remove_nan - removes NaN values from line plotting
% plot_set.mat_y - data for y axis (else wont plot any data)
% plot_set.mat_x - data for x axis. (else it will plot as 1:x elements)
% plot_set.ebars_lower_y - is lower bound of error bars (else wont plot error bars)
% plot_set.ebars_upper_y - is upper bound of error bars (else wont plot error bars)
% plot_set.ebars_lower_x - optional
% plot_set.ebars_upper_x - optional
% plot_set.ebars_shade - plots error bars as shaded area
% plot_set.ebars_line - plots error bars as lines area
%
% plot_set.data_color - colors for the figure. It either refers to
% settings.color1 variable or can be direct colors values (1:numberOfColors, 3RGB)
%
% plot_set.data_color_min & plot_set.data_color_max is colors for the range
% specification. It can be either a direct color (3 values) or refer to
% settings.color1 prespecified colors.
%
% plot_set.YTick (or ytick) - else will use values based on the data
% plot_set.XTick (or xtick) - else will use values based on the data
% plot_set.YLim (or ylim) - else will use values based on the data
% plot_set.XLim (or xlim) - else will use values based on the data
% plot_set.figure_title


%% X & Y data

% Check if Y data exists
if ~isfield (plot_set, 'mat_y')
    fprintf('Y data not present, will set figure options without plotting data\n')
end

% Flip dimensions if necessary
if isfield (plot_set, 'mat_x') && isfield (plot_set, 'mat_y')
    [m1, n1, o1] = size(plot_set.mat_y);
    [m2, n2, o2] = size(plot_set.mat_x);
    if m1~=n1 && m2~=n2 && m1~=m2 && m1==n2 && n1==m2 && o2==1
        plot_set.mat_x = plot_set.mat_x';
    end
end

% Create X data if needed
if ~isfield (plot_set, 'mat_x') && isfield (plot_set, 'mat_y')
    plot_set.mat_x = [];
    [m,n,~] = size(plot_set.mat_y);
    a = 1:n;
    plot_set.mat_x = repmat(a, m, 1);
end

% Make X data same size as Y, dimension 1;
if isfield (plot_set, 'mat_x')
    [m1, n1, o1] = size(plot_set.mat_y);
    [m2, n2, o2] = size(plot_set.mat_x);
    if m1>1 && m2==1
        plot_set.mat_x = repmat(plot_set.mat_x, m1, 1);
    end
end

% Make X data same size as Y, dimension 3;
if isfield (plot_set, 'mat_x')
    [m1, n1, o1] = size(plot_set.mat_y);
    [m2, n2, o2] = size(plot_set.mat_x);
    if o1>1 && o2==1
        plot_set.mat_x = repmat(plot_set.mat_x, 1, 1, o1);
    end
end


%% X & Y error bars data


% Make sure ebars_upper_x & ebars_lower_x exists
if (isfield (plot_set, 'ebars_lower_y') && isfield (plot_set, 'ebars_upper_y')) && ...
        (~isfield (plot_set, 'ebars_lower_x') && ~isfield (plot_set, 'ebars_upper_x'))
    
    if ~isfield (plot_set, 'mat_x')
        plot_set.ebars_lower_x = [];
        plot_set.ebars_upper_x = [];
        [m,n,~] = size(plot_set.ebars_lower_y);
        for m1 = 1:m
            plot_set.ebars_lower_x(m1,1:n,1) = 1:n;
            plot_set.ebars_upper_x(m1,1:n,1) = 1:n;
        end
    elseif isfield (plot_set, 'mat_x')
        plot_set.ebars_lower_x = plot_set.mat_x;
        plot_set.ebars_upper_x = plot_set.mat_x;
    end
    
end

% Make X data same size as Y
if isfield (plot_set, 'ebars_lower_x') && isfield (plot_set, 'ebars_lower_y')
    [m1, n1, o1] = size(plot_set.ebars_lower_y);
    [m2, n2, o2] = size(plot_set.ebars_lower_x);
    
    % Make X data same size as Y, dimension 1;
    if m1>1 && m2==1
        plot_set.ebars_lower_x = repmat(plot_set.ebars_lower_x, m1, 1);
        plot_set.ebars_upper_x = repmat(plot_set.ebars_upper_x, m1, 1);
    end
    
    % Make X data same size as Y, dimension 3;
    if o1>1 && o2==1
        plot_set.ebars_lower_x = repmat(plot_set.ebars_lower_x, 1, 1, o1);
        plot_set.ebars_upper_x = repmat(plot_set.ebars_upper_x, 1, 1, o1);
    end
end


%% Make sure size of all variables is equal

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

%% Remove NaN values

% plot_set.mat_remove_nan is output matrix for it

if ~isfield (plot_set, 'plot_remove_nan')
    plot_set.plot_remove_nan = 1;
end

if isfield (plot_set, 'mat_y') || isfield (plot_set, 'ebars_lower_y')
    
    if isfield (plot_set, 'mat_y')
        f_name = 'mat_y';
    elseif ~isfield (plot_set, 'mat_y') && isfield (plot_set, 'ebars_lower_y')
        f_name = 'ebars_lower_y';
    end
    
    [m,n,o] = size(plot_set.(f_name));
    plot_set.mat_remove_nan = NaN(m, n, o);
    
    for i=1:size(plot_set.(f_name), 3)
        
        temp1 = plot_set.(f_name)(:,:,i);
        if size(temp1,1)>1
            b = nanmean(temp1);
        else
            b = temp1;
        end
        
        % Repeat for each row, if needed
        for j = 1:m
            plot_set.mat_remove_nan(j,:,i) = isnan(b);
        end
        
    end
    
else
    fprintf('No data exists, thus no NaNs are removed')
end





%% Calculate X and Y limits in the figure

% Field names
f1_name_temp = cell(1); f1_name = cell(1);
f1_name_temp{1} = 'YLim';
f1_name_temp{2} = 'XLim';
f1_name{1} = 'ylim';
f1_name{2} = 'xlim';

% Rename variables if needed
for k=1:2
    if isfield(plot_set, f1_name_temp{k})
        plot_set.(f1_name{k}) = plot_set.(f1_name_temp{k});
        plot_set = rmfield(plot_set, f1_name_temp{k});
    end
end

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
                
                if isfield (plot_set, 'legend')
                    if k==1
                        val1_min = 0.20;
                        val1_max = 0.50;
                    elseif k==2
                        val1_min = 0.06;
                        val1_max = 0.06;
                    end
                else
                    val1_min = 0.06;
                    val1_max = 0.06;
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
end

%% Calculate X and Y ticks in the figure

% Field names
f1_name_temp = cell(1); f1_name = cell(1); f1_name_lim = cell(1);
f1_name_temp{1} = 'YTick';
f1_name_temp{2} = 'XTick';
f1_name{1} = 'ytick';
f1_name{2} = 'xtick';
f1_name_lim{1} = 'ylim';
f1_name_lim{2} = 'xlim';

% Rename variables if needed
for k=1:2
    if isfield(plot_set, f1_name_temp{k})
        plot_set.(f1_name{k}) = plot_set.(f1_name_temp{k});
        plot_set = rmfield(plot_set, f1_name_temp{k});
    end
end


% if X-Y limits dont exist, calculate them
for k = 1:2
    
    if isfield (plot_set, f1_name{k}) && ~isempty(plot_set.(f1_name{k}))
        
        % If ticks do not exist, calculate your own
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

%% Calculate colors to be used

% Else it will read out specified colors

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
            if size(plot_set.(f_name),3) == size(plot_set.data_color,1) % Only if appropriate number of colors is specified
                plot_set.main_color = plot_set.data_color;
            end
        elseif sum(plot_set.data_color>=1) == numel(plot_set.data_color) % Very likely to refer to indexes
            if size(plot_set.(f_name),3) == numel(plot_set.data_color) % Only if appropriate number of colors is specified
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
            n = size(plot_set.(f_name),3);
        elseif isfield (plot_set, 'data_color_min') && isfield (plot_set, 'data_color_max') && numel(plot_set.data_color_min)==3 && numel(plot_set.data_color_max)==3
            col_min = plot_set.data_color_min;
            col_max = plot_set.data_color_max;
            n = size(plot_set.(f_name),3);
        else % Initialize some backup colors
            fprintf('Color values either are not specified correctly, or are missing. Will use default colors\n')
            col_min = [0.2, 0.2, 0.2];
            col_max = [0.99, 0.3, 0.3];
            n = size(plot_set.(f_name),3);
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


%% Plot error shaded area


if isfield (plot_set, 'ebars_lower_y') && isfield (plot_set, 'ebars_upper_y') && ...
        isfield (plot_set, 'ebars_shade')
    
    [m,~,o] = size(plot_set.ebars_lower_y);
    
    for m1 = 1:m
        for o1 = 1:o
            
            % Select Y data
            ebars_lower_y_temp1_fig = plot_set.ebars_lower_y(m1,:,o1);
            ebars_upper_y_temp1_fig = plot_set.ebars_upper_y(m1,:,o1);
            
            % Remove NaN values from Y data
            if isfield(plot_set, 'plot_remove_nan') && plot_set.plot_remove_nan==1
                index = plot_set.mat_remove_nan(m1,:,o1);
                ebars_lower_y_temp1_fig = ebars_lower_y_temp1_fig(~index);
                ebars_upper_y_temp1_fig = ebars_upper_y_temp1_fig(~index);
            end
            
            % Select X data
            ebars_lower_x_temp1_fig = plot_set.ebars_lower_x(m1,:,o1);
            ebars_upper_x_temp1_fig = plot_set.ebars_upper_x(m1,:,o1);
            
            % Remove NaN values from X data
            if isfield(plot_set, 'plot_remove_nan') && plot_set.plot_remove_nan==1
                index = plot_set.mat_remove_nan(m1,:,o1);
                ebars_lower_x_temp1_fig = ebars_lower_x_temp1_fig(~index);
                ebars_upper_x_temp1_fig = ebars_upper_x_temp1_fig(~index);
            end
            
            % Plot only if Y values are not NaNs
            if ~isempty(ebars_lower_y_temp1_fig) && ~isempty(ebars_lower_y_temp1_fig) && ...
                    sum(isnan(ebars_lower_y_temp1_fig)) ~= numel(ebars_lower_y_temp1_fig) && ...
                    sum(isnan(ebars_upper_y_temp1_fig)) ~= numel(ebars_upper_y_temp1_fig)
                
                xc1 = ebars_lower_x_temp1_fig(1); % Min x, min y
                xc2 = ebars_upper_x_temp1_fig(1); % Min x, max y
                xc3 = ebars_upper_x_temp1_fig; % Upper bound of errors
                xc4 = ebars_upper_x_temp1_fig(end); % Max x, max y
                xc5 = ebars_lower_x_temp1_fig(end); % Max x, min y
                xc6 = ebars_lower_x_temp1_fig;
                xc6 = fliplr(xc6);
                
                yc1 = ebars_lower_y_temp1_fig(:,1,1); % Lower bound of errors
                yc2 = ebars_upper_y_temp1_fig(:,1,1); % upper bound of errors
                yc3 = ebars_upper_y_temp1_fig(:,:,1); % Upper bound of errors
                yc4 = ebars_upper_y_temp1_fig(:,end,1); % Upper bound of errors
                yc5 = ebars_lower_y_temp1_fig(:,end,1); % Lower bound of errors
                yc6 = ebars_lower_y_temp1_fig(:,:,1); % Lower bound of errors
                yc6 = fliplr(yc6);
                
                % Select color
                color1 = plot_set.shade_color(o1,:);
                color1(color1>1)=1;
                
                h = fill([xc1,xc2,xc3,xc4, xc5, xc6],[yc1, yc2, yc3, yc4, yc5, yc6], [1 0.7 0.2], 'linestyle', 'none');
                set (h(end), 'FaceColor', color1,'linestyle', 'none', 'FaceAlpha', 1)
                
            end
        end
        
    end
    
end


%%  Plot lines

if isfield (plot_set, 'mat_y')
    
    for m1 = 1:size(plot_set.mat_y, 1)
        for o1 = 1:size(plot_set.mat_y,3)
            
            % Select data dimension
            mat_y_temp1_fig = plot_set.mat_y(m1,:,o1);
            mat_x_temp1_fig = plot_set.mat_x(m1,:,o1);
            
            % Remove NaN values from Y data
            if isfield(plot_set, 'plot_remove_nan') && plot_set.plot_remove_nan==1
                index = plot_set.mat_remove_nan(m1,:,o1);
                mat_y_temp1_fig = mat_y_temp1_fig(~index);
                mat_x_temp1_fig = mat_x_temp1_fig(~index);
            end
            
            % Draw line
            if ~isempty(mat_y_temp1_fig) && ~isempty(mat_x_temp1_fig) && ...
                    numel(mat_x_temp1_fig) == numel(mat_y_temp1_fig)
                
                h=plot(mat_x_temp1_fig, mat_y_temp1_fig);
                
                % Select color
                color1 = plot_set.main_color(o1,:);
                color1(color1>1)=1;
                
                % Set line color and width
                if m1==1 && isfield (settings, 'wlinegraph')
                    set (h(end), 'LineWidth', settings.wlinegraph, 'Color', color1)
                elseif m1>1 && isfield (settings, 'wlineerror')
                    set (h(end), 'LineWidth', settings.wlineerror, 'Color', color1)
                else
                    fprintf('Line width not specified in settings.wlinegraph, using default line width\n')
                    set (h(end), 'LineWidth', 1, 'Color', color1)
                end
                
            end
        end
    end
end


%% Legend

% Legend x coordinate
if isfield (plot_set, 'legend') && ~isfield (plot_set, 'legend_x_coord')

    if isfield(plot_set, 'mat_x')
        cx1 = plot_set.mat_x(1);
        fprintf('Legend coordinate x set automatically based on data\n')
    elseif isfield(plot_set, 'xlim')
        cx1 = plot_set.xlim(1)+1;
        fprintf('No data exist, legend coordinate x set based on axis limits\n')
    else
        error ('Not possible to set x legend coordinate')
    end

    % Calculate legend position
    temp1 = [];
    for k=1:numel(plot_set.legend)
        temp1(k) = cx1;
    end

    plot_set.legend_x_coord = temp1;

end

if isfield (plot_set, 'legend') && ~isfield (plot_set, 'legend_y_coord')

    if isfield(plot_set, 'ylim')
        tmin = plot_set.ylim(1);
        tmax = plot_set.ylim(2);
        fprintf('Legend coordinate y set automatically based on data\n')
    else
        error ('Not possible to set y legend coordinate')
    end

    % Calculate legend position
    temp1 = []; x1_temp = [];
    for k=1:numel(plot_set.legend)
        temp1(k) = tmax - (tmax - tmin)*0.1*k;
    end

    plot_set.legend_y_coord = temp1;

end

% Set the legend
if isfield (plot_set, 'legend')

    for k=1:numel(plot_set.legend)

        l1 = plot_set.legend{k};
        x1 = plot_set.legend_x_coord(k);
        y1 = plot_set.legend_y_coord(k);

        % Select color
        color1 = plot_set.main_color(k,:);

        % Set font size
        if isfield (settings, 'fontszlabel')
            text(x1, y1, l1, 'Color', color1,  'FontSize', settings.fontszlabel, 'HorizontalAlignment', 'left')
        else
            fprintf('Font size not specified in settings.fontszlabel, using default fonts\n')
            text(x1, y1, l1, 'Color', color1,  'FontSize', 12, 'HorizontalAlignment', 'left')
        end

    end
end



%% Other

% Font size
hfig = gca;
if isfield (settings, 'fontsz')
    set (hfig, 'FontSize', settings.fontsz);
else
    fprintf('Font size not specified in settings.fontsz, using default fonts\n')
    set (hfig, 'FontSize', 10);
end

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
if isfield (plot_set, 'xtick')
    if ischar (plot_set.xtick)
        if strcmp(plot_set.xtick, 'none')
            hfig.XTick = plot_set.xlim(2)*1000;
        end
    else
        hfig.XTick = plot_set.xtick;
    end
end

% Y Lim
if isfield (plot_set, 'ylim')
    hfig.YLim = plot_set.ylim;
end

%  X Lim
if isfield (plot_set, 'xlim')
    hfig.XLim = plot_set.xlim;
end

% X label
if isfield (plot_set, 'xlabel')
    xlabel (plot_set.xlabel, 'FontSize', settings.fontszlabel);
end

% Y label
if isfield (plot_set, 'ylabel')
    ylabel (plot_set.ylabel, 'FontSize', settings.fontszlabel);
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
        title (plot_set.figure_title, 'FontSize', settings.fontszlabel, 'Color', plot_set.title_color);
    else
        title (plot_set.figure_title, 'FontSize', settings.fontszlabel)
    end
end
