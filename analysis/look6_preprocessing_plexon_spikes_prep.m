% Combine files, extract saccades, extract spikes
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
    data_folder_name = 'data_plexon_temp_2';
    settings.dates_used = get_dates_used_v10 (settings, data_folder_name);
    
    % Analysis for each day
    for i_date = 1:numel(settings.dates_used)
        
        % Select current date
        settings.date_current = settings.dates_used(i_date);
        
        % How many sessions are used?
        sessions_used = get_sessions_used_v10(settings, data_folder_name);
        
        % Do analysis for each desired session
        for i_session = 1:numel(sessions_used)
            
            % Which recorded session to use
            if numel(sessions_used)>1 && ~isnan(sessions_used(i_session))
                session_ind = sessions_used(i_session);
            else
                session_ind = [];
            end
                   
            clear var1; clear var2; clear var3;
            
            %================
            % Input file
            [path_in, ~, file_name] = get_generate_path_v10(settings, 'data_plexon_temp_2', '_spikes.mat', session_ind);
            
            % Output folder
            [~, path_out_short, file_name_out] = get_generate_path_v10(settings, 'data_combined_plexon', [], session_ind);
            
            
            if exist(path_in, 'file') && (~exist(path_out_short, 'dir') || settings.overwrite==1)
                
                if ~isdir(path_out_short)
                    mkdir(path_out_short);
                end
                
                % Load file in in order to combine it later
                if exist(path_in, 'file')
                    plexon_mat = get_struct_v11(path_in);
                    if isempty (plexon_mat)
                        fprintf('Failed to find any spikes, file is empty "%s"\n', file_name);
                    else
                        fprintf('\nExtracting spikes from file "%s"\n', file_name);
                    end
                elseif ~exist(path_in, 'file')
                    fprintf('Failed to find any spikes, file does not exist "%s"\n', file_name);
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
                                
                                % Save plexon channel name
                                spikes.channel_name = plexon_mat.channel_names(j,:);
                                
                                % File name for the plexon spikes
                                file_name_append = ['_ch', num2str(j), '_u', num2str(i), '_u.mat'];
                                [path_out, ~, file_name] = get_generate_path_v10(settings, 'data_combined_plexon', file_name_append, session_ind);
                                save(path_out, 'spikes')
                                fprintf('Plexon spikes successfuly saved to a file "%s"\n', file_name)
                                
                            end
                        end
                    end
                end
             
            elseif ~exist(path_in, 'file')
                fprintf('File "%s" does not exist\n', file_name_in);
            elseif exist(path_out_short, 'dir') && settings.overwrite==0
                fprintf('Folder for the date %s already exists, skipping spike extraction\n', num2str(settings.date_current))
            else
                fprintf('Unknown error for pl2 spike extraction, date %s\n', num2str(settings.date_current))
            end
            % End of checking whether to plot data
            
        end
        % Preprocessing for each session is over
        
    end
    % Pre-processing for each day is over
    
end
% Pre-processng for each subject is over


