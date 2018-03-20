close all;

task_names_used = unique(S.esetup_block_cond);
orientations_used = unique(S.esetup_background_texture_line_angle(:,1));
texture_on_used = [1, 0];
memory_angles_used = unique(S.memory_angle);


%%  Calculate axis limits

% Matrices
i = numel(memory_angles_used);
j = numel(task_names_used);
k = numel(orientations_used);
mat_y = NaN(1, numel(settings.plot_bins), i, j, k);
test1 = NaN(1, i, j, k);
mat_y_lower = NaN(1,numel(settings.plot_bins), i, j, k);
mat_y_upper =  NaN(1,numel(settings.plot_bins), i, j, k);

for i = 1:numel(memory_angles_used)
    for j = 1:numel(task_names_used)
        for k = 1:numel(orientations_used)
            
            memory_angle_current = memory_angles_used(i);
            task_name_current = task_names_used(j);
            orientation_current = orientations_used(k);
            
            % Get index
           index = S.esetup_background_texture_line_angle(:,1) == orientation_current & ...
                S.esetup_background_texture_on(:,1) == 1 & ...
                S.memory_angle == memory_angle_current & ...
                strcmp(S.esetup_block_cond, task_name_current) & ...
                strncmp(S.edata_error_code, 'correct', 7);
            temp1 = mat1_ini(index,:);
            test1(1,i,j,k) = sum(index);
            
            % Get means
            a = [];
            if sum(index)>1
                a = nanmean(temp1);
            elseif sum(index) == 1
                a = temp1;
            end
            [n] = numel(a);
            mat_y(1,1:n,i,j,k) = a;
            
            % Get error bars
            settings.bootstrap_on = 0;
            a = plot_helper_error_bar_calculation_v10(temp1, settings);
            try
                mat_y_upper(1,:,i,j,k)= a.se_upper;
                mat_y_lower(1,:,i,j,k)= a.se_lower;
            end
            settings = rmfield (settings, 'bootstrap_on');
            
        end
    end
end

% Reshape matrixes to know numbers of trials
[m,n,o,q,r,s] = size(mat_y_upper);
a = reshape(mat_y_lower, m, n, o*q*r*s);
b = reshape(mat_y_upper, m, n, o*q*r*s);

[m,n,o,q,r,s] = size(test1);
test1_copy = test1;
test1 = reshape(test1, m, n*o*q*r*s);

% Initialize structure with data
plot_set = struct;
plot_set.ebars_lower_y = a;
plot_set.ebars_upper_y = b;
look6_helper_data_limits;

% Count the rasters
val1_min = 0.05;
val1_max = 0.05;
h0_min = plot_set.ylim(1);
h0_max = plot_set.ylim(2);
plot_set.ylim(1) = h0_min - ((h0_max - h0_min) * val1_min);
plot_set.ylim(2) = h0_max + ((h0_max - h0_min) * val1_max);

all_fig_y_lim = plot_set.ylim;

% Figure size
fig_subplot_dim = [numel(task_names_used), numel(memory_angles_used)];
fig_size = [0, 0, fig_subplot_dim(2)*2.2, fig_subplot_dim(1)*2.2];


%% Work on each panel

for i_fig1 = 1:numel(task_names_used)
    
    task_name_current = task_names_used{i_fig1};
    fprintf('\nPreparing panels for the "%s" task \n', task_name_current)
    
    extended_title = 0;
    
    for i_fig2 = 1:numel(memory_angles_used)
        
        memory_angle_current = memory_angles_used(i_fig2);
        
        %==============
        % Plot each subplot
        
        % Data
        var1 = orientations_used;
        mat_y = NaN(1, numel(settings.plot_bins), numel(var1));
        test2 = NaN(1, numel(var1));
        mat_y_lower = NaN(1,numel(settings.plot_bins), numel(var1));
        mat_y_upper =  NaN(1,numel(settings.plot_bins), numel(var1));
        
        
        for i = 1:numel(orientations_used)
            
            orientation_current = orientations_used(i);
            
            % Get index
            index = S.esetup_background_texture_line_angle(:,1) == orientation_current & ...
                S.esetup_background_texture_on(:,1) == 1 & ...
                S.memory_angle == memory_angle_current & ...
                strcmp(S.esetup_block_cond, task_name_current) & ...
                strncmp(S.edata_error_code, 'correct', 7);
            temp1 = mat1_ini(index,:);
            test2(1,i) = sum(index);
            
            % Get means
            a = [];
            if sum(index)>1
                a = nanmean(temp1);
            elseif sum(index) == 1
                a = temp1;
            end
            [n] = numel(a);
            mat_y(1,1:n,i) = a;
            
            
            % Get error bars
            settings.bootstrap_on = 0;
            a = plot_helper_error_bar_calculation_v10(temp1, settings);
            try
                mat_y_upper(1,:,i)= a.se_upper;
                mat_y_lower(1,:,i)= a.se_lower;
            end
            settings = rmfield (settings, 'bootstrap_on');
            
        end
        
        % Is there any data to plot?
        fig_plot_on = sum(test2);
        
        if fig_plot_on > 0 % Decide whether to bother initializing a panel
            
            % Initialize subplot
            a = i_fig1 * numel(memory_angles_used) - numel(memory_angles_used);
            b = a + i_fig2;
            hfig = subplot(fig_subplot_dim(1), fig_subplot_dim(2), b);
            hold on;
            fprintf('\nPreparing panel for memory location "%s" \n', num2str(memory_angle_current))
            
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
            plot_helper_basic_line_figure;
            
            %===============
            % Plot inset with probe locations
            
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
            text(0, -0.5, 'Texture tilt', 'Color', [0.2, 0.2, 0.2],  'FontSize', settings.fontszlabel, 'HorizontalAlignment', 'center')
            
            
        end
        % End of decision whether to plot data
        
    end
    % End of each location
    
end
% End of each condition (look etc)

%==========
% Save data
%==========

if fig_plot_on>0
    
    plot_set.figure_size = fig_size;
    plot_set.figure_save_name = sprintf ('%s_fig%s', settings.neuron_name, num2str(settings.figure_current));
    plot_set.path_figure = path_fig;
    
    plot_helper_save_figure;
    close all;
    
end