
error_code_current = 'correct';


%% Plot the data

%==============
% Data
data_mat = struct;
data_mat.mat1_ini = data1.mat1_ini;
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
    
    % Initialize figure sub-panel
    current_subplot = current_subplot + 1;
    hfig = subplot(fig_subplot_dim(1), fig_subplot_dim(2), current_subplot);
    hold on;
    
    plot_set = struct;
    
    % Initialize structure with data
    plot_set.mat_y = mat_y;
    plot_set.mat_x = data1.mat1_plot_bins;
    plot_set.ebars_lower = mat_y_lower;
    plot_set.ebars_upper = mat_y_upper;
    plot_set.ebars_shade = 1;
    plot_set.plot_remove_nan = 1;
    
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
    plot_helper_line_plot_v10;
    
end


