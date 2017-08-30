% Combine files, extract saccades
% V1.0 - October 10, 2016. Neurophysiology setup.
% V1.1 - November 4, 2016. Neurophys setup. Small bug fixes.
% V2.0 - February 2, 2017. Psychophysics setup. Creates one file per session
% V1.2 - August 23, 2017. Neurophys setup. Re-written experiment design.
% Converted into function.
%
% Output - saved structures in 'temp2' folder:
% xx_settings
% xx_eye_traces
%
% Donatas Jonikaitis

function  preprocessing_import_files_v12(settings)

p1 = mfilename;
fprintf('\n=========\n')
fprintf('\n Current file:  %s\n', p1)
fprintf('\n=========\n')

% Load all the settings
settings = ini_setup(settings);

% Run pre-processing for each subject
for i_subj = 1:length(settings.subjects)
    
    settings.subject_current = settings.subjects{i_subj};
    
    % Add subject specific path to settings
    settings = convert_path_to_subj(settings, settings.subject_current);
    
    % Eyelink folder is used to determine existence of data files
    session_init = get_dates(settings.path_data_eyelink_edf_subject, settings.subject_current);
    
    % Save session_init data into settings matrix (needed for preprocessing)
    f1_data = fieldnames(session_init);
    for i=1:length(f1_data)
        settings.(f1_data{i}) = session_init.(f1_data{i});
    end
    
    % Which date to analyse (all days or a single day)
    if isfield(settings, 'preprocessing_sessions_used')
        if settings.preprocessing_sessions_used==1
            ind = 1:length(session_init.index_unique_dates);
        elseif settings.preprocessing_sessions_used==2
            ind = find(session_init.index_unique_dates==settings.preprocessing_day_id);
        elseif settings.preprocessing_sessions_used==3
            ind = length(session_init.index_unique_dates);
        end
    else
        fprintf('settings.preprocessing_day_id not defined, analyzing all data available\n')
        ind = 1:length(session_init.index_unique_dates);
    end    
    date_used = session_init.index_unique_dates(ind);
    
    % Analysis for each separate day
    for i_date = 1:length(date_used)
        settings.date_current = date_used(i_date);
        import_data(settings)
    end
     
end
% End of analysis for each subject


y = settings;


%==============
% Initialize settings
%==============

function y = ini_setup(settings)

% Experiment name
if ~isfield (settings, 'exp_name')
    settings.exp_name = input ('Type in experiment name: ', 's');
end

% Subject name
if ~isfield (settings, 'subjects')
    settings.subjects = input ('Type in subject name: ', 's');
end

% Overwriting analysis defaults
if ~isfield(settings, 'overwrite')
    settings.overwrite = 1;
end

% Run settings file:
eval(sprintf('%s_settings', settings.exp_name)); % Load general settings

% Output
y = settings;



%==============
% Determines which dates were recorded
%==============

function y = get_dates(path1, s_name)

% Get index of every folder for a given subject
session_init = get_path_dates_v20(path1, s_name);
if isempty(session_init.index_dates)
    fprintf('\nNo files detected, no data preprocessing done. Directory checked was:\n')
    fprintf('%s\n', path1)
end

y = session_init;


%============
% Add subject name at each path
%============

function y = convert_path_to_subj(settings, s_name)
% Add subject name to the path for simplifying the code

f1 = fieldnames(settings);
ind = strncmp(f1,'path_data_', 10);
for i = 1:numel(ind)
    if ind(i)==1
        v1 = sprintf('%s%s', f1{i}, '_subject');
        settings.(v1) = sprintf('%s%s/', settings.(f1{i}), s_name);
    end
end

y = settings;


%============
% Import files
%============

function import_data(settings)

folder_name = sprintf ('%s%d', settings.subject_current, settings.date_current);
file_name = sprintf ('%s%s', folder_name, '_settings.mat');
path1 = [settings.path_data_temp_2_subject, folder_name, '/', file_name];

if ~exist(path1, 'file') || settings.overwrite==1
    fprintf('\nStarting file conversion and combining for the folder name %s\n', folder_name)
    %===========
    % Main preprocessing function
    preprocessing_psych_eye_combine_v23 (settings, 'stim');
    %===========
else
    fprintf('\nFolder name %s already exists, skipping pre-processing\n', folder_name)
    % Do nothing
end


