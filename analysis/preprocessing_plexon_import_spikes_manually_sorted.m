% Extract plexon events and plexon analog signal.
% Requires to modify this file according to data storage properties
% Latest revision - January 10, 2018
% Donatas Jonikaitis

% Show file you are running
p1 = mfilename;
fprintf('\n=========\n')
fprintf('\n Current file:  %s\n', p1)
fprintf('\n=========\n')

% Loading the files needed
if ~exist('settings', 'var')
    settings = struct;
end
settings = get_settings_ini_v10(settings);


%% Analysis

for i_subj=1:length(settings.subjects)
    
    % Select curent subject
    settings.subject_current = settings.subjects{i_subj};
    
    % Get subject folder paths and dates to analyze
    f1 = 'path_data_plexon_temp_1_subject';
    settings = get_settings_path_and_dates_ini_v11(settings, f1);
    dates_used = settings.data_sessions_to_analyze;
    p1 = settings.(f1);
    
    % Analysis for each day
    for i_date = 1:numel(dates_used)
        
        % Current folder to be analysed (raw date, with session index)
        date_current = dates_used(i_date);
        sessions_used = find(date_current==settings.index_dates);
        
        % Do analysis for each desired session
        % No changes needed for this section
        for i_session = 1:numel(sessions_used)
            
            % Which recorded to use
            session_ind = sessions_used(i_session);
            
            % Folder name to be used
            folder_name = settings.index_directory{session_ind};
            
            clear var1; clear var2; clear var3;
            
            %================
            % Input file
            path_in = [p1, folder_name, '/' folder_name, '.pl2'];
            
            %===========
            % Extract all events from pl2 file
            %===========
            
            % Output
            f1 = 'path_data_plexon_temp_2_subject';
            path_out =  [settings.(f1), folder_name, '/'];
            path1 = [settings.(f1), folder_name, '/' folder_name, '_spikes.mat'];
            
            if exist(path_in, 'file') && (~exist(path1, 'file') || settings.overwrite==1)
                
                if ~isdir(path_out)
                    mkdir(path_out);
                end
                fprintf('Extracting spikes from %s.pl2\n', folder_name);
                plexon_spikes_v11(path_in, path1); % Script doing import of pl2 file
                
                % Load file in in order to combine it later
                if exist(path1, 'file')
                    var1 = get_struct_v11(path1);
                    if isempty (var1)
                        fprintf('Failed to extract spikes, file is empty %s\n', folder_name);
                    else
                        fprintf('Successfully extracted spikes %s\n', folder_name);
                    end
                end
                
            elseif ~exist(path_in, 'file')
                fprintf('File "%s.pl2" does not exist for a date %s\n', folder_name, num2str(date_current));
            elseif exist(path1, 'file') && settings.overwrite==0
                fprintf('File "%s_spikes.mat" already exists, skipping spike extraction for date %s\n', folder_name, num2str(date_current))
            else
                fprintf('Unknown error for pl2 spikes extraction, date %s\n', num2str(date_current))
            end
            
        end
        % Preprocessing for each session is over
        
    end
    % Pre-processing for each day is over
    
end
% Pre-processng for each subject is over

