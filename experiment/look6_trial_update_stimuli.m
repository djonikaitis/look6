% Create a structure TV which will be used to update stimulus values

%============

tv1 = struct; % Temporary Variable (TV)

% Select variables to be modified
if strcmp(expsetup.stim.exp_version_temp, 'delay')
    tv1(1).temp_var_final = nanmean(expsetup.stim.fixation_maintain_duration);
    tv1(1).temp_var_ini = expsetup.stim.fixation_maintain_duration_ini;
    tv1(1).temp_var_ini_step = expsetup.stim.fixation_maintain_duration_ini_step;
    tv1(1).name = 'esetup_fixation_maintain_duration';
    tv1(1).temp_var_current = NaN;
    tv1(2).temp_var_final = nanmean(expsetup.stim.memory_delay_duration);
    tv1(2).temp_var_ini = expsetup.stim.memory_delay_duration_ini;
    tv1(2).temp_var_ini_step = expsetup.stim.memory_delay_duration_ini_step;
    tv1(2).temp_var_current = NaN;
    tv1(2).name = 'esetup_memory_delay';
end

% Select variables to be modified
if strcmp(expsetup.stim.exp_version_temp, 'luminance change')
    tv1(1).temp_var_final = nanmean(expsetup.stim.st2_color_level);
    tv1(1).temp_var_ini = expsetup.stim.st2_color_level_ini;
    tv1(1).temp_var_ini_step = expsetup.stim.st2_color_level_ini_step;
    tv1(1).name = 'esetup_st2_color_level';
    tv1(1).temp_var_current = NaN;
end

% Select variables to be modified
if strcmp(expsetup.stim.exp_version_temp, 'luminance equal')
    tv1 = struct;
end

% Select variables to be modified
if strcmp(expsetup.stim.exp_version_temp, 'final')
    tv1 = struct;
end
