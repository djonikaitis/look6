% Create a structure TV which will be used to update stimulus values

%============

tv1 = struct; % Temporary Variable (TV)
tv1(1).update = 'none';

% Select variables to be modified
if strcmp(expsetup.stim.exp_version_temp, 'fix duration increase')
    tv1(1).temp_var_final = nanmean(expsetup.stim.fixation_maintain_duration_ini);
    tv1(1).temp_var_ini = expsetup.stim.fix_duration_increase_ini;
    tv1(1).temp_var_ini_step = expsetup.stim.fix_duration_increase_ini_step;
    tv1(1).name = 'esetup_fixation_maintain_duration';
    tv1(1).temp_var_current = NaN; % This value will be filed up
    tv1(1).update = 'gradual';
end

% Select variables to be modified
if strcmp(expsetup.stim.exp_version_temp, 'task switch luminance change') || ...
        strcmp(expsetup.stim.exp_version_temp, 'look luminance change') ||...
        strcmp(expsetup.stim.exp_version_temp, 'avoid luminance change')
    tv1(1).temp_var_final = nanmean(expsetup.stim.st2_color_level);
    tv1(1).temp_var_ini = expsetup.stim.st2_color_level_ini;
    tv1(1).temp_var_ini_step = expsetup.stim.st2_color_level_ini_step;
    tv1(1).name = 'esetup_st2_color_level';
    tv1(1).temp_var_current = NaN; % This value will be filed up
    tv1(1).update = 'gradual';
end

% Select variables to be modified
if strcmp(expsetup.stim.exp_version_temp, 'delay increase')
    tv1(1).temp_var_final = nanmean(expsetup.stim.fixation_maintain_duration);
    tv1(1).temp_var_ini = expsetup.stim.fixation_maintain_duration_ini;
    tv1(1).temp_var_ini_step = expsetup.stim.fixation_maintain_duration_ini_step;
    tv1(1).name = 'esetup_fixation_maintain_duration';
    tv1(1).temp_var_current = NaN; % This value will be filed up
    tv1(2).temp_var_final = nanmean(expsetup.stim.memory_delay_duration);
    tv1(2).temp_var_ini = expsetup.stim.memory_delay_duration_ini;
    tv1(2).temp_var_ini_step = expsetup.stim.memory_delay_duration_ini_step;
    tv1(2).temp_var_current = NaN; % This value will be filled up
    tv1(2).name = 'esetup_memory_delay';
    tv1(1).update = 'gradual';
end

% Select variables to be modified
if strcmp(expsetup.stim.exp_version_temp, 'distractor train luminance')
    tv1(1).temp_var_final = nanmean(expsetup.stim.distractor_color_level);
    tv1(1).temp_var_ini = expsetup.stim.distractor_color_level_ini;
    tv1(1).temp_var_ini_step = expsetup.stim.distractor_color_level_ini_step;
    tv1(1).name = 'esetup_distractor_color_level';
    tv1(1).temp_var_current = NaN; % This value will be filed up
    tv1(1).update = 'gradual';
end

% Select variables to be modified
if strcmp(expsetup.stim.exp_version_temp, 'distractor train position')
    tv1(1).temp_var_final = nanmean(expsetup.stim.distractor_coord_x);
    tv1(1).temp_var_ini = expsetup.stim.distractor_coord_x_ini;
    tv1(1).temp_var_ini_step = expsetup.stim.distractor_coord_x_ini_step;
    tv1(1).name = 'esetup_distractor_coord_x';
    tv1(1).temp_var_current = NaN; % This value will be filed up
    tv1(1).update = 'gradual';
end



