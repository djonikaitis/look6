% Plot whether plexon file detection was successful
% V1.0: November 1, 2016
% V1.1 January 12, 2018. Adapted code to new analysis conventions.
% Donatas Jonikaitis

close all;

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


%% Some settings

% Path to figures and statistics
settings.figure_folder_name = 'plex_psy_events_match';
settings.stats_file_name = sprintf('statistics_%s_', settings.figure_folder_name);
settings.figsize1 = [0, 0, 5, 5]; % Change figure into bigger than usual


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
    
    clear var1; clear var2; clear var3;
    
    % Which dates are used?
    dates_used = settings.data_sessions_to_analyze;
    
    for i_date = 1:length(dates_used)
        
        % Which date is it
        date_current = dates_used(i_date);
        
        %============
        % Psychtoolbox file path
        ind = date_current==settings_psy.index_dates;
        folder_name_psy = settings_psy.index_directory{ind};
        path1_psy = [p1_psy, folder_name_psy, '/', folder_name_psy, '.mat'];
        
        % Load psychtoolbox file
        var1 = get_struct_v11(path1_psy);
        
        %=============
        % Plexon events file path
        ind = date_current==settings.index_dates;
        folder_name_plex = settings.index_directory{ind};
        path1_plex = [p1_plex, folder_name_plex, '/', folder_name_plex, '_events_matched.mat'];
        
        % Load plexon events combined
        var2 = get_struct_v11(path1_plex);
        
        %==============
        % Non-matched plexon data
        

%         
%         %===============
%         %===============
%         % Prepare a combined file with easy trial indexing
%         
%         file_name_psy = [folder_name];
%         file_name_plex = [folder_name,'_events_matched'];
%         file_name_plex_nm = [folder_name,'_events'];
%         path_in_psy = sprintf('%s%s/%s.mat', settings.path_data_combined_subject, folder_name, file_name_psy);
%         path_in_plex = sprintf('%s%s/%s.mat', settings.path_data_combined_plexon_subject, folder_name, file_name_plex);
%         path_in_plex_nm = sprintf('%s%s/%s.mat', settings.path_data_combined_plexon_subject, folder_name, file_name_plex_nm);
%         
%         if exist(path_in_plex, 'file')==2
%             
%             % Path to subject specific figures folder
%             path1_fig = sprintf('%s%s/%s/%s/', settings.path_figures, settings.figure_folder_name, settings.subject_current, folder_name);
%             
%             % Check whether to plot figure
%             
%             if ~isdir(path1_fig) || settings.overwrite==1
%                 
%                 if ~isdir(path1_fig)
%                     mkdir(path1_fig)
%                 elseif isdir(path1_fig)
%                     rmdir(path1_fig, 's')
%                     mkdir(path1_fig)
%                 end
%                 
%                 % Initialize text file for statistics
%                 nameOut = sprintf('%s%s.txt', path1_fig, settings.stats_file_name); % File to be outputed
%                 fclose('all');
%                 fout = fopen(nameOut,'w');
%                 

%                 
%                 % Load plexon file, non-matched
%                 path1 = path_in_plex_nm;
%                 spikes1 = struct; varx = struct;
%                 if exist(path1, 'file')
%                     varx = load(path1);
%                     f1 = fieldnames(varx);
%                     if length(f1)==1
%                         spikes1 = varx.(f1{1});
%                     end
%                 end
%                 
%                 % Initialize variables of interest
%                 ses1 = var1.session;
%                 psy1 = var1.first_display;
%                 sp1 = spikes1.event_ts{1}*1000; % Its raw data, reset to milliseconds
%                 msg1 = plexon_ev.msg_1;
%                 psy2 = var1.target_off;
%                 msg2 = plexon_ev.msg_2;
%                 sp2 = spikes1.event_ts{2}*1000; % Its raw data, reset to milliseconds
%                 
%                 
%                 %==========
%                 % Prepare figure
%                 %==========
%                 
%                 %==========
%                 % Part 1 - plot matching blocks
%                 
%                 h = subplot(2,2,1);
%                 hold on;
%                 
%                 
%                 % Prepare colors for each session
%                 col_min = [0.2, 0.2, 0.5]; % Session 1
%                 col_max =  [0.4, 0.4, 1]; % Last session
%                 d1 = col_max-col_min;
%                 stepsz = 1/(max(ses1));
%                 for i=1:max(ses1)
%                     color1_line(i,:)=col_min + (d1*stepsz)*(i-1);
%                 end
%                 % Color for undetected events
%                 c1 = [1, 0.2, 0.2];
%                 
%                 % Plot each detected event
%                 for i=1:length(msg1)
%                     fcol1 = ses1(i);
%                     index = find(sp1==msg1(i)); % Select current trial
%                     if length(index)==1
%                         h = plot (index, sp1(index), '.');
%                         set (h(end), 'LineWidth', settings.wlinegraph, 'Color', color1_line(fcol1,:))
%                     end
%                 end
%                 
%                 % Plot each undetected plexon event
%                 for i=1:length(sp1)
%                     index = find(sp1(i)==msg1); % Select current session
%                     if isempty(index)
%                         h=plot(i, sp1(i), '.');
%                         set (h(end), 'LineWidth', settings.wlinegraph, 'Color', c1)
%                     end
%                 end
%                 
%                 set (gca,'FontSize', settings.fontsz);
%                 set(gca,'XLim',[-50 length(sp1)+50]);
%                 xlabel ('Message number', 'FontSize', settings.fontszlabel);
%                 ylabel ('Plexon time', 'FontSize', settings.fontszlabel);
%                 title('Detected plex events', 'FontSize', settings.fontszlabel)
%                 
%                 
%                 %==============
%                 % Part 2 - compare eyelink and eyetracker event timing (session by session)
%                 h = subplot(2,2,2);
%                 hold on;
%                 
%                 % Prepare colors for each session
%                 col_min = [0.2, 0.2, 0.5]; % Session 1
%                 col_max =  [0.4, 0.4, 1]; % Last session
%                 d1 = col_max-col_min;
%                 stepsz = 1/(max(ses1));
%                 for i=1:max(ses1)
%                     color1_line(i,:)=col_min + (d1*stepsz)*(i-1);
%                 end
%                 
%                 % Plot each detected event
%                 a = unique(ses1);
%                 for i=1:length(a)
%                     
%                     % Select current session
%                     index = ses1==a(i);
%                     d1 = msg1(index);
%                     d2 = psy1(index);
%                     
%                     % Plot each detected event time
%                     for j=1:length(d1)
%                         fcol1 = a(i);
%                         if ~isnan(d1(j)) && ~isnan(d2(j))
%                             h = plot (d2(j), d1(j), '.');
%                             set (h(end), 'LineWidth', settings.wlinegraph, 'Color', color1_line(fcol1,:))
%                         end
%                     end
%                 end
%                 
%                 set (gca,'FontSize', settings.fontsz);
%                 xlabel ('Psy start time', 'FontSize', settings.fontszlabel);
%                 ylabel ('Plex start time', 'FontSize', settings.fontszlabel);
%                 title('Plex vs psy trial start', 'FontSize', settings.fontszlabel)
%                 
%                 %===============
%                 % Part 3 - compare eyelink and eyetracker event timing
%                 h = subplot(2,2,3);
%                 hold on;
%                 
%                 a = unique(ses1);
%                 d1_f = []; d2_f = [];
%                 for i=1:length(a)
%                     index = ses1==a(i);
%                     d1 = msg1(index);
%                     d2 = psy1(index);
%                     d1 = diff(d1); % Calculate inter-trial interval
%                     d2 = diff(d2); % Calculate inter-trial interval
%                     d1_f = [d1_f; d1];
%                     d2_f = [d2_f; d2];
%                 end
%                 histogram(d1_f-d2_f, 50, 'FaceColor', [0.3, 0.8, 0.3]);
%                 
%                 set (gca,'FontSize', settings.fontsz);
%                 xlabel ('Time difference (ms)', 'FontSize', settings.fontszlabel);
%                 ylabel ('Occurence counts', 'FontSize', settings.fontszlabel);
%                 title('Plex-psy diff(trial start)', 'FontSize', settings.fontszlabel)
%                 
%                 
%                 %===============
%                 % Part 4 - compare trial durations
%                 h = subplot(2,2,4);
%                 hold on;
%                 
%                 % Trial duration
%                 d1 = msg2-msg1;
%                 d2 = psy2-psy1;
%                 
%                 histogram(d1-d2, 50, 'FaceColor', [0.3, 0.8, 0.3]);
%                 
%                 set (gca,'FontSize', settings.fontsz);
%                 xlabel ('Time difference (ms)', 'FontSize', settings.fontszlabel);
%                 ylabel ('Occurence counts', 'FontSize', settings.fontszlabel);
%                 title('Plex-psy trial dur diff', 'FontSize', settings.fontszlabel)
%                 
%                 % Export the figure & save it
%                 
%                 f_name = sprintf('%splex_events_match', path1_fig);
%                 set(gcf, 'PaperPositionMode', 'manual');
%                 set(gcf, 'PaperUnits', 'inches');
%                 set(gcf, 'PaperPosition', settings.figsize1)
%                 set(gcf, 'PaperSize', [settings.figsize1(3),settings.figsize1(4)]);
%                 print (f_name, '-dpdf')
%                 close all;
%                 %===============
%                 
%                 %=============
%                 % Text output
%                 %=============
%                 
%                 % Check whether any psychtoolbox session was not recorded
%                 targettext='Total number of psychtoolbox sessions recorded %d \n';
%                 fprintf(fout, targettext, max(ses1));
%                 
%                 % Report how many events were detected for each session
%                 a = unique(ses1);
%                 for i = 1:length(a)
%                     index1 = ses1==a(i); % Trials in given session session
%                     r1 = sum(~isnan(msg1(index1))); % Detected plexon trials for that session
%                     targettext='Session number %d: non-detected trials are %d; matched %d/%d trials \n';
%                     fprintf(fout, targettext, a(i), sum(index1)-r1, r1, sum(index1));
%                 end
%                 
%             else
%                 fprintf('\nPlex vs psych events figures folder %s exists, no plotting\n', folder_name)
%             end
%             % End of checking whether directory existed
%             
%         else
%             fprintf('\nPlexon events %s_plex_events  does not exist, no plots prepared\n', folder_name)
%         end
%         % End of conversion plexon event extraction
%         %==================
        
    end
    % Pre-processing for each day is over
    
end
% Pre-processng for each subject is over
