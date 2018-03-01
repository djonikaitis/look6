% Psychophysics performance


% Get current training conditions
c1 = unique(S.esetup_exp_version);

% Initialize matrices
if i_date==1
    conds1 = c1;
    test1 = NaN(1, numel(settings.dates_used), numel(c1), 3);
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


%% Plot data

if ~isempty(settings.dates_used) && i_date == numel(settings.dates_used)
    
    %===============
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
    
    
    %% Figure 1
    
    % Number of subplots
    num_figs = 2;
    
    % Initialize data
    %=================
    mat1=[];
    fig1=1;
    
    % Data
    total1 = nansum(test1(:,:,:,1:2),4); % Check all conditions combined
    mat1 = test1(:,:,:,1)./total1*100;
    mat1 = 100 - (100 - mat1)*2; % Convert into target selection
    pbins = 1:size(mat1,2);
    
    % Initialize structure
    plot_set = struct;
    plot_set.mat_y = mat1;
    plot_set.mat_x = pbins;
    
    plot_set.data_color_min = [0.5,0.5,0.5];
    plot_set.data_color_max = settings.color1(42,:);
    plot_set.data_color = [];
    
    for i=1:size(mat1,3)
        plot_set.legend{i} = conds1{i};
        plot_set.legend_y_coord(i) = i*-10;
        plot_set.legend_x_coord(i) = [pbins(1)];
    end
    
    % Labels for plotting
    plot_set.YTick = [0:25:100];
    plot_set.YLim = [min(plot_set.legend_y_coord)-10, 110];
    plot_set.figure_title = 'Performance';
    plot_set.xlabel = 'Day number';
    plot_set.ylabel = 'Correct target, % of trials';
    
    % Save data
    plot_set.figure_size = settings.figsize_2col;
    plot_set.figure_save_name = 'figure';
    plot_set.path_figure = path_fig;
    
    % Plot
    hfig = subplot(1, num_figs, fig1);
    hold on;
    plot_helper_basic_line_figure;
    
    
    %% Figure 2
    
    
    % Initialize data
    %=================
    mat1=[];
    fig1=2;
    
    % Data
    total1 = nansum(test1(:,:,:,1:3),4); % Check all conditions combined
    mat1 = test1(:,:,:,3)./total1*100;
    pbins = 1:size(mat1,2);
    
    % Initialize structure
    plot_set = struct;
    plot_set.mat_y = mat1;
    plot_set.mat_x = pbins;
    
    plot_set.data_color_min = [0.5,0.5,0.5];
    plot_set.data_color_max = settings.color1(42,:);
    plot_set.data_color = [];
    
    for i=1:size(mat1,3)
        plot_set.legend{i} = conds1{i};
        plot_set.legend_y_coord(i) = i*-10;
        plot_set.legend_x_coord(i) = [pbins(1)];
    end
    
    % Labels for plotting
    plot_set.YTick = [0:25:100];
    plot_set.YLim = [min(plot_set.legend_y_coord)-10, 110];
    plot_set.figure_title = 'Aborted trials';
    plot_set.xlabel = 'Day number';
    plot_set.ylabel = '% of trials';
    
    % Save data
    plot_set.figure_size = settings.figsize_2col;
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
    plot_set.figure_size = settings.figsize_2col;
    plot_set.figure_save_name = 'figure';
    plot_set.path_figure = path_fig;
    
    plot_helper_save_figure;
    
    close all;
    %===============
    
end






