% Prepare each figure

% close all;

error_code_current = 'correct';
extended_title = 0;
memory_angles_subset = [0, -180];


%% Accumulate data over units

%==============
% Data
data_mat = struct;
data_mat.mat1_ini = mat2_ini;
data_mat.var1{1} = S.memory_angle_relative;
data_mat.var1_match{1} = memory_angles_subset;
data_mat.var1{2} = S.esetup_block_cond;
data_mat.var1_match{2} = task_names_used;
data_mat.var1{3} = S.esetup_background_texture_on(:,1);
data_mat.var1_match{3} = texture_on_used;
data_mat.var1{4} = S.edata_error_code;
data_mat.var1_match{4} = error_code_current;
settings.bootstrap_on = 0;

[data_mat_ini_single, ~, ~, ~] = look6_helper_indexed_selection(data_mat, settings);

% Initialize data matrix to concatenate all data
% One channel - one row;
% One day - as many rows as there are channels;
if settings.channel_current == settings.channels_used(1)
    [~,n,o,p,q] = size(data_mat_ini_single);
    data_mat_ini_comb = NaN(1, n, o, p, q);
    data_mat_ini_date = NaN(1,1);
end

% Increase matrix size if current recording has more time bins than earlier
% recordings
[~, n, ~, ~, ~] = size(data_mat_ini_single);
[p, q, r, s, t] = size(data_mat_ini_comb);
if q < n
    temp1 = NaN(p, n, r, s, t);
    temp1_upper = NaN(p, n, r, s, t);
    temp1_lower = NaN(p, n, r, s, t);
    for r1 = 1:r
        for s1 = 1:s
            for t1 = 1:t
                temp1(:,1:q, r1, s1, t1) = data_mat_ini_comb(:,:,r1, s1, t1);
            end
        end
    end
    data_mat_ini_comb = temp1;
    clear temp1;
end

% Save averages into data_mat_ini_comb
[p, q, r, s, t] = size(data_mat_ini_comb);
for r1 = 1:r
    for s1 = 1:s
        for t1 = 1:t
            data_mat_ini_comb(p+1,:,r1,s1,t1)= data_mat_ini_single(1,:,r1,s1,t1);
        end
    end
end
% Save the data
data_mat_ini_date(p+1,1) = settings.date_current;


%% Axis limits for a given day

if settings.channel_current == settings.channels_used(end)
    
    index = data_mat_ini_date == settings.date_current;
    mat_y_upper = data_mat_ini_comb(index,:);
    mat_y_lower = data_mat_ini_comb(index,:);
    
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
    
    % Save output
    all_fig_y_lim = plot_set.ylim;
    
    %=================
    % Y limits for difference figure
    
    % Select data
    ind1 = data_mat_ini_date == settings.date_current; % Select current date
    mat_y_temp = NaN(sum(ind1), 2, 2);
        
    % Look data
    ind2 = find(strcmp(task_names_used, 'look'));
    if ~isempty(ind2)
        t1 = data_mat_ini_comb(ind1, :, :, ind2, :);
        mat_y_temp(:,1,:) = t1(:,1,1,:)-t1(:,1,2,:); % Calculate cued-uncued difference
    end

    % Avoid data
    ind2 = find(strcmp(task_names_used, 'avoid'));
    if ~isempty(ind2)
        t1 = data_mat_ini_comb(ind1, :, :, ind2, :);
        mat_y_temp(:,2,:) = t1(:,1,1,:)-t1(:,1,2,:); % Calculate cued-uncued difference
    end

    %===============
    % Determine axis limits
    % Initialize structure with data
    plot_set = struct;
    plot_set.ebars_lower_y = mat_y_temp;
    plot_set.ebars_upper_y = mat_y_temp;
    look6_helper_data_limits;
        
    % Add buffer on the axis
    val1_min = 0.05;
    val1_max = 0.05;
    h0_min = plot_set.ylim(1);
    h0_max = plot_set.ylim(2);
    plot_set.ylim(1) = h0_min - ((h0_max - h0_min) * val1_min);
    plot_set.ylim(2) = h0_max + ((h0_max - h0_min) * val1_max);
    
    fig_lim = plot_set.ylim;
    
end


%================
% Figure size

fig_subplot_dim = [numel(texture_on_used), numel(task_names_used)+1];
fig_size = [0, 0, fig_subplot_dim(2) * settings.figsize_1col(4), fig_subplot_dim(1) * settings.figsize_1col(3)];

extended_title = 0; % Initialize


%% PLOT FIGURES

if settings.channel_current == settings.channels_used(end)
    
    for i_fig1 = 1:numel(task_names_used)
        
        task_name_current = task_names_used{i_fig1};
        fprintf('\n%s: preparing panel for the "%s" task \n', settings.neuron_name, task_name_current)
        
        for i_fig2 = 1:numel(texture_on_used)
            
            texture_on_current = texture_on_used(i_fig2);
            fprintf('\n%s: preparing panel for the texture on = %s, "%s" task \n', settings.neuron_name, num2str(texture_on_current), task_name_current);
            
            % Select data
            ind1 = data_mat_ini_date == settings.date_current; % Select current date
            mat_y = data_mat_ini_comb(ind1, :, :, i_fig1, i_fig2);
            
            %================
            % Is there any data to plot?
            fig_plot_on = sum(sum(isnan(mat_y))) ~= numel(mat_y);
            
            if fig_plot_on == 1
                
                % Initialize figure sub-panel
                a = i_fig2 * (fig_subplot_dim(2)) - (fig_subplot_dim(2));
                b = a + i_fig1;
                hfig = subplot(fig_subplot_dim(1), fig_subplot_dim(2), b);
                hold on;
                fprintf('\n%s: preparing panel for the texture on = %s, "%s" task \n', settings.neuron_name, num2str(texture_on_current), task_name_current);
                
                axis 'equal';
                
                plot_set = struct;
                
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
                
                if texture_on_current==1
                    t1_temp = 'texture on';
                elseif texture_on_current==0
                    t1_temp = 'no texture';
                end
                
                % Figure title
                plot_set.figure_title = sprintf('%s, %s', task_name_current, t1_temp);
                
                if extended_title == 0
                    plot_set.xlabel = 'Opposite location';
                    plot_set.ylabel = 'Cued location';
                    extended_title = 1;
                end
                plot_set.ylim = all_fig_y_lim;
                plot_set.xlim = all_fig_y_lim;
                
                % Plot
                plot_helper_line_plot_v10;
                
                % Plot unity line
                h = plot(plot_set.xlim, plot_set.ylim, '-');
                set (h(end), 'LineWidth', settings.wlineerror , 'Color', [0.2,0.2,0.2])
                
                % Plot each marker
                for j=1:size(mat_y,1)
                    
                    h=plot(mat_y(j,2), mat_y(j,1));
                    
                    graphcond = plot_set.data_color;
                    set (h(end), 'Marker', settings.marker_type{graphcond}, 'MarkerFaceColor', settings.color1(graphcond,:), ...
                        'MarkerEdgeColor', 'none', 'MarkerSize', 6)
                end
                
            end
            % End of checking whether to plot data
        end
        % End of texture on
    end
    % End of look/avoid task
    
end
% Plot only if all channels have been analyzed


%% Plot benefit/cost combined panel

if settings.channel_current == settings.channels_used(end)
    
    for i_fig1 = 1:numel(texture_on_used)
        
        texture_on_current = texture_on_used(i_fig1);
        
        % Select data
        ind1 = data_mat_ini_date == settings.date_current; % Select current date
        mat_y_temp = NaN(sum(ind1), 2);
        
        % Look data
        ind2 = find(strcmp(task_names_used, 'look'));
        if ~isempty(ind2)
            t1 = data_mat_ini_comb(ind1, :, :, ind2, i_fig1);
            mat_y_temp(:,1) = t1(:,1,1)-t1(:,1,2); % Calculate cued-uncued difference
        end
        
        % Avoid data
        ind2 = find(strcmp(task_names_used, 'avoid'));
        if ~isempty(ind2)
            t1 = data_mat_ini_comb(ind1, :, :, ind2, i_fig1);
            mat_y_temp(:,2) = t1(:,1,1)-t1(:,1,2); % Calculate cued-uncued difference
        end
        
        % Determine date used (x axis)
        a = 1;
        mat_x = [a-0.2, a+0.2];
        
        %================
        % Is there any data to plot?
        
        fig_plot_on = sum(sum(isnan(mat_y_temp))) ~= numel(mat_y_temp);
        
        if fig_plot_on == 1
            
            % Initialize figure sub-panel
            a = i_fig1 * (fig_subplot_dim(2)) - (fig_subplot_dim(2));
            b = a + (fig_subplot_dim(2));
            hfig = subplot(fig_subplot_dim(1), fig_subplot_dim(2), b);
            hold on;
            fprintf('\n%s: preparing panel for the texture on = %s, all tasks \n', settings.neuron_name, num2str(texture_on_current));
                        
            %===============
            % Plot individual channels
            
            % Plot each marker
            for j = 1:size(mat_y_temp,1)
                for k = 1:size(mat_y_temp, 2)
                    
                    if k==1
                        graphcond = 1;
                    elseif k==2
                        graphcond = 2;
                    end
                    
                    h=plot(mat_x(k), mat_y_temp(j,k));
                    
                    set (h(end), 'Marker', settings.marker_type{graphcond}, 'MarkerFaceColor', settings.color1(graphcond,:), ...
                        'MarkerEdgeColor', 'none', 'MarkerSize', 6)
                end
            end
            
            % Plot each line
            plot_set = struct;
            plot_set.data_color = [0.5, 0.5, 0.5];
            plot_set.mat_y = mat_y_temp;
            plot_set.mat_x = mat_x;
            
            % Plot
            plot_helper_line_plot_v10;

               
            % ============
            % Plot averages
            
            plot_set = struct;
            
            plot_set.mat_x = mat_x;
            if size(mat_y_temp, 1)==1
                plot_set.mat_y = mat_y_temp;
            else
                plot_set.mat_y = nanmean(mat_y_temp);
            end
                
            plot_set.data_color = [0.2, 0.2, 0.2];
            
            if texture_on_current==1
                t1_temp = 'texture on';
            elseif texture_on_current==0
                t1_temp = 'no texture';
            end
            
            plot_set.ylabel = 'cue in - cue out';
            
            plot_set.xlim = [0.6, 1.4];
            plot_set.xtick = 'none';
            plot_set.ylim = fig_lim;
            
            % Figure title
            plot_set.figure_title = sprintf('%s', t1_temp);
            
            % Plot
            plot_helper_line_plot_v10;
            
            
        end
        % End of checking whether to plot data
    end
    % End of panel for each texture
end
% If last channel is used

%% Save data

%==========
% Save data
%==========

if settings.channel_current == settings.channels_used(end)
    
    if fig_plot_on == 1
        
        plot_set.figure_size = fig_size;
        plot_set.figure_save_name = sprintf ('ch_all_fig%s', num2str(settings.figure_current));
        plot_set.path_figure = path_fig;
        
        plot_helper_save_figure;
        close all;
        
    end
end
