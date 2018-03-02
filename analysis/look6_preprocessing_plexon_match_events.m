% Match trial onset/offset to experimentally recorded one
% V1.0 November 1, 2016
% V1.1 January. Updated to match new coding conventions. Plexon files now
% are imported session-by-session basis (multiple a day allowed).
% V1.2 March 1, 2018. Updated path definitions.
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
    
    % Which dates to run?
    data_folder_name = 'data_plexon_temp_2';
    settings.dates_used = get_dates_used_v10 (settings, data_folder_name);
        
    clear var1; clear var2; clear var3;

    % Analysis for each day
    for i_date = 1:numel(settings.dates_used)
        
        % Which date is it
        settings.date_current = settings.dates_used(i_date);
        
        % How many sessions are used?
        sessions_used = get_sessions_used_v10(settings, data_folder_name);
          
        %============
        % Psychtoolbox path
        [path1_psy, ~, file_name_psy] = get_generate_path_v10(settings, 'data_combined', '.mat');
        var1 = get_struct_v11(path1_psy);
        
        %==============
        % Plexon path output
        [path1_out, path1_out_short, file_name_out] = get_generate_path_v10(settings, 'data_combined_plexon', '_events_matched.mat');
        
        % Initialize output fields with matched events
        dset1_fields.msg1_recorded_stamps = NaN(numel(var1.(dset1_fields.session)), 1);
        dset1_fields.msg2_recorded_stamps = NaN(numel(var1.(dset1_fields.session)), 1);

        %===============
        % Do analysis for each session
        for i_session = 1:numel(sessions_used)
            
            % Which recorded session to use
            if numel(sessions_used)>1
                session_ind = sessions_used(i_session);
            else
                session_ind = [];
            end
                               
            %================
            % Input file
            [path1_in, ~, file_name_in] = get_generate_path_v10(settings, data_folder_name, '_events.mat', session_ind);
                
            %================
            % Match events
            %================
            
            if ~isempty(var1) && exist(path1_in, 'file') && (~exist(path1_out, 'file') || settings.overwrite==1)
                
                if ~isdir(path1_out_short)
                    mkdir(path1_out_short);
                end
                fprintf('\nImporting plexon events file "%s" and matching with psychtoolbox recording\n', file_name_in)
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
                fprintf('Psychtoolbox data file "%s" does not exist, no event matching performed\n', file_name_psy);
            elseif ~exist(path1_in, 'file')
                fprintf('Plexon events file "%s" does not exist, no event matching performed\n', file_name_in);
            elseif exist(path1_out, 'file') && settings.overwrite==0
                fprintf('File "%s" already exists, skipping event matching for given date\n', file_name_out)
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
            save (path1_out, 'plex')
            fprintf('Plexon events matched and saved successfully\n')
        else
            fprintf('Failed to find any plexon events, no data saved\n\n')
        end
        
        %=================
        
    end
    % Pre-processing for each day is over
    
end
% Pre-processng for each subject is over

