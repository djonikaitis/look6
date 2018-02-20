%% Specify conditions to be modified

% fix eframes_fixation_offset & edata_fixation_off
overwrite_temp_index{1} = 20170801:20171028;

% Fix exp matrix size mismatch for HB on 12.21.2017 (remove trial no 601, as this trial does not exist)
overwrite_temp_index{2} = 20171221;

% Convert look5 files into look6 format
overwrite_temp_index{3} = 20160101:20171231;

%% Fixation offset time bug

if settings.overwrite_temp_switch == 1 && settings.date_current >= overwrite_temp_index{1}(1) && settings.date_current <= overwrite_temp_index{1}(end)
    if strcmp(var1.general.expname, 'look6')

        v1 = 'eframes_fixation_offset';
        v2 = 'eframes_fixation_off';

        if isfield(var1.stim, v1) % check whether to do analysis

            %===========
            % edata_fixation_off';
            %===========

            fprintf('Correcting field: %s\n', v2)

            clear temp1_old; clear temp1_new
            temp_old = var1.stim.(v1);
            temp_new = var1.stim.(v2);

            for i=1:numel(temp_old)
                ind = find(temp_old{i}==1);
                if numel(ind)>=1
                    temp_new{i}(ind(1))=1;
                end
            end

            % Save corrected data
            var1.stim.(v2) = temp_new;

            % Remove old field
            var1.stim = rmfield(var1.stim, v1);

            %===========
            % edata_fixation_off';
            %===========

            v1 = 'edata_fixation_off';
            v2 = 'edata_st1_on';
            fprintf('Correcting field: %s\n', v1)

            clear temp1_old; clear temp1_new;
            temp_old = var1.stim.(v1);
            temp_new = var1.stim.(v2);

            % If ST1 appeared, that means fixation disappeared simultaneously
            % with it. If ST1 didnt appear, then fixation_off time is end of
            % the trial loop.
            ind = ~isnan(temp_new);
            temp_old(ind) = temp_new(ind);

            % Save corrected data
            var1.stim.(v1) = temp_old;

        else
            fprintf('Field %s already corrected, no changes written\n', v2)
        end
    end
end

%% Fix exp matrix size mismatch for HB on 12.21.2017 (remove trial no 601, as this trial does not exist)

if settings.overwrite_temp_switch == 1 && settings.date_current >= overwrite_temp_index{2}(1) && settings.date_current <= overwrite_temp_index{2}(end)
    if strcmp(var1.general.expname, 'look6') && strcmp(var1.general.subject_id, 'hb')

        f1 = fieldnames(var1.stim);
        for i = 1:numel(f1)
            [m,n] = size(var1.stim.(f1{i}));

            if m==601

                fprintf('Reducing the size of the field: %s\n', f1{i})

                % Remove extra cell or row
                if iscell(var1.stim.(f1{i}))
                    var1.stim.(f1{i})(m)=[];
                else
                    var1.stim.(f1{i})(m,:)=[];
                end
            end
        end

    end
end

%% Over-write settings file from look5


if settings.overwrite_temp_switch == 1 && settings.date_current >= overwrite_temp_index{3}(1) && settings.date_current <= overwrite_temp_index{3}(end)
    if strcmp(var1.general.expname, 'look5')
        
        
        % Initialize an empty variable
        fprintf('Early exp version detected: look5, initialize new data structure\n');
        var0 = var1.stim;
        
        % For easy copying later
        cond_text = cell(5,1);
        cond_text{1} = 'look';
        cond_text{2} = 'avoid';
        cond_text{3} = 'control irrelevant cue';
        cond_text{4} = 'control no cue';
        cond_text{5} = 'control fixate';
        
        % For easy copying later
        cond_text_long = cell(5,1);
        cond_text_long{1} = 'look';
        cond_text_long{2} = 'avoid';
        cond_text_long{3} = 'control_irrelevant_cue';
        cond_text_long{4} = 'control_no_cue';
        cond_text_long{5} = 'control_fixate';
        
        fprintf('First will modify all single-shot settings\n');
        
        %% A bunch of initial settings
        
        % training_stage_matrix is undefined at this stage
        if ~isfield (var0, 'training_stage_matrix')
            var0.training_stage_matrix = {'undefined'};
        end
        
        % Probe extended map
        if ~isfield (var0, 'exp_version') && isfield (var0, 'training_stage')
            var0.exp_version = var0.training_stage;
            var0 = rmfield(var0, 'training_stage');
        end
        
        % probe_extended_map
        if isfield (var0, 'exp_version')
            if var1.general.record_plexon==1
                var0.probe_extended_map = 0; % Recording
            else
                var0.probe_extended_map = -1; % Psychophysics
            end
            var0 = rmfield(var0, 'exp_version');
        else
            var0.probe_extended_map = -1; % Unknown
        end
        
        % probe_spacing_arc
        if ~isfield (var0, 'probe_spacing_arc') && isfield (var0, 'target_spacing_arc')
            var0.probe_spacing_arc = var0.target_spacing_arc;
            var0 = rmfield(var0, 'target_spacing_arc');
        end
        
        % main_cond
        if ~isfield (var0, 'main_cond') && isfield (var0, 'maincond')
            
            a = numel(var0.maincond);
            b = cell(a, 1);
            ind = var0.maincond==1;
            b(ind)=cond_text(1);
            ind = var0.maincond==2;
            b(ind)=cond_text(2);
            ind = var0.maincond==3;
            b(ind)=cond_text(3);
            ind = var0.maincond==4;
            b(ind)=cond_text(4);
            ind = var0.maincond==5;
            b(ind)=cond_text(5);
            
            var0.main_cond = b;
            var0 = rmfield(var0, 'maincond');
        end
        
        %% Fixation settings
        
        % Fixation arc
        if ~isfield (var0, 'fixation_arc')
            var0.fixation_arc = var0.fixation_position;
            var0 = rmfield(var0, 'fixation_position');
        end
        
        % fixation_size
        if numel(var0.fixation_size)>1
            var0.fixation_size = var0.fixation_size(end);
        end
        
        % fixation_pen
        if ~isfield (var0, 'fixation_pen')
            var0.fixation_pen = var0.ring_pen;
        end
        
        % Color and shape
        for i = 1:numel(cond_text_long)
            
            % fixation_color_
            a = ['fixation_color_task', num2str(i)];
            b = ['fixation_color_', cond_text_long{i}];
            if isfield(var0, a)
                var0.(b) = var0.(a);
                var0 = rmfield(var0, a);
            end
            
            % fixation_shape_
            a = ['fixation_shape_task', num2str(i)];
            b = ['fixation_shape_', cond_text_long{i}];
            if isfield(var0, a)
                var0.(b) = var0.(a);
                var0 = rmfield(var0, a);
            end
            
        end
        
        % fixation_size_drift
        if ~isfield (var0, 'fixation_size_drift')
            var0.fixation_size_drift = var0.fixation_accuracy_drift;
            var0 = rmfield(var0, 'fixation_accuracy_drift');
        end
        
        % fixation_size_eyetrack
        if ~isfield (var0, 'fixation_size_eyetrack')
            var0.fixation_size_eyetrack = var0.fixation_accuracy;
            var0 = rmfield(var0, 'fixation_accuracy');
        end
        
        %% Memory settings
        
        % memory_size
        if numel(var0.memory_size)>1
            var0.memory_size = var0.memory_size(end);
        end
        
        % Color and shape
        for i = 1:numel(cond_text_long)
            
            % memory_color_
            a = ['memory_color_task', num2str(i)];
            b = ['memory_color_', cond_text_long{i}];
            c = 'memory_color';
            if isfield(var0, a)
                var0.(b) = var0.(a);
                var0 = rmfield(var0, a);
            end
            if ~isfield(var0, a) && isfield (var0, c)
                var0.(b) = var0.(c);
            end
            
            % memory_shape_
            a = ['memory_shape_task', num2str(i)];
            b = ['memory_shape_', cond_text_long{i}];
            c = 'memory_shape';
            if isfield(var0, a)
                var0.(b) = var0.(a);
                var0 = rmfield(var0, a);
            end
            if ~isfield(var0, a) && isfield (var0, c)
                var0.(b) = var0.(c);
            end
            
            % memory_pen_
            a = ['memory_pen_width_task', num2str(i)];
            b = ['memory_pen_width_', cond_text_long{i}];
            c = 'memory_pen_width';
            if isfield(var0, a)
                var0.(b) = var0.(a);
                var0 = rmfield(var0, a);
            end
            if ~isfield(var0, a) && isfield (var0, c)
                var0.(b) = var0.(c);
            end
            
        end
        
        %% Response targets
        
        % response_size
        if numel(var0.response_size)>1
            var0.response_size = var0.response_size(end);
        end
        
        % st2_color_level
        if ~isfield (var0, 'st2_color_level')
            var0.st2_color_level = 0;
        end
        
        % response color and shape
        for i = 1:numel(cond_text_long)
            
            % response_t1_color
            a = ['response_t1_color_task', num2str(i)];
            b = ['response_t1_color_', cond_text_long{i}];
            if isfield(var0, a)
                var0.(b) = var0.(a);
                var0 = rmfield(var0, a);
            end
            
            % response_t2_color
            a = ['response_t2_color_task', num2str(i)];
            b = ['response_t2_color_', cond_text_long{i}];
            if isfield(var0, a)
                var0.(b) = var0.(a);
                var0 = rmfield(var0, a);
            end
            
            % response_shape_
            a = ['response_shape_task', num2str(i)];
            b = ['response_shape_', cond_text_long{i}];
            if isfield(var0, a)
                var0.(b) = var0.(a);
                var0 = rmfield(var0, a);
            end
            
            % response_t3_color
            a = ['response_t3_color_task', num2str(i)];
            b = ['response_t3_color_', cond_text_long{i}];
            if isfield(var0, a)
                var0.(b) = var0.(a);
                var0 = rmfield(var0, a);
            end
            
        end
        
        % response_t3_color_control_fixate value not saved, copy it from look task
        if ~isfield (var0, 'response_t3_color_control_fixate')
            a = 'response_t3_color_look';
            b = 'response_t3_color_control_fixate';
            var0.(b) = var0.(a);
        end
        
        % response_soa
        a = 'response_distractor_soa';
        b = 'response_soa';
        if isfield(var0, a)
            var0.(b) = var0.(a);
            var0 = rmfield(var0, a);
        end
        
        %% Background
        
        % background color and shape
        for i = 1:numel(cond_text_long)
            
            % background_color_
            a = ['background_color_task', num2str(i)];
            b = ['background_color_', cond_text_long{i}];
            if isfield(var0, a)
                var0.(b) = var0.(a);
                var0 = rmfield(var0, a);
            end
            
        end
        
        % background_textures_per_trial
        if ~isfield (var0, 'background_textures_per_trial')
            var0.background_textures_per_trial = 1;
        end
        
        %% Other settings
        
        % trial_abort_counter
        a = 'trial_error_counter';
        b = 'trial_abort_counter';
        if isfield(var0, a)
            var0.(b) = var0.(a);
            var0 = rmfield(var0, a);
        end
        
        %% Remove some unnecessary settings
        
        a = 'fixation_color';
        if isfield(var0, a)
            var0 = rmfield(var0, a);
        end
        
        a = 'fixation_shape';
        if isfield(var0, a)
            var0 = rmfield(var0, a);
        end
        
        a = 'background_color';
        if isfield(var0, a)
            var0 = rmfield(var0, a);
        end
        
        a = 'response_t3_color';
        if isfield(var0, a)
            var0 = rmfield(var0, a);
        end
        
        a = 'memory_color';
        if isfield(var0, a)
            var0 = rmfield(var0, a);
        end
        
        a = 'memory_shape';
        if isfield(var0, a)
            var0 = rmfield(var0, a);
        end
        
        a = 'memory_pen_width';
        if isfield(var0, a)
            var0 = rmfield(var0, a);
        end
        
        %% Restructure expsetup matrix
        
        fprintf('Splitting exp_setup and exp_data matrices into variables\n')
        
        % Setup column names in expmatrix
        em_name = cell(1,100);  % Initialize empty matrix for var names
        
        em_name{1} = 'esetup_fixation_acquire_duration';
        em_name{2} = 'esetup_fixation_maintain_duration';
        em_name{3} = 'esetup_fixation_arc';
        em_name{4} = 'esetup_fixation_radius';
        em_name{5} = 'em_fixation_size_eyetrack';
        em_name{7} = 'em_memory_coord_x';
        em_name{8} = 'em_memory_coord_y';
        em_name{9} = 'em_t1_coord1';
        em_name{10} = 'em_t1_coord2';
        em_name{11} = 'em_t2_coord1';
        em_name{12} = 'em_t2_coord2';
        em_name{13} = 'em_t3_coord1';
        em_name{14} = 'em_t3_coord2';
        em_name{15} = 'em_eye_window';
        em_name{18} = 'esetup_target_number';
        em_name{19} = 'em_probe_trial';
        em_name{20} = 'em_distractor_soa';
        em_name{21} = 'esetup_memory_duration';
        em_name{22} = 'esetup_memory_delay';
        em_name{23} = []; % 'em_reward_size_ms'; % removed
        em_name{24} = []; % 'em_reward_size_ml'; % removed
        em_name{25} = 'esetup_total_fixation_duration';
        em_name{26} = 'esetup_background_texture_on';
        em_name{27} = 'esetup_background_texture_line_angle';
        em_name{30} = 'esetup_block_no';
        em_name{31} = 'em_block_cond';
        em_name{32} = 'em_data_reject_1'; % duplicated 32 and 61
        em_name{35} = 'edata_first_display';
        em_name{36} = []; % 'em_data_last_display'; % removed
        em_name{37} = 'edata_fixation_on';
        em_name{38} = 'edata_fixation_off';
        em_name{39} = 'em_st1_on_1'; % duplicated 39 and 43
        em_name{40} = 'edata_fixation_acquired';
        em_name{41} = 'edata_fixation_drift_maintained';
        em_name{42} = 'edata_fixation_maintained';
        em_name{43} = 'em_st1_on_2'; % duplicated 39 and 43
        em_name{44} = 'edata_response_acquired';
        em_name{45} = 'edata_response_maintained';
        em_name{46} = 'edata_st1_off';
        em_name{47} = 'edata_st2_on';
        em_name{48} = 'edata_memory_on';
        em_name{49} = 'edata_memory_off';
        em_name{50} = 'edata_st2_off';
        em_name{51} = 'edata_background_texture_onset_time';
        em_name{52} = []; %'em_data_button_press'; % removed
        em_name{53} = 'edata_fixation_color_change';
        em_name{61} = 'em_data_reject_2'; % Duplicated 32 and 61
        em_name{62} = 'em_data_drift_x1';
        em_name{63} = 'em_data_drift_y1';
        em_name{64} = []; % 'em_data_error_counter'; % removed
        em_name{65} = 'edata_reward_size_ms';
        em_name{66} = 'edata_reward_size_ml';
        em_name{67} = 'edata_reward_on';
        em_name{68} = 'edata_reward_image_on';
        
        
        % Calculate how many trials are there
        a = numel (var0.trialmatrix);
        b = numel (var0.refresh_rate_mat);
        if a==b
            ind = 1:a;
            % Restructure the matrices
            for i=1:numel(em_name)
                if ~isempty(em_name{i})
                    var0.(em_name{i}) = var0.expmatrix(ind,i);
                end
            end
        else
            error ('Non-matching trial counts for "trialmatrix" and "refresh_rate_mat" - figure out whats wrong')
        end
        
        % Clear out expmatrix field
        var0 = rmfield(var0, 'expmatrix');
        
        
        %% Change exp_cond variable
        
        % esetup_block_cond
        if isfield(var0, 'em_block_cond')
            
            fprintf('Renaming conditions of the esetup_block_cond varialbe\n')
            a = numel (var0.trialmatrix);
            b = cell(a,1);
            
            for i = 1:numel(cond_text)
                ind = var0.em_block_cond==i;
                b(ind)={cond_text{i}};
            end
            var0.esetup_block_cond = b;
            var0 = rmfield(var0, 'em_block_cond');
            
        end
        
        % esetup_exp_version
        % Use undefined version given that it's unknown whether task switch
        % was done or not
        if ~isfield(var0, 'esetup_exp_version')
            a = numel (var0.trialmatrix);
            b = cell(a,1);
            for i = 1:numel(b)
                b(i)={var0.training_stage_matrix{1}};
            end
            var0.esetup_exp_version = b;
        end
        
        
        %% Fixation esetup
        
        %===================
        % esetup_fixation_color
        c = 'esetup_fixation_color';
        if ~isfield(var0, 'c')
            
            a = numel (var0.trialmatrix); % Create matrix
            mat1 = NaN(a,3);
            
            for i = 1:numel(cond_text)
                
                a = cond_text{i}; % index
                ind = strcmp(var0.esetup_block_cond, a);
                ind = find(ind==1);
                
                a = ['fixation_color_', cond_text_long{i}]; % replace values
                if sum(ind)>0 && isfield(var0, a)
                    for j=1:numel(ind)
                        mat1(ind(j),1:3) = var0.(a);
                    end
                end
            end
            
            var0.(c) = mat1;
        end
        
        %======================
        % esetup_fixation_shape
        c = 'esetup_fixation_shape';
        if ~isfield(var0, 'c')
            
            a = numel (var0.trialmatrix); % Create matrix
            mat1 = cell(a,1);
            
            for i = 1:numel(cond_text)
                
                a = cond_text{i}; % index
                ind = strcmp(var0.esetup_block_cond, a);
                ind = find(ind==1);
                
                a = ['fixation_shape_', cond_text_long{i}]; % replace values
                if sum(ind)>0 && isfield(var0, a)
                    for j=1:numel(ind)
                        mat1{ind(j)} = var0.(a);
                    end
                end
            end
            
            var0.(c) = mat1;
        end
        
        % esetup_fixation_size
        if ~isfield(var0, 'esetup_fixation_size')
            a = zeros(numel(var0.trialmatrix), 1);
            b = ones(numel(var0.trialmatrix), 1) * var0.fixation_size;
            var0.esetup_fixation_size = [a a, b, b];
        end
        
        % esetup_fixation_size_eyetrack
        if ~isfield(var0, 'esetup_fixation_size_eyetrack')
            a = zeros(numel(var0.trialmatrix), 1);
            b = var0.em_fixation_size_eyetrack;
            var0.esetup_fixation_size_eyetrack = [a a, b, b];
            var0 = rmfield(var0, 'em_fixation_size_eyetrack');
        end
        
        % esetup_fixation_size_drift
        if ~isfield(var0, 'esetup_fixation_size_drift')
            a = zeros(numel(var0.trialmatrix), 1);
            b = ones(numel(var0.trialmatrix), 1) * var0.fixation_size_drift;
            var0.esetup_fixation_size_drift = [a a, b, b];
        end
        
        % esetup_fixation_drift_correction_on
        if ~isfield(var0, 'esetup_fixation_drift_correction_on')
            a = ones(numel(var0.trialmatrix), 1);
            b =  a * var0.fixation_drift_correction_on;
            var0.esetup_fixation_drift_correction_on = b;
        end
        
        % esetup_fixation_drift_offset
        if ~isfield(var0, 'esetup_fixation_drift_offset')
            var0.esetup_fixation_drift_offset = [var0.em_data_drift_x1, var0.em_data_drift_y1];
            var0 = rmfield(var0, 'em_data_drift_x1');
            var0 = rmfield(var0, 'em_data_drift_y1');
        end
        
        %% Memory esetup
        
        % esetup_memory_coord
        if ~isfield(var0, 'esetup_memory_coord')
            var0.esetup_memory_coord = [var0.em_memory_coord_x, var0.em_memory_coord_y];
            var0 = rmfield(var0, 'em_memory_coord_x');
            var0 = rmfield(var0, 'em_memory_coord_y');
        end
        
        % esetup_memory_size
        if ~isfield(var0, 'esetup_memory_size')
            a = zeros(numel(var0.trialmatrix), 1);
            b = ones(numel(var0.trialmatrix), 1) * var0.memory_size;
            var0.esetup_memory_size = [a a, b, b];
        end
        
        %===================
        % esetup_memory_color
        c = 'esetup_memory_color';
        if ~isfield(var0, 'c')
            
            a = numel (var0.trialmatrix); % Create matrix
            mat1 = NaN(a,3);
            
            for i = 1:numel(cond_text)
                
                a = cond_text{i}; % index
                ind = strcmp(var0.esetup_block_cond, a);
                ind = find(ind==1);
                
                a = ['memory_color_', cond_text_long{i}]; % replace values
                if sum(ind)>0 && isfield(var0, a)
                    for j=1:numel(ind)
                        mat1(ind(j),1:3) = var0.(a);
                    end
                end
            end
            
            var0.(c) = mat1;
        end
        
        %======================
        % esetup_memory_shape
        c = 'esetup_memory_shape';
        if ~isfield(var0, 'c')
            
            a = numel (var0.trialmatrix); % Create matrix
            mat1 = cell(a,1);
            
            for i = 1:numel(cond_text)
                
                a = cond_text{i}; % index
                ind = strcmp(var0.esetup_block_cond, a);
                ind = find(ind==1);
                
                a = ['memory_shape_', cond_text_long{i}]; % replace values
                if sum(ind)>0 && isfield(var0, a)
                    for j=1:numel(ind)
                        mat1{ind(j)} = var0.(a);
                    end
                end
            end
            
            var0.(c) = mat1;
        end
        
        %===================
        % esetup_memory_pen_width
        c = 'esetup_memory_pen_width';
        if ~isfield(var0, 'c')
            
            a = numel (var0.trialmatrix); % Create matrix
            mat1 = NaN(a,1);
            
            for i = 1:numel(cond_text)
                
                a = cond_text{i}; % index
                ind = strcmp(var0.esetup_block_cond, a);
                ind = find(ind==1);
                
                a = ['memory_pen_width_', cond_text_long{i}]; % replace values
                if sum(ind)>0 && isfield(var0, a)
                    for j=1:numel(ind)
                        mat1(ind(j),1) = var0.(a);
                    end
                end
            end
            
            var0.(c) = mat1;
        end
        
        %% Saccade targets esetup
        
        
        %=====================
        % saccade target
        if ~isfield(var0, 'esetup_st1_coord')
            a = numel (var0.trialmatrix);
            var0.esetup_st1_coord = NaN(a,2);
            var0.esetup_st2_coord = NaN(a,2);
            var0.esetup_st1_color = NaN(a,3);
            var0.esetup_st2_color = NaN(a,3);
            var0.esetup_target_shape = cell(a,1);
            var0.esetup_target_pen_width = NaN(a,1);
        end
        
        % Look task, 2 targets
        if sum(isnan(var0.em_probe_trial)) ~= numel(var0.em_probe_trial)
            ind = strcmp(var0.esetup_block_cond, 'look') & var0.esetup_target_number==2 & var0.em_probe_trial==0;
        else
            ind = strcmp(var0.esetup_block_cond, 'look') & var0.esetup_target_number==2;
        end
        if sum(ind)>0
            var0.esetup_st1_coord(ind,1:2) = [var0.em_t1_coord1(ind,:), var0.em_t1_coord2(ind,:)];
            var0.esetup_st2_coord(ind,1:2) = [var0.em_t2_coord1(ind,:), var0.em_t2_coord2(ind,:)];
            var0.esetup_st1_color(ind,1:3) = repmat(var0.response_t1_color_look, sum(ind), 1);
            var0.esetup_st2_color(ind,1:3) = repmat(var0.response_t2_color_look, sum(ind), 1);
            var0.esetup_target_shape(ind) = {var0.response_shape_look};
            var0.esetup_target_pen_width(ind,1) = var0.response_pen_width;
        end
        
        % Look task, 1 target
        if sum(isnan(var0.em_probe_trial)) ~= numel(var0.em_probe_trial)
            ind = strcmp(var0.esetup_block_cond, 'look') & var0.esetup_target_number==1 & var0.em_probe_trial==0;
        else
            ind = strcmp(var0.esetup_block_cond, 'look') & var0.esetup_target_number==1;
        end
        if sum(ind)>0
            var0.esetup_st1_coord(ind,1:2) = [var0.em_t1_coord1(ind,:), var0.em_t1_coord2(ind,:)];
            var0.esetup_st1_color(ind,1:3) = repmat(var0.response_t1_color_look, sum(ind), 1);
            var0.esetup_target_shape(ind) = {var0.response_shape_look};
            var0.esetup_target_pen_width(ind,1) = var0.response_pen_width;
        end
        
        % Look task, probe
        if sum(isnan(var0.em_probe_trial)) ~= numel(var0.em_probe_trial)
            ind = strcmp(var0.esetup_block_cond, 'look') & var0.esetup_target_number==1 & var0.em_probe_trial==1;
        else
            ind = strcmp(var0.esetup_block_cond, 'look') & var0.esetup_target_number==1;
        end
        if sum(ind)>0
            var0.esetup_st1_coord(ind,1:2) = [var0.em_t3_coord1(ind,:), var0.em_t3_coord2(ind,:)];
            var0.esetup_st1_color(ind,1:3) = repmat(var0.response_t3_color_look, sum(ind), 1);
            var0.esetup_target_shape(ind) = {var0.response_t3_shape};
            var0.esetup_target_pen_width(ind,1) = var0.response_pen_width;
        end
        
        % Avoid task, 2 targets
        if sum(isnan(var0.em_probe_trial)) ~= numel(var0.em_probe_trial)
            ind = strcmp(var0.esetup_block_cond, 'avoid') & var0.esetup_target_number==2 & var0.em_probe_trial==0;
        else
            ind = strcmp(var0.esetup_block_cond, 'avoid') & var0.esetup_target_number==2;
        end
        if sum(ind)>0
            var0.esetup_st1_coord(ind,1:2) = [var0.em_t2_coord1(ind,:), var0.em_t2_coord2(ind,:)];
            var0.esetup_st2_coord(ind,1:2) = [var0.em_t1_coord1(ind,:), var0.em_t1_coord2(ind,:)];
            var0.esetup_st1_color(ind,1:3) = repmat(var0.response_t2_color_avoid, sum(ind), 1);
            var0.esetup_st2_color(ind,1:3) = repmat(var0.response_t1_color_avoid, sum(ind), 1);
            var0.esetup_target_shape(ind) = {var0.response_shape_avoid};
            var0.esetup_target_pen_width(ind,1) = var0.response_pen_width;
        end
        
        % Avoid task, 1 target
        if sum(isnan(var0.em_probe_trial)) ~= numel(var0.em_probe_trial)
            ind = strcmp(var0.esetup_block_cond, 'avoid') & var0.esetup_target_number==1 & var0.em_probe_trial==0;
        else
            ind = strcmp(var0.esetup_block_cond, 'avoid') & var0.esetup_target_number==1;
        end
        if sum(ind)>0
            var0.esetup_st1_coord(ind,1:2) = [var0.em_t2_coord1(ind,:), var0.em_t2_coord2(ind,:)];
            var0.esetup_st1_color(ind,1:3) = repmat(var0.response_t2_color_avoid, sum(ind), 1);
            var0.esetup_target_shape(ind) = {var0.response_shape_avoid};
            var0.esetup_target_pen_width(ind,1) = var0.response_pen_width;
        end
        
        % Avoid task, probe
        if sum(isnan(var0.em_probe_trial)) ~= numel(var0.em_probe_trial)
            ind = strcmp(var0.esetup_block_cond, 'avoid') & var0.esetup_target_number==1 & var0.em_probe_trial==1;
        else
            ind = strcmp(var0.esetup_block_cond, 'avoid') & var0.esetup_target_number==1;
        end
        if sum(ind)>0
            var0.esetup_st1_coord(ind,1:2) = [var0.em_t3_coord1(ind,:), var0.em_t3_coord2(ind,:)];
            var0.esetup_st1_color(ind,1:3) = repmat(var0.response_t3_color_avoid, sum(ind), 1);
            var0.esetup_target_shape(ind) = {var0.response_t3_shape};
            var0.esetup_target_pen_width(ind,1) = var0.response_pen_width;
        end
        
        
        % Task 3, 1 target
        apd_long = cond_text_long{3};
        apd_short = cond_text{3};
        
        if sum(isnan(var0.em_probe_trial)) ~= numel(var0.em_probe_trial)
            ind = strcmp(var0.esetup_block_cond, apd_short) & var0.esetup_target_number==1 & var0.em_probe_trial==0;
        else
            ind = strcmp(var0.esetup_block_cond, apd_short) & var0.esetup_target_number==1;
        end
        if sum(ind)>0
            var0.esetup_st1_coord(ind,1:2) = [var0.em_t3_coord1(ind,:), var0.em_t3_coord2(ind,:)];
            f1 = ['response_t1_color_', apd_long];
            var0.esetup_st1_color(ind,1:3) = repmat(var0.(f1), sum(ind), 1);
            f1 = ['response_shape_', apd_long];
            var0.esetup_target_shape(ind) = {var0.(f1)};
            var0.esetup_target_pen_width(ind,1) = var0.response_pen_width;
        end
        
        % Task 3, probe
        apd_long = cond_text_long{3};
        apd_short = cond_text{3};
        
        if sum(isnan(var0.em_probe_trial)) ~= numel(var0.em_probe_trial)
            ind = strcmp(var0.esetup_block_cond, apd_short) & var0.esetup_target_number==1 & var0.em_probe_trial==1;
        else
            % This option cant exist, as it would over write single target trial
        end
        if sum(ind)>0
            var0.esetup_st1_coord(ind,1:2) = [var0.em_t3_coord1(ind,:), var0.em_t3_coord2(ind,:)];
            f1 = ['response_t3_color_', apd_long];
            var0.esetup_st1_color(ind,1:3) = repmat(var0.(f1), sum(ind), 1);
            f1 = ['response_t3_shape'];
            var0.esetup_target_shape(ind) = {var0.(f1)};
            var0.esetup_target_pen_width(ind,1) = var0.response_pen_width;
        end
        
        % Task 4, probe
        apd_long = cond_text_long{4};
        apd_short = cond_text{4};
        
        if sum(isnan(var0.em_probe_trial)) ~= numel(var0.em_probe_trial)
            ind = strcmp(var0.esetup_block_cond, apd_short) & var0.esetup_target_number==1 & var0.em_probe_trial==1;
        else
            ind = strcmp(var0.esetup_block_cond, apd_short) & var0.esetup_target_number==1;
        end
        if sum(ind)>0
            var0.esetup_st1_coord(ind,1:2) = [var0.em_t3_coord1(ind,:), var0.em_t3_coord2(ind,:)];
            f1 = ['response_t3_color_', apd_long];
            var0.esetup_st1_color(ind,1:3) = repmat(var0.(f1), sum(ind), 1);
            f1 = ['response_t3_shape'];
            var0.esetup_target_shape(ind) = {var0.(f1)};
            var0.esetup_target_pen_width(ind,1) = var0.response_pen_width;
        end
        
        % Task 5, control fixation
        apd_short = cond_text{5};
        ind = strcmp(var0.esetup_block_cond, apd_short);
        if sum(ind)>0
            var0.esetup_target_number(ind,:) = 0;
        end
        
        % Remove fields
        var0 = rmfield (var0, 'em_t1_coord1');
        var0 = rmfield (var0, 'em_t1_coord2');
        var0 = rmfield (var0, 'em_t2_coord1');
        var0 = rmfield (var0, 'em_t2_coord2');
        var0 = rmfield (var0, 'em_t3_coord1');
        var0 = rmfield (var0, 'em_t3_coord2');
        var0 = rmfield (var0, 'em_probe_trial');
        
        % esetup_st2_color_level
        if ~isfield(var0, 'esetup_st2_color_level')
            a = numel (var0.trialmatrix);
            ind = a;
            var0.esetup_st2_color_level = zeros(ind,1);
        end
        
        % esetup_response_soa
        a = 'em_distractor_soa';
        b = 'esetup_response_soa';
        if isfield(var0, a)
            var0.(b) = var0.(a);
            var0 = rmfield(var0, a);
        end
        
        % esetup_target_size
        if ~isfield(var0, 'esetup_target_size')
            a = zeros(numel(var0.trialmatrix), 1);
            b = ones(numel(var0.trialmatrix), 1) * var0.response_size;
            var0.esetup_target_size = [a a, b, b];
        end
        
        % esetup_target_size_eyetrack
        if ~isfield(var0, 'esetup_target_size_eyetrack')
            a = zeros(numel(var0.trialmatrix), 1);
            b = var0.em_eye_window;
            var0.esetup_target_size_eyetrack = [a a, b, b];
            var0 = rmfield(var0, 'em_eye_window');
        end
        
        %% Background textures
        
        % esetup_background_textures_per_trial
        if ~isfield(var0, 'esetup_background_textures_per_trial')
            a = numel (var0.trialmatrix);
            ind = a;
            var0.esetup_background_textures_per_trial = NaN(ind,1);
        end
        
        % esetup_background_texture_line_number
        % esetup_background_texture_line_length
        if ~isfield(var0, 'esetup_background_texture_line_number')
            a = numel (var0.trialmatrix);
            ind = a;
            var0.esetup_background_texture_line_number(1:a, 1) = var0.background_texture_line_number;
            var0.esetup_background_texture_line_length(1:a, 1) = var0.background_texture_line_length;
        end
        
        %===================
        % esetup_background_color
        c = 'esetup_background_color';
        if ~isfield(var0, 'c')
            
            a = numel (var0.trialmatrix); % Create matrix
            mat1 = NaN(a,3);
            
            for i = 1:numel(cond_text)
                
                a = cond_text{i}; % index
                ind = strcmp(var0.esetup_block_cond, a);
                ind = find(ind==1);
                
                a = ['background_color_', cond_text_long{i}]; % replace values
                if sum(ind)>0 && isfield(var0, a)
                    for j=1:numel(ind)
                        mat1(ind(j),1:3) = var0.(a);
                    end
                end
            end
            
            var0.(c) = mat1;
        end
        
        
        %% Add missing data fields
        
        % edata_loop_over
        if ~isfield(var0, 'edata_loop_over')
            a = numel (var0.trialmatrix);
            ind = a;
            var0.edata_loop_over(1:a, 1) = NaN;
            for i = 1:a
                b = [];
                b(1) = var0.edata_fixation_off(i);
                b(2) = var0.edata_st1_off(i);
                b(3) = var0.edata_st2_off(i);
                if sum(isnan(b))==3
                    var0.edata_loop_over(i) = NaN;
                else
                    var0.edata_loop_over(i) = max(b);
                end
            end
        end
        
        % edata_fixation_drift_calculated
        if ~isfield(var0, 'edata_fixation_drift_calculated')
            a = numel (var0.trialmatrix);
            ind = a;
            var0.edata_fixation_drift_calculated = NaN(a,1);
        end
        
        
        % edata_st1_on
        if ~isfield(var0, 'edata_st1_on')
            a = numel (var0.trialmatrix);
            ind = a;
            var0.edata_st1_on(1:a, 1) = NaN;
            for i = 1:a
                b = [];
                b(1) = var0.em_st1_on_1(i);
                b(2) = var0.em_st1_on_2(i);
                if sum(isnan(b))==2
                    var0.edata_st1_on(i) = NaN;
                else
                    var0.edata_st1_on(i) = max(b);
                end
            end
            var0 = rmfield(var0, 'em_st1_on_1');
            var0 = rmfield(var0, 'em_st1_on_2');
        end
        
        % edata_eyelinkscreen_drift_on
        if ~isfield(var0, 'edata_eyelinkscreen_drift_on')
            a = numel (var0.trialmatrix);
            ind = a;
            var0.edata_eyelinkscreen_drift_on = NaN(a,1);
        end
        
        % edata_eyelinkscreen_fixation
        if ~isfield(var0, 'edata_eyelinkscreen_fixation')
            a = numel (var0.trialmatrix);
            ind = a;
            var0.edata_eyelinkscreen_fixation = NaN(a,1);
        end
        
        % edata_eyelinkscreen_memory
        if ~isfield(var0, 'edata_eyelinkscreen_memory')
            a = numel (var0.trialmatrix);
            ind = a;
            var0.edata_eyelinkscreen_memory = NaN(a,1);
        end
        
        % edata_eyelinkscreen_st1
        if ~isfield(var0, 'edata_eyelinkscreen_st1')
            a = numel (var0.trialmatrix);
            ind = a;
            var0.edata_eyelinkscreen_st1 = NaN(a,1);
        end
        
        % edata_eyelinkscreen_st2
        if ~isfield(var0, 'edata_eyelinkscreen_st2')
            a = numel (var0.trialmatrix);
            ind = a;
            var0.edata_eyelinkscreen_st2 = NaN(a,1);
        end
        
        % edata_eyelinkscreen_distractor
        if ~isfield(var0, 'edata_eyelinkscreen_distractor')
            a = numel (var0.trialmatrix);
            ind = a;
            var0.edata_eyelinkscreen_distractor = NaN(a,1);
        end
        
        
        %% Rename error codes
        
        fprintf('Renaming error codes\n')
        
        if ~isfield(var0, 'edata_error_code')
            a = numel (var0.trialmatrix);
            ind = a;
            var0.edata_error_code = cell(a, 1);
            for i = 1:a
                b = [];
                b(1) = var0.em_data_reject_1(i);
                b(2) = var0.em_data_reject_2(i);
                if sum(isnan(b))==2
                    var0.edata_error_code(i) = {'Undefined error'};
                else
                    e1 = max(b);
                    if e1==1
                        var0.edata_error_code(i) = {'correct'};
                    elseif e1==2
                        var0.edata_error_code(i) = {'fixation not acquired in time'};
                    elseif e1==3
                        var0.edata_error_code(i) = {'broke fixation before drift'};
                    elseif e1==4
                        var0.edata_error_code(i) = {'broke fixation'};
                    elseif e1==5
                        var0.edata_error_code(i) = {'looked at st2'};
                    elseif e1==6
                        var0.edata_error_code(i) = {'no saccade'};
                    elseif e1==7
                        var0.edata_error_code(i) = {'left ST'};
                    elseif e1==99
                        var0.edata_error_code(i) = {'unknown error'};
                    end
                end
            end
            var0 = rmfield(var0, 'em_data_reject_1');
            var0 = rmfield(var0, 'em_data_reject_2');
        end
        
        %% eframes
        
        c = 'eframes_time';
        if ~isfield(var0, c)
            a = numel (var0.trialmatrix);
            ind = a;
            var0.(c) = cell(a, 1);
            for i = 1:a
                var0.(c){i} = var0.trialmatrix{i}(:,1);
            end
        end
        
        c = 'eframes_eye_x';
        if ~isfield(var0, c)
            a = numel (var0.trialmatrix);
            ind = a;
            var0.(c) = cell(a, 1);
            for i = 1:a
                var0.(c){i} = var0.trialmatrix{i}(:,2);
            end
        end
        
        c = 'eframes_eye_y';
        if ~isfield(var0, c)
            a = numel (var0.trialmatrix);
            ind = a;
            var0.(c) = cell(a, 1);
            for i = 1:a
                var0.(c){i} = var0.trialmatrix{i}(:,3);
            end
        end
        
        c = 'eframes_eye_target';
        if ~isfield(var0, c)
            a = numel (var0.trialmatrix);
            ind = a;
            var0.(c) = cell(a, 1);
            for i = 1:a
                var0.(c){i} = var0.trialmatrix{i}(:,4);
            end
        end
        
        var0 = rmfield(var0, 'trialmatrix');
        var0 = rmfield(var0, 'refresh_rate_mat');
        
        %% Save output
        
        var1.stim = var0;
        
    end
end
