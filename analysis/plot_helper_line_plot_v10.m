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


%% Initialize some parameters


if  ~isfield(plot_set, 'legend_rotation')
    plot_set.legend_rotation = 0;
end


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
    plot_set.mat_x = repmat([1:n], m, 1);
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

%% Check that all variable sizes match

plot_set.helper_part = 'size check';
plot_helper_general_v10;


%% Remove NaN values

plot_set.helper_part = 'remove nan';
plot_helper_general_v10;


%% Calculate x & y lim

plot_set.helper_part = 'calculate data limits';
plot_helper_general_v10;

plot_set.helper_part = 'calculate axis limits';
if isfield (plot_set, 'legend')
    plot_set.val1_min_y = 0.1;
    plot_set.val1_max_y = 0.5;
    plot_set.val1_min_x = 0.06;
    plot_set.val1_max_x = 0.06;
else
    plot_set.val1_min_y = 0.06;
    plot_set.val1_max_y = 0.06;
    plot_set.val1_min_x = 0.06;
    plot_set.val1_max_x = 0.06;
end
plot_helper_general_v10;


%% Calculate X and Y ticks in the figure

plot_set.helper_part = 'calculate x and y ticks';
plot_helper_general_v10


%% Calculate colors

plot_set.helper_part = 'calculate colors';
if ~isfield(plot_set, 'color_dim')
    plot_set.color_dim = 3; % Which dimension to use for calculation of colors
end
plot_helper_general_v10


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
            
            % Create plotting data
            mat_y_3 = cell(1);
            mat_x_3 = cell(1);
            
            % Select data dimension
            mat_y_2 = plot_set.mat_y(m1,:,o1);
            mat_x_2 = plot_set.mat_x(m1,:,o1);
            
            % Remove NaN values from Y data
            if isfield(plot_set, 'plot_remove_nan') && plot_set.plot_remove_nan==1
                index = plot_set.mat_remove_nan(m1,:,o1);
                mat_y_3{1} = mat_y_2(~index);
                mat_x_3{1} = mat_x_2(~index);
            end
            
            % Split data if NaN should be removed
            if isfield(plot_set, 'plot_remove_nan') && plot_set.plot_remove_nan==0
                
                % Find existing data
                index = plot_set.mat_remove_nan(m1,:,o1);
                ind_nan = find(index == 1);
                ind_nan_start = [1, ind_nan+1];
                ind_nan_end = [ind_nan-1, numel(index)];
                t1 = (ind_nan_end - ind_nan_start)<0;
                ind_nan_start(t1)=[]; ind_nan_end(t1)=[];
                
                % Prepare split matrix
                if numel(ind_nan_start)>0
                    for i = 1:numel(ind_nan_start)
                        mat_y_3{i} =  mat_y_2(ind_nan_start(i):ind_nan_end(i));
                        mat_x_3{i} =  mat_x_2(ind_nan_start(i):ind_nan_end(i));
                    end
                end
            end
            
            % Draw line
            for p1 = 1:numel(mat_y_3)
                
                mat_y_4 = mat_y_3{p1};
                mat_x_4 = mat_x_3{p1};
                
                if ~isempty(mat_y_4) && ~isempty(mat_x_4) && ...
                        numel(mat_x_4) == numel(mat_y_4)
                    
                    h=plot(mat_x_4, mat_y_4);
                    
                    % Select color
                    color1 = plot_set.main_color(o1,:);
                    color1(color1>1)=1;
                    
                    % Set line color and width
                    if m1==1 && isfield (settings, 'wlinegraph')
                        numel(mat_x_4)
                        if numel(mat_x_4)>1
                            set (h(end), 'LineWidth', settings.wlinegraph, 'Color', color1)
                        elseif numel(mat_x_4)==1
                            
                            if isfield(plot_set, 'marker_shape')
                                mshape1 = plot_set.marker_shape{o1};
                            else
                                mshape1 = settings.marker_type{1};
                            end
                            
                            set (h(end), 'LineWidth', settings.wlinegraph, 'Color', color1, ...
                                'Marker', mshape1, 'MarkerFaceColor', color1, 'MarkerSize', settings.marker_size)
                        end
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
        text(x1, y1, l1, 'Color', color1,  'FontSize', plot_set.font_size_label, 'HorizontalAlignment', 'left')
        
    end
end


%% Figure general setup

plot_set.helper_part = 'general setup';
plot_helper_general_v10
