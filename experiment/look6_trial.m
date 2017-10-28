% Here all displays presented

window = expsetup.screen.window;


%% If block number has changed, reset stimulus luminance updating
% This is specific to only luminance changes; This works for interleaved
% tasks only

if tid>1 && (strcmp(expsetup.stim.esetup_exp_version{tid-1}, 'task switch luminance change') || strcmp(expsetup.stim.esetup_exp_version{tid-1}, 'task switch luminance equal'))
    % ind is number of trials in this block
    if expsetup.stim.trial_error_repeat == 1
        ind = strcmp(expsetup.stim.edata_error_code, 'correct') & expsetup.stim.esetup_block_no == expsetup.stim.esetup_block_no(tid-1);
    else
        ind = expsetup.stim.esetup_block_no == expsetup.stim.esetup_block_no(tid-1);
    end
    % If current block is new block, change task version
    if sum(ind) == expsetup.stim.number_of_trials_per_block 
        a = expsetup.stim.esetup_exp_version{tid-1};
        ind1 = strcmp(expsetup.stim.training_stage_matrix, a);
        ind1 = find(ind1==1);
        if strcmp(a, 'task switch luminance change')
            if ind1-1>=1
                b = expsetup.stim.training_stage_matrix{ind1-1};
            else
                error('Exp version before "task switch luminance change" has to be defined')
            end
        elseif strcmp(a, 'task switch luminance equal')
            if ind1-2>=1
                b = expsetup.stim.training_stage_matrix{ind1-2};
            else
                error('Exp version before "task switch luminance change" has to be defined')
            end
        end
        expsetup.stim.exp_version_update_next_trial = 1; % Update next trial
        expsetup.stim.esetup_st2_color_level(tid-1) = expsetup.stim.st2_color_level_ini; % Over-write previous trial
        expsetup.stim.esetup_exp_version{tid-1} = b; % Over-write previous trial
    end
end


%% Training stage of the experiment

runexp_trial_update_performance_v12


%% PREPARE ALL OBJECTS AND FRAMES TO BE DRAWN:

% In this case, randomization is done on each trial. Alternatively, all exp
% mat could be preset on first trial.
if tid == 1
    u1 = sprintf('%s_trial_randomize', expsetup.general.expname); % Path to file containing trial settings
    eval (u1);
elseif tid>1
    u1 = sprintf('%s_trial_randomize', expsetup.general.expname); % Path to file containing trial settings
    eval (u1);
end

% Initialize all rectangles for the task
u1 = sprintf('%s_trial_stimuli', expsetup.general.expname); % Path to file containing trial settings
eval (u1);

% Initialize all frames for the task
u1 = sprintf('%s_trial_frames', expsetup.general.expname); % Path to file containing trial settings
eval (u1);


%% Calculate trial number in a block 

% How many trials in a block recorded?
if expsetup.stim.trial_error_repeat == 1
    ind_correct = strcmp(expsetup.stim.edata_error_code, 'correct') & expsetup.stim.esetup_block_no == expsetup.stim.esetup_block_no(tid);
    ind_recorded = expsetup.stim.esetup_block_no == expsetup.stim.esetup_block_no(tid);
    % How many error trials recorded?
    temp1 = sum(ind_recorded)-sum(ind_correct)-1; % -1 as we dont know whether current trial will be correct
    % Block size is expected number of trials + error trials
    ind_total = expsetup.stim.number_of_trials_per_block + temp1;
else
    ind_recorded = expsetup.stim.esetup_block_no == expsetup.stim.esetup_block_no(tid);
    ind_total = expsetup.stim.number_of_trials_per_block;
end
% Which trial it is?
ind_tid = sum(ind_recorded);
% Which block it is?
ind_block = expsetup.stim.esetup_block_no(tid);
% Which task it is?
if expsetup.stim.esetup_block_cond(tid) == 1
    ind_task = sprintf('Look');
elseif expsetup.stim.esetup_block_cond(tid) == 2
    ind_task = sprintf('Avoid');
else
    ind_task = sprintf('Control');
end

msg1 = sprintf('%s task, trial %i of %i, block %i', ind_task, ind_tid, ind_total, ind_block);
fprintf('%s\n', msg1)


%% EYETRACKER INITIALIZE

% Start recording
if expsetup.general.recordeyes==1
    Eyelink('StartRecording');
    msg1=['TrialStart ', num2str(tid)];
    Eyelink('Message', msg1);
    WaitSecs(0.1);  % Record a few samples before we actually start displaying
end

% SEND MESSAGE WITH TRIAL ID TO EYELINK
if expsetup.general.recordeyes==1
    msg1 = sprintf('%s task, trial %i of %i, block %i', ind_task, ind_tid, ind_total, ind_block);
    Eyelink('Command', 'record_status_message ''%s'' ', msg1);
end


%% ================

% FIRST DISPLAY - BLANK

Screen('FillRect', window, expsetup.stim.esetup_background_color(tid,:));
if expsetup.general.record_plexon==1
    Screen('FillRect', window, [255, 255, 255], ph_rect, 1); % Photodiode
end
[~, time_current, ~]=Screen('Flip', window);

% Save plexon event
if expsetup.general.record_plexon==1
    a1 = zeros(1,expsetup.ni_daq.digital_channel_total);
    a1_s = expsetup.general.plex_event_start; % Channel number used for events
    a1(a1_s)=1;
    outputSingleScan(ni.session_plexon_events,a1);
    a1 = zeros(1,expsetup.ni_daq.digital_channel_total);
    outputSingleScan(ni.session_plexon_events,a1);
end

% Save eyelink and psychtoolbox events
if expsetup.general.recordeyes==1
    Eyelink('Message', 'first_display');
end
expsetup.stim.edata_first_display(tid,1) = time_current;

% Save frame onset
c1_frame_index1 = 1;
expsetup.stim.eframes_time{tid}(c1_frame_index1, 1) = time_current; % Save in the first row during presentation of first dislapy


%%  TRIAL LOOP

loop_over = 0;

while loop_over==0
    
    
    % ================
    % Initialize new frame index
    c1_frame_index1 = c1_frame_index1+1;
    
    
    %% Update frames dependent on acquiring fixation
    
    % Changes in fixation (stop blinking)
    if ~isnan(expsetup.stim.edata_fixation_acquired(tid,1)) && nansum(expsetup.stim.eframes_fixation_stops_blinking{tid}(:, 1))==0
        expsetup.stim.eframes_fixation{tid}(c1_frame_index1:end, 1) = 1;
        expsetup.stim.eframes_fixation_stops_blinking{tid}(c1_frame_index1, 1) = 1;
    end
    
    % Changes in fixation (remove fixation)
    t0 = expsetup.stim.edata_fixation_acquired(tid,1);
    t1 = expsetup.stim.esetup_total_fixation_duration(tid,1);
    if ~isnan(t0) && (time_current - t0 >= t1) && nansum(expsetup.stim.eframes_fixation_off{tid}(:, 1))==0
        expsetup.stim.eframes_fixation{tid}(c1_frame_index1:end, 1) = 0;
        expsetup.stim.eframes_fixation_offset{tid}(c1_frame_index1, 1) = 1;
        time_current
    end
    
    % Changes in fixation (color change)
    t0 = expsetup.stim.edata_fixation_acquired(tid,1);
    t1 = expsetup.stim.esetup_fixation_maintain_duration(tid,1);
    t2 = expsetup.stim.fixation_color_change_soa;
    if ~isnan(t0) && (time_current - t0 >= t1 + t2) && nansum(expsetup.stim.eframes_fixation_color_change{tid}(:, 1))~=1
        expsetup.stim.eframes_fixation_color_change{tid}(c1_frame_index1, 1) = 1;
    end
    
    
    %% Draw stimuli
    
    % Texture for the background
    t0 = expsetup.stim.edata_fixation_acquired(tid,1);
    t1 = expsetup.stim.esetup_fixation_maintain_duration(tid,1);
    t2 = expsetup.stim.background_texture_soa;
    if ~isnan(t0) && (time_current - t0 >= t1 + t2)
        if expsetup.stim.esetup_background_texture_on(tid)==1
            Screen('DrawLines', window, xy_texture_combined, expsetup.stim.background_texture_line_pen, expsetup.stim.background_texture_line_color);
            expsetup.stim.eframes_texture_on{tid}(c1_frame_index1,1) = 1;
        end
    end
    
    % Fixation
    if expsetup.stim.eframes_fixation{tid}(c1_frame_index1,1)==1
        % Properties
        if nansum(expsetup.stim.eframes_fixation_color_change{tid}(:, 1))==0
            c1 = expsetup.stim.esetup_fixation_color(tid,1:3);
        elseif nansum(expsetup.stim.eframes_fixation_color_change{tid}(:, 1))==1
            c1 = expsetup.stim.fixation_color_memory_delay;
        end
        sh1 = expsetup.stim.esetup_fixation_shape{tid};
        p1 = expsetup.stim.fixation_pen;
        r1 = fixation_rect;
        % Plot
        if strcmp(sh1,'circle')
            Screen('FillArc', window, c1, r1, 0, 360);
        elseif strcmp(sh1,'square')
            Screen('FillRect', window, c1, r1, p1);
        elseif strcmp(sh1,'empty_circle')
            Screen('FrameArc',window, c1, r1, 0, 360, p1)
        elseif strcmp(sh1,'empty_square')
            Screen('FrameRect', window, c1, r1, p1);
        end
    end
        
    % Memory on
    t0 = expsetup.stim.edata_fixation_acquired(tid,1);
    t1 = expsetup.stim.esetup_fixation_maintain_duration(tid,1);
    t2 = expsetup.stim.esetup_memory_duration(tid,1);
    if ~isnan(t0) && (time_current - t0 >= t1) && (time_current - t0 < t1+t2)
        % Properties
        sh1 = expsetup.stim.esetup_memory_shape{tid}; 
        c1 = expsetup.stim.esetup_memory_color(tid,:);
        p1 = expsetup.stim.esetup_memory_pen_width(tid);
        r1 = memory_rect;
        % Plot
        if strcmp(sh1,'circle')
            Screen('FillArc', window, c1, r1, 0, 360);
        elseif strcmp(sh1,'square')
            Screen('FillRect', window, c1, r1, p1);
        elseif strcmp(sh1,'empty_circle')
            Screen('FrameArc',window, c1, r1, 0, 360, p1)
        elseif strcmp(sh1,'empty_square')
            Screen('FrameRect', window, c1, r1, p1);
        end
        expsetup.stim.eframes_memory_on{tid}(c1_frame_index1,1) = 1;
        % Also plot a photo diode
        if isnan(expsetup.stim.edata_memory_on(tid,1))
            Screen('FillRect', window, [200, 200, 200], ph_rect, 1);
        end
    end
    
    % Memory off
    if ~isnan(t0) && (time_current - t0 >= t1+t2) && nansum(expsetup.stim.eframes_memory_off{tid}(:,1))==0
        expsetup.stim.eframes_memory_off{tid}(c1_frame_index1,1) = 1;
    end
    
    
    % ST1
    t0 = expsetup.stim.edata_fixation_acquired(tid,1);
    t1 = expsetup.stim.esetup_total_fixation_duration(tid,1);
    if ~isnan(t0) && (time_current - t0 >= t1)
        % Properties
        sh1 = expsetup.stim.esetup_target_shape{tid};
        r1 = st1_rect;
        c1 = expsetup.stim.esetup_st1_color(tid,:);
        p1 = expsetup.stim.esetup_target_pen_width(tid);
        % Plot
        if strcmp(sh1,'circle')
            Screen('FillArc', window, c1, r1, 0, 360);
        elseif strcmp(sh1,'square')
            Screen('FillRect', window, c1, r1, p1);
        elseif strcmp(sh1,'empty_circle')
            Screen('FrameArc',window, c1, r1, 0, 360, p1)
        elseif strcmp(sh1,'empty_square')
            Screen('FrameRect', window, c1, r1, p1);
        end
        expsetup.stim.eframes_st1_on{tid}(c1_frame_index1,1) = 1;
    end
    
    % ST2 off
    if ~isnan(expsetup.stim.edata_response_acquired(tid,1)) && nansum(expsetup.stim.eframes_st2_off{tid}(:,1))==0
        expsetup.stim.eframes_st2_off{tid}(c1_frame_index1,1) = 1;
    end
    
    % ST2
    t0 = expsetup.stim.edata_fixation_acquired(tid,1);
    t1 = expsetup.stim.esetup_total_fixation_duration(tid,1) + expsetup.stim.esetup_response_soa(tid,1);
    if ~isnan(t0) && (time_current - t0 >= t1) && expsetup.stim.esetup_target_number(tid) == 2 && ...
            nansum(expsetup.stim.eframes_st2_off{tid}(:,1))==0
        % Properties
        sh1 = expsetup.stim.esetup_target_shape{tid};
        r1 = st2_rect;
        c1 = expsetup.stim.esetup_st2_color(tid,:);
        p1 = expsetup.stim.esetup_target_pen_width(tid);
        % Plot
        if strcmp(sh1,'circle')
            Screen('FillArc', window, c1, r1, 0, 360);
        elseif strcmp(sh1,'square')
            Screen('FillRect', window, c1, r1, p1);
        elseif strcmp(sh1,'empty_circle')
            Screen('FrameArc',window, c1, r1, 0, 360, p1)
        elseif strcmp(sh1,'empty_square')
            Screen('FrameRect', window, c1, r1, p1);
        end
        expsetup.stim.eframes_st2_on{tid}(c1_frame_index1,1) = 1;
    end
    
    % Show distractor?
    if strcmp(expsetup.stim.esetup_exp_version{tid}, 'distractor train luminance') || ...
            strcmp(expsetup.stim.esetup_exp_version{tid}, 'distractor train position') || ...
            strcmp(expsetup.stim.esetup_exp_version{tid}, 'distractor on')
        
        % Distractor on
        t0 = expsetup.stim.edata_memory_on(tid,1);
        t1 = expsetup.stim.esetup_distractor_on_time(tid,1);
        t2 = expsetup.stim.esetup_distractor_duration(tid,1);
        if ~isnan(t0) && (time_current - t0 >= t1) && (time_current - t0 < t1+t2) && ...
                expsetup.stim.esetup_distractor_probability(tid) == 1
            
            % Properties
            sh1 = expsetup.stim.distractor_shape;
            c1 = expsetup.stim.esetup_distractor_color(tid,:);
            p1 = expsetup.stim.distractor_pen_width;
            r1 = dist_rect;
            % Plot
            if strcmp(sh1,'circle')
                Screen('FillArc', window, c1, r1, 0, 360);
            elseif strcmp(sh1,'square')
                Screen('FillRect', window, c1, r1, p1);
            elseif strcmp(sh1,'empty_circle')
                Screen('FrameArc',window, c1, r1, 0, 360, p1)
            elseif strcmp(sh1,'empty_square')
                Screen('FrameRect', window, c1, r1, p1);
            end
            expsetup.stim.eframes_distractor_on{tid}(c1_frame_index1,1) = 1;
        end
        
        % Distractor off
        if ~isnan(t0) && (time_current - t0 >= t1+t2) && nansum(expsetup.stim.eframes_distractor_off{tid}(:,1))==0 &&...
                expsetup.stim.esetup_distractor_probability(tid) == 1
            expsetup.stim.eframes_distractor_off{tid}(c1_frame_index1,1) = 1;
        end
    end

    
    %% FLIP AND RECORD TIME
    
    [~, time_current, ~]=Screen('Flip', window);
    
    % Save flip time into trialmat
    expsetup.stim.eframes_time{tid}(c1_frame_index1, 1) = time_current; % Add row to each refresh
    
    % Record texture onset
    if expsetup.stim.eframes_texture_on{tid}(c1_frame_index1,1)==1 && isnan(expsetup.stim.edata_texture_on(tid,1))
        if expsetup.general.recordeyes==1
            Eyelink('Message', 'texture_on');
        end
        expsetup.stim.edata_texture_on(tid,1) = time_current;
    end
    
    % Record fixation onset
    if expsetup.stim.eframes_fixation{tid}(c1_frame_index1,1)==1 && isnan(expsetup.stim.edata_fixation_on(tid,1))
        if expsetup.general.recordeyes==1
            Eyelink('Message', 'fixation_on');
        end
        expsetup.stim.edata_fixation_on(tid,1) = time_current;
    end
    
    % Record fixation offset
    if expsetup.stim.eframes_fixation_off{tid}(c1_frame_index1, 1)==1 && isnan(expsetup.stim.edata_fixation_off(tid,1))
        if expsetup.general.recordeyes==1
            Eyelink('Message', 'fixation_off');
        end
        expsetup.stim.edata_fixation_off(tid,1) = time_current
    end
    
    % Record fixation folor change
    if expsetup.stim.eframes_fixation_color_change{tid}(c1_frame_index1, 1)==1 && isnan(expsetup.stim.edata_fixation_color_change(tid,1))
        if expsetup.general.recordeyes==1
            Eyelink('Message', 'fixation_color_change');
        end
        expsetup.stim.edata_fixation_color_change(tid,1) = time_current;
    end
    
    % Record memory onset
    if expsetup.stim.eframes_memory_on{tid}(c1_frame_index1,1)==1 && isnan(expsetup.stim.edata_memory_on(tid,1))
        if expsetup.general.recordeyes==1
            Eyelink('Message', 'memory_on');
        end
        expsetup.stim.edata_memory_on(tid,1) = time_current;
    end
    
    % Record memory offset
    if expsetup.stim.eframes_memory_off{tid}(c1_frame_index1,1)==1 && isnan(expsetup.stim.edata_memory_off(tid,1))
        if expsetup.general.recordeyes==1
            Eyelink('Message', 'memory_off');
        end
        expsetup.stim.edata_memory_off(tid,1) = time_current;
    end
    
    % Record st1 onset
    if expsetup.stim.eframes_st1_on{tid}(c1_frame_index1,1)==1 && isnan(expsetup.stim.edata_st1_on(tid,1))
        if expsetup.general.recordeyes==1
            Eyelink('Message', 'target_on');
        end
        expsetup.stim.edata_st1_on(tid,1) = time_current;
    end
    
    % Record st2 onset
    if expsetup.stim.eframes_st2_on{tid}(c1_frame_index1,1)==1 && isnan(expsetup.stim.edata_st2_on(tid,1))
        if expsetup.general.recordeyes==1
            Eyelink('Message', 'st2_on');
        end
        expsetup.stim.edata_st2_on(tid,1) = time_current;
    end
    
    % Record st2 offset
    if expsetup.stim.eframes_st2_off{tid}(c1_frame_index1,1)==1 && isnan(expsetup.stim.edata_st2_off(tid,1))
        if expsetup.general.recordeyes==1
            Eyelink('Message', 'st2_off');
        end
        expsetup.stim.edata_st2_off(tid,1) = time_current;
    end
    
    % Record distractor onset
    if expsetup.stim.eframes_distractor_on{tid}(c1_frame_index1,1)==1 && isnan(expsetup.stim.edata_distractor_on(tid,1))
        if expsetup.general.recordeyes==1
            Eyelink('Message', 'distractor_on');
        end
        expsetup.stim.edata_distractor_on(tid,1) = time_current;
    end
    
    % Record distractor offset
    if expsetup.stim.eframes_distractor_off{tid}(c1_frame_index1,1)==1 && isnan(expsetup.stim.edata_distractor_off(tid,1))
        if expsetup.general.recordeyes==1
            Eyelink('Message', 'distractor_off');
        end
        expsetup.stim.edata_distractor_off(tid,1) = time_current;
    end
    
    
    %%  Get eyelink data sample
    
    try
        [mx,my] = runexp_eyelink_get_v11;
        expsetup.stim.eframes_eye_x{tid}(c1_frame_index1, 1)=mx;
        expsetup.stim.eframes_eye_y{tid}(c1_frame_index1, 1)=my;
    catch
        expsetup.stim.eframes_eye_x{tid}(c1_frame_index1, 1)=999999;
        expsetup.stim.eframes_eye_y{tid}(c1_frame_index1, 1)=999999;
    end
    
    
    
    %% Plot eyelink targets

    %===========================
    % Draw eyelink fixation area BEFORE drift correction
    %===========================

    if expsetup.general.recordeyes == 1 && ~isnan(expsetup.stim.edata_fixation_on(tid,1)) && isnan(expsetup.stim.edata_eyelinkscreen_drift_on(tid,1))
        if expsetup.stim.esetup_fixation_drift_correction_on(tid,1)==1
            a = round(fixation_rect_eyelink_drift);
            Eyelink('Command', 'draw_box %d %d %d %d 15', a(1),a(2),a(3),a(4));
        else
            a=round(fixation_rect_eyelink);
            Eyelink('Command', 'draw_box %d %d %d %d 15', a(1),a(2),a(3),a(4));
        end
        a=round(fixation_rect);
        Eyelink('Command', 'draw_filled_box %d %d %d %d 15', a(1),a(2),a(3),a(4));
        expsetup.stim.edata_eyelinkscreen_drift_on(tid,1) = time_current;
    end
    
     
    %===========================
    % Draw eyelink fixation area AFTER drift correction
    %===========================
    if expsetup.general.recordeyes == 1 && isnan(expsetup.stim.edata_eyelinkscreen_fixation(tid,1)) && ~isnan(expsetup.stim.edata_fixation_drift_maintained(tid,1))
        
        % Clear earlier screen
        Eyelink('command','clear_screen 0');
        x1_error = expsetup.stim.esetup_fixation_drift_offset(tid,1);
        y1_error = expsetup.stim.esetup_fixation_drift_offset(tid,2);
        
        % Recalculate eye-link rectangle
        eyepos=[];
        eyepos(1)=fixation_rect_eyelink(1)+x1_error;
        eyepos(3)=fixation_rect_eyelink(3)+x1_error;
        eyepos(2)=fixation_rect_eyelink(2)+y1_error;
        eyepos(4)=fixation_rect_eyelink(4)+y1_error;
        a=round(eyepos);
        Eyelink('Command', 'draw_box %d %d %d %d 15', a(1),a(2),a(3),a(4));
        
        % Recalculate eye-link rectangle
        eyepos=[];
        eyepos(1)=fixation_rect(1)+x1_error;
        eyepos(3)=fixation_rect(3)+x1_error;
        eyepos(2)=fixation_rect(2)+y1_error;
        eyepos(4)=fixation_rect(4)+y1_error;
        a=round(eyepos);
        Eyelink('Command', 'draw_filled_box %d %d %d %d 15', a(1),a(2),a(3),a(4));
        
        expsetup.stim.edata_eyelinkscreen_fixation(tid,1) = time_current;
        
    end
    
    %===========================
    % Memory target plotted (during delay)
    %===========================

    if expsetup.general.recordeyes == 1 && isnan(expsetup.stim.edata_eyelinkscreen_memory(tid,1)) && ~isnan(expsetup.stim.edata_memory_on(tid,1))
        
        x1_error = expsetup.stim.esetup_fixation_drift_offset(tid,1);
        y1_error = expsetup.stim.esetup_fixation_drift_offset(tid,2);
        
        % Recalculate eye-link rectangle
        eyepos=[];
        eyepos(1)=memory_rect(1)+x1_error;
        eyepos(3)=memory_rect(3)+x1_error;
        eyepos(2)=memory_rect(2)+y1_error;
        eyepos(4)=memory_rect(4)+y1_error;
        a=round(eyepos);
        Eyelink('Command', 'draw_filled_box %d %d %d %d 15', a(1),a(2),a(3),a(4)); % In color
        
        expsetup.stim.edata_eyelinkscreen_memory(tid,1) = time_current;
    end
    
    %===========================
    % Distractor plotted (during delay)
    %===========================
    
    if expsetup.general.recordeyes == 1 && isnan(expsetup.stim.edata_eyelinkscreen_distractor(tid,1)) && ~isnan(expsetup.stim.edata_distractor_on(tid,1))
        
        x1_error = expsetup.stim.esetup_fixation_drift_offset(tid,1);
        y1_error = expsetup.stim.esetup_fixation_drift_offset(tid,2);
        
        % Recalculate eye-link rectangle
        eyepos=[];
        eyepos(1)=dist_rect(1)+x1_error;
        eyepos(3)=dist_rect(3)+x1_error;
        eyepos(2)=dist_rect(2)+y1_error;
        eyepos(4)=dist_rect(4)+y1_error;
        a=round(eyepos);
        Eyelink('Command', 'draw_box %d %d %d %d 2', a(1),a(2),a(3),a(4)); % In color
        
        expsetup.stim.edata_eyelinkscreen_distractor(tid,1) = time_current;
    end
    
    %===========================
    % Draw sacacde target
    %===========================
    
    if expsetup.general.recordeyes == 1 && isnan(expsetup.stim.edata_eyelinkscreen_st1(tid,1)) && ~isnan(expsetup.stim.edata_st1_on(tid,1))
        
        % Clear earlier screen
        Eyelink('command','clear_screen 0');
        x1_error = expsetup.stim.esetup_fixation_drift_offset(tid,1);
        y1_error = expsetup.stim.esetup_fixation_drift_offset(tid,2);
        
        % Target
        eyepos=[];
        eyepos(1,1)=st1_rect_eyelink(1)+x1_error;
        eyepos(3,1)=st1_rect_eyelink(3)+x1_error;
        eyepos(2,1)=st1_rect_eyelink(2)+y1_error;
        eyepos(4,1)=st1_rect_eyelink(4)+y1_error;
        a=round(eyepos);
        Eyelink('Command', 'draw_box %d %d %d %d 4', a(1),a(2),a(3),a(4)); % Empty square
        
        expsetup.stim.edata_eyelinkscreen_st1(tid,1) = time_current;
    end
    
    %===========================
    % Draw distractor
    %===========================
    
    if expsetup.general.recordeyes == 1 && isnan(expsetup.stim.edata_eyelinkscreen_st2(tid,1)) && ~isnan(expsetup.stim.edata_st2_on(tid,1))
        if expsetup.stim.esetup_target_number(tid)==2
            
            x1_error = expsetup.stim.esetup_fixation_drift_offset(tid,1);
            y1_error = expsetup.stim.esetup_fixation_drift_offset(tid,2);
            
            % Distractor
            eyepos=[];
            eyepos(1,1)=st2_rect_eyelink(1)+x1_error;
            eyepos(3,1)=st2_rect_eyelink(3)+x1_error;
            eyepos(2,1)=st2_rect_eyelink(2)+y1_error;
            eyepos(4,1)=st2_rect_eyelink(4)+y1_error;
            a=round(eyepos);
            Eyelink('Command', 'draw_box %d %d %d %d 15', a(1),a(2),a(3),a(4)); % Empty square
        end
        expsetup.stim.edata_eyelinkscreen_st2(tid,1) = time_current;
    end
    %===================
    
    
    %% Check for eye position
    
    %===========================
    % Part 0: Determine which target participant looked at
    %===========================
    
    if expsetup.general.recordeyes==1
        
        % Target coordinates
        x1_target = []; y1_target = []; error1=[];
        x1_error = expsetup.stim.esetup_fixation_drift_offset(tid,1);
        y1_error = expsetup.stim.esetup_fixation_drift_offset(tid,2);
        % Initialize which targets to check for at which periods
        
        if expsetup.stim.esetup_fixation_drift_correction_on(tid,1)==1 && isnan(expsetup.stim.edata_fixation_drift_maintained(tid,1)) % Before drift correction
            
            % Target 1 - fixation position
            [x,y] = RectCenter(fixation_rect);
            x1_target(1) = x + x1_error; % Fixation coordinates x (with potential error)
            y1_target(1) = y + y1_error; % Fixation coordinates y (with potential error)
            error1(1) = expsetup.stim.esetup_fixation_size_drift(tid,4) * expsetup.screen.deg2pix;
            
        elseif ~isnan(expsetup.stim.edata_fixation_drift_maintained(tid,1)) && isnan(expsetup.stim.edata_st1_on(tid,1)) ... % After drift correction or if no drift correction is done
                && isnan(expsetup.stim.edata_distractor_on(tid,1))
            
            % Target 1 - fixation position
            [x,y]=RectCenter(fixation_rect);
            x1_target(1) = x + x1_error; % Fixation coordinates x (with potential error)
            y1_target(1) = y + y1_error; % Fixation coordinates y (with potential error)
            error1(1) = expsetup.stim.esetup_fixation_size_eyetrack(tid,4) * expsetup.screen.deg2pix;
            
        elseif ~isnan(expsetup.stim.edata_fixation_drift_maintained(tid,1)) && isnan(expsetup.stim.edata_st1_on(tid,1)) ... % After drift correction or if no drift correction is done
                && ~isnan(expsetup.stim.edata_distractor_on(tid,1))
            
            % Target 1 - fixation position
            [x,y]=RectCenter(fixation_rect);
            x1_target(1) = x + x1_error; % Fixation coordinates x (with potential error)
            y1_target(1) = y + y1_error; % Fixation coordinates y (with potential error)
            error1(1) = expsetup.stim.esetup_fixation_size_eyetrack(tid,4) * expsetup.screen.deg2pix;
            
            % Target 2 - distractor
            [x,y]=RectCenter(dist_rect);
            x1_target (2) = x+x1_error;
            y1_target (2) = y+y1_error;
            error1(2) = expsetup.stim.esetup_target_size_eyetrack(tid,4) * expsetup.screen.deg2pix;
        
        elseif ~isnan(expsetup.stim.edata_st1_on(tid,1))
            
            % Target 1 - fixation position
            [x,y]=RectCenter(fixation_rect);
            x1_target(1) = x + x1_error; % Fixation coordinates x (with potential error)
            y1_target(1) = y + y1_error; % Fixation coordinates y (with potential error)
            error1(1) = expsetup.stim.esetup_fixation_size_eyetrack(tid,4) * expsetup.screen.deg2pix;
            
            % Target 2 - saccade
            [x,y]=RectCenter(st1_rect);
            x1_target (2) = x+x1_error;
            y1_target (2) = y+y1_error;
            error1(2) = expsetup.stim.esetup_target_size_eyetrack(tid,4) * expsetup.screen.deg2pix;
            
            % Target 3 - distractor (if exists)
            if expsetup.stim.esetup_target_number(tid)==2
                [x,y]=RectCenter(st2_rect);
                x1_target (3) = x+x1_error;
                y1_target (3) = y+y1_error;
                error1(3) = expsetup.stim.esetup_target_size_eyetrack(tid,4) * expsetup.screen.deg2pix;
            elseif expsetup.stim.esetup_target_number(tid)==1
                % Check also for memory location directed saccades
                if sum (st1_rect==memory_rect) < numel(st1_rect)
                    [x,y]=RectCenter(memory_rect);
                    x1_target (3) = x+x1_error;
                    y1_target (3) = y+y1_error;
                else
                    x1_target (3) = NaN;
                    y1_target (3) = NaN;
                end
                error1(3) = expsetup.stim.esetup_target_size_eyetrack(tid,4) * expsetup.screen.deg2pix;
            end
            
            
        end
        
        % Data points with recorded saccade position
        x1_recorded = expsetup.stim.eframes_eye_x{tid}(c1_frame_index1, 1);
        y1_recorded = expsetup.stim.eframes_eye_y{tid}(c1_frame_index1, 1);
        
        % Which target eye went to?
        tsel1 = runexp_check_eye_target_v11 (x1_recorded, y1_recorded, x1_target, y1_target, error1);
        
        % Save it into matrix
        if length(tsel1)==1
            expsetup.stim.eframes_eye_target{tid}(c1_frame_index1, 1) = tsel1;
        end
    end
    
    
    %============================
    % Part 1: determine whether fixation was acquired at all
    %===========================
    
    if isnan(expsetup.stim.edata_fixation_acquired(tid,1))
        
        % Time
        timer1_now = expsetup.stim.eframes_time{tid}(c1_frame_index1, 1);
        %
        timer1_start = expsetup.stim.edata_fixation_on(tid,1);
        %
        timer1_duration = expsetup.stim.esetup_fixation_acquire_duration(tid,1);
        
        if expsetup.general.recordeyes==1
            if timer1_now - timer1_start < timer1_duration % Record an error
                if expsetup.stim.eframes_eye_target{tid}(c1_frame_index1, 1) == 1
                    expsetup.stim.edata_fixation_acquired(tid,1) = timer1_now;
                    Eyelink('Message', 'fixation_acquired');
                end
            elseif timer1_now - timer1_start >= timer1_duration % Record an error
                expsetup.stim.edata_error_code{tid} = 'fixation not acquired in time';
            end
        elseif expsetup.general.recordeyes==0
            if timer1_now - timer1_start >= timer1_duration % Record an error
                expsetup.stim.edata_fixation_acquired(tid,1) = timer1_now;
            end
        end
          
    end
    
        
    %============================
    % Part 2: determine whether drift fixation was maintained
    %===========================
    
    if expsetup.stim.esetup_fixation_drift_correction_on(tid,1)==1 && ~isnan(expsetup.stim.edata_fixation_acquired(tid,1)) && isnan(expsetup.stim.edata_fixation_drift_maintained(tid,1))
        
        % Time
        timer1_now = expsetup.stim.eframes_time{tid}(c1_frame_index1, 1);
        %
        timer1_start = expsetup.stim.edata_fixation_acquired(tid,1) + expsetup.stim.fixation_drift_maintain_minimum;
        %
        timer1_duration = expsetup.stim.fixation_drift_maintain_maximum - expsetup.stim.fixation_drift_maintain_minimum;
        
        if expsetup.general.recordeyes==1
            if timer1_now - timer1_start < timer1_duration % Record an error
                if expsetup.stim.eframes_eye_target{tid}(c1_frame_index1, 1) ~= 1
                    expsetup.stim.edata_error_code{tid} = 'broke fixation before drift';
                end
            elseif timer1_now - timer1_start >= timer1_duration % Record an error
                expsetup.stim.edata_fixation_drift_maintained(tid,1) = timer1_now;
                Eyelink('Message', 'fixation_drift_maintained');
            end
        elseif expsetup.general.recordeyes==0
            if timer1_now - timer1_start >= timer1_duration % Record an error
                expsetup.stim.edata_fixation_drift_maintained(tid,1) = timer1_now;
            end
        end
        
    end
    
    % Deterine the error to be updated for drift correction
    if expsetup.general.recordeyes == 1 && ~isnan(expsetup.stim.edata_fixation_drift_maintained(tid,1)) && isnan(expsetup.stim.edata_fixation_drift_calculated(tid,1))
        a = expsetup.stim.fixation_drift_maintain_maximum - expsetup.stim.fixation_drift_maintain_minimum;
        t1 = round(a/expsetup.screen.ifi);
        ind1 = (c1_frame_index1 - t1 + 1 : 1 : c1_frame_index1);
        ind1 (ind1<=0) = []; % In case theres problem with refresh rates, remove neg frames
        if numel(ind1)>1
            % Data points with recorded saccade position
            x1 = expsetup.stim.eframes_eye_x{tid}(ind1,1);
            y1 = expsetup.stim.eframes_eye_y{tid}(ind1,1);
            % Determine average position
            x1 = mean(x1);
            y1 = mean(y1);
            [fix_xc,fix_yc]=RectCenter(fixation_rect);
            expsetup.stim.esetup_fixation_drift_offset(tid,1) =  x1 - fix_xc;
            expsetup.stim.esetup_fixation_drift_offset(tid,2) =  y1 - fix_yc;
            expsetup.stim.edata_fixation_drift_calculated(tid,1) = 1;
        else
            expsetup.stim.esetup_fixation_drift_offset(tid,1) =  0;
            expsetup.stim.esetup_fixation_drift_offset(tid,2) =  0;
            expsetup.stim.edata_fixation_drift_calculated(tid,1) = 1;
        end
    end
    
   
    %===================
    % Part 3: Determine whether fixation was maintained
    %===================
    
    if ~isnan(expsetup.stim.edata_fixation_acquired(tid,1)) && isnan(expsetup.stim.edata_fixation_maintained(tid,1))
        
        % Time
        timer1_now = expsetup.stim.eframes_time{tid}(c1_frame_index1, 1);
        %
        timer1_start = expsetup.stim.edata_fixation_acquired(tid,1);
        %
        timer1_duration = expsetup.stim.esetup_total_fixation_duration(tid,1);
        
        if expsetup.general.recordeyes==1
            if timer1_now - timer1_start < timer1_duration % Record an error
                %============
                % Separate code for distractor on trials
                if strcmp(expsetup.stim.esetup_exp_version{tid}, 'distractor train luminance') || ...
                        strcmp(expsetup.stim.esetup_exp_version{tid}, 'distractor train position') || ...
                        strcmp(expsetup.stim.esetup_exp_version{tid}, 'distractor on')
                    %==
                    if expsetup.stim.eframes_eye_target{tid}(c1_frame_index1, 1) ==2
                        expsetup.stim.edata_error_code{tid} = 'looked at distractor';
                    elseif expsetup.stim.eframes_eye_target{tid}(c1_frame_index1, 1) ~= 1
                        expsetup.stim.edata_error_code{tid} = 'broke fixation';
                    end
                    %==
                else
                    if expsetup.stim.eframes_eye_target{tid}(c1_frame_index1, 1) ~= 1
                        expsetup.stim.edata_error_code{tid} = 'broke fixation';
                    end
                end
                %==============

            elseif timer1_now - timer1_start >= timer1_duration % Record an error
                % SPECIAL CASE: for fix training terminate the trial
                if strcmp(expsetup.stim.esetup_exp_version{tid}, 'fix duration increase') || ...
                        strcmp(expsetup.stim.esetup_exp_version{tid}, 'fix duration stable')
                    % Terminate the trial
                    expsetup.stim.edata_error_code{tid} = 'correct';
                end
                expsetup.stim.edata_fixation_maintained(tid,1) = timer1_now;
                Eyelink('Message', 'fixation_maintained');
                
            end
        elseif expsetup.general.recordeyes==0
            if timer1_now - timer1_start >= timer1_duration % Record an error
                % SPECIAL CASE: for fix training terminate the trial
                if strcmp(expsetup.stim.esetup_exp_version{tid}, 'fix duration increase') || ...
                        strcmp(expsetup.stim.esetup_exp_version{tid}, 'fix duration stable')
                    % Terminate the trial
                    expsetup.stim.edata_error_code{tid} = 'correct';
                end
                expsetup.stim.edata_fixation_maintained(tid,1) = timer1_now;
            end
        end
    end
    
    %===================
    % Part 4: Determine whether saccade target was acquired
    %===================
    
    if ~isnan(expsetup.stim.edata_st1_on(tid,1)) && isnan(expsetup.stim.edata_response_acquired(tid,1))
        
        % Time
        timer1_now = expsetup.stim.eframes_time{tid}(c1_frame_index1, 1);
        %
        timer1_start = expsetup.stim.edata_st1_on(tid,1);
        %
        timer1_duration = expsetup.stim.response_duration;
        
        if expsetup.general.recordeyes==1
            if timer1_now - timer1_start < timer1_duration % Record an error
                if expsetup.stim.eframes_eye_target{tid}(c1_frame_index1, 1) == 2
                    expsetup.stim.edata_response_acquired(tid,1) = timer1_now;
                    Eyelink('Message', 'response_acquired');
                elseif expsetup.stim.eframes_eye_target{tid}(c1_frame_index1, 1) > 2
                    expsetup.stim.edata_response_acquired(tid,1) = timer1_now;
                    Eyelink('Message', 'response_acquired');
                    expsetup.stim.edata_error_code{tid} = 'looked at st2';
                end
            elseif timer1_now - timer1_start >= timer1_duration % Record an error
                expsetup.stim.edata_error_code{tid} = 'no saccade';
            end
        elseif expsetup.general.recordeyes==0
            if timer1_now - timer1_start >= timer1_duration % Record an error
                expsetup.stim.edata_response_acquired(tid,1) = timer1_now;
            end
        end
        
    end
    
    
    %===================
    % Part 5: Determine whether saccade target was maintained
    %===================
    
    if ~isnan(expsetup.stim.edata_response_acquired(tid,1)) && isnan(expsetup.stim.edata_response_maintained(tid,1))
        
        % Time
        timer1_now = expsetup.stim.eframes_time{tid}(c1_frame_index1, 1);
        %
        timer1_start = expsetup.stim.edata_response_acquired(tid,1);
        %
        timer1_duration = expsetup.stim.response_saccade_hold_duration;
        
        if expsetup.general.recordeyes==1
            if timer1_now - timer1_start < timer1_duration % Record an error
                if expsetup.stim.eframes_eye_target{tid}(c1_frame_index1, 1) ~= 2  && expsetup.stim.eframes_eye_target{tid}(c1_frame_index1, 1) ~= 3
                    expsetup.stim.edata_error_code{tid} = 'left ST';
                end
            elseif timer1_now - timer1_start >= timer1_duration % Record an error
                expsetup.stim.edata_response_maintained(tid,1) = timer1_now;
                Eyelink('Message', 'response_maintained');
            end
        elseif expsetup.general.recordeyes==0
            if timer1_now - timer1_start >= timer1_duration % Record an error
                expsetup.stim.edata_response_maintained(tid,1) = timer1_now;
            end
        end

    end
    
    
    
    %% Check button presses
    
    [keyIsDown, keyTime, keyCode] = KbCheck;
    char = KbName(keyCode);
    % Catch potential press of two buttons
    if iscell(char)
        char=char{1};
    end
    
    % Record what kind of button was pressed
    if strcmp(char,'c') || strcmp(char,'p') || strcmp(char,'r') || strcmp(char,'space') || strcmp(char, expsetup.general.quit_key)
        expsetup.stim.edata_error_code{tid} = 'experimenter terminated the trial';
    end

    
    %% Correct trial?
    
    % Determine whether trial loop is to be finished
    if ~isnan(expsetup.stim.edata_response_maintained(tid,1))
        expsetup.stim.edata_error_code{tid} = 'correct';
    end
    
    %% If its the last frame, save few missing parameters & terminate
    
    % If run out of frames  - end trial (should never happen)
    if c1_frame_index1==size(expsetup.stim.eframes_time{tid},1)
        loop_over = 1;
    end
    
    % If error - end trial
    if ~isnan(expsetup.stim.edata_error_code{tid})
        loop_over = 1;
    end
    
    
end

% Reduce trialmat in size (save only frames that are used)
if c1_frame_index1+1<size(expsetup.stim.eframes_time{tid},1)
    f1 = fieldnames(expsetup.stim);
    ind = strncmp(f1,'eframes', 7);
    for i=1:numel(ind)
        if ind(i)==1
            if iscell(expsetup.stim.(f1{i}))
                expsetup.stim.(f1{i}){tid}(c1_frame_index1+1:end,:,:) = [];
            end
        end
    end
end

% Clear off all the screens
Screen('FillRect', window, expsetup.stim.esetup_background_color(tid,:));
if expsetup.general.record_plexon==1
    Screen('FillRect', window, [0, 0, 0], ph_rect, 1);
end
[~, time_current, ~]=Screen('Flip', window);

% Plexon message that display is cleared
% Individual event mode (EVENT 2)
if expsetup.general.record_plexon==1
    a1 = zeros(1,expsetup.ni_daq.digital_channel_total);
    a1_s = expsetup.general.plex_event_end; % Channel number used for events
    a1(a1_s)=1;
    outputSingleScan(ni.session_plexon_events,a1);
    a1 = zeros(1,expsetup.ni_daq.digital_channel_total);
    outputSingleScan(ni.session_plexon_events,a1);
end

% Save eyelink and psychtoolbox events
if expsetup.general.recordeyes==1
    Eyelink('Message', 'loop_over');
end
expsetup.stim.edata_loop_over(tid,1) = time_current;

% Save eyelink and psychtoolbox events
expsetup.stim.edata_fixation_off(tid,1)
if isnan(expsetup.stim.edata_fixation_off(tid,1))
    if expsetup.general.recordeyes==1
        Eyelink('Message', 'fixation_off');
    end
    expsetup.stim.edata_fixation_off(tid,1) = time_current;
end

% Record st1 offset
if ~isnan(expsetup.stim.edata_st1_on(tid,1)) && isnan(expsetup.stim.edata_st1_off(tid,1))
    if expsetup.general.recordeyes==1
        Eyelink('Message', 'target_off');
    end
    expsetup.stim.edata_st1_off(tid,1) = time_current;
end

% Record st2 offset
if ~isnan(expsetup.stim.edata_st2_on(tid,1)) && isnan(expsetup.stim.edata_st2_off(tid,1))
    if expsetup.general.recordeyes==1
        Eyelink('Message', 'distractor_off');
    end
    expsetup.stim.edata_st2_off(tid,1) = time_current;
end

% Clear eyelink screen
if expsetup.general.recordeyes==1
    Eyelink('command','clear_screen 0');
end

% Print trial duration
t1 = expsetup.stim.edata_loop_over(tid,1);
t0 = expsetup.stim.edata_first_display(tid,1);
fprintf('Trial duration (from first display to reward) was %i ms \n', round((t1-t0)*1000))
fprintf('Trial evaluation: %s\n', expsetup.stim.edata_error_code{tid})


%% Online performance tracking

% Check whether trial is counted towards online performance tracking. In
% some cases correct trials can be discounted.

if strcmp(expsetup.stim.esetup_exp_version{tid}, 'delay increase') || strcmp(expsetup.stim.esetup_exp_version{tid}, 'final version') ||...
        strcmp(expsetup.stim.esetup_exp_version{tid}, 'task switch luminance change') || strcmp(expsetup.stim.esetup_exp_version{tid}, 'task switch luminance equal') || ...
        strcmp(expsetup.stim.esetup_exp_version{tid}, 'added probe trials') || ...
        strcmp(expsetup.stim.esetup_exp_version{tid}, 'look luminance change') || strcmp(expsetup.stim.esetup_exp_version{tid}, 'look luminance equal') || ...
        strcmp(expsetup.stim.esetup_exp_version{tid}, 'avoid luminance change') || strcmp(expsetup.stim.esetup_exp_version{tid}, 'avoid luminance equal')
    %==========
    if strcmp(expsetup.stim.edata_error_code{tid}, 'correct')
        expsetup.stim.edata_trial_online_counter(tid,1) = 1;
    elseif strcmp(expsetup.stim.edata_error_code{tid}, 'looked at st2') || strcmp(expsetup.stim.edata_error_code{tid}, 'experimenter terminated the trial')
        expsetup.stim.edata_trial_online_counter(tid,1) = 2;
    end
    %=========
elseif strcmp(expsetup.stim.esetup_exp_version{tid}, 'distractor train luminance') || ...
        strcmp(expsetup.stim.esetup_exp_version{tid}, 'distractor train position') || ...
        strcmp(expsetup.stim.esetup_exp_version{tid}, 'distractor on')
    %==========
    if strcmp(expsetup.stim.edata_error_code{tid}, 'correct')
        expsetup.stim.edata_trial_online_counter(tid,1) = 1;
    elseif strcmp(expsetup.stim.edata_error_code{tid}, 'looked at distractor') || strcmp(expsetup.stim.edata_error_code{tid}, 'experimenter terminated the trial')
        expsetup.stim.edata_trial_online_counter(tid,1) = 2;
    end
    %=========
elseif strcmp(expsetup.stim.esetup_exp_version{tid}, 'fix duration increase') || ...
        strcmp(expsetup.stim.esetup_exp_version{tid}, 'fix duration stable')
    %==========
    if strcmp(expsetup.stim.edata_error_code{tid}, 'correct')
        expsetup.stim.edata_trial_online_counter(tid,1) = 1;
    elseif strcmp(expsetup.stim.edata_error_code{tid}, 'broke fixation') || strcmp(expsetup.stim.edata_error_code{tid}, 'experimenter terminated the trial')
        expsetup.stim.edata_trial_online_counter(tid,1) = 2;
    end
    %=========
else
    error ('Condition for correct/error trial tracking not specified')
end


%% Trial feedback

% Plot reward image onscreen
if expsetup.general.reward_on==1
    if expsetup.stim.reward_feedback==1
        
        if strcmp(expsetup.stim.edata_error_code{tid}, 'correct') || strcmp(char, 'space') || strcmp(char, 'r')
            Screen('DrawTexture', window, tex_positive, [], reward_rect, [], 0);
            [~, time_current, ~]=Screen('Flip', window);
        else
            Screen('DrawTexture',window, tex_negative, [], reward_rect, [], 0);
            [~, time_current, ~]=Screen('Flip', window);
        end
        
        if isnan(expsetup.stim.edata_reward_image_on(tid,1))
            if expsetup.general.recordeyes==1
                Eyelink('Message', 'reward_image_on');
            end
            expsetup.stim.edata_reward_image_on(tid,1) = time_current;
        end
        
    elseif expsetup.stim.reward_feedback==2  %Auditory feedback
        
        if isnan(expsetup.stim.edata_reward_image_on(tid,1))
            if expsetup.general.recordeyes==1
                Eyelink('Message', 'reward_image_on');
            end
            expsetup.stim.edata_reward_image_on(tid,1) = time_current;
        end
        
        if strcmp(expsetup.stim.edata_error_code{tid}, 'correct') || strcmp(char, 'space') || strcmp(char, 'r')
            b1 = MakeBeep(600, 0.05);
            b2 = MakeBeep(800, 0.05);
            beep = [b1, b2];
            Snd('Play', beep);
            WaitSecs(expsetup.stim.reward_feedback_audio_dur);
        elseif strcmp(expsetup.stim.edata_error_code{tid}, 'looked at distractor') % Wrong target selected
            b1 = MakeBeep(600, 0.05);
            b2 = MakeBeep(200, 0.05);
            beep = [b1, b2];
            Snd('Play', beep);
            WaitSecs(expsetup.stim.reward_feedback_audio_dur);
        else
            b1 = sin(0:2000);
            beep = [b1, b1];
            Snd('Play', beep);
            WaitSecs(expsetup.stim.reward_feedback_audio_dur);
        end
        
        
    elseif expsetup.stim.reward_feedback==3 && isfield (expsetup.general, 'arduino_session')
        
        if isnan(expsetup.stim.edata_reward_image_on(tid,1))
            if expsetup.general.recordeyes==1
                Eyelink('Message', 'reward_image_on');
            end
            expsetup.stim.edata_reward_image_on(tid,1) = time_current;
        end
        
        if strcmp(expsetup.stim.edata_error_code{tid}, 'correct') || strcmp(char, 'space') || strcmp(char, 'r')
            playTone(expsetup.general.arduino_session, 'D10', 600, 0.05);
            playTone(expsetup.general.arduino_session, 'D10', 800, 0.05);
            WaitSecs(expsetup.stim.reward_feedback_audio_dur);
        elseif strcmp(expsetup.stim.edata_error_code{tid}, 'looked at distractor') % Wrong target selected
            playTone(expsetup.general.arduino_session, 'D10', 600, 0.05);
            playTone(expsetup.general.arduino_session, 'D10', 200, 0.1);
            WaitSecs(expsetup.stim.reward_feedback_audio_dur);
        else
            playTone(expsetup.general.arduino_session, 'D10', 100, 0.2);
            WaitSecs(expsetup.stim.reward_feedback_audio_dur);
        end

        
    end
end


%% Start reward

% Prepare reward signal
if expsetup.general.reward_on==1
    if strcmp(expsetup.stim.edata_error_code{tid}, 'correct') || strcmp(char, 'space') || strcmp(char, 'r')
        % Continous reward
        reward_duration = expsetup.stim.reward_size_ms;
        signal1 = linspace(expsetup.ni_daq.reward_voltage, expsetup.ni_daq.reward_voltage, reward_duration)';
        signal1 = [0; signal1; 0; 0; 0; 0; 0];
        queueOutputData(ni.session_reward, signal1);        
    end
end

if expsetup.general.reward_on == 1
    if strcmp(expsetup.stim.edata_error_code{tid}, 'correct') || strcmp(char, 'space') || strcmp(char, 'r')
        ni.session_reward.startForeground;
        if expsetup.general.recordeyes==1
            Eyelink('Message', 'reward_on');
        end
        expsetup.stim.edata_reward_on(tid) = GetSecs;
        % Save how much reward was given
        expsetup.stim.edata_reward_size_ms(tid,1)=expsetup.stim.reward_size_ms;
        expsetup.stim.edata_reward_size_ml(tid,1)=expsetup.stim.reward_size_ml;
    else
        % Save how much reward was given
        expsetup.stim.edata_reward_size_ms(tid,1)=0;
        expsetup.stim.edata_reward_size_ml(tid,1)=0;
    end
end


%% Inter-trial interval & possibility to add extra reward

timer1_now = GetSecs;
time_start = GetSecs;
if ~isnan(expsetup.stim.edata_reward_on(tid)) 
    trial_duration = expsetup.stim.trial_dur_intertrial;
else % Error trials
    trial_duration = expsetup.stim.trial_dur_intertrial_error;
end

if strcmp(char,'x') || strcmp(char,'r') || strcmp(char,'c') || strcmp(char,'p') || strcmp(char,'space')
    endloop_skip = 1;
else
    endloop_skip = 0;
end

while endloop_skip == 0
    
    % Record what kind of button was pressed
    [keyIsDown,timeSecs,keyCode] = KbCheck;
    char = KbName(keyCode);
    % Catch potential press of two buttons
    if iscell(char)
        char=char{1};
    end
    
    % Give reward
    if strcmp(char,'space') || strcmp(char,'r')
        
        % Prepare reward signal
        if expsetup.general.reward_on==1
            % Continous reward
            reward_duration = expsetup.stim.reward_size_ms;
            signal1 = linspace(expsetup.ni_daq.reward_voltage, expsetup.ni_daq.reward_voltage, reward_duration)';
            signal1 = [0; signal1; 0; 0; 0; 0; 0];
            queueOutputData(ni.session_reward, signal1);
        end
        
        if expsetup.general.reward_on == 1
            ni.session_reward.startForeground;
            if expsetup.general.recordeyes==1
                Eyelink('Message', 'reward_on');
            end
            expsetup.stim.edata_reward_on(tid) = GetSecs;
            % Save how much reward was given
            expsetup.stim.edata_reward_size_ms(tid,1)=expsetup.stim.reward_size_ms;
            expsetup.stim.edata_reward_size_ml(tid,1)=expsetup.stim.reward_size_ml;
        end
        
        % End loop
        endloop_skip=1;
        
    elseif strcmp(char,'x') || strcmp(char,'p') || strcmp(char,'c')
        
        % End loop
        endloop_skip=1;
        
    end
    
    % Check time & quit loop
    timer1_now = GetSecs;
    if timer1_now - time_start >= trial_duration
        endloop_skip=1;
    end
    
end


%% Trigger new trial

Screen('FillRect', window, expsetup.stim.esetup_background_color(tid,:));
Screen('Flip', window);


%% Plot online data

% If plexon recording exists, get spikes
if expsetup.general.record_plexon == 1 && expsetup.general.plexon_online_spikes == 1
    look6_online_spikes;
    look6_online_plot;
end

if expsetup.general.record_plexon == 0
    look6_online_plot;
end



%% Stop experiment if too many errors in a row

if strcmp(expsetup.stim.edata_error_code{tid}, 'fixation not acquired in time') || ...
        strcmp(expsetup.stim.edata_error_code{tid}, 'broke fixation before drift') || ...
        strcmp(expsetup.stim.edata_error_code{tid}, 'broke fixation')
    % Trial failed
    expsetup.stim.edata_trial_abort_counter(tid,1) = 1;
end

% Add pause if trials are not accurate
if tid>=expsetup.stim.trial_abort_counter
    ind1 = tid-expsetup.stim.trial_abort_counter+1:tid;
    s1 = expsetup.stim.edata_trial_abort_counter(ind1, 1)==1;
    if sum(s1) == expsetup.stim.trial_abort_counter
        if ~strcmp(char,expsetup.general.quit_key')
            char='x';
            % Over-write older trials
            expsetup.stim.edata_trial_abort_counter(ind1, 1) = 2000;
        end
    end
end


%% STOP EYELINK RECORDING

if expsetup.general.recordeyes==1
    msg1=['TrialEnd ',num2str(tid)];
    Eyelink('Message', msg1);
    Eyelink('StopRecording');
end

fprintf('  \n')

%% Save texture as a separate file for each trial (to make memory faster)

dir1 = [expsetup.general.directory_data_psychtoolbox_subject];
if ~isdir (dir1)
    mkdir(dir1)
end
f_name = ['trial_' num2str(tid), '_texture_matrix'];
d1 = sprintf('%s%s', dir1, f_name);
save (d1, 'xy_texture_combined');

%% End experiment?

if expsetup.stim.esetup_block_no(tid) == expsetup.stim.number_of_blocks
    
    % How many trials in a block recorded?
    if expsetup.stim.trial_error_repeat == 1
        ind_correct = strcmp(expsetup.stim.edata_error_code, 'correct') & expsetup.stim.esetup_block_no == expsetup.stim.esetup_block_no(tid);
        ind_recorded = expsetup.stim.esetup_block_no == expsetup.stim.esetup_block_no(tid);
        % How many error trials recorded?
        temp1 = sum(ind_recorded)-sum(ind_correct); % -1 as we dont know whether current trial will be correct
        % Block size is expected number of trials + error trials
        ind_total = expsetup.stim.number_of_trials_per_block + temp1;
    else
        ind_recorded = expsetup.stim.esetup_block_no == expsetup.stim.esetup_block_no(tid);
        ind_total = expsetup.stim.number_of_trials_per_block;
    end
    % If it's last time of last block
    if sum(ind_recorded) == ind_total
        expsetup.stim.end_experiment = 1;
    end
    
end
    
    



