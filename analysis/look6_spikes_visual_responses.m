% Prepare each figure

num_fig = [1];

for fig1 = num_fig % Plot figures
    
    fprintf('Preparing figure %s out of %s total for this analysis\n', num2str(fig1), num2str(numel(num_fig)))
    
    S.expcond = NaN(size(S.START));
    
    %==============
    % Plot data for look, avoid or control conditions
    % (for each location separatelly)
    
    if fig1==1
        
        temp1 = unique(S.esetup_memory_coord, 'rows');
        [th,radiusdeg] = cart2pol(temp1(:,1), temp1(:,2));
        theta = (th*180)/pi;
        legend1_values = theta;
        
        % Texture on
        i1=0;
        for i=1:size(temp1,1)
            index = S.esetup_memory_coord(:,1)==temp1(i,1) & S.esetup_memory_coord(:,2)==temp1(i,2) & S.esetup_background_texture_on(:,1)==1 & strcmp(S.edata_error_code, 'correct');
            S.expcond(index)=i+i1;
        end
        
        % No texture
        i1=size(temp1,1)*1;
        for i=1:size(temp1,1)
            index = S.esetup_memory_coord(:,1)==temp1(i,1) & S.esetup_memory_coord(:,2)==temp1(i,2) & S.esetup_background_texture_on(:,1)==0  & strcmp(S.edata_error_code, 'correct');
            S.expcond(index)=i+i1;
        end
        
        % Indicate what is expected condition number
        cond1 = 1:size(temp1,1)*2;
        
        % Determine selected offset in the time (for example between first display and memory onset)
        S.tconst = S.memory_on - S.first_display;
        
        % Select appropriate interval for plottings
        int_bins = [-300:50:300];
        settings.bin_length = settings.bin_length;
        
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
    
    
    
    %% Plot data
    
    if fig1==1 || fig1==2
        
        plot_set = struct;
        
        % Data
        if fig1==1
            ind_fig = 1:length(legend1_values);
            plot_set.data_color_min = [1];
            plot_set.figure_title = 'Texture trials';
        elseif fig1==2
            m = length(legend1_values);
            ind_fig = m*1+1:m*2;
            plot_set.data_color_min = [1];
            plot_set.figure_title = 'No texture trials';
        end
        
        % Data
        mat_y = [];
        mat_y = mat2_ini(:,:,ind_fig);
        
        % Is there any data to plot?
        temp1_sum = sum(sum(~isnan(mat_y)));
        
        if temp1_sum>0
            
            % Initialize structure with data
            plot_set.mat_y = mat_y;
            plot_set.mat_x = pbins;
            plot_set.ebars_lower = mat2_ini_lower(:,:,ind_fig);
            plot_set.ebars_upper = mat2_ini_upper(:,:,ind_fig);
            plot_set.ebars_shade = 1;
            
            % Colors
            plot_set.data_color_min = 9;
            plot_set.data_color_max = 10;
            
            % Labels for plotting
            plot_set.xlabel = 'Time after memory on, ms';
            plot_set.ylabel = 'Firing rate, Hz';
            plot_set.xtick = [-250, 0: 250: 1000];
            
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
        
        
        %% Statistics file
        
%         if temp1_sum>0
%             
%             int1 = [-300, -50];
%             ind1 = int_bins > int1(1) & int_bins + settings.bin_length < int1(2);
%             
%             fprintf(fout, '\n \n');
%             targettext= sprintf ('ANOVA time and location factors for interval %s to %s ms\n', num2str(int1(1)), num2str(int1(2)) );
%             fprintf(fout, targettext);
%             
%             anovatable1=[];
%             anovatable1 = mat1_ini(:,ind1,ind_fig);
%             factnames{1}={'Time'};
%             factnames{2}={'Location'};
%             
%             % Get means and bootstrap data;            
%             mat1 = anovatable1;
%             mat2 = [];
%             for i1 = 1:size(mat1, 3)
%                 
%                 % Get error bars
%                 ind = ~isnan(mat1(:,1,i1));
%                 temp1 = mat1(ind,:,i1);
%                 settings.tboot1  = 100;
%                 a = plot_helper_error_bar_calculation_v10(temp1, settings);
%                 try
%                     mat2(:,:,i1) = a.bootstrap_matrix;
%                 end
%                 
%             end
%             
%             anovatable1 = mat2;
%             
%             subjectfactor = anovatable1;
%             for i=1:size(subjectfactor,1)
%                 subjectfactor(i,:,:)=i;
%             end
%             
%             factor1 = anovatable1;
%             for i=1:size(factor1,2)
%                 factor1(:,i,:)=i;
%             end
%             
%             factor2 = anovatable1;
%             for i=1:size(factor1,3)
%                 factor2(:,:,i)=i;
%             end
%             
%             a1=reshape(anovatable1,[],1);
%             s1=reshape(subjectfactor,[],1);
%             f1=reshape(factor1,[],1);
%             f2=reshape(factor2,[],1);
%             
%             stats=rm_anova2(a1, s1, f1, f2, factnames);
%             
%        
%         end
        
    end
    
end
% End of plotting each figure



%% Save output of the analysis

% Prepare output structure that can be read out later
if i_unit == settings.index_of_units_subset(1)
    st = struct;
    a = settings.index_of_units_available;
    st.visual_response = NaN(numel(a), 1);
    st.max_visual_response_coords = NaN(numel(a), 2);
end

% Copy whatever result into structure
a = settings.index_of_current_unit;
st.visual_response(a, 1) = 1;
st.max_visual_response_coords(a,:) = [NaN, NaN];

% Save output if it's last unit analyzed
if i_unit == settings.index_of_units_subset(end)
    
    % Create file path
    [path1, path1_short, ~] = get_generate_path_v10(settings, settings.temp1_data_folder, '_unit_descriptives.mat');
    if ~isdir (path1_short)
        mkdir(path1_short);
    end
    
    % Load file
    if isfile(path1)
        temp1 = get_struct_v11(path1);
    else
        temp1 = struct;
    end
    
    % Add fieldnames of analysis
    f1 = fieldnames(st);
    for i = 1:numel(f1)
        temp1.(f1{i}) = st.(f1{i});
    end
    
    % Save file
    save (path1, 'temp1');
    
end
