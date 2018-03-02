% Prepare each figure


for fig1 = 1:8
    
    fprintf('Preparing figure %s\n', num2str(fig1))
    
    if fig1<=8
        
        % Prepare exp conditions
        S.expcond = NaN(size(S.START));
        
        %===============
        % Memory position
        [th,radius1] = cart2pol(S.esetup_memory_coord(:,1), S.esetup_memory_coord(:,2));
        arc1 = (th*180)/pi;
        m1 = [round(arc1,1), round(radius1,1)];
        m2 = unique(m1, 'rows');
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
        
        % Over-write bin length
        settings.bin_length = settings.bin_length_long;
        
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
    % End of data calculation
    
    
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
    
    %% PLOT DATA
    
    if ~isempty(settings.dates_used) && i_date == numel(settings.dates_used) && ...
            ~isempty(units_used) && i_unit == numel(units_used)
        
        if fig1 == 1
            
            % Figure folder
            if numel(settings.dates_used)>1
                a = sprintf('dates %s - %s', num2str(settings.dates_used(1)), num2str(settings.dates_used(end)));
                [b, ~, ~] = get_generate_path_v10(settings, 'figures');
                path_fig = sprintf('%s%s/', b, a);
            elseif numel(settings.dates_used)==1
                [~, path_fig, ~] = get_generate_path_v10(settings, 'figures');
            end
            
            % Overwrite figure folders
            if ~isdir(path_fig) || settings.overwrite==1
                mkdir(path_fig)
            elseif isdir(path_fig)
                try
                    rmdir(path_fig, 's')
                end
                mkdir(path_fig)
            end
        end
        % End of decision whether to create figures folder
        
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
    
    
end
% End of each figure




