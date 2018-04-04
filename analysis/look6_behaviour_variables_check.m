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
error_code_subset{2} = 'broke fixation';
error_code_subset{3} = 'looked at st2';


%% Figures calculations


for fig1 = 1:numel(num_fig) % Plot figures
    
    close all;
    
    settings.figure_current = num_fig(fig1);
    fprintf('\nPreparing figure %s out of %s total for this analysis\n', num2str(fig1), num2str(numel(num_fig))  )
    
    %================
    % Figure size
    
    fig_subplot_dim = [3, 3];
    fig_size = [0, 0, fig_subplot_dim(2) * settings.figsize_1col(3), fig_subplot_dim(1) * settings.figsize_1col(4)];
    
    
    % Subplot 1
    look6_behaviour_variables_check_memory_delay_counts;
    
    % Subplot 2
    look6_behaviour_variables_check_orientation_counts;
    
    % Subplot 3
    look6_behaviour_variables_check_daily_performance;
    
    % Subplot 4
    look6_behaviour_variables_srt_bar;
    
    %==========
    % Save data
    %==========
    
    plot_set.figure_size = fig_size;
    plot_set.figure_save_name = sprintf ('%s %s fig%s', settings.subject_current, num2str(settings.date_current), num2str(settings.figure_current));
    plot_set.path_figure = path_fig;
    
    plot_helper_save_figure;
    close all;
    
    
end