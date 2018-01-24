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
settings = get_settings_ini_v10(settings);


%% Extra settings

settings.figure_folder_name = 'training performance';
settings.figure_size_temp = settings.figsize_2col;
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
        
        % Get current training conditions
        c1 = unique(S.esetup_exp_version);
        
        % Initialize matrices
        if i_date==1
            conds1 = c1;
            test1 = NaN(1, numel(dates_used), numel(c1), 3);
        end
        
        % Add extra conditions if needed
        if i_date>1
            for i=1:numel(c1)
                a = strcmp(conds1, c1{i});
                if sum(a)==0
                    m = numel(conds1);
                    conds1{m+1,1} = c1{i};
                    test1(1, :, m+1, 1:3) = NaN;
                end
            end
        end
        
        %===============
        % Data analysis
        %===============
        
        for k=1:numel(conds1)
            
            % Correct trials
            index1 = strncmp(S.edata_error_code, 'correct', 7) & ...
                strcmp(S.esetup_exp_version, conds1{k});
            test1(1,i_date,k,1)= sum(index1);
            
            % Wrong target trials
            index1 = strcmp(S.edata_error_code, 'looked at st2') & ...
                strcmp(S.esetup_exp_version, conds1{k});
            test1(1,i_date,k,2)= sum(index1);
            
            % Aborted trials
            index1 = strcmp(S.edata_error_code, 'broke fixation') & ...
                strcmp(S.esetup_exp_version, conds1{k});
            test1(1,i_date,k,3)= sum(index1);
            
        end
        
    end
    % End of analysis for each day
    
    %% Plot ini
    
    if ~isempty(dates_used)
        if numel(dates_used)==1
            pbins = 1:numel(dates_used);
            folder_name = num2str(dates_used);
        else
            pbins =  1:numel(dates_used);
            folder_name = [num2str(dates_used(1)), ' - ', num2str(dates_used(end))];
        end
        
        % Figure folder
        path_fig = sprintf('%s%s/%s/%s/', settings.path_figures, settings.figure_folder_name, settings.subject_current, folder_name);
        
        % Overwrite figure folders
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
        
        % Initialize text file for statistics
        nameOut = sprintf('%s%s.txt', path_fig, settings.stats_file_name); % File to be outputed
        fclose('all');
        fout = fopen(nameOut,'w');
        
    end
    
    %% Figure 1
    
    % Number of subplots
    num_figs = 2;
    
    if ~isempty(dates_used)
        
        % Initialize data
        %=================
        mat1=[];
        fig1=1;
        
        % Data
        total1 = nansum(test1(:,:,:,1:2),4); % Check all conditions combined
        mat1 = test1(:,:,:,1)./total1*100;
        mat1 = 100 - (100 - mat1)*2; % Convert into target selection
        
        % Initialize structure
        plot_set = struct;
        plot_set.mat1 = mat1;
        plot_set.pbins = pbins;
        
        plot_set.data_color_min = [0.5,0.5,0.5];
        plot_set.data_color_max = settings.color1(42,:);
        plot_set.data_color = [];
        
        for i=1:size(mat1,3)
            plot_set.legend{i} = conds1{i};
            plot_set.legend_y_coord(i) = i*-10;
            plot_set.legend_x_coord(i) = [pbins(1)];
        end
        
        % Labels for plotting
        plot_set.XTick = [];
        plot_set.x_plot_bins = pbins;
        plot_set.XLim = [pbins(1)-5, pbins(end)+5];
        plot_set.YTick = [0:25:100];
        plot_set.YLim = [min(plot_set.legend_y_coord)-10, 110];
        plot_set.figure_title = 'Performance';
        plot_set.xlabel = 'Day number';
        plot_set.ylabel = 'Correct target, % of trials';
        
        % Save data
        plot_set.figure_size = settings.figure_size_temp;
        plot_set.figure_save_name = 'figure';
        plot_set.path_figure = path_fig;
        
        % Plot
        hfig = subplot(1, num_figs, fig1);
        hold on;
        plot_helper_basic_line_figure;
    end
    
    %% Figure 2
    
    if ~isempty(dates_used)
        
        
        % Initialize data
        %=================
        mat1=[];
        fig1=2;
        
        % Data
        total1 = nansum(test1(:,:,:,1:3),4); % Check all conditions combined
        mat1 = test1(:,:,:,3)./total1*100;
        
        % Initialize structure
        plot_set = struct;
        plot_set.mat1 = mat1;
        plot_set.pbins = pbins;
        
        plot_set.data_color_min = [0.5,0.5,0.5];
        plot_set.data_color_max = settings.color1(42,:);
        plot_set.data_color = [];
        
        for i=1:size(mat1,3)
            plot_set.legend{i} = conds1{i};
            plot_set.legend_y_coord(i) = i*-10;
            plot_set.legend_x_coord(i) = [pbins(1)];
        end
        
        % Labels for plotting
        plot_set.XTick = [];
        plot_set.x_plot_bins = pbins;
        plot_set.XLim = [pbins(1)-5, pbins(end)+5];
        plot_set.YTick = [0:25:100];
        plot_set.YLim = [min(plot_set.legend_y_coord)-10, 110];
        plot_set.figure_title = 'Aborted trials';
        plot_set.xlabel = 'Day number';
        plot_set.ylabel = '% of trials';
        
        % Save data
        plot_set.figure_size = settings.figure_size_temp;
        plot_set.figure_save_name = 'figure';
        plot_set.path_figure = path_fig;
        
        
        % Plot
        % Initialize figure
        hfig = subplot(1, num_figs, fig1);
        hold on;
        plot_helper_basic_line_figure;
        
        
        %============
        % Export the figure & save it
        
        % Save data
        plot_set.figure_size = settings.figure_size_temp;
        plot_set.figure_save_name = 'figure';
        plot_set.path_figure = path_fig;
        
        plot_helper_save_figure;
        
        close all;
        %===============
    end
    
    
    
end
% End of analysis for each subject



