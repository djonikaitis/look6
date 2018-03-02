% Psychophysics performance


% Reset data
if isfield(S, 'target_on')
    S.sacconset = sacc1.saccade_matrix(:,1)-S.target_on;
end


%==============
% Exp condition
S.expcond = NaN(size(S.session,1),1);

index1 = strncmp(sacc1.trial_accepted, 'correct', 7) & S.esetup_target_number==1 & strcmp(S.esetup_block_cond, 'look') & ...
    S.esetup_response_soa==0 & S.esetup_st2_color_level==0 & strcmp(S.probe_extended_map, 'plexon recording');
S.expcond(index1)=1;

index1 = strncmp(sacc1.trial_accepted, 'correct', 7)  & S.esetup_target_number==1 & strcmp(S.esetup_block_cond, 'avoid') & ...
    S.esetup_response_soa==0 & S.esetup_st2_color_level==0 & strcmp(S.probe_extended_map, 'plexon recording');
S.expcond(index1)=2;

index1 = strncmp(sacc1.trial_accepted, 'correct', 7)  & S.esetup_target_number==2 & strcmp(S.esetup_block_cond, 'look') & ...
    S.esetup_response_soa==0 & S.esetup_st2_color_level==0 & strcmp(S.probe_extended_map, 'plexon recording');
S.expcond(index1)=3;

index1 = strncmp(sacc1.trial_accepted, 'correct', 7)  & S.esetup_target_number==2 & strcmp(S.esetup_block_cond, 'avoid') & ...
    S.esetup_response_soa==0 & S.esetup_st2_color_level==0 & strcmp(S.probe_extended_map, 'plexon recording');
S.expcond(index1)=4;

index1 = strcmp(sacc1.trial_accepted, 'wrong target') & S.esetup_target_number==2 & strcmp(S.esetup_block_cond, 'look') & ...
    S.esetup_response_soa==0 & S.esetup_st2_color_level==0 & strcmp(S.probe_extended_map, 'plexon recording');
S.expcond(index1)=5;

index1 = strcmp(sacc1.trial_accepted, 'wrong target') & S.esetup_target_number==2 & strcmp(S.esetup_block_cond, 'avoid') & ...
    S.esetup_response_soa==0 & S.esetup_st2_color_level==0 & strcmp(S.probe_extended_map, 'plexon recording');
S.expcond(index1)=6;

%===============
% Memory position
[th,radius1] = cart2pol(S.esetup_memory_coord(:,1), S.esetup_memory_coord(:,2));
arc1 = (th*180)/pi;
m1 = [round(arc1,1), round(radius1,1)];
m2 = unique(m1, 'rows');
S.esetup_memory_arc = m1(:,1);
S.esetup_memory_radius = m1(:,2);

% ST1 position
[th,radius1] = cart2pol(S.esetup_st1_coord(:,1), S.esetup_st1_coord(:,2));
arc1 = (th*180)/pi;
m1 = [round(arc1,1), round(radius1,1)];
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
    mat1_ini = NaN(numel(settings.dates_used), size(conds1,1), 8);
    mat2_ini = NaN(numel(settings.dates_used), 8);
    test1 = NaN(length(settings.dates_used), size(conds1,1), 8);
    mat3_ini = [];
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
            % Add element to mat1_ini
            [~, n, o] = size(mat1_ini);
            mat1_ini(:, n+1, 1:o) = NaN;
            test1(:, n+1, 1:o) = NaN;
        end
    end
end


% SRT
for i=1:size(conds1,1)
    for j=1:max(removeNaN(S.expcond))
        
        index1 = S.expcond==j & S.rel_arc==conds1(i,1) & S.rel_rad==conds1(i,2);
        
        if sum(index1)>settings.trial_total_threshold
            mat1_ini(i_date,i,j)=nanmedian(S.sacconset(index1),1);
        end
        test1(i_date,i,j)=sum(index1);
        
    end
end


%% PLOT DATA

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
    
    plot_set = struct;
    mat1=[];
    
    % Look correct and error
    m1 = nanmean(mat1_ini,2);
    mat1(:,1,1) = m1(:,3);
    mat1(:,2,1) = m1(:,4);
    % Avoid correct and error
    mat1(:,1,2) = m1(:,5);
    mat1(:,2,2) = m1(:,6);
    
    % Initialize structure
    plot_set.mat1 = mat1;
    
    plot_set.bar_width = 0.05;
    plot_set.pbins = plot_helper_bargraph_coordinates_x_v10(plot_set);
    
    plot_set.data_color = [9,10];
    
    plot_set.XTick = [];
    plot_set.x_plot_bins = plot_set.pbins;
    plot_set.xtick_label{1} = 'Correct';
    plot_set.xtick_label{2} = 'Error';
    plot_set.XLim = [plot_set.pbins(1)-0.1, plot_set.pbins(end)+0.1];
    plot_set.YTick = [100:25:200];
    plot_set.YLim = [90, 225];
    plot_set.figure_title = 'Main task trials';
    plot_set.xlabel = ' ';
    plot_set.ylabel = 'Reaction time, ms';
    
    plot_set.legend{1} = 'Look';
    plot_set.legend{2} = 'Avoid';
    for i=1:numel(plot_set.legend{1})
        plot_set.legend_y_coord(i) = 100;
        plot_set.legend_x_coord(i) = plot_set.pbins(i);
    end
    
    % Saving data
    plot_set.figure_size = settings.figsize_1col;
    plot_set.figure_save_name = 'main task';
    plot_set.path_figure = path_fig;
    
    
    %==================
    % Plot
    
    hfig = figure;
    hold on;
    
    e_bars = plot_helper_error_bar_calculation_v10(mat1, settings);
    plot_helper_bargraph_plot_v10
    
    plot_helper_save_figure;
    close all;
    
    
    
    
    %% FIGURE 2
    
    plot_set = struct;
    mat1=[];
    
    % Cued location
    a1 = conds1(:,1)==0 & conds1(:,2)==1;
    ind1 = find(a1==1);
    % Un-cued location
    a1 = conds1(:,1)==180 & conds1(:,2)==1;
    ind2 = find(a1==1);
    
    % Look correct and error
    mat1(:,1,1)=mat1_ini(:,ind1,1);
    mat1(:,2,1)=mat1_ini(:,ind2,1);
    % Avoid correct and error
    mat1(:,1,2)=mat1_ini(:,ind1,2);
    mat1(:,2,2)=mat1_ini(:,ind2,2);
    
    % Initialize structure
    plot_set.mat1 = mat1;
    
    plot_set.bar_width = 0.05;
    plot_set.pbins = plot_helper_bargraph_coordinates_x_v10(plot_set);
    
    plot_set.data_color = [9,10];
    
    plot_set.XTick = [];
    plot_set.x_plot_bins = plot_set.pbins;
    plot_set.xtick_label{1} = 'Look';
    plot_set.xtick_label{2} = 'Avoid';
    plot_set.XLim = [plot_set.pbins(1)-0.1, plot_set.pbins(end)+0.1];
    plot_set.YTick = [100:25:175];
    plot_set.YLim = [90, 180];
    plot_set.figure_title = 'Probe trials';
    plot_set.xlabel = ' ';
    plot_set.ylabel = 'Reaction time, ms';
    
    plot_set.legend{1} = 'Cued';
    plot_set.legend{2} = 'Un-cued';
    for i=1:numel(plot_set.legend{1})
        plot_set.legend_y_coord(i) = 100;
        plot_set.legend_x_coord(i) = plot_set.pbins(i);
    end
    
    % Saving data
    plot_set.figure_size = settings.figsize_1col;
    plot_set.figure_save_name = 'probe task';
    plot_set.path_figure = path_fig;
    
    
    %==================
    % Plot
    
    hfig = figure;
    hold on;
    
    e_bars = plot_helper_error_bar_calculation_v10(mat1, settings);
    plot_helper_bargraph_plot_v10
    
    plot_helper_save_figure;
    close all;
    
    %===============
    
end