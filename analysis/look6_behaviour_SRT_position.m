% Psychophysics performance

% Show file you are running
p1 = mfilename;
fprintf('\n=========\n')
fprintf('Current file:  %s\n', p1)
fprintf('=========\n\n')

% Loading the files needed
if ~exist('settings', 'var')
    settings = struct;
end
settings = get_settings_ini_v10(settings);


%% Extra settings

settings.figure_folder_name = 'srt position';
settings.figure_size_temp = settings.figsize_1col;
settings.stats_file_name = sprintf('statistics_%s_', settings.figure_folder_name);


for i_subj=1:length(settings.subjects)
    
    % Select curent subject
    settings.subject_current = settings.subjects{i_subj};
    
    % Which dates to run?
    settings.dates_used = get_dates_used_v10 (settings, 'data_psychtoolbox');
    
    % Analysis for each day
    for i_date = 1:numel(settings.dates_used)
        
        % Which date is it
        settings.date_current = settings.dates_used(i_date);
        
        %============
        % Load all settings
        path1 = get_generate_path_v10(settings, 'data_combined', '.mat');
        S = get_struct_v11(path1);
        
        path1 = get_generate_path_v10(settings, 'data_combined', '_saccades.mat');
        sacc1 = get_struct_v11(path1);
        
        %===============
        % Figure folder
        temp_switch = 0;
        if numel(settings.dates_used)>1 && i_date==1
            a = sprintf('dates %s - %s', num2str(settings.dates_used(1)), num2str(settings.dates_used(end)));
            [b, ~, ~] = get_generate_path_v10(settings, 'figures');
            path_fig = sprintf('%s%s/', b, a);
            temp_switch = 1;
        elseif numel(settings.dates_used)>1 && i_date>1
            temp_switch = 0;
        elseif numel(settings.dates_used)==1
            [~, path_fig, ~] = get_generate_path_v10(settings, 'figures');
            temp_switch = 1;
        end
        
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
        
        % Initialize empty file
        if temp_switch == 1
            f1 = sprintf('stats.txt');
            f_name = sprintf('%s%s', path_fig, f1);
            fclose('all');
            fout = fopen(f_name,'w');
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
            S.esetup_response_soa==0 & S.esetup_st2_color_level==0;
        S.expcond(index1)=1;
        
        index1 = strncmp(sacc1.trial_accepted, 'correct', 7) & S.esetup_target_number==1 & strcmp(S.esetup_block_cond, 'avoid') & ...
            S.esetup_response_soa==0 & S.esetup_st2_color_level==0;
        S.expcond(index1)=2;
        
        index1 = strncmp(sacc1.trial_accepted, 'correct', 7) & S.esetup_target_number==1 & strcmp(S.esetup_block_cond, 'control fixate') & ...
            S.esetup_response_soa==0 & S.esetup_st2_color_level==0;
        S.expcond(index1)=3;
        
        %===============
        % Memory position
        [th,radius1] = cart2pol(S.esetup_memory_coord(:,1), S.esetup_memory_coord(:,2));
        arc1 = (th*180)/pi;
        m1 = [round(arc1,1), round(radius1, 1)];
        m2 = unique(m1, 'rows');
        S.esetup_memory_arc = m1(:,1);
        S.esetup_memory_radius = m1(:,2);
        
        % ST1 position
        [th,radius1] = cart2pol(S.esetup_st1_coord(:,1), S.esetup_st1_coord(:,2));
        arc1 = (th*180)/pi;
        m1 = [round(arc1,1), round(radius1, 1)];
        m2 = unique(m1, 'rows');
        S.esetup_st1_arc = m1(:,1);
        S.esetup_st1_radius = m1(:,2);
        
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
            b=cell(numel(settings.dates_used), 1);
        end
        ind = ~isnan(S.expcond);
        if sum(ind)>0
            a = [S.rel_arc(ind), S.rel_rad(ind)];
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
            mat1_ini = cell(numel(settings.dates_used), size(conds1,1), 3);
            test1 = NaN(length(settings.dates_used), size(conds1,1), 3);
        end
        
        % In later instances, add extra conds1 values
        if ~isempty(coords1) && ~isempty(conds1)
            for i=1:size(coords1,1)
                a = conds1(:,1) == coords1(i,1) & conds1(:,2) == coords1(i,2);
                a = sum(a);
                % If element is missing, add it to conds matrix
                if a==0
                    % Add element to conds1
                    [m,n] = size(conds1);
                    conds1(m+1,1:n) = coords1(i,1:n);
                    % Add element to test1
                    [~, n, o] = size(test1);
                    test1(:, n+1, 1:o) = NaN;
                end
            end
        end
        
        %% SRT 
        
        for i=1:size(conds1,1)
            for j=1:max(removeNaN(S.expcond))
                
                index1 = S.expcond==j & S.rel_arc==conds1(i,1) & S.rel_rad==conds1(i,2);
                
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
    test2_ini = NaN(1, n, o);
    mat2_ini_upper = NaN(1, n, o);
    mat2_ini_lower = NaN(1, n, o);

    for i1 = 1:size(mat1_ini, 3) % For each condition
        
        % Get pbins
        [pbins, b_ind] = sort(conds1(:,1), 'ascend');
        if size(pbins,1)>1
            pbins = pbins';
        end
        
        % Restructure data in ascending order
        mat0 = cell(1, numel(b_ind));
        for j1 = 1:numel(b_ind)
            ind1 = b_ind(j1);
            c1 = mat1_ini(:,ind1,i1);
            mat0{1,j1} = cell2mat(c1);
        end
        
        % Get average data
        for j1=1:size(mat2_ini, 2)
            if numel(mat0{j1})>=settings.trial_total_threshold
                mat2_ini(1,j1,i1)= mean(mat0{j1});
            end
        end
        
        % Get error bars
        for j1=1:size(mat2_ini, 2)
            temp1 = mat0{j1};
            if numel(mat0{j1})>=settings.trial_total_threshold
                a = plot_helper_error_bar_calculation_v10(temp1, settings);
                try
                    mat2_ini_upper(1,j1,i1)= a.se_upper;
                    mat2_ini_lower(1,j1,i1)= a.se_lower;
                end
            end
        end
        
        % Save number of trials for controlling effects
        for j1=1:size(test2_ini, 2)
            test2_ini(1,j1,i1)= numel(mat0{j1});
        end
        
    end
    
    %% Figure 1
    
    if ~isempty(settings.dates_used)
        
        % Initialize data
        %=================
        fig1=1;
        
        % Data
        mat1 = [];
        mat1(:,:,1:3) = mat2_ini(:,:,1:3);

        % Initialize structure
        plot_set = struct;
        plot_set.mat_y = mat1;
        plot_set.mat_x = pbins;
        plot_set.plot_remove_nan = 1;
        plot_set.ebars_min = mat2_ini_lower(:,:,1:3);
        plot_set.ebars_max = mat2_ini_upper(:,:,1:3);
        plot_set.ebars_shade = 0;
        
        plot_set.data_color = [1, 2, 3];
        
        for i=1:size(mat1,3)
            plot_set.legend{1} = 'Look';
            plot_set.legend{2} = 'Avoid';
            plot_set.legend{3} = 'Control fixate';
            plot_set.legend_y_coord(i) = 100 - (i*10);
            plot_set.legend_x_coord(i) = [pbins(1)];
        end
        
        % Labels for plotting
        plot_set.XTick = [-180:90:180];
        plot_set.x_plot_bins = pbins;
        plot_set.XLim = [pbins(1)-10, pbins(end)+10];
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


