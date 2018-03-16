% Prepare each figure

num_fig = 1;

%%  Calculate few variables, done only once for all figures

S.expcond1 = NaN(size(S.START));
S.expcond2 = NaN(size(S.START));

%==========
% Texture
m1 = unique(S.esetup_background_texture_line_angle(:,1));
orientation1 = m1;

% One condition per texture
for i=1:numel(orientation1)
    index = S.esetup_background_texture_line_angle(:,1) == orientation1(i) & S.esetup_background_texture_on(:,1)==1;
    S.expcond1(index)=i;
end

%==========
% Location

temp1 = unique(S.esetup_memory_coord, 'rows');
[th,radiusdeg] = cart2pol(temp1(:,1), temp1(:,2));
theta = (th*180)/pi;
memory_angle = theta;

for i=1:size(temp1,1)
    index = S.esetup_memory_coord(:,1)==temp1(i,1) & S.esetup_memory_coord(:,2)==temp1(i,2);
    S.expcond2(index) = i;
end


%% Do figures

for fig1 = 1:numel(num_fig) % Plot figures
    
    settings.figure_current = num_fig(fig1);
    fprintf('Preparing figure %s out of %s total for this analysis\n', num2str(fig1), num2str(numel(num_fig))  )
    
    %=============
    % Load data or calculate data?
    
    % Over-write spike rates?
    if fig1==1
        new_mat = 1;
    else
        new_mat = 0;
    end
    
    % Try to load the data for given analysis
    temp1 = sprintf('_%s_mem_delay.mat', settings.neuron_name);
    [path1, path1_short, file_name] = get_generate_path_v10(settings, 'figures', temp1, settings.session_current);
    if isfile (path1)
        fprintf ('Skippind data binning and loading "%s"\n', file_name)
        data_mat = get_struct_v11(path1);
        mat1_ini = data_mat.mat1_ini;
        plot_bins_start = data_mat.plot_bins_start;
        plot_bins_end = data_mat.plot_bins_end;
        mat2_ini = data_mat.mat2_ini;
        new_mat = 0;
        clear data_mat;
    end
    
    % Initialize few variables
    settings.int_bins = settings.intervalbins_mem;
    settings.bin_length = settings.bin_length_short;
    S.tconst = S.memory_on - S.first_display;
    
    % Remove bins after memory delay
    a = prctile(S.esetup_memory_delay*1000, 75);
    settings.int_bins(settings.int_bins + settings.bin_length > a) = [];
    
    % plot_bins
    settings.plot_bins=settings.int_bins+settings.bin_length/2;
    
    %===============
    % Select appropriate time interval for spike binning
    
    if new_mat == 1
        
        %================
        % Calculate short time bins
        
        % Create a matrix with plot_bins
        int_bins = settings.int_bins;
        bin_length = settings.bin_length;
        t_dur = (S.edata_fixation_off - S.edata_memory_on) * 1000;
        
        % Over-write t_dur if second texture was presented
        a = 'edata_background_texture_onset_time';
        if size(S.(a), 2)>1
            index = ~isnan(S.(a)(:,2));
            t_dur(index) = (S.edata_fixation_off(index) - S.(a)(index,2) ) * 1000;
        end
        
        look6_helper_int_bins_calculator;
        
        %==================
        % Calculate long time bins
        
        plot_bins_start2 = NaN(numel(t_dur), 1); % Output matrix
        plot_bins_end2 = NaN(numel(t_dur), 1); % Output matrix
        
        plot_bins_start2(:,1) = 500;
        
        t_dur = (S.edata_fixation_off - S.edata_memory_on) * 1000;
        
        % Over-write t_dur if second texture was presented
        a = 'edata_background_texture_onset_time';
        if size(S.(a), 2)>1
            index = ~isnan(S.(a)(:,2));
            t_dur(index) = (S.edata_fixation_off(index) - S.(a)(index,2) ) * 1000;
        end
        
        plot_bins_end2(:,1) = t_dur;
        
        % Rempve trials when memory did not appear
        index = isnan(plot_bins_end2);
        plot_bins_start2(index)=NaN;
        
        
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
        
    end
    
    
    %% Plot the data
    
    if settings.figure_current==1
        
        % Data
        for fig_sub = 1:3
            
            plot_set = struct;
            
            % Select condition to plot
            if fig_sub==1
                t1 = 'look';
            elseif fig_sub==2
                t1 = 'avoid';
            elseif fig_sub==3
                t1 = 'control fixate';
            end
            plot_set.figure_title = sprintf('%s', t1);
            
            % Data
            cond1 = orientation1;
            mat_y = NaN(1, numel(settings.plot_bins), numel(cond1));
            mat_y_lower = NaN(1,numel(settings.plot_bins), numel(cond1));
            mat_y_upper =  NaN(1,numel(settings.plot_bins), numel(cond1));
            
            for i = 1:numel(cond1)
                
                index = S.expcond1 == i & strcmp(S.esetup_block_cond, t1) & ...
                    strncmp(S.edata_error_code, 'correct', 7);
                temp1 = mat1_ini(index,:);
                
                % Get means
                a = [];
                if sum(index)>1
                    a = nanmean(temp1);
                elseif sum(index) == 1
                    a = temp1;
                end
                [n] = numel(a);
                if ~isempty(a)
                    mat_y(1,1:n,i) = a;
                end
                
                % Get error bars
                settings.bootstrap_on = 0;
                a = plot_helper_error_bar_calculation_v10(temp1, settings);
                try
                    mat_y_upper(1,:,i)= a.se_upper;
                    mat_y_lower(1,:,i)= a.se_lower;
                end
                settings = rmfield (settings, 'bootstrap_on');
                
            end
            
            % Initialize structure with data
            plot_set.mat_y = mat_y;
            plot_set.mat_x = settings.plot_bins;
            plot_set.ebars_lower_y = mat_y_lower;
            plot_set.ebars_upper_y = mat_y_upper;
            plot_set.ebars_shade = 1;
            plot_set.plot_remove_nan = 1;
            
            % Colors
            plot_set.data_color_min = [23];
            plot_set.data_color_max = [21];
            
            % Labels for plotting
            plot_set.xlabel = 'Time after memory cue, ms';
            plot_set.ylabel = 'Firing rate, Hz';
            
            % Is there any data to plot?
            a = sum(sum(~isnan(plot_set.mat_y)));
            if a>0
                hfig = subplot(2,2,fig_sub);
                hold on;
                plot_helper_basic_line_figure;
            end
            
            
            %===============
            % Plot inset with probe locations
            
            if fig_sub == 1
                axes('Position',[0.35,0.85,0.06,0.06])
                
                axis 'equal'
                set (gca, 'Visible', 'off')
                hold on;
                
                % Initialize data values for plotting
                for i=1:length(orientation1)
                    
                    % Color
                    graphcond = i;
                    
                    % Find coordinates of a line
                    f_rad = 1;
                    f_arc = orientation1(i);
                    [xc,yc] = pol2cart(f_arc*pi/180, f_rad);
                    
                    % Plot cirlce
                    h = plot([0, xc(1)], [0, yc(1)], 'Color', plot_set.main_color(i,:), 'LineWidth', 1.8);
                    
                end
                
                % Add text
                text(0, -0.5, 'Texture angle', 'Color', [0.2, 0.2, 0.2],  'FontSize', settings.fontszlabel, 'HorizontalAlignment', 'center')
            end
            
        end
    end
    
    
    %% Plot the data
    
    if settings.figure_current==1
        
        % Data
        for fig_sub = 4
            
            plot_set = struct;
            
            hfig = subplot(2,2,fig_sub);
            hold on;
            
            % Select condition to plot
            cond1 = orientation1;
            cond2 = cell(1);
            cond2{1} = 'look';
            cond2{2} = 'avoid';
            cond2{3} = 'control fixate';
            
            % Data
            mat_y = NaN(1, numel(cond1), numel(cond2));
            mat_y_lower = NaN(1, numel(cond1), numel(cond2));
            mat_y_upper =  NaN(1, numel(cond1), numel(cond2));
            
            for i = 1:numel(cond1)
                for j = 1:numel(cond2)
                    
                    index = S.expcond1 == i & strcmp(S.esetup_block_cond, cond2{j}) & ...
                        strncmp(S.edata_error_code, 'correct', 7);
                    temp1 = mat2_ini(index,:);
                    
                    % Get means
                    a = [];
                    if sum(index)>1
                        a = nanmean(temp1);
                    elseif sum(index) == 1
                        a = temp1;
                    end
                    if ~isempty(a)
                        mat_y(1,i,j) = a;
                    end
                    
                    % Get error bars
                    settings.bootstrap_on = 0;
                    a = plot_helper_error_bar_calculation_v10(temp1, settings);
                    try
                        mat_y_upper(1,i,j)= a.se_upper;
                        mat_y_lower(1,i,j)= a.se_lower;
                    end
                    settings = rmfield (settings, 'bootstrap_on');
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
            
            
            %===========
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
            
            % Calculate figure limits
            for i = 1:size(yc_upper,3)
                h0_max(1,i) = max(yc_upper(:,:,i));
                h0_max(2,i) = max(xc_upper(:,:,i));
            end
            h_max = max(max(h0_max));
            h_max = h_max + h_max*0.2;
            
            % Initialize structure with data
            plot_set = struct;
            plot_set.mat_y = yc;
            plot_set.mat_x = xc;
            plot_set.ebars_lower_y = yc_lower;
            plot_set.ebars_upper_y = yc_upper;
            plot_set.ebars_lower_x = xc_lower;
            plot_set.ebars_upper_x = xc_upper;
            plot_set.ebars_shade = 1;
            
            % Colors
            plot_set.data_color = [1,2,4];
            
            % Labels for plotting
            plot_set.YLim = [-h_max, h_max];
            plot_set.XLim = [-h_max, h_max];
            
            
            % Save data
            plot_set.figure_size = [0, 0, 5, 5];
            plot_set.figure_save_name = sprintf ('%s_fig_%s', settings.neuron_name, num2str(settings.figure_current));
            plot_set.path_figure = path_fig;
            
            % Initialize the data
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
            
            %==========
            % Plot data
            %==========
            
            plot_helper_basic_line_figure;
            plot_helper_save_figure;
            close all;
            
        end
    end
    
    
end
% End of plotting each figure





