% Prepare each figure

num_fig = 2;


%%  Calculate few variables, done only once for all figures

% Save memory angle
temp1 = S.esetup_memory_coord;
[th,radiusdeg] = cart2pol(temp1(:,1), temp1(:,2));
theta = (th*180)/pi;
S.memory_angle = theta;


%% Figures calculations

for fig1 = 1:numel(num_fig) % Plot figures
    
    settings.figure_current = num_fig(fig1);
    fprintf('\nPreparing figure %s out of %s total for this analysis\n', num2str(fig1), num2str(numel(num_fig))  )
    
    %=============
    % Load data or calculate data?
    
    % Over-write spike rates?
    if fig1==1
        new_mat = 1;
    else
        new_mat = 0;
    end
    
    % Try to load the data for given analysis
    temp1 = sprintf('_%s_mem_delay.mat', settings.neuron_name);
    [path1, path1_short, file_name] = get_generate_path_v10(settings, 'figures', temp1, settings.session_current);
    if isfile (path1)
        fprintf ('Skippind data binning and loading "%s"\n', file_name)
        data_mat = get_struct_v11(path1);
        mat1_ini = data_mat.mat1_ini;
        plot_bins_start = data_mat.plot_bins_start;
        plot_bins_end = data_mat.plot_bins_end;
        new_mat = 0;
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
        
        % Save data
        d1 = struct;
        d1.mat1_ini = mat1_ini;
        d1.plot_bins_start = plot_bins_start;
        d1.plot_bins_end = plot_bins_end;
        d1.plot_bins = settings.plot_bins;
        save (path1, 'd1')
        
    end
    
    
    %% Plot data
    
    
    if settings.figure_current==1
        
        look6_spikes_memory_timecourse_raw_rasters;
        
    end
    
    if settings.figure_current==2
        
        look6_spikes_memory_timecourse_loc_orientation_interaction;
        
    end
    
%     if settings.figure_current==3
%         
%         look6_spikes_memory_timecourse_task;
%         
%     end
    
    if settings.figure_current==4
        
        look6_spikes_memory_timecourse_task;
        
    end
    
    
end
% End of plotting each figure