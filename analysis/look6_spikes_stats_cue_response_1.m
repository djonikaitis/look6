
close all; 

error_code_current = 'correct';

% Figure size
fig_subplot_dim = [1, 3];
fig_size = [0, 0, fig_subplot_dim(2) * settings.figsize_1col(3), fig_subplot_dim(1) * settings.figsize_1col(4)];
current_subplot = 0;


%% Calculate visual selectivity

selectivity_found = 0;
rf1 = struct;

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
stats_mat = NaN(numel(var1), numel(var1));
for i = 1:size(mtbl1, 1)
    m = mtbl1(i,1);
    n = mtbl1(i,2);
    a = mtbl1(i,6);
    if a<=0.05
        stats_mat(m,n) = 1;
        stats_mat(n,m) = 1;
    elseif a>0.05
        stats_mat(m,n) = 0;
        stats_mat(n,m) = 0;
    end
end

% Calculate location relative to memory
v2 = nansum(stats_mat);
% Look for RFs that are localized within one quadrant
loc_ind = find(v2==numel(v2)-1);

% Which location shows memory response?
if ~isempty(loc_ind) && numel(loc_ind)==1
    a = memory_angles_used(loc_ind);
    rf1.memory_rf = a;
    selectivity_found = 1;
else
    a = min(memory_angles_used);
    rf1.memory_rf = 'none';
    selectivity_found = 0;
end

% Reset memory arc relative to RF center
temp1 = NaN(numel(S.session), 1);
for i = 1:max(S.session)
    index = S.session == i;
    temp1(index) = S.memory_angle(index) - a;
end
% Round off
temp1 = round(temp1, 1);
% Reset to range -180:180
ind = temp1<=-180;
temp1(ind)=temp1(ind)+360;
ind = temp1>180;
temp1(ind)=temp1(ind)-360;

rf1.memory_angle_relative = temp1;
memory_angles_relative_used = unique(removeNaN(rf1.memory_angle_relative));

temp1 = sprintf('_%s_rf.mat', settings.neuron_name);
[p1, p2, file_name] = get_generate_path_v10(settings, 'data_combined_rf1', temp1, settings.session_current);
if ~isdir(p2)
    mkdir(p2);
end
save (p1, 'rf1')


%% Calculate colors

if  selectivity_found == 1
    col_min = settings.color1(9,:);
    col_max = settings.color1(10,:);
    n = numel(memory_angles_used);
else
    col_min = settings.color1(12,:);
    col_max = settings.color1(10,:);
    n = numel(memory_angles_used);
end

% Other location colors are calculated as a range
temp_c = [];
if n>1
    d1 = col_max-col_min;
    stepsz = 1/(n-1);
    for i=1:n
        temp_c(i,:)=col_min + (d1*stepsz)*(i-1);
    end
else
    temp_c(1,:)=col_min;
end

% Re-order colors to match recorded memory locations
v1 = memory_angles_relative_used;
v1 = memory_angles_used;
if selectivity_found == 1
    v2 = v1 - rf1.memory_rf;
else
    v2 = v1 - min(memory_angles_used);
end
v2(v2<=-180) = v2(v2<=-180)+360;
v2(v2>180) = v2(v2>180)-360;
v3 = abs(v2);
[v4,ind] = sort(v3, 'ascend');

temp_color1 = NaN(numel(v1), 3);
for i = 1:numel(ind)
    temp_color1(ind(i),:) = temp_c(i,:);
end



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
        
        if selectivity_found==1
            r1 = [1:2];
        else
            r1 = 1;
        end
        
        
        for fig_rep1 = r1
            
            % Initialize figure sub-panel
            current_subplot = current_subplot + 1;
            hfig = subplot(fig_subplot_dim(1), fig_subplot_dim(2), current_subplot);
            hold on;
            
            plot_set = struct;
            plot_set.mat_y = temp1;
            plot_set.ebars_lower_y = temp1_lower;
            plot_set.ebars_upper_y = temp1_upper;
            
            
            if fig_rep1 == 1
                plot_set.data_color_min = [0.2, 0.2, 0.2];
                plot_set.data_color_max = [0.8, 0.8, 0.8];
                plot_set.figure_title = ['Raw data'];
                plot_set.xlabel = 'Cue loc on the screen';
            else
                plot_set.data_color = temp_color1;
                plot_set.figure_title = ['RF data'];
                plot_set.xlabel = 'Cue loc relative to RF';
            end
            plot_set.val1_max_y = 0.5; % This is due to the need to show statistics
            plot_set.val1_min_y = 0.4; % This is due to the need to show statistics

            if fig_rep1 == 2
                v1 = memory_angles_relative_used;
                v1 = memory_angles_used;
                v2 = v1 - rf1.memory_rf;
                v2(v2<=-180) = v2(v2<=-180)+360;
                v2(v2>180) = v2(v2>180)-360;
                for i = 1:numel(v2)
                    plot_set.legend{i} = [num2str(round(v2(i)))];
                end
                plot_set.legend_color = [0.9, 0.9, 1];
            end
            
            plot_set.ylabel = 'Spikes/s';
            plot_set.xtick = 'none';
            
            plot_helper_bargraph_plot_v10
            
            % Add statistics values
            if fig_rep1 == 1
                
                for i = 1:size(stats_mat,1)
                    s1 = stats_mat(i,:);
                    x1 = plot_set.mat_x(i);
                    rng = plot_set.ylim(2) - plot_set.ylim(1);
                    y0 = plot_set.ebars_upper_y(i);
                    for j = 1:numel(s1)
                        y1 = y0 + rng*j*0.06;
                        if s1(j)==0
                            l1 = ['ns'];
                        elseif s1(j)==1
                            l1 = ['*'];
                        else
                            l1 = [' '];
                        end
                        c1 = plot_set.main_color(j,:);
                        text(x1, y1, l1,...
                            'Color', c1, 'FontSize', plot_set.font_size_label, 'HorizontalAlignment', 'center', 'Rotation', 0);
                        
                    end
                end
                
            end
            
        end
        
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

