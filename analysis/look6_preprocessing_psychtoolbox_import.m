% Combine files, extract saccades, extract spikes
% V1.0 - October 10, 2016
% V1.1 - November 4, 2016. Small bug fixes.
% V1.2 - August 23, 2017. Updated to new experimental design.
% Donatas Jonikaitis

% clear all;
clc; 
close all;


%% Initial setup

% Loading the files needed
if ~exist('settings', 'var')
    settings = struct;
end

% Experiment name
if ~isfield (settings, 'exp_name')
    settings.exp_name = input ('Type in experiment name: ', 's');
end

% Default subject number: all subjects
if ~isfield (settings, 'subjects')
    sN1 = 'all'; % Subject name
end

% Overwriting analysis defaults
if ~isfield(settings, 'overwrite')
    settings.overwrite = 1;
end

% Run settings file:
eval(sprintf('%s_settings', settings.exp_name)); % Load general settings



%% Run preprocessing

for i=1:length(settings.subjects)
    
    settings.subject_name=settings.subjects{i}; % Select curent subject
    
    % Initialize subject specific folders where data is stored
    for i=1:length(settings.path_spec_names)
        v1 = ['path_', settings.path_spec_names{i}];
        settings.(v1) = sprintf ('%s%s/', settings.path_spec_folder{i}, settings.subject_name);
    end
    
    % Get index of every folder for a given subject
    p1 = settings.path_data_eyelink_edf;
    session_init = get_path_dates_v20(p1, settings.subject_name);
    if isempty(session_init.index_dates)
        fprintf('------------------\n');
        fprintf('\nNo psychtoolbox files detected, no data preprocessing done. Directory checked was:\n')
        fprintf('%s\n', p1)
        fprintf('------------------\n');
    end
    
%     % Save session_init matrix into settings matrix
%     % This part is necessary for preprocessing to run
%     f1_data = fieldnames(session_init);
%     for i=1:length(f1_data)
%         settings.(f1_data{i})= session_init.(f1_data{i});
%     end
    
%     % Which date to analyse (all days or a single day)
%     if settings.preprocessing_sessions_used==1
%         ind = [1:length(session_init.index_unique_dates)];
%     elseif settings.preprocessing_sessions_used==2
%         ind = find(session_init.index_unique_dates==settings.preprocessing_day_id);
%     elseif settings.preprocessing_sessions_used==3
%         ind = length(session_init.index_unique_dates);
%     end
%     date_index = session_init.index_unique_dates(ind);
%     
    
%     for i_date = 1:length(date_index)
%         
%         %============
%         % Run basic pre-processing
%                 
%         folder_name = [settings.subject_name, num2str(date_index(i_date))];
%         path1 = [settings.path_data_combined, folder_name, '/', folder_name, '_settings.mat'];
%         if ~exist(path1, 'file') || settings.overwrite==1
%             fprintf('------------------\n')
%             fprintf('\nStarting file conversion and combining for the folder name %s\n', folder_name)
%             %===========
%             % Main preprocessing function
%             preprocessing_psychtoolbox_v22 (settings, date_index(i_date), 'stim.expmatrix', 'stim.trialmatrix', 'stim.refresh_rate_mat');
%             %===========
%         else
%             fprintf('------------------\n')
%             fprintf('\nFolder name %s already exists, skipping pre-processing\n', folder_name)
%             % Do nothing
%         end
% 
%     end
%     % Pre-processing for each day is over
    
end
% Pre-processng for each subject is over
