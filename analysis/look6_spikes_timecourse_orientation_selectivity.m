
close all;

error_code_current = 'correct';
task_names_used_current = cell(1);
task_names_used_current{1} = 'look';
task_names_used_current{2} = 'avoid';

texture_on_current = 1;

i_fig1 = 0;
fig_subplot_dim = [1,numel(task_names_used) + 1];
fig_size = [0, 0, fig_subplot_dim(2) * settings.figsize_1col(3), fig_subplot_dim(1) * settings.figsize_1col(4)];

%% Subplot 1

for rep1 = 1:numel(task_names_used)
    
    i_fig1 = i_fig1+1;
    
    % ==============
    % Data
    data_mat = struct;
    data_mat.mat1_ini = mat1_ini;
    data_mat.var1{1} = S.esetup_background_texture_line_angle(:,1);
    data_mat.var1_match{1} = orientations_used;
    data_mat.var1{2} = S.esetup_block_cond(:,1);
    data_mat.var1_match{2} = task_names_used(rep1);
    data_mat.var1{3} = S.esetup_background_texture_on(:,1);
    data_mat.var1_match{3} = texture_on_current;
    data_mat.var1{4} = S.edata_error_code;
    data_mat.var1_match{4} = error_code_current;
    settings.bootstrap_on = 0;
    
    [mat_y_ini, mat_y_upper, mat_y_lower, ~] = look6_helper_indexed_selection(data_mat, settings);
    
    %================
    % Is there any data to plot?
    fig_plot_on = sum(sum(isnan(mat_y_ini))) ~= numel(mat_y_ini);
    
    if fig_plot_on==1
        
        hfig = subplot(fig_subplot_dim(1), fig_subplot_dim(2), i_fig1);
        hold on;
        
        plot_set = struct;
        
        % Initialize structure with data
        plot_set.mat_y = mat_y_ini;
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
        plot_set.figure_title = task_names_used{rep1};
        
        % Plot
        plot_helper_line_plot_v10;
        
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
        text(0, -0.5, 'Texture tilt', 'Color', [0.2, 0.2, 0.2],  'FontSize', settings.font_size_label, 'HorizontalAlignment', 'center')
    end
end


%% Subplot 2

% for i_fig1 = 2
%     
%     % ==============
%     % Data
%     data_mat = struct;
%     data_mat.mat1_ini = mat1_ini;
%     data_mat.var1{1} = S.esetup_background_texture_line_angle(:,1);
%     data_mat.var1_match{1} = orientations_used;
%     data_mat.var1{2} = S.esetup_block_cond;
%     data_mat.var1_match{2} = task_names_used;
%     data_mat.var1{3} = S.esetup_background_texture_on(:,1);
%     data_mat.var1_match{3} = texture_on_current;
%     data_mat.var1{4} = S.edata_error_code;
%     data_mat.var1_match{4} = error_code_current;
%     settings.bootstrap_on = 0;
%     
%     [mat_y, mat_y_upper, mat_y_lower, ~] = look6_helper_indexed_selection(data_mat, settings);
%     
%     % Reshape data
%     [m,n,o,p] = size(mat_y_ini);
%     mat_y = NaN(1,numel(orientations_used),;
%     mat_y_lower = NaN(1,numel(orientations_used));
%     mat_y_upper = NaN(1,numel(orientations_used));
%     for j = 1:size(mat_y,2)
%         for i = 1:size(mat_y_ini,3)
%             for k = 1:size(mat_y,4)
%                 
%                 mat_y(1,i) = mat_y_ini(1,j,i);
%                 mat_y_upper(1,i) = mat_y_upper_ini(1,j,i);
%                 mat_y_lower(1,i) = mat_y_lower_ini(1,j,i);
%             end
%         end
%     end
%     
%     % Convert axial data to radial
%     temp1 = orientations_used';
%     or_radians = circ_axial(circ_ang2rad(temp1),2);
%     
%     % Calculate mean angle
%     angle1 = NaN(1,size(mat_y,1));
%     for j = 1:size(mat_y,1)
%         angle1(:,j) = circ_mean(or_radians, mat_y(j,:),2);
%     end
%     angle2 = angle1;
%     
%     % Calculate radius
%     diff_or = diff(or_radians(1:2));
%     radius1 = NaN(1,size(mat_y,1));
%     
%     for j = 1:size(mat_y,1)
%         mw = max(mat_y(j,:));
%         r = circ_r(or_radians, mat_y(j,:), diff_or) * mw;
%         radius1(1,j) = r(1);
%     end
% 
%     %================
%     % Is there any data to plot?
%     fig_plot_on = sum(sum(isnan(mat_y_ini))) ~= numel(mat_y_ini);
%         
%     if fig_plot_on==1
%         
%         hfig = subplot(1, 2, i_fig1);
%         hold on;
%         set (gca, 'Color', [0.5,1,1])
%         axis 'equal'
%         set (gca, 'Visible', 'off')
%         
%         % Repeat first value Y
%         m = size(mat_y,2);
%         for i = 1:size(mat_y,3)
%             mat_y(:,m+1, i) = mat_y(:,1, i);
%             mat_y_lower(:,m+1, i) = mat_y_lower(:,1, i);
%             mat_y_upper(:,m+1, i) = mat_y_upper(:,1, i);
%         end
%         
%         % Repeat first value X
%         mat_x = [];
%         m = numel(or_radians);
%         mat_x(1:m) = or_radians;
%         % Repeat first value
%         m = numel(mat_x);
%         mat_x(m+1) = mat_x(1);
%         
%         %===========
%         % Convert to cartesian coordinates
%         yc = []; yc_lower =[]; yc_upper = [];
%         xc = []; xc_lower =[]; xc_upper = [];
%         xi = [0:1:360];
%         
%         for k = 1:size(mat_y,3)
%             
%             [x1, y1] = pol2cart(mat_x, mat_y(:,:,k));
%             yc(:,:,k) = y1;
%             xc(:,:,k) = x1;
%             
%             [x1, y1] = pol2cart(mat_x, mat_y_lower(:,:,k));
%             yc_lower(:,:,k) = y1;
%             xc_lower(:,:,k) = x1;
%             
%             [x1, y1] = pol2cart(mat_x, mat_y_upper(:,:,k));
%             yc_upper(:,:,k) = y1;
%             xc_upper(:,:,k) = x1;
% 
%         end
%         
%         %============
%         % Calculate figure limits
%         for i = 1:size(mat_y_upper,3)
%             h0_max(1,i) = max(mat_y_upper(:,:,i)); % Use non polar coord for axis limits
%             h0_max(2,i) = max(mat_y_lower(:,:,i)); % Use non-polar coord for axis limits
%         end
%         h_max = max(max(h0_max));
%         h_max_data = h_max;
%         h_max_axis = h_max + h_max*0.2;
%         
%         
%         %==============
%         plot_set = struct;
%         
%         % Initialize structure with data
%         plot_set.mat_y = yc;
%         plot_set.mat_x = xc;
%                 plot_set.ebars_lower_y = yc_lower;
%                 plot_set.ebars_upper_y = yc_upper;
%                 plot_set.ebars_shade = 1;
%         
%         %         % Colors
%         plot_set.data_color = [0.1, 0.1, 0.1];
%         %         plot_set.data_color_max = [21];
%         %
%         %         % Labels for plotting
%         %         plot_set.xlabel = 'Time after texture, ms';
%         %         plot_set.ylabel = 'Firing rate, Hz';
%         %         plot_set.title = 'Spiking rates for all tasks';
%         
%         % Labels for plotting
%         plot_set.ylim = [-h_max_axis, h_max_axis];
%         plot_set.xlim = [-h_max_axis, h_max_axis];
%         
% 
%         
%       
%         %===============
%         % Plot circles
% 
%         %============
%         % Plot the axis properties
%         %============
%         
%         % Axis properties
%         minaxis1 = 0; % Limits latencies plotted
%         maxaxis1 = h_max_data; % Limits latencies plotted
%         if maxaxis1 < 50
%             step1 = 10;
%         elseif maxaxis1<100
%             step1 = 20;
%         elseif maxaxis1<250
%             step1 = 50;
%         else
%             step1 = 100;
%         end
%         plot_angle = 90; % Angle at which tick marks are drawn
%         
%         % Reset to figure to the limits chosen
%         tickrange1 = maxaxis1 - minaxis1;
%         tick_small = [0:step1:maxaxis1]; % Step for small tick
%         tick_small_temp = tick_small-minaxis1;
%         tick_small_temp(tick_small_temp<=0) = [];
%         
%         % Fill in the largest circle
%         ticks1=[tickrange1];
%         cpos1 = [0,0];
%         cl1=[0.9,0.9, 0.9];
%         h=rectangle('Position', [cpos1(1,1)-ticks1, cpos1(1,2)-ticks1, ticks1*2, ticks1*2],...
%             'EdgeColor', cl1, 'FaceColor', [1,1,1], 'Curvature', 1, 'LineWidth', 0.7, 'LineStyle', '-');
%         
%         % Draw vertical and horizontal lines
%         cl1 = [0.9,0.9,0.9];
%         h = plot([-tickrange1, tickrange1], [0,0]);
%         set (h(end), 'LineWidth', 0.7, 'Color', cl1)
%         h = plot([0,0], [-tickrange1, tickrange1]);
%         set (h(end), 'LineWidth', 0.7, 'Color', cl1)
%         
%         % Plot small cirlces
%         cpos1 = [0,0];
%         ticks1=[tick_small_temp];
%         cl1=[0.9,0.9,0.9];
%         for i=1:length(ticks1)
%             h=rectangle('Position', [cpos1(1,1)-ticks1(i), cpos1(1,2)-ticks1(i), ticks1(i)*2, ticks1(i)*2],...
%                 'EdgeColor', cl1, 'FaceColor', 'none', 'Curvature', 1, 'LineWidth', 0.7, 'LineStyle', '-');
%         end
%         
%         % Add tick marks
%         ticks1 = [tick_small_temp];
%         ticks1labels=[tick_small_temp+minaxis1]; % Plots real values
%         for i=1:length(ticks1)
%             [x,y] = pol2cart(plot_angle*pi/180,ticks1(i));
%             if ticks1labels(i)~=max(ticks1labels)
%                 text(x,y, num2str(ticks1labels(i)), 'FontSize', settings.font_size_figure, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
%             else
%                 text(x,y, ['spikes, Hz '], 'FontSize', settings.font_size_figure, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
%             end
%         end
%         
%         % Plot data
%         plot_helper_line_plot_v10;
%         
%         % Plot mean calculated angle
%         [x1, y1] = pol2cart(angle2, radius1);
%         plot([0, x1], [0, y1], 'r')
% 
%         
%     end
% end

%% Plot data fits

i_fig1 = i_fig1+1;
hfig = subplot(fig_subplot_dim(1), fig_subplot_dim(2), i_fig1);
hold on;

% ==============
% Data
data_mat = struct;
data_mat.mat1_ini = mat2_ini;
data_mat.var1{1} = S.esetup_background_texture_line_angle(:,1);
data_mat.var1_match{1} = orientations_used;
data_mat.var1{2} = S.esetup_block_cond;
data_mat.var1_match{2} = task_names_used;
data_mat.var1{3} = S.esetup_background_texture_on(:,1);
data_mat.var1_match{3} = texture_on_current;
data_mat.var1{4} = S.edata_error_code;
data_mat.var1_match{4} = error_code_current;
settings.bootstrap_on = 0;

[mat_y_ini, mat_y_upper_ini, mat_y_lower_ini, ~] = look6_helper_indexed_selection(data_mat, settings);

% Convert axial data to radial
t1 = orientations_used';
or_radians = circ_axial(circ_ang2rad(t1),2);

% Recalculate into mean angle for each condition and time bin
[m,n,o,p] = size(mat_y_ini);
mat_y = NaN(1,n,p);
mat_y_lower = NaN(1,n,p);
mat_y_upper = NaN(1,n,p);

% % Calculate mean angle
% for i = 1:size(mat_y_ini,2)
%     for j = 1:size(mat_y_ini,4)
%        v1 = mat_y_ini(:,i,:,j);
%        v1 = reshape(v1,1,numel(v1));
%        mat_y(1,i,j) = circ_mean(or_radians, v1, 2);
%        dori = diff(or_radians(1:2));
%        a = circ_std(or_radians, v1, dori, 2);
%        mat_y_lower(1,i,j) = mat_y(1,i,j) - a;
%        mat_y_upper(1,i,j) = mat_y(1,i,j) + a;
%     end
% end


t1 = orientations_used';
or_radians = circ_axial(circ_ang2rad(t1),2);
temp1 = round(mat_y_ini);

% Output
temp1_output = cell(1, size(temp1,2), size(temp1,4));

for i = 1:size(temp1, 2)
    for j = 1:size(temp1, 4)
        
        % Data
        v1 = temp1(:,i,:,j);
        ydata = reshape(v1,1,numel(v1));
        xdata = or_radians;
        
        % Initialize params
        params = [0, 2, 200, 100];
        options.MaxFunctionEvaluations = 5000;
        options.MaxIterations = 5000;
        
        % Steinmetz & Moore, 2014
        if sum(isnan(ydata))<numel(ydata)
            fun = @(params,xdata) params(3) + params(4) * exp(params(2)*cos(xdata-params(1)))/(2*pi*besseli(0,params(2)));
            [x, fval] = lsqcurvefit(fun, params, xdata, ydata, [-pi, 0, 0, 0], [pi, 6, inf, inf], options);
            temp1_output{1,i,j} = x;
        end
        
    end
end
    
% Prepare data matrices
bin_number = 1;

% Recalculate into mean angle for each condition and time bin


temp1 = round(mat_y_ini);
mat_x = or_radians;
mat_x_line = linspace(mat_x(1),mat_x(end));

m1 = numel(mat_x_line);
[m,n,o,p] = size(mat_y_ini);
mat_y = NaN(1,o,p);
mat_y_lower = NaN(1,o,p);
mat_y_upper = NaN(1,o,p);
mat_y_line = NaN(1, m1, p);

for j = 1:size(temp1_output,3)
    
    % Data
    i = bin_number;
    v1 = temp1(:,i,:,j);
    mat_y(:,:,j) = reshape(v1,1,numel(v1));

    % Fits
    x = temp1_output{1,i,j};
    mat_y_line(:,:,j) = fun(x, mat_x_line);
    
end

%================
% Is there any data to plot?
fig_plot_on = sum(sum(isnan(mat_y))) ~= numel(mat_y);

if fig_plot_on==1
    
    
    plot_set = struct;
    
    % Initialize structure with data
    plot_set.mat_y = mat_y;
    plot_set.mat_x = mat_x;
    plot_set.marker_shape{1} = 'o';
    plot_set.marker_shape{2} = 's';
    plot_set.marker_only = 1;
% %     plot_set.ebars_lower_y = mat_y_lower;
% %     plot_set.ebars_upper_y = mat_y_upper;
% %     plot_set.ebars_shade = 1;
    
    % Colors
    c1 = NaN(numel(task_names_used), 1);
    ind = strcmp(task_names_used, 'look');
    if (sum(ind))==1
        c1(ind) = 1;
    end
    ind = strcmp(task_names_used, 'avoid');
    if (sum(ind))==1
        c1(ind) = 2;
    end
    ind = strcmp(task_names_used, 'control fixate');
    if (sum(ind))==1
        c1(ind) = 4;
    end
    plot_set.data_color = c1;
    
    % Plot
    plot_helper_line_plot_v10;
    

end

%================
% Is there any data to plot?
fig_plot_on = sum(sum(isnan(mat_y_line))) ~= numel(mat_y_line);

if fig_plot_on==1
        
    plot_set = struct;
    
    % Initialize structure with data
    plot_set.mat_y = mat_y_line;
    plot_set.mat_x = mat_x_line;
% %     plot_set.ebars_lower_y = mat_y_lower;
% %     plot_set.ebars_upper_y = mat_y_upper;
% %     plot_set.ebars_shade = 1;
    
    % Colors
    c1 = NaN(numel(task_names_used), 1);
    ind = strcmp(task_names_used, 'look');
    if (sum(ind))==1
        c1(ind) = 1;
    end
    ind = strcmp(task_names_used, 'avoid');
    if (sum(ind))==1
        c1(ind) = 2;
    end
    ind = strcmp(task_names_used, 'control fixate');
    if (sum(ind))==1
        c1(ind) = 4;
    end
    plot_set.data_color = c1;
    
    % Labels for plotting
    plot_set.legend = task_names_used;
    plot_set.xlabel = 'Orientation (radians * 2)';
    plot_set.ylabel = 'Spikes/s';
    plot_set.figure_title = 'Texture by task';
    
    % Plot
    plot_helper_line_plot_v10;
    

end





% i_fig1 = i_fig1+1;
% 
% 
% if fig_plot_on==1
%     
%     hfig = subplot(fig_subplot_dim(1), fig_subplot_dim(2), i_fig1);
%     hold on;
%     
%     plot_set = struct;
%     
%     % Initialize structure with data
%     plot_set.mat_y = (temp1_vm_kappa/2);
%     plot_set.mat_x = settings.plot_bins;
% %     plot_set.ebars_lower_y = mat_y_lower;
% %     plot_set.ebars_upper_y = mat_y_upper;
% %     plot_set.ebars_shade = 1;
%     
%     % Colors
%     c1 = NaN(numel(task_names_used), 1);
%     ind = strcmp(task_names_used, 'look');
%     if (sum(ind))==1
%         c1(ind) = 1;
%     end
%     ind = strcmp(task_names_used, 'avoid');
%     if (sum(ind))==1
%         c1(ind) = 2;
%     end
%     ind = strcmp(task_names_used, 'control fixate');
%     if (sum(ind))==1
%         c1(ind) = 4;
%     end
%     plot_set.data_color = c1;
%     
%     % Labels for plotting
%     plot_set.xlabel = 'Time after texture, ms';
%     plot_set.ylabel = 'Mean texture angle';
%     plot_set.figure_title = 'Responses to texture';
%     
%     % Plot
%     plot_helper_line_plot_v10;
%     
% 
% end

%% Plot von-misses fit

% if fig_plot_on==1
%     
%     hfig = subplot(fig_subplot_dim(1), fig_subplot_dim(2), i_fig1);
%     hold on;
%     
%     plot_set = struct;
%     
%     
%     % Initialize structure with data
%     plot_set.mat_y = (temp1_vm_mu);
%     plot_set.mat_x = settings.plot_bins;
% %     plot_set.ebars_lower_y = mat_y_lower;
% %     plot_set.ebars_upper_y = mat_y_upper;
% %     plot_set.ebars_shade = 1;
%     
%     % Colors
%     c1 = NaN(numel(task_names_used), 1);
%     ind = strcmp(task_names_used, 'look');
%     if (sum(ind))==1
%         c1(ind) = 1;
%     end
%     ind = strcmp(task_names_used, 'avoid');
%     if (sum(ind))==1
%         c1(ind) = 2;
%     end
%     ind = strcmp(task_names_used, 'control fixate');
%     if (sum(ind))==1
%         c1(ind) = 4;
%     end
%     plot_set.data_color = c1;
%     
%     % Labels for plotting
%     plot_set.xlabel = 'Time after texture, ms';
%     plot_set.ylabel = 'Mean texture angle';
%     plot_set.figure_title = 'Responses to texture';
%     
%     % Plot
%     plot_helper_line_plot_v10;
%     
% 
% end




%% Plot orientation selectivity statistic

% i_fig1 = i_fig1+1;
% 
% mat_y = NaN(1, size(mat1_ini,2), numel(task_names_used));
% 
% for j = 1:numel(task_names_used)
%     
%     % Get index
%     index = S.esetup_background_texture_on(:,1) == texture_on_current & ...
%         strncmp(S.edata_error_code, error_code_current, 7) &...
%         strcmp(S.esetup_block_cond, task_names_used{j});
%     
%     y = S.esetup_background_texture_line_angle(index,2);
%     
%     for i = 1:size(mat1_ini, 2)
%         meas1 = mat1_ini(index,i);
%         [p, tbl] = kruskalwallis(meas1,y, 'off');
% %         [p,tbl] = anova1(meas1, y, 'off');
%         mat_y(1,i,j) = p;
%     end
% end
% 
% hfig = subplot(fig_subplot_dim(1), fig_subplot_dim(2), i_fig1);
% hold on;
% 
% plot_set = struct;
% 
% % Initialize structure with data
% plot_set.mat_y = mat_y;
% plot_set.mat_x = settings.plot_bins;
% 
% % Colors
% c1 = NaN(numel(task_names_used), 1);
% ind = strcmp(task_names_used, 'look');
% if (sum(ind))==1
%     c1(ind) = 1;
% end
% ind = strcmp(task_names_used, 'avoid');
% if (sum(ind))==1
%     c1(ind) = 2;
% end
% ind = strcmp(task_names_used, 'control fixate');
% if (sum(ind))==1
%     c1(ind) = 4;
% end
% plot_set.data_color = c1;
% 
% % Labels for plotting
% plot_set.xlabel = 'Time after texture, ms';
% plot_set.ylabel = 'ANOVA p val';
% plot_set.legend = task_names_used;
% plot_set.title = 'ANOVA task by task';
% 
% % Plot
% plot_helper_line_plot_v10;
    



%% Plot the data


%==========
% Save data
%==========

if fig_plot_on>0

    plot_set.figure_size = fig_size;
    plot_set.figure_save_name = sprintf ('%s_fig%s', settings.neuron_name, num2str(settings.figure_current));
    plot_set.path_figure = path_fig;
    
    plot_helper_save_figure;
%     close all;
end