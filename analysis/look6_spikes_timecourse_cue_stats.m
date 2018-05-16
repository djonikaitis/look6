
close all; 

error_code_current = 'correct';

% Figure size
fig_subplot_dim = [1, 3];
fig_size = [0, 0, fig_subplot_dim(2) * settings.figsize_1col(3), fig_subplot_dim(1) * settings.figsize_1col(4)];
current_subplot = 0;


%% Work on each panel

                
%==============
% Data
data_mat = struct;
data_mat.mat1_ini = data1.mat1_ini;
data_mat.var1{1} = S.memory_angle;
data_mat.var1_match{1} = memory_angles_used;
data_mat.var1{2} = S.edata_error_code;
data_mat.var1_match{2} = error_code_current;
settings.bootstrap_on = 0;

[mat_y, mat_y_upper, mat_y_lower, ~] = look6_helper_indexed_selection(data_mat, settings);

%================
% Is there any data to plot?

fig_plot_on = sum(sum(isnan(mat_y))) ~= numel(mat_y);

if fig_plot_on > 0 % Decide whether to bother initializing a panel
    
    % Initialize figure sub-panel
    current_subplot = current_subplot + 1;
    hfig = subplot(fig_subplot_dim(1), fig_subplot_dim(2), current_subplot);
    hold on;
    
    plot_set = struct;
    
    plot_set.data_color_min = [0.2, 0.2, 0.2];
    plot_set.data_color_max = [0.8, 0.8, 0.8];
    
    % Figure title
    plot_set.figure_title = 'Responses to the cue';
    
    %===============
    % Averages data
    % Initialize structure with data
    plot_set.mat_y = mat_y;
    plot_set.mat_x = data1.mat1_plot_bins;
    plot_set.ebars_lower_y = mat_y_lower;
    plot_set.ebars_upper_y = mat_y_upper;
    plot_set.ebars_shade = 1;
    
    % Labels for plotting
    plot_set.xlabel = 'Time after cue, ms';
    plot_set.ylabel = 'Firing rate, Hz';
    
    % Plot
    plot_helper_line_plot_v10;
    
end
% End of checking whether data exists for plotting


%===============
% Plot inset with legend
if fig_plot_on == 1
    
    axes('Position',[0.01,0.8,0.1,0.1])
    axis 'equal'
    set (gca, 'Visible', 'off')
    hold on;
    
    var1 = round(memory_angles_used);
    
    % Plot circle radius
    cpos1 = [0,0];
    ticks1 = [1];
    cl1 = [0.5,0.5,0.5];
    for i=1:length(ticks1)
        h=rectangle('Position', [cpos1(1,1)-ticks1(i), cpos1(1,2)-ticks1(i), ticks1(i)*2, ticks1(i)*2],...
            'EdgeColor', cl1, 'FaceColor', 'none', 'Curvature', 1, 'LineWidth', 0.5, 'LineStyle', '-');
    end
    
    % Plot fixation dot
    cpos1 = [0,0];
    ticks1 = [0.1];
    cl1 = [0.5,0.5,0.5];
    for i=1:length(ticks1)
        h=rectangle('Position', [cpos1(1,1)-ticks1(i), cpos1(1,2)-ticks1(i), ticks1(i)*2, ticks1(i)*2],...
            'EdgeColor', cl1, 'FaceColor', cl1, 'Curvature', 1, 'LineWidth', 0.5, 'LineStyle', '-');
    end
    
    % Initialize data values for plotting
    for i=1:length(var1)
        
        % Color
        graphcond = i;
        
        % Find coordinates of a line
        f_rad = 1;
        f_arc = var1(i);
        [xc,yc] = pol2cart(f_arc*pi/180, f_rad);
        objsize = 0.7;
        
        % Plot cirlce
        h=rectangle('Position', [xc(1)-objsize(1)/2, yc(1)-objsize(1)/2, objsize(1), objsize(1)],...
            'EdgeColor', plot_set.main_color(i,:), 'FaceColor', plot_set.main_color(i,:),'Curvature', 0, 'LineWidth', 1);
        
    end
  
end
%==============
% End of inset

%% Work on each panel

%==============
% Data
data_mat = struct;
data_mat.mat1_ini = data1.mat2_ini;
data_mat.var1{1} = S.memory_angle;
data_mat.var1_match{1} = memory_angles_used;
data_mat.var1{2} = S.edata_error_code;
data_mat.var1_match{2} = error_code_current;
settings.bootstrap_on = 0;

[mat_y, mat_y_upper, mat_y_lower, ~] = look6_helper_indexed_selection(data_mat, settings);

% Is there data to plot?
[i,j,k,m,o] = size(mat_y);
temp1 = reshape(mat_y, 1, i*j*k*m*o);
temp1_upper = reshape(mat_y_upper, 1, i*j*k*m*o);
temp1_lower = reshape(mat_y_lower, 1, i*j*k*m*o);

fig_plot_on = sum(sum(isnan(temp1))) ~= numel(temp1);


% Plot
if fig_plot_on == 1
    
    % Initialize figure sub-panel
    current_subplot = current_subplot + 1;
    hfig = subplot(fig_subplot_dim(1), fig_subplot_dim(2), current_subplot);
    hold on;
    
    plot_set = struct;
    plot_set.mat_y = temp1;
    plot_set.ebars_lower_y = temp1_lower;
    plot_set.ebars_upper_y = temp1_upper;
    
    plot_set.data_color_min = [0.2, 0.2, 0.2];
    plot_set.data_color_max = [0.8, 0.8, 0.8];
    
    plot_set.ylabel = 'Spikes/s';
    plot_set.xlabel = 'Cue location';
    plot_set.figure_title = ['0 to 200 ms after cue'];
    plot_set.xtick = 'none';
    
    plot_helper_bargraph_plot_v10
    
end


%% Work on each panel

selectivity_found = 0;

%=================
% Determine if theres effect of condition
index = strncmp(S.edata_error_code, error_code_current, 7);
label1 = S.memory_angle(index,:);
meas1 = data1.mat2_ini(index,:);

% Stats
[p, tbl, stats] = kruskalwallis(meas1, label1, 'off');
[mtbl1] = multcompare(stats, 'Display', 'off');

% Restructure matrix and find which location differs from all others
var1 = memory_angles_used;
v1 = NaN(numel(var1), numel(var1));
for i = 1:size(mtbl1, 1)
    m = mtbl1(i,1);
    n = mtbl1(i,2);
    a = mtbl1(i,6);
    if a<=0.05
        v1(m,n) = 1;
        v1(n,m) = 1;
    elseif a>0.05
        v1(m,n) = 0;
        v1(n,m) = 0;
    end
end

% Calculate location relative to memory
v2 = nansum(v1);
loc_ind = find(v2==numel(v2)-1);
ST = struct;

if ~isempty(loc_ind) && numel(loc_ind)==1
    
    % Reset memory arc relative to RF center
    temp1 = NaN(numel(S.session), 1);
    for i = 1:max(S.session)
        index = S.session == i;
        a = memory_angles_used(loc_ind);
        temp1(index) = S.memory_angle(index) - a;
    end
    % Round off
    temp1 = round(temp1, 1);
    % Reset to range -180:180
    ind = temp1<-180;
    temp1(ind)=temp1(ind)+360;
    ind = temp1>=180;
    temp1(ind)=temp1(ind)-360;
    ST.memory_angle_relative = temp1;
    ST.memory_angle_relative_used = removeNaN(unique(temp1));
    selectivity_found = 1;
    
else
end

             
%==============
% Data
data_mat = struct;
data_mat.mat1_ini = data1.mat2_ini;
data_mat.var1{1} = ST.memory_angle_relative;
data_mat.var1_match{1} = ST.memory_angle_relative_used;
data_mat.var1{2} = S.edata_error_code;
data_mat.var1_match{2} = error_code_current;
settings.bootstrap_on = 0;

[mat_y, mat_y_upper, mat_y_lower, ~] = look6_helper_indexed_selection(data_mat, settings);

% Is there data to plot?
[i,j,k,m,o] = size(mat_y);
temp1 = reshape(mat_y, 1, i*j*k*m*o);
temp1_upper = reshape(mat_y_upper, 1, i*j*k*m*o);
temp1_lower = reshape(mat_y_lower, 1, i*j*k*m*o);

fig_plot_on = sum(sum(isnan(temp1))) ~= numel(temp1);


% Plot
if fig_plot_on == 1
    
    % Initialize figure sub-panel
    current_subplot = current_subplot + 1;
    hfig = subplot(fig_subplot_dim(1), fig_subplot_dim(2), current_subplot);
    hold on;
    
    plot_set = struct;
    plot_set.mat_y = temp1;
    plot_set.ebars_lower_y = temp1_lower;
    plot_set.ebars_upper_y = temp1_upper;
    
    if selectivity_found == 0
        plot_set.data_color_min = [0.2, 0.2, 0.2];
        plot_set.data_color_max = [0.8, 0.8, 0.8];
    else
        plot_set.data_color_min = [1];
        plot_set.data_color_max = [10];
    end

    
    plot_set.ylabel = 'Spikes/s';
    plot_set.xlabel = 'Cue location';
    plot_set.figure_title = ['0 to 200 ms after cue'];
    plot_set.xtick_label = 'none';
    
    for i = 1:numel(memory_angles_used)
        plot_set.legend{i} = num2str(round(memory_angles_used(i)));
    end
    plot_set.legend_color = [0.9, 0.9, 1];
    
    plot_helper_bargraph_plot_v10
    
end




% ==========
% Save data
% ==========

if fig_plot_on == 1
    
    plot_set.figure_size = fig_size;
    plot_set.figure_save_name = sprintf ('%s_fig%s', settings.neuron_name, num2str(settings.figure_current));
    plot_set.path_figure = path_fig;
    
    plot_helper_save_figure;
    close all;
    
end
