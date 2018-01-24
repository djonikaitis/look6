% Combine files, extract saccades, extract spikes
% Latest revision - January 19, 2018
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
    dates_used = get_dates_used_v10 (settings, 'data_plexon_temp_2');
    
    % Analysis for each day
    for i_date = 1:numel(dates_used)
        
        % Select current date
        settings.date_current = dates_used(i_date);
        
        % How many sessions are used?
        p1 = get_generate_path_v10(settings, 'data_plexon_temp_2');
        temp1 = get_path_dates_v20(p1, settings.subject_current);
        ind = settings.date_current==temp1.index_dates;
        sessions_used = temp1.index_sessions(ind);
        
        % Do analysis for each desired session
        for i_session = 1:numel(sessions_used)
            
            % Which recorded session to use
            if numel(sessions_used)>1
                session_ind = sessions_used(i_session);
            else
                session_ind = [];
            end
                   
            clear var1; clear var2; clear var3;
            
            %================
            % Input file
            [path_in, ~, file_name] = get_generate_path_v10(settings, 'data_plexon_temp_2', '_spikes.mat', session_ind);
            
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
                            save(eval('path_out'), 'spikes')
                            fprintf('Plexon spikes successfuly saved to a file "%s"\n', file_name)
                            
                        end
                    end
                end
            end
            
 
        end
        % Preprocessing for each session is over
        
    end
    % Pre-processing for each day is over
    
end
% Pre-processng for each subject is over


% % %
% % %         % Specify file names and paths
% % %         file_name_ev = [folder_name,'_events_matched'];
% % %         path_in_ev = sprintf('%s%s/%s.mat', settings.path_data_combined_plexon_subject, folder_name, file_name_ev);
% % %         file_name_spikes = [folder_name,'_spikes'];
% % %         path_in_spikes = sprintf('%s%s/%s.mat', settings.path_data_combined_plexon_subject, folder_name, file_name_spikes);
% % %         path_out = sprintf('%s%s/', settings.path_data_spikes, folder_name); % Path to raw plexon file
% % %
% % %         if ~isdir(path_out) || settings.overwrite==1
% % %
% % %             % Check whether to remove directory or create one
% % %             if settings.overwrite==1
% % %                 if isdir(path_out)
% % %                     rmdir(path_out, 's');
% % %                 end
% % %             end
% % %
% % %             if exist(path_in_spikes, 'file') && exist(path_in_ev, 'file')
% % %
% % %
% % %
% % %

% % %
% % %
% % %
% % %
% % %             else
% % %                 fprintf('\nMissing plexon events or spikes files %s, importing failed\n', folder_name)
% % %             end
% % %             % End of checkign whether files exist
% % %
% % %         else
% % %             fprintf('Plexon spikes folder %s exists, no importing done\n', folder_name)
% % %         end
% % %         % End of conversion plexon event extraction
% % %         %==================
% % %

