% Prepare each figure

num_fig = [1];
file_name_ext = '1';
overwrite_spikes = 0;

%%  Calculate few variables, done only once for all figures

% Save memory angle
temp1 = S.esetup_memory_coord;
[th,radiusdeg] = cart2pol(temp1(:,1), temp1(:,2));
theta = (th*180)/pi;
S.memory_angle = theta;

%=====================
% Initialize a few variables
task_names_used = unique(S.esetup_block_cond);
orientations_used = unique(S.esetup_background_texture_line_angle(:,1));
texture_on_used = [1,0];
memory_angles_used = unique(S.memory_angle);


%% Figures calculations


for fig1 = 1:numel(num_fig)
    
    settings.figure_current = num_fig(fig1);
    fprintf('\nPreparing figure %s out of %s total for this analysis\n', num2str(fig1), num2str(numel(num_fig))  )
    
    % Over-write spike rates?
    if fig1==1
        new_mat = 1;
    else
        new_mat = 0;
    end
    
    % Try to load the data for given analysis
    temp1 = sprintf('_%s_%s.mat', settings.neuron_name, file_name_ext);
    [path1, path1_short, file_name] = get_generate_path_v10(settings, 'figures', temp1, settings.session_current);
    if isfile (path1)
        fprintf ('Skippind data binning and loading "%s"\n', file_name)
        data1 = get_struct_v11(path1);
        new_mat = 0;
    end
    
    
    %===============
    % Select appropriate time interval for spike binning
    if new_mat == 1 || overwrite_spikes == 1
        
        data1 = struct;
        
        %================
        % mat1_ini
        
        % Time relative to which spikes are calculated
        if isfield(S, 'texture_on_1')
            S.tconst = S.texture_on_1 - S.first_display;
        else
            S.tconst = (S.edata_background_texture_onset_time(:,1) - S.edata_first_display(:,1))*1000;
        end
        
        % Create a matrix with plot_bins
        int_bins = settings.intervalbins_tex;
        bin_length = settings.bin_length_long;
        t_dur = NaN(numel(S.START), 1);
        t_dur(1:end) = max(int_bins);
              
        % plot_bins
        plot_bins_center=int_bins+bin_length/2;
        
        look6_helper_int_bins_calculator;
        
        % Spikes and events
        t1_spike = spikes1.ts; % Initialize spike timing
        t1_evt = events_mat.msg_1; % Get timing of the events
        t1_evt = t1_evt + S.tconst; % Reset to time relative to tconst
        
        % Calculate spiking rates
        mat1_ini = look6_helper_spike_binning(t1_spike, t1_evt, plot_bins_start, plot_bins_end);
        
        % Save data
        data1.mat1_ini = mat1_ini;
        data1.mat1_plot_bins_start = plot_bins_start;
        data1.mat1_plot_bins_end = plot_bins_end;
        data1.mat1_plot_bins = plot_bins_center;
        data1.mat1_ini_name = 'data relative to texture 1 onset';
        clear mat1_ini; clear plot_bins_start; clear plot_bins_end;
        
        
        %================
        % mat2_ini
        
        % Time relative to which spikes are calculated
        S.tconst = S.memory_on - S.first_display;
        
        % Create a matrix with plot_bins
        int_bins = settings.intervalbins_mem;
        bin_length = settings.bin_length_long;
        t_dur = NaN(numel(S.START), 1);
        
        % Remove bins after 75% percentile of memory delay
        a = prctile(S.esetup_memory_delay*1000, 75);
        int_bins(int_bins + bin_length > a) = [];
        
        % Experiments with single texture only
        if size(S.edata_background_texture_onset_time,2)==1
            a = (S.edata_fixation_off - S.edata_memory_on) * 1000;
            t_dur = a;
        end
        % Texture 1 only trials / also no texture trials
        if size(S.edata_background_texture_onset_time,2)==2
            a = (S.edata_fixation_off - S.edata_memory_on) * 1000;
            index = isnan(S.edata_background_texture_onset_time(:,2));
            t_dur(index) = a(index);
        end
        % Texture 2 trials
        if size(S.edata_background_texture_onset_time,2)==2
            a = (S.edata_background_texture_onset_time(:,2) - S.edata_memory_on) * 1000;
            index = ~isnan(S.edata_background_texture_onset_time(:,2));
            t_dur(index) = a(index);
        end
        
        % plot_bins
        plot_bins_center=int_bins+bin_length/2;
        
        look6_helper_int_bins_calculator;
        
        % Spikes and events
        t1_spike = spikes1.ts; % Initialize spike timing
        t1_evt = events_mat.msg_1; % Get timing of the events
        t1_evt = t1_evt + S.tconst; % Reset to time relative to tconst
        
        % Calculate spiking rates
        mat1_ini = look6_helper_spike_binning(t1_spike, t1_evt, plot_bins_start, plot_bins_end);
        
        % Save data
        data1.mat2_ini = mat1_ini;
        data1.mat2_plot_bins_start = plot_bins_start;
        data1.mat2_plot_bins_end = plot_bins_end;
        data1.mat2_plot_bins = plot_bins_center;
        data1.mat2_ini_name = 'data relative to cue onset';
        clear mat1_ini; clear plot_bins_start; clear plot_bins_end;
        
        
        %================
        % mat3_ini
        
        % Time relative to which spikes are calculated
        if isfield(S, 'texture_on_2')
            S.tconst = S.texture_on_2 - S.first_display;
        else
            if size(S.edata_background_texture_onset_time,2)==1
                S.tconst = NaN(numel(S.START),1);
            elseif size(S.edata_background_texture_onset_time,2)==2
                S.tconst = (S.edata_background_texture_onset_time(:,2) - S.edata_first_display(:,1))*1000;
            end
        end
        
        % Create a matrix with plot_bins
        int_bins = settings.intervalbins_mem;
        bin_length = settings.bin_length_long;
        t_dur = NaN(numel(S.START), 1);
        
        % Texture 1 only trials / also no texture trials
        if size(S.edata_background_texture_onset_time,2)==2
            a = (S.edata_fixation_off - S.edata_memory_on) * 1000;
            index = isnan(S.edata_background_texture_onset_time(:,2));
            t_dur(index) = a(index);
        end
        % Texture 2 trials
        if size(S.edata_background_texture_onset_time,2)==2
            a = (S.edata_fixation_off - S.edata_background_texture_onset_time(:,2)) * 1000;
            index = ~isnan(S.edata_background_texture_onset_time(:,2));
            t_dur(index) = a(index);
        end
        
        % plot_bins
        plot_bins_center=int_bins+bin_length/2;
        
        look6_helper_int_bins_calculator;
        
        % Spikes and events
        t1_spike = spikes1.ts; % Initialize spike timing
        t1_evt = events_mat.msg_1; % Get timing of the events
        t1_evt = t1_evt + S.tconst; % Reset to time relative to tconst
        
        % Calculate spiking rates
        mat1_ini = look6_helper_spike_binning(t1_spike, t1_evt, plot_bins_start, plot_bins_end);
        
        % Save data
        data1.mat3_ini = mat1_ini;
        data1.mat3_plot_bins_start = plot_bins_start;
        data1.mat3_plot_bins_end = plot_bins_end;
        data1.mat3_plot_bins = plot_bins_center;
        data1.mat3_ini_name = 'data relative to texture 2 onset';
        clear mat1_ini; clear plot_bins_start; clear plot_bins_end;
        
        %========================
        % mat4_ini
        
        % Time relative to which spikes are calculated
        S.tconst = S.fixation_off - S.first_display;
        
        % Create a matrix with plot_bins
        int_bins = settings.intervalbins_mem;
        bin_length = settings.bin_length_long;
        t_dur = NaN(numel(S.START), 1);
        
        % Texture 1 only trials / also no texture trials
        if size(S.edata_background_texture_onset_time,2)==2
            a = (S.edata_fixation_off - S.edata_memory_on) * 1000;
            index = isnan(S.edata_background_texture_onset_time(:,2));
            t_dur(index) = a(index);
        end
        % Texture 2 trials
        if size(S.edata_background_texture_onset_time,2)==2
            a = (S.edata_fixation_off - S.edata_background_texture_onset_time(:,2)) * 1000;
            index = ~isnan(S.edata_background_texture_onset_time(:,2));
            t_dur(index) = a(index);
        end
        
        % plot_bins
        plot_bins_center=int_bins+bin_length/2;
        
        look6_helper_int_bins_calculator;
        
        % Spikes and events
        t1_spike = spikes1.ts; % Initialize spike timing
        t1_evt = events_mat.msg_1; % Get timing of the events
        t1_evt = t1_evt + S.tconst; % Reset to time relative to tconst
        
        % Calculate spiking rates
        mat1_ini = look6_helper_spike_binning(t1_spike, t1_evt, plot_bins_start, plot_bins_end);
        
        % Save data
        data1.mat3_ini = mat1_ini;
        data1.mat3_plot_bins_start = plot_bins_start;
        data1.mat3_plot_bins_end = plot_bins_end;
        data1.mat3_plot_bins = plot_bins_center;
        data1.mat3_ini_name = 'data relative to texture 2 onset';
        clear mat1_ini; clear plot_bins_start; clear plot_bins_end;
        
        
        %================
        % Save data
        save (path1, 'data1')
        fprintf ('Saved binned data as new file "%s"\n', file_name)
        
    end
    
    
    %% Plot data
    
    if settings.figure_current==1
        
        % Figure size
        close all;
        fig_subplot_dim = [1, 4];
        fig_size = [0, 0, fig_subplot_dim(2) * settings.figsize_1col(3), fig_subplot_dim(1) * settings.figsize_1col(4)];
        current_subplot = 0;
        
        look6_spikes_stats_orientations_1b;
        %         look6_spikes_stats_orientations_1a;
        
    end
    
    if settings.figure_current==2
        
        look6_spikes_stats_orientations_2;
        look6_spikes_stats_orientations_3;
        look6_spikes_stats_orientations_4;
        
    end
    

    
    
end
% End of plotting each figure