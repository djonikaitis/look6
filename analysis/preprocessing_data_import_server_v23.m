% Synchronize the data with the server
%
% v1.0 DJ: August 11, 2016. Basic code.
% v2.0 DJ: April 2, 2017. Roather quick code, able to work on its own,
% independent of experiment code. Assumption that data is stored as:
% exp_name\data_type\subject_name\session_folder\file_name
% for example: look5\plexon_data\hb\hb_2017_01_01\hb_2017_01_01.pl2
% Data has to be organized... get over it...
% V2.1 DJ: October 30, 2017. Can import only specific dates (to make data
% transfer faster in case one needs only one day)
% V2.2 DJ, November 14, 2017. Supports data upload and download. For this
% specifyc settings.data_direction = 'upload' or 'download'. Default is
% download.
% V2.3 DJ, Feb 1, 2018 Added file over-write during import/export

function  preprocessing_data_import_server_v23(settings)


% Show file you are running
p1 = mfilename;
fprintf('\n=========\n')
fprintf('Current file:  %s\n', p1)
fprintf('=========\n')

% Loading the files needed
if ~exist('settings', 'var')
    settings = struct;
end
settings = get_settings_ini_v10(settings);

% Determine the direction of the data
if isfield (settings, 'data_direction')
    if strcmp(settings.data_direction, 'download')
        path_baseline_server = settings.path_baseline_server;
        path_baseline_data = settings.path_baseline_data;
    elseif strcmp(settings.data_direction, 'upload')
        path_baseline_server = settings.path_baseline_data;
        path_baseline_data = settings.path_baseline_server;
    end
else
    path_baseline_server = settings.path_baseline_server;
    path_baseline_data = settings.path_baseline_data;
end

% Determine whehter one can connect to server
if isfield (settings, 'data_direction') && strcmp(settings.data_direction, 'download') && exist (path_baseline_server)==7
    fprintf ('\nSuccessfully connected to server\n')
    settings.data_import_from_server = 1;
elseif isfield (settings, 'data_direction') && strcmp(settings.data_direction, 'upload') && exist (path_baseline_data)==7
    fprintf ('\nSuccessfully connected to server\n')
    settings.data_import_from_server = 1;
elseif ~isfield (settings, 'data_direction') && exist (path_baseline_server)==7
    fprintf ('\nSuccessfully connected to server\n')
    settings.data_import_from_server = 1;
else
    fprintf ('\nCould not connect to server, breaking import\n')
    fprintf ('%s\n', path_baseline_server)
    settings.data_import_from_server = 0;
    return
end


% Do analysis if one can connect to server
if settings.data_import_from_server ==1
    
    % Run pre-processing for each subject
    for i_subj = 1:length(settings.subjects)
        
        % Select curent subject
        settings.subject_current = settings.subjects{i_subj};
        fprintf ('Will prepare sync for a given subject: %s\n', settings.subject_current)
        
        % Setup path
        settings.path_server_in = sprintf ('%s%s/', path_baseline_server, settings.exp_name); % Link to experiment specific folder ('att1')
        settings.path_server_out =  sprintf ('%s%s/', path_baseline_data, settings.exp_name);
        
        % Determine which data folders exist
        dir_index = dir(settings.path_server_in);
        
        % For each data folder
        for folder_i = 1:length(dir_index)
            
            dont_analyze_this_folder = 0; % If 1 - analyze this folder
            
            % Exclude '.' folders
            dont_analyze_this_folder = strncmp(dir_index(folder_i).name, '.', 1) || strncmp(dir_index(folder_i).name, '..', 2);
            
            % Are there some pre-specified excluded folders?
            if dont_analyze_this_folder == 0
                if isfield(settings, 'import_folders_exclude') && ~isempty(settings.import_folders_exclude)
                    a = strcmp(settings.import_folders_exclude, dir_index(folder_i).name);
                else
                    a = 0;
                end
                if sum(a)>0
                    dont_analyze_this_folder = 1;
                else
                    dont_analyze_this_folder = 0;
                end
            end
            
            % Are there some pre-specified included folders?
            if dont_analyze_this_folder == 0
                if isfield(settings, 'import_folders_include') && ~isempty(settings.import_folders_exclude)
                    a = strcmp(settings.import_folders_include, dir_index(folder_i).name);
                else
                    a = 0;
                end
                if sum(a)>0
                    dont_analyze_this_folder = 1;
                else
                    dont_analyze_this_folder = 0;
                end
            end
            
            
            if dont_analyze_this_folder == 0
                
                settings.path_server_server_in_subject = sprintf('%s%s/%s/%s', settings.path_server_in, dir_index(folder_i).name, settings.subject_current);
                settings.path_server_server_out_subject = sprintf('%s%s/%s/%s', settings.path_server_out, dir_index(folder_i).name, settings.subject_current);
                
                fprintf('\n============\n')
                fprintf('Will synchronise following data sub-folder: \n');
                fprintf('%s\n', settings.path_server_server_in_subject)
                fprintf('============\n\n')
                
                settings = get_settings_path_and_dates_ini_v11(settings, 'path_server_server_in_subject');
                dates_used = settings.data_sessions_to_analyze;
                
                % Analysis for each separate day
                for i_date = 1:length(dates_used)
                    
                    % Current folder to be analysed (raw date, with session index)
                    date_current = dates_used(i_date);
                    settings.date_current = date_current; % Variable needed for data import
                    ind_folders = find (date_current==settings.index_dates);
                    
                    fprintf('\n============\n')
                    fprintf('Will synchronise following date %s\n', num2str(date_current));
                    fprintf('============\n\n')
                    
                    for i_folder = 1:numel(ind_folders)
                        
                        folder_name = settings.index_directory{ind_folders(i_folder)};
                        path1_temp_inp_folder = sprintf('%s%s/', settings.path_server_server_in_subject, folder_name);
                        path1_temp_out_folder = sprintf('%s%s/', settings.path_server_server_out_subject, folder_name);
                        
                        % Create input folder if it doesn't exist
                        if ~isdir (path1_temp_out_folder)
                            mkdir(path1_temp_out_folder);
                        end
                        
                        %==========================
                        % Determine folder contents and sync them
                        index_file = dir(path1_temp_inp_folder);
                        
                        for file_i = 1:length(index_file)
                            if ~strncmp(index_file(file_i).name, '.', 1) && ~strncmp(index_file(file_i).name, '..', 2)
                                
                                fprintf('Will synchronise following file "%s" in the folder "%s" \n', index_file(file_i).name, folder_name);
                                
                                % Make such a folder on the server
                                path1_source = sprintf('%s%s', path1_temp_inp_folder, index_file(file_i).name);
                                path1_destination = sprintf('%s%s', path1_temp_out_folder, index_file(file_i).name);
                                
                                %========
                                if exist(path1_destination) == 2
                                    if isfield(settings, 'server_overwrite') && settings.server_overwrite==1
                                        fprintf('Data file "%s" exists, overwriting as specified by user input in settings.overwrite\n', index_file(file_i).name);
                                        delete(path1_destination);
                                        if exist(path1_destination) ~= 2
                                            fprintf('File successfully deleted\n');
                                        elseif exist(path1_destination) == 2
                                            error ('File deletion failed, no contingency code written')
                                        end
                                        status = 0; temp_counter = 1;
                                        while status==0
                                            [status, message] = copyfile(path1_source, path1_destination);
                                            if status ~=0
                                                fprintf('Success, file copied\n');
                                            end
                                            if status == 0
                                                fprintf('Failed to sync file "%s", will attempt again. Error id: %s\n', index_file(file_i).name, message);
                                                temp_counter = temp_counter+1;
                                                if temp_counter==3
                                                    status = -1;
                                                    fprintf('Failed to sync file "%s", skipping the sync\n', index_file(file_i).name);
                                                end
                                            end
                                        end
                                    else
                                        fprintf('Data file "%s" exists, no sync\n', index_file(file_i).name);
                                    end
                                else
                                    fprintf('Will synchronise data file "%s" \n', index_file(file_i).name);
                                    status = 0; temp_counter = 1;
                                    while status==0
                                        [status, message] = copyfile(path1_source, path1_destination);
                                        if status ~=0
                                            fprintf('Success, file copied\n\n');
                                        end
                                        if status == 0
                                            fprintf('Failed to sync file "%s", will attempt again. Error id: %s\n', index_file(file_i).name, message);
                                            temp_counter = temp_counter+1;
                                            if temp_counter==3
                                                status = -1;
                                                fprintf('Failed to sync file "%s", skipping the sync\n\n', index_file(file_i).name);
                                            end
                                        end
                                    end
                                end
                                %========
                                
                            end
                            % End of checking exp folder exists (exclude '..')
                        end
                        % End of analysis for each single file
                        %======================
                        
                        
                    end
                    % End of analysis for each folder within a date
                end
                % End of analysis for each date
                
            else
                fprintf ('This folder is excluded from uploads: %s\n', dir_index(folder_i).name)
            end
            % End of checking exp folder exists (exclude '..') or
            % pre-specified folders
        end
        % End of analysis for each data folder (pyschtoolbox, raw etc)
    end
    % End of anlaysis for each subject
    
end
% End of importing

