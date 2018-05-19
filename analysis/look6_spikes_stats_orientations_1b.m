%% Subplot 1

error_code_current = 'correct';


for i_fig1 = 1:3
    
    %==============
    % Data
    data_mat = struct;
    data_mat.var1_match{1} = orientations_used;
    data_mat.var1{2} = S.esetup_background_texture_on(:,1);
    data_mat.var1_match{2} = texture_on_current;
    data_mat.var1{3} = S.edata_error_code;
    data_mat.var1_match{3} = error_code_current;
    settings.bootstrap_on = 0;
    
    if i_fig1==1
        data_mat.mat1_ini = data1.mat1_ini;
        plot_bins = data1.mat1_plot_bins;
        data_mat.var1{1} = S.esetup_background_texture_line_angle(:,1);
    elseif i_fig1==2
        data_mat.mat1_ini = data1.mat2_ini;
        plot_bins = data1.mat2_plot_bins;
        data_mat.var1{1} = S.esetup_background_texture_line_angle(:,1);
    elseif i_fig1==3
        data_mat.mat1_ini = data1.mat3_ini;
        plot_bins = data1.mat3_plot_bins;
        data_mat.var1{1} = S.esetup_background_texture_line_angle(:,2);
    end
    
    [mat_y, mat_y_upper, mat_y_lower, ~] = look6_helper_indexed_selection(data_mat, settings);

    %================
    % Is there any data to plot?
    fig_plot_on = sum(sum(isnan(mat_y))) ~= numel(mat_y);
        
    if fig_plot_on==1
        
        % Initialize figure sub-panel
        current_subplot = current_subplot + 1;
        hfig = subplot(fig_subplot_dim(1), fig_subplot_dim(2), current_subplot);
        hold on;
        
        plot_set = struct;
        
        % Initialize structure with data
        plot_set.mat_y = mat_y;
        plot_set.mat_x = plot_bins;
        plot_set.ebars_lower_y = mat_y_lower;
        plot_set.ebars_upper_y = mat_y_upper;
        plot_set.ebars_shade = 1;
        
        % Colors
        plot_set.data_color_min = [23];
        plot_set.data_color_max = [21];
        
        % Labels for plotting
        if i_fig1==1
            plot_set.xlabel = 'Time after texture 1, ms';
        elseif i_fig1==2
            plot_set.xlabel = 'Time after cue, ms';
        elseif i_fig1==3
            plot_set.xlabel = 'Time after texture 2, ms';
        end
        plot_set.ylabel = 'Firing rate, Hz';
        
        % Plot
        plot_helper_line_plot_v10;
        
        %===============
        % Plot inset with legend
        
        if i_fig1==1
        axes('Position',[0.01,0.85,0.12,0.12])
        
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
        % End of inset
        
    end
end

% ==========
% Save data
% ==========

if fig_plot_on == 1
    
    plot_set.figure_size = fig_size;
    plot_set.figure_save_name = sprintf ('%s_fig%s', settings.neuron_name, num2str(settings.figure_current));
    plot_set.path_figure = path_fig;
    
    plot_helper_save_figure;
    close all;
    
end