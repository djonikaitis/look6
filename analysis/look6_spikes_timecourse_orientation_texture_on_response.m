
close all;

error_code_current = 'correct';


%% Plot the data

%==============
% Data
data_mat = struct;
data_mat.mat1_ini = mat1_ini;
data_mat.var1{1} = S.esetup_background_texture_on(:,1);
data_mat.var1_match{1} = texture_on_used;
data_mat.var1{2} = S.edata_error_code;
data_mat.var1_match{2} = error_code_current;
settings.bootstrap_on = 0;

[mat_y, mat_y_upper, mat_y_lower, ~] = look6_helper_indexed_selection(data_mat, settings);

%================
% Is there any data to plot?
fig_plot_on = sum(sum(isnan(mat_y))) ~= numel(mat_y);

if fig_plot_on==1
    
    plot_set = struct;
    
    % Initialize structure with data
    plot_set.mat_y = mat_y;
    plot_set.mat_x = settings.plot_bins;
    plot_set.ebars_lower = mat_y_lower;
    plot_set.ebars_upper = mat_y_upper;
    plot_set.ebars_shade = 1;
    
    % Colors
    plot_set.data_color = [23, 21];
    
    % Legend
    plot_set.legend{1} = 'Texture';
    plot_set.legend{2} = 'No texture';
    
    % Labels for plotting
    plot_set.xtick = [-150, 0, 250, 500];
    plot_set.figure_title = 'Responses to texture';
    plot_set.xlabel = 'Time after texture, ms';
    plot_set.ylabel = 'Firing rate, Hz';
    
    % Plot
    hfig = figure;
    hold on;
    plot_helper_line_plot_v10;
    
    % Save data
    plot_set.figure_size = settings.figsize_1col;
    plot_set.figure_save_name = sprintf ('%s_fig%s', settings.neuron_name, num2str(settings.figure_current));
    plot_set.path_figure = path_fig;
    
    plot_helper_save_figure;
    close all;
end
