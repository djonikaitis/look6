% Psychophysics performance

% Reset data
if isfield(S, 'target_on')
    S.sacconset = sacc1.saccade_matrix(:,1)-S.target_on;
end

task_names_subset = cell(1);
task_names_subset{1} = 'look';
task_names_subset{2} = 'avoid';

memory_angles_relative_st1_subset = [0, -180];
error_code_current = {'correct'};

%==============
% Subplot
%==============


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

%==========
% Plot correct vs error
%==========

% Select data for plotting
mat1 = NaN(1, numel(task_names_subset), 2);
for i = 1:numel(task_names_subset)
    
    j = strcmp(error_code_subset, 'correct');
    mat1(1,i,1) = data_mat.mat_y(1, i, j);
    mat1_lower_y(1,i,1) = data_mat.mat_y_lower(1, i, j);
    mat1_upper_y(1,i,1) = data_mat.mat_y_upper(1, i, j);
    
    j = strcmp(error_code_subset, 'looked at st2');
    mat1(1,i,2) = data_mat.mat_y(1, i, j);
    mat1_lower_y(1,i,2) = data_mat.mat_y_lower(1, i, j);
    mat1_upper_y(1,i,2) = data_mat.mat_y_upper(1, i, j);
    
end

% Is there data to plot?
[i,j,k,m,o] = size(data_mat.mat_y);
mat_y = reshape(data_mat.mat_y, 1, i*j*k*m*o);

fig_plot_on = sum(sum(isnan(mat_y))) ~= numel(mat_y);

% Plot
if fig_plot_on == 1
    
    hfig = subplot(fig_subplot_dim(1), fig_subplot_dim(2), 7);
    hold on;
    
    plot_set = struct;
    plot_set.mat_y = mat1;
    plot_set.ebars_lower_y = mat1_lower_y;
    plot_set.ebars_upper_y = mat1_upper_y;
    
    plot_set.data_color = [1,2];
    
    % xticks
    plot_set.xtick_label{1} = 'Correct';
    plot_set.xtick_label{2} = 'Error';
    
    plot_set.ylim = [90, max(max(plot_set.mat_y)) + 30];
    plot_set.ylabel = 'Reaction time, ms';
    
    plot_set.figure_title = 'Main task trials';
    
    plot_set.legend{1} = 'Look';
    plot_set.legend{2} = 'Avoid';
    for i=1:numel(plot_set.legend{1})
        plot_set.legend_y_coord(i) = 95;
    end
    
    plot_helper_bargraph_plot_v10
    
end

%==============
% Subplot 
%==============


%==============
% Data

data_mat = struct;
data_mat.mat1_ini = S.sacconset;
data_mat.var1{1} = S.memory_angle_relative_st1;
data_mat.var1_match{1} = memory_angles_relative_st1_subset;
data_mat.var1{2} = S.esetup_block_cond;
data_mat.var1_match{2} = task_names_used;
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

%==========
% Plot correct vs error
%==========

% Is there data to plot?
[i,j,k,m,o] = size(data_mat.mat_y);
mat_y = reshape(data_mat.mat_y, 1, i*j*k*m*o);

fig_plot_on = sum(sum(isnan(mat_y))) ~= numel(mat_y);

% Plot
if fig_plot_on == 1
    
    hfig = subplot(fig_subplot_dim(1), fig_subplot_dim(2), 8);
    hold on;
    
    plot_set = struct;
    plot_set.mat_y = data_mat.mat_y;
    plot_set.ebars_lower_y = data_mat.mat_y_lower;
    plot_set.ebars_upper_y = data_mat.mat_y_upper;
        
    plot_set.data_color = [9,10];
    
    % xticks
    n1_used = task_names_used;
    if strcmp(task_names_used, 'control fixate')
        ind = strcmp(task_names_used, 'control fixate');
        n1_used{ind} = 'control';
    end
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

