% Prepare each figure

num_fig = 4;


%%  Calculate few variables, done only once for all figures

% Save memory angle
temp1 = S.esetup_memory_coord;
[th,radiusdeg] = cart2pol(temp1(:,1), temp1(:,2));
theta = (th*180)/pi;
S.memory_angle = theta;

% Reset memory arc relative to RF center (assumes
% RF is in left lower visual field) at the moment.
% Done for each session separately.
S.memory_angle_relative = NaN(numel(S.session), 1);
for i = 1:max(S.session)
    index = S.session == i;
    a = unique(S.memory_angle(index));
    a = min(a);
    S.memory_angle_relative(index) = S.memory_angle(index) - a;
end
% Round off
S.memory_angle_relative = round(S.memory_angle_relative, 1);
% Reset to range -180:180
ind = S.memory_angle_relative<-180;
S.memory_angle_relative(ind)=S.memory_angle_relative(ind)+360;
ind = S.memory_angle_relative>=180;
S.memory_angle_relative(ind)=S.memory_angle_relative(ind)-360;

%=====================
% Initialize a few variables
task_names_used = unique(S.esetup_block_cond);
orientations_used = unique(S.esetup_background_texture_line_angle(:,1));
texture_on_used = [1,0];
memory_angles_used = unique(S.memory_angle);
memory_angles_relative_used = unique(S.memory_angle_relative);



%% Do figures

for fig1 = 1:numel(num_fig) % Plot figures
    
    settings.figure_current = num_fig(fig1);
    fprintf('\nPreparing figure %s out of %s total for this analysis\n', num2str(fig1), num2str(numel(num_fig)))
    
    %=============
    % Load data or calculate data?
    
    % Over-write spike rates?
    if fig1==1
        new_mat = 1;
    else
        new_mat = 0;
    end
    
    % Try to load the data for given analysis
    temp1 = sprintf('_%s_tex.mat', settings.neuron_name);
    [path1, path1_short, file_name] = get_generate_path_v10(settings, 'figures', temp1, settings.session_current);
    if isfile (path1)
        fprintf ('Skippind data binning and loading "%s"\n', file_name)
        data_mat = get_struct_v11(path1);
        mat1_ini = data_mat.mat1_ini;
        plot_bins_start = data_mat.plot_bins_start;
        plot_bins_end = data_mat.plot_bins_end;
        mat2_ini = data_mat.mat2_ini; % Get long (summary) bins
        new_mat = 0;
        clear data_mat;
    end
    
    % Initialize few variables
    settings.int_bins = settings.intervalbins_tex;
    settings.bin_length = settings.bin_length_short;
    if isfield(S, 'texture_on_1')
        S.tconst = S.texture_on_1 - S.first_display;
    else
        S.tconst = (S.edata_background_texture_onset_time(:,1) - S.edata_first_display(:,1))*1000;
    end
    
    % plot_bins
    settings.plot_bins=settings.int_bins+settings.bin_length/2;
    
    %===============
    % Select appropriate time interval for spike binning
    
    if new_mat == 1
        
        %================
        % Calculate short time bins
        
        % Create a matrix with plot_bins
        int_bins = settings.int_bins;
        bin_length = settings.bin_length;
        t_dur = NaN(numel(S.START), 1);
        t_dur(1:end) = max(settings.int_bins);
        
        look6_helper_int_bins_calculator;
        
        %==================
        % Calculate long time bins
        
        plot_bins_start2 = NaN(numel(t_dur), 1); % Output matrix
        plot_bins_end2 = NaN(numel(t_dur), 1); % Output matrix
        
        plot_bins_start2(:,1) = 100;
        plot_bins_end2(:,1) = t_dur;
        
    end
    
    %============
    % Find spikes
    
    if new_mat==1 % This decides whether to over_write the calculated data matrix
        
        % Spikes and events
        t1_spike = spikes1.ts; % Initialize spike timing
        t1_evt = events_mat.msg_1; % Get timing of the events
        t1_evt = t1_evt + S.tconst; % Reset to time relative to tconst
        
        % Calculate spiking rates
        mat1_ini = look6_helper_spike_binning(t1_spike, t1_evt, plot_bins_start, plot_bins_end);
        
        % Calculate long time bin rates
        mat2_ini = look6_helper_spike_binning(t1_spike, t1_evt, plot_bins_start2, plot_bins_end2);
        
        % Save data
        d1 = struct;
        d1.mat1_ini = mat1_ini;
        d1.plot_bins_start = plot_bins_start;
        d1.plot_bins_end = plot_bins_end;
        d1.plot_bins = settings.plot_bins;
        d1.mat2_ini = mat2_ini;
        save (path1, 'd1')
        clear d1;
        fprintf ('Saved binned data as new file "%s"\n', file_name)
        
    end
    
    %% Plot data
    
    if settings.figure_current ==1
        
        look6_spikes_timecourse_orientation_raw_rasters;
        
    end
        
    if settings.figure_current==2
        
        look6_spikes_timecourse_orientation_all_orientations;
        
    end
    
    if settings.figure_current==3
        
        look6_spikes_timecourse_orientation_texture_on_response;
        
    end
    
    if settings.figure_current==4
        
        look6_spikes_timecourse_orientation_selectivity;
        
    end
    
    if settings.figure_current==5
        
        look6_spikes_timecourse_orientation_fits_by_location;
        
    end
    
end
% End of plotting each figure

    
    
    
    
