% Combine files, extract saccades, extract spikes
% V1.0: November 1, 2016
% Donatas Jonikaitis

% clear all;
close all;
% clc;


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

for i_subj=1:length(settings.subjects)
    
    settings.subject_name=settings.subjects{i_subj}; % Select curent subject
    
    % Initialize subject specific folders where data is stored
    for i=1:length(settings.path_spec_names)
        v1 = ['path_', settings.path_spec_names{i}];
        settings.(v1) = sprintf ('%s%s/', settings.path_spec_folder{i}, settings.subject_name);
    end
    
    % Get index of every folder for a given subject
    p1 = settings.path_data_combined_plexon;
    session_init = get_path_dates_v20(p1, settings.subject_name);
    if isempty(session_init.index_dates)
        fprintf('------------------\n');
        fprintf('\nNo plexon files detected, no data combination done. Directory checked was:\n')
        fprintf('%s\n', path1)
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
    date_index = session_init.index_unique_dates(ind);
    
    
    for i_date = 1:length(date_index)
        
        % Current folder to be analysed (raw date, with session index)
        i1 = find(date_index(i_date)==settings.index_dates);
        folder_name = settings.index_directory{i1};
        
        
        % Prepare a combined file with easy trial indexing
        
        %===============
        % How is the file with plexon event time stamps called?
        
        % Read out of recorded events
        if date_index(i_date)==20160803 || date_index(i_date)==20160919 || date_index(i_date)==20160923 || date_index(i_date)==20161012 ...
            || date_index(i_date)==20161021 || date_index(i_date)==20161028 || date_index(i_date)==20161030 || date_index(i_date)==20161019 || date_index(i_date)==20170321 ...
            || date_index(i_date)==20170328 || date_index(i_date)==20170330 || date_index(i_date)==20170419;  
            
            file_name_plex = [folder_name,'_events'];
            path_in_plex = sprintf('%s%s/%s.mat', settings.path_data_combined_plexon, folder_name, file_name_plex);
            
        else  % Read out of analog signal (if used)
            
            file_name_plex = [folder_name,'_analog_AI01'];
            path_in_plex = sprintf('%s%s/%s.mat', settings.path_data_combined_plexon, folder_name, file_name_plex);
            
            % If processed analog signal does not exist
            if ~exist(path_in_plex, 'file')
                
                % Load original analog file 
                f1 = [folder_name,'_analog'];
                path1 = sprintf('%s%s/%s.mat', settings.path_data_combined_plexon, folder_name, f1);
                if exist(path1, 'file')
                    
                    % Load file
                    var1 = struct; varx = struct;
                    varx = load(path1);
                    f1 = fieldnames(varx);
                    if length(f1)==1
                        var1 = varx.(f1{1});
                    end
                    
                    % Extract refresh info out of raw analog signal
                    ch_n = 1; % Which saved channel is used
                    ai01 =  preprocessing_plexon_get_events_AI01_v10 (var1, ch_n);
                    
                    % Save the output of the conversion
                    if ~isempty(fieldnames(ai01))
                        save (eval('path_in_plex'), 'ai01')
                    end
                    
                else
                    % File wont be loadad
                end
            end
            
        end
        % End of specification for file_name_plex
        %===============
                
        
        % Specify file names and paths
        file_name_psy = [folder_name,'_settings'];
        file_name_out = [folder_name,'_events_matched']; % Detected events are saved with this name
        path_in_psy = sprintf('%s%s/%s.mat', settings.path_data_combined, folder_name, file_name_psy);
        path_out = sprintf('%s%s/%s.mat', settings.path_data_combined_plexon, folder_name, file_name_out); % Path to raw plexon file
        
        if (~exist(path_out, 'file') || settings.overwrite==1)
            
            if exist(path_in_psy, 'file') && exist(path_in_plex, 'file')
                
                fprintf('\nImporting plexon events file %s and matching with psychtoolbox recording\n', file_name_plex)
                clear plex;
                
                % Load all settings
                path1 = path_in_psy;
                var1 = struct; varx = struct;
                if exist(path1, 'file')
                    varx = load(path1);
                    f1 = fieldnames(varx);
                    if length(f1)==1
                        var1 = varx.(f1{1});
                    end
                end
                
                % Load plexon file
                path1 = path_in_plex;
                plexon_ev = struct; varx = struct;
                if exist(path1, 'file')
                    varx = load(path1);
                    f1 = fieldnames(varx);
                    if length(f1)==1
                        plexon_ev = varx.(f1{1});
                    end
                end
                
                %================
                % Reading out analog signal
                %================
                
                if isfield(plexon_ev, 'refresh_rates')
                    
%                     % Initialize variables of interest
%                     psy1 = var1.eyelink_events.first_display;
%                     sp1 = plexon_ev.time2';
%                     ses1 = var1.session;
%                     y = preprocessing_match_plexon_events_v10(psy1, sp1, ses1); % Y is new field which contains matched time stamps
%                     plex.msg_1 = y;

                    
                %================    
                % Reading out events, less reliable
                %================
                else
                    
                    %==============
                    % Match events
                    % Change this part for each project
                    
                    % Initialize variables of interest
                    psy1 = var1.eyelink_events.first_display;
                    sp1 = plexon_ev.event_ts{1}*1000; % Message timing is reset to milliseconds
                    ses1 = var1.session;
                    
                    y = preprocessing_match_plexon_events_v11(psy1, sp1, ses1); % Y is new field which contains matched time stamps
                    plex.msg_1 = y;
                    
                    %==========
                    % Change this part for each project
                    %==========
                    
                    % Initialize variables of interest
                    psy2 = var1.eyelink_events.targets_off;
                    sp2 = plexon_ev.event_ts{2}*1000; % Message timing is reset to milliseconds
                    ses1 = var1.session;
                    
                    y = preprocessing_match_plexon_events_v11(psy2, sp2, ses1); % Y is new field which contains matched time stamps
                    plex.msg_2 = y;
                    
                    % Save both structures
                    % Check that matching events did not fail:
                    a = ~isnan(plex.msg_1); b=~isnan(plex.msg_2);
                    if sum(a)>0 && sum(b)>0
                        save (eval('path_out'), 'plex')
                        fprintf('Plexon events imported and saved successfully\n')
                    else
                        fprintf('Failed to find any plexon events, no data saved\n\n')
                    end

                end
                %
                %===========
            else
                fprintf('\nMissing plexon events or psychtoolbox files, importing failed\n', folder_name)
            end
            % End of checkign whether files exist
            
        else
            fprintf('\nPlexon events %s_plex_events exist, no importing done\n', folder_name)
        end
        % End of conversion plexon event extraction
        %==================
        
    end
    % Pre-processing for each day is over
    
end
% Pre-processng for each subject is over
