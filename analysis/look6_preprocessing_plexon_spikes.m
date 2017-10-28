% Combine files, extract saccades, extract spikes
% Latest revision - November 2, 2016
% Donatas Jonikaitis

close all;
clear all; 
settings.exp_name = 'look6';
settings.subjects = 'aq';

p1 = mfilename;
fprintf('\n=========\n')
fprintf('\n Current file:  %s\n', p1)
fprintf('\n=========\n')

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
    settings.subjects = 'all'; % Subject name
end

% Overwriting analysis defaults
if ~isfield(settings, 'overwrite')
    settings.overwrite = 1;
end

% Run settings file:
eval(sprintf('%s_analysis_settings', settings.exp_name)); % Load general settings


%% Run preprocessing

for i_subj=1:length(settings.subjects)
    
    settings.subject_current=settings.subjects{i_subj}; % Select curent subject
    
    % Initialize subject specific folders where data is stored
    f1 = fieldnames(settings);
    ind = strncmp(f1,'path_data_', 10);
    for i = 1:numel(ind)
        if ind(i)==1
            v1 = sprintf('%s%s', f1{i}, '_subject');
            settings.(v1) = sprintf('%s%s/', settings.(f1{i}), settings.subject_current);
        end
    end
    
    % Get index of every folder for a given subject
    path1 = settings.path_data_combined_plexon_subject;
    session_init = get_path_dates_v20(path1, settings.subject_current);
    if isempty(session_init.index_dates)
        fprintf('\nNo files detected, no data analysis done. Directory checked was:\n')
        fprintf('%s\n', path1)
    end
    

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
    
    
    for i_date = 1:length(date_used)
        
        date_current = date_used(i_date);
        
        % Current folder to be analysed (raw date, with session index)
        ind = date_current==settings.index_dates;
        folder_name = settings.index_directory{ind};
        
        % Specify file names and paths
        file_name_ev = [folder_name,'_events_matched'];
        path_in_ev = sprintf('%s%s/%s.mat', settings.path_data_combined_plexon_subject, folder_name, file_name_ev);
        file_name_spikes = [folder_name,'_spikes'];
        path_in_spikes = sprintf('%s%s/%s.mat', settings.path_data_combined_plexon_subject, folder_name, file_name_spikes);
        path_out = sprintf('%s%s/', settings.path_data_spikes, folder_name); % Path to raw plexon file
        
        if ~isdir(path_out) || settings.overwrite==1
            
            % Check whether to remove directory or create one
            if settings.overwrite==1
                if isdir(path_out)
                    rmdir(path_out, 's');
                end
            end
            
            if exist(path_in_spikes, 'file') && exist(path_in_ev, 'file')
                
                % Create empty directory for saving files
                if ~isdir(path_out)
                    mkdir(path_out);
                end
                
                fprintf('\nExtracting spikes from file %s\n', file_name_spikes);
                
                % Load all settings
                path1 = path_in_spikes;
                var1 = struct; varx = struct;
                if exist(path1, 'file')
                    varx = load(path1);
                    f1 = fieldnames(varx);
                    if length(f1)==1
                        var1 = varx.(f1{1});
                    end
                end
                plexon_mat = var1;
                
                % Load plexon file
                path1 = path_in_ev;
                var2 = struct; varx = struct;
                if exist(path1, 'file')
                    varx = load(path1);
                    f1 = fieldnames(varx);
                    if length(f1)==1
                        var2 = varx.(f1{1});
                    end
                end
                
                
                %==============
                % Change this part for each project
                
                if ~isempty(fieldnames(plexon_mat))
                    for i=1:size(plexon_mat.spike_ts,1) % For each unit (UNIT 1 is unsorted)
                        for j=1:size(plexon_mat.spike_ts,2) % For each channel
                            
                            temp1 = plexon_mat.spike_ts(i,j); temp1=temp1{1}; % Select data
                            
                            if ~isempty(temp1) % If spikes exists
                                
                                % Save spikes data
                                spikes = struct;
                                spikes.ts = temp1;
                                % Reset data to psychtoolbox timing (into milliseconds)
                                spikes.ts = spikes.ts*1000;
                                
                                % Read out event time-stamps
                                a = fieldnames(var2);
                                for k = 1:length(a)
                                    if ~isempty (var2.(a{k}))
                                        spikes.(a{k}) = var2.(a{k});
                                    end
                                end
                                
                                spikes.channel_name = plexon_mat.channel_names(j,:);
                                
                                % saved file name = [subjectNameDate_channelNumber_unitNumber_unitType.mat];
                                % unitType: s-single, m-multiunit, u-unknown
                                file_name = [settings.subject_current, num2str(i_date), '_ch', num2str(j),'_u', num2str(i), '_u.mat'];
                                path1 = [path_out, file_name];
                                save(eval('path1'), 'spikes')
                                fprintf('Plexon spikes successfuly exported to a folder %s\n', file_name)
                                
                            end
                        end
                    end
                end
                
                
            else
                fprintf('\nMissing plexon events or spikes files %s, importing failed\n', folder_name)
            end
            % End of checkign whether files exist
            
        else
            fprintf('Plexon spikes folder %s exists, no importing done\n', folder_name)
        end
        % End of conversion plexon event extraction
        %==================
        
    end
    % Pre-processing for each day is over
    
end
% Pre-processng for each subject is over
