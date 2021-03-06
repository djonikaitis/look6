% Prepare each figure

num_fig = [4];


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


%% Figures calculations

for fig1 = 1:numel(num_fig) % Plot figures
    
    settings.figure_current = num_fig(fig1);
    fprintf('\nPreparing figure %s out of %s total for this analysis\n', num2str(fig1), num2str(numel(num_fig))  )
    
    %=============
    % Load data or calculate data?
    new_mat = 1;
    
%     % Over-write spike rates?
%     if fig1==1
%         new_mat = 1;
%     else
%         new_mat = 0;
%     end
    
    % Try to load the data for given analysis
    temp1 = sprintf('_%s_mem_delay.mat', settings.neuron_name);
    [path1, path1_short, file_name] = get_generate_path_v10(settings, 'figures', temp1, settings.session_current);
    if isfile (path1)
        fprintf ('Skippind data binning and loading "%s"\n', file_name)
        data_mat = get_struct_v11(path1);
        mat1_ini = data_mat.mat1_ini;
%         plot_bins_start = data_mat.mat1_plot_bins_start;
%         plot_bins_end = data_mat.mat1_plot_bins_end;
        mat2_ini = data_mat.mat2_ini; % Get long (summary) bins
%         if ~isfield (data_mat, 'mat3_ini')
%             new_mat = 1;
%         else
%             new_mat = 0;
%         end
        clear data_mat;
    end
    
    % Initialize few variables
    settings.int_bins = settings.intervalbins_mem;
    settings.bin_length = settings.bin_length_short;
    S.tconst = S.memory_on - S.first_display;
    
    % Remove bins after memory delay
    a = prctile(S.esetup_memory_delay*1000, 75);
    settings.int_bins(settings.int_bins + settings.bin_length > a) = [];
    
    % plot_bins
    settings.plot_bins=settings.int_bins+settings.bin_length/2;
    
    %===============
    % Select appropriate time interval for spike binning
    
    if new_mat == 1
        
        % Create a matrix with plot_bins
        int_bins = settings.int_bins;
        bin_length = settings.bin_length;
        t_dur = (S.edata_fixation_off - S.edata_memory_on) * 1000;
        
        look6_helper_int_bins_calculator;
        
        %==================
        % Calculate long time bins
        
        plot_bins_start2 = NaN(numel(t_dur), 1); % Output matrix
        plot_bins_end2 = NaN(numel(t_dur), 1); % Output matrix
        
        plot_bins_start2(:,1) = 500;
        plot_bins_end2(:,1) = t_dur;
        
        %====================
        % Calculate bins for orientation selectivity
        if isfield (S, 'edata_background_texture_onset_time') & size(S.edata_background_texture_onset_time, 2) == 1
            t_dur = (S.edata_fixation_off - S.edata_memory_on) * 1000;
        else
            index = ~isnan(S.edata_background_texture_onset_time(:,2));
            t_dur(index) = (S.edata_background_texture_onset_time(index,2) - S.edata_memory_on(index,1)) * 1000;
            index = isnan(S.edata_background_texture_onset_time(:,2));
            t_dur(index) = (S.edata_fixation_off(index,1) - S.edata_memory_on(index,1)) * 1000;
%         else
%             t_dur = (S.edata_fixation_off - S.edata_memory_on) * 1000;
        end
        
        plot_bins_start3 = NaN(numel(t_dur), 1); % Output matrix
        plot_bins_end3 = NaN(numel(t_dur), 1); % Output matrix
        
        plot_bins_start3(:,1) = 250;
        plot_bins_end3(:,1) = t_dur;
        
    end
    
    %============
    % Find spikes
    
    if new_mat==1 % This decides whether to over_write the calculated data matrix
        
        % Spikes and events
        t1_spike = spikes1.ts; % Initialize spike timing
        t1_evt = events_mat.msg_1; % Get timing of the events
        t1_evt = t1_evt + S.tconst; % Reset to time relative to tconst
        
%         % Calculate spiking rates
%         mat1_ini = look6_helper_spike_binning(t1_spike, t1_evt, plot_bins_start, plot_bins_end);
% 
%         % Calculate long time bin rates
%         mat2_ini = look6_helper_spike_binning(t1_spike, t1_evt, plot_bins_start2, plot_bins_end2);
        
        % Calculate long time bin rates
        mat3_ini = look6_helper_spike_binning(t1_spike, t1_evt, plot_bins_start3, plot_bins_end3);
        
        % Save data
        d1 = struct;
        d1.mat1_ini = mat1_ini;
        d1.mat1_plot_bins_start = plot_bins_start;
        d1.mat1_plot_bins_end = plot_bins_end;
        d1.mat1_plot_bins = settings.plot_bins;
        
        d1.mat2_ini = mat2_ini;
        d1.mat2_plot_bins_start = plot_bins_start2;
        d1.mat2_plot_bins_end = plot_bins_end2;
        
        d1.mat3_ini = mat3_ini;
        d1.mat3_plot_bins_start = plot_bins_start3;
        d1.mat3_plot_bins_end = plot_bins_end3;
        save (path1, 'd1')
        clear d1;
        fprintf ('Saved binned data as new file "%s"\n', file_name)
        
    end
    
    
    %% Plot data
    
    
    if settings.figure_current==1
        
        look6_spikes_timecourse_memory_raw_rasters;
        
    end
    
    if settings.figure_current==2
        
        look6_spikes_timecourse_memory_orientation_response;
        
    end
    
    if settings.figure_current==3
        
        look6_spikes_timecourse_memory_scatter;
        
    end
    
    if settings.figure_current==4
        
        look6_spikes_timecourse_memory_task;
        
    end
    
    if settings.figure_current==5
        
        look6_spikes_timecourse_memory_cumulative;
        
    end
    
    if settings.figure_current==6
        
        look6_spikes_timecourse_memory_fits_by_location;
        
    end
    
    
    
end
% End of plotting each figure