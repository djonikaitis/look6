% If wanted, plot each trial with saccade detection time (raw data)
% Latest revision - October 10, 2016
% Donatas Jonikaitis

close all;


%% Initial setup

% Loading the files needed
if ~exist('settings', 'var')
    settings = struct;
end

% Setup exp name
if ~isfield (settings, 'exp_name')
    settings.exp_name = input ('Type in experiment name: ', 's');
end

% Default subject number: all subjects
if ~isfield (settings, 'subjects')
    sN1 = 'all'; % Subject name
end

% Overwriting analysis defaults
if ~isfield(settings, 'overwrite')
    settings.overwrite = 1;
end

% Run settings file:
eval(sprintf('%s_settings', settings.exp_name)); % Load general settings

%% Some settings

settings.figure_folder_name = 'saccades_raw_traces';
settings.figsize1=[0, 0, 6, 2.5]; % Unique figure size settings in this case

% How many trials per error type to plot?
trials_to_plot = 10;
% trials_to_plot = length(S.trial_accepted);


%% Run preprocessing

for i=1:length(settings.subjects)
    
    settings.subject_name=settings.subjects{i}; % Select curent subject
    
    % Initialize subject specific folders where data is stored
    for i=1:length(settings.path_spec_names)
        v1 = ['path_', settings.path_spec_names{i}];
        settings.(v1) = sprintf ('%s%s/', settings.path_spec_folder{i}, settings.subject_name);
    end
    
    % Get index of every folder for a given subject
    session_init = get_path_dates_v20(settings.path_data_combined, settings.subject_name);
    
    % Which date to analyse (all days or a single day)
    if settings.preprocessing_sessions_used==1
        ind = [1:length(session_init.index_unique_dates)];
    elseif settings.preprocessing_sessions_used==2
        ind = find(session_init.index_unique_dates==settings.preprocessing_day_id);
    elseif settings.preprocessing_sessions_used==3
        ind = length(session_init.index_unique_dates);
    end
    date_index = session_init.index_unique_dates(ind);
    
    
    for i_date = 1:length(date_index)
        
        %============
        % Run pre-processing
        folder_name = [settings.subject_name, num2str(date_index(i_date))];
        path1 = [settings.path_data_combined, folder_name, '/', folder_name, '.mat']; % File with settings
        path2 = [settings.path_data_combined, folder_name, '/', folder_name, '_eye_traces.mat']; % File with raw data
        path3 = [settings.path_data_combined, folder_name, '/', folder_name, '_saccades.mat']; % File with saccades
        
        
        % Load all settings
        var1 = struct; varx = load(path1);
        f1 = fieldnames(varx);
        if length(f1)==1
            var1 = varx.(f1{1});
        end
        % Load raw saccade data
        var2 = struct; varx = load(path2);
        f1 = fieldnames(varx);
        if length(f1)==1
            var2 = varx.(f1{1});
        end
        % Load detected saccades
        var3 = struct; varx = load(path3);
        f1 = fieldnames(varx);
        if length(f1)==1
            var3 = varx.(f1{1});
        end
        
        % Copy raw data
        saccraw1 = var2.eye_processed;
        sacc1 = var1.saccades_EK;
        S = var1;
        
        % Save saccade date into matrix S for simplicity
        S.sacmatrix = var3.sacmatrix;
        S.trial_accepted = var3.trial_accepted;
        
        
        %% Select trials to plot
        
        
        % Select subset of trials or plot all?
        if trials_to_plot < length(S.trial_accepted)
            ind_trials = [];
            a = unique(removeNaN(S.trial_accepted));
            for i=1:length(a)
                b = find (S.trial_accepted==a(i));
                if length(b)<=trials_to_plot
                    c = b;
                else
                    b_perm_ind = randperm(length(b));
                    b=b(b_perm_ind);
                    c = b(1:trials_to_plot);
                end
                if size(c,2)>1
                    c=c';
                end
                ind_trials=[ind_trials;c];
            end
            
        else
            ind_trials = 1:length(S.trial_accepted);
        end
        
        
        %% Initialize folder where the plot will be saved
        
        % General path to figures folder (subject and date specified)
        path1 = sprintf('%s%s/%s/%s/', settings.path_figures, settings.figure_folder_name, settings.subject_name, folder_name) ;
        if isdir(path1)
            rmdir(path1, 's')
        else
            mkdir(path1)
        end
        
        %% Plot
        
        for tid_0=1:length(ind_trials)
            
            tid = ind_trials(tid_0);
            
            if ~isnan(S.trial_accepted(tid))
                
                % Data to be used in the trial
                sx1 = saccraw1{tid}; % Raw eye-traces
                sx2 = sacc1{tid}; % Saccades data
                
                h = subplot(1,3,[1]);
                hold on;
                
                %================
                % Plot fixation
                
                % Size
                objsize = S.fixation_size{tid}(3:4);
                % Position
                f_rad = S.em_fixation_radius(tid);
                f_arc = S.em_fixation_arc(tid);
                [xc,yc] = pol2cart(f_arc*pi/180, f_rad);
                pos1=[xc,yc];
                % Color
                if isfield(S, 'fixation_color_memory_delay')
                    fcolor1 = S.fixation_color_memory_delay{tid}./255;
                elseif ~isfield(S, 'fixation_color_memory_delay')
                    if S.em_blockcond(tid)==1
                        fcolor1 = S.fixation_color_task1{tid}./255;
                    elseif S.em_blockcond(tid)==2
                        fcolor1 = S.fixation_color_task2{tid}./255;
                    elseif S.em_blockcond(tid)==3
                        fcolor1 = S.fixation_color_task3{tid}./255;
                    elseif S.em_blockcond(tid)==4
                        fcolor1 = S.fixation_color_task4{tid}./255;
                    elseif  S.em_blockcond(tid)==5
                        fcolor1 = S.fixation_color_task5{tid}./255;
                    end
                end
                
                % Shape
                if S.em_blockcond(tid)==1
                    if strcmp(S.fixation_shape_task1{tid}, 'circle')
                        v1 = 1;
                    elseif strcmp(S.fixation_shape_task1{tid}, 'square')
                        v1 = 0;
                    end
                elseif S.em_blockcond(tid)==2
                    if strcmp(S.fixation_shape_task2{tid}, 'circle')
                        v1 = 1;
                    elseif strcmp(S.fixation_shape_task2{tid}, 'square')
                        v1 = 0;
                    end
                elseif S.em_blockcond(tid)==3
                    if strcmp(S.fixation_shape_task3{tid}, 'circle')
                        v1 = 1;
                    elseif strcmp(S.fixation_shape_task3{tid}, 'square')
                        v1 = 0;
                    end
                elseif S.em_blockcond(tid)==4
                    if strcmp(S.fixation_shape_task4{tid}, 'circle')
                        v1 = 1;
                    elseif strcmp(S.fixation_shape_task4{tid}, 'square')
                        v1 = 0;
                    end
                elseif  S.em_blockcond(tid)==5
                    if strcmp(S.fixation_shape_task5{tid}, 'circle')
                        v1 = 1;
                    elseif strcmp(S.fixation_shape_task5{tid}, 'square')
                        v1 = 0;
                    end
                end
                
                
                % Plot
                h=rectangle('Position', [pos1(1)-objsize(1)/2, pos1(2)-objsize(2)/2, objsize(1), objsize(2)],...
                    'EdgeColor', fcolor1, 'FaceColor', fcolor1, 'Curvature', v1, 'LineWidth', 1);
                
                %=========
                % Plot fixation tracking window
                
                % Size
                objsize = S.em_fixation_window(tid) * 2;
                
                % Plot
                h=rectangle('Position', [pos1(1)-objsize(1)/2, pos1(2)-objsize(1)/2, objsize(1), objsize(1)],...
                    'EdgeColor', fcolor1, 'FaceColor', 'none', 'Curvature', 1, 'LineWidth', 1);
                
                
                %==========
                % Plot saccade target 1
                
                
                if S.em_blockcond(tid)~=5
                    
                    % Size
                    objsize = S.response_size{tid}(3:4);
                    
                    % Position
                    if S.em_blockcond(tid)==1 && S.em_target_number(tid)==2
                        xc = S.em_t1_coord1(tid);
                        yc = S.em_t1_coord2(tid);
                    elseif S.em_blockcond(tid)==2 && S.em_target_number(tid)==2
                        xc = S.em_t2_coord1(tid);
                        yc = S.em_t2_coord2(tid);
                    elseif S.em_target_number(tid)==1
                        xc = S.em_t3_coord1(tid);
                        yc = S.em_t3_coord2(tid);
                    end
                    pos1 = [xc, yc];
                    
                    % Color & curvature
                    if S.em_blockcond(tid)==1 && S.em_target_number(tid)==2
                        fcolor1 = S.response_t1_color_task1{tid}./255;
                        if strcmp(S.response_shape_task1{tid}, 'circle')
                            v1 = 1;
                        elseif strcmp(S.response_shape_task1{tid}, 'square')
                            v1 = 0;
                        end
                    elseif S.em_blockcond(tid)==2 && S.em_target_number(tid)==2
                        fcolor1 = S.response_t2_color_task2{tid}./255;
                        if strcmp(S.response_shape_task2{tid}, 'circle')
                            v1 = 1;
                        elseif strcmp(S.response_shape_task2{tid}, 'square')
                            v1 = 0;
                        end
                    elseif S.em_target_number(tid)==1
                        fcolor1 = S.response_t3_color_task3{tid}./255;
                        if strcmp(S.response_t3_shape{tid}, 'circle')
                            v1 = 1;
                        elseif strcmp(S.response_t3_shape{tid}, 'square')
                            v1 = 0;
                        end
                    end
                    
                    % Plot
                    h=rectangle('Position', [pos1(1)-objsize(1)/2, pos1(2)-objsize(2)/2, objsize(1), objsize(2)],...
                        'EdgeColor', fcolor1, 'FaceColor', fcolor1,'Curvature', v1, 'LineWidth', 1);
                    
                    
                    %=========
                    % Plot saccade detection window
                    
                    % Size
                    objsize = S.em_eye_window(tid) * 2;
                    h=rectangle('Position', [pos1(1)-objsize(1)/2, pos1(2)-objsize(1)/2, objsize(1), objsize(1)],...
                        'EdgeColor', fcolor1, 'FaceColor', 'none', 'Curvature', 1, 'LineWidth', 1);
                end
                
                %=================
                % Plot distractor
                if S.em_target_number(tid)==2 && S.em_blockcond(tid)~=5
                    
                    
                    % Size
                    objsize = S.response_size{tid}(3:4);
                    % Position
                    if S.em_blockcond(tid)==1
                        xc = S.em_t2_coord1(tid);
                        yc = S.em_t2_coord2(tid);
                    elseif S.em_blockcond(tid)==2
                        xc = S.em_t1_coord1(tid);
                        yc = S.em_t1_coord2(tid);
                    end
                    pos1 = [xc, yc];
                    
                    % Color & curvature
                    if S.em_blockcond(tid)==1 && S.em_target_number(tid)==2
                        fcolor1 = S.response_t2_color_task1{tid}./255;
                        if strcmp(S.response_shape_task1{tid}, 'circle')
                            v1 = 1;
                        elseif strcmp(S.response_shape_task1{tid}, 'square')
                            v1 = 0;
                        end
                    elseif S.em_blockcond(tid)==2 && S.em_target_number(tid)==2
                        fcolor1 = S.response_t1_color_task2{tid}./255;
                        if strcmp(S.response_shape_task2{tid}, 'circle')
                            v1 = 1;
                        elseif strcmp(S.response_shape_task2{tid}, 'square')
                            v1 = 0;
                        end
                    end
                    
                    % Plot
                    h=rectangle('Position', [pos1(1)-objsize(1)/2, pos1(2)-objsize(2)/2, objsize(1), objsize(2)],...
                        'EdgeColor', fcolor1, 'FaceColor', fcolor1, 'Curvature', v1, 'LineWidth', 1);
                    
                end
                
                %====================
                % Plot memory target in single probe trials (otherwise we know where memory is)
                if (S.em_target_number(tid)==1 && S.em_blockcond(tid)~=5) || S.em_blockcond(tid)==5 
                    
                    % Size
                    objsize = S.memory_size{tid}(3:4);
                    
                    % Position
                    xc = S.em_target_coord1(tid);
                    yc = S.em_target_coord2(tid);
                    pos1 = [xc, yc];
                    
                    % Color
                    fcolor1=S.memory_color{tid}./255;
                    if sum(fcolor1)>2.7
                        fcolor1 = [0.5, 0.5, 0.5];
                    end
                    
                    if strcmp(S.memory_shape{tid}, 'empty_circle')
                        v1 = 1; c1 = [1,1,1];
                    elseif strcmp(S.memory_shape{tid}, 'empty_square')
                        v1 = 0; c1 = [1,1,1];
                    elseif strcmp(S.memory_shape{tid}, 'circle')
                        v1 = 1; c1 = fcolor1;
                    elseif strcmp(S.memory_shape{tid}, 'square')
                        v1 = 0; c1 = fcolor1;
                    end
                    
                    % Plot
                    h=rectangle('Position', [pos1(1)-objsize(1)/2, pos1(2)-objsize(2)/2, objsize(1), objsize(2)],...
                        'EdgeColor', fcolor1, 'FaceColor', c1, 'Curvature', v1, 'LineWidth', 1);
                end
                
                %====================
                % Plot raw data (select only part of the time for it)
                t1 = S.first_display(tid);
                t2 = S.targets_off(tid);
                index1 = sx1(:,1)>=t1 & sx1(:,1)<=t2;
                fcolor1 = [0.5, 0.5, 0.5];
                if sum(index1)>1
                    h=plot(sx1(index1,2), sx1(index1,3), 'Color', fcolor1, 'LineWidth', 1);
                end
                
                % Plot selected saccade
                index1=sx1(:,1)>=S.sacmatrix(tid,1) & sx1(:,1)<=S.sacmatrix(tid,2);
                if length(index1)>1
                    x1=sx1(index1,2); y1=sx1(index1,3); % Convert to eye position in space
                    h=plot(x1, y1, 'g', 'LineWidth', 1);
                end
                
                axis equal
                
                % Radius
                if S.em_blockcond(tid)==1 && S.em_target_number(tid)==2
                    xc = S.em_t1_coord1(tid);
                    yc = S.em_t1_coord2(tid);
                elseif S.em_blockcond(tid)==3 && S.em_target_number(tid)==2
                    xc = S.em_t2_coord1(tid);
                    yc = S.em_t2_coord2(tid);
                elseif S.em_target_number(tid)==1
                    xc = S.em_t3_coord1(tid);
                    yc = S.em_t3_coord2(tid);
                end
                
                if S.trial_accepted(tid)==3 || S.trial_accepted(tid)==1
                    set(gca,'XLim',[-40,40]);
                    set(gca,'YLim',[-40,40]);
                else
                    set(gca,'YLim',[-17,17]);
                    set(gca,'XLim',[-17,17]);
                end
                
                set(gca,'YTick',[yc]);
                set(gca,'XTick',[xc]);
                
                % Error codes
                if S.trial_accepted(tid)==1
                    title('Blink')
                elseif S.trial_accepted(tid)==2
                    title('Missing data points')
                elseif S.trial_accepted(tid)==3
                    title('Aborted trial (no fix)')
                elseif S.trial_accepted(tid)==4
                    title('Aborted trial (left fix)')
                elseif S.trial_accepted(tid)==5
                    title('Looked at memory')
                elseif S.trial_accepted(tid)==6
                    title('No saccade initiated')
                elseif S.trial_accepted(tid)==7
                    title('Incorrect large saccade')
                elseif S.trial_accepted(tid)==8
                    title('Broke fix after memory')
                    % Correct trial
                elseif S.trial_accepted(tid)==-1
                    title('OK', 'FontSize', settings.fontszlabel)
                elseif S.trial_accepted(tid)==-2
                    title('Wrong target', 'FontSize', settings.fontszlabel)
                elseif S.trial_accepted(tid)==99
                    title('Unclasified error', 'FontSize', settings.fontszlabel)
                end
                
                %% Position in time
                
                %===========
                % Start figure
                hfig=subplot(1,3,[2:3]);
                hold on;
                
                %=====================
                % Plot fixation before eye movement acquired it
                yc=S.em_fixation_radius(tid);
                if S.fixation_drift_correction_on{tid}==1
                    s_window = S.fixation_accuracy_drift{tid} * 2;
                else
                    s_window = S.em_fixation_window(tid) * 2;
                end
                t_start = S.fixation_on(tid) - S.first_display(tid);
                if ~isnan(S.fixation_acquired(tid))
                    t_dur = (S.fixation_acquired(tid) - S.fixation_on(tid));
                else
                    t_dur = (S.fixation_off(tid) - S.fixation_on(tid));
                end
                h=rectangle('Position', [t_start, yc-s_window/2, t_dur, s_window],...
                    'EdgeColor', [0.9, 0.9, 0.9],  'FaceColor', 'none', 'Curvature', 0, 'LineWidth', 1);
                
                
                
                %=====================
                % Plot fixation after eye movement acquired it (drift maintenance period)
                if ~isnan(S.fixation_acquired(tid))
                    yc=S.em_fixation_radius(tid);
                    if S.fixation_drift_correction_on{tid}==1
                        s_window = S.fixation_accuracy_drift{tid} * 2;
                    else
                        s_window = S.em_fixation_window(tid) * 2;
                    end
                    t_start = S.fixation_acquired(tid) - S.first_display(tid);
                    if ~isnan(S.drift_maintained(tid))
                        t_dur = S.drift_maintained(tid) - S.fixation_acquired(tid);
                    elseif isnan(S.drift_maintained(tid))
                        t_dur = S.fixation_off(tid) - S.fixation_acquired(tid);
                    end
                    h=rectangle('Position', [t_start, yc-s_window/2, t_dur, s_window],...
                        'EdgeColor', [0.9, 0.9, 0.9],  'FaceColor', [0.9, 0.9, 0.9], 'Curvature', 0, 'LineWidth', 1);
                end
                
                if  ~isnan(S.drift_maintained(tid))
                    if S.drift_correction(tid,1) == 1
                        text(t_start, -7, ['Drift ', num2str(round(S.drift_correction(tid,4), 2))], 'Color', [0.7, 0.7, 0.7],  'FontSize', settings.fontszlabel, 'HorizontalAlignment', 'left')
                    elseif S.drift_correction(tid,1) == 0
                        text(t_start, -7, ['Drift OK'], 'Color', [0.7, 0.7, 0.7],  'FontSize', settings.fontszlabel, 'HorizontalAlignment', 'left')
                    end
                end
                
                
                %===================
                % Plot fixation where eye is allowed before saccade target onset
                if ~isnan(S.drift_maintained(tid))
                    yc=S.em_fixation_radius(tid);
                    s_window = S.em_fixation_window(tid) * 2;
                    t_start = S.drift_maintained(tid) - S.first_display(tid);
                    if ~isnan(S.fixation_maintained(tid)) && S.em_blockcond(tid)~=5
                        t_dur = S.targets_on(tid) - S.drift_maintained(tid);
                    elseif ~isnan(S.fixation_maintained(tid)) && S.em_blockcond(tid)==5
                        t_dur = S.fixation_off(tid) - S.drift_maintained(tid);
                    elseif isnan(S.fixation_maintained(tid))
                        t_dur = S.fixation_off(tid) - S.drift_maintained(tid);
                    end
                    h=rectangle('Position', [t_start, yc-s_window/2, t_dur, s_window],...
                        'EdgeColor', [0.7, 0.7, 0.7],  'FaceColor', [0.7, 0.7, 0.7], 'Curvature', 0, 'LineWidth', 1);
                    
                end
                
                %============
                % Plot saccade target 1 time window
                if ~isnan(S.targets_on(tid)) && S.em_blockcond(tid)~=5
                    if S.em_blockcond(tid)==1 && S.em_target_number(tid)==2
                        xc = S.em_t1_coord1(tid);
                        yc = S.em_t1_coord2(tid);
                    elseif S.em_blockcond(tid)==2 && S.em_target_number(tid)==2
                        xc = S.em_t2_coord1(tid);
                        yc = S.em_t2_coord2(tid);
                    elseif S.em_target_number(tid)==1
                        xc = S.em_t3_coord1(tid);
                        yc = S.em_t3_coord2(tid);
                    end
                    yc = sqrt(xc.^2 + yc.^2); % Transform yc to distance
                    s_window = S.response_saccade_accuracy{tid} * 2;
                    t_start = S.targets_on(tid) - S.first_display(tid);
                    t_dur = S.targets_off(tid) - S.targets_on(tid) ;
                    h=rectangle('Position', [t_start, yc-s_window/2, t_dur, s_window],...
                        'EdgeColor', [1, 0.5, 0.5], 'FaceColor', [1, 0.5, 0.5], 'Curvature', 0, 'LineWidth', 1);
                    text(t_start, -4, 'ST1', 'Color', [1, 0.5, 0.5],  'FontSize', settings.fontszlabel, 'HorizontalAlignment', 'left')
                end
                
                
                %==============
                % Plot saccade target 2 time window
                if ~isnan(S.distractor_on(tid)) && S.em_target_number(tid)==2 && S.em_blockcond(tid)~=5
                    if S.em_blockcond(tid)==1
                        xc = S.em_t2_coord1(tid);
                        yc = S.em_t2_coord2(tid);
                    elseif S.em_blockcond(tid)==2
                        xc = S.em_t1_coord1(tid);
                        yc = S.em_t1_coord2(tid);
                    end
                    yc = sqrt(xc.^2 + yc.^2); % Transform yc to distance
                    s_window = S.response_saccade_accuracy{tid} * 2;
                    t_start = S.distractor_on(tid) - S.first_display(tid);
                    t_dur = S.distractor_off(tid) - S.distractor_on(tid) ;
                    h=rectangle('Position', [t_start, yc-s_window/2, t_dur, s_window],...
                        'EdgeColor', [0.7, 0.1, 0.1], 'FaceColor', 'none', 'Curvature', 0, 'LineWidth', 1);
                    text(t_start, -7, 'ST2', 'Color', [0.7, 0.1, 0.1],  'FontSize', settings.fontszlabel, 'HorizontalAlignment', 'left')
                end
                
                %===================
                % Plot memory onset
                if ~isnan(S.memory_on(tid))
                    xc=S.em_target_coord1(tid);
                    yc=S.em_target_coord2(tid);
                    yc = sqrt(xc.^2 + yc.^2); % Transform yc to distance
                    s_window=S.response_saccade_accuracy{tid} * 2;
                    t_start=S.memory_on(tid)-S.first_display(tid);
                    if ~isnan(S.memory_off(tid))
                        t_dur = S.memory_off(tid) - S.memory_on(tid);
                    else
                        t_dur = S.memory_duration{tid};
                    end
                    h=rectangle('Position', [t_start, yc-s_window/2, t_dur, s_window],...
                        'EdgeColor', [0.4, 0.4, 1],  'FaceColor', 'none', 'Curvature', 0, 'LineWidth', 1);
                    text(t_start, -8, 'M', 'Color', [0.4, 0.4, 1],  'FontSize', settings.fontszlabel, 'HorizontalAlignment', 'left')
                end
                
                %=================
                % Plot reward timing
                if ~isnan(S.reward_on(tid))
                    yc = 0;
                    s_window = 1;
                    t_start = S.reward_on(tid)-S.first_display(tid);
                    t_dur = S.em_data_reward_size_ms(tid);
                    h=rectangle('Position', [t_start, yc-s_window, t_dur, s_window],...
                        'EdgeColor', [0.7, 0.7, 0.1], 'FaceColor', 'none', 'Curvature', 0, 'LineWidth', 1);
                    text(t_start, 2, 'Reward', 'Color', [0.7, 0.7, 0.1],  'FontSize', settings.fontszlabel, 'HorizontalAlignment', 'left')
                end
                
                %==============
                % Plot eye position data
                t1=S.first_display(tid); % Relative to first display
                t2=S.last_display(tid);
                if length(sx1)>1
                    index1=sx1(:,1)>=t1 & sx1(:,1)<=t2; % Select time
                    sx1(:,1)=sx1(:,1)-t1; % Reset eye position timing relative to t1
                    x1=sx1(index1,2); y1=sx1(index1,3); % Select position
                    eyecoord1 = sqrt(x1.^2 + y1.^2); % Calculate amplitude of the eye position
                    h=plot(sx1(index1,1), eyecoord1, 'Color', [0.1, 0.1, 0.1], 'LineWidth', 1); % Plot eye position in space and time
                end
                
                % Add data of the blinks
                index1=sx1(:,4)==0; % Select blinks
                x1=sx1(index1,2); y1=sx1(index1,3); % Select positiion
                eyecoord1 = sqrt(x1.^2 + y1.^2); % Calculate amplitude of the eye position
                h=plot(sx1(index1,1), eyecoord1, '.y', 'LineWidth', 1);
                
                % Plot every single saccade detected
                t1 = S.first_display(tid); % Relative to first display
                if size(sx2,2)>1
                    sx2(:,1)=sx2(:,1)-t1; % Reset eye position timing relative to t1
                    sx2(:,2)=sx2(:,2)-t1; % Reset eye position timing relative to t1
                    for i=1:size(sx2,1)
                        index1=sx1(:,1)>=sx2(i,1) & sx1(:,1)<=sx2(i,2);
                        x1=sx1(index1,2); y1=sx1(index1,3); % Convert to eye position in space
                        eyecoord1 = sqrt(x1.^2 + y1.^2); % Convert to position in space
                        h=plot(sx1(index1,1), eyecoord1, 'Color', [0.2, 0.2, 0.8],  'LineWidth', 1);
                    end
                end
                
                % Plot saccade of interest
                if size(sx1,2)>1
                    index1=sx1(:,1)>=S.sacmatrix(tid,1) & sx1(:,1)<=S.sacmatrix(tid,2);
                    x1=sx1(index1,2); y1=sx1(index1,3); % Convert to eye position in space
                    eyecoord1 = sqrt(x1.^2 + y1.^2); % Convert to position in space
                    h=plot(sx1(index1,1), eyecoord1, 'Color', [0.2, 1, 0.2], 'LineWidth', 1);
                end
                
                
                % X Lim
                set (gca,'FontSize', settings.fontsz);
                if S.reward_on(tid)>0
                    t_start = ((S.first_display(tid) - S.first_display(tid))) - 100;
                    t_end = ((S.reward_on(tid) - S.first_display(tid))) + 100;
                    set(gca,'XLim',[t_start,t_end]);
                else
                    t_start = ((S.first_display(tid) - S.first_display(tid))) - 100;
                    t_end = ((S.fixation_off(tid) - S.first_display(tid))) + 300;
                    set(gca,'XLim',[t_start,t_end]);
                end
                
                % Y tick label
                if S.em_blockcond(tid)==1 && S.em_target_number(tid)==2
                    xc = S.em_t1_coord1(tid);
                    yc = S.em_t1_coord2(tid);
                elseif S.em_blockcond(tid)==2 && S.em_target_number(tid)==2
                    xc = S.em_t2_coord1(tid);
                    yc = S.em_t2_coord2(tid);
                elseif S.em_blockcond(tid)~=5 && S.em_target_number(tid)==1
                    xc = S.em_t3_coord1(tid);
                    yc = S.em_t3_coord2(tid);
                elseif S.em_blockcond(tid)==5
                    xc = S.em_target_coord1(tid);
                    yc = S.em_target_coord2(tid);
                end
                yc = sqrt(xc.^2 + yc.^2); % Transform yc to distance
                if round(yc,1)>0
                    set(gca,'YTick',[0,round(yc,1)]);
                else
                    set(gca,'YTick',[0]);
                end
                if S.trial_accepted(tid)==1
                    set(gca,'YLim',[-12,40]);
                else
                    set(gca,'YLim',[-12,17]);
                end
                
                % X tick labels
                if ~isnan(S.memory_on(tid)) && ~isnan(S.targets_on(tid)) && S.em_blockcond(tid)~=5
                    if S.targets_on(tid)-S.memory_on(tid)>500
                        t1 = S.memory_on(tid) - S.first_display(tid);
                        t2 = S.targets_on(tid) - S.first_display(tid);
                        t3 = S.last_display(tid) - S.first_display(tid);
                        set(gca,'XTick', [0, t1, t2, t3])
                    else
                        t1 = S.targets_on(tid) - S.first_display(tid);
                        t2 = S.last_display(tid) - S.first_display(tid);
                        set(gca,'XTick', [0, t1, t2])
                    end
                elseif ~isnan(S.memory_on(tid)) && isnan(S.targets_on(tid)) && S.em_blockcond(tid)~=5
                    t1 = S.memory_on(tid) - S.first_display(tid);
                    t2 = S.last_display(tid) - S.first_display(tid);
                    set(gca,'XTick', [0, t1, t2])
                elseif ~isnan(S.last_display(tid)) && isnan(S.memory_on(tid))
                    t1 = S.last_display(tid) - S.first_display(tid);
                    set(gca,'XTick', [0, t1])
                end
                if ~isnan(S.memory_on(tid)) && S.em_blockcond(tid)==5
                    t1 = S.memory_on(tid) - S.first_display(tid);
                    t2 = S.fixation_off(tid) - S.first_display(tid);
                    set(gca,'XTick', [0, t1, t2])
                end
                
                xlabel ('Time', 'FontSize', settings.fontszlabel)
                ylabel ('Gaze position', 'FontSize', settings.fontszlabel)
                
                
                
                %% Save the output
                
                
                %============
                % Export the figure & save it
                path1_fig=sprintf('%scode %s/', path1, num2str(S.trial_accepted(tid)));
                if ~isdir(path1_fig)
                    mkdir(path1_fig)
                end
                
                % Save figure
                f_name = sprintf('%strial %s', path1_fig, num2str(tid));
                set(gcf, 'PaperPositionMode', 'manual');
                set(gcf, 'PaperUnits', 'inches');
                set(gcf, 'PaperPosition', settings.figsize1)
                set(gcf, 'PaperSize', [settings.figsize1(3),settings.figsize1(4)]);
                print (f_name, '-dpdf')
                %===============
                
                close all;
                
                
            end
            % End of a plot
            
        end
        % End of analysis for each trial
        
        
    end
    % End of analysis for each day
    
end
% End of analysis for each subject

