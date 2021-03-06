% Prepare each figure

num_fig = 1;

for fig1 = num_fig % Plot figures
    
    fprintf('\nPreparing figure %s out of %s total for this analysis\n', num2str(fig1), num2str(numel(num_fig)))
    
    S.expcond = NaN(size(S.START));
    
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
        
        % Create a matrix with plot_bins
        int_bins = settings.int_bins;
        bin_length = settings.bin_length;
        t_dur = (S.edata_fixation_off - S.edata_memory_on) * 1000;
        
        look6_helper_int_bins_calculator;
        
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
        
        % Save data
        d1 = struct;
        d1.mat1_ini = mat1_ini;
        d1.plot_bins_start = plot_bins_start;
        d1.plot_bins_end = plot_bins_end;
        d1.plot_bins = settings.plot_bins;
        save (path1, 'd1')
        
    end
    
    
    %% Plot data
    
    if fig1==1 || fig1==2
        
        plot_set = struct;
        
        % Data
        if fig1==1
            plot_set.data_color_min = [1];
            plot_set.figure_title = 'Texture trials';
            v1 = 1;
        elseif fig1==2
            plot_set.data_color_min = [1];
            plot_set.figure_title = 'No texture trials';
            v1 = 0;
        end
        
        % Calculate memory locations
        temp1 = unique(S.esetup_memory_coord, 'rows');
        [th,radiusdeg] = cart2pol(temp1(:,1), temp1(:,2));
        theta = (th*180)/pi;
        cond1 = theta;
        
        % Initialize conditions
        S.expcond1 = NaN(size(S.START));
        for i=1:size(temp1,1)
            index = S.esetup_memory_coord(:,1)==temp1(i,1) & S.esetup_memory_coord(:,2)==temp1(i,2)...
                & S.esetup_background_texture_on(:,1)==v1 & strncmp(S.edata_error_code, 'correct', 7);
            S.expcond1(index)=i;
        end
        
        % Data
        mat_y = NaN(1, numel(settings.plot_bins), numel(cond1));
        mat_y_lower = NaN(1,numel(settings.plot_bins), numel(cond1));
        mat_y_upper =  NaN(1,numel(settings.plot_bins), numel(cond1));
        
        for i = 1:numel(cond1)
            
            index = S.expcond1 == i;
            temp1 = mat1_ini(index,:);
            
            % Get means
            a = [];
            if sum(index)>1
                a = nanmean(temp1);
            elseif sum(index) == 1
                a = temp1;
            end
            [n] = numel(a);
            mat_y(1,1:n,i) = a;
            
            % Get error bars
            settings.bootstrap_on = 0;
            a = plot_helper_error_bar_calculation_v10(temp1, settings);
            try
                mat_y_upper(1,:,i)= a.se_upper;
                mat_y_lower(1,:,i)= a.se_lower;
            end
            settings = rmfield (settings, 'bootstrap_on');
            
        end
        
        % Is there any data to plot?
        a = sum(sum(~isnan(mat_y)));
        
        if a>0
            
            % Initialize structure with data
            plot_set.mat_y = mat_y;
            plot_set.mat_x = settings.plot_bins;
            plot_set.ebars_lower_y = mat_y_lower;
            plot_set.ebars_upper_y = mat_y_upper;
            plot_set.ebars_shade = 1;
            
            % Colors
            plot_set.data_color_max = 10;
            
            % Labels for plotting
            plot_set.xlabel = 'Time after memory cue, ms';
            plot_set.ylabel = 'Firing rate, Hz';
            
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
            for i=1:length(cond1)
                
                % Color
                graphcond = i;
                
                % Find coordinates of a line
                f_rad = 1;
                f_arc = cond1(i);
                [xc,yc] = pol2cart(f_arc*pi/180, f_rad);
                objsize = 0.7;
                
                % Plot cirlce
                h=rectangle('Position', [xc(1)-objsize(1)/2, yc(1)-objsize(1)/2, objsize(1), objsize(1)],...
                    'EdgeColor', plot_set.color1(i,:), 'FaceColor', plot_set.color1(i,:),'Curvature', 0, 'LineWidth', 1);
                
            end
            
            % Cue location
            m = find((cond1)<-90);
            if numel(m)>1
                m=m(1);
            end
            text(0, -2, 'Cue in RF', 'Color', plot_set.color1(m,:),  'FontSize', settings.fontszlabel, 'HorizontalAlignment', 'center')
            
            plot_helper_save_figure;
            close all;
            
        end
        % End of checking whether data exists for plotting
        
        
        %
        %
        %         %% Statistics file
        %
        % %         if temp1_sum>0
        % %
        % %             int1 = [-300, -50];
        % %             ind1 = int_bins > int1(1) & int_bins + settings.bin_length < int1(2);
        % %
        % %             fprintf(fout, '\n \n');
        % %             targettext= sprintf ('ANOVA time and location factors for interval %s to %s ms\n', num2str(int1(1)), num2str(int1(2)) );
        % %             fprintf(fout, targettext);
        % %
        % %             anovatable1=[];
        % %             anovatable1 = mat1_ini(:,ind1,ind_fig);
        % %             factnames{1}={'Time'};
        % %             factnames{2}={'Location'};
        % %
        % %             % Get means and bootstrap data;
        % %             mat1 = anovatable1;
        % %             mat2 = [];
        % %             for i1 = 1:size(mat1, 3)
        % %
        % %                 % Get error bars
        % %                 ind = ~isnan(mat1(:,1,i1));
        % %                 temp1 = mat1(ind,:,i1);
        % %                 settings.tboot1  = 100;
        % %                 a = plot_helper_error_bar_calculation_v10(temp1, settings);
        % %                 try
        % %                     mat2(:,:,i1) = a.bootstrap_matrix;
        % %                 end
        % %
        % %             end
        % %
        % %             anovatable1 = mat2;
        % %
        % %             subjectfactor = anovatable1;
        % %             for i=1:size(subjectfactor,1)
        % %                 subjectfactor(i,:,:)=i;
        % %             end
        % %
        % %             factor1 = anovatable1;
        % %             for i=1:size(factor1,2)
        % %                 factor1(:,i,:)=i;
        % %             end
        % %
        % %             factor2 = anovatable1;
        % %             for i=1:size(factor1,3)
        % %                 factor2(:,:,i)=i;
        % %             end
        % %
        % %             a1=reshape(anovatable1,[],1);
        % %             s1=reshape(subjectfactor,[],1);
        % %             f1=reshape(factor1,[],1);
        % %             f2=reshape(factor2,[],1);
        % %
        % %             stats=rm_anova2(a1, s1, f1, f2, factnames);
        % %
        % %
        % %         end
        %
        %     end
        %
        % end
        % % End of plotting each figure
        %
        %
        %
        % %% Save output of the analysis
        %
        % % Prepare output structure that can be read out later
        % if i_unit == settings.index_of_units_subset(1)
        %     st = struct;
        %     a = settings.index_of_units_available;
        %     st.visual_response = NaN(numel(a), 1);
        %     st.max_visual_response_coords = NaN(numel(a), 2);
        % end
        %
        % % Copy whatever result into structure
        % a = settings.index_of_current_unit;
        % st.visual_response(a, 1) = 1;
        % st.max_visual_response_coords(a,:) = [NaN, NaN];
        %
        % % Save output if it's last unit analyzed
        % if i_unit == settings.index_of_units_subset(end)
        %
        %     % Create file path
        %     [path1, path1_short, ~] = get_generate_path_v10(settings, settings.temp1_data_folder, '_unit_descriptives.mat');
        %     if ~isdir (path1_short)
        %         mkdir(path1_short);
        %     end
        %
        %     % Load file
        %     if isfile(path1)
        %         temp1 = get_struct_v11(path1);
        %     else
        %         temp1 = struct;
        %     end
        %
        %     % Add fieldnames of analysis
        %     f1 = fieldnames(st);
        %     for i = 1:numel(f1)
        %         temp1.(f1{i}) = st.(f1{i});
        %     end
        %
        %     % Save file
        %     save (path1, 'temp1');
        
    end
    
    %% Plot figure
    
    if fig1==3
        
        plot_set = struct;
        
        % Determine exp versions used
        cond1 = cell(1);
        cond1{1} = 'look';
        cond1{2} = 'avoid';
        cond1{3} = 'control fixate';
        
        % Initialize matrices
        int_bins = 1:50:numel(S.session);
        
        % Plot bins
        pbins = [];
        for i = 1:numel(int_bins)-1
            pbins(i) = (int_bins(i)+int_bins(i+1))/2;
        end
        
        % Data
        mat_y = NaN(1, numel(int_bins)-1, numel(cond1));
        mat_y_lower = NaN(1,numel(int_bins)-1, numel(cond1));
        mat_y_upper =  NaN(1,numel(int_bins)-1, numel(cond1));
        
        
        % Sliding window analysis
        for j = 1:length(int_bins)-1
                
                ind = int_bins(j):1:int_bins(j+1);
                
                % Correct trials
                index = S.esetup_background_texture_on(ind,1)==v1;
               
                % Spikes
                temp0 = mat1_ini(ind,1);
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
        
        % Is there any data to plot?
        a = sum(sum(~isnan(mat_y)));
        
        if a>0
            
            hfig = figure;
            hold on;
            
            %===========
            % Plot blocked conditions
            
            % Correct block_number variable
            block_no = S.esetup_block_no;
            if max(S.session)>1
                for i = 2:max(S.session)
                    ind = find(S.session==i);
                    block_no(ind) = S.esetup_block_no(ind) + S.esetup_block_no(ind(1)-1);
                end
            end
            
            %============
            % Plot each block color
            for i=1:max(block_no)
                
                ind = find(block_no==i);
                if ~isempty(ind)
                    c1 = unique(S.esetup_block_cond(ind));
                    % Define coordinates of the square
                    x1 = ind(1); x2 = (ind(end)-ind(1))+1;
                    y1 = 0; y2 = 3000;
                    % Color
                    if strcmp(c1, 'look')
                        color1 = settings.face_color1(5,:);
                    elseif  strcmp(c1, 'avoid')
                        color1 = settings.face_color1(6,:);
                    elseif  strcmp(c1, 'control fixate')
                        color1 = settings.face_color1(8,:);
                    end
                    
                    h = rectangle('Position', [x1, y1, x2, y2], 'FaceColor', color1, 'EdgeColor', 'none');
                end
            end
            
            
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
            
            % Save data
            plot_set.figure_size = settings.figsize_1col;
            plot_set.figure_save_name = sprintf ('%s_fig_%s', settings.neuron_name, num2str(fig1));
            plot_set.path_figure = path_fig;
            
            % Plot
            plot_helper_basic_line_figure;
            
            plot_helper_save_figure;
            close all;
            
        end
        

    end
    
end
