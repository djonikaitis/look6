% Prepare each figure

num_fig = 1:4;

for fig1 = num_fig % Plot figures
    
    fprintf('Preparing figure %s out of %s total for this analysis\n', num2str(fig1), num2str(numel(num_fig)))
    
    S.expcond = NaN(size(S.START));
    
    if fig1==1
        
        % Texture
        m1 = unique(S.esetup_background_texture_line_angle(:,1));
        orientation1 = m1;
        
        % One condition per texture
        index = S.esetup_background_texture_on(:,1)==1 & strncmp(S.edata_error_code, 'correct', 7);
        S.expcond(index) = 1;
        
        % Indicate what is expected condition number
        cond1 = 1;
        
        % Determine selected offset in the time (for example between first display and memory onset)
        S.tconst = NaN(numel(S.START), 1);
        ind = S.expcond == 1;
        S.tconst(ind) = S.memory_on(ind) - S.first_display(ind);
        
        % Select appropriate interval for plottings
        int_bins = [-200, -50];
        int_bins_fig1 = int_bins; % Save for later
        
        new_mat = 1;
        
    end
    
    if fig1==2 || fig1==3 || fig1==4
        
        % Texture
        m1 = unique(S.esetup_background_texture_line_angle(:,1));
        orientation1 = m1;
        
        % Find memory target arc
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
        
        % Indicate what is expected condition number
        cond1 = 1:length(m1)*3;
        
        % Over-write spike rates?
        if fig1==2
            new_mat = 1;
        else
            new_mat = 0;
        end
        
        % Data collected during memory delay, before
        % target onset
        S.tconst = S.memory_on - S.first_display;
        int_bins = [500, 650];
        int_bins_fig2 = int_bins; % Save for later
        
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
        mat1_ini = NaN(size(S.expcond,1), numel(orientation1), length(cond1));
        test1 = NaN(1, numel(orientation1), length(cond1));
        
        % How many trials recorded for each condition?
        for i=1:numel(orientation1)
            for k=1:length(cond1)
                index = S.expcond == cond1(k) & S.esetup_background_texture_line_angle(:,1)==orientation1(i);
                test1(1,i,k)=sum(index);
            end
        end
        
        % Find spikes
        for tid = 1:size(mat1_ini,1)
            for j=1:length(orientation1)
                for k=1:length(cond1)
                    
                    c1 = S.expcond(tid); % Which condition it is currently?
                    
                    % If particular conditon on a given trial
                    % exists, then calculate firing rates
                    if ~isnan(c1) && c1==k
                        
                        % Index
                        index = t1_spike >= t1(tid) + int_bins(1) & ...
                            t1_spike <= t1(tid) + int_bins(2) & ...
                            S.expcond(tid) == cond1(k) &...
                            S.esetup_background_texture_line_angle(tid,1) == orientation1(j);
                        
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
        
        % Initialize plot bins
        pbins=[orientation1'];
        
        % Convert to HZ
        mat1_ini = mat1_ini*(1000/settings.bin_length);
        
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
        mat1 = [];
        mat1(:,:,1) = mat2_ini(:,:,1);
        
        % Initialize structure with data
        plot_set = struct;
        plot_set.mat_y = mat1;
        plot_set.mat_x = pbins;
        plot_set.ebars_lower = mat2_ini_lower;
        plot_set.ebars_upper = mat2_ini_upper;
        plot_set.ebars_shade = 1;
        
        % Colors
        plot_set.data_color = 10;
        
        % Labels for plotting
        plot_set.xtick = [0:45:180];
        plot_set.figure_title = sprintf('Texture: %s to %s ms', num2str(int_bins_fig1(1)), num2str(int_bins_fig1(2)));
        plot_set.xlabel = 'Background orientation';
        plot_set.ylabel = 'Firing rate, Hz';
        
        % Save data
        plot_set.figure_size = settings.figsize_1col;
        plot_set.figure_save_name = sprintf ('%s_fig_%s', neuron_name, num2str(fig1));
        plot_set.path_figure = path_fig;
        
        % Plot
        hfig = figure;
        hold on;
        plot_helper_basic_line_figure;
        
        plot_helper_save_figure;
        close all;
    end
    
    
    if fig1==2 || fig1==3 || fig1==4
        
        plot_set = struct;
        
        % Data
        if fig1==2
            ind = 1:length(legend1_values);
            plot_set.data_color_min = [1];
            plot_set.figure_title = sprintf('Look: %s to %s ms', num2str(int_bins_fig2(1)), num2str(int_bins_fig2(2)));
        elseif fig1==3
            m = length(legend1_values);
            ind = m+1:m*2;
            plot_set.data_color_min = [2];
            plot_set.figure_title = sprintf('Avoid: %s to %s ms', num2str(int_bins_fig2(1)), num2str(int_bins_fig2(2)));
        elseif fig1==4
            m = length(legend1_values);
            ind = m*2+1:m*3;
            plot_set.data_color_min = [4];
            plot_set.figure_title = sprintf('Control: %s to %s ms', num2str(int_bins_fig2(1)), num2str(int_bins_fig2(2)));
        end
        
        % Data
        mat1 = [];
        mat1 = mat2_ini(:,:,ind);
        
        % Is there any data to plot?
        a = sum(sum(~isnan(mat1)));
        
        if a>0
            
            % Initialize structure with data
            plot_set.mat_y = mat1;
            plot_set.mat_x = pbins;
            plot_set.ebars_lower = mat2_ini_lower(:,:,ind);
            plot_set.ebars_upper = mat2_ini_upper(:,:,ind);
            plot_set.ebars_shade = 1;
            
            % Colors
            plot_set.data_color_max = [10];
            
            % Labels for plotting
            plot_set.xtick = [0:45:180];
            plot_set.xlabel = 'Background orientation';
            plot_set.ylabel = 'Firing rate, Hz';
            
            % Save data
            plot_set.figure_size = settings.figsize_1col;
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
% End of each figure





