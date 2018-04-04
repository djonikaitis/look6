% Plots lines and sets up figure settings
% Options:

% plot_set.plot_remove_nan - removes NaN values from line plotting. Default
% is 1;
% plot_set.mat_y - data for y axis (else wont plot any data)
% plot_set.mat_x - data for x axis. (else it will plot as 1:x elements)
%
% plot_set.ebars_lower_y - is lower bound of error bars (else wont plot error bars)
% plot_set.ebars_upper_y - is upper bound of error bars (else wont plot error bars)
% plot_set.ebars_lower_x - optional
% plot_set.ebars_upper_x - optional
%
% plot_set.data_color - colors for the figure. It either refers to
% settings.color1 variable or can be direct colors values (1:numberOfColors, 3RGB)
%
% plot_set.data_color_min & plot_set.data_color_max is colors for the range
% specification. It can be either a direct color (3 values) or refer to
% settings.color1 prespecified colors.
%
% plot_set.bar_base_value - whether bars start at 0 or lower/higher;
% plot_set.ytick - else will use values based on the data
% plot_set.xtick - else will use values based on the data
% plot_set.xtick_label - else will use values based on the data
% plot_set.ylim - else will use values based on the data
% plot_set.xlim - else will use values based on the data
% plot_set.figure_title


%% Initialize parameters

if ~isfield(plot_set, 'bar_width')
    plot_set.bar_width = 0.05;
end

if ~isfield (plot_set, 'space_width')
    plot_set.space_width = plot_set.bar_width * 0.3;
end

if ~isfield(plot_set, 'bar_base_value')
    plot_set.bar_base_value = 0;
end

if isfield (plot_set, 'legend') && isfield (plot_set, 'legend_x_coord') && ~isfield(plot_set, 'legend_rotation')
    plot_set.legend_rotation = 0;
else
    plot_set.legend_rotation = 90;
end

%% X & Y data

% Check if Y data exists
if ~isfield (plot_set, 'mat_y')
    fprintf('Y data not present, will set figure options without plotting data\n')
end

% Create X data if needed
if ~isfield (plot_set, 'mat_x') && isfield (plot_set, 'mat_y')
    plot_set.mat_x = plot_helper_bargraph_coordinates_x_v10(plot_set);
end


%% X & Y error bars

% Make sure ebars_upper_x & ebars_lower_x exists
if (isfield (plot_set, 'ebars_lower_y') && isfield (plot_set, 'ebars_upper_y')) && ...
        (~isfield (plot_set, 'ebars_lower_x') && ~isfield (plot_set, 'ebars_upper_x'))
    
    if ~isfield (plot_set, 'mat_x')
        plot_set.ebars_lower_x = plot_helper_bargraph_coordinates_x_v10(plot_set);
        plot_set.ebars_upper_x = plot_helper_bargraph_coordinates_x_v10(plot_set);
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
    plot_set.val1_min_y = 0.06;
    plot_set.val1_max_y = 0.06;
    plot_set.val1_min_x = 0.2;
    plot_set.val1_max_x = 0.2;
else
    plot_set.val1_min_y = 0.06;
    plot_set.val1_max_y = 0.06;
    plot_set.val1_min_x = 0.2;
    plot_set.val1_max_x = 0.2;
end
plot_helper_general_v10;


%% Calculate X and Y ticks in the figure

plot_set.helper_part = 'calculate x and y ticks';
plot_helper_general_v10


%% Calculate colors

plot_set.helper_part = 'calculate colors';
if ~isfield(plot_set, 'color_dim')
    plot_set.color_dim = 2; % Which dimension to use for calculation of colors
end
plot_helper_general_v10


%% Plot bars

if isfield (plot_set, 'mat_y')
    
    for m1 = 1:size(plot_set.mat_y, 2)
        for o1 = 1:size(plot_set.mat_y, 3)
            
            % Select data dimension
            mat_y_temp1_fig = plot_set.mat_y(:,m1,o1);
            mat_x_temp1_fig = plot_set.mat_x(:,m1,o1);
            
            % Remove NaN values from Y data
            if isfield(plot_set, 'plot_remove_nan') && plot_set.plot_remove_nan==1
                index = plot_set.mat_remove_nan(:,m1,o1);
                mat_y_temp1_fig = mat_y_temp1_fig(~index);
                mat_x_temp1_fig = mat_x_temp1_fig(~index);
            end
            
            % Draw a bar
            if ~isempty(mat_y_temp1_fig) && ~isempty(mat_x_temp1_fig) && ...
                    numel(mat_x_temp1_fig) == numel(mat_y_temp1_fig)
                
                % Select color
                if plot_set.color_dim == 2
                    ind1 = m1;
                elseif plot_set.color_dim == 3
                    ind1 = o1;
                end
                color1 = plot_set.main_color(ind1,:);
                color1(color1>1)=1;
                
                %=======
                % MEANS
                if size(mat_y_temp1_fig,1)>1
                    error ('bar plots not written for multiple rows of data')
                else
                    h = bar(mat_x_temp1_fig, mat_y_temp1_fig, plot_set.bar_width);
                end
                
                % Set color
                set (h(end), 'LineWidth', settings.wlineerror, 'EdgeColor', color1, 'FaceColor', color1, 'BaseValue', plot_set.bar_base_value);
                
            end
        end
    end
    
end


%% Plot error bars

if  isfield (plot_set, 'ebars_upper_y') && isfield (plot_set, 'ebars_lower_y') && ...
        isfield (plot_set, 'ebars_upper_x') && isfield (plot_set, 'ebars_lower_x')

    for m1 = 1:size(plot_set.ebars_upper_y, 2)
        for o1 = 1:size(plot_set.ebars_upper_y, 3)

            % Select Y data
            ebars_lower_y_temp1_fig = plot_set.ebars_lower_y(:,m1,o1);
            ebars_upper_y_temp1_fig = plot_set.ebars_upper_y(:,m1,o1);

            % Remove NaN values from Y data
            if isfield(plot_set, 'plot_remove_nan') && plot_set.plot_remove_nan==1
                index = plot_set.mat_remove_nan(:,m1,o1);
                ebars_lower_y_temp1_fig = ebars_lower_y_temp1_fig(~index);
                ebars_upper_y_temp1_fig = ebars_upper_y_temp1_fig(~index);
            end

            % Select X data
            ebars_lower_x_temp1_fig = plot_set.ebars_lower_x(:,m1,o1);
            ebars_upper_x_temp1_fig = plot_set.ebars_upper_x(:,m1,o1);

            % Remove NaN values from X data
            if isfield(plot_set, 'plot_remove_nan') && plot_set.plot_remove_nan==1
                index = plot_set.mat_remove_nan(:,m1,o1);
                ebars_lower_x_temp1_fig = ebars_lower_x_temp1_fig(~index);
                ebars_upper_x_temp1_fig = ebars_upper_x_temp1_fig(~index);
            end

            % Get Y data if it exist for up-down error bars
            if isfield (plot_set, 'mat_y')

                % Select Y data averages
                mat_y_temp1_fig = plot_set.mat_y(:,m1,o1);

                % Remove NaN values from Y data
                if isfield(plot_set, 'plot_remove_nan') && plot_set.plot_remove_nan==1
                    index = plot_set.mat_remove_nan(:,m1,o1);
                    mat_y_temp1_fig = mat_y_temp1_fig(~index);
                end
                
            end

            % Draw a bar
            if ~isempty(mat_y_temp1_fig) && ~isempty(mat_x_temp1_fig) && ...
                    numel(mat_x_temp1_fig) == numel(mat_y_temp1_fig)

                % Select color
                if plot_set.color_dim == 2
                    ind1 = m1;
                elseif plot_set.color_dim == 3
                    ind1 = o1;
                end
                color1 = plot_set.main_color(ind1,:);
                color1(color1>1)=1;
                color2 = plot_set.shade_color(ind1,:);
                color2(color2>1)=1;

                if isfield (plot_set, 'mat_y')

                    % Calculate means if necessary
                    if size(mat_y_temp1_fig,1)>1
                        error ('Error bar plotting not specified for multipe rows of data')
                    else
                        mat_y_temp1_fig = nanmean(mat_y_temp1_fig);
                    end
                    
                    if sign(mat_y_temp1_fig)>=0
                        h = plot([ebars_lower_x_temp1_fig, ebars_upper_x_temp1_fig], [mat_y_temp1_fig, ebars_upper_y_temp1_fig]);
                        set (h(end), 'LineWidth', settings.wlineerror, 'Color', color1)
                        h = plot([ebars_lower_x_temp1_fig, ebars_upper_x_temp1_fig], [ebars_lower_y_temp1_fig, mat_y_temp1_fig]);
                        set (h(end), 'LineWidth', settings.wlineerror, 'Color', color2)
                    else
                        h = plot([ebars_lower_x_temp1_fig, ebars_upper_x_temp1_fig], [mat_y_temp1_fig, ebars_upper_y_temp1_fig]);
                        set (h(end), 'LineWidth', settings.wlineerror, 'Color', color2)
                        h = plot([ebars_lower_x_temp1_fig, ebars_upper_x_temp1_fig], [ebars_lower_y_temp1_fig, mat_y_temp1_fig]);
                        set (h(end), 'LineWidth', settings.wlineerror, 'Color', color1)
                    end
                    
                else % IF no mat_y exists
                    h = plot([ebars_lower_x_temp1_fig, ebars_upper_x_temp1_fig], [ebars_lower_y_temp1_fig, ebars_upper_y_temp1_fig]);
                    set (h(end), 'LineWidth', settings.wlineerror, 'Color', color1)
                end

            end
        end
    end

end


%% Legend


% Legend x coordinate
if isfield (plot_set, 'legend') && ~isfield (plot_set, 'legend_x_coord')

    if isfield(plot_set, 'mat_x')
        cx1 = [];
        for i = 1:size(plot_set.mat_x, 2)
            cx1(i) = plot_set.mat_x(1,i,1);
        end
        plot_set.legend_rotation = 90;
        fprintf('Legend coordinate x set automatically based on data\n')
    elseif isfield(plot_set, 'xlim')
        cx1 = plot_set.xlim(1)+1;
        plot_set.legend_rotation = 0;
        fprintf('No data exist, legend coordinate x set based on axis limits\n')
    else
        error ('Not possible to set x legend coordinate')
    end

    plot_set.legend_x_coord = cx1;

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
        color1 = [0.9,0.9,0.9];
        
        % Set font size
        text(x1, y1, l1,...
            'Color', color1, 'FontSize', plot_set.font_size_label, 'HorizontalAlignment', 'left', 'Rotation', plot_set.legend_rotation);
        
        
    end
end

%% Figure general setup

plot_set.helper_part = 'general setup';
plot_helper_general_v10
