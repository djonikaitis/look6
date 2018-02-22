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
settings.data_sessions = 'selected';

% which setup?
% 'dj office', 'plexon lab', 'edoras', 'plexon office', 'dj laptop'
settings.exp_setup = 'undefined';

eval(sprintf('%s_analysis_settings', settings.exp_name)); % Load general settings


%% Preprocessing: import data into usable format

% Import raw data files of psychtoolbox & eyelink
% This step should be default for most experiments
% Data is not analysed, only combined

run_this_section_of_analysis = 0;

if run_this_section_of_analysis == 1
    
    % Connect to server and import data from it
    settings.this_analysis = 0;
    if settings.this_analysis == 1
        settings.server_overwrite = 0;
        settings.data_direction = 'download';
        settings.server_folders_include = {};
        settings.server_folders_include{1} = 'data_eyelink_edf';
        settings.server_folders_include{2} = 'data_psychtoolbox';
        % Run code
        preprocessing_data_import_server_v23(settings);
    end
    
    % Modify raw settings file for bugs (only bugs are fixed)
    settings.this_analysis = 1;
    if settings.this_analysis == 1
        settings.overwrite = 1;
        preprocessing_overwrite_raw_settings_v11(settings);
    end
    
    % Import .mat and .edf files into one folder
    settings.this_analysis = 1;
    settings.overwrite = 1;
    if settings.this_analysis == 1
        preprocessing_import_psych_and_edf_v14(settings);
    end
    
end


%% Preprocessing: prepare combined folder, convert eylink data into degrees, do drift correction

run_this_section_of_analysis = 0;

if run_this_section_of_analysis == 1
    
    % Combine settings and saccades files into one file;
    % reset saccades to degrees of visual angle; do drift correction
    settings.this_analysis = 1;
    if settings.this_analysis == 1
        settings.overwrite = 1; % If 1, runs analysis again even if it was done
        preprocessing_eyelink_conversion_v15(settings);
    end
    
    % Modify raw settings for compatibility between experiments
    settings.this_analysis = 1;
    if settings.this_analysis == 1
        settings.overwrite = 1;
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

run_this_section_of_analysis = 0;

if run_this_section_of_analysis == 1
    
    % Detect saccades
    settings.this_analysis = 1;
    if settings.this_analysis == 1
        settings.overwrite = 1;
        look6_preprocessing_saccade_detection;
    end
    
    % Plot eye traces for manual inspection
    settings.this_analysis = 1;
    if settings.this_analysis == 1
        settings.overwrite = 1;
        look6_preprocessing_plot_saccades_raw;
    end
    
end

%% Behavioural data analysis

    
run_this_section_of_analysis = 1;

if run_this_section_of_analysis == 1
    
    % Plot day to day trials accepted/rejected
    settings.this_analysis = 1;
    settings.overwrite = 1;
    if settings.this_analysis==1
        settings.function_name = 'look6_behaviour_daily_performance';
        look6_analysis_template_behaviour;
    end
    
%     % Plot day to day trials accepted/rejected
%     settings.this_analysis = 1;
%     if settings.this_analysis==1
%         settings.overwrite = 1;
%         look6_analysis_plot_training_performance;
%     end
%   
% 
%     % Plot day to day trials accepted/rejected
%     settings.this_analysis = 1;
%     if settings.this_analysis==1
%         settings.overwrite = 1;
%         look6_analysis_plot_look_avoid_training;
%     end
%     
%     % Bar graph of look/avoid task performance
%     settings.this_analysis = 1;
%     if settings.this_analysis==1
%         settings.overwrite = 1;
%         look6_analysis_SRT_bar;
%     end
%     
%     % Line graph of look/avoid task performance
%     settings.this_analysis = 0;
%     if settings.this_analysis==1
%         settings.overwrite = 1;
%         look6_analysis_SRT_position;
%     end
    
end


%% Import plexon files

run_this_section_of_analysis = 0;

if run_this_section_of_analysis == 1
    
%     % Creates folder "plexon_temp_2" which contains all spikes, events etc
%     settings.preprocessing_plexon_import = 1;
%     settings.overwrite = 0; % If 1, runs analysis again even if it was done
%     if settings.preprocessing_plexon_import == 1
%         preprocessing_plexon_import_events_and_analog;
%         preprocessing_plexon_import_spikes_manually_sorted;
%         settings.this_analysis = 0;
%     end
%     
%     % Creates folder "plexon_data_combined" which contains all spikes, events etc
%     settings.preprocessing_plexon_spikes_prep = 1;
%     settings.overwrite = 0; % If 1, runs analysis again even if it was done
%     if settings.preprocessing_plexon_spikes_prep == 1
%         look6_preprocessing_plexon_spikes_prep;
%         settings.this_analysis = 0;
%     end
%     
%     % Match plexon events with psychtoolbox events. Creates matrix
%     % events_matched
%     settings.preprocessing_plexon_match_events = 1;
%     settings.overwrite = 0; % If 1, runs analysis again even if it was done
%     if settings.preprocessing_plexon_match_events == 1
%         look6_preprocessing_plexon_match_events;
%         look6_preprocessing_plexon_match_events_plot;
%         settings.this_analysis = 0;
%     end
    
end


%% Neurophysiology data analysis

run_this_section_of_analysis = 0;

if run_this_section_of_analysis == 1
    
    settings.this_analysis = 1;
    settings.overwrite = 1;
    if settings.this_analysis==1
        settings.function_name = 'look6_spikes_task_timecourse';
        look6_analysis_template_individual_units;
    end
    
    settings.this_analysis = 1;
    settings.overwrite = 1;
    if settings.this_analysis==1
        settings.function_name = 'look6_spikes_orientation_timecourse';
        look6_analysis_template_individual_units;
    end
    
    %         look6_analysis_orientation_profile;
    %         look6_analysis_dual_orientation_timecourse;
    
end