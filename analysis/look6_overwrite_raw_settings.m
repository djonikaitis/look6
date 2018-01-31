%% Specify conditions to be modified

% fix eframes_fixation_offset & edata_fixation_off
overwrite_temp_index{1} = 20170801:20171028;

% Fix exp matrix size mismatch for HB on 12.21.2017 (remove trial no 601, as this trial does not exist)
overwrite_temp_index{2} = 20171221;

% Fix exp matrix size mismatch for HB on 12.21.2017 (remove trial no 601, as this trial does not exist)
overwrite_temp_index{3} = 20160101:20171231;

%% Fixation offset time bug

if settings.overwrite_temp_switch == 1 && date_current >= overwrite_temp_index{1}(1) && date_current <= overwrite_temp_index{1}(end)
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

if settings.overwrite_temp_switch == 1 && date_current >= overwrite_temp_index{2}(1) && date_current <= overwrite_temp_index{2}(end)
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


if settings.overwrite_temp_switch == 1 && date_current >= overwrite_temp_index{3}(1) && date_current <= overwrite_temp_index{3}(end)
    if strcmp(var1.general.expname, 'look5') && strcmp(var1.general.subject_id, 'hb')
        
        % Initialize an empty variable
        fprintf('Early exp version detected: look5, initialize new data structure\n');
        vtemp1 = struct;
        
        fprintf('Early exp version detected: look5. Splitting exp_setup and exp_data matrices into variables\n')
        
        %% Restructure expsetup matrix
        
        % Setup column names in expmatrix
        % This part to be removed in future experiments
        em_name = cell(1,100);  % Initialize empty matrix for var names
        
        % Exp setup
        em_name{1} = 'esetup_fixation_acquire_duration';  % Time to acquire fixation
        em_name{2} = 'em_fixation_maintain_duration'; % Time to maintain fixation
        em_name{3} = 'esetup_fixation_arc'; % Position of st 1 (deg on a circle)
        em_name{4} = 'esetup_fixation_radius'; % Distance to st 1 (radius)
        em_name{5} = 'esetup_fixation_size_eyetrack'; % Fixation accuracy
        %         % 6
        em_name{7} = 'esetup_memory_coord_x'; % Position of  memory target (x)
        em_name{8} = 'esetup_memory_coord_y'; % Distance of memory target (y)
        em_name{9} = 'em_t1_coord1'; % REMOVE FIELD
        em_name{10} = 'em_t1_coord2'; % REMOVE FIELD
        em_name{11} = 'em_t2_coord1'; % REMOVE
        em_name{12} = 'em_t2_coord2'; % REMOVE
        em_name{13} = 'em_t3_coord1'; % REMOVE
        em_name{14} = 'em_t3_coord2'; % REMOVE
        
        %         em_name{15} = 'em_eye_window'; % Saccade accuracy
        %         % 16
        %         % 17
                em_name{18} = 'esetup_target_number'; % 1 or 2 targets
                em_name{19} = 'em_probe_trial'; %  1 - probe; 0 - no probe; % DEAL WITH THIS
                em_name{20} = 'em_distractor_soa'; % SOA between t1 & t2
                em_name{21} = 'esetup_memory_duration'; % Duration of memory target
                em_name{22} = 'esetup_memory_delay'; % Delay duration
        %         em_name{23} = 'em_reward_size_ms'; % REMOVE THIS FIELD
        %         em_name{24} = 'em_reward_size_ml'; % REMOVE THIS FIELD
                em_name{25} = 'esetup_total_fixation_duration'; % How long delay + fixation lasts
                em_name{26} = 'esetup_background_texture_on'; % Is texture shown
                em_name{27} = 'esetup_background_texture_line_angle'; % Angle of the lines in the texture
        %         % 28
        %         % 29
        
        % Necessary columns
        em_name{30} = 'esetup_block_no';
        em_name{31} = 'esetup_block_cond'; % Which blocked condition is presented (example: 2 blocked conditions in a 4 block experiment) NECESSARY COLUMN FOR ALL EXPS
        em_name{32} = 'em_data_reject'; % Was the trial online accepted or rejected? NECESSARY COLUMN FOR ALL EXPS
        % 33
        % 34
        
        % Recorded data
        em_name{35} = 'edata_first_display';
        %         em_name{36} = 'em_data_last_display';
        em_name{37} = 'edata_fixation_on';
        em_name{38} = 'edata_fixation_off';
        %         em_name{39} = 'em_data_response_on';
        em_name{40} = 'edata_fixation_acquired';
        em_name{41} = 'edata_fixation_drift_maintained';
        em_name{42} = 'edata_fixation_maintained';
        em_name{43} = 'edata_st1_on';
        em_name{44} = 'edata_response_acquired';
        em_name{45} = 'edata_response_maintained';
        em_name{46} = 'edata_st1_off';
        em_name{47} = 'edata_st2_on';
        em_name{48} = 'edata_memory_on';
        em_name{49} = 'edata_memory_off';
        em_name{50} = 'edata_st2_off';
        em_name{51} = 'edata_background_texture_onset_time';
        %         em_name{52} = 'em_data_button_press'; % REMOVE THIS FIELD
        em_name{53} = 'edata_fixation_color_change';
        %         % 54
        %         % 55
        %         % 56
        %         % 57
        %         % 58
        %         % 59
        %         % 60
        em_name{61} = 'em_data_reject';
        em_name{62} = 'temp1_data_drift_x1';
        em_name{63} = 'temp1_data_drift_y1';
        %         em_name{64} = 'em_data_error_counter';
        em_name{65} = 'edata_reward_size_ms';
        em_name{66} = 'edata_reward_size_ml';
        em_name{67} = 'edata_reward_on';
        em_name{68} = 'edata_reward_image_on';
        
        % Calculate how many trials are there
        a = numel (var1.stim.trialmatrix);
        b = numel (var1.stim.refresh_rate_mat);
        if a==b
            ind = 1:a;
            % Restructure the matrices
            for i=1:numel(em_name)
                if ~isempty(em_name{i})
                    var1.stim.(em_name{i}) = var1.stim.expmatrix(:,i);
                end
            end
        else
            error ('Non-matching trial counts for "trialmatrix" and "refresh_rate_mat" - figure out whats wrong')
        end
        
        % Clear out expmatrix field
        var1.stim = rmfield(var1.stim, 'expmatrix');
        
        %% Rename error codes
        
        fprintf('Renaming error codes\n')
% % % %         a = numel (var1.stim.trialmatrix);
% % % %         b = cell(a,1);
% % % %         ind = var1.stim.em_data_reject==1;
% % % %         b(ind)={'look'};
% % % %         ind = var1.stim.em_data_reject==2;
% % % %         b(ind)={'avoid'};
% % % %         ind = var1.stim.em_data_reject==3;
% % % %         b(ind)={'control irrelevant cue and single target or probe'};
% % % %         ind = var1.stim.em_data_reject==4;
% % % %         b(ind)={'control no cue and probe'};
% % % %         ind = var1.stim.em_data_reject==5;
% % % %         b(ind)={'control fixate'};
% % % %         
% % % %         var1.stim.edata_error_code = b;
% % % %         var1.stim = rmfield(var1.stim, 'em_data_reject');

        
        %% Change exp_cond variable
        
        fprintf('Renaming conditions of the esetup_block_cond varialbe\n')
        a = numel (var1.stim.trialmatrix);
        b = cell(a,1);
        ind = var1.stim.esetup_block_cond==1;
        b(ind)={'look'};
        ind = var1.stim.esetup_block_cond==2;
        b(ind)={'avoid'};
        ind = var1.stim.maincond==3;
        b(ind)={'control irrelevant cue and single target or probe'};
        ind = var1.stim.maincond==4;
        b(ind)={'control no cue and probe'};
        ind = var1.stim.esetup_block_cond==5;
        b(ind)={'control fixate'};
        
        var1.stim.esetup_block_cond = b;
        
        a = numel(var1.stim.maincond);
        b = cell(a, 1);
        ind = var1.stim.maincond==1;
        b(ind)={'look'};
        ind = var1.stim.maincond==2;
        b(ind)={'avoid'};
        ind = var1.stim.maincond==3;
        b(ind)={'control irrelevant cue and single target or probe'};
        ind = var1.stim.maincond==4;
        b(ind)={'control no cue and probe'};
        ind = var1.stim.maincond==5;
        b(ind)={'control fixate'};
        
        var1.stim.maincond = b;
        
        if var1.stim.exp_version == 1
            var1.stim.probe_extended_map = 0;
        elseif var1.stim.exp_version == 1
            var1.stim.probe_extended_map = 3;
        end
        var1.stim = rmfield(var1.stim, 'exp_version');

        
        %% Concatenate a few variables
        
        fprintf('Concatenating a few of the variables (for each trial)\n')
        
        % esetup_memory_coord
        var1.stim.esetup_memory_coord = [var1.stim.esetup_memory_coord_x; var1.stim.esetup_memory_coord_y];
        var1.stim = rmfield(var1.stim, 'esetup_memory_coord_x');
        var1.stim = rmfield(var1.stim, 'esetup_memory_coord_y');
        
        % esetup_fixation_drift_offset
        var1.stim.esetup_fixation_drift_offset = [var1.stim.temp1_data_drift_x1; var1.stim.esetup_memory_coord_y];
        var1.stim = rmfield(var1.stim, 'temp1_data_drift_x1');
        var1.stim = rmfield(var1.stim, 'temp1_data_drift_y1');
        
        
        %% Create a bunch of condition specific variables
        
        % esetup_fixation_size_eyetrack
        a = zeros(numel(var1.stim.trialmatrix), 1);
        b = var1.stim.esetup_fixation_size_eyetrack;
        var1.stim.esetup_fixation_size_eyetrack = [a; a; b; b];
        
        % esetup_fixation_size_drift
        a = zeros(numel(var1.stim.trialmatrix), 1);
        b = ones(numel(var1.stim.trialmatrix), 1) * var1.stim.fixation_accuracy_drift;
        var1.stim.esetup_fixation_size_drift = [a; a; b; b];
        
        % esetup_fixation_size
        a = zeros(numel(var1.stim.trialmatrix), 1);
        b = ones(numel(var1.stim.trialmatrix), 1) * var1.stim.fixation_size(end);
        var1.stim.esetup_fixation_size = [a; a; b; b];
        
        % esetup_memory_size
        a = numel(var1.stim.trialmatrix);
        b =  repmat(var1.stim.memory_size, a, 1);
        var1.stim.esetup_memory_size = b;
        
        % esetup_target_size
        a = zeros(numel(var1.stim.trialmatrix), 1);
        b = ones(numel(var1.stim.trialmatrix), 1) * var1.stim.response_size;
        var1.stim.esetup_target_size = [a; a; b; b];
        
        % esetup_target_size_eyetrack
        a = zeros(numel(var1.stim.trialmatrix), 1);
        b = ones(numel(var1.stim.trialmatrix), 1) * var1.stim.response_saccade_accuracy;
        var1.stim.esetup_target_size = [a; a; b; b];
        esetup_target_size_eyetrack
        
        %% Condition specific variables
        
        ind_1 = strcmp(var1.stim.esetup_block_cond, 'look');
        ind_2 = strcmp(var1.stim.esetup_block_cond, 'avoid');
        ind_5 = strcmp(var1.stim.esetup_block_cond, 'control fixate');
        
        % esetup_fixation_color
        a = numel (var1.stim.trialmatrix);
        b = NaN(a,3);
        b(ind_1,1:3)=var1.stim.fixation_color_task1;
        b(ind_2,1:3)=var1.stim.fixation_color_task2;
        b(ind_5,1:3)=var1.stim.fixation_color_task5;
        var1.stim.esetup_fixation_color = b;
        
        % esetup_fixation_shape
        a = numel (var1.stim.trialmatrix);
        b = cell(a,1);
        b(ind_1)={var1.stim.fixation_shape_task1};
        b(ind_2)={var1.stim.fixation_shape_task2};
        b(ind_5)={var1.stim.fixation_shape_task5};
        var1.stim.esetup_fixation_shape = b;

        % esetup_memory_shape
        a = numel (var1.stim.trialmatrix);
        b = cell(a,1);
        b(ind_1)={var1.stim.memory_shape_task1};
        b(ind_2)={var1.stim.memory_shape_task2};
        b(ind_5)={var1.stim.memory_shape_task5};
        var1.stim.esetup_memory_shape = b;
        
        % esetup_memory_color
        a = numel (var1.stim.trialmatrix);
        b = NaN(a,3);
        b(ind_1,1:3)=var1.stim.fixation_color_task1;
        b(ind_2,1:3)=var1.stim.fixation_color_task2;
        b(ind_5,1:3)=var1.stim.fixation_color_task5;
        var1.stim.esetup_memory_color = b;
        
        % esetup_memory_pen_width
        a = numel (var1.stim.trialmatrix);
        b = NaN(a,1);
        b(ind_1,1)=var1.stim.memory_pen_width_task1;
        b(ind_2,1)=var1.stim.memory_pen_width_task2;
        b(ind_5,1)=var1.stim.memory_pen_width_task5;
        var1.stim.esetup_memory_pen_width = b;
        
        %=====================
        % saccade target
        a = numel (var1.stim.trialmatrix);
        var1.stim.esetup_st1_coord=NaN(a,2);
        var1.stim.esetup_st2_coord=NaN(a,2);
        var1.stim.esetup_st1_color = NaN(a,3);
        var1.stim.esetup_st2_color = NaN(a,3);
        var1.stim.esetup_target_shape = cell(a,1);
        var1.stim.esetup_target_pen_width = NaN(a,1);

        % Look task, 2 targets
        ind = strcmp(var1.stim.esetup_block_cond, 'look') & var1.stim.esetup_target_number=2 & var1.stim.em_probe_trial==0;
        var1.stim.esetup_st1_coord(ind,1:2) = [var1.stim.em_t1_coord1(ind,:); var1.stim.em_t1_coord2(ind,:)];
        var1.stim.esetup_st2_coord(ind,1:2) = [var1.stim.em_t2_coord1(ind,:); var1.stim.em_t2_coord2(ind,:)];
        var1.stim.esetup_st1_color(ind,1;3) = var1.stim.response_t1_color_task1;
        var1.stim.esetup_st2_color(ind,1:3) = var1.stim.response_t2_color_task1;
        var1.stim.esetup_target_shape(ind) = {var1.stim.response_shape_task1};
        var1.stim.esetup_target_pen_width(ind,1) = var1.stim.response_pen_width;
        
        % Look task, 1 target
        ind = strcmp(var1.stim.esetup_block_cond, 'look') & var1.stim.esetup_target_number=1 & var1.stim.em_probe_trial==0;
        var1.stim.esetup_st1_coord(ind,1:2) = [var1.stim.em_t1_coord1(ind,:); var1.stim.em_t1_coord2(ind,:)];
        var1.stim.esetup_st1_color(ind,1;3) = var1.stim.response_t1_color_task1;
        var1.stim.esetup_target_shape(ind) = {var1.stim.response_shape_task1};
        var1.stim.esetup_target_pen_width(ind,1) = var1.stim.response_pen_width;
        
        % Look task, probe
        ind = strcmp(var1.stim.esetup_block_cond, 'look') & var1.stim.esetup_target_number=1 & var1.stim.em_probe_trial==1;
        var1.stim.esetup_st1_coord(ind,1:2) = [var1.stim.em_t3_coord1(ind,:); var1.stim.em_t3_coord2(ind,:)];
        var1.stim.esetup_st1_color(ind,1;3) = var1.stim.response_t3_color_task1;
        var1.stim.esetup_target_shape(ind) = {var1.stim.response_t3_shape};
        var1.stim.esetup_target_pen_width(ind,1) = var1.stim.response_pen_width;
        
        % Avoid task, 2 targets
        ind = strcmp(var1.stim.esetup_block_cond, 'avoid') & var1.stim.esetup_target_number=2 & var1.stim.em_probe_trial==0;
        var1.stim.esetup_st1_coord(ind,1:2) = [var1.stim.em_t2_coord1(ind,:); var1.stim.em_t2_coord2(ind,:)];
        var1.stim.esetup_st2_coord(ind,1:2) = [var1.stim.em_t1_coord1(ind,:); var1.stim.em_t1_coord2(ind,:)];
        var1.stim.esetup_st1_color(ind,1;3) = var1.stim.response_t2_color_task2;
        var1.stim.esetup_st2_color(ind,1:3) = var1.stim.response_t1_color_task2;
        var1.stim.esetup_target_shape(ind) = {var1.stim.response_shape_task2};
        var1.stim.esetup_target_pen_width(ind,1) = var1.stim.response_pen_width;
        
        % Avoid task, 1 target
        ind = strcmp(var1.stim.esetup_block_cond, 'avoid') & var1.stim.esetup_target_number=1 & var1.stim.em_probe_trial==0;
        var1.stim.esetup_st1_coord(ind,1:2) = [var1.stim.em_t2_coord1(ind,:); var1.stim.em_t2_coord2(ind,:)];
        var1.stim.esetup_st1_color(ind,1;3) = var1.stim.response_t2_color_task2;
        var1.stim.esetup_target_shape(ind) = {var1.stim.response_shape_task2};
        var1.stim.esetup_target_pen_width(ind,1) = var1.stim.response_pen_width;
        
        % Avoid task, probe
        ind = strcmp(var1.stim.esetup_block_cond, 'avoid') & var1.stim.esetup_target_number=1 & var1.stim.em_probe_trial==1;
        var1.stim.esetup_st1_coord(ind,1:2) = [var1.stim.em_t3_coord1(ind,:); var1.stim.em_t3_coord2(ind,:)];
        var1.stim.esetup_st1_color(ind,1;3) = var1.stim.response_t3_color_task2;
        var1.stim.esetup_target_shape(ind) = {var1.stim.response_t3_shape};
        var1.stim.esetup_target_pen_width(ind,1) = var1.stim.response_pen_width;
        
        %==================
        % Task 3, 1 target
        ind = strcmp(var1.stim.esetup_block_cond, 'control - irrelevant cue and single target or probe') & var1.stim.esetup_target_number=1 & var1.stim.em_probe_trial==0;
        var1.stim.esetup_st1_coord(ind,1:2) = [var1.stim.em_t3_coord1(ind,:); var1.stim.em_t3_coord2(ind,:)];
        var1.stim.esetup_st1_color(ind,1;3) = var1.stim.response_t1_color_task3;
        var1.stim.esetup_target_shape(ind) = {var1.stim.response_shape_task3};
        var1.stim.esetup_target_pen_width(ind,1) = var1.stim.response_pen_width;
        
        % Task 3, probe
        ind = strcmp(var1.stim.esetup_block_cond, 'control - irrelevant cue and single target or probe') & var1.stim.esetup_target_number=1 & var1.stim.em_probe_trial==1;
        var1.stim.esetup_st1_coord(ind,1:2) = [var1.stim.em_t3_coord1(ind,:); var1.stim.em_t3_coord2(ind,:)];
        var1.stim.esetup_st1_color(ind,1;3) = var1.stim.response_t3_color_task3;
        var1.stim.esetup_target_shape(ind) = {var1.stim.response_t3_shape};
        var1.stim.esetup_target_pen_width(ind,1) = var1.stim.response_pen_width;
       
        %===================
        % Task 4, probe
        ind = strcmp(var1.stim.esetup_block_cond, 'control - no cue and probe') & var1.stim.esetup_target_number=1 & var1.stim.em_probe_trial==1;
        var1.stim.esetup_st1_coord(ind,1:2) = [var1.stim.em_t3_coord1(ind,:); var1.stim.em_t3_coord2(ind,:)];
        var1.stim.esetup_st1_color(ind,1;3) = var1.stim.response_t3_color_task4;
        var1.stim.esetup_target_shape(ind) = {var1.stim.response_t3_shape};
        var1.stim.esetup_target_pen_width(ind,1) = var1.stim.response_pen_width;
        
        %===================
        % Task 5, control fixation
        ind = strcmp(var1.stim.esetup_block_cond, 'control fixation');
        var1.stim.esetup_target_number(ind,:) = 0;
        
        % Remove fields
        var1.stim = rmfield (var1.stim, 'em_t1_coord1');
        var1.stim = rmfield (var1.stim, 'em_t1_coord2');
        var1.stim = rmfield (var1.stim, 'em_t2_coord1');
        var1.stim = rmfield (var1.stim, 'em_t2_coord2');
        var1.stim = rmfield (var1.stim, 'em_t3_coord1');
        var1.stim = rmfield (var1.stim, 'em_t3_coord2');
        var1.stim = rmfield (var1.stim, 'em_probe_trial');
        
        var1.stim = rmfield(var1.stim, 'em_reward_size_ms');
        var1.stim = rmfield(var1.stim, 'em_reward_size_ml');
        
        % esetup_background_color
        a = numel (var1.stim.trialmatrix);
        b = NaN(a,3);
        b(ind_1,1:3)=var1.stim.fixation_color_look;
        b(ind_2,1:3)=var1.stim.fixation_color_avoid;
        b(ind_3,1:3)=var1.stim.fixation_color_control_irrelevant_cue_and_single_target_or_probe;
        b(ind_4,1:3)=var1.stim.fixation_color_control_no_texture_and_probe;
        b(ind_5,1:3)=var1.stim.fixation_color_control_fixate;
        var1.stim.esetup_memory_color = b;
        
        %% Add additional long variables
        
        fprintf('Adding a few empty variables (for each trial)\n')

        a = numel (var1.stim.trialmatrix);
        b = numel (var1.stim.refresh_rate_mat);
        if a==b
            ind = a;
            
            % esetup_fixation_drift_correction_on
            var1.stim.esetup_fixation_drift_correction_on(1:ind,1) = var1.stim.fixation_drift_correction_on;
            % background_texture_line_number
            var1.stim.esetup_background_texture_line_number(1:ind,1) = var1.stim.background_texture_line_number;
            % background_texture_line_length
            var1.stim.esetup_background_texture_line_length(1:ind,1) = var1.stim.background_texture_line_length;

            % Add missing fields
            var1.stim.edata_fixation_drift_calculated = NaN(ind,1);
            var1.stim.esetup_background_textures_per_trial = NaN(ind,1);
            var1.stim.edata_eyelinkscreen_drift_on = NaN(ind,1);
            var1.stim.edata_eyelinkscreen_fixation = NaN(ind,1);
            var1.stim.edata_eyelinkscreen_memory = NaN(ind,1);
            var1.stim.edata_eyelinkscreen_st1 = NaN(ind,1);
            var1.stim.edata_eyelinkscreen_st2 = NaN(ind,1);
            var1.stim.edata_eyelinkscreen_distractor = NaN(ind,1);
            var1.stim.esetup_st2_color_level = zeros(ind,1);
        end
        
        %% Rename a few of variables
        
        fprintf('Renaming a few of variables\n')
        
        % Fixation look
        a = 'fixation_color_task1';
        b = 'fixation_color_look';
        if isfield(var1.stim, a)
            var1.stim.(b) = var1.stim.(a);
            var1.stim = rmfield(var1.stim, a);
        end
        
        a = 'fixation_shape_task1';
        b = 'fixation_shape_look';
        if isfield(var1.stim, a)
            var1.stim.(b) = var1.stim.(a);
            var1.stim = rmfield(var1.stim, a);
        end
        
        % Fixation avpid
        a = 'fixation_color_task2';
        b = 'fixation_color_avoid';
        if isfield(var1.stim, a)
            var1.stim.(b) = var1.stim.(a);
            var1.stim = rmfield(var1.stim, a);
        end
        
        a = 'fixation_shape_task2';
        b = 'fixation_shape_avoid';
        if isfield(var1.stim, a)
            var1.stim.(b) = var1.stim.(a);
            var1.stim = rmfield(var1.stim, a);
        end
        
        % Fixation task 3
        a = 'fixation_color_task3';
        b = 'fixation_color_control_irrelevant_cue_and_single_target_or_probe';
        if isfield(var1.stim, a)
            var1.stim.(b) = var1.stim.(a);
            var1.stim = rmfield(var1.stim, a);
        end
        
        a = 'fixation_shape_task3';
        b = 'fixation_shape_control_irrelevant_cue_and_single_target_or_probe';
        if isfield(var1.stim, a)
            var1.stim.(b) = var1.stim.(a);
            var1.stim = rmfield(var1.stim, a);
        end
        
                % Fixation task 4
        a = 'fixation_color_task4';
        b = 'fixation_color_control_no_cue_and_probe';
        if isfield(var1.stim, a)
            var1.stim.(b) = var1.stim.(a);
            var1.stim = rmfield(var1.stim, a);
        end
        
        a = 'fixation_shape_task4';
        b = 'fixation_shape_control_no_cue_and_probe';
        if isfield(var1.stim, a)
            var1.stim.(b) = var1.stim.(a);
            var1.stim = rmfield(var1.stim, a);
        end
        
        
        % Fixation control
        a = 'fixation_color_task5';
        b = 'fixation_color_control_fixate';
        if isfield(var1.stim, a)
            var1.stim.(b) = var1.stim.(a);
            var1.stim = rmfield(var1.stim, a);
        end
        
        a = 'fixation_shape_task5';
        b = 'fixation_shape_control_fixate';
        if isfield(var1.stim, a)
            var1.stim.(b) = var1.stim.(a);
            var1.stim = rmfield(var1.stim, a);
        end
        
        % Distractor soa
        a = 'em_distractor_soa';
        b = 'esetup_response_soa';
        if isfield(var1.stim, a)
            var1.stim.(b) = var1.stim.(a);
            var1.stim = rmfield(var1.stim, a);
        end
        
        % Color level variable does not exist
        var1.stim.st2_color_level = 0;
        
        % Fixation size eyetrack
        if numel(var1.stim.memory_size)>1
            var1.stim.fixation_size = var1.stim.fixation_size(end);
        end
        
        % Fixation arc
        var1.stim.fixation_arc = var1.stim.fixation_position;
        var1.stim = rmfield(var1.stim, 'fixation_position');

        
        % Drift correction
        var1.stim.fixation_size_drift = var1.stim.fixation_accuracy_drift;
        var1.stim = rmfield(var1.stim, 'fixation_accuracy_drift');
        
        % Fixation size eyetrack
        var1.stim.fixation_size_eyetrack = var1.stim.fixation_accuracy;
        var1.stim = rmfield(var1.stim, 'fixation_accuracy');
        
        % Memory
        if numel(var1.stim.memory_size)>1
            var1.stim.memory_size = var1.stim.memory_size(end);
        end
        
        % Memory look
        a = 'memory_color_task1';
        b = 'memory_color_look';
        if isfield(var1.stim, a)
            var1.stim.(b) = var1.stim.(a);
            var1.stim = rmfield(var1.stim, a);
        end
        
        a = 'memory_shape_task1';
        b = 'memory_shape_look';
        if isfield(var1.stim, a)
            var1.stim.(b) = var1.stim.(a);
            var1.stim = rmfield(var1.stim, a);
        end
        
        a = 'memory_pen_width_task1';
        b = 'memory_pen_width_look';
        if isfield(var1.stim, a)
            var1.stim.(b) = var1.stim.(a);
            var1.stim = rmfield(var1.stim, a);
        end
        
        % Memory avoid
        a = 'memory_color_task2';
        b = 'memory_color_avoid';
        if isfield(var1.stim, a)
            var1.stim.(b) = var1.stim.(a);
            var1.stim = rmfield(var1.stim, a);
        end
        
        a = 'memory_shape_task2';
        b = 'memory_shape_avoid';
        if isfield(var1.stim, a)
            var1.stim.(b) = var1.stim.(a);
            var1.stim = rmfield(var1.stim, a);
        end
        
        a = 'memory_pen_width_task2';
        b = 'memory_pen_width_avoid';
        if isfield(var1.stim, a)
            var1.stim.(b) = var1.stim.(a);
            var1.stim = rmfield(var1.stim, a);
        end
        
                % Memory control_irrelevant_cue_and_single_target_or_probe
        a = 'memory_color_task3';
        b = 'memory_color_control_irrelevant_cue_and_single_target_or_probe';
        if isfield(var1.stim, a)
            var1.stim.(b) = var1.stim.(a);
            var1.stim = rmfield(var1.stim, a);
        end
        
        a = 'memory_shape_task3';
        b = 'memory_shape_control_irrelevant_cue_and_single_target_or_probe';
        if isfield(var1.stim, a)
            var1.stim.(b) = var1.stim.(a);
            var1.stim = rmfield(var1.stim, a);
        end
        
        a = 'memory_pen_width_task3';
        b = 'memory_pen_control_irrelevant_cue_and_single_target_or_probe';
        if isfield(var1.stim, a)
            var1.stim.(b) = var1.stim.(a);
            var1.stim = rmfield(var1.stim, a);
        end

        % Memory control
        a = 'memory_color_task5';
        b = 'memory_color_control_fixate';
        if isfield(var1.stim, a)
            var1.stim.(b) = var1.stim.(a);
            var1.stim = rmfield(var1.stim, a);
        end
        
        a = 'memory_shape_task5';
        b = 'memory_shape_control_fixate';
        if isfield(var1.stim, a)
            var1.stim.(b) = var1.stim.(a);
            var1.stim = rmfield(var1.stim, a);
        end
        
        a = 'memory_pen_width_task5';
        b = 'memory_pen_width_control_fixate';
        if isfield(var1.stim, a)
            var1.stim.(b) = var1.stim.(a);
            var1.stim = rmfield(var1.stim, a);
        end
        
        % Background texture
        a = 'background_color_task1';
        b = 'background_color_look';
        if isfield(var1.stim, a)
            var1.stim.(b) = var1.stim.(a);
            var1.stim = rmfield(var1.stim, a);
        end
        
        % Background texture
        a = 'background_color_task2';
        b = 'background_color_avoid';
        if isfield(var1.stim, a)
            var1.stim.(b) = var1.stim.(a);
            var1.stim = rmfield(var1.stim, a);
        end
        
        % Background texture
        a = 'background_color_task3';
        b = 'background_color_control_irrelevant_cue_and_single_target_or_probe';
        if isfield(var1.stim, a)
            var1.stim.(b) = var1.stim.(a);
            var1.stim = rmfield(var1.stim, a);
        end
        
        % Background texture
        a = 'background_color_task4';
        b = 'background_color_control_no_cue_and_probe';
        if isfield(var1.stim, a)
            var1.stim.(b) = var1.stim.(a);
            var1.stim = rmfield(var1.stim, a);
        end
        
        % Background texture
        a = 'background_color_task5';
        b = 'background_color_control_fixate';
        if isfield(var1.stim, a)
            var1.stim.(b) = var1.stim.(a);
            var1.stim = rmfield(var1.stim, a);
        end
        
        % Response size
        if numel(var1.stim.response_size)>1
            var1.stim.response_size = var1.stim.response_size(end);
        end
        
        %====================
        % T1 colors look
        a = 'response_t1_color_task1';
        b = 'response_t1_color_look';
        if isfield(var1.stim, a)
            var1.stim.(b) = var1.stim.(a);
            var1.stim = rmfield(var1.stim, a);
        end
        
        a = 'response_t2_color_task1';
        b = 'response_t2_color_look';
        if isfield(var1.stim, a)
            var1.stim.(b) = var1.stim.(a);
            var1.stim = rmfield(var1.stim, a);
        end
        
        a = 'response_shape_task1';
        b = 'response_shape_look';
        if isfield(var1.stim, a)
            var1.stim.(b) = var1.stim.(a);
            var1.stim = rmfield(var1.stim, a);
        end
        
        %================
        % T1 colors avoid
        a = 'response_t1_color_task2';
        b = 'response_t1_color_avoid';
        if isfield(var1.stim, a)
            var1.stim.(b) = var1.stim.(a);
            var1.stim = rmfield(var1.stim, a);
        end
        
        a = 'response_t2_color_task2';
        b = 'response_t2_color_avoid';
        if isfield(var1.stim, a)
            var1.stim.(b) = var1.stim.(a);
            var1.stim = rmfield(var1.stim, a);
        end
        
        a = 'response_shape_task2';
        b = 'response_shape_avoid';
        if isfield(var1.stim, a)
            var1.stim.(b) = var1.stim.(a);
            var1.stim = rmfield(var1.stim, a);
        end
        
        %================
        % T1 colors control
        a = 'response_t1_color_task3';
        b = 'response_t1_control_irrelevant_cue_and_single_target_or_probe';
        if isfield(var1.stim, a)
            var1.stim.(b) = var1.stim.(a);
            var1.stim = rmfield(var1.stim, a);
        end
        
        a = 'response_shape_task3';
        b = 'response_shape_control_irrelevant_cue_and_single_target_or_probe';
        if isfield(var1.stim, a)
            var1.stim.(b) = var1.stim.(a);
            var1.stim = rmfield(var1.stim, a);
        end
        
        %==================
        % T3 colors
        a = 'response_t3_color_task1';
        b = 'response_t3_color_look';
        if isfield(var1.stim, a)
            var1.stim.(b) = var1.stim.(a);
            var1.stim = rmfield(var1.stim, a);
        end
        
        a = 'response_t3_color_task2';
        b = 'response_t3_color_avoid';
        if isfield(var1.stim, a)
            var1.stim.(b) = var1.stim.(a);
            var1.stim = rmfield(var1.stim, a);
        end
        
        a = 'response_t3_color_task3';
        b = 'response_t3_color_control_irrelevant_cue_and_single_target_or_probe';
        if isfield(var1.stim, a)
            var1.stim.(b) = var1.stim.(a);
            var1.stim = rmfield(var1.stim, a);
        end
        
        a = 'response_t3_color_task4';
        b = 'response_t3_color_control_no_cue_and_probe';
        if isfield(var1.stim, a)
            var1.stim.(b) = var1.stim.(a);
            var1.stim = rmfield(var1.stim, a);
        end
        
        %================
        % Control fixate value not saved, copy it from look task
        a = 'response_t3_color_look';
        b = 'response_t3_color_control_fixate';
        var1.stim.(b) = var1.stim.(a);
        
        % Response soa
        a = 'response_distractor_soa';
        b = 'response_soa';
        if isfield(var1.stim, a)
            var1.stim.(b) = var1.stim.(a);
            var1.stim = rmfield(var1.stim, a);
        end
        
        
        %% Remove few varialbes
        
        fprintf('Removing a few temorary variables\n')

        var1.stim = rmfield(var1.stim, 'fixation_color');
        var1.stim = rmfield(var1.stim, 'fixation_shape');
        var1.stim = rmfield(var1.stim, 'background_color');
        var1.stim = rmfield(var1.stim, 'response_t3_color');
        var1.stim = rmfield(var1.stim, 'memory_color');
        var1.stim = rmfield(var1.stim, 'memory_shape');
        var1.stim = rmfield(var1.stim, 'memory_pen_width');



        %% Add fields that are based on expsetup values
        
        
        

        
    end
end