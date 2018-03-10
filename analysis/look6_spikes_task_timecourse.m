% Prepare each figure

num_fig = 1:7;

for fig1 = num_fig % Plot figures
    
    fprintf('Preparing figure %s out of %s total for this analysis\n', num2str(fig1), numel(num2str(num_fig)))
    
    S.expcond = NaN(size(S.START));
    
    %==============
    % Texture vs no texture condition, works as basic
    % selection criterion for visual responsiveness of
    % neurons
    if fig1==1
        
        % Setup conditions
        index = S.esetup_background_texture_on(:,1)==1 & strncmp(S.edata_error_code, 'correct', 7);
        S.expcond(index)=1;
        index = S.esetup_background_texture_on(:,1)==0 & strncmp(S.edata_error_code, 'correct', 7);
        S.expcond(index)=2;
        
        % Indicate what is expected condition number
        cond1 = 1:2;
        
        % Determine selected offset in the time (for example between first display and memory onset)
        S.tconst = S.fixation_on - S.first_display;
        
        % Select appropriate interval for plottings
        int_bins = settings.intervalbins_tex;
        settings.bin_length = settings.bin_length_short;
        
        new_mat = 1;
        
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
    
    %==============
    % Plot data for look, avoid or control conditions
    % (for each location separatelly)
    
    if fig1==2 || fig1==3 || fig1==4 || fig1==5 || fig1==6 || fig1==7
        
        temp1 = unique(S.esetup_memory_coord, 'rows');
        [th,radiusdeg] = cart2pol(temp1(:,1), temp1(:,2));
        theta = (th*180)/pi;
        legend1_values = theta;
        
        % Look task
        i1=0;
        for i=1:size(temp1,1)
            index = S.esetup_memory_coord(:,1)==temp1(i,1) & S.esetup_memory_coord(:,2)==temp1(i,2) & strcmp(S.esetup_block_cond, 'look') & S.esetup_background_texture_on(:,1)==1 & strcmp(S.edata_error_code, 'correct');
            S.expcond(index)=i+i1;
        end
        % Avoid task
        i1=size(temp1,1);
        for i=1:size(temp1,1)
            index = S.esetup_memory_coord(:,1)==temp1(i,1) & S.esetup_memory_coord(:,2)==temp1(i,2) & strcmp(S.esetup_block_cond, 'avoid') & S.esetup_background_texture_on(:,1)==1  & strcmp(S.edata_error_code, 'correct');
            S.expcond(index)=i+i1;
        end
        % Control task
        i1=size(temp1,1)*2;
        for i=1:size(temp1,1)
            index = S.esetup_memory_coord(:,1)==temp1(i,1) & S.esetup_memory_coord(:,2)==temp1(i,2) & strcmp(S.esetup_block_cond, 'control fixate') & S.esetup_background_texture_on(:,1)==1  & strcmp(S.edata_error_code, 'correct');
            S.expcond(index)=i+i1;
        end
        
        % Look task, no texture
        i1=size(temp1,1)*3;
        for i=1:size(temp1,1)
            index = S.esetup_memory_coord(:,1)==temp1(i,1) & S.esetup_memory_coord(:,2)==temp1(i,2) & strcmp(S.esetup_block_cond, 'look') & S.esetup_background_texture_on(:,1)==0  & strcmp(S.edata_error_code, 'correct');
            S.expcond(index)=i+i1;
        end
        % Avoid task, no texture
        i1=size(temp1,1)*4;
        for i=1:size(temp1,1)
            index = S.esetup_memory_coord(:,1)==temp1(i,1) & S.esetup_memory_coord(:,2)==temp1(i,2) & strcmp(S.esetup_block_cond, 'avoid') & S.esetup_background_texture_on(:,1)==0  & strcmp(S.edata_error_code, 'correct');
            S.expcond(index)=i+i1;
        end
        % Control task, no texture
        i1=size(temp1,1)*5;
        for i=1:size(temp1,1)
            index = S.esetup_memory_coord(:,1)==temp1(i,1) & S.esetup_memory_coord(:,2)==temp1(i,2) & strcmp(S.esetup_block_cond, 'control fixate') & S.esetup_background_texture_on(:,1)==0  & strcmp(S.edata_error_code, 'correct');
            S.expcond(index)=i+i1;
        end
        
        % Indicate what is expected condition number
        cond1 = 1:size(temp1,1)*6;
        
        % Determine selected offset in the time (for example between first display and memory onset)
        S.tconst = S.memory_on - S.first_display;
        
        % Select appropriate interval for plottings
        int_bins = settings.intervalbins_mem;
        settings.bin_length = settings.bin_length_short;
        
        % Remove bins after memory delay
        a = min(S.esetup_memory_delay)*1000;
        int_bins(int_bins + settings.bin_length>a)=[];
        
        
        % Over-write spike rates?
        if fig1==2
            new_mat = 1;
        elseif fig1>2
            new_mat = 0;
        end
        
        % Try to load the data for given analysis
        temp1 = sprintf('_%s_fig2.mat', settings.neuron_name);
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
            index = S.expcond == cond1(k);
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
    % End of checking whether new_mat==1
    
    
    
    %% Select data for plotting
    
    % Get means and bootstrap data;
    [~,n,o] = size(mat1_ini);
    mat2_ini = NaN(1, n, o);
    mat2_ini_upper = NaN(1, n, o);
    mat2_ini_lower = NaN(1, n, o);
    
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
        
    end
    
    
    %% Plot the data
    
    if fig1==1
        
        % Data
        mat_y = [];
        mat_y(:,:,1:2) = mat2_ini(:,:,1:2);
        
        % Initialize structure with data
        plot_set = struct;
        plot_set.mat_y = mat_y;
        plot_set.mat_x = pbins;
        plot_set.ebars_lower = mat2_ini_lower;
        plot_set.ebars_upper = mat2_ini_upper;
        plot_set.ebars_shade = 1;
        
        % Colors
        plot_set.data_color = [23, 21];
        
        % Legend
        plot_set.legend{1} = 'Texture';
        plot_set.legend{2} = 'No texture';
        
        % Labels for plotting
        plot_set.xtick = [-150, 0, 250, 500];
        plot_set.figure_title = 'Responses to texture';
        plot_set.xlabel = 'Time after texture onset, ms';
        plot_set.ylabel = 'Firing rate, Hz';
        
        % Save data
        plot_set.figure_size = settings.figsize_1col;
        plot_set.figure_save_name = sprintf ('%s_fig_%s', settings.neuron_name, num2str(fig1));
        plot_set.path_figure = path_fig;
        
        % Plot
        hfig = figure;
        hold on;
        plot_helper_basic_line_figure;
        
        plot_helper_save_figure;
        close all;
        
    end
    
    
    %% Plot data
    
    if fig1>=2 && fig1<=7
        
        plot_set = struct;
        
        % Data
        if fig1==2
            ind = 1:length(legend1_values);
            plot_set.data_color_min = [1];
            plot_set.figure_title = 'Look, texture on';
        elseif fig1==3
            m = length(legend1_values);
            ind = m+1:m*2;
            plot_set.data_color_min = [2];
            plot_set.figure_title = 'Avoid, texture on';
        elseif fig1==4
            m = length(legend1_values);
            ind = m*2+1:m*3;
            plot_set.data_color_min = [4];
            plot_set.figure_title = 'Control, texture on';
        elseif fig1==5
            m = length(legend1_values);
            ind = m*3+1:m*4;
            plot_set.data_color_min = [1];
            plot_set.figure_title = 'Look, no texture';
        elseif fig1==6
            m = length(legend1_values);
            ind = m*4+1:m*5;
            plot_set.data_color_min = [2];
            plot_set.figure_title = 'Avoid, no texture';
        elseif fig1==7
            m = length(legend1_values);
            ind = m*5+1:m*6;
            plot_set.data_color_min = [4];
            plot_set.figure_title = 'Control, no texture';
        end
        
        % Data
        mat_y = [];
        mat_y = mat2_ini(:,:,ind);
        
        % Is there any data to plot?
        a = sum(sum(~isnan(mat_y)));
        
        if a>0
            
            % Initialize structure with data
            plot_set.mat_y = mat_y;
            plot_set.mat_x = pbins;
            plot_set.ebars_lower = mat2_ini_lower(:,:,ind);
            plot_set.ebars_upper = mat2_ini_upper(:,:,ind);
            plot_set.ebars_shade = 1;
            
            % Colors
            plot_set.data_color_min = 9;
            plot_set.data_color_max = 10;
            
            % Labels for plotting
            plot_set.xlabel = 'Time after memory on, ms';
            plot_set.ylabel = 'Firing rate, Hz';
            plot_set.xtick = [-250, 0, 500:500:2000];
            
            % Save data
            plot_set.figure_size = settings.figsize_1col;
            plot_set.figure_save_name = sprintf ('%s_fig_%s', settings.neuron_name, num2str(fig1));
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
            for i=1:length(legend1_values)
                
                % Color
                graphcond = i;
                
                % Find coordinates of a line
                f_rad = 1;
                f_arc = legend1_values(i);
                [xc,yc] = pol2cart(f_arc*pi/180, f_rad);
                objsize = 0.7;
                
                % Plot cirlce
                h=rectangle('Position', [xc(1)-objsize(1)/2, yc(1)-objsize(1)/2, objsize(1), objsize(1)],...
                    'EdgeColor', plot_set.color1(i,:), 'FaceColor', plot_set.color1(i,:),'Curvature', 0, 'LineWidth', 1);
                
            end
            
            % Cue location
            m = find((legend1_values)<-90);
            text(0, -2, 'Cue in RF', 'Color', plot_set.color1(m,:),  'FontSize', settings.fontszlabel, 'HorizontalAlignment', 'center')
            
            plot_helper_save_figure;
            close all;
            
        end
        % End of checking whether data exists for plotting
        
    end
    
    
    
end
% End of plotting each figure