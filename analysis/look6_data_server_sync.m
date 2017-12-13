% Analysis code
% V1.0 August 29, 2016. Initial version.
% V1.1 November 1, 2016. Made script more modular.

clear all;
clc;
close all;

settings.exp_name = 'look6';

% Which subject to run?
% 'subject id' or 'all' to run all subjects
settings.subjects = 'all'; 

% Which sessions to run?
% 'all', 'last', 'before', 'after', 'interval', 'selected'
settings.data_sessions = 'all'; 

% which setup
% 'dj office', 'plexon', 'edoras'
settings.exp_setup = 'plexon';

eval(sprintf('%s_analysis_settings', settings.exp_name)); % Load general settings


%% Preprocessing: import data into usable format

% Import raw data files of psychtoolbox & eyelink
% This step should be default for most experiments

% Connect to server and import data from it
% Connect to server and import data from it
settings.data_import_from_server = 1;
if settings.data_import_from_server == 1
    settings.data_direction = 'upload';
    settings.import_folders_include = {};
    settings.import_folders_include{1} = 'data_plexon_raw';
%     settings.import_folders_include{1} = 'data_eyelink_edf';
%     settings.import_folders_include{2} = 'data_psychtoolbox';
    settings.import_folders_exclude = {};
%     settings.import_folders_exclude{1} = 'data_plexon_raw';
%     settings.import_folders_exclude{2} = 'data_plexon_mat';
    % Run code
    preprocessing_data_import_server_v22(settings);
end

