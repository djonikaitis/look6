% Plots spike rasters for different neurons/days

% p1 = mfilename;
p1 = settings.function_name;
fprintf('\n=========\n')
fprintf('Current data analysis file:  %s\n', p1)
fprintf('=========\n')

% Loading the files needed
if ~exist('settings', 'var')
    settings = struct;
end
settings = get_settings_ini_v10(settings);


%% Extra settings

if isfield (settings, 'function_name') && ~isfield (settings, 'figure_folder_name')
    
    % Extract figure folder name
    a = settings.function_name;
    m = numel(settings.exp_name);
    if strncmp(a, settings.function_name, m)
        b = settings.function_name(m+2:end);
    end
    
    % Create figure folder name
    if numel(b)>0
        settings.figure_folder_name = b;
    else
        a = 'undefined_figure';
        fprintf('\nNo figure folder name defined, initializing default "%s"\n', a);
        settings.figure_folder_name = a;
    end  
    
end

if ~isfield (settings, 'temp1_data_folder')
    settings.temp1_data_folder = 'data_combined_plexon';
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
            % Create figure folders
            if ~isdir(path_fig)
                mkdir(path_fig)
            elseif isdir(path_fig)
                try
                    rmdir(path_fig, 's')
                end
                mkdir(path_fig)
            end
            
            if settings.overwrite==1
                fprintf('Overwriting existing figures folder "%s" for the date %s\n', settings.figure_folder_name, num2str(settings.date_current));
            else
                fprintf('Create new figures folder "%s" for the date %s\n', settings.figure_folder_name, num2str(settings.date_current));
            end
            
            % %=================
            % % Initialize text file for statistics
            % f_ext = sprintf ('_%s_%s', neuron_name, settings.stats_file_name);
            % path1 = get_generate_path_v10(settings, 'figures', f_ext);
            % fclose('all');
            % fout = fopen(path1,'w');
            
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
            path1 = get_generate_path_v10(settings, settings.temp1_data_folder, '_events_matched.mat');
            events_mat = get_struct_v11(path1);
            
            %=============
            % Determine neurons that exist on a given day
            [~, path1] = get_generate_path_v10(settings, settings.temp1_data_folder);
            spikes_init = get_path_spikes_v11 (path1, settings.subject_current); % Path to each neuron
            
            % Determine which units to use
            units_used = find(~isnan(spikes_init.index_unit));
            if isempty(units_used)
                fprintf('No neuro units for the date %s detected, skipping analysis for this day\n', num2str(settings.date_current))
            end
            
            % Run analysis for each unit
            for i_unit = 1:numel(units_used)
                
                current_unit = units_used(i_unit);
                
                % Prepare unit name
                neuron_name = ['ch', num2str(spikes_init.index_channel(i_unit)), '_u',  num2str(spikes_init.index_unit(i_unit))];
                fprintf('Working on analysis for the unit %s\n', neuron_name)

                %=================
                % Load spikes data
                path1 = spikes_init.index_path{current_unit};
                spikes1 = get_struct_v11(path1);
                
                
                %% DO YOUR ANALYSIS HERE
                
                eval(settings.function_name)
                
                
            end
            % End of each neuron
            
        else
            fprintf('Figures folder "%s" for the date %s already exists, skipping analysis\n', settings.figure_folder_name, num2str(settings.date_current))
        end
        % End of decision to over-write figure folder or not
        
    end
    % End of each date
    
end
% End of each subject

% Clear out figure folder name
settings = rmfield(settings, 'figure_folder_name');
