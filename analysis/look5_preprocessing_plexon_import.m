% Extract plexon events, plexon spikes and plexon analog signal. 
% Requires to modify this file accoriding to data storage properties
% V1.0 - October 30, 2016
% Donatas Jonikaitis

% clear all; 
% clc;
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
    p1 = settings.path_data_plexon_raw;
    session_init = get_path_dates_v20(p1, settings.subject_name);
    if isempty(session_init.index_dates)
        fprintf('------------------\n');
        fprintf('\nNo plexon files detected, no preprocessing done. Directory checked was:\n')
        fprintf('%s\n', p1)
        fprintf('------------------\n');
    end
    
    % Save session_init matrix into settings matrix
    % This part is necessary for preprocessing to run
    f1_data = fieldnames(session_init);
    for i=1:length(f1_data)
        settings.(f1_data{i})= session_init.(f1_data{i});
    end
    
    % Which date to analyse (all days or a single day)
    if settings.preprocessing_sessions_used==1
        ind = [1:length(session_init.index_unique_dates)];
    elseif settings.preprocessing_sessions_used==2
        ind = find(session_init.index_unique_dates==settings.preprocessing_day_id);
    elseif settings.preprocessing_sessions_used==3
        ind = length(session_init.index_unique_dates);
    end
    date_index = session_init.index_unique_dates(ind); % Only subset of dates selected
    
    
    % Run analysis for every single day
    for i_date = 1:length(date_index)
        
        
        % Current folder to be analysed (raw date, with session index)
        i1 = find(date_index(i_date)==settings.index_dates);
        folder_name_raw = settings.index_directory{i1};
        
        clear var1; clear var2; clear var3;
        
        fprintf('------------------\n');
        
        %===========
        % Convert pl2 file to mat file with all spikes
        %===========
        
        path_in = settings.path_data_plexon_raw;
        path_out = settings.path_data_plexon_mat;
        file_name_in = [folder_name_raw,'_sorted'];
        file_name_out = [folder_name_raw,'_spikes'];
        path_plexon_pl2 = sprintf('%s%s/%s.pl2', path_in, folder_name_raw, file_name_in); % Path to raw plexon file
        path_plexon_mat = sprintf('%s%s/%s.mat', path_out, folder_name_raw, file_name_out); % Path to output of extracted spikes matrix
        
        % Check whether to remove directory or create one
        if settings.overwrite==1
            dir_temp = [path_out, folder_name_raw];
            if isdir(dir_temp)
            rmdir(dir_temp, 's');
            end
        end
            
        if ~exist (path_plexon_mat,'file')
            if ~exist (path_plexon_pl2, 'file')
                fprintf('%s.pl2 does not exist, either no recording or incorrect file names provided\n', file_name_in);
            elseif exist (path_plexon_pl2, 'file') && ~exist (path_plexon_mat,'file') % If asc file doesn't exist - do the conversion
                if ~exist (path_plexon_mat,'file')
                    %=====
                    dir_temp = [path_out, folder_name_raw];
                    if ~isdir(dir_temp);
                        mkdir(dir_temp);
                    end
                    fprintf('Extracting spikes from %s.pl2\n', file_name_in);
                    plexon_spikes_v11(path_plexon_pl2, path_plexon_mat); % Script doing import of pl2 file
                    
                    %======
                    if exist(path_plexon_mat, 'file')
                        varx = load(path_plexon_mat);
                        % Extract a structure which is in the var1
                        f1 = fieldnames(varx);
                        if length(f1)==1
                            var1 = varx.(f1{1});
                        end
                    end
                    %=====
                end
            end
        else
            fprintf('File %s already exists, skipping spike extraction\n', file_name_out)
        end
        
        
        % Load spikes file in in order to combine it later
        if ~exist('var1', 'var')
            var1 = struct; % Initialize empty structur
        end

        
        %===========
        % Extract all events from pl2 file 
        %===========
        
        path_in = settings.path_data_plexon_raw;
        path_out = settings.path_data_plexon_mat;
        file_name_in = [folder_name_raw,];
        file_name_out = [folder_name_raw,'_events'];
        path_plexon_pl2 = sprintf('%s%s/%s.pl2', path_in, folder_name_raw, file_name_in); % Path to raw plexon file
        path_plexon_mat = sprintf('%s%s/%s.mat', path_out, folder_name_raw, file_name_out); % Path to output of extracted spikes matrix
        
        if ~exist (path_plexon_mat,'file')
            if ~exist (path_plexon_pl2, 'file')
                fprintf('%s.pl2 does not exist, either no recording or incorrect file names provided\n', file_name_in);
            elseif exist (path_plexon_pl2, 'file') && ~exist (path_plexon_mat,'file') % If asc file doesn't exist - do the conversion
                if ~exist (path_plexon_mat,'file')
                    %====
                    dir_temp = [path_out, folder_name_raw];
                    if ~isdir(dir_temp);
                        mkdir(dir_temp);
                    end
                    fprintf('Extracting events from %s.pl2\n', file_name_in);
                    plexon_events_v10(path_plexon_pl2, path_plexon_mat); % Script doing import of pl2 file
                    
                    %======
                    % Load file in in order to combine it later
                    if exist(path_plexon_mat, 'file')
                        varx = load(path_plexon_mat);
                        % Extract a structure which is in the var1
                        f1 = fieldnames(varx);
                        if length(f1)==1
                            var2 = varx.(f1{1});
                        end
                    end
                    %=====
                    
                end
            end
        else
            fprintf('File %s already exists, skipping event extraction\n', file_name_out)
        end
        
        % Load spikes file in in order to combine it later
        if ~exist('var2', 'var')
            var2 = struct; % Initialize empty structur
        end
        
        %===========
        % Extract analog signal of interest from pl2 file 
        %===========
        
        path_in = settings.path_data_plexon_raw;
        path_out = settings.path_data_plexon_mat;
        file_name_in = [folder_name_raw];
        file_name_out = [folder_name_raw,'_analog'];
        path_plexon_pl2 = sprintf('%s%s/%s.pl2', path_in, folder_name_raw, file_name_in); % Path to raw plexon file
        path_plexon_mat = sprintf('%s%s/%s.mat', path_out, folder_name_raw, file_name_out); % Path to output of extracted spikes matrix
        channel_names{1} = 'AI01'; 
        
        if ~exist (path_plexon_mat,'file')
            if ~exist (path_plexon_pl2, 'file')
                fprintf('%s.pl2 does not exist, either no recording or incorrect file names provided\n', file_name_in);
            elseif exist (path_plexon_pl2, 'file') && ~exist (path_plexon_mat,'file') % If asc file doesn't exist - do the conversion
                if ~exist (path_plexon_mat,'file')
                   
                    %=====
                    dir_temp = [path_out, folder_name_raw];
                    if ~isdir(dir_temp);
                        mkdir(dir_temp);
                    end
                    fprintf('Extracting analong signal from %s.pl2\n', file_name_in);
                    plexon_analog_v10(path_plexon_pl2, path_plexon_mat, channel_names); % Script doing import of pl2 file
                    
                    %======
                    % Load file in in order to combine it later
                    if exist(path_plexon_mat, 'file')
                        varx = load(path_plexon_mat);
                        % Extract a structure which is in the var1
                        f1 = fieldnames(varx);
                        if length(f1)==1
                            var3 = varx.(f1{1});
                        end
                    end
                    %=====
                    
                end
            end
        else
            fprintf('File %s already exists, skipping event extraction\n', file_name_out)
        end
        
        if ~exist('var3', 'var')
            var3 = struct; % Initialize empty structur
        end

        
        %============
        % Check whether all three files exist and copy them to the folder
        % of interest
        %============
        
        % At the moment analysis can not deal wiht more than one
        % repetition, but this can be changed in this section
        
        % Path to data output output folder (without session indexes, just subject name and date)
        f_name = [settings.subject_name, num2str(date_index(i_date))];
        path1 = sprintf('%s%s/', settings.path_data_combined_plexon, f_name);
        
        % Check whether to remove directory or create one
        if settings.overwrite==1
            if isdir(path1)
                rmdir(path1, 's');
            end
        end
        
        if ~isempty(fieldnames(var1))
            if ~isdir(path1);
                mkdir(path1);
            end
            plex = var1; 
            p1 = sprintf('%s%s_spikes.mat', path1, f_name);
            save(eval('p1'), 'plex');
            fprintf('Saved spikes data in folder %s\n', f_name);
        else
            fprintf('Spikes data - no saving completed\n');
        end
        
        if ~isempty(fieldnames(var2))
            if ~isdir(path1);
                mkdir(path1);
            end
            plex = var2;
            p1 = sprintf('%s%s_events.mat', path1, f_name);
            save(eval('p1'), 'plex');
            fprintf('Saved events data in folder %s\n', f_name);
        else
            fprintf('Events data - no saving completed\n');
        end
        
        if ~isempty(fieldnames(var3))
            if ~isdir(path1);
                mkdir(path1);
            end
            plex = var3;
            p1 = sprintf('%s%s_analog.mat', path1, f_name);
            save(eval('p1'), 'plex');
            fprintf('Saved analog data in folder %s\n', f_name);
        else
            fprintf('Analog data - no saving completed\n');
        end
       
        
        
    end
    % Pre-processing for each day is over
    
end
% Pre-processng for each subject is over
