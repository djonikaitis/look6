
close all;

threshold1 = 50; % Max number of trials to plot

error_code_current = 'correct';
texture_on_current = 1;

%% Calculate axis limits

%==============
% Data
data_mat = struct;
data_mat.mat1_ini = mat1_ini;
data_mat.var1{1} = S.memory_angle;
data_mat.var1_match{1} = memory_angles_used;
data_mat.var1{2} = S.esetup_block_cond;
data_mat.var1_match{2} = task_names_used;
data_mat.var1{3} = S.esetup_background_texture_line_angle(:,1);
data_mat.var1_match{3} = orientations_used;
data_mat.var1{4} = S.esetup_background_texture_on(:,1);
data_mat.var1_match{4} = texture_on_current;
data_mat.var1{5} = S.edata_error_code;
data_mat.var1_match{5} = error_code_current;
settings.bootstrap_on = 0;

[~, mat_y_upper, mat_y_lower, test1] = look6_helper_indexed_selection(data_mat, settings);

%===============
% Y limits
% Reshape matrixes to know numbers of trials
[m,n,o,q,r,s] = size(mat_y_upper);
a = reshape(mat_y_lower, m, n, o*q*r*s);
b = reshape(mat_y_upper, m, n, o*q*r*s);

% Initialize structure with data
plot_set = struct;
plot_set.ebars_lower_y = a;
plot_set.ebars_upper_y = b;
look6_helper_data_limits;

% Add buffer on the axis
val1_min = 0.05;
val1_max = 0.05;
h0_min = plot_set.ylim(1);
h0_max = plot_set.ylim(2);
plot_set.ylim(1) = h0_min - ((h0_max - h0_min) * val1_min);
plot_set.ylim(2) = h0_max + ((h0_max - h0_min) * val1_max);

% Add space for spike rasters
[m,n,o,q,r,s] = size(test1);
test1_copy = test1;
test1 = reshape(test1_copy, m, n*o*q*r*s);

a = max(test1);
if a>threshold1
    a = threshold1;
end
plot_set.ylim(2) = plot_set.ylim(2) + a*2;
all_fig_y_lim = plot_set.ylim;


%%  Figure size

if numel(orientations_used)==4
    fig_subplot_dim = [2,2];
elseif numel(orientations_used)==5
    fig_subplot_dim = [2,3];
elseif numel(orientations_used)==6
    fig_subplot_dim = [2,3];
elseif numel(orientations_used)==7
    fig_subplot_dim = [3,3];
elseif numel(orientations_used)==8
    fig_subplot_dim = [3,3];
elseif numel(orientations_used)==9
    fig_subplot_dim = [3,3];
elseif numel(orientations_used)==10
    fig_subplot_dim = [3,4];
end

fig_size = [0, 0, fig_subplot_dim(2) * settings.figsize_1col(4), fig_subplot_dim(1) * settings.figsize_1col(3)];


%% Work on each panel

for i_fig1 = 1:numel(task_names_used)
    
    task_name_current = task_names_used{i_fig1};
    fprintf('\n%s: preparing figure for the "%s" task \n', settings.neuron_name, task_name_current)
    
    for i_fig2 = 1:numel(memory_angles_used)
        
        memory_angle_current = memory_angles_used(i_fig2);
        fprintf('\n%s: preparing figure for the memory location "%s", "%s" task \n', settings.neuron_name, num2str(memory_angle_current), task_name_current)
        
        % Is there any data to plot for current condition and location?
        a = test1_copy(:, i_fig2, i_fig1, :);
        fig_plot_on = sum(a);
        
        extended_title=0;
        
        if fig_plot_on > 0
            
            for i_fig3 = 1:numel(orientations_used)
                
                orientation_current = orientations_used(i_fig3);
                
                % Only if data exists
                if test1_copy(1, i_fig2, i_fig1, i_fig3) > 0
                    
                    % Initialize figure
                    hfig = subplot(fig_subplot_dim(1), fig_subplot_dim(2), i_fig3);
                    hold on;
                    fprintf('\n%s: preparing panel for %s deg texture tilt angle \n', settings.neuron_name, num2str(orientation_current))
                    
                    % Data
                    plot_set = struct;
                    
                    mat_y = NaN(1, numel(settings.plot_bins));
                    mat_y_lower = NaN(1,numel(settings.plot_bins));
                    mat_y_upper =  NaN(1,numel(settings.plot_bins));
                    
                    % Get index
                    index = S.esetup_background_texture_line_angle(:,1) == orientation_current & ...
                        S.memory_angle == memory_angle_current & ...
                        strcmp(S.esetup_block_cond, task_name_current) & ...
                        S.esetup_background_texture_on(:,1) == texture_on_current & ...
                        strncmp(S.edata_error_code, error_code_current, 7);
                    temp1 = mat1_ini(index,:);
                    
                    % Get means
                    a = []; i = 1;
                    if sum(index)>=settings.trial_number_threshold
                        a = nanmean(temp1);
                    end
                    [n] = numel(a);
                    mat_y(1,1:n,i) = a;
                    
                    % Get error bars
                    if sum(index)>=settings.trial_number_threshold
                        settings.bootstrap_on = 0;
                        a = plot_helper_error_bar_calculation_v10(temp1, settings);
                        mat_y_upper(1,:,i)= a.se_upper;
                        mat_y_lower(1,:,i)= a.se_lower;
                        settings = rmfield (settings, 'bootstrap_on');
                    end
                    
                    %==============
                    % Plot spikes and events
                    % Spikes and events
                    t1_spike = spikes1.ts; % Initialize spike timing
                    t1_evt = events_mat.msg_1; % Get timing of the events
                    t1_evt = t1_evt + S.tconst; % Reset to time relative to tconst
                    
                    % Select all spikes in the trial
                    evt_ind = t1_evt(index);
                    
                    % Reduce number of spikes plotted to threshold1
                    if numel(evt_ind)>threshold1
                        a = randperm(numel(evt_ind));
                        ind = a(1:threshold1);
                        ind = sort(ind,'ascend');
                        evt_ind = evt_ind(ind);
                    end
                    
                    % Plot spike rasters
                    for i = 1:numel(evt_ind)
                        
                        % Get spikes in current trial
                        ind = t1_spike >= evt_ind(i)+settings.int_bins(1) & t1_spike <= evt_ind(i)+settings.int_bins(end);
                        data1 = t1_spike(ind) - evt_ind(i);
                        
                        % Y coord
                        a = ones(numel(data1), 1);
                        a = a * all_fig_y_lim(2);
                        a = a - i*2;
                        for j = 1:numel(data1)
                            plot([data1(j),data1(j)], [a(j),a(j)-1], 'LineWidth', 0.1, 'Color', [0.1,0.1,0.1]);
                        end
                    end
                    
                    %===============
                    % Averages data
                    % Initialize structure with data
                    plot_set.mat_y = mat_y;
                    plot_set.mat_x = settings.plot_bins;
                    plot_set.ebars_lower_y = mat_y_lower;
                    plot_set.ebars_upper_y = mat_y_upper;
                    plot_set.ebars_shade = 1;
                    
                    plot_set.ylim = all_fig_y_lim;
                    
                    % Colors
                    if strcmp(task_name_current, 'look')
                        plot_set.data_color = [1];
                    elseif strcmp(task_name_current, 'avoid')
                        plot_set.data_color = [2];
                    elseif strcmp(task_name_current, 'control fixate')
                        plot_set.data_color = [4];
                    else
                        plot_set.data_color = [0.1, 0.1, 0.1];
                    end
                    
                    % Labels for plotting
                    if extended_title == 0
                        plot_set.xlabel = 'Time after cue, ms';
                        plot_set.ylabel = 'Firing rate, Hz';
                    end
                    
                    % Figure title
                    if extended_title==0
                        plot_set.figure_title = sprintf('%s, loc %s, tex %s', task_name_current, num2str(memory_angle_current), num2str(orientation_current));
                        extended_title = 1;
                    else
                        plot_set.figure_title = sprintf('Texture %s deg', num2str(orientation_current));
                    end
                    
                    % Plot
                    plot_helper_basic_line_figure;
                    
                    
                end
                % End of decision whether to plot a sub-panel for
                % orientation
                
            end
            % End of each orientation
        end
        
        
        %==========
        % Save data
        %==========
        
        if fig_plot_on > 0
            
            plot_set.figure_size = fig_size;
            plot_set.figure_save_name = sprintf ('%s_fig%s_%s_location_%s', settings.neuron_name, num2str(settings.figure_current), task_name_current, num2str(memory_angle_current));
            plot_set.path_figure = path_fig;
            
            plot_helper_save_figure;
            close all;
        end
        
    end
    % End of each location
    
end
% End of look avoid etc