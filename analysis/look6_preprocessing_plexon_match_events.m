% Match trial onset/offset to experimentally recorded one
% V1.0 November 1, 2016
% V1.1 January. Updated to match new coding conventions. Plexon files now
% are imported session-by-session basis (multiple a day allowed).
% Donatas Jonikaitis

% Show file you are running
p1_plex = mfilename;
fprintf('\n=========\n')
fprintf('\n Current file:  %s\n', p1_plex)
fprintf('\n=========\n')

% Loading the files needed
if ~exist('settings', 'var')
    settings = struct;
end
settings = get_settings_ini_v10(settings);

% Some settings for extracting data
dset1_fields.msg1 = 'first_display';
dset1_fields.msg1_code = 1;
dset1_fields.msg2 = 'target_off';
dset1_fields.msg2_code = 2;
dset1_fields.session = 'session';


%% Run preprocessing

for i_subj=1:length(settings.subjects)
    
    % Select curent subject
    settings.subject_current = settings.subjects{i_subj};
        
    % Get info about existing plexon files
    f1 = 'path_data_plexon_temp2_subject';
    settings = get_settings_path_and_dates_ini_v11(settings, f1);
    dates_used = settings.data_sessions_to_analyze;
    p1_plex = settings.(f1);
    
    % Get info about psychtoolbox files
    f1 = 'path_data_combined_subject';
    settings_psy = get_settings_path_and_dates_ini_v11(settings);
    p1_psy = settings.(f1);
    
    clear var1; clear var2; clear var3;

    % Analysis for each day
    for i_date = 1:numel(dates_used)
           
        % Psychtoolbox file path
        date_current = dates_used(i_date);
        ind = date_current==settings_psy.index_dates;
        folder_name_psy = settings_psy.index_directory{ind};
        path1_psy = [p1_psy, folder_name_psy, '/', folder_name_psy, '.mat'];
        
        % Load psychtoolbox file
        var1 = get_struct_v11(path1_psy);
        
        % Plexon matched events output file
        f1 = 'path_data_combined_plexon_subject';
        folder_name_plex = folder_name_psy;
        path_out_folder =  [settings.(f1), folder_name_plex, '/'];
        path1_out = [settings.(f1), folder_name_plex, '/' folder_name_plex, '_events_matched.mat'];

        % Current plexon folder to be analysed (multiple sessions)
        date_current = dates_used(i_date);
        sessions_used = find(date_current==settings.index_dates);
        
        % Initialize output fields with matched events
        dset1_fields.msg1_recorded_stamps = NaN(numel(var1.(dset1_fields.session)), 1);
        dset1_fields.msg2_recorded_stamps = NaN(numel(var1.(dset1_fields.session)), 1);

        %===============
        % Do analysis for each session
        for i_session = 1:numel(sessions_used)
            
            % Which recorded to use
            session_ind = sessions_used(i_session);
            
            % Folder name to be used
            folder_name = settings.index_directory{session_ind};
            
            % Plexon input file
            path1_in = [p1_plex, folder_name, '/' folder_name, '_events.mat'];
            
            %================
            % Match events
            %================
            
            if ~isempty(var1) && exist(path1_in, 'file') && (~exist(path1_out, 'file') || settings.overwrite==1)
                
                if ~isdir(path_out_folder)
                    mkdir(path_out_folder);
                end
                fprintf('\nImporting plexon events file "%s_events.mat" and matching with psychtoolbox recording\n', folder_name)
                clear plex;
                
                % Load plexon events file
                plexon_ev = get_struct_v11(path1_in);
                
                %==============
                % Match events
                % Change this part for each project
                  
                % Event 1
                % Initialize variables of interest
                psy1 = var1.(dset1_fields.msg1);
                sp1 = plexon_ev.event_ts{dset1_fields.msg1_code}*1000; % Message timing is reset to milliseconds
                ses1 = var1.(dset1_fields.session);
                
                y = preprocessing_match_plexon_events_v11(psy1, sp1, ses1); % Y is new field which contains matched time stamps
                ind = ~isnan(y);
                dset1_fields.msg1_recorded_stamps(ind) = y(ind);
                
                % Event 2
                % Initialize variables of interest
                psy1 = var1.(dset1_fields.msg2);
                sp1 = plexon_ev.event_ts{dset1_fields.msg2_code}*1000; % Message timing is reset to milliseconds
                ses1 = var1.(dset1_fields.session);
                
                y = preprocessing_match_plexon_events_v11(psy1, sp1, ses1); % Y is new field which contains matched time stamps
                ind = ~isnan(y);
                dset1_fields.msg2_recorded_stamps(ind) = y(ind);
                
                  
            elseif isempty(var1)
                fprintf('Psychtoolbox data file "%s.mat" does not exist for a date %s\n', folder_name_psy, num2str(date_current));
            elseif ~exist(path1_in, 'file')
                fprintf('File "%s.mat" does not exist for a date %s\n', folder_name, num2str(date_current));
            elseif exist(path1_out, 'file') && settings.overwrite==0
                fprintf('File "%s_events_matched.mat" already exists, skipping event matching for date %s\n', folder_name_plex, num2str(date_current))
            else
                fprintf('Unknown error for event matching, date %s\n', num2str(date_current))
            end
           % End of analysis
            
        end
        % End of each session (plexon file)
        
        %=================
        % Save output file
        
        clear plex;
        plex.msg_1 = dset1_fields.msg1_recorded_stamps;
        plex.msg_2 = dset1_fields.msg2_recorded_stamps;
        
        % Check that matching events did not fail:
        a = ~isnan(plex.msg_1); b=~isnan(plex.msg_2);
        if sum(a)>0 && sum(b)>0
            save (eval('path1_out'), 'plex')
            fprintf('Plexon events matched and saved successfully\n')
        else
            fprintf('Failed to find any plexon events, no data saved\n\n')
        end
        
        %=================
        
    end
    % Pre-processing for each day is over
    
end
% Pre-processng for each subject is over


%% Analog data

%             
% %         else  % Read out of analog signal (if used)
% %             
% %             file_name_plex = [folder_name,'_analog_AI01'];
% %             path_in_plex = sprintf('%s%s/%s.mat', settings.path_data_combined_plexon_subject, folder_name, file_name_plex);
% %             
% %             % If processed analog signal does not exist
% %             if ~exist(path_in_plex, 'file')
% %                 
% %                 % Load original analog file 
% %                 f1 = [folder_name,'_analog'];
% %                 path1 = sprintf('%s%s/%s.mat', settings.path_data_combined_plexon_subject, folder_name, f1);
% %                 if exist(path1, 'file')
% %                     
% %                     % Load file
% %                     var1 = struct; varx = struct;
% %                     varx = load(path1);
% %                     f1 = fieldnames(varx);
% %                     if length(f1)==1
% %                         var1 = varx.(f1{1});
% %                     end
% %                     
% %                     % Extract refresh info out of raw analog signal
% %                     ch_n = 1; % Which saved channel is used
% %                     ai01 =  preprocessing_plexon_get_events_AI01_v10 (var1, ch_n);
% %                     
% %                     % Save the output of the conversion
% %                     if ~isempty(fieldnames(ai01))
% %                         save (eval('path_in_plex'), 'ai01')
% %                     end
% %                     
% %                 else
% %                     % File wont be loadad
% %                 end
% %             end

%                 
%                 %================
%                 % Reading out analog signal
%                 %================
%                 
%                 if isfield(plexon_ev, 'refresh_rates')
%                     
% %                     % Initialize variables of interest
% %                     psy1 = var1.eyelink_events.first_display;
% %                     sp1 = plexon_ev.time2';
% %                     ses1 = var1.session;
% %                     y = preprocessing_match_plexon_events_v10(psy1, sp1, ses1); % Y is new field which contains matched time stamps
% %                     plex.msg_1 = y;