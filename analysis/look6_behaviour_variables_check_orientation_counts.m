%================
% Subplot 2
%================

error_code_current = cell(1);
error_code_current{1} = 'correct';
texture_on_current = [1];

%==============
% Data

data_mat = struct;
data_mat.var1{1} = S.esetup_background_texture_line_angle(:,1);
data_mat.var1_match{1} = orientations_used;
data_mat.var1{2} = S.esetup_block_cond;
data_mat.var1_match{2} = task_names_used;
data_mat.var1{3} = S.edata_error_code;
data_mat.var1_match{3} = error_code_current;
data_mat.var1{4} = S.esetup_background_texture_on(:,1);
data_mat.var1_match{4} = texture_on_current;

data_mat = look6_helper_indexed_selection_behaviour(data_mat, settings);

mat_y = data_mat.trial_counts;
fig_plot_on = sum(sum(isnan(mat_y))) ~= numel(mat_y);

if fig_plot_on == 1
    
    hfig = subplot(fig_subplot_dim(1), fig_subplot_dim(2), 2);
    hold on;
    fprintf('\n%s %s: preparing panel with orientation counts\n', settings.subject_current, num2str(settings.date_current));
    
    %=============
    % Line figures
    %=============
    
    plot_set = struct;
    
    % Colors
    plot_set.data_color = NaN(1, numel(task_names_used));
    ind1 = strcmp(task_names_used, 'look');
    if ~isempty(ind1)
        plot_set.data_color(ind1) = [1];
    end
    ind1 = strcmp(task_names_used, 'avoid');
    if ~isempty(ind1)
        plot_set.data_color(ind1) = [2];
    end
    ind1 = strcmp(task_names_used, 'control fixate');
    if ~isempty(ind1)
        plot_set.data_color(ind1) = [4];
    end
    
    % Figure title
    plot_set.figure_title = sprintf('Background orientation');
    
    %===============
    % Averages data
    % Initialize structure with data
    plot_set.mat_y = data_mat.trial_counts;
    plot_set.mat_x = orientations_used;
    
    % Labels for plotting
    plot_set.xlabel = 'Background angle, deg';
    plot_set.ylabel = 'No of trials';
    plot_set.legend = task_names_used;
    
    % Plot
    plot_helper_line_plot_v10;
    
end