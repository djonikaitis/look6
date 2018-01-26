% Plots spike rasters for different stimulus background colors

% Show file you are running
p1 = mfilename;
fprintf('\n=========\n')
fprintf('Current file:  %s\n', p1)
fprintf('=========\n')

% Loading the files needed
if ~exist('settings', 'var')
    settings = struct;
end
settings = get_settings_ini_v10(settings);

%% Extra settings

settings.figure_folder_name = 'orientation_timecourse';
settings.figure_size_temp = settings.figsize_1col;
settings.stats_file_name = sprintf('stats.txt');


%% Run analysis

for i_subj=1:length(settings.subjects)
    
    % Select curent subject
    settings.subject_current = settings.subjects{i_subj};
    
    % Which dates to run?
    settings.dates_used = get_dates_used_v10 (settings, 'data_combined_plexon');
    
    % Analysis for each day
    for i_date = 1:length(settings.dates_used)
        
        % Which date is it
        settings.date_current = settings.dates_used(i_date);
        
        %==========
        % Figures folder
        [~, path_fig, ~] = get_generate_path_v10(settings, 'figures');
        
        % Now decide whether to over-write analysis
        if ~isdir(path_fig) || settings.overwrite==1
            
            %==============
            % Create figure folders
            if ~isdir(path_fig)
                mkdir(path_fig)
            elseif isdir(path_fig)
                try
                    rmdir(path_fig, 's')
                end
                mkdir(path_fig)
            end
            fprintf('\nCreating figures folder "%s" for the date %s\n', settings.figure_folder_name, num2str(settings.date_current))

            
            %============
            % Psychtoolbox file path & file
            path1 = get_generate_path_v10(settings, 'data_combined', '.mat');
            S = get_struct_v11(path1);
            
            %============
            % Events file
            path1 = get_generate_path_v10(settings, 'data_combined_plexon', '_events_matched.mat');
            events_mat = get_struct_v11(path1);
            
            %=============
            % Determine neurons that exist on a given day
            [~, path1] = get_generate_path_v10(settings, 'data_combined_plexon');
            spikes_init = get_path_spikes_v11 (path1, settings.subject_current); % Path to each neuron
            
            % Determine which units to use
            units_used = find(~isnan(spikes_init.index_unit));
            
            % Run analysis for each unit
            for i_unit = 1 %:numel(units_used)
                
                
                current_unit = units_used(i_unit);
                
                % Prepare unit name
                neuron_name = ['ch', num2str(spikes_init.index_channel(i_unit)), '_u',  num2str(spikes_init.index_unit(i_unit))];
                fprintf('Working on analysis for the unit %s\n', neuron_name)

                %=================
                % Load spikes data
                path1 = spikes_init.index_path{current_unit};
                spikes1 = get_struct_v11(path1);
                
                %=================
                % Initialize text file for statistics
                f_ext = sprintf ('_%s_%s', neuron_name, settings.stats_file_name);
                path1 = get_generate_path_v10(settings, 'figures', f_ext);
                fclose('all');
                fout = fopen(path1,'w');
                
                
                %% Figure calculations
                
                for fig1 = 1 % Plot figures
                    
                    fprintf('Preparing figure %s\n', num2str(fig1))
                    
                    S.expcond = NaN(size(S.START));
                    
                    %==============
                    % Texture vs no texture condition, works as basic
                    % selection criterion for visual responsiveness of
                    % neurons
                    if fig1==1
                        
                        % Plot no orientation trials too
                        index = S.esetup_background_texture_on(:,1)==0;
                        S.esetup_background_texture_line_angle(index,1) = 270;
                        
                        % Texture
                        m1 = unique(S.esetup_background_texture_line_angle(:,1));
                        orientation1 = m1;
                        
                        % One condition per texture
                        for i=1:numel(orientation1)
                            index = S.esetup_background_texture_line_angle(:,1) == orientation1(i) & strcmp(S.edata_error_code, 'correct');
                            S.expcond(index)=i;
                        end
                        
                        % Indicate what is expected condition number
                        cond1 = 1:numel(orientation1);
                        
                        % Determine selected offset in the time (for example between first display and memory onset)
                        S.tconst = S.fixation_on - S.first_display;
                        
                        % Select appropriate interval for plottings
                        int_bins = settings.intervalbins_tex_timecourse1;
                        
                        new_mat = 1;
                        
                    end     
                    
                    %===========
                    % Initialize spike timing
                    t1_spike = spikes1.ts;
                    
                    % Get timing of the events
                    t1 = events_mat.msg_1;
                    t1 = t1 + S.tconst; % Reset to time relative to tconst
                    
                    
                    %============
                    % Find spikes
                    
                    if new_mat==1 % This decides whether to over_write the calculated data matrix
                        
                        %============
                        % Initialize empty matrix
                        mat1_ini = NaN(size(S.expcond,1), numel(int_bins), numel(cond1));
                        test1 = NaN(1, length(cond1));
                        
                        % How many trials recorded for each condition?
                        for k=1:length(cond1)
                            index = S.expcond(:,1) == cond1(k);
                            test1(k)=sum(index);
                        end
                        
                        %=============
                        % Calculate spiking rates
                        
                        for tid = 1:size(mat1_ini,1)
                            for j = 1:length(int_bins)
                                for k=1:length(cond1)
                                    
                                    c1 = S.expcond(tid); % Which condition it is currently?
                                    
                                    % If particular conditon on a given trial
                                    % exists, then calculate firing rates
                                    if ~isnan(c1) && c1==k
                                        
                                        % Index
                                        index = t1_spike >= t1(tid) + int_bins(j) & ...
                                            t1_spike <= t1(tid) + int_bins(j) + settings.bin_length & ...
                                            S.expcond(tid) == cond1(k);
                                        
                                        % Save data
                                        if sum(index)==0
                                            mat1_ini(tid,j,c1)=0; % Save as zero spikes
                                        elseif sum(index)>0
                                            mat1_ini(tid,j,c1)=sum(index); % Save spikes counts
                                        end
                                    end
                                    
                                end
                            end
                        end
                        
                        % Convert to HZ
                        mat1_ini = mat1_ini*(1000/settings.bin_length);
                        
                        % Initialize plot bins
                        pbins=int_bins+settings.bin_length/2;
                        
                    end
                    % End of checking whether new_mat==1
                    
                    
                    
                    %% Select data for plotting
                    
                    % Get means and bootstrap data;
                    [~,n,o] = size(mat1_ini);
                    mat2_ini = NaN(1, n, o);
                    mat2_ini_upper = NaN(1, n, o);
                    mat2_ini_lower = NaN(1, n, o);
                    h0_min = NaN(1, o); h_min = NaN;
                    h0_max = NaN(1, o); h_max = NaN;
                    
                    for i1 = 1:size(mat1_ini, 3)
                        
                        % Get average data
                        mat2_ini(1,:,i1)= nanmean(mat1_ini(:, :, i1));
                        
                        % Get error bars
                        ind = ~isnan(mat1_ini(:,1,i1));
                        temp1 = mat1_ini(ind,:,i1);
                        a = plot_helper_error_bar_calculation_v10(temp1, settings);
                        try
                            mat2_ini_upper(1,:,i1)= a.se_upper;
                            mat2_ini_lower(1,:,i1)= a.se_lower;
                        end
                        
                        % Setup axis limits
                        h0_min(i1) = min(mat2_ini_lower(:,:,i1));
                        h0_max(i1) = max(mat2_ini_upper(:,:,i1));
                        
                    end
                    
                    % Setup axis limits
                    h0_max = max(h0_max); h0_min = min(h0_min);
                    h_max = h0_max + ((h0_max - h0_min) *0.4);
                    h_min = h0_min - ((h0_max - h0_min) *0.5);
                    
                    
                    %% Plot the data
                    
                    if fig1==1
                        
                        % Data
                        mat1 = [];
                        mat1 = mat2_ini(:,:,1:numel(orientation1));
                        
                        % Initialize structure with data
                        plot_set = struct;
                        plot_set.mat1 = mat1;
                        plot_set.pbins = pbins;
                        plot_set.ebars_min = mat2_ini_lower;
                        plot_set.ebars_max = mat2_ini_upper;
                        plot_set.ebars_shade = 1;
                        
                        % Colors
                        plot_set.data_color_min = [23];
                        plot_set.data_color_max = [21];

                        
                        % Labels for plotting
                        plot_set.XTick = [-100:100:500];
                        plot_set.YLim = [h_min, h_max];
                        plot_set.figure_title = 'Responses to texture';
                        plot_set.xlabel = 'Time after texture onset, ms';
                        plot_set.ylabel = 'Firing rate, Hz';
                        
                        % Save data
                        plot_set.figure_size = settings.figure_size_temp;
                        plot_set.figure_save_name = sprintf ('%s_fig_%s', neuron_name, num2str(fig1));
                        plot_set.path_figure = path_fig;
                        
                        % Plot
                        hfig = figure;
                        hold on;
                        plot_helper_basic_line_figure;
                        
                        %===============
                        % Plot inset with probe locations
                        
                        axes('Position',[0.75,0.8,0.1,0.1])
                        
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
                        for i=1:length(orientation1)
                            
                            % Color
                            graphcond = i;
                            
                            % Find coordinates of a line
                            f_rad = 1;
                            f_arc = orientation1(i);
                            [xc,yc] = pol2cart(f_arc*pi/180, f_rad);
                            objsize = 0.2;
                            
                            % Plot cirlce
                            h=rectangle('Position', [xc(1)-objsize(1)/2, yc(1)-objsize(1)/2, objsize(1), objsize(1)],...
                                'EdgeColor', plot_set.color1_range(i,:), 'FaceColor', plot_set.color1_range(i,:),'Curvature', 0, 'LineWidth', 1);
                            
                        end
                        
                        % Cue location
                        m = find((orientation1)==270);
                        text(0, -2, 'No Tex', 'Color', plot_set.color1_range(m,:),  'FontSize', settings.fontszlabel, 'HorizontalAlignment', 'center')
                        
                        plot_helper_save_figure;
                        close all;
                    end
                    
                    
                    %% Plot more data?
                    
                    
                end
                % End of plotting each figure
                
            end
            % End of each neuron
            
        else
            fprintf('\nFigures folder "%s" for the date %s already exists, skipping analysis\n', settings.figure_folder_name, num2str(settings.date_current))
        end
        % End of decision to over-write figure folder or not
        
    end
    % End of each date
    
end
% End of each subject




