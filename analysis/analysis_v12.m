% Analysis code
% V1.0 August 29, 2016. Initial version.
% V1.1 November 1, 2016. Made script more modular.
% V1.11 November 29, 2017. Added exp setup with paths.
% V1.12 February 1, 2018. Can over-write server files

%% All settings part

clear all;
clc;
close all;

settings.exp_name = 'look6';

% Which subject to run?
% use subject initials for one subject or 'all' to run all subjects
settings.subjects = 'aq';

% Which sessions to run?
% 'all', 'last', 'before', 'after', 'interval', 'selected'
settings.data_sessions = 'selected';

% which setup?
% 'unknown', 'dj office', 'plexon lab', 'edoras', 'plexon office', 'dj laptop'
settings.exp_setup = 'unknown';

eval(sprintf('%s_analysis_settings', settings.exp_name)); % Load general settings

% Select analysis to run:
analysis_edf_and_psych_data_import = 0;
analysis_eyelink_drift_and_conversion = 0;
analysis_detect_saccades = 0;
analysis_behaviour_srt_plots = 0;
analysis_import_plexon_files = 0;
analysis_spikes_timecourse = 1;


%% Preprocessing: import data into usable format

% Import raw data files of psychtoolbox & eyelink
% This step should be default for most experiments
% Data is not analysed, only combined

if analysis_edf_and_psych_data_import == 1
    
    % Connect to server and import data from it
    settings.this_analysis = 1;
    if settings.this_analysis == 1
        settings.server_overwrite = 0;
        settings.data_direction = 'download';
        settings.server_folders_include = {};
%         settings.server_folders_include{1} = 'data_eyelink_edf';
%         settings.server_folders_include{2} = 'data_psychtoolbox';
        settings.server_folders_include{1} = 'data_plexon_temp_2';
        % Run code
        preprocessing_data_import_server_v23(settings);
    end
    
    % Modify raw settings file for bugs (only bugs are fixed)
    settings.this_analysis = 1;
    if settings.this_analysis == 1
        settings.overwrite = 0;
        preprocessing_overwrite_raw_settings_v11(settings);
    end
    
    % Import .mat and .edf files into one folder
    settings.this_analysis = 1;
    settings.overwrite = 0;
    if settings.this_analysis == 1
        preprocessing_import_psych_and_edf_v14(settings);
    end
    
end


%% Preprocessing: prepare combined folder, convert eylink data into degrees, do drift correction

if analysis_eyelink_drift_and_conversion == 1
    
    % Combine settings and saccades files into one file;
    % reset saccades to degrees of visual angle; do drift correction
    settings.this_analysis = 1;
    if settings.this_analysis == 1
        settings.overwrite = 0; % If 1, runs analysis again even if it was done
        preprocessing_eyelink_conversion_v15(settings);
    end
    
    % Modify raw settings for compatibility between experiments
    settings.this_analysis = 1;
    if settings.this_analysis == 1
        settings.overwrite = 0;
        preprocessing_overwrite_all_settings_v11(settings);
    end
    
end


%% Clear out some folders

% run_this_section_of_analysis = 0;
% 
% if run_this_section_of_analysis == 1
%     
%     % Remove intermediate pre-processing folders
%     settings.this_analysis = 0;
%     if settings.this_analysis == 1
%         preprocessing_remove_folders_v10(settings, 'path_data_psychtoolbox_subject');
%         preprocessing_remove_folders_v10(settings, 'path_data_eyelink_edf_subject');
%         preprocessing_remove_folders_v10(settings, 'path_data_temp_1_subject');
%         preprocessing_remove_folders_v10(settings, 'path_data_temp_2_subject');
%         settings.this_analysis = 0;
%     end
% end


%% Preprocessing: detect and plot saccades


if analysis_detect_saccades == 1
    
    % Detect saccades
    settings.this_analysis = 1;
    if settings.this_analysis == 1
        settings.overwrite = 0;
        look6_preprocessing_saccade_detection;
    end
    
    % Plot eye traces for manual inspection
    settings.this_analysis = 0;
    if settings.this_analysis == 1
        settings.overwrite = 0;
        look6_preprocessing_plot_saccades_raw;
    end
    
end

%% Behavioural data analysis

settings.this_analysis = 1;
settings.overwrite = 0;
if settings.this_analysis == 1
    settings.function_name = 'look6_preprocessing_checking_data_variables';
    look6_analysis_template_behaviour;
end
    
if analysis_behaviour_srt_plots == 1
    
    settings.this_analysis = 0;
    settings.overwrite = 1;
    if settings.this_analysis==1
        settings.temp1_data_folder = 'data_combined_plexon';
        settings.function_name = 'look6_behaviour_variables_check';
        look6_analysis_template_behaviour;
    end

    settings.this_analysis = 0;
    settings.overwrite = 1;
    if settings.this_analysis==1
        settings.function_name = 'look6_behaviour_training_over_time';
        look6_analysis_template_behaviour;
    end
    
    settings.this_analysis = 0;
    settings.overwrite = 1;
    if settings.this_analysis==1
        settings.function_name = 'look6_behaviour_look_avoid_training';
        look6_analysis_template_behaviour;
    end
   
    settings.this_analysis = 1;
    settings.overwrite = 1;
    if settings.this_analysis==1
        settings.function_name = 'look6_behaviour_SRT_bar';
        look6_analysis_template_behaviour;
    end
    
%     settings.this_analysis = 1;
%     settings.overwrite = 1;
%     if settings.this_analysis==1
%         settings.function_name = 'look6_behaviour_SRT_position';
%         look6_analysis_template_behaviour;
%     end

    
end


%% Import plexon files


if analysis_import_plexon_files == 1
    
    % Creates folder "plexon_temp_2" which contains all spikes, events etc
    settings.this_analysis = 1;
    settings.overwrite = 0; % If 1, runs analysis again even if it was done
    if settings.this_analysis == 1
        preprocessing_plexon_import_events_and_analog;
        preprocessing_plexon_import_spikes_manually_sorted;
    end
    
    % Creates folder "plexon_data_combined" which contains all spikes, events etc
    settings.this_analysis = 1;
    settings.overwrite = 1; % If 1, runs analysis again even if it was done
    if settings.this_analysis == 1
        look6_preprocessing_plexon_spikes_prep;
    end
    
    % Match plexon events with psychtoolbox events. Creates matrix
    % events_matched
    settings.this_analysis = 1;
    settings.overwrite = 1; % If 1, runs analysis again even if it was done
    if settings.this_analysis == 1
        look6_preprocessing_plexon_match_events;
        look6_preprocessing_plexon_match_events_plot;
    end
    
end


%% Neurophysiology data analysis


if analysis_spikes_timecourse == 1
    
%     settings.preselected_channels_used = 24; % For debugging
    
    settings.this_analysis = 1;
    settings.overwrite = 1;
    if settings.this_analysis==1
        settings.temp1_data_folder = 'data_combined_plexon';
        settings.function_name = 'look6_spikes_timecourse_memory';
        look6_analysis_template_individual_units;
    end
    
    settings.this_analysis = 0;
    settings.overwrite = 1;
    if settings.this_analysis==1
        settings.temp1_data_folder = 'data_combined_plexon';
        settings.function_name = 'look6_spikes_timecourse_orientation';
        look6_analysis_template_individual_units;
    end
    
    settings.this_analysis = 0;
    settings.overwrite = 1;
    if settings.this_analysis==1
        settings.temp1_data_folder = 'data_combined_plexon';
        settings.function_name = 'look6_spikes_timecourse_precue';
        look6_analysis_template_individual_units;
    end
    
    %     settings.this_analysis = 0;
%     settings.overwrite = 1;
%     if settings.this_analysis==1
%         settings.temp1_data_folder = 'data_combined_plexon';
%         settings.function_name = 'look6_spikes_dual_orientation_timecourse';
%         look6_analysis_template_individual_units;
%     end
    
%     settings.this_analysis = 0;
%     settings.overwrite = 1;
%     if settings.this_analysis==1
%         settings.temp1_data_folder = 'data_combined_plexon';
%         settings.function_name = 'look6_spikes_summary_scatter';
%         look6_analysis_template_individual_units;
%     end
    
end