% Plots spike rasters for different neurons/days

%% INI

% Is function name defined?
if isfield (settings, 'function_name')
    % OK
else
    error('No function_name provided, can not run the code');
end

% Show the file you are running
% p1 = mfilename;
p1 = settings.function_name;
fprintf('\n=========\n')
fprintf('Current data analysis file:  %s\n', p1)
fprintf('=========\n')

% Initialize settings
if ~exist('settings', 'var')
    settings = struct;
end
settings = get_settings_ini_v10(settings);

% Data folder
if ~isfield (settings, 'temp1_data_folder')
    settings.temp1_data_folder = 'data_combined_plexon';
end

%% Figure/stats folder name

a = settings.function_name;
m = numel(settings.exp_name);
if strncmp(a, settings.function_name, m)
    b = settings.function_name(m+2:end);
else
    b = settings.function_name(1:end);
end

if numel(b)>0
    settings.figure_folder_name = b;
else
    a = 'undefined_figure';
    fprintf('\nNo figure folder name defined, initializing default "%s"\n', a);
    settings.figure_folder_name = a;
end


%% Run analysis

for i_subj=1:length(settings.subjects)
    
    % Select curent subject
    settings.subject_current = settings.subjects{i_subj};
    
    % Which dates to run?
    settings.dates_used = get_dates_used_v10 (settings, settings.temp1_data_folder);
    
    if isempty(settings.dates_used)
        fprintf('No dates for the specified range detected, skipping analysis\n')
    end
    
    % Analysis for each day
    for i_date = 1:numel(settings.dates_used)
        
        % Which date is it
        settings.date_current = settings.dates_used(i_date);
        
        % How many sessions are used?
        settings.sessions_used = get_sessions_used_v10(settings, settings.temp1_data_folder);
        
        % Analysis for each plexon recording session
        for i_session = 1:numel(settings.sessions_used)
            
            % Which session is it
            if numel(settings.sessions_used)>1 && ~isnan(settings.sessions_used(i_session))
                settings.session_current = settings.sessions_used(i_session);
                fprintf('\nAnalysing "%s" data for the date %s and session %s\n', ...
                    settings.subject_current, num2str(settings.date_current), num2str(settings.session_current));
            else
                settings.session_current = [];
                fprintf('\nAnalysing "%s" data for the date %s\n', settings.subject_current, num2str(settings.date_current));
            end
            
            %==========
            % Figures folder
            [~, path_fig, file_name] = get_generate_path_v10(settings, 'figures', [], settings.session_current);
            
            % Now decide whether to over-write analysis
            if ~isdir(path_fig) || settings.overwrite==1
                
                %==============
                % Create figure folders. Delete old figures.
                if ~isdir(path_fig)
                    mkdir(path_fig)
                    fprintf('Created new figures folder "%s" for the date %s\n', settings.figure_folder_name, num2str(settings.date_current));
                elseif isdir(path_fig)
                    fprintf('Overwriting figures "%s" for the date %s (overwrite only .pdf files)\n', settings.figure_folder_name, num2str(settings.date_current));
                    % Delete figure files, leave other files un-touched
                    a = dir(path_fig);
                    for i = 1:numel(a)
                        b = a(i).name;
                        m = length(b);
                        if length(b)>4 && strcmp(b(m-3:m), '.pdf')
                            path1 = sprintf('%s%s', path_fig, b);
                            delete (path1)
                        end
                    end
                end
                
                %=================
                % Initialize text file for statistics
                f_ext = sprintf ('_stats.txt');
                path1 = get_generate_path_v10(settings, 'figures', f_ext, settings.session_current);
                fclose('all');
                fout = fopen(path1,'w');
                
                %============
                % Psychtoolbox path & file
                path1 = get_generate_path_v10(settings, 'data_combined', '.mat');
                S = get_struct_v11(path1);
                
                %============
                % Saccades path & file
                path1 = get_generate_path_v10(settings, 'data_combined', '_saccades.mat');
                sacc1 = get_struct_v11(path1);
                
                %============
                % Events path & file
                path1 = get_generate_path_v10(settings, settings.temp1_data_folder, '_events_matched.mat', settings.session_current);
                events_mat = get_struct_v11(path1);
                
                %============
                % Unit descriptives file
                [path1] = get_generate_path_v10(settings, settings.temp1_data_folder, '_unit_descriptives.mat', settings.session_current);
                unit_descriptives = get_struct_v11(path1);
                
                % Get spikes
                if ~isempty(fieldnames(events_mat))
                    
                    %=============
                    %=============
                    % Determine neurons that exist on a given day
                    [~, path1] = get_generate_path_v10(settings, settings.temp1_data_folder);
                    spikes_init = get_path_spikes_v11 (path1, settings.subject_current); % Path to each neuron
                    
                    % Find all units for given recording.
                    % Sort them in ascending order
                    a = spikes_init.index_channel;
                    a = a(~isnan(a));
                    settings.channels_available = a;
                    
                    if isempty(settings.channels_available)
                        fprintf('No neuro units for the date %s detected, skipping analysis for this day\n', num2str(settings.date_current))
                    end
                    
                    % Select a subset of units to use (for debugging usually)
                    settings.channels_used = settings.channels_available;
                    
                    % Run analysis for each unit
                    for i_unit = 1:numel(settings.channels_used)
                        
                        % Which channel is it
                        settings.channel_current = settings.channels_used(i_unit);
                        
                        % Neuron name
                        settings.neuron_name = spikes_init.index_file_name_short{settings.channel_current};
                    
                        %=================
                        % Load spikes data
                        path1 = spikes_init.index_path{settings.channel_current};
                        spikes1 = get_struct_v11(path1);
                        
                        % Prepare unit name
                        fprintf('\nWorking on analysis for the neural unit %s\n', settings.neuron_name)
                        
                        
                        %% DO YOUR ANALYSIS HERE
                        
                        eval(settings.function_name)
                        
                        
                    end
                    % End of each neuron
                end
                % End of decision whether events mat exists
                
            else
                fprintf('Figures folder "%s" for the date %s already exists, skipping analysis\n', settings.figure_folder_name, num2str(settings.date_current))
            end
            % End of decision to over-write figure folder or not
            
        end
        % End of each session
        
    end
    % End of each date
    
end
% End of each subject


settings = rmfield (settings, 'temp1_data_folder');
