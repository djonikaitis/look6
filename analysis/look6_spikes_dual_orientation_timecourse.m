% Prepare each figure

if size (S.esetup_background_texture_on, 2) == 2 % Only if two textures were presented
    
num_fig = 1:3;

for fig1 = num_fig % Plot figures
    
    fprintf('Preparing figure %s out of %s total for this analysis\n', num2str(fig1), num2str(numel(num_fig)))
      
        
        S.expcond = NaN(numel(S.START), 2);
        
        %==============
        % Texture vs no texture condition, works as basic
        % selection criterion for visual responsiveness of
        % neurons
        if fig1==1 || fig1==2 || fig1==3
            
            
            % Plot no orientation trials too
            index = S.esetup_background_texture_on(:,1) == 0;
            S.esetup_background_texture_line_angle(index,1) = 270;
            index = S.esetup_background_texture_on(:,2) == 0;
            S.esetup_background_texture_line_angle(index,2) = 270;
            
            % Texture
            m1 = unique(S.esetup_background_texture_line_angle(:,1));
            orientation1 = m1;
            
            % Were two textures presented during the trial?
            S.esetup_background_texture_double = NaN(numel(S.START), 1);
            index = ~isnan(S.esetup_background_texture_on(:,1) + S.esetup_background_texture_on(:,2));
            S.esetup_background_texture_double(index) = 1;
            
            % One condition per texture
            for i=1:numel(orientation1)
                index = S.esetup_background_texture_line_angle(:,1) == orientation1(i) & S.esetup_background_texture_double == 1 & strncmp(S.edata_error_code, 'correct', 7);
                S.expcond(index,1)=i;
            end
            
            % One condition per texture
            for i=1:numel(orientation1)
                index = S.esetup_background_texture_line_angle(:,2) == orientation1(i) & S.esetup_background_texture_double == 1 & strncmp(S.edata_error_code, 'correct', 7);
                S.expcond(index,2)=i;
            end
            
            % Indicate what is expected condition number
            cond1 = 1:numel(orientation1);
            
            % Determine selected offset in the time (for example between first display and memory onset)
            if isfield (S, 'texture_on_2')
                S.tconst = S.texture_on_2 - S.first_display;
            else
                S.tconst = (S.edata_background_texture_onset_time(:,2) - S.edata_first_display(:,1))*1000;
                temp1 = NaN(numel(S.START), 1);
                for i=1:numel(S.eframes_time)
                    a1 = find(S.eframes_texture_on{i} == 1);
                    a2 = find(S.eframes_texture_on{i} == 2);
                    if ~isempty(a1) && ~isempty(a2)
                        t1 = S.eframes_time{i}(1);
                        t2 = S.eframes_time{i}(a2(1));
                        temp1(i) = (t2-t1)*1000;
                    end
                end
                fprintf('No messages found for the texture onset time; Using psychtoolbox data. Average data error: %s ms\n', num2str (nanmean(S.tconst-temp1)) )
            end
            
            % Select appropriate interval for plottings
            int_bins = [-450:50:450];
            
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
            mat1_ini = NaN(size(S.expcond,1), numel(int_bins), numel(cond1), 2);
            test1 = NaN(1, length(cond1), 2);
            
            % How many trials recorded for each condition?
            for j = 1:2
                for k=1:length(cond1)
                    index = S.expcond(:,j) == cond1(k);
                    test1(1,k,j)=sum(index);
                end
            end
            
            %=============
            % Calculate spiking rates
            
            for tid = 1:size(mat1_ini,1)
                for j = 1:length(int_bins)
                    for k=1:length(cond1)
                        for m = 1:2 % Pre and post second texture
                            
                            c1 = S.expcond(tid,m); % Which condition it is currently?
                            
                            % If particular conditon on a given trial
                            % exists, then calculate firing rates
                            if ~isnan(c1) && c1==k
                                
                                % Index
                                index = t1_spike >= t1(tid) + int_bins(j) & ...
                                    t1_spike <= t1(tid) + int_bins(j) + settings.bin_length & ...
                                    S.expcond(tid,m) == cond1(k);
                                
                                % Save data
                                if sum(index)==0
                                    mat1_ini(tid,j,c1,m)=0; % Save as zero spikes
                                elseif sum(index)>0
                                    mat1_ini(tid,j,c1,m)=sum(index); % Save spikes counts
                                end
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
        
        if new_mat==1
            
            % Get means and bootstrap data;
            [~,n,o,p] = size(mat1_ini);
            mat2_ini = NaN(1, n, o, p);
            mat2_ini_upper = NaN(1, n, o, p);
            mat2_ini_lower = NaN(1, n, o, p);
            
            for i1 = 1:size(mat1_ini, 3)
                for p = 1:size(mat1_ini, 4)
                    
                    % Get average data
                    mat2_ini(1,:,i1, p)= nanmean(mat1_ini(:, :, i1, p));
                    
                    % Get error bars
                    ind = ~isnan(mat1_ini(:,1,i1, p));
                    temp1 = mat1_ini(ind,:,i1, p);
                    a = plot_helper_error_bar_calculation_v10(temp1, settings);
                    try
                        mat2_ini_upper(1,:,i1,p)= a.se_upper;
                        mat2_ini_lower(1,:,i1,p)= a.se_lower;
                    end
                end
            end
            
        end
        
        %% Plot the data
        
        if fig1==1 || fig1==2 || fig1==3
            
            % Data
            mat1 = []; m1=[]; m2=[];
            plot_set = struct;
            
            if fig1==1
                mat1 = mat2_ini(:,:,1:numel(orientation1), 1);
                m1 = mat2_ini_lower(:,:,:,1);
                m2 = mat2_ini_upper(:,:,:,1);
                plot_set.figure_title = 'Texture 1 selectivity';
            elseif fig1==2
                mat1 = mat2_ini(:,:,1:numel(orientation1), 2);
                m1 = mat2_ini_lower(:,:,:,2);
                m2 = mat2_ini_upper(:,:,:,2);
                plot_set.figure_title = 'Texture 2 selectivity';
            elseif fig1==3
                ind = pbins<=0;
                mat1(:,ind,:) = mat2_ini(:,ind,:, 1);
                m1(:,ind,:) = mat2_ini_lower(:,ind,:,1);
                m2(:,ind,:) = mat2_ini_upper(:,ind,:,1);
                ind = pbins>0;
                mat1(:,ind,:) = mat2_ini(:,ind,:, 2);
                m1(:,ind,:) = mat2_ini_lower(:,ind,:,2);
                m2(:,ind,:) = mat2_ini_upper(:,ind,:,2);
                plot_set.figure_title = 'Texture 1 and 2 selectivity';
            end
            
            % Initialize structure with data
            plot_set.mat_y = mat1;
            plot_set.ebars_lower = m1;
            plot_set.ebars_upper = m2;
            plot_set.mat_x = pbins;
            plot_set.ebars_shade = 1;
            
            % Colors
            plot_set.data_color_min = [23];
            plot_set.data_color_max = [21];
            
            
            % Labels for plotting
            plot_set.xtick = [-400:200:400];
            plot_set.xlabel = 'Time relative to texture 2, ms';
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
            
            % Initialize data values for plotting
            m = find((orientation1)==270);
            for i=1:length(orientation1)
                
                if i~=m
                    % Color
                    graphcond = i;
                    
                    % Find coordinates of a line
                    f_rad = 1;
                    f_arc = orientation1(i);
                    [xc,yc] = pol2cart(f_arc*pi/180, f_rad);
                    
                    % Plot lines
                    h = plot([0, xc(1)], [0, yc(1)], 'Color', plot_set.color1(i,:), 'LineWidth', 1.8);
                    
                elseif i==m
                    text(0, -0.5, 'No tex', 'Color', plot_set.color1(m,:),  'FontSize', settings.fontszlabel, 'HorizontalAlignment', 'center')
                end
                
            end
            
            plot_helper_save_figure;
            close all;
        end
                
        
    end
    % End of plotting each figure
    
end
% End of checking if to plot a figure






