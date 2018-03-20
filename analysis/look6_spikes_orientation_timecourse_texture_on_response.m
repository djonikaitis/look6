
close all;

task_names_used = unique(S.esetup_block_cond);
orientations_used = unique(S.esetup_background_texture_line_angle(:,1));
texture_on_used = [1, 0];
memory_angles_used = unique(S.memory_angle);


%% Plot the data

% Matrices
k = numel(texture_on_used);
mat_y = NaN(1, numel(settings.plot_bins), k);
test1 = NaN(1, k);
mat_y_lower = NaN(1,numel(settings.plot_bins), k);
mat_y_upper =  NaN(1,numel(settings.plot_bins), k);

for k = 1:numel(texture_on_used)
    
    texture_on_current = texture_on_used(k);
    
    % Get index
    index = S.esetup_background_texture_on(:,1) == texture_on_current & ...
        strncmp(S.edata_error_code, 'correct', 7);
    temp1 = mat1_ini(index,:);
    test1(1,k) = sum(index);
    
    % Get means
    a = [];
    if sum(index)>1
        a = nanmean(temp1);
    elseif sum(index) == 1
        a = temp1;
    end
    [n] = numel(a);
    mat_y(1,1:n,k) = a;
    
    % Get error bars
    settings.bootstrap_on = 0;
    a = plot_helper_error_bar_calculation_v10(temp1, settings);
    try
        mat_y_upper(1,:,k)= a.se_upper;
        mat_y_lower(1,:,k)= a.se_lower;
    end
    settings = rmfield (settings, 'bootstrap_on');
    
end

% Plot data
if sum(test1)>0
    
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
    plot_helper_basic_line_figure;
    
    % Save data
    plot_set.figure_size = settings.figsize_1col;
    plot_set.figure_save_name = sprintf ('%s_fig%s', settings.neuron_name, num2str(settings.figure_current));
    plot_set.path_figure = path_fig;
    
    plot_helper_save_figure;
    close all;
end
