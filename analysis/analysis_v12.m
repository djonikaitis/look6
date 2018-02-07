% Analysis code
% V1.0 August 29, 2016. Initial version.
% V1.1 November 1, 2016. Made script more modular.
% V1.11 November 29, 2017. Added exp setup with paths.
% V1.12 February 1, 2018. Can over-write server files

clear all;
clc;
close all;

settings.exp_name = 'look6';

% Which subject to run?
% use subject initials for one subject or 'all' to run all subjects
settings.subjects = 'hb';

% Which sessions to run?
% 'all', 'last', 'before', 'after', 'interval', 'selected'
settings.data_sessions = 'last';

% which setup?
% 'dj office', 'plexon lab', 'edoras', 'plexon office', 'dj laptop'
settings.exp_setup = 'unknown';

eval(sprintf('%s_analysis_settings', settings.exp_name)); % Load general settings


%% Preprocessing: import data into usable format

% Import raw data files of psychtoolbox & eyelink
% This step should be default for most experiments
% Data is not analysed, only combined

do_this_analysis = 1;

if do_this_analysis == 1
    
    % Connect to server and import data from it
    settings.this_analysis = 0;
    if settings.this_analysis == 1
        settings.data_direction = 'download';
        settings.import_folders_include = {};
        settings.import_folders_include{1} = 'data_eyelink_edf';
        settings.import_folders_include{2} = 'data_psychtoolbox';
        settings.import_folders_exclude = {};
        settings.import_folders_exclude{1} = 'data_plexon_raw';
        settings.import_folders_exclude{2} = 'data_plexon_mat';
        % Run code
        preprocessing_data_import_server_v23(settings);
        settings.this_analysis = 0;
    end
    
    % Modify raw settings file for bugs (only bugs are fixed)
    settings.this_analysis = 0;
    if settings.this_analysis == 1
        settings.overwrite=1;
        preprocessing_overwrite_raw_settings_v10(settings);
        settings.this_analysis = 0;
    end
    
    % Import .mat and .edf files into one folder
    settings.this_analysis = 1;
    settings.overwrite = 1;
    if settings.this_analysis == 1
        preprocessing_import_psych_and_edf_v14(settings);
        settings.this_analysis = 0;
    end
    
    % Connect to server and import data from it
    settings.this_analysis = 0;
    if settings.this_analysis == 1
        settings.data_direction = 'upload';
        settings.import_folders_include = {};
        settings.import_folders_include{1} = 'data_temp_1';
        settings.import_folders_include{2} = 'data_temp_2';
        settings.import_folders_include{3} = 'data_psychtoolbox';
        % Run code
        preprocessing_data_import_server_v22(settings);
        settings.this_analysis = 0;
    end
    
end


%% Preprocessing: prepare combined folder, convert eylink data into degrees, do drift correction

do_this_analysis = 0;

if do_this_analysis == 1
    
    % Combine settings and saccades files into one file;
    % reset saccades to degrees of visual angle; do drift correction
    settings.preprocessing_eyelink_conversion = 1;
    if settings.preprocessing_eyelink_conversion == 1
        settings.overwrite = 0; % If 1, runs analysis again even if it was done
        preprocessing_eyelink_conversion_v14(settings);
        settings.this_analysis = 0;
    end
    
    % Remove intermediate pre-processing folders
    settings.preprocessing_remove_folders = 0;
    if settings.preprocessing_remove_folders == 1
        preprocessing_remove_folders_v10(settings, 'path_data_psychtoolbox_subject');
        preprocessing_remove_folders_v10(settings, 'path_data_eyelink_edf_subject');
        preprocessing_remove_folders_v10(settings, 'path_data_temp_1_subject');
        preprocessing_remove_folders_v10(settings, 'path_data_temp_2_subject');
        settings.this_analysis = 0;
    end
    
    % Modify raw settings for compatibility between experiments
    settings.overwrite_all_settings = 1;
    if settings.overwrite_all_settings == 1
        settings.overwrite = 1;
        preprocessing_overwrite_all_settings_v10(settings);
        settings.this_analysis = 0;
    end
    
end


%% Preprocessing: detect and plot saccades

do_this_analysis = 0;

if do_this_analysis == 1
    
    % Detect saccades
    settings.preprocessing_saccade_detection = 1;
    if settings.preprocessing_saccade_detection == 1
        settings.overwrite = 0;
        look6_preprocessing_saccade_detection;
        settings.this_analysis = 0;
    end
    
    % Plot eye traces for manual inspection
    settings.plot_saccades_raw = 0;
    if settings.plot_saccades_raw == 1
        settings.overwrite = 0;
        look6_preprocessing_plot_saccades_raw;
        settings.this_analysis = 0;
    end
    
    
end

%% Behavioural data analysis

do_this_analysis = 0;

if do_this_analysis == 1
    
    % Plot day to day trials accepted/rejected
    settings.analysis_plot_training_performance = 1;
    if settings.analysis_plot_training_performance==1
        settings.overwrite = 1;
        look6_analysis_plot_training_performance;
        settings.this_analysis = 0;
    end
    
    % Plot day to day trials accepted/rejected
    settings.analysis_errors_timecourse = 0;
    if settings.analysis_errors_timecourse==1
        settings.overwrite = 1;
        look6_analysis_plot_last_day_performance;
        settings.this_analysis = 0;
    end
    
    % Plot day to day trials accepted/rejected
    settings.analysis_plot_look_avoid_training = 0;
    if settings.analysis_plot_look_avoid_training==1
        settings.overwrite = 1;
        look6_analysis_plot_look_avoid_training;
        settings.this_analysis = 0;
    end
    
    % Bar graph of look/avoid task performance
    settings.analysis_srt_bar = 0;
    if settings.analysis_srt_bar==1
        settings.overwrite = 1;
        look6_analysis_SRT_bar;
        settings.this_analysis = 0;
    end
    
    % Bar graph of look/avoid task performance
    settings.analysis_srt_positions = 0;
    if settings.analysis_srt_positions==1
        settings.overwrite = 1;
        look6_analysis_SRT_positions;
        settings.this_analysis = 0;
    end
    
end


%% Import plexon files

do_this_analysis = 0;

if do_this_analysis == 1
    
    % Creates folder "plexon_temp_2" which contains all spikes, events etc
    settings.preprocessing_plexon_import = 1;
    settings.overwrite = 0; % If 1, runs analysis again even if it was done
    if settings.preprocessing_plexon_import == 1
        preprocessing_plexon_import_events_and_analog;
        preprocessing_plexon_import_spikes_manually_sorted;
        settings.this_analysis = 0;
    end
    
    % Creates folder "plexon_data_combined" which contains all spikes, events etc
    settings.preprocessing_plexon_spikes_prep = 1;
    settings.overwrite = 0; % If 1, runs analysis again even if it was done
    if settings.preprocessing_plexon_spikes_prep == 1
        look6_preprocessing_plexon_spikes_prep;
        settings.this_analysis = 0;
    end
    
    % Match plexon events with psychtoolbox events. Creates matrix
    % events_matched
    settings.preprocessing_plexon_match_events = 1;
    settings.overwrite = 0; % If 1, runs analysis again even if it was done
    if settings.preprocessing_plexon_match_events == 1
        look6_preprocessing_plexon_match_events;
        look6_preprocessing_plexon_match_events_plot;
        settings.this_analysis = 0;
    end
    
end


%% Neurophysiology data analysis

do_this_analysis = 0;

if do_this_analysis == 1
    
    % Spiking rates for different conditions
    settings.this_analysis = 0;
    settings.overwrite = 1;
    if settings.this_analysis==1
        look6_analysis_spikes_timecourse;
        settings.this_analysis = 0;
    end
    
    % Spiking rates for different conditions
    settings.this_analysis = 0;
    settings.overwrite = 1;
    if settings.this_analysis==1
        look6_analysis_orientation_profile;
        look6_analysis_orientation_timecourse;
        look6_analysis_dual_orientation_timecourse;
        settings.this_analysis = 0;
    end
    
end