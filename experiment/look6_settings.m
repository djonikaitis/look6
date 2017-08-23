% All possible experimental settings within this file;
%
% Produces stim structure which contains all stimuli settings and trial
% definitions


%% Different training stages have different stim durations

stim.exp_version_temp = 'luminance change'; % Version you want to run

stim.training_stage_matrix = {'fixation training', 'look only', 'avoid only', 'added probe trials', ...
    'delay increase', 'luminance change', 'luminance equal', 'final version'};
stim.training_stage_matrix_numbers = 1:numel(stim.training_stage_matrix);

% Stage 'fixation training'. Learn to fixate while memory target is flashed.
% Stage 'look only'. Learn to do look task.
% Stage 'avoid only'. Learn to do avoid task.
% Stage 'luminance change'. Tasks interleaved, using stimulus luminance
% Stage 'delay increase'. Increase the delay.
% Stage 'final version'. No changes to the code. Look/avoid tasks interleaved.

% Stage 'delay'
% Increase memory delay duration
stim.memory_delay_duration_ini = 0.4;
stim.memory_delay_duration_ini_step = 0.1;
stim.fixation_maintain_duration_ini = 2.2;
stim.fixation_maintain_duration_ini_step = -0.1;

% Stage 'luminance change'
% Use stimulus luminance for interleaving blocks
stim.st2_color_level_ini = 0.6;
stim.st2_color_level_ini_step = -0.1;


%% Quick settings

% Specify target coordinates based on a RF mapping
x = -5; y = -3;
stim.target_spacing_arc = 90;

% Defaults
stim.main_cond = [2,1]; % 1 - look; 2 - avoid; 3 - control;  Can also run all tasks interleaved
stim.target_number(1:100)= 2; % Number of probes (= 1 or 2)
stim.target_number(97:100)= 1; % Number of probes (= 1 or 2)
stim.memory_delay_duration = [1.8:0.01:2.2]; % How long memory delay lasts
stim.memory_delay_duration_probe = stim.memory_delay_duration;
stim.number_of_trials_per_block = 150;
stim.number_of_blocks = 4;
stim.main_cond_shuffle = 2; % 1 - shuffle, 2 - preset order


%% Stimulus positions

[theta, rho] = cart2pol (x, y);
theta = (theta/pi)*180;
% Setup baseline coordinates
stim.target_arc = theta;
stim.target_radius = rho;

% Recalculate to the grid
target_arc = [stim.target_arc:stim.target_spacing_arc:stim.target_arc+359];
target_radius = [repmat(stim.target_radius, 1, length(target_arc))];
[xc, yc] = pol2cart(target_arc*pi/180, target_radius);

% Save coordintes
stim.response_target_coord = [xc',yc'];
stim.response_t3_coord  = stim.response_target_coord;

%%  Reward

% stim.reward_coeff1 = [460.0749   64.8784]; % Mount rack reward, measure as of 03.08.2016
stim.reward_coeff1 = [881.4887   -3.3301]; % Pump reward measure as of 10.19.2016

if isfield(expsetup.general, 'subject_id') && strcmp(expsetup.general.subject_id, 'aq')
    stim.reward_size_ml = 0.25; % Typical reward to start with
elseif isfield(expsetup.general, 'subject_id') && strcmp(expsetup.general.subject_id, 'hb')
    stim.reward_size_ml = 0.16; % Typical reward to start with
elseif isfield(expsetup.general, 'subject_id') && strcmp(expsetup.general.subject_id, 'jw')
    stim.reward_size_ml = 0.25; % Typical reward to start with
else
    stim.reward_size_ml = 0.18;
end
stim.reward_size_ms = round(polyval(stim.reward_coeff1, stim.reward_size_ml));
stim.reward_feedback = 3; % If 1 - show feedback;  2 - play audio feedback; 3 - audio feedback via arduino
stim.reward_feedback_audio_dur = 0.2; % How long to wait to give reward feedback
stim.reward_pic_size = [0, 0, 5, 5]; % If reward pic is shown, thats the size

%% Stimuli

%==============
% Fixation

% Fix position
stim.fixation_arc = [0]; % Fixation position in degrees from center
stim.fixation_radius = [0]; % Center-fixation distance

% Fix size
stim.fixation_size = [0.5]; % Size of fixation (degrees)
stim.fixation_pen = 4; % Fixation outline thickness (pixels)
stim.fixation_blink_frequency = 2; % How many time blinks per second;

% Look task fixation
stim.fixation_color_task1 = [20,20,200]; % Color of fixation or text on the screen
stim.fixation_shape_task1 = 'circle';
% Avoid task fixation
stim.fixation_color_task2 = [20,20,200]; % Color of fixation or text on the screen
stim.fixation_shape_task2 = 'circle';

% Fixation color change relative to memory target onset
stim.fixation_color_change_soa = -0.3; % Neg if before memory on, pos if after memory on
stim.fixation_color_memory_delay = [20,20,200];

% Fixation duration
stim.fixation_acquire_duration = [0.5]; % How long to show fixation before it is acquired
stim.fixation_maintain_duration = [0.6:0.01:0.8]; % Time to maintain target before memory onset

%===============
% Drif correction

stim.fixation_drift_correction_on = 1; % 1 - drift correction initiated
stim.fixation_size_drift = 5; % Larger fixation window for drift correction
stim.fixation_drift_maintain_minimum = 0.5; % Drift correction starts
stim.fixation_drift_maintain_maximum = 0.6; % Drift correction ends
if isfield(expsetup.general, 'subject_id') && strcmp(expsetup.general.subject_id(1:2), 'aq')
    stim.fixation_size_eyetrack = 2.5; % Window within which to maintain fixation
elseif isfield(expsetup.general, 'subject_id') && strcmp(expsetup.general.subject_id(1:2), 'hb')
    stim.fixation_size_eyetrack = 2.5; % Window within which to maintain fixation
else
    stim.fixation_size_eyetrack = 2.5; % Window within which to maintain fixation
end


%======================
% Memory target
stim.memory_size = [1]; % How big the object shown on the screen should be (DEGREES)
if ~isfield(stim, 'memory_color_task1')
    if strcmp (expsetup.general.subject_id(1:2), 'hb')
        stim.memory_color_task1 = [20,20,20]; % Color of the memory object
    else
        stim.memory_color_task1 = [20,200,20]; % Color of the memory object
    end
    stim.memory_shape_task1 = 'empty_square';  % circle, square, empty_circle, empty_quare
    stim.memory_pen_width_task1 = 10; % If empty shapes are drawn
end
if ~isfield(stim, 'memory_color_task2')
    if strcmp (expsetup.general.subject_id(1:2), 'hb')
        stim.memory_color_task2 = [20,200,20]; % Color of the memory object
    else
        stim.memory_color_task2 = [20,20,20]; % Color of the memory object
    end
    stim.memory_shape_task2 = 'empty_square';  % circle, square, empty_circle, empty_quare
    stim.memory_pen_width_task2 = 10; % If empty shapes are drawn
end
if ~isfield(stim, 'memory_color_task3')
    stim.memory_color_task3 = [20,20,20]; % Color of the memory object
    stim.memory_shape_task3 = 'empty_square';  % circle, square, empty_circle, empty_quare
    stim.memory_pen_width_task3 = 10; % If empty shapes are drawn
end
if ~isfield(stim, 'memory_color_task5')
    stim.memory_color_task5 = [250,250,250]; % Color of the memory object
    stim.memory_shape_task5 = 'square';  % circle, square, empty_circle, empty_quare
    stim.memory_pen_width_task5 = 10; % If empty shapes are drawn
end
if ~isfield(stim, 'memory_duration')
    stim.memory_duration = [0.05];
end

%================
% Response objects

stim.response_size = [1]; % How big the object shown on the screen should be (degrees)
stim.response_saccade_accuracy = 5;

stim.response_duration = 0.5; % How fast to make a response
stim.response_saccade_hold_duration = 0.2; % How long fixation on the saccade target for it to be a good trial
stim.response_pen_width = 5; % If empty shapes are drawn

stim.st2_color_level = 0; % No difference between ST1 and ST2

% Look task (T1 and T2, 85% of trials)
stim.response_shape_task1 = 'circle'; % circle, square, empty_circle, empty_quare
stim.response_t1_color_task1 = stim.fixation_color_memory_delay; % Memorized
stim.response_t2_color_task1 = stim.fixation_color_memory_delay; % Non-memorized

%====================
% Avoid task (T1 and T2, 85% of trials)
stim.response_shape_task2 = 'circle'; % circle, square, empty_circle, empty_quare
stim.response_t1_color_task2 = stim.fixation_color_memory_delay; % Memorized
stim.response_t2_color_task2 = stim.fixation_color_memory_delay; % Non-memorized


%=====================
% Probe (T3, 15 of trials)
stim.response_t3_color_task1 = [20,20,20]; % Color of the probe
stim.response_t3_color_task2 = [20,20,20];
stim.response_t3_color_task3 = [20,20,20];
stim.response_t3_shape = 'circle'; % circle, square, empty_circle, empty_quare


%============
% Distractor properties
if ~isfield(stim, 'response_distractor_soa')
    stim.response_distractor_soa = 0.0;
end
stim.response_remove_t2 = 1; % 1 - removes second target once first target is fixated

%==============
% Screen colors
stim.background_color_task1 = [127, 127, 127];
stim.background_color_task2 = [127, 127, 127];
stim.background_color_task3 = [127, 127, 127];

%==============
% Background texture
stim.background_texture_line_pen = 2; % Width of lines
stim.background_texture_line_color = [90,90,90];
stim.background_texture_line_length = 2; % Length in degrees
stim.background_texture_line_number = 10000; % Number of lines to be drawn;
stim.background_texture_line_angle = [0:20:179];
stim.background_texture_soa = -0.6; % Relative to memory onset; Negative - before memory onset;
stim.background_texture_on = [ones(1, length(stim.background_texture_line_angle)), 0]; % 1 - texture on, 0 - no texture

%===============
% Duration of inter-trial
stim.trial_dur_intertrial = 0.1; % Blank screen at the end
stim.trial_dur_intertrial_error = 2; % Blank screen at the end

%================
% Staircase
stim.trial_online_counter = 3; % How many trials to count for updating task difficulty
stim.trial_correct_goal_up = 3; % What is accuracy to make task harder
stim.trial_correct_goal_down = 2; % What is accuracy to make task harder

% Other
stim.trial_error_repeat = 1; % 1 - repeats same trial if error occured immediatelly; 0 - no repeat
stim.trial_abort_counter = 20; % Quit experiment if trials in a row are aborted
stim.plot_every_x_trial = 1; % Every which trial to plot (every 1, 2nd, 10th etc trial)
stim.end_experiment = 0; % Default value 

% Picture file used for instruction
stim.instrpic{1}='image_condition1';
stim.instrpic{2}='image_condition2';

% Define expmatrix file (settings for each trial)
if ~isfield (stim, 'number_of_blocks')
    stim.number_of_trials_per_block = 500;
    stim.number_of_blocks = 2;
end


%% Settings that change on each trial (matrix; one trial = one row)

% Specify column names for expmatrix
stim.esetup_exp_version{1} = NaN; % Which task version participant is doing
stim.esetup_block_no = NaN; % Which block number (1:number of blocks)
stim.esetup_block_cond = NaN; % Which blocked condition is presented

% Fixation
stim.esetup_fixation_arc = NaN;  % Fixation x position
stim.esetup_fixation_radius = NaN;  % Fixation x position
stim.esetup_fixation_color(1,1:3) = NaN;
stim.esetup_fixation_shape{1} = NaN;
stim.esetup_fixation_size(1,1:4) = NaN;
stim.esetup_fixation_size_drift(1,1:4) = NaN;
stim.esetup_fixation_size_eyetrack(1,1:4) = NaN;

% Fixation timing
stim.esetup_fixation_acquire_duration = NaN;
stim.esetup_fixation_maintain_duration = NaN;
stim.esetup_total_fixation_duration = NaN; % Delay + fixation duration

% Fixation drift parameters
stim.esetup_fixation_drift_correction_on = NaN; % Do drift correction or not?
stim.esetup_fixation_drift_offset(1,1:2) = NaN; % X-Y offset for the drift;

% Memory target and saccade targets
stim.esetup_memory_coord(1,1:2) = NaN;
stim.esetup_memory_size(1,1:4) = NaN;
stim.esetup_memory_color(1,1:3) = NaN;
stim.esetup_memory_shape{1} = NaN;
stim.esetup_memory_pen_width = NaN;

% Target
stim.esetup_st1_coord(1,1:2) = NaN;
stim.esetup_st1_color(1,1:3) = NaN;
% Distractor
stim.esetup_st2_coord(1,1:2) = NaN;
stim.esetup_st2_color(1,1:3) = NaN;
stim.esetup_st2_color_level = NaN;

% Response targets, common properties
stim.esetup_target_size(1,1:4) = NaN;
stim.esetup_target_size_eyetrack(1,1:4) = NaN;
stim.esetup_target_number = NaN; % 1 or 2 targets
stim.esetup_target_shape{1} = NaN;
stim.esetup_target_pen_width = NaN;

% Durations
stim.esetup_distractor_soa = NaN; % SOA between t1 & t2
stim.esetup_memory_duration = NaN; % Duration of memory target
stim.esetup_memory_delay = NaN; % Delay duration

% Texture & background
stim.esetup_background_texture_on = NaN; % Is texture shown
stim.esetup_background_texture_line_angle = NaN;
stim.esetup_background_texture_line_number = NaN;
stim.esetup_background_texture_line_length = NaN;
stim.esetup_xy_texture_combined{1} = NaN;
stim.esetup_background_color(1,1:3) = NaN; % Is texture shown

% Stim timing recorded
stim.edata_first_display = NaN; 
stim.edata_loop_over = NaN; 

% Fixation
stim.edata_fixation_on = NaN; 
stim.edata_fixation_acquired = NaN; 
stim.edata_fixation_drift_maintained = NaN;
stim.edata_fixation_drift_calculated = NaN; % Moment when calculations of the drift are done
stim.edata_fixation_maintained = NaN; 
stim.edata_fixation_off = NaN; 
stim.edata_fixation_color_change = NaN; 

% Targets
stim.edata_st1_on = NaN;
stim.edata_st1_off = NaN;
stim.edata_st2_on = NaN;
stim.edata_st2_off = NaN;
stim.edata_response_acquired = NaN;
stim.edata_response_maintained = NaN;

% Other
stim.edata_memory_on = NaN;
stim.edata_memory_off = NaN;
stim.edata_texture_on = NaN;

% Reward
stim.edata_reward_image_on = NaN;
stim.edata_reward_on = NaN;
stim.edata_reward_size_ms = NaN; % How much reward animal was given
stim.edata_reward_size_ml = NaN; % How much reward animal was given

% Variables for eyetracking plotting
stim.edata_eyelinkscreen_drift_on = NaN; % Drift stimulus window drawn on eyelink screen
stim.edata_eyelinkscreen_fixation = NaN; % Fixation after drift correction is done
stim.edata_eyelinkscreen_memory = NaN;
stim.edata_eyelinkscreen_st1 = NaN;
stim.edata_eyelinkscreen_st2 = NaN;

% Monitoring performance
stim.edata_error_code{1} = NaN;

stim.edata_trial_abort_counter = NaN;
stim.edata_trial_online_counter = NaN; % Error code


%% Settings that change on each frame (one trial = one cell; within cell - one row = one frame onscreen)

% Timingn and eye position
stim.eframes_time{1}(1) = NaN;
stim.eframes_eye_x{1}(1) = NaN;
stim.eframes_eye_y{1}(1) = NaN;
stim.eframes_eye_target{1}(1) = NaN;

% Other variables
stim.eframes_fixation{1}(1) = NaN;
stim.eframes_fixation_off{1}(1) = NaN;
stim.eframes_fixation_color_change{1}(1) = NaN;
stim.eframes_fixation_stops_blinking{1}(1) = NaN;
stim.eframes_texture_on{1}(1) = NaN;
stim.eframes_memory_on{1}(1) = NaN;
stim.eframes_memory_off{1}(1) = NaN;
stim.eframes_st1_on{1}(1) = NaN;
stim.eframes_st2_on{1}(1) = NaN;
stim.eframes_st2_off{1}(1) = NaN;



%% Save into expsetup

expsetup.stim=stim;


