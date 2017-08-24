% Plot whether plexon file detection was successful
% V1.0: November 1, 2016
% Donatas Jonikaitis

% clear all;
close all;
% clc;


%% Initial setup

% Loading the files needed
if ~exist('settings', 'var')
    settings = struct;
end

% Experiment name
if ~isfield (settings, 'exp_name')
    settings.exp_name = input ('Type in experiment name: ', 's');
end

% Default subject number: all subjects
if ~isfield (settings, 'subjects')
    sN1 = 'all'; % Subject name
end

% Run settings file:
eval(sprintf('%s_settings', settings.exp_name)); % Load general settings

% Overwriting analysis defaults
if ~isfield(settings, 'overwrite')
    settings.overwrite = 1;
end


%% Some settings

% Path to figures and statistics
settings.figure_folder_name = 'plex_psy_events_match';
settings.stats_file_name = sprintf('statistics_%s_', settings.figure_folder_name);
settings.figsize1 = [0, 0, 5, 5]; % Change figure into bigger than usual


%% Run preprocessing

for i_subj=1:length(settings.subjects)
    
    settings.subject_name=settings.subjects{i_subj}; % Select curent subject
    
    % Initialize subject specific folders where data is stored
    for i=1:length(settings.path_spec_names)
        v1 = ['path_', settings.path_spec_names{i}];
        settings.(v1) = sprintf ('%s%s/', settings.path_spec_folder{i}, settings.subject_name);
    end
    
    % Get index of every folder for a given subject
    p1=settings.path_data_combined_plexon;
    session_init = get_path_dates_v20(p1, settings.subject_name);
    
    % Save session_init matrix into settings matrix
    % This part is necessary for preprocessing to run
    f1_data = fieldnames(session_init);
    for i=1:length(f1_data)
        settings.(f1_data{i})= session_init.(f1_data{i});
    end
    
    % Which date to analyse (all days or a single day)
    if settings.preprocessing_sessions_used==1
        ind = [1:length(session_init.index_unique_dates)];
    elseif settings.preprocessing_sessions_used==2
        ind = find(session_init.index_unique_dates==settings.preprocessing_day_id);
    elseif settings.preprocessing_sessions_used==3
        ind = length(session_init.index_unique_dates);
    end
    date_index = session_init.index_unique_dates(ind);
    
    
    for i_date = 1:length(date_index)
        
        % Current folder to be analysed (raw date, with session index)
        i1 = find(date_index(i_date)==settings.index_dates);
        folder_name = settings.index_directory{i1};
        
        %===============
        %===============
        % Prepare a combined file with easy trial indexing
        
        file_name_psy = [folder_name,'_settings'];
        file_name_plex = [folder_name,'_events_matched'];
        file_name_plex_nm = [folder_name,'_events'];
        path_in_psy = sprintf('%s%s/%s.mat', settings.path_data_combined, folder_name, file_name_psy);
        path_in_plex = sprintf('%s%s/%s.mat', settings.path_data_combined_plexon, folder_name, file_name_plex);
        path_in_plex_nm = sprintf('%s%s/%s.mat', settings.path_data_combined_plexon, folder_name, file_name_plex_nm);
        
        if exist(path_in_plex, 'file')
            
            % Path to subject specific figures folder
            path1_fig = sprintf('%s%s/%s/%s/', settings.path_figures, settings.figure_folder_name, settings.subject_name, folder_name);
            
            % Check whether to plot figure
            
            if ~isdir(path1_fig) || settings.overwrite==1
                
                if ~isdir(path1_fig)
                    mkdir(path1_fig)
                elseif isdir(path1_fig)
                    rmdir(path1_fig, 's')
                    mkdir(path1_fig)
                end
                
                % Initialize text file for statistics
                nameOut = sprintf('%s%s.txt', path1_fig, settings.stats_file_name); % File to be outputed
                fclose('all');
                fout = fopen(nameOut,'w');
                
                %==============
                % Load all settings
                path1 = path_in_psy;
                var1 = struct; varx = struct;
                if exist(path1, 'file')
                    varx = load(path1);
                    f1 = fieldnames(varx);
                    if length(f1)==1
                        var1 = varx.(f1{1});
                    end
                end
                
                % Load plexon file, matched
                path1 = path_in_plex;
                plexon_ev = struct; varx = struct;
                if exist(path1, 'file')
                    varx = load(path1);
                    f1 = fieldnames(varx);
                    if length(f1)==1
                        plexon_ev = varx.(f1{1});
                    end
                end
                
                % Load plexon file, non-matched
                path1 = path_in_plex_nm;
                spikes1 = struct; varx = struct;
                if exist(path1, 'file')
                    varx = load(path1);
                    f1 = fieldnames(varx);
                    if length(f1)==1
                        spikes1 = varx.(f1{1});
                    end
                end
                
                % Initialize variables of interest
                ses1 = var1.session;
                psy1 = var1.eyelink_events.first_display;
                sp1 = spikes1.event_ts{1}*1000; % Its raw data, reset to milliseconds
                msg1 = plexon_ev.msg_1;
                psy2 = var1.eyelink_events.targets_off;
                msg2 = plexon_ev.msg_2;
                sp2 = spikes1.event_ts{2}*1000; % Its raw data, reset to milliseconds
                
                
                %==========
                % Prepare figure
                %==========
                
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
                
            else
                fprintf('\nPlex vs psych events figures folder %s exists, no plotting\n', folder_name)
            end
            % End of checking whether directory existed
            
        else
            fprintf('\nPlexon events %s_plex_events  does not exist, no plots prepared\n', folder_name)
        end
        % End of conversion plexon event extraction
        %==================
        
    end
    % Pre-processing for each day is over
    
end
% Pre-processng for each subject is over
