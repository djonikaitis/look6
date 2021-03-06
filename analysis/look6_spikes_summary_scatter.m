% Prepare each figure


%% Analysis

num_fig = [1:9];
settings.get_error_bars = 0;

for fig1 = num_fig
    
    fprintf('Preparing figure %s out of %s total for this analysis\n', num2str(fig1), num2str(numel(num_fig)))
    
    if fig1<=9
        
        % Prepare exp conditions
        S.expcond = NaN(size(S.START));
        
        %===============
        % Memory position
        [th,radius1] = cart2pol(S.esetup_memory_coord(:,1), S.esetup_memory_coord(:,2));
        arc1 = (th*180)/pi;
        m1 = [round(arc1,1), round(radius1,1)];
        p = unique(m1, 'rows');
        S.esetup_memory_arc = m1(:,1);
        S.esetup_memory_radius = m1(:,2);
        
        
        % Reset memory arc relative to RF center (assumes
        % RF is in left lower visual field)
        a = unique(S.esetup_memory_arc);
        a = min(a);
        S.rel_arc = S.esetup_memory_arc - a;
        % Round off
        S.rel_arc = round(S.rel_arc, 1);
        % Reset to range -180:180
        ind = S.rel_arc<-180;
        S.rel_arc(ind)=S.rel_arc(ind)+360;
        ind = S.rel_arc>=180;
        S.rel_arc(ind)=S.rel_arc(ind)-360;
        
        
        % Find how many relative positions are recorded relative to memory
        m1 = unique(S.rel_arc);
        legend1_values = m1;
        
        % Texture condition
        % Look task
        i1=0;
        for i=1:size(m1,1)
            index = S.rel_arc==m1(i) & strcmp(S.esetup_block_cond, 'look') & S.esetup_background_texture_on(:,1)==1  & strncmp(S.edata_error_code, 'correct', 7);
            S.expcond(index)=i+i1;
        end
        % Avoid task
        i1=size(m1,1);
        for i=1:size(m1,1)
            index = S.rel_arc==m1(i) & strcmp(S.esetup_block_cond, 'avoid') & S.esetup_background_texture_on(:,1)==1  & strncmp(S.edata_error_code, 'correct', 7);
            S.expcond(index)=i+i1;
        end
        % Control task
        i1=size(m1,1)*2;
        for i=1:size(m1,1)
            index = S.rel_arc==m1(i) & strcmp(S.esetup_block_cond, 'control fixate') & S.esetup_background_texture_on(:,1)==1  & strncmp(S.edata_error_code, 'correct', 7);
            S.expcond(index)=i+i1;
        end
        
        % No texture condition
        % Look task
        i1=size(m1,1)*3;
        for i=1:size(m1,1)
            index = S.rel_arc==m1(i) & strcmp(S.esetup_block_cond, 'look') & S.esetup_background_texture_on(:,1)==0  & strncmp(S.edata_error_code, 'correct', 7);
            S.expcond(index)=i+i1;
        end
        % Avoid task
        i1=size(m1,1)*4;
        for i=1:size(m1,1)
            index = S.rel_arc==m1(i) & strcmp(S.esetup_block_cond, 'avoid') & S.esetup_background_texture_on(:,1)==0  & strncmp(S.edata_error_code, 'correct', 7);
            S.expcond(index)=i+i1;
        end
        % Control task
        i1=size(m1,1)*5;
        for i=1:size(m1,1)
            index = S.rel_arc==m1(i) & strcmp(S.esetup_block_cond, 'control fixate') & S.esetup_background_texture_on(:,1)==0  & strncmp(S.edata_error_code, 'correct', 7);
            S.expcond(index)=i+i1;
        end
        
        % Indicate what is expected condition number
        cond1 = 1:size(m1,1)*6;
        % Save value
        settings.cond1 = cond1;
        
        % Determine selected offset in the time (for example between first display and memory onset)
        S.tconst = S.memory_off - S.first_display;
        
        % Select appropriate interval for plottings
        int_bins = settings.intervalbins_mem;
        settings.bin_length = settings.bin_length_long;
        
        % Remove bins after memory delay
        a = min(S.esetup_memory_delay)*1000;
        int_bins(int_bins + settings.bin_length>a)=[];
                
        % Over-write spike rates?
        if fig1==num_fig(1)
            new_mat = 1;
        else
            new_mat = 0;
        end
        
        % Try to load the data for given analysis
        temp1 = sprintf('_%s_fig1.mat', settings.neuron_name);
        [path1, path1_short, file_name] = get_generate_path_v10(settings, 'figures', temp1, settings.session_current);
        if isfile (path1)
            fprintf ('Skippind data binning and loading "%s"\n', file_name)
            data_mat = get_struct_v11(path1);
            mat1_ini = data_mat.mat1_ini;
            pbins = data_mat.pbins;
            new_mat = 0;
        end
        
    end
    
       
    %============
    % Find spikes
    
    if new_mat==1 % This decides whether to over_write the calculated data matrix
        
        %===========
        % Initialize spike timing
        t1_spike = spikes1.ts;
        
        % Get timing of the events
        t1 = events_mat.msg_1;
        t1 = t1 + S.tconst; % Reset to time relative to tconst
        
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
        
        % Save data
        d1 = struct;
        d1.mat1_ini = mat1_ini;
        d1.pbins = pbins;
        save (path1, 'd1')
                
    end
    % End of data calculation
    
    
    %% Select data for plotting
    
    % Initialize data matrix to concatenate all data
    if i_date == 1
        if i_unit == 1
            [~,n,o] = size(mat1_ini);
            mat2_ini = NaN(1, n, o);
            mat2_ini_date = NaN(1,1);
            if settings.get_error_bars == 1
                mat2_ini_upper = NaN(1, n, o);
                mat2_ini_lower = NaN(1, n, o);
            end
        end
    end
    
    % Increase matrix size if needed (if delays get longer over period of recordings)
    [~, n, ~] = size(mat1_ini);
    [p, q, r] = size(mat2_ini);
    if q < n
        temp1 = NaN(p, n, r);
        temp1_upper = NaN(p, n, r);
        temp1_lower = NaN(p, n, r);
        for i = 1:r
            temp1(:,1:q, i) = mat2_ini(:,:,i);
        end
    end
    mat2_ini = temp1;
    clear temp1;
    if settings.get_error_bars == 1
        mat2_ini_upper = temp1_upper;
        mat2_ini_lower = temp1_lower;
        clear temp1_upper; clear temp1_lower;
    end

    % Save averages into mat2_ini
    m = size(mat2_ini, 1);
    
    for i1 = 1:size(mat1_ini, 3)
                
        % Get average data
        n = size(mat1_ini, 2);
        mat2_ini(m+1,1:n,i1)= nanmean(mat1_ini(:, :, i1));
        
        % Get error bars
        if settings.get_error_bars == 1
            ind = ~isnan(mat1_ini(:,1,i1));
            temp1 = mat1_ini(ind,:,i1);
            a = plot_helper_error_bar_calculation_v10(temp1, settings);
            try
                mat2_ini_upper(m+1,1:n,i1)= a.se_upper;
                mat2_ini_lower(m+1,1:n,i1)= a.se_lower;
            end
        end
        
    end
    
    % Save the data
    mat2_ini_date(m+1,1) = i_date;
    
    %% Figure folder
    
    if ~isempty(settings.dates_used) && i_date == numel(settings.dates_used) && ...
            ~isempty(settings.channels_used) && i_unit == numel(settings.channels_used)
        
        if fig1 == num_fig(1)
            
            % Figure folder
            if numel(settings.dates_used)>1
                a = sprintf('dates %s - %s', num2str(settings.dates_used(1)), num2str(settings.dates_used(end)));
                [b, ~, ~] = get_generate_path_v10(settings, 'figures');
                path_fig = sprintf('%s%s/', b, a);
            elseif numel(settings.dates_used)==1
                [~, path_fig, ~] = get_generate_path_v10(settings, 'figures', [], settings.session_current);
            end
            
            %==============
            % Create figure folders. Delete old figures.
            if ~isdir(path_fig)
                mkdir(path_fig)
                fprintf('Created new figures folder "%s" for the date %s\n', settings.figure_folder_name, num2str(settings.date_current));
            elseif isdir(path_fig)
                fprintf('Overwriting existing figures folder "%s" for the date %s\n', settings.figure_folder_name, num2str(settings.date_current));
                % Delete figure files, leave other files un-touched
                a = dir(path_fig);
                for i = 1:numel(a)
                    if strncmp(a(i).name, 'fig', 3)
                        path1 = sprintf('%s%s', path_fig, a(i).name);
                        delete (path1)
                    end
                end
            end
            
        end
        % End of decision whether to create figures folder
        
    end
    
    
    %% PLOT FIGURES
    
    if ~isempty(settings.dates_used) && i_date == numel(settings.dates_used) && ...
            ~isempty(settings.channels_used) && i_unit == numel(settings.channels_used)

        
        if fig1<=8
            
            plot_set = struct;
            a = find(int_bins>500);
            ind_time = a(1);
            
            mat0=[];
                    
            % Data
            if fig1==1
                                
                % Select location
                m(1) = find(legend1_values==0);
                m(2) = find(abs(legend1_values)==180);
                % Select condition
                n = length(legend1_values)*1 - length(legend1_values);
                ind = m+n;                
                plot_set.data_color = [1];
                plot_set.figure_title = 'Look, texture on';
                
                mat0 = mat2_ini(:,ind_time,ind);
                
                
            elseif fig1==2
                
                % Select location
                m(1) = find(legend1_values==0);
                m(2) = find(abs(legend1_values)==180);
                % Select condition
                n = length(legend1_values)*2 - length(legend1_values);
                ind = m+n;
                plot_set.data_color = [2];
                plot_set.figure_title = 'Avoid, texture on';
                
                mat0 = mat2_ini(:,ind_time,ind);
                
            elseif fig1==3
                
                % Select location
                m(1) = find(legend1_values==0);
                m(2) = find(abs(legend1_values)==180);
                % Select condition
                n = length(legend1_values)*3 - length(legend1_values);
                ind = m+n;
                plot_set.data_color = [4];
                plot_set.figure_title = 'Control, texture on';
                
                mat0 = mat2_ini(:,ind_time,ind);
                
            elseif fig1==4
                
                % Select location
                m(1) = find(legend1_values==0);
                m(2) = find(abs(legend1_values)==180);
                % Select condition
                n = length(legend1_values)*4 - length(legend1_values);
                ind = m+n;
                plot_set.data_color = [1];
                plot_set.figure_title = 'Look, no texture';
                
                mat0 = mat2_ini(:,ind_time,ind);
                
            elseif fig1==5
                                
                % Select location
                m(1) = find(legend1_values==0);
                m(2) = find(abs(legend1_values)==180);
                % Select condition
                n = length(legend1_values)*5 - length(legend1_values);
                ind = m+n;
                plot_set.data_color = [2];
                plot_set.figure_title = 'Avoid, no texture';
                
                mat0 = mat2_ini(:,ind_time,ind);
                
            elseif fig1==6
                
                % Select location
                m(1) = find(legend1_values==0);
                m(2) = find(abs(legend1_values)==180);
                % Select condition
                n = length(legend1_values)*6 - length(legend1_values);
                ind = m+n;
                plot_set.data_color = [4];
                plot_set.figure_title = 'Control, no texture';
                
                mat0 = mat2_ini(:,ind_time,ind);
                
            elseif fig1==7
                                
                % Avoid task
                m = find(legend1_values==0);
                n = length(legend1_values)*2 - length(legend1_values);
                ind = m+n;
                mat0(:,1) = mat2_ini(:,ind_time,ind);
                % Look task
                m = find(legend1_values==0);
                n = length(legend1_values)*1 - length(legend1_values);
                ind = m+n;
                mat0(:,2) = mat2_ini(:,ind_time,ind);
                
                plot_set.data_color = [10];
                plot_set.figure_title = 'Texture on';
                
            elseif fig1==8
                                                
                % Avoid task
                m = find(legend1_values==0);
                n = length(legend1_values)*5 - length(legend1_values);
                ind = m+n;
                mat0(:,1) = mat2_ini(:,ind_time,ind);
                % Look task
                m = find(legend1_values==0);
                n = length(legend1_values)*4 - length(legend1_values);
                ind = m+n;
                mat0(:,2) = mat2_ini(:,ind_time,ind);
                
                plot_set.data_color = [10];
                plot_set.figure_title = 'No texture';
                
                
            end
            
            % Xlabels
            if fig1<=6
                plot_set.xlabel = 'Opposite location';
                plot_set.ylabel = 'Cued location';
            elseif fig1==7 || fig1==8
                plot_set.xlabel = 'Avoid task';
                plot_set.ylabel = 'Look task';
            end
            
            % Is there any data to plot?
            a = sum(sum(~isnan(mat0)));
            
            if a>0
                
                % Setup axis limits
                h0_min = min(mat0);
                h0_max = max(mat0);
                
                % Setup axis limits
                h0_max = max(h0_max); h0_min = min(h0_min);
                h_max = h0_max + ((h0_max - h0_min) *0.1);
                h_min = h0_min - ((h0_max - h0_min) *0.1);
                if h_min<0
                    h_min = 0;
                end
                
                % Initialize structure with data
                mat_y = mat0(:,1);
                mat_x = mat0(:,2);
                
                % Save data
                plot_set.figure_size = settings.figsize_1col;
                plot_set.figure_save_name = sprintf ('fig_%s', num2str(fig1));
                plot_set.path_figure = path_fig;
                
                plot_set.ylim = [h_min, h_max];
                plot_set.xlim = [h_min, h_max];
                
                % Plot
                hfig = figure;
                hold on;
                axis 'equal'
                
                % Plot unity line
                h = plot([h_min, h_max], [h_min, h_max], '-');
                set (h(end), 'LineWidth', settings.wlineerror , 'Color', [0.2,0.2,0.2])
                
                % Plot each marker
                for j=1:size(mat_y,1)
                    
                    h=plot(mat_x(j,1), mat_y(j,1));
                    
                    graphcond = plot_set.data_color;
                    set (h(end), 'Marker', settings.marker1{graphcond}, 'MarkerFaceColor', settings.color1(graphcond,:), ...
                        'MarkerEdgeColor', 'none', 'MarkerSize', settings.msize)
                end

                % Set figure options
                plot_helper_basic_line_figure;
                
                % Save
                plot_helper_save_figure;
                close all;
        
            end
            % End of checking if there is any data to plot
            
        end
        % End of plotting each figure 
                
    end
    % Decision if its finally time to plot a figure
    
    
    %% Plot data
    
    if ~isempty(settings.dates_used) && i_date == numel(settings.dates_used) && ...
            ~isempty(settings.channels_used) && i_unit == numel(settings.channels_used)
        
        if fig1==9
            
            % Select one bin to plot
            plot_set = struct;
            a = find(int_bins>=500);
            ind_time = a(1);
            
            % Figure title
            a = (int_bins(a(1)));
            title1 = sprintf('%s to %s ms after cue onset', num2str(a), num2str(a+settings.bin_length));
            
            conds1 = cell(1);
            conds1{1} = 'Look';
            conds1{2} = 'Avoid';
            conds1{3} = 'Control';
            plot_set.data_color_temp = [1,2,4];
            
            %================
            % Data
            mat1 = []; mat0 = []; 
            for i = 1:3 % For each conditon
                
                % Select location
                m(1) = find(legend1_values==0);
                m(2) = find(abs(legend1_values)==180);
                
                % Select condition
                n = length(legend1_values)*i - length(legend1_values);
                ind = m+n;
                
                mat0 = mat2_ini(:,ind_time,ind);
                mat1(:,i) = (mat0(:,1) - mat0(:,2))./mat0(:,2);
                
            end
            
            %==============
            % Setup X axis limits
            h0_min = min(mat2_ini_date);
            h0_max = max(mat2_ini_date);
            
            % Setup axis limits
            h0_max = max(h0_max); h0_min = min(h0_min);
            h_max = h0_max + ((h0_max - h0_min) *0.1);
            h_min = h0_min - ((h0_max - h0_min) *0.1);
            
            if numel (settings.dates_used)==1
                plot_set.xlim = [0, 1.4];
                plot_set.xtick = 1;
            else
                plot_set.xlim = [h_min, h_max];
            end
            plot_set.xlabel = 'Recording date';
            
            %==============
            % Setup Y axis limits
            h0_min = min(min(mat1));
            h0_max = max(max(mat1));
            
            % Setup axis limits
            h0_max = max(h0_max); h0_min = min(h0_min);
            h_max = h0_max + ((h0_max - h0_min) *0.2);
            h_min = h0_min - ((h0_max - h0_min) *0.5);
           
            plot_set.ylim = [h_min, h_max];
            plot_set.ylabel = 'Cued vs non-cued, proportion';
            
            %===============
            plot_set.figure_title = title1;
            
            %================
            % Plot
            hfig = figure;
            hold on;
            
            % Plot unity line
            h = plot([plot_set.xlim(1), plot_set.xlim(2)], [0, 0], '-');
            set (h(end), 'LineWidth', settings.wlineerror , 'Color', [0.2,0.2,0.2])
            
            % Plot dots
            for i = 1:3
                
                plot_set.data_color = plot_set.data_color_temp(i);
                
                % Plot each date separately
                for j = 1:max(mat2_ini_date)
                    
                    ind1 = mat2_ini_date==j;
                    
                    mat_y = mat1(ind1,i);
                    mat_x = mat2_ini_date(ind1,:);
                    
                    % Randomixe mat_x
                    if numel(mat_x)>1
                        a = [j-0.1, j+0.1];
                        mat_x = a(1) + (a(2)-a(1)).*rand(100,1);
                    end
                    
                    % Plot each unit separately
                    for j=1:size(mat_y,1)
                        
                        h=plot(mat_x(j,1), mat_y(j,1));
                        
                        graphcond = plot_set.data_color;
                        set (h(end), 'Marker', settings.marker1{graphcond}, 'MarkerFaceColor', settings.color1(graphcond,:), ...
                            'MarkerEdgeColor', 'none', 'MarkerSize', settings.msize)
                    end
                    
                    % Set figure options
                    plot_helper_basic_line_figure;
                    
                end
            end
            
            %===============
            % Legend
            
            if sum(~isnan(mat1(:,1)))>0
                t1_s(1) = 1;
            else
                t1_s(1) = 0;
            end
            if sum(~isnan(mat1(:,2)))>0
                t1_s(2) = 1;
            else
                t1_s(2) = 0;
            end
            if sum(~isnan(mat1(:,3)))>0
                t1_s(3) = 1;
            else
                t1_s(3) = 0;
            end
            
            index1 = find(t1_s==1);

            % Set legend labels and coordinates
            a = plot_set.ylim;
            step1 = (a(2)-a(1)) * 0.05;
            for i = 1:numel(index1)               
                plot_set.legend{i} = conds1{index1(i)};
                plot_set.legend_y_coord(i) = a(1)+step1*i;
                plot_set.legend_x_coord(i) = [0.2];
                plot_set.data_color(i) = plot_set.data_color_temp(index1(i));
            end
            plot_helper_basic_line_figure;
            
            
            %==========                
            % Save data
            plot_set.figure_size = settings.figsize_1col;
            plot_set.figure_save_name = sprintf ('fig_%s', num2str(fig1));
            plot_set.path_figure = path_fig;
            
            % Save
            plot_helper_save_figure;
            close all;
            
            
        end
        
    end
    
    
end
% End of each figure




