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

% which setup?
% 'dj office', 'plexon lab', 'edoras', 'plexon office', 'dj laptop'
settings.exp_setup = 'edoras';

eval(sprintf('%s_analysis_settings', settings.exp_name)); % Load general settings


%% Preprocessing: import data into usable format

% Import raw data files of psychtoolbox & eyelink
% This step should be default for most experiments

% Connect to server and import data from it
settings.this_analysis = 0;
if settings.this_analysis == 1
    settings.server_overwrite = 0;
    settings.data_direction = 'download';
    settings.server_folders_include = {};
    settings.server_folders_include{1} = 'data_eyelink_edf';
    settings.server_folders_include{2} = 'data_psychtoolbox';
    settings.import_folders_exclude = {};
    % Run code
    preprocessing_data_import_server_v23(settings);
    settings.this_analysis = 0;
end

