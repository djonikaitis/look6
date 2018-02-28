% Psychophysics performance

% Remove figure folder that was created by default
try
    rmdir(path_fig, 's')
end

% Initialize matrices on recorded first date
if i_date==1
    conds1 = cell(4,1);
    test1 = NaN(1, numel(settings.dates_used), 4, 3);
end

% Initialize conditions

%==============
% Exp condition
S.expcond = NaN(size(S.session,1),1);

index1 = (strcmp(S.esetup_exp_version, 'task switch luminance equal') | strcmp(S.esetup_exp_version, 'task switch luminance change')) ...
    & strcmp(S.esetup_block_cond, 'look');
S.expcond(index1) = 1;
conds1{1} = 'task switch - look';

index1 = (strcmp(S.esetup_exp_version, 'task switch luminance equal') | strcmp(S.esetup_exp_version, 'task switch luminance change')) ...
    & strcmp(S.esetup_block_cond, 'avoid');
S.expcond(index1) = 2;
conds1{2} = 'task switch - avoid';

index1 = (strcmp(S.esetup_exp_version, 'look luminance equal') | strcmp(S.esetup_exp_version, 'look luminance change'));
S.expcond(index1) = 3;
conds1{3} = 'single task - look';

index1 = (strcmp(S.esetup_exp_version, 'avoid luminance equal') | strcmp(S.esetup_exp_version, 'avoid luminance change'));
S.expcond(index1) = 4;
conds1{4} = 'single task - avoid';


%===============
% Data analysis
%===============

for k=1:numel(conds1)
    
    % Correct trials
    index1 = strncmp(S.edata_error_code, 'correct', 7) & S.expcond==k;
    test1(1,i_date,k,1)= sum(index1);
    
    % Wrong target trials
    index1 = strcmp(S.edata_error_code, 'looked at st2') & S.expcond==k;
    test1(1,i_date,k,2)= sum(index1);
    
    % Aborted trials
    index1 = strcmp(S.edata_error_code, 'broke fixation') & S.expcond==k;
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
    pbins = 1:size(mat1,2);
    
    % Initialize structure
    plot_set = struct;
    plot_set.plot_remove_nan = 0;
    plot_set.mat_y = mat1;
    plot_set.mat_x = pbins;
    
    plot_set.data_color = [1, 2, 5, 6];
    
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
    plot_set.ylabel = '% of trials correct';
    
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
    plot_set.plot_remove_nan = 0;
    plot_set.mat_y = mat1;
    plot_set.mat_x = pbins;
    
    plot_set.data_color = [1, 2, 5, 6];
    
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
    
%     close all;
    
end
% End of plotting





