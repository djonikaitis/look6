% Analysis code
% V1.0 August 29, 2016. Initial version.
% V1.1 November 1, 2016. Made script more modular.
%

clear all;
clc;
close all;

settings.subjects = 'hb'; % Subject name
settings.exp_name = 'look6'; % Epxeriment name
% eval(sprintf('%s_settings', settings.exp_name)); % Load general settings


%% Preprocessing: import data into usable format

% Import raw data files of psychtoolbox, eyelink and plexon
% This step should be default for most experiments

% Creates a folders "temp1" with edf data converted to .asc and 
% "temp2" which contains matched psychtoolbox and
% eylinkd data. This data is still raw.
settings.preprocessing_import_files = 1;
settings.overwrite = 0; % If 1, runs analysis again even if it was done 
if settings.preprocessing_import_files == 1
    preprocessing_import_files_v12(settings);
end

% Creates a folder "temp3". Combines settings and saccades files into one file; 
% reset saccades to degrees of visual angle; do drift correction
% This file needs to be updated for each experiment
settings.preprocessing_eyelink_conversion = 1;
settings.overwrite = 1  ; % If 1, runs analysis again even if it was done 
if settings.preprocessing_eyelink_conversion == 1
    preprocessing_eyelink_conversion_v11(settings);
end

 
% % % Creates folder "combined_plexon" which contains all spikes, events etc
% % settings.preprocessing_plexon_import = 0;
% % settings.overwrite = 1; % If 1, runs analysis again even if it was done 
% % if settings.preprocessing_plexon_import == 1
% %     look5_preprocessing_plexon_import;
% % end
% 
% % % Match plexon events with psychtoolbox events. Creates matrix
% % % events_matched
% % settings.preprocessing_plexon_match_events = 0;
% % settings.overwrite = 1; % If 1, runs analysis again even if it was done 
% % if settings.preprocessing_plexon_match_events == 1
% %     look5_preprocessing_plexon_match_events;
% %     look5_preprocessing_plexon_match_plot;
% % end
% % 
% % % Export plexon spiking data into processed matrices. Reset time of spikes to match
% % % psychtoolbox timing. 
% % settings.preprocessing_plexon_spikes = 0;
% % settings.overwrite = 1; % If 1, runs analysis again even if it was done 
% % if settings.preprocessing_plexon_spikes == 1
% %     look5_preprocessing_plexon_spikes;
% % end
% 
% 
% %% Preprocessing: saccades
% 
% % % Detect saccades
% % settings.overwrite = 0;
% % settings.preprocessing_saccade_detection = 1;
% % if settings.preprocessing_saccade_detection == 1
% %     look5_preprocessing_saccade_detection;
% % end
% 
% 
% % % % Plot grouped eye traces to detect errors in algorithm
% % % settings.plot_saccade_detection = 1;
% % % if settings.plot_saccade_detection == 1;
% % %     look5_plot_saccade_detection;
% % % end
% % 
% % % % Plot eye traces for manual inspection
% % % settings.plot_saccades_raw = 0;
% % % if settings.plot_saccades_raw == 0
% % %     look5_plot_saccades_raw;
% % % end
% % 
% % 
% % 
% % %% Data analysis
% % 
% % % Plot day to day trials accepted/rejected
% % settings.analysis_errors_timecourse = 1;
% % settings.overwrite = 1;
% % if settings.analysis_errors_timecourse==1
% %     look5_analysis_errors_timecourse;
% % end
% 
% % % Spiking rates for different conditions
% % settings.analysis_spikes_timecourse = 0;
% % settings.overwrite = 1;
% % if settings.analysis_spikes_timecourse==1
% %     look5_analysis_spikes_timecourse;
% % end
% 
% % % Spiking rates for different conditions
% % settings.analysis_orientation_profile = 1;
% % settings.overwrite = 1;
% % if settings.analysis_orientation_profile==1
% %     look5_analysis_orientation_profile;
% % end
% % 
% % 
% % 
