%================
% Subplot 2
%================

%==============
% Data
data_mat = struct;
data_mat.mat1_ini = S.esetup_background_texture_line_angle(:,1);
data_mat.mat1_bins = orientations_used;
data_mat.var1{1} = S.esetup_block_cond;
data_mat.var1_match{1} = task_names_used;
data_mat.var1{2} = S.edata_error_code;
data_mat.var1_match{2} = error_code_current;
data_mat.var1{3} = S.esetup_background_texture_on(:,1);
data_mat.var1_match{3} = texture_on_current;
data_mat.output = NaN(1, numel(data_mat.mat1_bins), numel(data_mat.var1_match{1}));

for i = 1:numel(data_mat.mat1_bins)
    for j = 1:numel(data_mat.var1_match{1})
        for k = 1:numel(data_mat.var1_match{2})
            
            % Index
            index = data_mat.mat1_ini == data_mat.mat1_bins(i) & ...
                strcmp (data_mat.var1{1}, data_mat.var1_match{1}(j)) & ...
                strcmp (data_mat.var1{2}, data_mat.var1_match{2}(k));
            
            % Output
            data_mat.output(1,i,j) = sum(index);
            
        end
    end
end

mat_y = data_mat.output;
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
    plot_set.mat_y = data_mat.output;
    plot_set.mat_x = orientations_used;
    
    % Labels for plotting
    plot_set.xlabel = 'Background angle, deg';
    plot_set.ylabel = 'No of trials';
    plot_set.legend = task_names_used;
    
    % Plot
    plot_helper_basic_line_figure;
    
end