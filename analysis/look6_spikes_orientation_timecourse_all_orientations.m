
close all;

task_names_used = unique(S.esetup_block_cond);
orientations_used = unique(S.esetup_background_texture_line_angle(:,1));
texture_on_used = [1, 0];
memory_angles_used = unique(S.memory_angle);
error_code_current = 'correct';

texture_on_current = 1;

%% Subplot 1

for i_fig1 = 1
    
    %==============
    % Data
    data_mat = struct;
    data_mat.mat1_ini = mat1_ini;
    data_mat.var1{1} = S.esetup_background_texture_line_angle(:,1);
    data_mat.var1_match{1} = orientations_used;
    data_mat.var1{2} = S.esetup_background_texture_on(:,1);
    data_mat.var1_match{2} = texture_on_current;
    data_mat.var1{3} = S.edata_error_code;
    data_mat.var1_match{3} = error_code_current;
    settings.bootstrap_on = 0;
    
    [mat_y, mat_y_upper, mat_y_lower, ~] = look6_helper_indexed_selection(data_mat, settings);

    %================
    % Is there any data to plot?
    fig_plot_on = sum(sum(isnan(mat_y))) ~= numel(mat_y);
        
    if fig_plot_on==1
        
        hfig = subplot(1, 2, i_fig1);
        hold on;
        
        plot_set = struct;
        
        % Initialize structure with data
        plot_set.mat_y = mat_y;
        plot_set.mat_x = settings.plot_bins;
        plot_set.ebars_lower_y = mat_y_lower;
        plot_set.ebars_upper_y = mat_y_upper;
        plot_set.ebars_shade = 1;
        
        % Colors
        plot_set.data_color_min = [23];
        plot_set.data_color_max = [21];
        
        % Labels for plotting
        plot_set.xlabel = 'Time after texture, ms';
        plot_set.ylabel = 'Firing rate, Hz';
        
        % Plot
        plot_helper_basic_line_figure;
        
        %===============
        % Plot inset with legend
        
        axes('Position',[0.17,0.85,0.06,0.06])
        
        axis 'equal'
        set (gca, 'Visible', 'off')
        hold on;
        
        % Initialize data values for plotting
        for i=1:length(orientations_used)
            
            % Color
            graphcond = i;
            
            % Find coordinates of a line
            f_rad = 1;
            f_arc = orientations_used(i);
            [xc,yc] = pol2cart(f_arc*pi/180, f_rad);
            
            % Plot cirlce
            h = plot([0, xc(1)], [0, yc(1)], 'Color', plot_set.main_color(i,:), 'LineWidth', 1.8);
            
        end
        
        % Add text
        text(0, -0.5, 'Texture tilt', 'Color', [0.2, 0.2, 0.2],  'FontSize', settings.fontszlabel, 'HorizontalAlignment', 'center')
    end
end

%% Plot the data


for i_fig1 = 2
    
    hfig = subplot(1,2,i_fig1);
    hold on;
    
    %==============
    % Data
    data_mat = struct;
    data_mat.mat1_ini = mat2_ini;
    data_mat.var1{1} = S.esetup_background_texture_line_angle(:,1);
    data_mat.var1_match{1} = orientations_used;
    data_mat.var1{2} = S.esetup_background_texture_on(:,1);
    data_mat.var1_match{2} = texture_on_current;
    data_mat.var1{3} = S.edata_error_code;
    data_mat.var1_match{3} = error_code_current;
    settings.bootstrap_on = 0;
    
    [mat_y, mat_y_upper, mat_y_lower, ~] = look6_helper_indexed_selection(data_mat, settings);
    
    [m,n,o] = size(mat_y);
    mat_y = reshape(mat_y, m, n*o);
    mat_y_lower = reshape(mat_y_lower, m, n*o);
    mat_y_upper = reshape(mat_y_upper, m, n*o);
    
    %=============
    % Duplicate data
    m = size(mat_y,2);
    for i = 1:size(mat_y,3)
        mat_y(:,m+1:m+m, i) = mat_y(:,1:m, i);
        mat_y_lower(:,m+1:m+m, i) = mat_y_lower(:,1:m, i);
        mat_y_upper(:,m+1:m+m, i) = mat_y_upper(:,1:m, i);
    end
    
    % Repeat first value
    m = size(mat_y,2);
    for i = 1:size(mat_y,3)
        mat_y(:,m+1, i) = mat_y(:,1, i);
        mat_y_lower(:,m+1, i) = mat_y_lower(:,1, i);
        mat_y_upper(:,m+1, i) = mat_y_upper(:,1, i);
    end
    
    %================
    % Data X
    
    mat_x = [];
    
    % Duplicate data
    m = numel(orientations_used);
    mat_x(1:m) = orientations_used;
    mat_x(m+1:m+m) = orientations_used+180;
    % Repeat first value
    m = numel(mat_x);
    mat_x(m+1) = mat_x(1)+360;
    
    
    %===========
    % Convert to cartesian coordinates
    yc = []; yc_lower =[]; yc_upper = [];
    xc = []; xc_lower =[]; xc_upper = [];
    xi = [0:1:360];
    
    for k = 1:size(mat_y,3)
        
        yInt = interp1(mat_x, mat_y(:,:,k), xi, 'linear');
        [x1, y1] = pol2cart(xi*pi/180, yInt);
        yc(:,:,k) = y1;
        xc(:,:,k) = x1;
        
        yInt = interp1(mat_x, mat_y_lower(:,:,k), xi, 'linear');
        [x1, y1] = pol2cart(xi*pi/180, yInt);
        yc_lower(:,:,k) = y1;
        xc_lower(:,:,k) = x1;
        
        yInt = interp1(mat_x, mat_y_upper(:,:,k), xi, 'linear');
        [x1, y1] = pol2cart(xi*pi/180, yInt);
        yc_upper(:,:,k) = y1;
        xc_upper(:,:,k) = x1;
        
    end
    
    %================
    % Is there any data to plot?
    fig_plot_on = sum(sum(isnan(mat_y))) ~= numel(mat_y);
    
    if fig_plot_on==1
        
        % Calculate figure limits
        for i = 1:size(yc_upper,3)
            h0_max(1,i) = max(yc_upper(:,:,i));
            h0_max(2,i) = max(xc_upper(:,:,i));
        end
        h_max = max(max(h0_max));
        h_max = h_max + h_max*0.2;
        
        % Initialize structure with data
        plot_set = struct;
        plot_set.mat_y = yc;
        plot_set.mat_x = xc;
        plot_set.ebars_lower_y = yc_lower;
        plot_set.ebars_upper_y = yc_upper;
        plot_set.ebars_lower_x = xc_lower;
        plot_set.ebars_upper_x = xc_upper;
        plot_set.ebars_shade = 1;
        
        % Colors
        plot_set.data_color = [0.1, 0.1, 0.1];
        
        % Labels for plotting
        plot_set.YLim = [-h_max, h_max];
        plot_set.XLim = [-h_max, h_max];
        
        % Initialize the data
        set (gca, 'Color', [1,1,1])
        hold on;
        axis equal
        
        
        %============
        % Plot the axis properties
        %============
        
        % Axis properties
        minaxis1 = 0; % Limits latencies plotted
        maxaxis1 = h_max; % Limits latencies plotted
        if h_max < 50
            step1 = 10;
        elseif h_max<100
            step1 = 20;
        elseif h_max<250
            step1 = 50;
        else
            step1 = 100;
        end
        tick_small = [0:step1:maxaxis1]; % Step for small tick
        tick_large = [0:step1:maxaxis1]; % Step for large tick
        plot_angle = 90; % Angle at which tick marks are drawn
        
        % Reset to figure to the limits chosen
        tickrange1 = maxaxis1 - minaxis1;
        tick_small_temp = tick_small-minaxis1;
        tick_small_temp(tick_small_temp<=0) = [];
        tick_large_temp = tick_large-minaxis1;
        tick_large_temp(tick_large_temp<=0) = [];
        
        % Fill in the largest circle
        if tick_small_temp(end)>=tick_large_temp(end)
            ticks1=[tickrange1];
            cpos1 = [0,0];
            cl1=[0.9,0.9,0.9];
        else
            ticks1=[tickrange1];
            cpos1 = [0,0];
            cl1=[0.7,0.7,0.7];
        end
        h=rectangle('Position', [cpos1(1,1)-ticks1, cpos1(1,2)-ticks1, ticks1*2, ticks1*2],...
            'EdgeColor', cl1, 'FaceColor', [1,1,1], 'Curvature', 1, 'LineWidth', 0.7, 'LineStyle', '-');
        
        % Draw vertical and horizontal lines
        cl1 = [0.9,0.9,0.9];
        h = plot([-tickrange1, tickrange1], [0,0]);
        set (h(end), 'LineWidth', 0.7, 'Color', cl1)
        h = plot([0,0], [-tickrange1, tickrange1]);
        set (h(end), 'LineWidth', 0.7, 'Color', cl1)
        
        % Fill the the central cirlce
        if tick_small_temp(1)<=tick_large_temp(1)
            ticks1=[tick_small_temp(1)];
            cpos1 = [0,0];
            cl1=[0.9,0.9,0.9];
        else
            ticks1=[tick_large_temp(1)];
            cpos1 = [0,0];
            cl1=[0.7,0.7,0.7];
        end
        h=rectangle('Position', [cpos1(1,1)-ticks1, cpos1(1,2)-ticks1, ticks1*2, ticks1*2],...
            'EdgeColor', cl1, 'FaceColor', [1,1,1], 'Curvature', 1, 'LineWidth', 0.7, 'LineStyle', '-');
        
        % Plot small cirlces
        cpos1 = [0,0];
        ticks1=[tick_small_temp];
        cl1=[0.9,0.9,0.9];
        for i=1:length(ticks1)
            h=rectangle('Position', [cpos1(1,1)-ticks1(i), cpos1(1,2)-ticks1(i), ticks1(i)*2, ticks1(i)*2],...
                'EdgeColor', cl1, 'FaceColor', 'none', 'Curvature', 1, 'LineWidth', 0.7, 'LineStyle', '-');
        end
        
        % Add tick marks
        ticks1 = [tick_small_temp];
        ticks1labels=[tick_small_temp+minaxis1]; % Plots real values
        for i=1:length(ticks1)
            [x,y] = pol2cart(plot_angle*pi/180,ticks1(i));
            if ticks1labels(i)~=max(ticks1labels)
                text(x,y, num2str(ticks1labels(i)), 'FontSize', settings.fontsz, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
            else
                text(x,y, ['spikes, Hz '], 'FontSize', settings.fontsz, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
            end
        end
        
        %==========
        % Plot data
        %==========
        
        plot_helper_basic_line_figure;
        
    end
    % End of decision wheter to plot data
    
end

%==========
% Save data
%==========

if fig_plot_on>0

    plot_set.figure_size = settings.figsize_2col;
    plot_set.figure_save_name = sprintf ('%s_fig%s', settings.neuron_name, num2str(settings.figure_current));
    plot_set.path_figure = path_fig;
    
    plot_helper_save_figure;
    close all;
end