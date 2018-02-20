% Change raw data files to be compliant with current analysis.
% Changes are renaming columns or fixing bugs in the code that are well
% established.
% No data changes in this code.
%
% V1.0 October 30, 2017
% V1.1 February 19, 2018 Updated path definitions

function  preprocessing_overwrite_raw_settings_v11(settings)

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

folder_name = 'data_psychtoolbox';

% Run pre-processing for each subject
for i_subj = 1:length(settings.subjects)
    
    % Select curent subject
    settings.subject_current = settings.subjects{i_subj};
    
    % Get subject folder paths and dates to analyze
    settings.dates_used = get_dates_used_v10 (settings, folder_name);
    
    %===========
    % Find an index of dates to be modified
    settings.overwrite_temp_switch = 0;
    a1 = sprintf('%s_overwrite_raw_settings', settings.exp_name); % Path to file containing trial settings
    eval(a1)
    
    % Analysis for each separate day
    for i_date = 1:length(settings.dates_used)
        
        % Which date is it
        settings.date_current = settings.dates_used(i_date);
        
        % By default, it will not over-write the data
        settings.overwrite_temp_switch = 0;
        if exist('overwrite_temp_index', 'var')
            b = [];
            for i = 1:numel (overwrite_temp_index)
                a = overwrite_temp_index{i};
                b(i) = sum(settings.date_current == a);
            end
            if sum(b)>0
                settings.overwrite_temp_switch = 1;
                fprintf('\nCurrent date %s will be modified as the raw data file\n', num2str(settings.date_current))
            else
                fprintf('\nCurrent date %s is not in the list to be modified as the raw data file\n',  num2str(settings.date_current))
            end
        else
            fprintf('\nScript for over-writing raw data has no dates specified, no files will be modified\n')
        end
        
        if settings.overwrite_temp_switch == 1
            
            % Current plexon folder to be analysed (multiple sessions)
            sessions_used = get_sessions_used_v10(settings, folder_name);
            
            % Do analysis for each desired session
            % No changes needed for this section
            for i_session = 1:numel(sessions_used)
                
                % Which recorded to use
                session_ind = sessions_used(i_session);
                
                % Generate output path
                [path1, ~, file_name] = get_generate_path_v10(settings, folder_name, '_data_structure.mat', session_ind);
                [path1_copy, ~, file_name_copy] = get_generate_path_v10(settings, folder_name, '_data_structure_original.mat', session_ind);
                
                %================
                % Analysis
                %================
                
                if ((exist(path1, 'file') && ~exist(path1_copy, 'file')) || settings.overwrite==1) && exist(path1, 'file')
                    
                    fprintf('\nChanges to exp settings file "%s" with modifications and bug fixes\n', file_name)
                    
                    %==========
                    % Save original file before doing changes
                    % Original data is saved only once
                    if ~exist(path1_copy, 'file')
                        copyfile(path1, path1_copy)
                        fprintf('Will save original settings file to a copy "%s"\n', file_name_copy)
                    else
                        fprintf('Copy of the settings file "%s" exists, original file is kept intact\n', file_name_copy)
                    end
                    
                    % Now open the original data file (always)
                    var1 = get_struct_v11(path1_copy);
                    
                    %===========
                    % Main preprocessing function
                    a1 = sprintf('%s_overwrite_raw_settings', settings.exp_name); % Path to file containing trial settings
                    eval(a1)
                    
                    %===========
                    % Save data
                    expsetup = var1;
                    save (path1, 'expsetup')
                    
                elseif ~exist(path1, 'file')
                    fprintf('\nData file "%s" does not exist, skipping analysis\n', file_name)
                elseif exist(path1, 'file') && settings.overwrite==0
                    fprintf('\nCopy of the settings file "%s" already exists, skipping analysis\n', file_name_copy)
                else
                    fprintf('\nUnknown file localisation error \n')
                end
                % End of analysis
                
            end
            % End of each session
        end
        % End of settings.overwrite_temp_switch
    end
    % End of each day
end
% End of analysis for each subject
