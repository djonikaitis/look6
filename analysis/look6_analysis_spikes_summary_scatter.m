% Plots spike rasters for different stimulus background colors

% Initial setup

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

settings.figure_folder_name = 'spikes_summary_scatter';
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
        
        %===============
        % Figures folder (decide whether to over-write analysis or not)
        temp_switch = 0;
        if numel(settings.dates_used)>1 && i_date==1
            path1 = get_generate_path_v10(settings, 'figures'); % Get short path
            a = sprintf('date range %s - %s', num2str(settings.dates_used(1)), num2str(settings.dates_used(end)));
            path_fig = sprintf('%s%s/%s/%s/', path1, a);
            temp_switch = 1;
        elseif numel(settings.dates_used)>1 && i_date>1
            temp_switch = 0;
        elseif numel(settings.dates_used)==1
            [~, path_fig] = get_generate_path_v10(settings, 'figures'); % Get short path
            temp_switch = 1;
        else
            path_fig = [];
        end
        
        % Now decide whether to over-write analysis
        if ~isempty(path_fig) && (~isdir(path_fig) || settings.overwrite==1)
            
            % Overwrite figure folders
            if  temp_switch == 1
                if ~isdir(path_fig)
                    mkdir(path_fig)
                elseif isdir(path_fig)
                    try
                        rmdir(path_fig, 's')
                    end
                    mkdir(path_fig)
                end
            end
            
            % Initialize text file for statistics
            if  temp_switch == 1
                nameOut = sprintf('%s%s.txt', path_fig, settings.stats_file_name); % File to be outputed
                fclose('all');
                fout = fopen(nameOut,'w');
            end
            
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
                
                %==============
                % Plot data for look, avoid or control conditions
                % (for each location separatelly)
                
                fig1=1;
                
                if fig1==1
                    
                    % Prepare exp conditions
                    S.expcond = NaN(size(S.START));
                    
                    % Find memory target arc
                    [th,radiusdeg] = cart2pol(S.esetup_memory_coord(:,1), S.esetup_memory_coord(:,2));
                    objposdeg = (th*180)/pi;
                    S.em_mem_arc = objposdeg;
                    S.em_mem_rad = radiusdeg;
                    
                    % Reset memory arc relative to RF center (assumes
                    % RF is in left lower visual field)
                    
                    % Find relative probe-memory position
                    a = unique(S.em_mem_arc);
                    a = min(a);
                    S.rel_arc = S.em_mem_arc - a;
                    ind = S.rel_arc<-180;
                    S.rel_arc(ind)=S.rel_arc(ind)+360;
                    ind = S.rel_arc>=180;
                    S.rel_arc(ind)=S.rel_arc(ind)-360;
                    S.rel_arc = round(S.rel_arc, 1);
                    
                    % Find how many relative positions are recorded relative to memory
                    m1 = unique(S.rel_arc);
                    legend1_values = m1;
                    
                    % Look task
                    i1=0;
                    for i=1:size(m1,1)
                        index = S.rel_arc==m1(i) & strcmp(S.esetup_block_cond, 'look') & S.esetup_background_texture_on(:,1)==1  & strcmp(S.edata_error_code, 'correct');
                        S.expcond(index)=i+i1;
                    end
                    % Avoid task
                    i1=size(m1,1);
                    for i=1:size(m1,1)
                        index = S.rel_arc==m1(i) & strcmp(S.esetup_block_cond, 'avoid') & S.esetup_background_texture_on(:,1)==1  & strcmp(S.edata_error_code, 'correct');
                        S.expcond(index)=i+i1;
                    end
                    % Control task
                    i1=size(m1,1)*2;
                    for i=1:size(m1,1)
                        index = S.rel_arc==m1(i) & strcmp(S.esetup_block_cond, 'control fixate') & S.esetup_background_texture_on(:,1)==1  & strcmp(S.edata_error_code, 'correct');
                        S.expcond(index)=i+i1;
                    end
                    
                    % Look task, no texture
                    i1=size(m1,1)*3;
                    for i=1:size(m1,1)
                        index = S.rel_arc==m1(i) & strcmp(S.esetup_block_cond, 'look') & S.esetup_background_texture_on(:,1)==0  & strcmp(S.edata_error_code, 'correct');
                        S.expcond(index)=i+i1;
                    end
                    % Avoid task
                    i1=size(m1,1)*4;
                    for i=1:size(m1,1)
                        index = S.rel_arc==m1(i) & strcmp(S.esetup_block_cond, 'avoid') & S.esetup_background_texture_on(:,1)==0  & strcmp(S.edata_error_code, 'correct');
                        S.expcond(index)=i+i1;
                    end
                    % Control task
                    i1=size(m1,1)*5;
                    for i=1:size(m1,1)
                        index = S.rel_arc==m1(i) & strcmp(S.esetup_block_cond, 'control fixate') & S.esetup_background_texture_on(:,1)==0  & strcmp(S.edata_error_code, 'correct');
                        S.expcond(index)=i+i1;
                    end
                    
                    
                    % Indicate what is expected condition number
                    cond1 = 1:size(m1,1)*6;
                    % Save value
                    settings.cond1 = cond1;
                    
                    % Determine selected offset in the time (for example between first display and memory onset)
                    S.tconst = S.fixation_off - S.first_display;
                    
                    % Select appropriate interval for plottings
                    int_bins = [-1000:200:-200];
                    settings.bin_length = 200;
                    
                    % Over-write spike rates?
                    if fig1==1
                        new_mat = 1;
                    else
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
                % End of decision whether to calculate spike rates
                
                
                %% Select data for plotting
                
                % Initialize data matrix to concatenate all data
                if i_date == 1
                    if i_unit == 1
                        [~,n,o] = size(mat1_ini);
                        mat2_ini = NaN(1, n, o);
                        mat2_ini_upper = NaN(1, n, o);
                        mat2_ini_lower = NaN(1, n, o);
                    end
                end
                
                % Save averages into mat2_ini
                m = size(mat2_ini, 1);
                
                for i1 = 1:size(mat1_ini, 3)
                    
                    % Get average data
                    mat2_ini(m+1,:,i1)= nanmean(mat1_ini(:, :, i1));
                    
                    % Get error bars
                    ind = ~isnan(mat1_ini(:,1,i1));
                    temp1 = mat1_ini(ind,:,i1);
                    a = plot_helper_error_bar_calculation_v10(temp1, settings);
                    try
                        mat2_ini_upper(m+1,:,i1)= a.se_upper;
                        mat2_ini_lower(m+1,:,i1)= a.se_lower;
                    end
                    
                end
                
            end
            % End of each neuron
            
        else
            fprintf('\nFigures folder "%s" for the date %s already exists, skipping analysis\n', settings.figure_folder_name, num2str(settings.date_current))
        end
        % End of decision whether to plot a figure or not
        
    end
    % End of each date
    
    
    %% Plot figure for each participant separately
    
    for fig1 = 1
        
        
        % Data
        mat1 = [];
        bin_no = numel(int_bins);
        plot_set = struct;
        
        % Data
        if fig1==1
            
            % Select location
            m(1) = find(legend1_values==0);
            m(2) = find(abs(legend1_values)==180);
            % Select condition
            n = length(legend1_values)*1 - length(legend1_values);
            bin_3 = m+n;
            mat0 = mat2_ini(:, bin_no, bin_3);
            
            plot_set.data_color = [1];
            plot_set.figure_title = 'Look, texture on';
            
        end
        
        % Setup axis limits
        h0_min = min(mat0);
        h0_max = max(mat0);
        
        % Setup axis limits
        h0_max = max(h0_max); h0_min = min(h0_min);
        h_max = h0_max + ((h0_max - h0_min) *0.1);
        h_min = h0_min - ((h0_max - h0_min) *0.1);
        
        % Initialize structure with data
        plot_set.mat_y = mat0(:,1);
        plot_set.mat_x = mat0(:,2);
        
        %             plot_set.ebars_min = mat2_ini_lower;
        %             plot_set.ebars_max = mat2_ini_upper;
        %             plot_set.ebars_shade = 1;
        %
        %             % Labels for plotting
        %             plot_set.XTick = [-100:100:500];
        %             plot_set.YLim = [h_min, h_max];
        %             plot_set.figure_title = 'Responses to texture';
        %             plot_set.xlabel = 'Time after texture onset, ms';
        %             plot_set.ylabel = 'Firing rate, Hz';
        
        % Save data
        plot_set.figure_size = settings.figure_size_temp;
        plot_set.figure_save_name = sprintf ('fig_%s', num2str(fig1));
        plot_set.path_figure = path_fig;
        
        
        % Plot
        hfig = figure;
        hold on;
        
        % Plot unity line
        h = plot([h_min, h_max], [h_min, h_max], '-');
        set (h(end), 'LineWidth', settings.wlineerror , 'Color', [0.2,0.2,0.2])
        
        % Plot each marker
        for j=1:size(plot_set.mat_y,1)
            
            h=plot(plot_set.mat_x(j,1), plot_set.mat_y(j,1));
            
            graphcond = plot_set.data_color;
            set (h(end), 'Marker', settings.marker1{graphcond}, 'MarkerFaceColor', settings.color1(graphcond,:), ...
                'MarkerEdgeColor', 'none', 'MarkerSize', settings.msize)
        end
        
        % % % % % % % % % % % %     plot_helper_basic_line_figure;
        
        % Save
        plot_helper_save_figure;
        close all;
        
    end
    % End of each figure
    
    
end
% End of each subject




