% Psychophysics performance

% Show file you are running
p1 = mfilename;
fprintf('\n=========\n')
fprintf('Current file:  %s\n', p1)
fprintf('=========\n')

% Loading the files needed
if ~exist('settings', 'var')
    settings = struct;
end
settings = get_settings_ini_v11(settings);


%% Extra settings

settings.figure_folder_name = 'srt position';
settings.figure_size_temp = settings.figsize_1col;
settings.stats_file_name = sprintf('statistics_%s_', settings.figure_folder_name);

for i_subj=1:length(settings.subjects)
    
    % Select curent subject
    settings.subject_current = settings.subjects{i_subj};
    
    % Get subject folder paths and dates to analyze
    settings = get_settings_path_and_dates_ini_v11(settings);
    dates_used = settings.data_sessions_to_analyze;
    
    % Analysis for each day
    for i_date = 1:numel(dates_used)
        
        % Current folder to be analysed (raw date, with session index)
        date_current = dates_used(i_date);
        ind0 = date_current==settings.index_dates;
        folder_name = settings.index_directory{ind0};
        
        % Data folders
        path1 = [settings.path_data_combined_subject, folder_name, '/', folder_name, '.mat'];
        path2 = [settings.path_data_combined_subject, folder_name, '/', folder_name, '_saccades.mat'];
        
        % Load all files
        S = get_struct_v11(path1);
        sacc1 = get_struct_v11(path2);
        
        %===============
        % Figure folder
        temp_switch = 0;
        if numel(dates_used)>1 && i_date==1
            a = sprintf('dates %s - %s', num2str(dates_used(1)), num2str(dates_used(end)));
            path_fig = sprintf('%s%s/%s/%s/', settings.path_figures, settings.figure_folder_name, settings.subject_current, a);
            temp_switch = 1;
        elseif numel(dates_used)>1 && i_date>1
            temp_switch = 0;
        elseif numel(dates_used)==1
            path_fig = sprintf('%s%s/%s/%s/', settings.path_figures, settings.figure_folder_name, settings.subject_current, folder_name);
            temp_switch = 1;
        end
        
        % Overwrite figure folders
        if  temp_switch == 1
            if ~isdir(path_fig) || settings.overwrite==1
                if ~isdir(path_fig)
                    mkdir(path_fig)
                elseif isdir(path_fig)
                    try
                        rmdir(path_fig, 's')
                    end
                    mkdir(path_fig)
                end
            end
        end
        
        % Initialize text file for statistics
        if  temp_switch == 1
            nameOut = sprintf('%s%s.txt', path_fig, settings.stats_file_name); % File to be outputed
            fclose('all');
            fout = fopen(nameOut,'w');
        end
        
        %% Analysis
        
        % Reset data
        if isfield(S, 'target_on')
            S.sacconset = sacc1.saccade_matrix(:,1)-S.target_on;
        end
        
        %==============
        % Exp condition
        S.expcond = NaN(size(S.session,1),1);
        
        index1 = strncmp(sacc1.trial_accepted, 'correct', 7) & S.esetup_target_number==1 & strcmp(S.esetup_block_cond, 'look') & ...
            S.esetup_response_soa==0 & S.esetup_st2_color_level==0 & cell2mat(S.probe_extended_map)==1;
        S.expcond(index1)=1;
        
        index1 = strncmp(sacc1.trial_accepted, 'correct', 7) & S.esetup_target_number==1 & strcmp(S.esetup_block_cond, 'avoid') & ...
            S.esetup_response_soa==0 & S.esetup_st2_color_level==0 & cell2mat(S.probe_extended_map)==1;
        S.expcond(index1)=2;
        
        index1 = strncmp(sacc1.trial_accepted, 'correct', 7) & S.esetup_target_number==1 & strcmp(S.esetup_block_cond, 'control fixate') & ...
            S.esetup_response_soa==0 & S.esetup_st2_color_level==0 & cell2mat(S.probe_extended_map)==1;
        S.expcond(index1)=3;
        
        %===============
        % Memory position
        [th,radius1] = cart2pol(S.esetup_memory_coord(:,1), S.esetup_memory_coord(:,2));
        arc1 = (th*180)/pi;
        m1 = [round(arc1,1), round(radius1, 1)];
        m2 = unique(m1, 'rows');
        S.esetup_memory_arc = round(m1(:,1), 1);
        S.esetup_memory_radius = round(m1(:,2), 1);
        
        
        % ST1 position
        [th,radius1] = cart2pol(S.esetup_st1_coord(:,1), S.esetup_st1_coord(:,2));
        arc1 = (th*180)/pi;
        m1 = [round(arc1,1), round(radius1, 1)];
        m2 = unique(m1, 'rows');
        S.esetup_st1_arc = round(m1(:,1),1);
        S.esetup_st1_radius = round(m1(:,2), 1);
        
        % Find relative probe-memory position
        S.rel_arc = S.esetup_memory_arc - S.esetup_st1_arc;
        S.rel_rad = S.esetup_st1_radius./S.esetup_memory_radius;
        % Round off
        S.rel_arc = round(S.rel_arc, 1);
        S.rel_rad = round(S.rel_rad, 1);
        % Reset to range -180:180
        ind = S.rel_arc<=-180;
        S.rel_arc(ind)=S.rel_arc(ind)+360;
        ind = S.rel_arc>180;
        S.rel_arc(ind)=S.rel_arc(ind)-360;
        
        % Determine unique stimulus positions
        if i_date==1
            b=cell(numel(dates_used), 1);
        end
        ind = ~isnan(S.expcond);
        if sum(ind)>0
            a = [S.rel_arc(ind), S.rel_rad(ind), S.esetup_memory_radius(ind)];
            b{i_date} =  unique(a,'rows');
        end
        
        % Initialize coordinates matrix
        if i_date == 1
            coords1 = [];
            conds1 = [];
        end
        
        % Add concatenation over different days
        if numel(b)>0
            coords1 = cell2mat(b);
            coords1 = unique(coords1,'rows');
        end
        
        % In the first instance, initialize all variables
        if ~isempty(coords1) && isempty(conds1)
            conds1 = coords1;
            mat1_ini = cell(numel(dates_used), size(conds1,1), 3);
            test1 = NaN(length(dates_used), size(conds1,1), 3);
        end
        
        % In later instances, add extra conds1 values
        if ~isempty(coords1) && ~isempty(conds1)
            for i=1:size(coords1,1)
                a = [];
                for j = 1:size(conds1,2)
                    a(:,j) =  conds1(:,j) == coords1(i,j);
                end
                a = sum(a,2);
                % If element is missing, add it to conds matrix
                if sum(a==3)==0
                    % Add element to conds1
                    [m,n] = size(conds1);
                    conds1(m+1,1:n) = coords1(i,1:n);
                    % Add element to mat1_ini
                    [~, n, o] = size(test1);
                    test1(:, n+1, 1:o) = NaN;
                end
            end
        end
        
        %% SRT 
        
        for i=1:size(conds1,1)
            for j=1:max(removeNaN(S.expcond))
                
                index1 = S.expcond==j & S.rel_arc==conds1(i,1) & S.rel_rad==conds1(i,2) &...
                    S.esetup_memory_radius==conds1(i,3);
                
                if sum(index1)>0
                    mat1_ini{i_date,i,j} = S.sacconset(index1);
                end
                test1(i_date,i,j)=sum(index1);
                
            end
        end
        
        
    end
    % End of each day
    
    
    %% Plot figure for each participant separately
    
    % Combine multipe days into one matrix;
    % Get means and bootstrap data;
    [~,n,o] = size(mat1_ini);
    mat2_ini = NaN(1, n, o);
    mat2_ini_upper = NaN(1, n, o);
    mat2_ini_lower = NaN(1, n, o);

    
    for i1 = 1:size(mat1_ini, 3)
        
        % Combine days into one matrix
        mat0 = cell(size(conds1,1), 1);
        for i=1:size(conds1,1)
            c1 = cell(1);
            c1{1} = mat1_ini(:,i,i1);
            mat0{i} = cell2mat(c1{1});
        end
        
        % Get pbins
        [pbins, b_ind] = sort(conds1(:,1), 'ascend');
        
        % Get average data
        for j1=1:size(mat2_ini, 2)
            mat2_ini(1,j1,i1)= median(mat0{b_ind(j1)});
        end
        
        % Get error bars
        for j1=1:size(mat2_ini, 2)
            temp1 = mat0{b_ind(j1)};
            a = plot_helper_error_bar_calculation_v10(temp1, settings);
            try
                mat2_ini_upper(1,j1,i1)= a.se_upper;
                mat2_ini_lower(1,j1,i1)= a.se_lower;
            end
        end
        
    end
    
    %% Figure 1
    
    if ~isempty(dates_used)
        
        % Initialize data
        %=================
        fig1=1;
        
        % Data
        mat1 = [];
        mat1(:,:,1:3) = mat2_ini(:,:,1:3);

        % Initialize structure
        plot_set = struct;
        plot_set.mat1 = mat1;
        plot_set.pbins = pbins;
        
        plot_set.data_color = [1, 2, 3];
        
        for i=1:size(mat1,3)
            plot_set.legend{1} = 'Look';
            plot_set.legend{2} = 'Avoid';
            plot_set.legend{3} = 'Control fixate';
            plot_set.legend_y_coord(i) = 100 - (i*10);
            plot_set.legend_x_coord(i) = [pbins(1)];
        end
        
        % Labels for plotting
        plot_set.XTick = [-90:90:90];
        plot_set.x_plot_bins = pbins;
        plot_set.XLim = [pbins(1)-5, pbins(end)+5];
        plot_set.YTick = [100:25:200];
        plot_set.YLim = [min(plot_set.legend_y_coord)-10, 205];
        plot_set.figure_title = 'Performance';
        plot_set.xlabel = 'Probe position, deg';
        plot_set.ylabel = 'RT, ms';
        
        % Save data
        plot_set.figure_size = settings.figure_size_temp;
        plot_set.figure_save_name = 'figure';
        plot_set.path_figure = path_fig;
        
        % Plot
        hfig = figure;
        hold on;
        plot_helper_basic_line_figure;
        
        plot_helper_save_figure;
        close all;
    end
        
    
end
% End of each subject





%
%     %===============
%     %===============
%     % ANALYSIS
%     %===============
%     %===============
%
%     % Find distances needed
%     if bilateral1==1
%         index=S.objposrel<0;
%         S.objposrel(index)=S.objposrel(index)+360; % Reset them all to the positive axis
%         probeposConds=(unique(removeNaN(S.objposrel)));
%     elseif bilateral1==2
%         S.objposrel=abs(S.objposrel);
%         probeposConds=(unique(removeNaN(S.objposrel)));
%     end
%


%
% %% Plot
%
% for fig_legend1=2
%     for fig1=[1:3]
%
%         % Reset to figure to the limits chosen
%         tickrange1=maxaxis1-minaxis1;
%         tick_small_temp=tick_small-minaxis1;
%         tick_small_temp(tick_small_temp<=0)=[];
%         tick_large_temp=tick_large-minaxis1;
%         tick_large_temp(tick_large_temp<=0)=[];
%
%         % Initialize the data
%         hfig=figure;
%         set (gca, 'Color', [1,1,1])
%         hold on;
%         axis equal
%
%         %================
%         % Plot figure outlines
%
%         % Fill in the largest circle
%         if tick_small_temp(end)>=tick_large_temp(end)
%             ticks1=[tickrange1];
%             cpos1 = [0,0];
%             cl1=[0.9,0.9,0.9];
%         else
%             ticks1=[tickrange1];
%             cpos1 = [0,0];
%             cl1=[0.7,0.7,0.7];
%         end
%         h=rectangle('Position', [cpos1(1,1)-ticks1, cpos1(1,2)-ticks1, ticks1*2, ticks1*2],...
%             'EdgeColor', cl1, 'FaceColor', [1,1,1], 'Curvature', 1, 'LineWidth', 0.7, 'LineStyle', '-');
%
%
%         % Draw vertical and horizontal lines
%         cl1=[0.7,0.7,0.7];
%         h=plot([-tickrange1, tickrange1], [0,0]);
%         set (h(end), 'LineWidth', 0.7, 'Color', cl1)
%         h=plot([0,0], [-tickrange1, tickrange1]);
%         set (h(end), 'LineWidth', 0.7, 'Color', cl1)
%
%         % Fill the the central cirlce
%         if tick_small_temp(1)<=tick_large_temp(1)
%             ticks1=[tick_small_temp(1)];
%             cpos1 = [0,0];
%             cl1=[0.9,0.9,0.9];
%         else
%             ticks1=[tick_large_temp(1)];
%             cpos1 = [0,0];
%             cl1=[0.7,0.7,0.7];
%         end
%         h=rectangle('Position', [cpos1(1,1)-ticks1, cpos1(1,2)-ticks1, ticks1*2, ticks1*2],...
%             'EdgeColor', cl1, 'FaceColor', [1,1,1], 'Curvature', 1, 'LineWidth', 0.7, 'LineStyle', '-');
%
%         % Plot small cirlces
%         cpos1 = [0,0];
%         ticks1=[tick_small_temp];
%         cl1=[0.9,0.9,0.9];
%         for i=1:length(ticks1);
%             h=rectangle('Position', [cpos1(1,1)-ticks1(i), cpos1(1,2)-ticks1(i), ticks1(i)*2, ticks1(i)*2],...
%                 'EdgeColor', cl1, 'FaceColor', 'none', 'Curvature', 1, 'LineWidth', 0.7, 'LineStyle', '-');
%         end
%
%         % Plot large cirlces
%         cpos1 = [0,0];
%         ticks1=[tick_large_temp];
%         cl1=[0.7,0.7,0.7];
%         for i=1:length(ticks1);
%             h=rectangle('Position', [cpos1(1,1)-ticks1(i), cpos1(1,2)-ticks1(i), ticks1(i)*2, ticks1(i)*2],...
%                 'EdgeColor', cl1, 'FaceColor', 'none', 'Curvature', 1, 'LineWidth', 0.7, 'LineStyle', '-');
%         end
%
%         % Set up the limits of the graph
%         set(gca,'YLim',[-tickrange1 tickrange1]);
%         set(gca,'XLim',[-tickrange1 tickrange1]);
%
%
%         %================
%         % Plot the data
%         %================
%
%         mat2=mat1_data-minaxis1; % Reset the matrix to minimal axis
%         d2 = d1_data-minaxis1;
%         f2 = f1_data-minaxis1;
%
%
%         conds1=[]; figcolor1=[];
%         save_name=sprintf('fig%d', fig1);
%
%         if fig1==1
%             conds1=[3,4];
%             figcolor1=[1,2];
%             title1 = 'Main task';
%         elseif fig1==2
%             conds1=[1,3];
%             figcolor1=[1,2];
%             title1 = 'Look task';
%         elseif fig1==3
%             conds1=[2,4];
%             figcolor1=[1,2];
%             title1 = 'Avoid task';
%         elseif fig1==4
%
%         end
%
%         %=================
%         % Determine which plot-bins & data is used
%
%         pbins={};
%         mat1=NaN(size(mat2,1),size(mat2,2),length(conds1)); % Initialize empty matrix
%         mj1=NaN(size(mat2,1),size(mat2,2),length(conds1)); % Initialize empty matrix
%         mj2=NaN(size(mat2,1),size(mat2,2),length(conds1)); % Initialize empty matrix
%
%
%         for k=1:length(conds1)
%
%             pbins2=NaN(1,size(mat2,2)); % Initialize empty matrix
%             index=S.expcond==conds1(k);
%             p_rel1=unique(removeNaN(S.objposrel(index))); % Find displacements for each condition
%
%             % GENERAL PART
%             % Select relevant data
%             for m=1:length(p_rel1);
%                 index2=[];
%                 index2=find(probeposConds==p_rel1(m));
%                 pbins2(1,m) = probeposConds(index2);
%                 mat1(:,m,k) = mat2(:,index2,conds1(k));
%                 mj1(:,m,k) = d2(:,index2,conds1(k));
%                 mj2(:,m,k) = f2(:,index2,conds1(k));
%             end
%
%             % SPECIFIC PART
%             % Add extra values if needed
%             %========
%             % Two sides are plotted
%             if bilateral1==1
%                 if fig1==1
%                     pbins{k}=pbins2;
%                 elseif fig1==2
%                     if k==1
%                         pbins2(1,m+1)=360;
%                         pbins{k}=pbins2;
%                         mat1(:,m+1,k)=mat1(:,1,k);
%                         mj1(:,m+1,k)=mj1(:,1,k);
%                         mj2(:,m+1,k)=mj2(:,1,k);
%                     elseif k==2
%                         pbins{k}=pbins2;
%                     end
%                 elseif fig1==3
%                     if k==1
%                         pbins2(1,m+1)=360;
%                         pbins{k}=pbins2;
%                         mat1(:,m+1,k)=mat1(:,1,k);
%                         mj1(:,m+1,k)=mj1(:,1,k);
%                         mj2(:,m+1,k)=mj2(:,1,k);
%                     elseif k==2
%                         pbins{k}=pbins2;
%                     end
%                 end
%             end
%
%         end
%
%
%
%         %=====================
%         % Plot ERROR BARS
%         for k=1:size(mat1,3)
%
%             % Select only data with existing data in it
%             index=isfinite(pbins{k});
%             plotbins=pbins{k};
%             plotbins=plotbins(index);
%             d1=mj1(:,index,k);
%             f1=mj2(:,index,k);
%
%             graphcond=figcolor1(k);
%
%             % Plot error bars
%             if length(plotbins)>1
%
%                 % Set up x (error) and a (angle on the circle)
%                 xc1=f1(:,1,:); % Max error, 1st point
%                 xc2=d1(:,1,:); % Min error, 1st point
%                 xc3=d1(:,:,:); % Lower bound of error
%                 xc4=d1(:,end,:); % Min error, last point
%                 xc5=f1(:,end,:); % Max error, last point
%                 xc6=f1(:,:,:); % Upper bound of error
%                 ac1=plotbins(1);
%                 ac2=plotbins(1);
%                 ac3=plotbins;
%                 ac4=plotbins(end);
%                 ac5=plotbins(end);
%                 ac6=plotbins;
%
%                 % Extrapolate
%                 xc11=xc1;
%                 xc22=xc2;
%                 xc33=interp1(ac3,xc3,xi, 'linear');
%                 index_0=isfinite(xc33);
%                 xc33=xc33(index_0);
%                 xc44=xc4;
%                 xc55=xc5;
%                 xc66=interp1(ac6,xc6,xi, 'linear');
%                 index_1=isfinite(xc66);
%                 xc66=xc66(index_1);
%                 ac11=ac1;
%                 ac22=ac2;
%                 ac33=xi(index_0);
%                 ac44=ac4;
%                 ac55=ac5;
%                 ac66=xi(index_1);
%
%                 % Convert to polar coordinates
%                 [x1,y1]=pol2cart(ac11*pi/180,xc11);
%                 [x2,y2]=pol2cart(ac22*pi/180,xc22);
%                 [x3,y3]=pol2cart(ac33*pi/180,xc33);
%                 [x4,y4]=pol2cart(ac44*pi/180,xc44);
%                 [x5,y5]=pol2cart(ac55*pi/180,xc55);
%                 [x6,y6]=pol2cart(ac66*pi/180,xc66);
%                 x6=fliplr(x6);
%                 y6=fliplr(y6);
%
%                 % Plot the error bars
%                 h=fill([x1,x2,x3,x4,x5,x6],[y1, y2, y3, y4, y5, y6], [1 0.7 0.2],'linestyle','none');
%                 set (h(end), 'FaceColor', facecolor1(graphcond,:,:),'linestyle', 'none', 'FaceAlpha', 1)
%
%             end
%         end
%
%         % PLOT MEANS
%         for k=1:size(mat1,3)
%
%             % Select only data with existing data in it
%             index=isfinite(pbins{k});
%             plotbins=pbins{k};
%             plotbins=plotbins(index);
%             mat1_plot2=mat1(:,index,k);
%
%             % Plot circle lines
%             if length(plotbins)>1
%                 if size(mat1,1)>1
%                     yInt = interp1(plotbins,nanmean(mat1_plot2),xi, 'linear');
%                 else
%                     yInt = interp1(plotbins,mat1_plot2,xi, 'linear');
%                 end
%                 [xc, yc] = pol2cart(xi*pi/180,yInt);
%                 h=plot(xc, yc);
%                 graphcond=figcolor1(k);
%                 set (h(end), 'LineWidth', wlinegraph, 'Color', color1(graphcond,:))
%             end
%
%             % Plot markers
%             if (fig1==1 && k==1) || settings.marker_on==1
%                 if size(mat1,1)>1
%                     [xc, yc] = pol2cart(plotbins*pi/180,nanmean(mat1_plot2));
%                 else
%                     [xc, yc] = pol2cart(plotbins*pi/180,mat1_plot2);
%                 end
%                 for j=1:length(xc)
%                     h=plot(xc(j), yc(j));
%                     graphcond=figcolor1(k);
%                     set (h(end), 'Marker', marker1{graphcond}, 'MarkerFaceColor', color1(graphcond,:), 'MarkerEdgeColor', color1(graphcond,:), ...
%                         'MarkerSize', 6)
%                 end
%             end
%
%             % Plot error bar for the marker
%             if (fig1==1 && k==1)
%                 yInt=mj2(:,1,k);
%                 [xc1, yc1] = pol2cart(0*pi/180,yInt);
%                 yInt=mj1(:,1,k);
%                 [xc2, yc2] = pol2cart(0*pi/180,yInt);
%                 h=plot([xc1,xc2],[yc1,yc2]);
%                 graphcond=figcolor1(k);
%                 set (h(end), 'LineWidth', wlineerror, 'Color', color1(graphcond,:))
%             end
%         end
%
%         % Add tick marks
%         ticks1=[tick_large_temp,tick_small_temp];
%         ticks1labels=[tick_large_temp+minaxis1, tick_small_temp+minaxis1]; % Plots real values
%         for i=1:length(ticks1)
%             [x,y] = pol2cart(plotang*pi/180,ticks1(i));
%             if ticks1labels(i)~=max(ticks1labels)
%                 text(x,y, num2str(ticks1labels(i)), 'FontSize', fontsz, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
%             else
%                 text(x,y, ['SRT ', num2str(ticks1labels(i)), ' ms'], 'FontSize', fontsz, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
%             end
%         end
%
%         % FIGURE SETUP
%         set (gca,'FontSize', fontsz);
%         set (gca,'Visible', 'off');
%
%         % Figure title
%         title (title1, 'FontSize', fontszlabel)
%
%         %============
%         % Export the figure & save it
%
%         settings.subject_path = [settings.figures_directory, sprintf('%s/%s/', settings.figure_folder_name, sN1) ];
%         if isdir (settings.subject_path)
%             cd (settings.subject_path)
%         else
%             mkdir (settings.subject_path)
%         end
%
%         if fig_legend1==1
%             fileName=[settings.subject_path, save_name, '_no_legend'];
%         elseif fig_legend1==2
%             fileName=[settings.subject_path, save_name];
%         end
%         set(gcf, 'PaperPositionMode', 'manual');
%         set(gcf, 'PaperUnits', 'inches');
%         set(gcf, 'PaperPosition', settings.figsize)
%         set(gcf, 'PaperSize', [settings.figsize(3),settings.figsize(4)]);
%         print (fileName, '-dpdf')
%         close all;
%         %===============
%         %
%         %     %==================
%         %     %==================
%         %     %=================
%         %     % Bootstrap statistics
%         %
%         %     if max(S.subjectNo)>1 && runstatistics==1 && error1==1 && (fig1==1 || fig1==2) && bilateral1==1;
%         %
%         %         fprintf(fout, '\n \n');
%         %         targettext='Bootstrap stats comparing two conditions of interest \n \n';
%         %         fprintf(fout, targettext);
%         %
%         %         if fig1==1
%         %             num_of_comparisons=3;
%         %         elseif fig1==2
%         %             num_of_comparisons=1;
%         %         end
%         %
%         %         % Test 1
%         %         for j=1:num_of_comparisons;
%         %             if j==1 && fig1==1
%         %                 fprintf(fout, '\n');
%         %                 targettext='Look vs avoid \n';
%         %                 fprintf(fout, targettext);
%         %                 diff1=b1(:,1:12)-b1(:,13:24);
%         %             elseif j==2 && fig1==1
%         %                 fprintf(fout, '\n');
%         %                 targettext='Look vs control \n';
%         %                 fprintf(fout, targettext);
%         %                 diff1=b1(:,1:12)-b1(:,25:36);
%         %             elseif j==3 && fig1==1
%         %                 fprintf(fout, '\n');
%         %                 targettext='Avoid vs control \n';
%         %                 fprintf(fout, targettext);
%         %                 diff1=b1(:,13:24)-b1(:,25:36);
%         %             elseif j==1 && fig1==2
%         %                 fprintf(fout, '\n');
%         %                 targettext='Alerting task vs control task \n';
%         %                 fprintf(fout, targettext);
%         %                 diff1=b1(:,1:12)-b1(:,13:24);
%         %             end
%         %
%         %             % Find p-values
%         %             pval=NaN(1,size(diff1,2));
%         %             for i=1:length(pval)
%         %                 if mean (diff1(:,i))>0 & sum(diff1(:,i)>0)>0
%         %                     pval(i) = (sum(diff1(:,i)<0)/tboot1);
%         %                 elseif mean (diff1(:,i))>0 & sum(diff1(:,i)>0)==0
%         %                     pval(i) = (1/tboot1);
%         %                 elseif mean (diff1(:,i))<0 & sum(diff1(:,i)>0)>0
%         %                     pval(i) = (sum(diff1(:,i)>0)/tboot1);
%         %                 elseif mean (diff1(:,i))<0 & sum(diff1(:,i)>0)==0
%         %                     pval(i) = (1/tboot1);
%         %                 end
%         %             end
%         %
%         %             % Make a two sided t-test
%         %             pval=pval*2;
%         %
%         %             targettext='Bootstrapped mean difference 2 \n';
%         %             fprintf(fout, targettext);
%         %             for i=1:size(diff1,2)
%         %                 targettext='%.2f ;';
%         %                 fprintf(fout, targettext, nanmean(diff1(:,i)));
%         %             end
%         %             fprintf(fout, '\n');
%         %             nanmean(diff1)
%         %
%         %             targettext='Bootstrapped  SD of the difference 2 \n';
%         %             fprintf(fout, targettext);
%         %             for i=1:size(diff1,2)
%         %                 targettext='%.2f ;';
%         %                 fprintf(fout, targettext, std(diff1(:,i)));
%         %             end
%         %             fprintf(fout, '\n');
%         %             nanmean(diff1)
%         %
%         %             targettext='Bootstrapped statistics 2 \n';
%         %             fprintf(fout, targettext);
%         %             for i=1:size(pval,2)
%         %                 targettext='%.4f ;';
%         %                 fprintf(fout, targettext, pval(i));
%         %             end
%         %             fprintf(fout, '\n');
%         %
%         %         end
%         %     end
%         %     %==================
%         %
%     end
% end
%
% % %% STATISTICS
% %
% % %================
% % % Latencies
% %
% %
% % if max(S.subjectNo)>1 && runstatistics==1
% %
% %     S.expcond2=NaN(size(S.data,1),1);
% %
% %     index=S.maincond==1 & S.trialaccepted==-1 & S.responsecond==2; % Look trials (2 targest)
% %     S.expcond2(index)=1;
% %     index=S.maincond==1 & S.trialaccepted==-1 & S.objposrel==0 & S.responsecond==1; % Look trials probe
% %     S.expcond2(index)=2;
% %     index=S.maincond==1 & S.trialaccepted==-1 & S.objposrel~=0 & S.responsecond==1; % Look trials probe non-cued
% %     S.expcond2(index)=3;
% %     index=S.maincond==2 & S.trialaccepted==-1 & S.responsecond==2; % Avoid trials (2 targest)
% %     S.expcond2(index)=4;
% %     index=S.maincond==2 & S.trialaccepted==-1 & S.objposrel==0 & S.responsecond==1; % Avopid trials (catch)
% %     S.expcond2(index)=5;
% %     index=S.maincond==2 & S.trialaccepted==-1 & S.objposrel~=0 & S.responsecond==1; % Avoid trials (catch)
% %     S.expcond2(index)=6;
% %     index=S.maincond==3 & S.trialaccepted==-1 & S.objposrel==0 & S.responsecond==1; % Alerting
% %     S.expcond2(index)=7;
% %     index=S.maincond==3 & S.trialaccepted==-1 & S.objposrel~=0 & S.responsecond==1; % Alerting
% %     S.expcond2(index)=8;
% %     index=S.maincond==4 & S.trialaccepted==-1 & S.objposrel==0 & S.responsecond==1; % Control
% %     S.expcond2(index)=9;
% %     index=S.maincond==4 & S.trialaccepted==-1 & S.objposrel~=0 & S.responsecond==1; % Control
% %     S.expcond2(index)=10;
% %
% %
% %     % SRT
% %     lat1=NaN(max(S.subjectNo), max(S.expcond2),1);
% %     for i=1:max(S.expcond2);
% %         for f=1:max(S.subjectNo)
% %             index1=S.expcond2==i & S.subjectNo==f;
% %             if sum(index1)>Threshold
% %                 lat1(f,i)=nanmedian(S.sacconset(index1),1);
% %             end
% %         end
% %     end
% %
% %     %==
% %     fprintf(fout, '\n');
% %     targettext='Latency in the look main task: %.0f +- %.0f ms';
% %     fprintf(fout, targettext, round(nanmean(lat1(:,1))), round(se(lat1(:,1))));
% %     fprintf(fout, '\n');
% %     targettext='Latency to cue location in the look probe task: %.0f +- %.0f ms';
% %     fprintf(fout, targettext, round(nanmean(lat1(:,2))), round(se(lat1(:,2))));
% %     fprintf(fout, '\n');
% %
% %     [a_stat,b_stat,c_stat,d_stat]=ttest(lat1(:,1),lat1(:,2));
% %     targettext='Statistics: t(%d)=%.2f, p=%.4f \n';
% %     fprintf(fout, targettext, d_stat.df, d_stat.tstat, b_stat);
% %     fprintf(fout, '\n');
% %
% %     %==
% %     fprintf(fout, '\n');
% %     targettext='Latency in the avoid main task: %.0f +- %.0f ms';
% %     fprintf(fout, targettext, round(nanmean(lat1(:,4))), round(se(lat1(:,4))));
% %     fprintf(fout, '\n');
% %     targettext='Latency to cue location in the avoid probe task: %.0f +- %.0f ms';
% %     fprintf(fout, targettext, round(nanmean(lat1(:,5))), round(se(lat1(:,5))));
% %     fprintf(fout, '\n');
% %
% %     [a_stat,b_stat,c_stat,d_stat]=ttest(lat1(:,4),lat1(:,5));
% %     targettext='Statistics: t(%d)=%.2f, p=%.4f \n';
% %     fprintf(fout, targettext, d_stat.df, d_stat.tstat, b_stat);
% %     fprintf(fout, '\n');
% %
% %     %==
% %     [a_stat,b_stat,c_stat,d_stat]=ttest(lat1(:,2),lat1(:,5));
% %     targettext='Cued location: look vs avoid probe task: t(%d)=%.2f, p=%.4f \n';
% %     fprintf(fout, targettext, d_stat.df, d_stat.tstat, b_stat);
% %     fprintf(fout, '\n');
% %
% %     %==
% %     fprintf(fout, '\n');
% %     targettext='Latency to the cue in the control task: %.0f +- %.0f ms';
% %     fprintf(fout, targettext, round(nanmean(lat1(:,9))), round(se(lat1(:,9))));
% %     fprintf(fout, '\n');
% %     targettext='Latency away from the cue in the control task: %.0f +- %.0f ms';
% %     fprintf(fout, targettext, round(nanmean(lat1(:,10))), round(se(lat1(:,10))));
% %     fprintf(fout, '\n');
% %
% %     [a_stat,b_stat,c_stat,d_stat]=ttest(lat1(:,9),lat1(:,10));
% %     targettext='Statistics: t(%d)=%.2f, p=%.4f \n';
% %     fprintf(fout, targettext, d_stat.df, d_stat.tstat, b_stat);
% %     fprintf(fout, '\n');
% %
% %     %==
% %     [a_stat,b_stat,c_stat,d_stat]=ttest(lat1(:,2),lat1(:,9));
% %     targettext='Cued location: look probe vs control: t(%d)=%.2f, p=%.4f \n';
% %     fprintf(fout, targettext, d_stat.df, d_stat.tstat, b_stat);
% %     fprintf(fout, '\n');
% %
% %     %==
% %     [a_stat,b_stat,c_stat,d_stat]=ttest(lat1(:,5),lat1(:,9));
% %     targettext='Cued location: avoid probe vs control: t(%d)=%.2f, p=%.4f \n';
% %     fprintf(fout, targettext, d_stat.df, d_stat.tstat, b_stat);
% %     fprintf(fout, '\n');
% %
% %     fprintf(fout, '\n');
% %     targettext='Latency in the look main task: %.0f +- %.0f ms';
% %     fprintf(fout, targettext, round(nanmean(lat1(:,1))), round(se(lat1(:,1))));
% %     fprintf(fout, '\n');
% %     fprintf(fout, '\n');
% %     targettext='Latency in the avoid main task: %.0f +- %.0f ms';
% %     fprintf(fout, targettext, round(nanmean(lat1(:,4))), round(se(lat1(:,4))));
% %     fprintf(fout, '\n');
% %
% %     %==
% %     [a_stat,b_stat,c_stat,d_stat]=ttest(lat1(:,1),lat1(:,4));
% %     targettext='Main task comparisons: look cued vs avoid non-cued: t(%d)=%.2f, p=%.4f \n';
% %     fprintf(fout, targettext, d_stat.df, d_stat.tstat, b_stat);
% %     fprintf(fout, '\n');
% %
% %
% % end
% %
% %
% % %% =================
% %
% % % Add ANOVA
% %
% % if max(S.subjectNo)>1 && runstatistics==1 && bilateral1==1
% %
% %     if bilateral1==1
% %         m1=[1,4,7,10]; % Those columns contain data in bbb (0, 90, 180 and 270 degrees)
% %         n1 = [2,3,5,6,7,8,9,11,12];
% %     elseif bilateral1==2
% %         m1=[1,4,7]; % Those columns contain data in bbb (0, 90, 180 and 270 degrees)
% %     end
% %
% %     for rep1=1:3
% %
% %         if rep1==1
% %             fprintf(fout, '\n \n');
% %             targettext='ANOVA for look vs avoid task \n';
% %             fprintf(fout, targettext);
% %             anovatable1=[];
% %             anovatable1(:,:,1)=mat1(:,m1,1);
% %             anovatable1(:,:,2)=mat1(:,m1,2);
% %         elseif rep1==2
% %             fprintf(fout, '\n \n');
% %             targettext='ANOVA for look vs control task \n';
% %             fprintf(fout, targettext);
% %             anovatable1=[];
% %             anovatable1(:,:,1)=mat1(:,m1,1);
% %             anovatable1(:,:,2)=mat1(:,m1,4);
% %         elseif rep1==3
% %             fprintf(fout, '\n \n');
% %             targettext='ANOVA for avoid vs control task \n';
% %             fprintf(fout, targettext);
% %             anovatable1=[];
% %             anovatable1(:,:,1)=mat1(:,m1,2);
% %             anovatable1(:,:,2)=mat1(:,m1,4);
% %         end
% %
% %         subjectfactor=anovatable1;
% %         for i=1:size(subjectfactor,1)
% %             subjectfactor(i,:,:)=i;
% %         end
% %
% %         factor1=anovatable1;
% %         for i=1:size(factor1,2)
% %             factor1(:,i,:)=i;
% %         end
% %
% %         factor2=anovatable1;
% %         for i=1:size(factor1,3)
% %             factor2(:,:,i)=i;
% %         end
% %
% %         a1=reshape(anovatable1,[],1);
% %         s1=reshape(subjectfactor,[],1);
% %         f1=reshape(factor1,[],1);
% %         f2=reshape(factor2,[],1);
% %         factnames{1}={'Position'};
% %         factnames{2}={'Condition'};
% %
% %         stats=rm_anova2(a1,s1,f1,f2,factnames);
% %
% %         % Write the results into a text file
% %         for i=1:3
% %             if i==1
% %                 var_name1='Main effect: Position';
% %             elseif i==2
% %                 var_name1='Main effect: Condition';
% %             elseif i==3
% %                 var_name1='Interaction: Position * Condition';
% %             end
% %             targettext='%s F(%d,%d)=%.2f, p=%.4f \n';
% %             fprintf(fout, targettext, var_name1, cell2mat(stats(i+1,3)), cell2mat(stats(i+4,3)), cell2mat(stats(i+1,5)), cell2mat(stats(i+1,6)));
% %         end
% %
% %     end
% %
% %     %===================
% %     % Individual condition (effect of stimulus position)
% %
% %     fprintf(fout, '\n \n');
% %     targettext='ANOVA for look probe task main effect of position \n';
% %     fprintf(fout, targettext);
% %     ddd=mat1(:,m1,1);
% %     [a,stats]=anova_rm(ddd(:,:,:));
% %     targettext='%s F(%d,%d)=%.2f, p=%.4f \n';
% %     fprintf(fout, targettext, 'Main effect', cell2mat(stats(2,3)), cell2mat(stats(3,3)), cell2mat(stats(2,5)), cell2mat(stats(2,6)));
% %
% %     fprintf(fout, '\n \n');
% %     targettext='ANOVA for avoid probe task main effect of position \n';
% %     fprintf(fout, targettext);
% %     ddd=mat1(:,m1,2);
% %     [a,stats]=anova_rm(ddd(:,:,:));
% %     targettext='%s F(%d,%d)=%.2f, p=%.4f \n';
% %     fprintf(fout, targettext, 'Main effect', cell2mat(stats(2,3)), cell2mat(stats(3,3)), cell2mat(stats(2,5)), cell2mat(stats(2,6)));
% %
% %     fprintf(fout, '\n \n');
% %     targettext='ANOVA for control task main effect of position \n';
% %     fprintf(fout, targettext);
% %     ddd=mat1(:,m1,4);
% %     [a,stats]=anova_rm(ddd(:,:,:));
% %     targettext='%s F(%d,%d)=%.2f, p=%.4f \n';
% %     fprintf(fout, targettext, 'Main effect', cell2mat(stats(2,3)), cell2mat(stats(3,3)), cell2mat(stats(2,5)), cell2mat(stats(2,6)));
% %
% %     fprintf(fout, '\n \n');
% %     targettext='ANOVA for avoid main task, effect of distractor position relative to the cue\n';
% %     fprintf(fout, targettext);
% %     ddd=mat1(:,n1,6);
% %     [a,stats]=anova_rm(ddd(:,:,:));
% %     targettext='%s F(%d,%d)=%.2f, p=%.4f \n';
% %     fprintf(fout, targettext, 'Main effect', cell2mat(stats(2,3)), cell2mat(stats(3,3)), cell2mat(stats(2,5)), cell2mat(stats(2,6)));
% %
% % end
% %
% % close all;