% Plot whether plexon file detection was successful
% V1.0: November 1, 2016
% V1.1 January 16, 2018. Adapted code to new analysis conventions.
% Donatas Jonikaitis

close all;

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


%% Some settings

% Path to figures and statistics
settings.figure_folder_name = 'plex_psy_events_match';
settings.stats_file_name = sprintf('statistics_%s_', settings.figure_folder_name);
settings.figsize1 = [0, 0, 5, 5]; % Change figure into bigger than usual

% Some settings for extracting data
dset1_fields.msg1 = 'first_display';
dset1_fields.msg1_code = 1;
dset1_fields.msg2 = 'loop_over';
dset1_fields.msg2_code = 2;
dset1_fields.session = 'session';

%% Run preprocessing

for i_subj=1:length(settings.subjects)
    
    % Select curent subject
    settings.subject_current = settings.subjects{i_subj};
    
    % Get path info about plexon events files
    f1 = 'path_data_combined_plexon_subject';
    settings = get_settings_path_and_dates_ini_v11(settings, f1);
    p1_plex = settings.(f1);
    
    % Get path info about psychtoolbox files
    f1 = 'path_data_combined_subject';
    settings_psy = get_settings_path_and_dates_ini_v11(settings);
    p1_psy = settings.(f1);
    
    % Get path info about existing plexon raw plexon events file
    f1 = 'path_data_plexon_temp_2_subject';
    settings_plex_temp_2 = get_settings_path_and_dates_ini_v11(settings, f1);
    p1_plex_temp_2 = settings.(f1);
    
    % Which dates are used?
    dates_used = settings.data_sessions_to_analyze;
    
    for i_date = 1:length(dates_used)
        
        clear var1; clear var2; clear var3;
        
        % Which date is it
        settings.date_current = dates_used(i_date);
        
        %============
        % Psychtoolbox file path & file
        ind = date_current==settings_psy.index_dates;
        folder_name_psy = settings_psy.index_directory{ind};
        path1_psy = [p1_psy, folder_name_psy, '/', folder_name_psy, '.mat'];
        
        %==========
        % Figures folder
        path_fig = sprintf('%s%s/%s/%s/', settings.path_figures, settings.figure_folder_name, settings.subject_current, folder_name_psy);
        
        % Check whetther to over-write data or not
        if ~isdir(path_fig) || settings.overwrite==1
            
            % Psychtoolbox data
            % Load file
            var1 = get_struct_v11(path1_psy);
            
            %=============
            % Plexon events file path & file
            ind = date_current==settings.index_dates;
            folder_name_plex = settings.index_directory{ind};
            path1_plex = [p1_plex, folder_name_plex, '/', folder_name_plex, '_events_matched.mat'];
            
            % Load file
            var2 = get_struct_v11(path1_plex);
            
            %==============
            % Non-matched, raw plexon events
            
            % Current plexon folder to be analysed (multiple sessions)
            sessions_used = find(date_current == settings_plex_temp_2.index_dates);
            sp1 = []; sp2 = []; % Initialize var
            
            % Do analysis for each session
            for i_session = 1:numel(sessions_used)
                
                % Raw plexon events file path & file
                ind = sessions_used(i_session);
                folder_name_plex_temp_2 = settings_plex_temp_2.index_directory{ind};
                path1_plex_temp_2 = [p1_plex_temp_2, folder_name_plex_temp_2, '/' folder_name_plex_temp_2, '_events.mat'];
                
                % Load file
                temp1 = get_struct_v11(path1_plex_temp_2);
                sp1_temp = temp1.event_ts{dset1_fields.msg1_code}*1000; % Message timing is reset to milliseconds
                sp2_temp = temp1.event_ts{dset1_fields.msg2_code}*1000; % Message timing is reset to milliseconds
                
                % Concatenate multiple recording sessions
                if ~isempty(sp1_temp)
                    if isempty(sp1)
                        sp1 = sp1_temp;
                    else
                        sp1 = [sp1; sp1_temp];
                    end
                    var3.sp1 = sp1;
                end
                
                % Concatenate multiple recording sessions
                if ~isempty(sp2_temp)
                    if isempty(sp2)
                        sp2 = sp2_temp;
                    else
                        sp2 = [sp2; sp2_temp];
                    end
                    var3.sp2 = sp2;
                end
                
            end
            % End of analysis for each session
            
            %% Do the plotting
            
            if ~isempty(var1) && ~isempty(var2) && ~isempty(var3)
                
                % Overwrite figure folders
                if ~isdir(path_fig) || settings.overwrite==1
                    if ~isdir(path_fig)
                        mkdir(path_fig)
                    elseif isdir(path_fig)
                        try
                            rmdir(path_fig, 's')
                        end
                        mkdir(path_fig)
                    end
                end
                
                % Initialize empty file
                f_name = sprintf('%s%s.txt', path_fig, folder_name_psy);
                fclose('all');
                fout = fopen(f_name,'w');
                
                %===================
                % Prepare figure
                %===================
                
                % Initialize variables of interest
                ses1 = var1.session;
                psy1 = var1.(dset1_fields.msg1);
                msg1 = var2.msg_1; % Matched data
                sp1 = var3.sp1; % Raw data
                psy2 = var1.(dset1_fields.msg2);
                msg2 = var2.msg_2; % Matched data
                sp2 = var3.sp2; % Raw data
                
                %==========
                % Part 1 - plot matching blocks
                
                h = subplot(2,2,1);
                hold on;
                
                % Prepare colors for each session
                col_min = [0.2, 0.2, 0.5]; % Session 1
                col_max =  [0.4, 0.4, 1]; % Last session
                d1 = col_max-col_min;
                stepsz = 1/(max(ses1));
                for i=1:max(ses1)
                    color1_line(i,:)=col_min + (d1*stepsz)*(i-1);
                end
                % Color for undetected events
                c1 = [1, 0.2, 0.2];
                
                % Plot each detected event
                for i=1:length(msg1)
                    fcol1 = ses1(i);
                    index = find(sp1==msg1(i)); % Select current trial
                    if length(index)==1
                        h = plot (index, sp1(index), '.');
                        set (h(end), 'LineWidth', settings.wlinegraph, 'Color', color1_line(fcol1,:))
                    end
                end
                
                % Plot each undetected plexon event
                for i=1:length(sp1)
                    index = find(sp1(i)==msg1); % Select current session
                    if isempty(index)
                        h=plot(i, sp1(i), '.');
                        set (h(end), 'LineWidth', settings.wlinegraph, 'Color', c1)
                    end
                end
                
                set (gca,'FontSize', settings.fontsz);
                set(gca,'XLim',[-50 length(sp1)+50]);
                xlabel ('Message number', 'FontSize', settings.fontszlabel);
                ylabel ('Plexon time', 'FontSize', settings.fontszlabel);
                title('Detected plex events', 'FontSize', settings.fontszlabel)
                
                
                %==============
                % Part 2 - compare eyelink and eyetracker event timing (session by session)
                h = subplot(2,2,2);
                hold on;
                
                % Prepare colors for each session
                col_min = [0.2, 0.2, 0.5]; % Session 1
                col_max =  [0.4, 0.4, 1]; % Last session
                d1 = col_max-col_min;
                stepsz = 1/(max(ses1));
                for i=1:max(ses1)
                    color1_line(i,:)=col_min + (d1*stepsz)*(i-1);
                end
                
                % Plot each detected event
                a = unique(ses1);
                for i=1:length(a)
                    
                    % Select current session
                    index = ses1==a(i);
                    d1 = msg1(index);
                    d2 = psy1(index);
                    
                    % Plot each detected event time
                    for j=1:length(d1)
                        fcol1 = a(i);
                        if ~isnan(d1(j)) && ~isnan(d2(j))
                            h = plot (d2(j), d1(j), '.');
                            set (h(end), 'LineWidth', settings.wlinegraph, 'Color', color1_line(fcol1,:))
                        end
                    end
                end
                
                set (gca,'FontSize', settings.fontsz);
                xlabel ('Psy start time', 'FontSize', settings.fontszlabel);
                ylabel ('Plex start time', 'FontSize', settings.fontszlabel);
                title('Plex vs psy trial start', 'FontSize', settings.fontszlabel)
                
                
                %===============
                % Part 3 - compare eyelink and eyetracker event timing
                h = subplot(2,2,3);
                hold on;
                
                a = unique(ses1);
                d1_f = []; d2_f = [];
                for i=1:length(a)
                    index = ses1==a(i);
                    d1 = msg1(index);
                    d2 = psy1(index);
                    d1 = diff(d1); % Calculate inter-trial interval
                    d2 = diff(d2); % Calculate inter-trial interval
                    d1_f = [d1_f; d1];
                    d2_f = [d2_f; d2];
                end
                histogram(d1_f-d2_f, 50, 'FaceColor', [0.3, 0.8, 0.3]);
                
                set (gca,'FontSize', settings.fontsz);
                xlabel ('Time difference (ms)', 'FontSize', settings.fontszlabel);
                ylabel ('Occurence counts', 'FontSize', settings.fontszlabel);
                title('Plex-psy diff(trial start)', 'FontSize', settings.fontszlabel)
                
                
                %===============
                % Part 4 - compare trial durations
                h = subplot(2,2,4);
                hold on;
                
                % Trial duration
                d1 = msg2-msg1;
                d2 = psy2-psy1;
                
                histogram(d1-d2, 50, 'FaceColor', [0.3, 0.8, 0.3]);
                
                set (gca,'FontSize', settings.fontsz);
                xlabel ('Time difference (ms)', 'FontSize', settings.fontszlabel);
                ylabel ('Occurence counts', 'FontSize', settings.fontszlabel);
                title('Plex-psy trial dur diff', 'FontSize', settings.fontszlabel)
                
                % Export the figure & save it
                
                f_name = sprintf('%splex_events_match', path1_fig);
                set(gcf, 'PaperPositionMode', 'manual');
                set(gcf, 'PaperUnits', 'inches');
                set(gcf, 'PaperPosition', settings.figsize1)
                set(gcf, 'PaperSize', [settings.figsize1(3),settings.figsize1(4)]);
                print (f_name, '-dpdf')
                close all;
                %===============
                
                %=============
                % Text output
                %=============
                
                % Check whether any psychtoolbox session was not recorded
                targettext='Total number of psychtoolbox sessions recorded %d \n';
                fprintf(fout, targettext, max(ses1));
                
                % Report how many events were detected for each session
                a = unique(ses1);
                for i = 1:length(a)
                    index1 = ses1==a(i); % Trials in given session session
                    r1 = sum(~isnan(msg1(index1))); % Detected plexon trials for that session
                    targettext='Session number %d: non-detected trials are %d; matched %d/%d trials \n';
                    fprintf(fout, targettext, a(i), sum(index1)-r1, r1, sum(index1));
                end
                
                
                
                %===================
                %===================
                
            elseif isempty(var1)
                fprintf('Psychtoolbox data file "%s.mat" does not exist for a date %s, no plots prepared\n', folder_name_psy, num2str(date_current));
            elseif isempty(var2)
                fprintf('Matched events file "%s.mat" does not exist for a date %s, no plots prepared\n', folder_name_plex, num2str(date_current));
            elseif isempty(var3)
                fprintf('Raw events files for the date %s do not exist (multiple files possible), no plots prepared\n', num2str(date_current));
            end
            % End of analysis
        
        else
            fprintf('Figures folder already exists, skipping plotting for a given day %s\n', num2str(date_current));
        end
        % End of check whether to over-write figures or not
        
    end
    % Pre-processing for each day is over
    
end
% Pre-processng for each subject is over
