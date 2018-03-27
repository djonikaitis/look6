% Prepare each figure

num_fig = [1];


%%  Calculate few variables, done only once for all figures

% Save memory angle
temp1 = S.esetup_memory_coord;
[th,radiusdeg] = cart2pol(temp1(:,1), temp1(:,2));
theta = (th*180)/pi;
S.memory_angle = theta;

% Reset memory arc relative to RF center (assumes
% RF is in left lower visual field) at the moment.
% Done for each session separately.
S.memory_angle_relative = NaN(numel(S.session), 1);
for i = 1:max(S.session)
    index = S.session == i;
    a = unique(S.memory_angle(index));
    a = min(a);
    S.memory_angle_relative(index) = S.memory_angle(index) - a;
end
% Round off
S.memory_angle_relative = round(S.memory_angle_relative, 1);
% Reset to range -180:180
ind = S.memory_angle_relative<-180;
S.memory_angle_relative(ind)=S.memory_angle_relative(ind)+360;
ind = S.memory_angle_relative>=180;
S.memory_angle_relative(ind)=S.memory_angle_relative(ind)-360;

%=====================
% Initialize a few variables
task_names_used = unique(S.esetup_block_cond);
orientations_used = unique(S.esetup_background_texture_line_angle(:,1));
texture_on_used = [1,0];
memory_angles_used = unique(S.memory_angle);
memory_angles_relative_used = unique(S.memory_angle_relative);
exp_versions_used = unique(S.esetup_exp_version);


%% Figures calculations


for fig1 = 1:numel(num_fig) % Plot figures
    
    close all;
    
    %================
    % Figure size
    
    fig_subplot_dim = [3, 2];
    fig_size = [0, 0, fig_subplot_dim(2) * settings.figsize_1col(3), fig_subplot_dim(1) * settings.figsize_1col(4)];
    
    % Subplot 1
    look6_behaviour_variables_check_memory_delay_counts;
    
    % Subplot 2
    look6_behaviour_variables_check_orientation_counts;
    
    % Subplot 3
    look6_behaviour_variables_check_daily_performance;
    
    %==========
    % Save data
    %==========
    
    if fig_plot_on == 1
        
        plot_set.figure_size = fig_size;
        plot_set.figure_save_name = sprintf ('%s %s fig%s', settings.subject_current, num2str(settings.date_current), num2str(settings.figure_current));
        plot_set.path_figure = path_fig;
        
        plot_helper_save_figure;
        close all;
        
    end
    
    
end