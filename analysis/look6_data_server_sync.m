% Analysis code
% V1.0 August 29, 2016. Initial version.
% V1.1 November 1, 2016. Made script more modular.

clear all;
clc;
close all;

% Which subject to run?
settings.subjects = 'all'; % 'all' to run all subjects
settings.exp_name = 'look6';

% which setup
% 'dj office', 'plexon'
settings.exp_setup = 'plexon';

% Which sessions to run?
% 'all', 'last', 'before', 'after', 'interval', 'selected'
settings.data_sessions = 'all'; 

eval(sprintf('%s_analysis_settings', settings.exp_name)); % Load general settings


%% Preprocessing: import data into usable format

% Import raw data files of psychtoolbox & eyelink
% This step should be default for most experiments

% Connect to server and import data from it
settings.data_import_from_server = 1;
if settings.data_import_from_server == 1
    settings.import_folders_include{1} = 'data_plexon_raw';
    settings.data_direction = 'upload';
xx%     settings.import_folders_exclude{1} = 'data_plexon_raw';
%     settings.import_folders_exclude{2} = 'data_plexon_mat';
    % Run code
    preprocessing_data_import_server_v22(settings);
end
