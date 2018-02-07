% Plots lines and sets up figure settings 
% Options:
% plot_set.mat1 is data for y axis (else wont plot any data) 
% plot_set.pbins is data for x axis. (else it will plot as a range 1:x
% elements)
% plot_set.ebars_min is lower bound of error bars (else wont plot error bars)
% plot_set.ebars_min is upper bound of error bars (else wont plot error bars)
% plot_set.ebars_shade plots error bars as shaded area
% plot_set.ebars_line plots error bars as lines area
%
% plot_set.data_color is colors for the figure. It either refers to
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


%%  Calculate colors if it is a range
% Else it will read out specified colors

if isfield (plot_set, 'data_color_min') && isfield (plot_set, 'data_color_max') && isfield (plot_set, 'mat_y')
        
    % Settings
    if numel(plot_set.data_color_min)==1 && numel(plot_set.data_color_max)==1
        col_min = settings.color1 (plot_set.data_color_min,:);
        col_max = settings.color1 (plot_set.data_color_max,:);
        n = size(plot_set.mat_y,3);
    elseif numel(plot_set.data_color_min)==3 && numel(plot_set.data_color_max)==3
        col_min = plot_set.data_color_min;
        col_max = plot_set.data_color_max;
        n = size(plot_set.mat_y,3);
    else
        sprintf('data_color_min and data_color_max not specified correctly, using default color scheme')
        col_min = [0.3, 0.3, 0.3];
        col_max = [1, 0.2, 0.2];
        n = size(plot_set.mat_y,3);
    end
    
    % Other location colors are calculated as a range
    if n>1
        d1 = col_max-col_min;
        stepsz = 1/(n-1);
        for i=1:n
            color1_range(i,:)=col_min + (d1*stepsz)*(i-1);
        end
    else
        color1_range(1,:)=col_min;
    end
    
    plot_set.color1_range = color1_range;
    
end


%% Plot error shaded area


if isfield (plot_set, 'ebars_min') && isfield (plot_set, 'ebars_max') && isfield (plot_set, 'ebars_shade')
    
    d1 = plot_set.ebars_min;
    f1 = plot_set.ebars_max;
    mat_x = plot_set.mat_x;
    
    for k=1:size(d1,3)
        
            graphcond=k;
            
            xc1 = mat_x(1); % Min x, min y
            xc2 = mat_x(1); % Min x, max y
            xc3 = mat_x; % Upper bound of errors
            xc4 = mat_x(end); % Max x, max y
            xc5 = mat_x(end); % Max x, min y
            xc6 = mat_x;
            xc6 = fliplr(xc6);
            
            yc1 = d1(:,1,k); % Lower bound of errors
            yc2 = f1(:,1,k); % upper bound of errors
            yc3 = f1(:,:,k); % Upper bound of errors
            yc4 = f1(:,end,k); % Upper bound of errors
            yc5 = d1(:,end,k); % Lower bound of errors
            yc6 = d1(:,:,k); % Lower bound of errors
            yc6 = fliplr(yc6);
            
            % Select color
            if isfield(plot_set, 'color1_range')
                c1_temp0 = plot_set.color1_range(k,:);
                temp0 = 1-c1_temp0;
                c1 = c1_temp0 + temp0.*0.6;
            elseif isfield(plot_set, 'data_color') && ~isempty(plot_set.data_color)
                if sum(plot_set.data_color<=1) == numel(plot_set.data_color)
                    c1 = plot_set.data_color(k,:);
                elseif sum(plot_set.data_color>1) == numel(plot_set.data_color)
                    graphcond = plot_set.data_color(k);
                    c1 = settings.face_color1(graphcond,:);
                end
            else
                error ('Figure colors not specified')
            end
            
            h=fill([xc1,xc2,xc3,xc4, xc5, xc6],[yc1, yc2, yc3, yc4, yc5, yc6], [1 0.7 0.2], 'linestyle', 'none');
            set (h(end), 'FaceColor', c1,'linestyle', 'none', 'FaceAlpha', 1)
            
    end
    
end


%%  Plot lines

if isfield (plot_set, 'mat_y')
    
    mat_y = plot_set.mat_y;
    mat_x = plot_set.mat_x;
    
    for k=1:size(mat_y,3)
        
        % Draw line
        if size(mat_y,1)>1
            h=plot(mat_x, nanmean(mat_y(1,:,k),1));
        elseif size(mat_y,1)==1
            h=plot(mat_x, mat_y(1,:,k));
        end
        
        % Select color
        if isfield(plot_set, 'color1_range')
            c1 = color1_range(k,:);
        elseif isfield(plot_set, 'data_color') && ~isempty(plot_set.data_color)
            graphcond = plot_set.data_color(k);
            c1 = settings.color1(graphcond,:);
        else
            error ('Figure colors not specified')
        end
        
        % Set color and line width
        if isfield (settings, 'wlinegraph')
            set (h(end), 'LineWidth', settings.wlinegraph, 'Color', c1)
        else
            sprintf('Line width not specified in settings.wlinegraph, using default line width')
            set (h(end), 'LineWidth', 1, 'Color', c1)
        end
        
    end
end

%% Legend

% Plot legend text
if isfield (plot_set, 'legend') && isfield (plot_set, 'legend_x_coord') && isfield (plot_set, 'legend_y_coord')
    
    for k=1:numel(plot_set.legend)
        
        legend1 = plot_set.legend{k};
        y1 = plot_set.legend_y_coord(k);
        x1 = plot_set.legend_x_coord(k);
        
        % Select color
        if isfield(plot_set, 'color1_range')
            c1 = color1_range(k,:);
        elseif isfield(plot_set, 'data_color') && ~isempty(plot_set.data_color)
            if sum(plot_set.data_color<=1) == numel(plot_set.data_color)
                c1 = plot_set.data_color(k,:);
            elseif sum(plot_set.data_color>1) == numel(plot_set.data_color)
                graphcond = plot_set.data_color(k);
                c1 = settings.color1(graphcond,:);
            end
        else
            error ('Figure colors not specified')
        end

        % Set font size
        if isfield (settings, 'fontszlabel')
            text(x1, y1, legend1, 'Color', c1,  'FontSize', settings.fontszlabel, 'HorizontalAlignment', 'left')
        else
            sprintf('Font size not specified in settings.fontszlabel, using default fonts')
            text(x1, y1, legend1, 'Color', c1,  'FontSize', 12, 'HorizontalAlignment', 'left')
        end
        
    end
end

hfig = gca;
set (hfig, 'FontSize', settings.fontsz);



%% Y Tick

if isfield (plot_set, 'YTick') && ~isempty(plot_set.YTick) % If y-ticks exist
    
    hfig.YTick = plot_set.YTick;

else % If y-ticks do not exist, calculate your own
    
    % Extract data regardless whether error bars exist or not
    if isfield (plot_set, 'ebars_min') && isfield (plot_set, 'ebars_max')
        t0 = plot_set.ebars_min;
        t1 = plot_set.ebars_max;
    elseif isfield (plot_set, 'mat_y')
        t0 = plot_set.mat_y;
        t1 = plot_set.mat_y;
    else
        sprintf('No values for YTick provided, using defaults')
        t0 = 0;
        t1 = 1;
    end
    
    % Calculate min and max
    for i1 = 1:size(t0, 3)
        ps_h0_min(i1) = min(t0(:,:,i1));
        ps_h0_max(i1) = max(t1(:,:,i1));
    end
    
    % Calculate axis limits
    ps_h0_max = max(ps_h0_max); ps_h0_min = min(ps_h0_min);
    ps_h_max = ps_h0_max + ((ps_h0_max - ps_h0_min) *0.4);
    ps_h_min = ps_h0_min - ((ps_h0_max - ps_h0_min) *0.5);
    
    % Get the data about axis size
    if ps_h_max-ps_h_min <=3
        ps_y_tick = [-2:1:2];
    elseif ps_h_max-ps_h_min <=6
        ps_y_tick = [-5:1:5];
    elseif ps_h_max-ps_h_min <=11
        ps_y_tick = [-10:2:10];
    elseif  ps_h_max-ps_h_min <=25
        ps_y_tick = [0:5:25];
    elseif ps_h_max-ps_h_min <=50
        ps_y_tick = [0:10:50];
    elseif ps_h_max-ps_h_min <=200
        ps_y_tick = [0:50:ps_h_max];
    elseif ps_h_max-ps_h_min >200
        ps_y_tick = [0:100:ps_h_max];
    end
    
    hfig.YTick = ps_y_tick;
    
    % Clean up
    clear ps_y_tick; clear ps_h0_max; clear ps_h0_min; clear ps_h_max; clear ps_h_min; clear t0; clear t1;
    
end
    

%%   X Tick

if isfield (plot_set, 'XTick') && ~isempty(plot_set.XTick)
   
    hfig.XTick = plot_set.XTick;

elseif isfield (plot_set, 'mat_x')
    
    mat_x = plot_set.mat_x;
    if mat_x(end)<=10
        hfig.XTick = [1,5,10];
    elseif mat_x(end)<=20
        hfig.XTick = [1,5:5:mat_x(end)];
    elseif mat_x(end)<=50
        hfig.XTick = [1,10:10:mat_x(end)];
    elseif mat_x(end)<=100
        hfig.XTick = [1,20:20:mat_x(end)];
    elseif mat_x(end)<=250
        hfig.XTick = [1,50:50:mat_x(end)];
    elseif mat_x(end)<=500
        hfig.XTick = [1,100:100:mat_x(end)];
    elseif mat_x(end)<=1000
        hfig.XTick = [1,250:250:mat_x(end)];
    elseif mat_x(end)<=2500
        hfig.XTick = [1,500:500:mat_x(end)];
    elseif mat_x(end)<=5000
        hfig.XTick = [1,1000:1000:mat_x(end)];
    end
    
else
    sprintf('No values for XTick provided, using defaults')
     hfig.XTick = [-1, 0, 1];
end


%% Other

% Y Lim
if isfield (plot_set, 'YLim')
    hfig.YLim = plot_set.YLim;
else
    sprintf('No values for YLim provided, using defaults')
    hfig.YLim = [0, 1];
end

% X Lim
if isfield (plot_set, 'XLim')
    hfig.XLim = plot_set.XLim;
else
    if isfield (plot_set, 'mat_x')
        r1 = abs(plot_set.mat_x(end) - plot_set.mat_x(1));
        a = plot_set.mat_x(1) - r1*0.05;
        b = plot_set.mat_x(end) + r1*0.05;
        hfig.XLim = [a, b];
    else
        sprintf('No values for XLim provided, using defaults')
        hfig.XLim = [-2, 2];
    end
    
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
    title (plot_set.figure_title, 'FontSize', settings.fontszlabel)
end
