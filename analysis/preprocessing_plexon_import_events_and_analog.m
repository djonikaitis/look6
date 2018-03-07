% Extract plexon events and plexon analog signal.
% Requires to modify this file according to data storage properties
% Latest revision - March 1, 2018
% Donatas Jonikaitis

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


%% Analysis

for i_subj=1:length(settings.subjects)
    
    % Select curent subject
    settings.subject_current = settings.subjects{i_subj};
    
    % Which dates to run?
    data_folder_name = 'data_plexon_raw';
    settings.dates_used = get_dates_used_v10 (settings, data_folder_name);
    
    % Else attempt to retrieve pre-processed data
    if isempty(settings.dates_used)
        data_folder_name = 'data_plexon_temp_1';
        settings.dates_used = get_dates_used_v10 (settings, data_folder_name);
    end
    
    % Analysis for each day
    for i_date = 1:numel(settings.dates_used)
        
        % Which date is it
        settings.date_current = settings.dates_used(i_date);
        
        % How many sessions are used?
        sessions_used = get_sessions_used_v10(settings, data_folder_name);
        
        % Do analysis for each desired session
        % No changes needed for this section
        for i_session = 1:numel(sessions_used)
            
            % Which recorded session to use
            if numel(sessions_used)>1 && ~isnan(sessions_used(i_session))
                session_ind = sessions_used(i_session);
            else
                session_ind = [];
            end
            
            %================
            % Input file
            if ~isnan(session_ind)
                [path_in, ~, file_name_in] = get_generate_path_v10(settings, data_folder_name, '.pl2', session_ind);
            else
                [path_in, ~, file_name_in] = get_generate_path_v10(settings, data_folder_name, '.pl2');
            end
            
            clear var1; clear var2; clear var3;
            
            %===========
            % Extract all events from pl2 file
            %===========
            
            % Output file
            if ~isnan(session_ind)
                [path1, path1_short, file_name_out] = get_generate_path_v10(settings, 'data_plexon_temp_2', '_events.mat', session_ind);
            else
                [path1, path1_short, file_name_out] = get_generate_path_v10(settings, 'data_plexon_temp_2', '_events.mat');
            end
            
            
            if exist(path_in, 'file') && (~exist(path1, 'file') || settings.overwrite==1)
                
                if ~isdir(path1_short)
                    mkdir(path1_short);
                end
                fprintf('Extracting events from file "%s"\n', file_name_in);
                plexon_events_v10(path_in, path1); % Script doing import of pl2 file
                
                % Load file in in order to combine it later
                if exist(path1, 'file')
                    var1 = get_struct_v11(path1);
                    if isempty (var1)
                        fprintf('Failed to extract events, file is empty "%s"\n', file_name_out);
                    else
                        fprintf('Successfully extracted events "%s"\n', file_name_out);
                    end
                end
                
            elseif ~exist(path_in, 'file')
                fprintf('File "%s" does not exist\n', file_name_in);
            elseif exist(path1, 'file') && settings.overwrite==0
                fprintf('File "%s" already exists, skipping event extraction\n', file_name_out)
            else
                fprintf('Unknown error for pl2 event extraction, date %s\n', num2str(settings.date_current))
            end
            
            %===========
            % Extract analog signal of interest from pl2 file
            %===========
            
            % Output file
            if ~isnan(session_ind)
                [path1, path1_short, file_name_out] = get_generate_path_v10(settings, 'data_plexon_temp_2', '_analog.mat', session_ind);
            else
                [path1, path1_short, file_name_out] = get_generate_path_v10(settings, 'data_plexon_temp_2', '_analog.mat');
            end
            channel_names{1} = 'AI01';
            
            if exist(path_in, 'file') && (~exist(path1, 'file') || settings.overwrite==1)
                
                if ~isdir(path1_short)
                    mkdir(path1_short);
                end
                fprintf('Extracting analog signal from file "%s"\n', file_name_in);
                plexon_analog_v10(path_in, path1, channel_names); % Script doing import of pl2 file
                
                % Load file in in order to combine it later
                if exist(path1, 'file')
                    var1 = get_struct_v11(path1);
                    if isempty (var1)
                        fprintf('Failed to extract analog signal, file is empty "%s"\n', file_name_out);
                    else
                        fprintf('Successfully extracted analog signal "%s"\n', file_name_out);
                    end
                end
                
            elseif ~exist(path_in, 'file')
                fprintf('File "%s" does not exist\n', file_name_in);
            elseif exist(path1, 'file') && settings.overwrite==0
                fprintf('File "%s" already exists, skipping event extraction\n', file_name_out)
            else
                fprintf('Unknown error for pl2 event extraction, date %s\n', num2str(settings.date_current))
            end
            
        end
        % Preprocessing for each session is over
        
    end
    % Pre-processing for each day is over
    
end
% Pre-processng for each subject is over

