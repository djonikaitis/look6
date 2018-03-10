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
    if strcmp(data_folder_name, 'data_plexon_raw')
        fprintf('Will import unsorted spikes only, sorting option not seleccted\n')
    end
    settings.dates_used = get_dates_used_v10 (settings, data_folder_name);
    
    % Analysis for each day
    for i_date = 1:numel(settings.dates_used)
        
        % Which date is it
        settings.date_current = settings.dates_used(i_date);
        
        % How many sessions are used?
        settings.sessions_used = get_sessions_used_v10(settings, data_folder_name);
        
        % Do analysis for each desired session
        % No changes needed for this section
        for i_session = 1:numel(settings.sessions_used)
            
            % Which recorded to use
            if isempty(settings.sessions_used)
            else
            end
            session_ind = settings.sessions_used(i_session);
            
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
                [path1, path1_short, file_name_out] = get_generate_path_v10(settings, 'data_plexon_temp_2', '_spikes.mat', session_ind);
            else
                [path1, path1_short, file_name_out] = get_generate_path_v10(settings, 'data_plexon_temp_2', '_spikes.mat');
            end
            
            if exist(path_in, 'file') && (~exist(path1, 'file') || settings.overwrite==1)
                
                if ~isdir(path1_short)
                    mkdir(path1_short);
                end
                fprintf('Extracting spikes from file "%s"\n', file_name_in);
                plexon_spikes_v11(path_in, path1); % Script doing import of pl2 file
                
                % Load file in in order to combine it later
                if exist(path1, 'file')
                    var1 = get_struct_v11(path1);
                    if isempty (var1)
                        fprintf('Failed to extract spikes, file is empty "%s"\n', file_name_out);
                    else
                        fprintf('Successfully extracted spikes "%s"\n', file_name_out);
                    end
                end
                
            elseif ~exist(path_in, 'file')
                fprintf('File "%s" does not exist\n', file_name_in);
            elseif exist(path1, 'file') && settings.overwrite==0
                fprintf('File "%s" already exists, skipping spike extraction\n', file_name_out)
            else
                fprintf('Unknown error for pl2 spike extraction, date %s\n', num2str(settings.date_current))
            end
            
        end
        % Preprocessing for each session is over
        
    end
    % Pre-processing for each day is over
    
end
% Pre-processng for each subject is over

