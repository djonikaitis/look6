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


%% Figures calculations

for fig1 = 1:numel(num_fig) % Plot figures
    
    settings.figure_current = num_fig(fig1);
    fprintf('\nPreparing figure %s out of %s total for this analysis\n', num2str(fig1), num2str(numel(num_fig))  )
    
    %=============
    % Load data or calculate data?
    
    % Over-write spike rates?
    if fig1==1
        new_mat = 1;
    else
        new_mat = 0;
    end
    
    % Try to load the data for given analysis
    temp1 = sprintf('_%s_pre_fixation.mat', settings.neuron_name);
    [path1, path1_short, file_name] = get_generate_path_v10(settings, 'figures', temp1, settings.session_current);
    if isfile (path1)
        fprintf ('Skippind data binning and loading "%s"\n', file_name)
        data_mat = get_struct_v11(path1);
        mat1_ini = data_mat.mat1_ini;
        plot_bins_start = data_mat.plot_bins_start;
        plot_bins_end = data_mat.plot_bins_end;
        mat2_ini = data_mat.mat2_ini; % Get long (summary) bins
        new_mat = 0;
        clear data_mat;
    end
    
    % Initialize few variables
    settings.int_bins = settings.intervalbins_tex;
    settings.bin_length = settings.bin_length_long;
    if isfield(S, 'texture_on_1')
        S.tconst = S.texture_on_1 - S.first_display;
    else
        S.tconst = (S.edata_background_texture_onset_time(:,1) - S.edata_first_display(:,1))*1000;
    end
    
    % Remove bins after memory delay
    a = prctile(S.esetup_memory_delay*1000, 75);
    settings.int_bins(settings.int_bins + settings.bin_length > a) = [];
    
    % plot_bins
    settings.plot_bins=settings.int_bins+settings.bin_length/2;
    
    %===============
    % Select appropriate time interval for spike binning
    
    if new_mat == 1
        
        % Create a matrix with plot_bins
        int_bins = settings.int_bins;
        bin_length = settings.bin_length;
        t_dur = (S.edata_fixation_off - S.edata_memory_on) * 1000;
        
        look6_helper_int_bins_calculator;
        
        %==================
        % Calculate long time bins
        
        plot_bins_start2 = NaN(numel(t_dur), 1); % Output matrix
        plot_bins_end2 = NaN(numel(t_dur), 1); % Output matrix
        
        plot_bins_start2(:,1) = 0;
        plot_bins_end2(:,1) = 250;
        
    end
    
    %============
    % Find spikes
    
    if new_mat==1 % This decides whether to over_write the calculated data matrix
        
        % Spikes and events
        t1_spike = spikes1.ts; % Initialize spike timing
        t1_evt = events_mat.msg_1; % Get timing of the events
        t1_evt = t1_evt + S.tconst; % Reset to time relative to tconst
        
        % Calculate spiking rates
        mat1_ini = look6_helper_spike_binning(t1_spike, t1_evt, plot_bins_start, plot_bins_end);
        
        % Calculate long time bin rates
        mat2_ini = look6_helper_spike_binning(t1_spike, t1_evt, plot_bins_start2, plot_bins_end2);
        
        % Save data
        d1 = struct;
        d1.mat1_ini = mat1_ini;
        d1.plot_bins_start = plot_bins_start;
        d1.plot_bins_end = plot_bins_end;
        d1.plot_bins = settings.plot_bins;
        d1.mat2_ini = mat2_ini;
        save (path1, 'd1')
        clear d1;
        fprintf ('Saved binned data as new file "%s"\n', file_name)
        
    end
    
    
    %% Plot data
    
    
    if settings.figure_current==1
        
        close all;
        
        error_code_current = 'correct';
        
        %================
        % Figure size
        
        fig_subplot_dim = [1, 3];
        fig_size = [0, 0, fig_subplot_dim(2) * settings.figsize_1col(3), fig_subplot_dim(1) * settings.figsize_1col(4)];
        
        extended_title = 0; % Initialize
        
        texture_on_current = 1;
        
        %==============
        % Data
        data_mat = struct;
        data_mat.mat1_ini = mat1_ini;
        data_mat.var1{1} = S.esetup_block_cond;
        data_mat.var1_match{1} = task_names_used;
        data_mat.var1{2} = S.esetup_background_texture_on(:,1);
        data_mat.var1_match{2} = texture_on_current;
        data_mat.var1{3} = S.edata_error_code;
        data_mat.var1_match{3} = error_code_current;
        settings.bootstrap_on = 0;
        
        [mat_y, mat_y_upper, mat_y_lower, ~] = look6_helper_indexed_selection(data_mat, settings);
        
        %================
        % Is there any data to plot?
        
        fig_plot_on = sum(sum(isnan(mat_y))) ~= numel(mat_y);
        
        %===============
        % Subplot 1
        %================
        
        if fig_plot_on > 0 % Decide whether to bother initializing a panel
            
            plot_set = struct;
            
            hfig = subplot(fig_subplot_dim(1), fig_subplot_dim(2), 1);
            hold on;
            fprintf('\n%s: preparing panel for all tasks combined \n', settings.neuron_name);
            
            % Colors
            plot_set.data_color = NaN(1, numel(task_names_used));
            ind1 = strcmp(task_names_used, 'look');
            if ~isempty(ind1)
                plot_set.data_color(ind1) = [1];
            end
            ind1 = strcmp(task_names_used, 'avoid');
            if ~isempty(ind1)
                plot_set.data_color(ind1) = [2];
            end
            ind1 = strcmp(task_names_used, 'control fixate');
            if ~isempty(ind1)
                plot_set.data_color(ind1) = [4];
            end
            
            % Figure title
            plot_set.figure_title = sprintf('Average response for each task');
            
            %===============
            % Averages data
            % Initialize structure with data
            plot_set.mat_y = mat_y;
            plot_set.mat_x = settings.plot_bins;
            plot_set.ebars_lower_y = mat_y_lower;
            plot_set.ebars_upper_y = mat_y_upper;
            plot_set.ebars_shade = 1;
            
            % Labels for plotting
            plot_set.xlabel = 'Time after texture, ms';
            plot_set.ylabel = 'Firing rate, Hz';
            plot_set.legend = task_names_used;
            
            % Plot
            plot_helper_line_plot_v10;
            
        end
        
        %================
        % Subplot 2 and 3
        %================
        
        if fig_plot_on > 0 % Decide whether to bother initializing a panel
            
            for i_fig = 2:3
                
                hfig = subplot(fig_subplot_dim(1), fig_subplot_dim(2), i_fig);
                hold on;
                fprintf('\n%s: preparing panel for smoothed responses over time \n', settings.neuron_name);
                
                %===========
                % Plot blocked conditions
                
                % Correct block_number variable
                block_no = S.esetup_block_no;
                if max(S.session)>1
                    for i = 2:max(S.session)
                        ind = find(S.session==i);
                        block_no(ind) = block_no(ind) + block_no(ind(1)-1);
                    end
                end
                
                %============
                % Plot each block color
                for i=1:max(block_no)
                    
                    % Select current block
                    indBl = find(block_no==i);
                    
                    if ~isempty(indBl)
                        
                        % Define coordinates of the square
                        x1 = indBl(1);
                        x2 = (indBl(end)-indBl(1))+1;
                        y1 = 0; y2 = 3000;
                        
                        % Which conditiopn is it
                        task_name_current = unique(S.esetup_block_cond(indBl));
                        
                        % Color
                        if strcmp(task_name_current, 'look')
                            ind2 = strcmp(task_names_used, 'look');
                            color1 = plot_set.shade_color(ind2,:);
                        end
                        if strcmp(task_name_current, 'avoid')
                            ind2 = strcmp(task_names_used, 'avoid');
                            color1 = plot_set.shade_color(ind2,:);
                        end
                        if strcmp(task_name_current, 'control fixate')
                            ind2 = strcmp(task_names_used, 'control fixate');
                            color1 = plot_set.shade_color(ind2,:);
                        end
                        
                        h = rectangle('Position', [x1, y1, x2, y2], 'FaceColor', color1, 'EdgeColor', 'none');
                    end
                end
            end
            %==============
            
            
            % Subplot 2
            %===========
            % Spikes over time
            %===========
            
            hfig = subplot(fig_subplot_dim(1), fig_subplot_dim(2), 2);
            hold on;
            
            % Initialize matrices
            int_bins_dur = 50;
            int_bins = 1:numel(S.session)-int_bins_dur;
            
            % Plot bins
            pbins = [];
            for i = 1:numel(int_bins)
                pbins(i) = int_bins(i) + int_bins_dur/2;
            end
            
            % Ini mat
            mat_y = NaN(1, numel(int_bins)-1);
            mat_y_lower = NaN(1,numel(int_bins)-1);
            mat_y_upper =  NaN(1,numel(int_bins)-1);
            
            % Find bin of interest
            ind_bin = 1;
            
            % Sliding window analysis
            for j = 1:length(int_bins)
                
                ind = int_bins(j) : (int_bins(j) + int_bins_dur);
                
                % Spikes on all trials
                temp0 = mat1_ini(ind,ind_bin);
                
                % Spikes on subset of trials
                index = S.esetup_background_texture_on(ind,1)==1;
                
                % Subset of trials
                temp1 = temp0(index,1);
                
                % Get means
                a = [];
                if sum(index)>1
                    a = nanmean(temp1);
                elseif sum(index) == 1
                    a = temp1;
                end
                if ~isempty(a)
                    mat_y(1,j) = a;
                end
                
                % Get error bars
                settings.bootstrap_on = 0;
                a = plot_helper_error_bar_calculation_v10(temp1, settings);
                try
                    mat_y_upper(1,j)= a.se_upper;
                    mat_y_lower(1,j)= a.se_lower;
                end
                settings = rmfield (settings, 'bootstrap_on');
                
            end
            
            plot_set = struct;
            
            % Initialize structure with data
            plot_set.mat_y = mat_y;
            plot_set.mat_x = pbins;
            plot_set.ebars_lower_y = mat_y_lower;
            plot_set.ebars_upper_y = mat_y_upper;
            plot_set.ebars_shade = 1;
            
            % Colors
            plot_set.data_color = [0.5,0.5,0.5];
            
            % Labels for plotting
            plot_set.xlabel = 'Trial number';
            plot_set.ylabel = 'Firing rate, Hz';
            
            % Figure title
            a = settings.int_bins(ind_bin);
            b = settings.int_bins(ind_bin) + settings.bin_length;
            plot_set.figure_title = sprintf('%s to %s ms to texture on', num2str(a), num2str(b));
            
            % Plot
            plot_helper_line_plot_v10;
            
            % Subplot 3
            %===============
            % Behaviour over time
            %================
            
            hfig = subplot(fig_subplot_dim(1), fig_subplot_dim(2), 3);
            hold on;
            
            % Ini mat
            mat_y = NaN(1, numel(int_bins), 3);
            mat_y_lower = NaN(1,numel(int_bins), 3);
            mat_y_upper =  NaN(1,numel(int_bins), 3);
            
            % Sliding window analysis
            for j = 1:length(int_bins)
                
                ind = int_bins(j) : (int_bins(j) + int_bins_dur);
                
                % Correct trials
                index1 = strncmp(S.edata_error_code(ind), 'correct', 7);
                mat_y(1,j,1)= sum(index1);
                
                % Wrong target trials
                index1 = strcmp(S.edata_error_code(ind), 'looked at st2');
                mat_y(1,j,2)= sum(index1);
                
                % Aborted trials
                index1 = strcmp(S.edata_error_code(ind), 'broke fixation');
                mat_y(1,j,3)= sum(index1);
                
            end
            
            % Data
            total1 = nansum(mat_y(:,:,1:2),3); % Check all conditions combined
            mat_y_2 = mat_y(:,:,1)./total1*100;
            
            plot_set = struct;
            
            % Initialize structure with data
            plot_set.mat_y = mat_y_2;
            plot_set.mat_x = pbins;
            
            % Colors
            plot_set.data_color = [0.5,0.5,0.5];
            
            % Labels for plotting
            plot_set.xlabel = 'Trial number';
            plot_set.ylabel = '% Correct trials';
            plot_set.ylim = [-5, 105];
            
            % Figure title
            plot_set.figure_title = sprintf('Behaviour performance');
            
            % Plot
            plot_helper_line_plot_v10;
            
            
        end
        
        %==========
        % Save data
        %==========
        
        if fig_plot_on == 1
            
            plot_set.figure_size = fig_size;
            plot_set.figure_save_name = sprintf ('%s_fig%s', settings.neuron_name, num2str(settings.figure_current));
            plot_set.path_figure = path_fig;
            
            plot_helper_save_figure;
            close all;
            
        end
        
    end
    
end
% End of plotting each figure