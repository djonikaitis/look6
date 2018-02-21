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

settings.figure_folder_name = 'spikes_orientation_timecourse';
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
            for i_unit = 1:numel(units_used)
                
                
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
                
                for fig1 = 1:2 % Plot figures
                    
                    fprintf('Preparing figure %s\n', num2str(fig1))
                    
                    S.expcond = NaN(size(S.START));
                    
                    %==============
                    % Texture vs no texture condition, works as basic
                    % selection criterion for visual responsiveness of
                    % neurons
                    if fig1==1 || fig1==2
                        
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
                        int_bins = settings.intervalbins_tex_radial;
                        
                        if fig1==1
                            new_mat = 1;
                        elseif fig1==2
                            new_mat = 0;
                        end
                        
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
                        plot_set.mat_y = mat1;
                        plot_set.mat_x = pbins;
                        plot_set.ebars_min = mat2_ini_lower;
                        plot_set.ebars_max = mat2_ini_upper;
                        plot_set.ebars_shade = 1;
                        
                        % Colors
                        plot_set.data_color_min = [23];
                        plot_set.data_color_max = [21];

                        
                        % Labels for plotting
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
                                'EdgeColor', plot_set.color1(i,:), 'FaceColor', plot_set.color1(i,:),'Curvature', 0, 'LineWidth', 1);
                            
                        end
                        
                        plot_helper_save_figure;
                        close all;
                    end
                    
                    
                    %% Plot the data
                    
                    if fig1==2
                        
                        ind1 = [];
                        % Baseline
                        ind1(1) = 1;
                        % First texture
                        i1 = find(pbins>300);
                        ind1(2) = i1(1);
                        
                        %==============
                        % Data Y
                        
                        mat_y = [];
                        mat_y_lower = [];
                        mat_y_upper = [];
                        
                        % Restructure data
                        for i = 1:numel(orientation1)
                            for k = 1:numel(ind1)
                                mat_y(:,i,k) = mat2_ini(:,ind1(k),i);
                                mat_y_lower(:,i,k) = mat2_ini_lower(:,ind1(k),i);
                                mat_y_upper(:,i,k) = mat2_ini_upper(:,ind1(k),i);
                            end
                        end
                        
                        % Duplicate data
                        m = size(mat_y,2);
                        for i = 1:size(mat_y,3)
                            mat_y(:,m+1:m+m, i) = mat_y(:,1:m, i);
                            mat_y_lower(:,m+1:m+m, i) = mat_y_lower(:,1:m, i);
                            mat_y_upper(:,m+1:m+m, i) = mat_y_upper(:,1:m, i);
                        end
                        
                        % Repeat first value
                        m = size(mat_y,2);
                        for i = 1:size(mat_y,3)
                            mat_y(:,m+1, i) = mat_y(:,1, i);
                            mat_y_lower(:,m+1, i) = mat_y_lower(:,1, i);
                            mat_y_upper(:,m+1, i) = mat_y_upper(:,1, i);
                        end
                        
                        %================
                        % Data X
                        
                        mat_x = [];
                        
                        % Duplicate data
                        m = numel(orientation1);
                        mat_x(1:m) = orientation1;
                        mat_x(m+1:m+m) = orientation1+180;
                        % Repeat first value
                        m = numel(mat_x);
                        mat_x(m+1) = mat_x(1)+360;
                        
                        
                        % Convert to cartesian coordinates
                        yc = []; yc_lower =[]; yc_upper = [];
                        xc = []; xc_lower =[]; xc_upper = [];
                        xi = [0:1:360];
                        
                        for k = 1:size(mat_y,3)
                            
                            yInt = interp1(mat_x, mat_y(:,:,k), xi, 'linear');
                            [x1, y1] = pol2cart(xi*pi/180, yInt);
                            yc(:,:,k) = y1;
                            xc(:,:,k) = x1;
                            
                            yInt = interp1(mat_x, mat_y_lower(:,:,k), xi, 'linear');
                            [x1, y1] = pol2cart(xi*pi/180, yInt);
                            yc_lower(:,:,k) = y1;
                            xc_lower(:,:,k) = x1;
                            
                            yInt = interp1(mat_x, mat_y_upper(:,:,k), xi, 'linear');
                            [x1, y1] = pol2cart(xi*pi/180, yInt);
                            yc_upper(:,:,k) = y1;
                            xc_upper(:,:,k) = x1;

                        end
                                                                        
                        % Initialize structure with data
                        plot_set = struct;
                        plot_set.mat_y = yc;
                        plot_set.mat_x = xc;
                        plot_set.ebars_lower_y = yc_lower;
                        plot_set.ebars_upper_y = yc_upper;
                        plot_set.ebars_lower_x = xc_lower;
                        plot_set.ebars_upper_x = xc_upper;
                        plot_set.ebars_shade = 1;
                        plot_set.plot_remove_nan = 1;
                        
                        % Colors
                        plot_set.data_color(1) = [21];
                        plot_set.data_color(2) = [23];
                        
                        % Labels for plotting
                        plot_set.YLim = [-h_max, h_max];
                        plot_set.XLim = [-h_max, h_max];
                        
                        plot_set.figure_title = 'Responses to texture';
                        
                        % Save data
                        plot_set.figure_size = settings.figure_size_temp;
                        plot_set.figure_save_name = sprintf ('%s_fig_%s', neuron_name, num2str(fig1));
                        plot_set.path_figure = path_fig;
                        
                        % Initialize the data
                        hfig=figure;
                        set (gca, 'Color', [1,1,1])
                        hold on;
                        axis equal
                        
                        %============
                        % Plot the axis properties
                        %============
                        
                        try
                            % Axis properties
                            minaxis1 = 0; % Limits latencies plotted
                            maxaxis1 = h_max; % Limits latencies plotted
                            if h_max < 50
                                step1 = 10;
                            elseif h_max<100
                                step1 = 20;
                            elseif h_max<250
                                step1 = 50;
                            else
                                step1 = 100;
                            end
                            tick_small = [0:step1:maxaxis1]; % Step for small tick
                            tick_large = [0:step1:maxaxis1]; % Step for large tick
                            plot_angle = 90; % Angle at which tick marks are drawn
                            
                            % Reset to figure to the limits chosen
                            tickrange1 = maxaxis1 - minaxis1;
                            tick_small_temp = tick_small-minaxis1;
                            tick_small_temp(tick_small_temp<=0) = [];
                            tick_large_temp = tick_large-minaxis1;
                            tick_large_temp(tick_large_temp<=0) = [];
                            
                            % Fill in the largest circle
                            if tick_small_temp(end)>=tick_large_temp(end)
                                ticks1=[tickrange1];
                                cpos1 = [0,0];
                                cl1=[0.9,0.9,0.9];
                            else
                                ticks1=[tickrange1];
                                cpos1 = [0,0];
                                cl1=[0.7,0.7,0.7];
                            end
                            h=rectangle('Position', [cpos1(1,1)-ticks1, cpos1(1,2)-ticks1, ticks1*2, ticks1*2],...
                                'EdgeColor', cl1, 'FaceColor', [1,1,1], 'Curvature', 1, 'LineWidth', 0.7, 'LineStyle', '-');
                            
                            % Draw vertical and horizontal lines
                            cl1 = [0.9,0.9,0.9];
                            h = plot([-tickrange1, tickrange1], [0,0]);
                            set (h(end), 'LineWidth', 0.7, 'Color', cl1)
                            h = plot([0,0], [-tickrange1, tickrange1]);
                            set (h(end), 'LineWidth', 0.7, 'Color', cl1)
                            
                            % Fill the the central cirlce
                            if tick_small_temp(1)<=tick_large_temp(1)
                                ticks1=[tick_small_temp(1)];
                                cpos1 = [0,0];
                                cl1=[0.9,0.9,0.9];
                            else
                                ticks1=[tick_large_temp(1)];
                                cpos1 = [0,0];
                                cl1=[0.7,0.7,0.7];
                            end
                            h=rectangle('Position', [cpos1(1,1)-ticks1, cpos1(1,2)-ticks1, ticks1*2, ticks1*2],...
                                'EdgeColor', cl1, 'FaceColor', [1,1,1], 'Curvature', 1, 'LineWidth', 0.7, 'LineStyle', '-');
                            
                            % Plot small cirlces
                            cpos1 = [0,0];
                            ticks1=[tick_small_temp];
                            cl1=[0.9,0.9,0.9];
                            for i=1:length(ticks1)
                                h=rectangle('Position', [cpos1(1,1)-ticks1(i), cpos1(1,2)-ticks1(i), ticks1(i)*2, ticks1(i)*2],...
                                    'EdgeColor', cl1, 'FaceColor', 'none', 'Curvature', 1, 'LineWidth', 0.7, 'LineStyle', '-');
                            end
                            
                            
                            % Add tick marks
                            ticks1 = [tick_small_temp];
                            ticks1labels=[tick_small_temp+minaxis1]; % Plots real values
                            for i=1:length(ticks1)
                                [x,y] = pol2cart(plot_angle*pi/180,ticks1(i));
                                if ticks1labels(i)~=max(ticks1labels)
                                    text(x,y, num2str(ticks1labels(i)), 'FontSize', settings.fontsz, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
                                else
                                    text(x,y, ['spikes, Hz '], 'FontSize', settings.fontsz, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
                                end
                            end
                            
                            
                        end
                        
                        set (gca,'Visible', 'off');
                        
                        %==========
                        % Plot data
                        %==========
                        
                        plot_helper_basic_line_figure;
                        plot_helper_save_figure;
                        close all;
                      
                        
                    end
                    
                    
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




