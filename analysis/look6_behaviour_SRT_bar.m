% Prepare each figure

num_fig = [1];


%%  Calculate few variables, done only once for all figures

% Save memory angle
temp1 = S.esetup_memory_coord;
[th,radiusdeg] = cart2pol(temp1(:,1), temp1(:,2));
theta = (th*180)/pi;
S.memory_angle = theta;

% Save st1 angle
temp1 = S.esetup_st1_coord;
[th,radiusdeg] = cart2pol(temp1(:,1), temp1(:,2));
theta = (th*180)/pi;
S.st1_angle = theta;

%=================
% Memory location relative to ST1
S.memory_angle_relative_st1 = S.memory_angle - S.st1_angle;
S.memory_angle_relative_st1 = round(S.memory_angle_relative_st1, 1);
% Reset to range -180:180
ind = S.memory_angle_relative_st1<-180;
S.memory_angle_relative_st1(ind)=S.memory_angle_relative_st1(ind)+360;
ind = S.memory_angle_relative_st1>=180;
S.memory_angle_relative_st1(ind)=S.memory_angle_relative_st1(ind)-360;

%=====================
% Initialize a few variables
task_names_used = unique(S.esetup_block_cond);
orientations_used = unique(S.esetup_background_texture_line_angle(:,1));
texture_on_used = [1,0];
memory_angles_used = unique(S.memory_angle);
memory_angles_relative_st1_used = unique(S.memory_angle_relative_st1);
exp_versions_used = unique(S.esetup_exp_version);

error_code_subset = cell(1);
error_code_subset{1} = 'correct';
error_code_subset{2} = 'looked at st2';

% Reset data
if isfield(S, 'target_on')
    S.sacconset = sacc1.saccade_matrix(:,1)-S.target_on;
end

% Other variables used for analysis
task_names_subset = cell(1);
task_names_subset{1} = 'look';
task_names_subset{2} = 'avoid';

memory_angles_relative_st1_subset = [0, -180];
error_code_current = {'correct'};


%% Plot

for fig1 = 1:numel(num_fig) % Plot figures
    
        
    %================
    % Subplot 1
    %================
    
    %==============
    % Data
    
    data_mat = struct;
    data_mat.mat1_ini = S.sacconset;
    data_mat.var1{1} = S.esetup_block_cond;
    data_mat.var1_match{1} = task_names_subset;
    data_mat.var1{2} = S.edata_error_code;
    data_mat.var1_match{2} = error_code_subset;
    data_mat.var1{3} = S.esetup_target_number;
    data_mat.var1_match{3} = 2;
    data_mat.var1{4} = S.esetup_st2_color_level;
    data_mat.var1_match{4} = 0;
    data_mat.var1{5} = S.esetup_response_soa;
    data_mat.var1_match{5} = 0;
    
    data_mat.method =  'mean';
    data_mat = look6_helper_indexed_selection_behaviour(data_mat, settings);
    
    % Initialize mat
    if settings.date_current == settings.dates_used(1)
        mat1 = NaN(numel(settings.dates_used), numel(task_names_subset), 2);
    end
    
    % Select data for plotting
    for i = 1:size(mat1,2)
        for j = 1:size(mat1,3)
            mat1(i_date,i,j) = data_mat.mat_y(1, i, j);
            if numel(settings.dates_used)==1
                mat1_lower_y(i_date,i,j) = data_mat.mat_y_lower(1, i, j);
                mat1_upper_y(i_date,i,j) = data_mat.mat_y_upper(1, i, j);
            end
        end
    end
    
    % Add error bars
    if numel(settings.dates_used)>1 && settings.date_current == settings.dates_used(end)
        settings.bootstrap_on = 0;
        e_bars = plot_helper_error_bar_calculation_v10(mat1, settings);
    end
    
    %==========
    % Plot
    %==========
    
    if ~isempty(settings.dates_used) && settings.date_current == settings.dates_used(end)
        
        close all;
        
        settings.figure_current = num_fig(fig1);
        fprintf('\nPreparing figure %s out of %s total for this analysis\n', num2str(fig1), num2str(numel(num_fig))  )
        
        %================
        % Figure size
        
        fig_subplot_dim = [1, 2];
        fig_size = [0, 0, fig_subplot_dim(2) * settings.figsize_1col(3), fig_subplot_dim(1) * settings.figsize_1col(4)];
        
        % Is there data to plot?
        [i,j,k,m,o] = size(mat1);
        mat_y = reshape(mat1, 1, i*j*k*m*o);
        
        fig_plot_on = sum(sum(isnan(mat_y))) ~= numel(mat_y);
        
        % Plot
        if fig_plot_on == 1
            
            hfig = subplot(fig_subplot_dim(1), fig_subplot_dim(2), 1);
            hold on;
            
            plot_set = struct;
            plot_set.mat_y = nanmean(mat1);
            plot_set.ebars_lower_y = e_bars.se_lower;
            plot_set.ebars_upper_y = e_bars.se_upper;
            
            plot_set.data_color = [1,2];
            
            % xticks
            plot_set.xtick_label = error_code_subset;
            ind = strcmp(plot_set.xtick_label, 'looked at st2');
            plot_set.xtick_label{ind} = 'error';
            
            plot_set.ylim = [90, max(max(plot_set.mat_y)) + 30];
            plot_set.ylabel = 'Reaction time, ms';
            
            plot_set.figure_title = 'Main task trials';
            
            plot_set.legend = task_names_subset;
            for i=1:numel(plot_set.legend)
                plot_set.legend_y_coord(i) = 95;
            end
            
            plot_helper_bargraph_plot_v10
            
        end
        
    end
    
    %==============
    % Subplot 2
    %==============
    
    %==============
    % Data
    
    data_mat = struct;
    data_mat.mat1_ini = S.sacconset;
    data_mat.var1{1} = S.memory_angle_relative_st1;
    data_mat.var1_match{1} = memory_angles_relative_st1_subset;
    data_mat.var1{2} = S.esetup_block_cond;
    data_mat.var1_match{2} = task_names_subset;
    data_mat.var1{3} = S.edata_error_code;
    data_mat.var1_match{3} = error_code_current;
    data_mat.var1{4} = S.esetup_target_number;
    data_mat.var1_match{4} = 1;
    data_mat.var1{5} = S.esetup_st2_color_level;
    data_mat.var1_match{5} = 0;
    data_mat.var1{6} = S.esetup_response_soa;
    data_mat.var1_match{6} = 0;
    data_mat.method =  'mean';
    
    data_mat = look6_helper_indexed_selection_behaviour(data_mat, settings);
    
    % Select data for plotting
    if settings.date_current == settings.dates_used(1)
        mat2 = NaN(numel(settings.dates_used), numel(memory_angles_relative_st1_subset), numel(task_names_subset));
        [m,n,o] = size(mat2);
        mat2_lower_y = NaN(1,n,o);
        mat2_upper_y = NaN(1,n,o);
    end
    
    for i = 1:size(mat2,2)
        for j = 1:size(mat2,3)
            mat2(i_date,i,j) = data_mat.mat_y(1, i, j);
            if numel(settings.dates_used)==1
                mat2_lower_y(i_date,i,j) = data_mat.mat_y_lower(1, i, j);
                mat2_upper_y(i_date,i,j) = data_mat.mat_y_upper(1, i, j);
            end
        end
    end
    
    % Add error bars
    if numel(settings.dates_used)>1 && settings.date_current == settings.dates_used(end)
        settings.bootstrap_on = 0;
        e_bars = plot_helper_error_bar_calculation_v10(mat2, settings);
    end
    
    %==========
    % Plot
    %==========
    
    if ~isempty(settings.dates_used) && settings.date_current == settings.dates_used(end)
        
        
        settings.figure_current = num_fig(fig1);
        fprintf('\nPreparing figure %s out of %s total for this analysis\n', num2str(fig1), num2str(numel(num_fig)) )
        
        %================
        % Figure size
        
        fig_subplot_dim = [1, 2];
        fig_size = [0, 0, fig_subplot_dim(2) * settings.figsize_1col(3), fig_subplot_dim(1) * settings.figsize_1col(4)];
        
        % Is there data to plot?
        [i,j,k,m,o] = size(mat2);
        mat_y = reshape(mat2, 1, i*j*k*m*o);
        
        fig_plot_on = sum(sum(isnan(mat_y))) ~= numel(mat_y);
        
        % Plot
        if fig_plot_on == 1
            
            hfig = subplot(fig_subplot_dim(1), fig_subplot_dim(2), 2);
            hold on;
            
            plot_set = struct;
            plot_set.mat_y = nanmean(mat2);
            plot_set.ebars_lower_y = e_bars.se_lower;
            plot_set.ebars_upper_y = e_bars.se_upper;
            
            plot_set.data_color = [9,10];
            
            % xticks
            n1_used = task_names_subset;
            plot_set.xtick_label = n1_used;
            
            plot_set.ylim = [90, max(max(plot_set.mat_y))+ 30];
            plot_set.ylabel = 'Reaction time, ms';
            
            plot_set.figure_title = 'Probe trials';
            
            plot_set.legend{1} = 'Cued';
            plot_set.legend{2} = 'Uncued';
            for i=1:numel(plot_set.legend{1})
                plot_set.legend_y_coord(i) = 95;
            end
            
            plot_helper_bargraph_plot_v10
            
        end
    end
    
    
end



