% Randomized all parameters for the trial


%% Initialize NaN fields of all settings

% New trial initialized
if tid == 1
    % Do nothing
else
    f1 = fieldnames(expsetup.stim);
    ind = strncmp(f1,'esetup', 6) |...
        strncmp(f1,'edata', 5);
    for i=1:numel(ind)
        if ind(i)==1
            if ~iscell(expsetup.stim.(f1{i}))
                [m,n,o]=size(expsetup.stim.(f1{i}));
                expsetup.stim.(f1{i})(tid,1:n,1:o) = NaN;
            elseif iscell(expsetup.stim.(f1{i}))
                [m,n,o]=size(expsetup.stim.(f1{i}));
                expsetup.stim.(f1{i}){tid,1:n,1:o} = NaN;
            end
        end
    end
end

var_copy = struct; % This structure exists for training purposes only

%% Which exp version is running?

expsetup.stim.esetup_exp_version{tid,1} = expsetup.stim.exp_version_temp;


%% Main condition & block number

if tid==1
    a = expsetup.stim.number_of_blocks/numel(expsetup.stim.main_cond);
    a = floor(a);
    if size(expsetup.stim.main_cond, 1)< size(expsetup.stim.main_cond,2)
        expsetup.stim.main_cond = expsetup.stim.main_cond';
    end
    expsetup.stim.main_cond_reps = repmat(expsetup.stim.main_cond, a, 1);
end

if tid==1
    % Shuffle conditons or just do them in a sequence?
    if stim.main_cond_shuffle==1
        temp1=Shuffle(expsetup.stim.main_cond_reps);
    else
        temp1=expsetup.stim.main_cond_reps;
    end
    expsetup.stim.main_cond_reps = temp1;
    expsetup.stim.esetup_block_cond(tid) = temp1(1);
    expsetup.stim.esetup_block_no(tid) = 1;
elseif tid>1 
    if expsetup.stim.trial_error_repeat == 1
        ind = strcmp(expsetup.stim.edata_error_code, 'correct') & expsetup.stim.esetup_block_no == expsetup.stim.esetup_block_no(tid-1);
    else
        ind = expsetup.stim.esetup_block_no == expsetup.stim.esetup_block_no(tid-1);
    end
    if sum(ind) < expsetup.stim.number_of_trials_per_block % Same block
        expsetup.stim.esetup_block_cond(tid) = expsetup.stim.esetup_block_cond(tid-1);
        expsetup.stim.esetup_block_no(tid) = expsetup.stim.esetup_block_no(tid-1);
    elseif sum(ind) >= expsetup.stim.number_of_trials_per_block % New block
        expsetup.stim.esetup_block_no(tid) = expsetup.stim.esetup_block_no(tid-1)+1;
        i1 = expsetup.stim.esetup_block_no(tid);
        expsetup.stim.esetup_block_cond(tid) = expsetup.stim.main_cond_reps(i1);
    end
end

%% If it's look only or avoid only task training, replace conditions

if strcmp(expsetup.stim.exp_version_temp, 'look luminance change') ||...
        strcmp(expsetup.stim.exp_version_temp, 'look luminance equal')
    expsetup.stim.esetup_block_cond(tid) = 1;
elseif strcmp(expsetup.stim.exp_version_temp, 'avoid luminance change') || ...
        strcmp(expsetup.stim.exp_version_temp, 'avoid luminance equal')
    expsetup.stim.esetup_block_cond(tid) = 2;
end

%%  Background color

if expsetup.stim.esetup_block_cond(tid) == 1
    expsetup.stim.esetup_background_color(tid,1:3) = expsetup.stim.background_color_task1;
elseif expsetup.stim.esetup_block_cond(tid) == 2
    expsetup.stim.esetup_background_color(tid,1:3) = expsetup.stim.background_color_task2;
elseif expsetup.stim.esetup_block_cond(tid) == 3
    expsetup.stim.esetup_background_color(tid,1:3) = expsetup.stim.background_color_task3;
elseif expsetup.stim.esetup_block_cond(tid) == 4
    expsetup.stim.esetup_background_color(tid,1:3) = expsetup.stim.background_color_task4;
elseif expsetup.stim.esetup_block_cond(tid) == 5
    expsetup.stim.esetup_background_color(tid,1:3) = expsetup.stim.background_color_task5;
end


%%  Fix

% Fixation color

% Initialize different colors and shapes, based on block_cond
if expsetup.stim.esetup_block_cond(tid,1) == 1
    expsetup.stim.esetup_fixation_color(tid,1:3) = expsetup.stim.fixation_color_task1;
    expsetup.stim.esetup_fixation_shape{tid} = expsetup.stim.fixation_shape_task1;
elseif expsetup.stim.esetup_block_cond(tid,1) == 2
    expsetup.stim.esetup_fixation_color(tid,1:3) = expsetup.stim.fixation_color_task2;
    expsetup.stim.esetup_fixation_shape{tid} = expsetup.stim.fixation_shape_task2;
elseif expsetup.stim.esetup_block_cond(tid,1) == 3
    expsetup.stim.esetup_fixation_color(tid,1:3) = expsetup.stim.fixation_color_task3;
    expsetup.stim.esetup_fixation_shape{tid} = expsetup.stim.fixation_shape_task3;
elseif expsetup.stim.esetup_block_cond(tid,1) == 4
    expsetup.stim.esetup_fixation_color(tid,1:3) = expsetup.stim.fixation_color_task4;
    expsetup.stim.esetup_fixation_shape{tid} = expsetup.stim.fixation_shape_task4;
elseif expsetup.stim.esetup_block_cond(tid,1) == 5
    expsetup.stim.esetup_fixation_color(tid,1:3) = expsetup.stim.fixation_color_task5;
    expsetup.stim.esetup_fixation_shape{tid} = expsetup.stim.fixation_shape_task5;
end
    
% Fixation position
ind1=randperm(numel(expsetup.stim.fixation_arc));
expsetup.stim.esetup_fixation_arc(tid,1) = expsetup.stim.fixation_arc(ind1(1));
expsetup.stim.esetup_fixation_radius(tid,1) = expsetup.stim.fixation_radius(ind1(1));

% Fixation size
temp1=Shuffle(expsetup.stim.fixation_size);
expsetup.stim.esetup_fixation_size(tid,1:4) = [0, 0, temp1(1), temp1(1)];

% Fixation size drift
temp1=Shuffle(expsetup.stim.fixation_size_drift);
expsetup.stim.esetup_fixation_size_drift(tid,1:4) = [0, 0, temp1(1), temp1(1)];

% Fixation size eyetrack
temp1=Shuffle(expsetup.stim.fixation_size_eyetrack);
expsetup.stim.esetup_fixation_size_eyetrack(tid,1:4) = [0, 0, temp1(1), temp1(1)];

% Fixation acquire duration
temp1=Shuffle(expsetup.stim.fixation_acquire_duration);
expsetup.stim.esetup_fixation_acquire_duration(tid,1) = temp1(1);
 
% Fixation maintain duration varies as a stage of training

%============
% Modified part for two contingencies
ind0 = strcmp(expsetup.stim.training_stage_matrix, expsetup.stim.esetup_exp_version{tid});
ind1 = find(ind0==1);
%==========
% For fix duration increase training
%=========
if strcmp(expsetup.stim.esetup_exp_version{tid}, 'fix duration increase')
    
    ind0 = strcmp(expsetup.stim.training_stage_matrix, 'fix duration increase');
    ind2 = find(ind0==1);
    
    temp1 = Shuffle(tv1(1).temp_var_current);
    var_copy.esetup_fixation_maintain_duration = temp1(1); % Copy variable for error trials
    
    %==========
    % For fix delay duration increase training
    %=========
else
    ind0 = strcmp(expsetup.stim.training_stage_matrix, 'delay increase');
    ind2 = find(ind0==1);
    if ind1>ind2
        temp1 = Shuffle(expsetup.stim.fixation_maintain_duration);
    elseif ind1==ind2
        temp1 = Shuffle(tv1(1).temp_var_current);
        var_copy.esetup_fixation_maintain_duration = temp1(1); % Copy variable for error trials
    elseif ind1<ind2
        temp1 = Shuffle(expsetup.stim.fixation_maintain_duration_ini);
    end
end

%=============
expsetup.stim.esetup_fixation_maintain_duration(tid,1) = temp1(1);

% Do drift correction or not?
expsetup.stim.esetup_fixation_drift_correction_on(tid) = expsetup.stim.fixation_drift_correction_on;

% What is starting drift error? 0 by default
expsetup.stim.esetup_fixation_drift_offset (tid,1:2) = 0;



%% Memory target

% Memory size
temp1=Shuffle(expsetup.stim.memory_size);
expsetup.stim.esetup_memory_size(tid,1:4) = [0, 0, temp1(1), temp1(1)];

% Initialize different colors and shapes, based on block_cond
if expsetup.stim.esetup_block_cond(tid) == 1
    expsetup.stim.esetup_memory_color(tid,1:3) = expsetup.stim.memory_color_task1;
    expsetup.stim.esetup_memory_shape{tid} = expsetup.stim.memory_shape_task1;
    expsetup.stim.esetup_memory_pen_width(tid) = expsetup.stim.memory_pen_width_task1;
elseif expsetup.stim.esetup_block_cond(tid) == 2
    expsetup.stim.esetup_memory_color(tid,1:3) = expsetup.stim.memory_color_task2;
    expsetup.stim.esetup_memory_shape{tid} = expsetup.stim.memory_shape_task2;
    expsetup.stim.esetup_memory_pen_width(tid) = expsetup.stim.memory_pen_width_task2;
elseif expsetup.stim.esetup_block_cond(tid) == 3
    expsetup.stim.esetup_memory_color(tid,1:3) = expsetup.stim.memory_color_task3;
    expsetup.stim.esetup_memory_shape{tid} = expsetup.stim.memory_shape_task3;
    expsetup.stim.esetup_memory_pen_width(tid) = expsetup.stim.memory_pen_width_task3;
elseif expsetup.stim.esetup_block_cond(tid) == 4
    expsetup.stim.esetup_memory_color(tid,1:3) = expsetup.stim.memory_color_task4;
    expsetup.stim.esetup_memory_shape{tid} = expsetup.stim.memory_shape_task4;
    expsetup.stim.esetup_memory_pen_width(tid) = expsetup.stim.memory_pen_width_task4;
elseif expsetup.stim.esetup_block_cond(tid) == 5
    expsetup.stim.esetup_memory_color(tid,1:3) = expsetup.stim.memory_color_task5;
    expsetup.stim.esetup_memory_shape{tid} = expsetup.stim.memory_shape_task5;
    expsetup.stim.esetup_memory_pen_width(tid) = expsetup.stim.memory_pen_width_task5;
end

% Memory duration
expsetup.sim.esetup_memory_duration(tid) = expsetup.stim.memory_duration;

%% Response size

temp1=Shuffle(expsetup.stim.response_size);
expsetup.stim.esetup_target_size(tid,1:4) = [0, 0, temp1(1), temp1(1)];

temp1=Shuffle(expsetup.stim.response_saccade_accuracy);
expsetup.stim.esetup_target_size_eyetrack(tid,1:4) = [0, 0, temp1(1), temp1(1)];


%% Probe or no-probe trial

% Look, avoid
if expsetup.stim.esetup_block_cond(tid) == 1 || expsetup.stim.esetup_block_cond(tid) == 2
    
    %=========
    % Modified part
    ind0 = strcmp(expsetup.stim.training_stage_matrix, expsetup.stim.esetup_exp_version{tid});
    ind1 = find(ind0==1);
    ind0 = strcmp(expsetup.stim.training_stage_matrix, 'added probe trials');
    ind2 = find(ind0==1);
    if ind1>ind2
        temp1 = Shuffle(expsetup.stim.target_number); % Select 1 or 2 targets
    elseif ind1==ind2
        temp1 = Shuffle(expsetup.stim.target_number);
    elseif ind1<ind2
        temp1 = 2; % Before probe trials, it's two targets
    end
    %===========
    expsetup.stim.esetup_target_number(tid) = temp1(1);
    
elseif expsetup.stim.esetup_block_cond(tid) >= 3
    error('Target number not defined')
end

% SOA
temp1 = Shuffle(expsetup.stim.response_soa);
expsetup.stim.esetup_response_soa(tid) = temp1(1);


%% Stimuli positions

a = Shuffle(1:size(expsetup.stim.response_target_coord,1));
temp1 = expsetup.stim.response_target_coord(a,:);
expsetup.stim.esetup_memory_coord(tid,1:2) = temp1(1,1:2);

% Saccade target positions
st_mem = expsetup.stim.esetup_memory_coord(tid,:); % Memorized
st_nonmem = temp1(2,1:2); % Non-memorized

% Probe positions
a = Shuffle(1:size(expsetup.stim.response_t3_coord,1));
temp1 = expsetup.stim.response_t3_coord(a,:);
st3 = temp1(1,1:2);

% ST2 color, varies as a stage of training. For look/avoid task ST2 color
% level and step is the same.
%=========
if strcmp(expsetup.stim.esetup_exp_version{tid}, 'task switch luminance change') ||...
        strcmp(expsetup.stim.esetup_exp_version{tid}, 'look luminance change') ||...
        strcmp(expsetup.stim.esetup_exp_version{tid}, 'avoid luminance change')
    temp1 = Shuffle(tv1(1).temp_var_current);
    var_copy.esetup_st2_color_level = temp1(1); % Copy variable for error trials
else
    temp1 = Shuffle(expsetup.stim.st2_color_level);
end

% End of fixed part
%===========
expsetup.stim.esetup_st2_color_level(tid) = temp1(1);
    
    
% Initialize different colors and shapes, based on block_cond
if expsetup.stim.esetup_block_cond(tid,1) == 1 && expsetup.stim.esetup_target_number(tid,1) == 2
    
    expsetup.stim.esetup_st1_coord(tid,1:2) = st_mem;
    expsetup.stim.esetup_st2_coord(tid,1:2) = st_nonmem;
    expsetup.stim.esetup_st1_color(tid,1:3) = expsetup.stim.response_t1_color_task1;
    expsetup.stim.esetup_target_shape{tid} = expsetup.stim.response_shape_task1;
    
    % ST2 color level changes
    if strcmp(expsetup.stim.esetup_exp_version{tid}, 'task switch luminance change') ||...
            strcmp(expsetup.stim.esetup_exp_version{tid}, 'look luminance change') ||...
            strcmp(expsetup.stim.esetup_exp_version{tid}, 'avoid luminance change')
        % Calculate ST2 level
        c1 = expsetup.stim.response_t2_color_task1;
        d1 = expsetup.stim.esetup_background_color(tid,1:3) - c1;
        a1 = c1 + d1 * expsetup.stim.esetup_st2_color_level(tid);
        expsetup.stim.esetup_st2_color(tid,1:3) = a1;
        var_copy.esetup_st2_color = expsetup.stim.esetup_st2_color(tid,1:3); % Copy variable for error trials
    else
        c1 = expsetup.stim.response_t2_color_task1;
        expsetup.stim.esetup_st2_color(tid,1:3) = c1;
    end

elseif expsetup.stim.esetup_block_cond(tid,1) == 2 && expsetup.stim.esetup_target_number(tid,1) == 2
    
    expsetup.stim.esetup_st1_coord(tid,1:2) = st_nonmem;
    expsetup.stim.esetup_st2_coord(tid,1:2) = st_mem;
    expsetup.stim.esetup_st1_color(tid,1:3) = expsetup.stim.response_t2_color_task2;
    expsetup.stim.esetup_target_shape{tid} = expsetup.stim.response_shape_task2;
    
    % ST2 color level changes
    if strcmp(expsetup.stim.esetup_exp_version{tid}, 'task switch luminance change') ||...
            strcmp(expsetup.stim.esetup_exp_version{tid}, 'look luminance change') ||...
            strcmp(expsetup.stim.esetup_exp_version{tid}, 'avoid luminance change')
        % Calculate ST2 level
        c1 = expsetup.stim.response_t1_color_task2;
        d1 = expsetup.stim.esetup_background_color(tid,1:3) - c1;
        a1 = c1 + d1 * expsetup.stim.esetup_st2_color_level(tid);
        expsetup.stim.esetup_st2_color(tid,1:3) = a1;
        var_copy.esetup_st2_color = expsetup.stim.esetup_st2_color(tid,1:3); % Copy variable for error trials
    else
        c1 = expsetup.stim.response_t1_color_task1;
        expsetup.stim.esetup_st2_color(tid,1:3) = c1;
    end
    
elseif expsetup.stim.esetup_block_cond(tid,1) == 1 && expsetup.stim.esetup_target_number(tid,1) == 1
    expsetup.stim.esetup_st1_coord(tid,1:2) = st3;
    expsetup.stim.esetup_st2_coord(tid,1:2) = NaN;
    expsetup.stim.esetup_st1_color(tid,1:3) = expsetup.stim.response_t3_color_task1;
    expsetup.stim.esetup_st2_color(tid,1:3) = NaN;
    expsetup.stim.esetup_target_shape{tid} = expsetup.stim.response_t3_shape;
elseif expsetup.stim.esetup_block_cond(tid,1) == 2 && expsetup.stim.esetup_target_number(tid,1) == 1
    expsetup.stim.esetup_st1_coord(tid,1:2) = st3;
    expsetup.stim.esetup_st2_coord(tid,1:2) = NaN;
    expsetup.stim.esetup_st1_color(tid,1:3) = expsetup.stim.response_t3_color_task2;
    expsetup.stim.esetup_st2_color(tid,1:3) = NaN;
    expsetup.stim.esetup_target_shape{tid} = expsetup.stim.response_t3_shape;
end
expsetup.stim.esetup_target_pen_width(tid,1) = expsetup.stim.response_pen_width;

%% Distractor

% Distractor position

%============
% Modified part
ind0 = strcmp(expsetup.stim.training_stage_matrix, expsetup.stim.esetup_exp_version{tid});
ind1 = find(ind0==1);
ind0 = strcmp(expsetup.stim.training_stage_matrix, 'distractor train position');
ind2 = find(ind0==1);
if ind1>ind2
    a = Shuffle(1:size(expsetup.stim.distractor_coord,1));
    temp1 = expsetup.stim.distractor_coord(a,:);
    expsetup.stim.esetup_distractor_coord(tid,1:2) = temp1(1,1:2);
elseif ind1==ind2
    temp1 = Shuffle(tv1(1).temp_var_current);
    var_copy.esetup_distractor_coord(1,1:2) = [temp1(1),0]; % Copy variable for error trials
    var_copy.esetup_distractor_coord_x(1,1) = temp1(1); % Copy variable for error trials
    expsetup.stim.esetup_distractor_coord(tid,1:2) = [temp1(1),0];
    expsetup.stim.esetup_distractor_coord_x(tid,1) = temp1(1);
elseif ind1<ind2
    temp1 = Shuffle(expsetup.stim.distractor_coord_x_ini);
    expsetup.stim.esetup_distractor_coord(tid,1:2) = [temp1(1),0];
    expsetup.stim.esetup_distractor_coord_x(tid,1) = temp1(1);
end
%=============


% Distractor probability
if strcmp(expsetup.stim.esetup_exp_version{tid}, 'distractor train luminance') || ...
        strcmp(expsetup.stim.esetup_exp_version{tid}, 'distractor train position')
    b = round(expsetup.stim.distractor_probability_ini * 100); % Distractor probability during training
    a = [];
    a (1:b) = 1; % Probabilty of event = 1
    if b < 100
        a(b+1 : 1 : 100) = 0; % Probability of event == 0
    end
    temp1 = Shuffle(a);
elseif  strcmp(expsetup.stim.esetup_exp_version{tid}, 'distractor on')
    b = round(expsetup.stim.distractor_probability * 100); % Distractor probability after training
    a = [];
    a (1:b) = 1; % Probabilty of event = 1
    if b < 100
        a(b+1 : 1 : 100) = 0; % Probability of event == 0
    end
    temp1 = Shuffle(a);
else
    temp1 = 0; % No distractor
end
expsetup.stim.esetup_distractor_probability(tid) = temp1(1);


% Distractor color level
%============
% Fixed part
ind0 = strcmp(expsetup.stim.training_stage_matrix, expsetup.stim.esetup_exp_version{tid});
ind1 = find(ind0==1);
ind0 = strcmp(expsetup.stim.training_stage_matrix, 'distractor train luminance');
ind2 = find(ind0==1);
if ind1>ind2
    temp1 = Shuffle(expsetup.stim.distractor_color_level);
elseif ind1==ind2
    temp1 = Shuffle(tv1(1).temp_var_current);
    var_copy.esetup_distractor_color_level = temp1(1); % Copy variable for error trials
elseif ind1<ind2
    temp1 = Shuffle(expsetup.stim.distractor_color_level);
end
%=============
expsetup.stim.esetup_distractor_color_level(tid,1) = temp1(1);


% Distractor color level changes
if strcmp(expsetup.stim.esetup_exp_version{tid}, 'distractor train luminance')
    % Calculate distractor level
    c1 = expsetup.stim.distractor_color;
    d1 = expsetup.stim.esetup_background_color(tid,1:3) - c1;
    a1 = c1 + d1 * expsetup.stim.esetup_distractor_color_level(tid);
    expsetup.stim.esetup_distractor_color(tid,1:3) = a1;
    var_copy.esetup_distractor_color = expsetup.stim.esetup_distractor_color(tid,1:3); % Copy variable for error trials
else
    c1 = expsetup.stim.distractor_color;
    expsetup.stim.esetup_distractor_color(tid,1:3) = c1;
end

% Distractor duration
temp1 = Shuffle(expsetup.stim.distractor_duration);
expsetup.stim.esetup_distractor_duration(tid) = temp1(1);

% Distractor onset time
temp1 = Shuffle(expsetup.stim.distractor_on_time);
expsetup.stim.esetup_distractor_on_time(tid) = temp1(1);

%%  Memory delay duration

temp1 = Shuffle(expsetup.stim.memory_duration);
expsetup.stim.esetup_memory_duration(tid) = temp1(1);

% Memory delay duration
if expsetup.stim.esetup_target_number(tid,1)==2 % Two target trials
   
    % Memory duration, varies as a stage of training
    %=========
    ind0 = strcmp(expsetup.stim.training_stage_matrix, expsetup.stim.esetup_exp_version{tid});
    ind1 = find(ind0==1);
    ind0 = strcmp(expsetup.stim.training_stage_matrix, 'delay increase');
    ind2 = find(ind0==1);
    if ind1>ind2
        temp1 = Shuffle(expsetup.stim.memory_delay_duration);
    elseif ind1==ind2
        temp1 = Shuffle(tv1(2).temp_var_current);
        var_copy.esetup_memory_delay = temp1(1); % Copy variable for error trials
    elseif ind1<ind2
        temp1 = Shuffle(expsetup.stim.memory_delay_duration_ini);
    end
    %===========
    
elseif expsetup.stim.esetup_target_number(tid,1)==1 % Single target trials
    
    % Memory duration, varies as a stage of training
    %=========
    ind0 = strcmp(expsetup.stim.training_stage_matrix, expsetup.stim.esetup_exp_version{tid});
    ind1 = find(ind0==1);
    ind0 = strcmp(expsetup.stim.training_stage_matrix, 'delay increase');
    ind2 = find(ind0==1);
    if ind1>ind2
        temp1 = Shuffle(expsetup.stim.memory_delay_duration_probe);
    elseif ind1==ind2
        temp1 = Shuffle(tv1(2).temp_var_current);
        var_copy.esetup_memory_delay = temp1(1); % Copy variable for error trials
    elseif ind1<ind2
        temp1 = Shuffle(expsetup.stim.memory_delay_duration_ini);
    end
    %===========
    
end
expsetup.stim.esetup_memory_delay(tid) = temp1(1);


% If memory probe is shown, add it to the fixation maintenance duration
expsetup.stim.esetup_total_fixation_duration(tid) = ...
    expsetup.stim.esetup_fixation_maintain_duration(tid) + ...
    expsetup.sim.esetup_memory_duration(tid) + ...
    expsetup.stim.esetup_memory_delay(tid);



%% Texture

% Is texture on
temp1 = Shuffle(expsetup.stim.background_texture_on);
expsetup.stim.esetup_background_texture_on(tid) = temp1(1);

% Angle of the texture
temp1 = Shuffle(expsetup.stim.background_texture_line_angle);
expsetup.stim.esetup_background_texture_line_angle(tid) = temp1(1);

% Number of lines
temp1 = Shuffle(expsetup.stim.background_texture_line_number);
expsetup.stim.esetup_background_texture_line_number(tid) = temp1(1);

% Line length
temp1 = Shuffle(expsetup.stim.background_texture_line_length);
expsetup.stim.esetup_background_texture_line_length(tid) = temp1(1);


%% If previous trial was an error, then copy settings of the previous trial

if tid>1
    if expsetup.stim.trial_error_repeat == 1 % Repeat error trial immediately
        if  ~strcmp(expsetup.stim.edata_error_code{tid-1}, 'correct')
            f1 = fieldnames(expsetup.stim);
            ind = strncmp(f1,'esetup', 6);
            for i=1:numel(ind)
                if ind(i)==1
                    if ~iscell(expsetup.stim.(f1{i}))
                        [m,n,o]=size(expsetup.stim.(f1{i}));
                        expsetup.stim.(f1{i})(tid,1:n,1:o) = expsetup.stim.(f1{i})(tid-1,1:n,1:o);
                    elseif iscell(expsetup.stim.(f1{i}))
                        expsetup.stim.(f1{i}){tid} = expsetup.stim.(f1{i}){tid-1};
                    end
                end
            end
        end
    end
end

%% Training protocol update
% If previous trial was an error, some stimulus properties are not copied
% (very important, else task will not get easier)

if tid>1
    if expsetup.stim.trial_error_repeat == 1 % Repeat error trial immediately
        if  ~strcmp(expsetup.stim.edata_error_code{tid-1}, 'correct')
            if ~isempty(fieldnames(var_copy))
                f1 = fieldnames(var_copy);
                for i=1:numel(f1)
                    if ~iscell(expsetup.stim.(f1{i}))
                        [m,n,o]=size(var_copy.(f1{i}));
                        expsetup.stim.(f1{i})(tid,1:n,1:o) = var_copy.(f1{i})(1:m,1:n,1:o);
                    elseif iscell(expsetup.stim.(f1{i}))
                        expsetup.stim.(f1{i}){tid} = var_copy.(f1{i});
                    end
                end
            end
        end
    end
end

