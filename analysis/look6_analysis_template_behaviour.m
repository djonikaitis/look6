% Plots spike rasters for different stimulus background colors

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
    settings.temp1_data_folder = 'data_combined';
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
    
    if isempty( settings.dates_used)
        fprintf('No dates for the specified range detected, skipping analysis\n')
    end
    
    % Analysis for each day
    for i_date = 1:length(settings.dates_used)
        
        % Which date is it
        settings.date_current = settings.dates_used(i_date);
        fprintf('\nAnalysing data for subject "%s" for the date %s\n', settings.subject_current, num2str(settings.date_current));
        
        %==========
        % Figures folder
        [~, path_fig, ~] = get_generate_path_v10(settings, 'figures');
        
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
            path1 = get_generate_path_v10(settings, 'figures', f_ext);
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
            
            
            %% DO YOUR ANALYSIS HERE
            
            if ~isempty(S) && ~isempty(sacc1)
                eval(settings.function_name)
            end
            
            
        else
            fprintf('Figures folder "%s" for the date %s already exists, skipping analysis\n', settings.figure_folder_name, num2str(settings.date_current))
        end
        % End of decision to over-write figure folder or not
        
    end
    % End of each date
    
end
% End of each subject

settings = rmfield (settings, 'temp1_data_folder');
