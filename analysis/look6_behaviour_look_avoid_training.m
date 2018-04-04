
% Prepare each figure

num_fig = [1];

%=====================
% Initialize a few variables
task_names_used = unique(S.esetup_block_cond);
exp_versions_used = unique(S.esetup_exp_version);

error_code_subset = cell(1);
error_code_subset{1} = 'correct';
error_code_subset{2} = 'broke fixation';
error_code_subset{3} = 'looked at st2';

%====================
% Group data differently

S.expcond = cell(size(S.session,1),1);

index1 = (strcmp(S.esetup_exp_version, 'task switch luminance equal') | strcmp(S.esetup_exp_version, 'task switch luminance change')) ...
    & strcmp(S.esetup_block_cond, 'look');
t1 = 'task switch - look';
S.expcond(index1) = {t1};

index1 = (strcmp(S.esetup_exp_version, 'task switch luminance equal') | strcmp(S.esetup_exp_version, 'task switch luminance change')) ...
    & strcmp(S.esetup_block_cond, 'avoid');
t1 = 'task switch - avoid';
S.expcond(index1) = {t1};

index1 = (strcmp(S.esetup_exp_version, 'look luminance equal') | strcmp(S.esetup_exp_version, 'look luminance change'));
t1 = 'single task - look';
S.expcond(index1) = {t1};

index1 = (strcmp(S.esetup_exp_version, 'avoid luminance equal') | strcmp(S.esetup_exp_version, 'avoid luminance change'));
t1 = 'single - avoid';
S.expcond(index1) = {t1};

index1 = strncmp(S.esetup_exp_version, 'control', 7);
t1 = 'control task';
S.expcond(index1) = {t1};

task_names_used_alternate = unique(S.expcond);

%====================
% Multi-day figure folders

% Remove single day figures folder
if isdir (path_fig)
    rmdir(path_fig, 's');
end

% Create figures folder
if ~isempty(settings.dates_used) && settings.date_current == settings.dates_used(end)
    
    % Path
    if numel(settings.dates_used)>1
        a = sprintf('dates %s - %s', num2str(settings.dates_used(1)), num2str(settings.dates_used(end)));
        [b, ~, ~] = get_generate_path_v10(settings, 'figures');
        path_fig = sprintf('%s%s/', b, a);
    elseif numel(settings.dates_used)==1
        [~, path_fig, ~] = get_generate_path_v10(settings, 'figures');
    end
    
    % Overwrite figure folders
    if ~isdir(path_fig)
        mkdir(path_fig)
    elseif isdir(path_fig) && settings.overwrite==1
        try
            rmdir(path_fig, 's')
        end
        mkdir(path_fig)
    end
    
end


%% Plot

for fig1 = 1:numel(num_fig) % Plot figures
    
    %===============
    % Data analysis
    %===============
    
    % Initialize matrices
    if settings.date_current == settings.dates_used(1)
        test1 = NaN(1, numel(settings.dates_used), numel(task_names_used_alternate), 3);
        conds1 = task_names_used_alternate;
    end
    
    % Add extra conditions if needed
    if settings.date_current ~= settings.dates_used(1)
        for i = 1:numel(task_names_used_alternate)
            a = strcmp(conds1, task_names_used_alternate{i});
            if sum(a) == 0
                m = numel(conds1);
                conds1{m+1,1} = task_names_used_alternate{i};
                test1(1, :, m+1, 1:3) = NaN;
            end
        end
    end
    
    for k=1:numel(conds1)
        for m = 1:numel(error_code_subset)
            index1 = strncmp(S.edata_error_code, error_code_subset{m}, numel(error_code_subset{m})) & ...
                strcmp(S.expcond, conds1{k});
            test1(1, i_date, k, m)= sum(index1);
        end
    end
    
    % Save conds1 output
    task_subset_used = conds1;
    
    %================
    % Subplot 1-2
    %================
    
    if ~isempty(settings.dates_used) && settings.date_current == settings.dates_used(end)
        
        close all;
        
        settings.figure_current = num_fig(fig1);
        fprintf('\nPreparing figure %s out of %s total for this analysis\n', num2str(fig1), num2str(numel(num_fig))  )
        
        %================
        % Figure size
        
        fig_subplot_dim = [1, 2];
        fig_size = [0, 0, fig_subplot_dim(2) * settings.figsize_1col(3), fig_subplot_dim(1) * settings.figsize_1col(4)];
        
        % Is there data to plot?
        data_mat.mat_y = test1;
        [i,j,k,m,o] = size(data_mat.mat_y);
        mat_y = reshape(data_mat.mat_y, 1, i*j*k*m*o);
        
        fig_plot_on = sum(sum(isnan(mat_y))) ~= numel(mat_y);
        
        %=================
        % Subplot 1
        %=================
        
        if fig_plot_on == 1
            
            hfig = subplot(fig_subplot_dim(1), fig_subplot_dim(2), 1);
            hold on;
            
            % Data
            temp1 = [];
            ind1 = strcmp(error_code_subset, 'correct');
            temp1(:,:,:,1) = test1(:,:,:,ind1);
            ind1 = strcmp(error_code_subset, 'looked at st2');
            temp1(:,:,:,2) = test1(:,:,:,ind1);
            
            total1 = temp1(:,:,:,1); % Sum across training stages
            total2 = nansum(temp1, 4); % Sum across correct/error trials
            
            mat1 = total1./total2*100;
            
            % Initialize structure
            plot_set = struct;
            plot_set.mat_y = mat1;
            plot_set.plot_remove_nan = 0;
            
            plot_set.data_color = numel(task_subset_used);
            ind = strcmp(task_subset_used, 'task switch - look');
            plot_set.data_color(ind) = 1;
            ind = strcmp(task_subset_used, 'task switch - avoid');
            plot_set.data_color(ind) = 2;
            ind = strcmp(task_subset_used, 'single task - look');
            plot_set.data_color(ind) = 5;
            ind = strcmp(task_subset_used, 'single task - avoid');
            plot_set.data_color(ind) = 6;
            ind = strcmp(task_subset_used, 'control task');
            plot_set.data_color(ind) = 3;
            
            % Labels for plotting
            plot_set.ytick = [0:25:100];
            plot_set.figure_title = 'Performance';
            plot_set.xlabel = 'Day number';
            plot_set.ylabel = '% trials correct';
            
            for i=1:size(mat1,3)
                plot_set.legend{i} = conds1{i};
                plot_set.legend_y_coord(i) = i*-10;
            end
            plot_set.ylim = [min(plot_set.legend_y_coord)-10, 110];
            
            % Plot
            plot_helper_line_plot_v10;
            
        end
        
        %=================
        % Subplot 2
        %=================
        
        if fig_plot_on == 1
            
            hfig = subplot(fig_subplot_dim(1), fig_subplot_dim(2), 2);
            hold on;
            
            % Data
            total2 = nansum(test1, 4); % Sum across correct/error trials
            ind1 = strcmp(error_code_subset, 'broke fixation');
            mat1 = test1(:,:,:,ind1)./total2*100;
            
            % Initialize structure
            plot_set = struct;
            plot_set.mat_y = mat1;
            plot_set.plot_remove_nan = 0;
            
            plot_set.data_color = numel(task_subset_used);
            ind = strcmp(task_subset_used, 'task switch - look');
            plot_set.data_color(ind) = 1;
            ind = strcmp(task_subset_used, 'task switch - avoid');
            plot_set.data_color(ind) = 2;
            ind = strcmp(task_subset_used, 'single task - look');
            plot_set.data_color(ind) = 5;
            ind = strcmp(task_subset_used, 'single task - avoid');
            plot_set.data_color(ind) = 6;
            ind = strcmp(task_subset_used, 'control task');
            plot_set.data_color(ind) = 3;
            
            % Labels for plotting
            plot_set.ytick = [0:25:100];
            plot_set.figure_title = 'Aborted trials';
            plot_set.xlabel = 'Day number';
            plot_set.ylabel = '% of trials';
            
            for i=1:size(mat1,3)
                plot_set.legend{i} = conds1{i};
                plot_set.legend_y_coord(i) = i*-10;
            end
            plot_set.ylim = [min(plot_set.legend_y_coord)-10, 110];
            
            % Plot
            plot_helper_line_plot_v10;
            
        end
        
        %==========
        % Save data
        %==========
        
        if fig_plot_on==1
            
            plot_set.figure_size = fig_size;
            plot_set.figure_save_name = sprintf ('%s %s fig%s', settings.subject_current, num2str(settings.date_current), num2str(settings.figure_current));
            plot_set.path_figure = path_fig;
            
            plot_helper_save_figure;
            close all;
        end
        
    end
        
end


