% Plots lines and sets up figure settings
% Options:
%
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
% plot_set.YTick - else will use values based on the data
% plot_set.XTick - else will use values based on the data
% plot_set.YTLim - else will use values based on the data
% plot_set.XLim - else will use values based on the data
% plot_set.figure_title


%% Make sure pbins exists

if ~isfield (plot_set, 'mat_x') && isfield (plot_set, 'mat_y')
    plot_set.mat_x = 1:numel(plot_set.mat_y);
end

if ~isfield (plot_set, 'plot_remove_nan')
    plot_set.plot_remove_nan = 1;
end



%% Calculate colors to be used

% Else it will read out specified colors

if isfield (plot_set, 'mat_y')
    
    % Data_color exists
    if isfield(plot_set, 'data_color') && ~isempty(plot_set.data_color)
        if sum(sum(plot_set.data_color<=1)) == numel(plot_set.data_color)
            if size(plot_set.mat_y,3) == size(plot_set.data_color,1) % Only if appropriate number of colors is specified
                plot_set.color1 = plot_set.data_color;
            end
        elseif sum(plot_set.data_color>=1) == numel(plot_set.data_color) % Very likely to refer to indexes
            if size(plot_set.mat_y,3) == numel(plot_set.data_color) % Only if appropriate number of colors is specified
                ind = plot_set.data_color;
                plot_set.color1 = settings.color1(ind,:);
                plot_set.face_color1 = settings.face_color1(ind,:);
            end
        end
    end
    
    % Color range exists
    if ~isfield (plot_set, 'color1')
        
        % How many color values to calculate
        if isfield (plot_set, 'data_color_min') && isfield (plot_set, 'data_color_max') && numel(plot_set.data_color_min)==1 && numel(plot_set.data_color_max)==1
            col_min = settings.color1 (plot_set.data_color_min,:);
            col_max = settings.color1 (plot_set.data_color_max,:);
            n = size(plot_set.mat_y,3);
        elseif isfield (plot_set, 'data_color_min') && isfield (plot_set, 'data_color_max') && numel(plot_set.data_color_min)==3 && numel(plot_set.data_color_max)==3
            col_min = plot_set.data_color_min;
            col_max = plot_set.data_color_max;
            n = size(plot_set.mat_y,3);
        else % Initialize some backup colors
            fprintf('Color values either are not specified, or are missing. Will use default colors\n')
            col_min = [0.2, 0.2, 0.2];
            col_max = [0.3, 0.8, 0.1];
            n = size(plot_set.mat_y,3);
        end
        
        % Other location colors are calculated as a range
        plot_set.color1 = [];
        if n>1
            d1 = col_max-col_min;
            stepsz = 1/(n-1);
            for i=1:n
                plot_set.color1(i,:)=col_min + (d1*stepsz)*(i-1);
            end
        else
            plot_set.color1(1,:)=col_min;
        end
    end
    
    if ~isfield (plot_set, 'face_color1')
        plot_set.face_color1 = [];
        for i = 1:size(plot_set.color1,1)
            d1 = 1 - plot_set.color1(i,:);
            plot_set.face_color1(i,:) = plot_set.color1(i,:) + d1.*0.6;
        end
    end
    
end


%% Plot error shaded area


if (  (isfield (plot_set, 'ebars_lower_y') && isfield (plot_set, 'ebars_upper_y')) || ...
        (isfield (plot_set, 'ebars_lower') && isfield (plot_set, 'ebars_upper'))  ) ...
        && isfield (plot_set, 'ebars_shade')
    
    
    % Temp data selection
    if isfield (plot_set, 'ebars_lower_y') && isfield (plot_set, 'ebars_upper_y')
        temp1 = plot_set.ebars_lower_y;
    else
        temp1 = plot_set.ebars_lower;
    end
    
    for k = 1:size(temp1,3)
        
        % Select data dimension
        if isfield (plot_set, 'ebars_lower_y') && isfield (plot_set, 'ebars_upper_y')
            ebars_lower_y = plot_set.ebars_lower_y(:,:,k);
            ebars_upper_y = plot_set.ebars_upper_y(:,:,k);
        else
            ebars_lower_y = plot_set.ebars_lower(:,:,k);
            ebars_upper_y = plot_set.ebars_upper(:,:,k);
        end
        
        % Select x axis values
        % Use either values same as plotting
        % Or use pre-specified values
        if ~isfield(plot_set, 'ebars_upper_x')
            if size(plot_set.mat_y, 3)>1 && size(plot_set.mat_x, 3)==1
                temp_x_lower = plot_set.mat_x;
                temp_x_upper = plot_set.mat_x;
            elseif size(plot_set.mat_y, 3)==size(plot_set.mat_x, 3)
                temp_x_lower = plot_set.mat_x(:,:,k);
                temp_x_upper = plot_set.mat_x(:,:,k);
            else
                error ('X and Y matrix size mismatch')
            end
        elseif isfield(plot_set, 'ebars_lower_x') && isfield(plot_set, 'ebars_upper_x')
            if size(plot_set.mat_y, 3)>1 && size(plot_set.ebars_lower_x, 3)==1
                temp_x_lower = plot_set.ebars_lower_x;
                temp_x_upper = plot_set.ebars_upper_x;
            elseif size(plot_set.mat_y, 3)==size(plot_set.ebars_lower_x, 3)
                temp_x_lower = plot_set.ebars_lower_x(:,:,k);
                temp_x_upper = plot_set.ebars_upper_x(:,:,k);
            else
                error ('X and Y matrix size mismatch')
            end
        end
        
        % Remove missing data for easier plotting
        % Check one limit to check missing values
        if isfield(plot_set, 'plot_remove_nan') && plot_set.plot_remove_nan==1
            b = ebars_lower_y;
            ind = isnan(b);
            ebars_lower_y = b(:, ~ind);
            ebars_upper_x = temp_x_upper(:, ~ind);
            ebars_lower_x = temp_x_lower(:, ~ind);
        else
            ebars_upper_x = temp_x_upper;
            ebars_lower_x = temp_x_lower;
        end
        
        xc1 = ebars_lower_x(1); % Min x, min y
        xc2 = ebars_upper_x(1); % Min x, max y
        xc3 = ebars_upper_x; % Upper bound of errors
        xc4 = ebars_upper_x(end); % Max x, max y
        xc5 = ebars_lower_x(end); % Max x, min y
        xc6 = ebars_lower_x;
        xc6 = fliplr(xc6);
        
        yc1 = ebars_lower_y(:,1,1); % Lower bound of errors
        yc2 = ebars_upper_y(:,1,1); % upper bound of errors
        yc3 = ebars_upper_y(:,:,1); % Upper bound of errors
        yc4 = ebars_upper_y(:,end,1); % Upper bound of errors
        yc5 = ebars_lower_y(:,end,1); % Lower bound of errors
        yc6 = ebars_lower_y(:,:,1); % Lower bound of errors
        yc6 = fliplr(yc6);
        
        % Select color
        color1 = plot_set.face_color1(k,:);
        
        h=fill([xc1,xc2,xc3,xc4, xc5, xc6],[yc1, yc2, yc3, yc4, yc5, yc6], [1 0.7 0.2], 'linestyle', 'none');
        set (h(end), 'FaceColor', color1,'linestyle', 'none', 'FaceAlpha', 1)
        
    end
    
end


%%  Plot lines

if isfield (plot_set, 'mat_y')
    
    for k=1:size(plot_set.mat_y,3)
        
        % Select data dimension
        if size(plot_set.mat_y, 3)>1 && size(plot_set.mat_x, 3)==1
            temp_y = plot_set.mat_y(:,:,k);
            temp_x = plot_set.mat_x;
        elseif size(plot_set.mat_y, 3)==size(plot_set.mat_x, 3)
            temp_y = plot_set.mat_y(:,:,k);
            temp_x = plot_set.mat_x(:,:,k);
        else
            error ('X and Y matrix size mismatch')
        end
        
        % Calculate averages (if multiple data available)
        % Remove missing data for easier plotting
        if isfield(plot_set, 'plot_remove_nan') && plot_set.plot_remove_nan==1
            
            if size(temp_y,1)>1
                b = nanmean(temp_y);
                ind = isnan(b);
            else
                b = temp_y;
                ind = isnan(b);
            end
            mat_y = b(:, ~ind);
            mat_x = temp_x(:, ~ind);
            
        else
            
            if size(temp_y,1)>1
                b = nanmean(temp_y);
            else
                b = temp_y;
            end
            mat_y = b;
            mat_x = temp_x;
            
        end
        
        % Draw line
        if numel(mat_x) == numel(mat_y)
            h=plot(mat_x, mat_y);
        else
            error('X and Y matrix size mismatch')
        end
        
        % Select color
        color1 = plot_set.color1(k,:);
        
        % Set color and line width
        if isfield (settings, 'wlinegraph')
            set (h(end), 'LineWidth', settings.wlinegraph, 'Color', color1)
        else
            sprintf('Line width not specified in settings.wlinegraph, using default line width')
            set (h(end), 'LineWidth', 1, 'Color', color1)
        end
        
    end
end


%% Legend

% Plot legend text
if isfield (plot_set, 'legend')
    
    if isfield (plot_set, 'legend_x_coord') && isfield (plot_set, 'legend_y_coord')
        x1_temp = plot_set.legend_x_coord(k);
        y1_temp = plot_set.legend_y_coord(k);
    else
        
        % Legend coordinates not specified, using defaults
        fprintf('Legend coordinates not specified, using defaults\n')
        
        % Extract data regardless whether error bars exist or not
        if isfield (plot_set, 'ebars_lower_y') && isfield (plot_set, 'ebars_upper_y')
            t0 = plot_set.ebars_lower_y;
            t1 = plot_set.ebars_upper_y;
        elseif isfield (plot_set, 'ebars_lower') && isfield (plot_set, 'ebars_upper')
            t0 = plot_set.ebars_lower;
            t1 = plot_set.ebars_upper;
        elseif isfield (plot_set, 'mat_y')
            t0 = plot_set.mat_y;
            t1 = plot_set.mat_y;
        else
            t0 = -5;
            t1 = 5;
        end
        
        % Calculate min and max
        ps_h0_min = []; ps_h0_max = [];
        for i1 = 1:size(t0, 3)
            ps_h0_min(i1) = min(t0(:,:,i1));
            ps_h0_max(i1) = max(t1(:,:,i1));
        end
        
        % Calculate axis limits
        val1 = 0.5; 
        val2 = 0.2;
        
        ps_h0_max = max(ps_h0_max); ps_h0_min = min(ps_h0_min);
        ps_h_max = ps_h0_max + ((ps_h0_max - ps_h0_min) * val1);
        ps_h_min = ps_h0_min - ((ps_h0_max - ps_h0_min) * val2);
        
        % Calculate legend position
        for k=1:numel(plot_set.legend)
            y1_temp(k) = ps_h_max - (ps_h_max - ps_h_min)*0.1*k;
            x1_temp(k) = plot_set.mat_x(1);
        end
        
    end
    
    for k=1:numel(plot_set.legend)
        
        l1 = plot_set.legend{k};
        x1 = x1_temp(k);
        y1 = y1_temp(k);
        
        % Select color
        color1 = plot_set.color1(k,:);
        
        % Set font size
        if isfield (settings, 'fontszlabel')
            text(x1, y1, l1, 'Color', color1,  'FontSize', settings.fontszlabel, 'HorizontalAlignment', 'left')
        else
            sprintf('Font size not specified in settings.fontszlabel, using default fonts')
            text(x1, y1, l1, 'Color', color1,  'FontSize', 12, 'HorizontalAlignment', 'left')
        end
        
    end
end

hfig = gca;
set (hfig, 'FontSize', settings.fontsz);



%% Y Tick

if isfield (plot_set, 'YTick') && ~isempty(plot_set.YTick) && ~isstr(plot_set.YTick)
    
    hfig.YTick = plot_set.YTick;
    
else % If y-ticks do not exist, calculate your own
    
    fprintf('No values for YTick provided, calculating defaults\n')
    
    % Extract data regardless whether error bars exist or not
    if isfield (plot_set, 'ebars_lower_y') && isfield (plot_set, 'ebars_upper_y')
        t0 = plot_set.ebars_lower_y;
        t1 = plot_set.ebars_upper_y;
    elseif isfield (plot_set, 'ebars_lower') && isfield (plot_set, 'ebars_upper')
        t0 = plot_set.ebars_lower;
        t1 = plot_set.ebars_upper;
    elseif isfield (plot_set, 'mat_y')
        t0 = plot_set.mat_y;
        t1 = plot_set.mat_y;
    else
        t0 = -5;
        t1 = 5;
    end
    
    % Calculate min and max
    ps_h0_min = []; ps_h0_max = [];
    for i1 = 1:size(t0, 3)
        ps_h0_min(i1) = min(t0(:,:,i1));
        ps_h0_max(i1) = max(t1(:,:,i1));
    end
    
    % Calculate axis limits
    if isfield (plot_set, 'legend')
        val1 = 0.50; val2 = 0.20;
    else
        val1 = 0.20; val2 = 0.20;
    end
    ps_h0_max = max(ps_h0_max); ps_h0_min = min(ps_h0_min);
    ps_h_max = ps_h0_max + ((ps_h0_max - ps_h0_min) * val1);
    ps_h_min = ps_h0_min - ((ps_h0_max - ps_h0_min) * val2);
    
    % Select number of tick values
    try
        a = (ps_h_max-ps_h_min)/4;
        b = [0.1, 0.2, 0.5, 1:1:5, 10:5:25, 30:10:100, 150:50:250, 300:100:1000];
        c = b(a>=b);
        step1 = c(end);
    catch
        step1 = 1;
    end
    
    % Set ticks
    ps_tick = [-step1*1000:step1:step1*1000];
    try
        hfig.YTick = ps_tick;
    end
        
    % Clean up
    clear ps_tick; clear ps_h0_max; clear ps_h0_min; clear ps_h_max; clear ps_h_min; clear t0; clear t1;
    
end


%%  X Tick

if isfield (plot_set, 'XTick') && ~isempty(plot_set.XTick) && ~isstr(plot_set.XTick)
    
    hfig.XTick = plot_set.XTick;
    
elseif isfield (plot_set, 'mat_x')
    
    fprintf('No values for XTick provided, calculating defaults\n')
    
    % Extract data regardless whether error bars exist or not
    if isfield (plot_set, 'ebars_lower_x') && isfield (plot_set, 'ebars_upper_x')
        t0 = plot_set.ebars_lower_x;
        t1 = plot_set.ebars_upper_x;
    elseif isfield (plot_set, 'mat_x')
        t0 = plot_set.mat_x;
        t1 = plot_set.mat_x;
    else
        t0 = -5;
        t1 = 5;
    end
    
    % Calculate min and max
    ps_h0_min = []; ps_h0_max = [];
    for i1 = 1:size(t0, 3)
        ps_h0_min(i1) = min(t0(:,:,i1));
        ps_h0_max(i1) = max(t1(:,:,i1));
    end
    
    % Calculate axis limits
    val1 = 0.05; 
    val2 = 0.05;
    ps_h0_max = max(ps_h0_max); 
    ps_h0_min = min(ps_h0_min);
    ps_h_max = ps_h0_max + ((ps_h0_max - ps_h0_min) * val1);
    ps_h_min = ps_h0_min - ((ps_h0_max - ps_h0_min) * val2);
    
    % Select number of tick values
    try
        a = (ps_h_max-ps_h_min)/4;
        b = [0.1, 0.2, 0.5, 1:1:5, 10:5:25, 30:10:100, 150:50:250, 300:100:1000];
        c = b(a>=b);
        step1 = c(end);
    catch
        step1 = 1;
    end
    
    % Set ticks
    ps_tick = [-step1*1000:step1:step1*1000];
    try
        hfig.XTick = ps_tick;
    end
    
    clear ps_tick; clear ps_h0_max; clear ps_h0_min; clear ps_h_max; clear ps_h_min; clear t0; clear t1;
end



%% Y Lim

if isfield (plot_set, 'YLim')
    
    hfig.YLim = plot_set.YLim;
    
else
    
    % Extract data regardless whether error bars exist or not
    if isfield (plot_set, 'ebars_lower_y') && isfield (plot_set, 'ebars_upper_y')
        t0 = plot_set.ebars_lower_y;
        t1 = plot_set.ebars_upper_y;
    elseif isfield (plot_set, 'ebars_lower') && isfield (plot_set, 'ebars_upper')
        t0 = plot_set.ebars_lower;
        t1 = plot_set.ebars_upper;
    elseif isfield (plot_set, 'mat_y')
        t0 = plot_set.mat_y;
        t1 = plot_set.mat_y;
    else
        t0 = -5;
        t1 = 5;
    end
    
    % Calculate min and max
    ps_h0_min = []; ps_h0_max = [];
    for i1 = 1:size(t0, 3)
        ps_h0_min(i1) = min(t0(:,:,i1));
        ps_h0_max(i1) = max(t1(:,:,i1));
    end
    
    % Setup axis limits
    if isfield (plot_set, 'legend')
        val1 = 0.51; val2 = 0.21;
    else
        val1 = 0.21; val2 = 0.21;
    end
    ps_h0_max = max(ps_h0_max); ps_h0_min = min(ps_h0_min);
    ps_h_max = ps_h0_max + ((ps_h0_max - ps_h0_min) * val1);
    ps_h_min = ps_h0_min - ((ps_h0_max - ps_h0_min) * val2);
    
    % Set axis limits
    if ~isnan(ps_h_min) && ~isnan(ps_h_max)
        hfig.YLim = [ps_h_min, ps_h_max];
        fprintf('No values for YLim provided, using defaults\n')
    else
        hfig.YLim = [-5, 5];
        fprintf('No Y data detected, setting axis to minimal\n')
    end
    
    clear ps_h0_min; clear ps_h0_max; clear ps_h_min; clear ps_h_max;
    
end

%%  X Lim

if isfield (plot_set, 'XLim')
    
    hfig.XLim = plot_set.XLim;
    
else
    if isfield (plot_set, 'mat_x')
        
        % Initialize values
        temp1 = plot_set.mat_x;
        o = size(temp1, 3);
        ps_h0_min = NaN(1, o); ps_h_min = NaN;
        ps_h0_max = NaN(1, o); ps_h_max = NaN;
        
        % Extract min and max values
        for i1 = 1:size(temp1, 3)
            if size(temp1,1)>1
                b = nanmean(temp1(:,:,i1));
            else
                b = temp1(:,:,i1);
            end
            ps_h0_min(i1) = min(b);
            ps_h0_max(i1) = max(b);
        end
        
        % Setup axis limits
        val1 = 0.06;
        val2 = 0.06;
        ps_h0_max = max(ps_h0_max); ps_h0_min = min(ps_h0_min);
        ps_h_max = ps_h0_max + ((ps_h0_max - ps_h0_min) * val1);
        ps_h_min = ps_h0_min - ((ps_h0_max - ps_h0_min) * val2);
        
        % Set axis limits
        if ~isnan(ps_h_min) && ~isnan(ps_h_max)
            hfig.XLim = [ps_h_min, ps_h_max];
            fprintf('No values for XLim provided, using defaults\n')
        else
            hfig.XLim = [-5, 5];
            fprintf('No X data detected, setting axis to minimal\n')
        end
        
        clear ps_h0_min; clear ps_h0_max; clear ps_h_min; clear ps_h_max; clear temp1
        
    else
        fprintf('No values for XLim provided, using defaults\n')
        hfig.XLim = [-5, 5];
    end
    
end

%% Other

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
    title (plot_set.figure_title, 'FontSize', settings.fontszlabel)
end
