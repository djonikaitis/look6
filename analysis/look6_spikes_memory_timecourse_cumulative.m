
close all;

task_names_used = unique(S.esetup_block_cond);
orientations_used = unique(S.esetup_background_texture_line_angle(:,1));
texture_on_used = [1,0];
memory_angles_used = unique(S.memory_angle);

temp1 = [];
m1 = memory_angles_used<-90;
t1 = memory_angles_used(m1);
temp1(1) = t1(1);
m1 = memory_angles_used>0 & memory_angles_used<90;
t1 = memory_angles_used(m1);
temp1(2) = t1(1);
memory_angles_used = temp1;

%% Calculate axis limits

% Matrices
i = numel(memory_angles_used);
j = numel(task_names_used);
k = numel(texture_on_used);
mat_y = NaN(1, numel(settings.plot_bins), i, j, k);
test1 = NaN(1, i, j, k);
mat_y_lower = NaN(1,numel(settings.plot_bins), i, j, k);
mat_y_upper =  NaN(1,numel(settings.plot_bins), i, j, k);

for i = 1:numel(memory_angles_used)
    for j = 1:numel(task_names_used)
        for k = 1:numel(texture_on_used)
            
            memory_angle_current = memory_angles_used(i);
            task_name_current = task_names_used(j);
            texture_on_current = texture_on_used(k);
            
            % Get index
            index = S.esetup_background_texture_on(:,1) == texture_on_current & ...
                S.memory_angle == memory_angle_current & ...
                strcmp(S.esetup_block_cond, task_name_current) & ...
                strncmp(S.edata_error_code, 'correct', 7);
            temp1 = mat1_ini(index,:);
            test1(1,i,j,k) = sum(index);
            
            % Get means
            a = [];
            if sum(index)>1
                a = nanmean(temp1);
            elseif sum(index) == 1
                a = temp1;
            end
            [n] = numel(a);
            mat_y(1,1:n,i,j,k) = a;
            
            % Get error bars
            settings.bootstrap_on = 0;
            a = plot_helper_error_bar_calculation_v10(temp1, settings);
            try
                mat_y_upper(1,:,i,j,k)= a.se_upper;
                mat_y_lower(1,:,i,j,k)= a.se_lower;
            end
            settings = rmfield (settings, 'bootstrap_on');
            
        end
    end
end

% Reshape matrixes to know numbers of trials
[m,n,o,q,r,s] = size(mat_y_upper);
a = reshape(mat_y_lower, m, n, o*q*r*s);
b = reshape(mat_y_upper, m, n, o*q*r*s);

[m,n,o,q,r,s] = size(test1);
test1 = reshape(test1, m, n*o*q*r*s);

% Initialize structure with data
plot_set = struct;
plot_set.ebars_lower_y = a;
plot_set.ebars_upper_y = b;
look6_helper_data_limits;

% Count the rasters
val1_min = 0.05;
val1_max = 0.05;
h0_min = plot_set.ylim(1);
h0_max = plot_set.ylim(2);
plot_set.ylim(1) = h0_min - ((h0_max - h0_min) * val1_min);
plot_set.ylim(2) = h0_max + ((h0_max - h0_min) * val1_max);

% Save output
all_fig_y_lim = plot_set.ylim;

% Figure size
fig_subplot_dim = [numel(texture_on_used), numel(task_names_used)+1];
fig_size = [0, 0, fig_subplot_dim(2)*2.2, fig_subplot_dim(1)*2.2];

extended_title = 0; % Initialize


%% Work on each panel

for i_fig1 = 1:numel(task_names_used)
    
    task_name_current = task_names_used{i_fig1};
    fprintf('\nPreparing panel for the "%s" task \n', task_name_current)
    
    for i_fig2 = 1:numel(texture_on_used)
        
        texture_on_current = texture_on_used(i_fig2);
        
        %==============
        % Plot each subplot
        
        % Data
        var1 = memory_angles_used;
        mat_y = NaN(1, numel(settings.plot_bins), numel(var1));
        test2 = NaN(1, numel(var1));
        mat_y_lower = NaN(1,numel(settings.plot_bins), numel(var1));
        mat_y_upper =  NaN(1,numel(settings.plot_bins), numel(var1));
        
        % For each location
        for i = 1:numel(memory_angles_used)
            
            memory_angle_current = memory_angles_used(i);
            
            % Get index
            index = S.esetup_background_texture_on(:,1) == texture_on_current & ...
                S.memory_angle == memory_angle_current & ...
                strcmp(S.esetup_block_cond, task_name_current) & ...
                strncmp(S.edata_error_code, 'correct', 7);
            temp1 = mat1_ini(index,:);
            test2(1,i) = sum(index);
            
            % Get means
            a = [];
            if sum(index)>1
                a = nanmean(temp1);
            elseif sum(index) == 1
                a = temp1;
            end
            [n] = numel(a);
            mat_y(1,1:n,i) = a;
            
            
            % Get error bars
            settings.bootstrap_on = 0;
            a = plot_helper_error_bar_calculation_v10(temp1, settings);
            try
                mat_y_upper(1,:,i)= a.se_upper;
                mat_y_lower(1,:,i)= a.se_lower;
            end
            settings = rmfield (settings, 'bootstrap_on');
            
        end
        
        %================
        % Is there any data to plot?
        fig_plot_on = sum(test2);
        
        if fig_plot_on > 0 % Decide whether to bother initializing a panel
            
            % Initialize figure panel
            a = i_fig2 * (numel(task_names_used)+1) - (numel(task_names_used)+1);
            b = a + i_fig1;
            hfig = subplot(fig_subplot_dim(1), fig_subplot_dim(2), b);
            hold on;
            fprintf('\nPreparing panels %s for the texture on = %s, "%s" task \n', num2str(i_fig1), num2str(texture_on_current), task_name_current);
            
            plot_set = struct;
            
            % Colors
            if strcmp(task_name_current, 'look')
                plot_set.data_color_min = [1];
            elseif strcmp(task_name_current, 'avoid')
                plot_set.data_color_min = [2];
            elseif strcmp(task_name_current, 'control fixate')
                plot_set.data_color_min = [4];
            else
                plot_set.data_color = [0.1, 0.1, 0.1];
            end
            
            if texture_on_current==1
                t1_temp = 'texture on';
            elseif texture_on_current==0
                t1_temp = 'no texture';
            end
            
            % Figure title
            plot_set.figure_title = sprintf('%s, %s', task_name_current, t1_temp);
            
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
            plot_set.data_color_max = 10;
            
            % Labels for plotting
            if extended_title == 0
                plot_set.xlabel = 'Time after cue, ms';
                plot_set.ylabel = 'Firing rate, Hz';
                extended_title = 1;
            end
            
            % Plot
            plot_helper_basic_line_figure;
            
        end
        % End of checking whether data exists for plotting
        
    end
    % End of texture on/off
    
    %===============
    % Plot inset with probe locations
    
    if fig_plot_on > 0 % Decide whether to bother initializing a panel
        
        if i_fig1==1
            axes('Position',[0.93,0.92,0.04,0.04])
        elseif i_fig1==2
            axes('Position',[0.93,0.80,0.04,0.04])
        elseif i_fig1==3
            axes('Position',[0.93,0.68,0.04,0.04])
        end
        
        axis 'equal'
        set (gca, 'Visible', 'off')
        hold on;
        
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
        for i=1:length(memory_angles_used)
            
            % Color
            graphcond = i;
            
            % Find coordinates of a line
            f_rad = 1;
            f_arc = memory_angles_used(i);
            [xc,yc] = pol2cart(f_arc*pi/180, f_rad);
            objsize = 0.7;
            
            % Plot cirlce
            h=rectangle('Position', [xc(1)-objsize(1)/2, yc(1)-objsize(1)/2, objsize(1), objsize(1)],...
                'EdgeColor', plot_set.main_color(i,:), 'FaceColor', plot_set.main_color(i,:),'Curvature', 0, 'LineWidth', 1);
            
        end
        
        % Cue location
        m = find((memory_angles_used)<-90);
        if numel(m)>1
            m=m(1);
        end
        text(0, -2, 'Cue in RF', 'Color', plot_set.main_color(m,:),  'FontSize', settings.fontszlabel, 'HorizontalAlignment', 'center')
        %==============
        % End of inset
        
    end
    
end
% End of look/avoid

%===============
% Plot inset with probe locations

if i_fig1==1
    axes('Position',[0.93,0.92,0.04,0.04])
elseif i_fig1==2
    axes('Position',[0.93,0.80,0.04,0.04])
elseif i_fig1==3
    axes('Position',[0.93,0.68,0.04,0.04])
end

axis 'equal'
set (gca, 'Visible', 'off')
hold on;

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
for i=1:length(memory_angles_used)
    
    % Color
    graphcond = i;
    
    % Find coordinates of a line
    f_rad = 1;
    f_arc = memory_angles_used(i);
    [xc,yc] = pol2cart(f_arc*pi/180, f_rad);
    objsize = 0.7;
    
    % Plot cirlce
    h=rectangle('Position', [xc(1)-objsize(1)/2, yc(1)-objsize(1)/2, objsize(1), objsize(1)],...
        'EdgeColor', plot_set.main_color(i,:), 'FaceColor', plot_set.main_color(i,:),'Curvature', 0, 'LineWidth', 1);
    
end

% Cue location
m = find((memory_angles_used)<-90);
if numel(m)>1
    m=m(1);
end
text(0, -2, 'Cue in RF', 'Color', plot_set.main_color(m,:),  'FontSize', settings.fontszlabel, 'HorizontalAlignment', 'center')
%==============
% End of inset



%% Plot 2

for i_fig2 = 1:numel(texture_on_used)
    
    texture_on_current = texture_on_used(i_fig2);
    
    %==============
    % Plot each subplot
    
    % Data
    var1 = memory_angles_used;
    var2 = task_names_used;
    mat_y = NaN(1, numel(settings.plot_bins), numel(var2), numel(var1));
    test2 = NaN(1, numel(var2), numel(var1));
    mat_y_lower = NaN(1,numel(settings.plot_bins), numel(var2), numel(var1));
    mat_y_upper =  NaN(1,numel(settings.plot_bins), numel(var2), numel(var1));
    
    % For each location
    for i = 1:numel(memory_angles_used)
        for j=1:numel(task_names_used)
            
            memory_angle_current = memory_angles_used(i);
            task_name_current = task_names_used{j};
            
            % Get index
            index = S.esetup_background_texture_on(:,1) == texture_on_current & ...
                S.memory_angle == memory_angle_current & ...
                strcmp(S.esetup_block_cond, task_name_current) & ...
                strncmp(S.edata_error_code, 'correct', 7);
            temp1 = mat1_ini(index,:);
            test2(1,j,i) = sum(index);
            
            % Get means
            a = [];
            if sum(index)>1
                a = nanmean(temp1);
            elseif sum(index) == 1
                a = temp1;
            end
            [n] = numel(a);
            mat_y(1,1:n,j,i) = a;
            
            
            % Get error bars
            settings.bootstrap_on = 0;
            a = plot_helper_error_bar_calculation_v10(temp1, settings);
            try
                mat_y_upper(1,:,j,i)= a.se_upper;
                mat_y_lower(1,:,j,i)= a.se_lower;
            end
            settings = rmfield (settings, 'bootstrap_on');
            
        end
    end
    
    %     % Normalize relative to first time bin
    %     for i = 1:size(mat_y,3)
    %         for j = 1:size(mat_y,4)
    %             ind2 = 1:3;
    %             a = nanmean(mat_y(:,ind2,i,j));
    %             mat_y(:,:,i,j) = mat_y(:,:,i,j)./a;
    %         end
    %     end
    
    % Remove some bins
    index = settings.plot_bins<500;
    for i = 1:size(mat_y,3)
        for j = 1:size(mat_y,4)
            mat_y(:,index,i,j) = NaN;
        end
    end
    
    % Recalculate as a difference
    [m,n,o,p] = size(mat_y);
    mat_temp1 = NaN(m,n,o);
    for i = 1:size(mat_y,3)
        a = mat_y(:,:,i,1)-mat_y(:,:,i,2);
        mat_temp1(1,:,i) = cumsum(a, 'omitnan');
    end
    
    
    %================
    % Is there any data to plot?
    fig_plot_on = sum(sum(test2));
    
    if fig_plot_on > 0 % Decide whether to bother initializing a panel
        
        % Initialize figure panel
        a = i_fig2 * (numel(task_names_used)+1) - (numel(task_names_used)+1);
        b = a + numel(task_names_used)+1;
        hfig = subplot(fig_subplot_dim(1), fig_subplot_dim(2), b);
        hold on;
        fprintf('\nPreparing panels %s for the texture on = %s \n', num2str(i_fig1), num2str(texture_on_current));
        
        plot_set = struct;
        
        % Colors
        c1 = NaN(numel(task_names_used), 1);
        ind = strcmp(task_names_used, 'look');
        if (sum(ind))==1
            c1(ind) = 1;
        end
        ind = strcmp(task_names_used, 'avoid');
        if (sum(ind))==1
            c1(ind) = 2;
        end
        ind = strcmp(task_names_used, 'control fixate');
        if (sum(ind))==1
            c1(ind) = 4;
        end
        plot_set.data_color = c1;
        
        if texture_on_current==1
            t1_temp = 'texture on';
        elseif texture_on_current==0
            t1_temp = 'no texture';
        end
        
        % Figure title
        plot_set.figure_title = sprintf('%s', t1_temp);
        
        %===============
        % Averages data
        % Initialize structure with data
        plot_set.mat_y = mat_temp1;
        plot_set.mat_x = settings.plot_bins;
        plot_set.ebars_shade = 1;
        
        % Labels for plotting
        plot_set.xlabel = 'Time after cue, ms';
        plot_set.ylabel = '(in RF - out RF) cummulative sum';
        plot_set.legend = task_names_used;
        
        % Plot
        plot_helper_basic_line_figure;
        
    end
    % End of checking whether data exists for plotting
    
end
% End of texture on/off



%% Save data

%==========
% Save data
%==========

if fig_plot_on>0
    
    
    % Save data
    plot_set.figure_size = fig_size;
    plot_set.figure_save_name = sprintf ('%s_fig%s', settings.neuron_name, num2str(settings.figure_current));
    plot_set.path_figure = path_fig;
    
    plot_helper_save_figure;
    close all;
    
end
