close all;

error_code_current = 'correct';
texture_on_current = 1;


%%  Calculate axis limits

%==============
% Data
data_mat = struct;
data_mat.mat1_ini = mat1_ini;
data_mat.var1{1} = S.memory_angle;
data_mat.var1_match{1} = memory_angles_used;
data_mat.var1{2} = S.esetup_block_cond;
data_mat.var1_match{2} = task_names_used;
data_mat.var1{3} = S.esetup_background_texture_line_angle(:,1);
data_mat.var1_match{3} = orientations_used;
data_mat.var1{4} = S.esetup_background_texture_on(:,1);
data_mat.var1_match{4} = texture_on_current;
data_mat.var1{5} = S.edata_error_code;
data_mat.var1_match{5} = error_code_current;
settings.bootstrap_on = 0;

[~, mat_y_upper, mat_y_lower, ~] = look6_helper_indexed_selection(data_mat, settings);

%===============
% Y limits
% Reshape matrixes to know numbers of trials
[m,n,o,q,r,s] = size(mat_y_upper);
a = reshape(mat_y_lower, m, n, o*q*r*s);
b = reshape(mat_y_upper, m, n, o*q*r*s);

% Initialize structure with data
plot_set = struct;
plot_set.ebars_lower_y = a;
plot_set.ebars_upper_y = b;
look6_helper_data_limits;

% Add buffer on the axis
val1_min = 0.05;
val1_max = 0.05;
h0_min = plot_set.ylim(1);
h0_max = plot_set.ylim(2);
plot_set.ylim(1) = h0_min - ((h0_max - h0_min) * val1_min);
plot_set.ylim(2) = h0_max + ((h0_max - h0_min) * val1_max);

% Save output
all_fig_y_lim = plot_set.ylim;

%================
% Figure size

fig_subplot_dim = [numel(task_names_used), numel(memory_angles_used)];
fig_size = [0, 0, fig_subplot_dim(2) * settings.figsize_1col(4), fig_subplot_dim(1) * settings.figsize_1col(3)];


%% Work on each panel

for i_fig1 = 1:numel(task_names_used)
    
    task_name_current = task_names_used{i_fig1};
    fprintf('\n%s: preparing panel for the "%s" task \n', settings.neuron_name, task_name_current)
    
    extended_title = 0;
    
    for i_fig2 = 1:numel(memory_angles_used)
        
        memory_angle_current = memory_angles_used(i_fig2);
        
        %==============
        % Data
        data_mat = struct;
        data_mat.mat1_ini = mat1_ini;
        data_mat.var1{1} = S.esetup_background_texture_line_angle(:,1);
        data_mat.var1_match{1} = orientations_used;
        data_mat.var1{2} = S.esetup_block_cond;
        data_mat.var1_match{2} = task_name_current;
        data_mat.var1{3} = S.memory_angle;
        data_mat.var1_match{3} = memory_angle_current;
        data_mat.var1{4} = S.esetup_background_texture_on(:,1);
        data_mat.var1_match{4} = texture_on_current;
        data_mat.var1{5} = S.edata_error_code;
        data_mat.var1_match{5} = error_code_current;
        settings.bootstrap_on = 0;
        
        [mat_y, mat_y_upper, mat_y_lower, ~] = look6_helper_indexed_selection(data_mat, settings);
        
        %================
        % Is there any data to plot?
        fig_plot_on = sum(sum(isnan(mat_y))) ~= numel(mat_y);
        
        if fig_plot_on == 1 % Decide whether to bother initializing a panel
            
            % Initialize figure sub-panel
            a = i_fig1 * (fig_subplot_dim(2)) - (fig_subplot_dim(2));
            b = a + i_fig2;
            hfig = subplot(fig_subplot_dim(1), fig_subplot_dim(2), b);
            hold on;
            fprintf('\n%s: preparing panel for memory location "%s", "%s" task \n', settings.neuron_name, num2str(memory_angle_current), task_name_current);
            
            plot_set = struct;
            
            %===============
            % Averages data
            % Initialize structure with data
            plot_set.mat_y = mat_y;
            plot_set.mat_x = settings.plot_bins;
            plot_set.ebars_lower_y = mat_y_lower;
            plot_set.ebars_upper_y = mat_y_upper;
            plot_set.ebars_shade = 1;
            
            plot_set.ylim = all_fig_y_lim;
            
            % Colors
            plot_set.data_color_min = [23];
            plot_set.data_color_max = [21];
            
            % Labels for plotting
            if extended_title == 0
                plot_set.xlabel = 'Time after cue, ms';
                plot_set.ylabel = 'Firing rate, Hz';
            end
            
            % Figure title
            if extended_title==0
                plot_set.figure_title = sprintf('%s, loc %s', task_name_current, num2str(memory_angle_current));
                extended_title = 1;
            else
                plot_set.figure_title = sprintf('Location %s deg', num2str(memory_angle_current));
            end
            
            % Plot
            plot_helper_line_plot_v10;
            
        end
        % End of decision whether to plot data
    end
    % End of each location
    
end
% End of each condition (look etc)


%===============
% Plot inset with probe locations

if ~isnan(all_fig_y_lim(1)) && ~isnan(all_fig_y_lim(2))
    
    axes('Position',[0.03,0.92,0.04,0.04])
    
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


%==========
% Save data
%==========

if ~isnan(all_fig_y_lim(1)) && ~isnan(all_fig_y_lim(2))
    
    plot_set.figure_size = fig_size;
    plot_set.figure_save_name = sprintf ('%s_fig%s', settings.neuron_name, num2str(settings.figure_current));
    plot_set.path_figure = path_fig;
    
    plot_helper_save_figure;
    close all;
    
end