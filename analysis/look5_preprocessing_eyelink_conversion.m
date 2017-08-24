% Combine files, extract saccades, extract spikes
% V1.0 Septeber 6, 2016
% Donatas Jonikaitis



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

% Overwriting analysis defaults
if ~isfield(settings, 'overwrite')
    settings.overwrite = 1;
end

% Run settings file:
eval(sprintf('%s_settings', settings.exp_name)); % Load general settings


%% Run preprocessing

for i=1:length(settings.subjects)
    
    settings.subject_name=settings.subjects{i}; % Select curent subject
    
    % Initialize subject specific folders where data is stored
    for i=1:length(settings.path_spec_names)
        v1 = ['path_', settings.path_spec_names{i}];
        settings.(v1) = sprintf ('%s%s/', settings.path_spec_folder{i}, settings.subject_name);
    end
    
    % Get index of every folder for a given subject
    session_init = get_path_dates_v20(settings.path_data_combined, settings.subject_name);
    if isempty(session_init.index_dates)
        fprintf('------------------\n');
        fprintf('\nNo folders with files detected, no eyelink conversion done. Directory checked was:\n')
        fprintf('%s\n', path1)
        fprintf('------------------\n');
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
        
        
        %===============
        %===============
        % Prepare a combined file with easy trial indexing
        
        folder_name = [settings.subject_name, num2str(date_index(i_date))];
        path1 = [settings.path_data_combined, folder_name, '/', folder_name, '.mat'];
        
        if ~exist(path1, 'file') || settings.overwrite==1
            
            %===============
            
            % If data is over-written, remove earlier file
            if settings.overwrite==1 && exist('path1','file')
                delete (path1)
            end
            
            fprintf('\nPreparing matrix %s which stores all settings and data\n', folder_name)

            
            %%  Convert saccades into degrees of visual angle
                        
            % File with all settings
            path0 = [settings.path_data_combined, folder_name, '/', folder_name, '_settings.mat'];
            
            % Load all settings
            var1 = struct; varx = struct;
            if exist(path0, 'file')
                varx = load(path0);
                f1 = fieldnames(varx);
                if length(f1)==1
                    var1 = varx.(f1{1});
                end
            end
                 
            % Reset saccades to degrees of visual angle
            if ~isempty(fieldnames(var1))
                sacc1 = var1.eye_data.saccades_EK; % Copy saccades
                for tid=1:length(sacc1)
                    sx1 = sacc1{tid};
                    if size(sx1,2)>1
                        sx1(:,[3,5]) = sx1(:,[3,5])-var1.screen.dispcenter{tid}(1); % Reset to display center (pixels)
                        sx1(:,[4,6]) = sx1(:,[4,6])-var1.screen.dispcenter{tid}(2);
                        sx1(:,[4,6]) = sx1(:,[4,6]) *-1; % For y coordinate multiply by (-1) - so that above display center is positive
                        sx1(:,[3,5]) = sx1(:,[3,5])./var1.screen.deg2pix{tid}; % Convert to degrees of visual angle
                        sx1(:,[4,6]) = sx1(:,[4,6])./var1.screen.deg2pix{tid}; % Convert to degrees of visual angle
                        sacc1{tid} = sx1; % Save it back into structure
                    end
                end
                var1.eye_data.saccades_EK = sacc1;                
            end
   
            
            %% Extract only fields of interest:
            
            
            % Extract all stim settings
            if ~isempty(fieldnames(var1))
                
                var_names = fieldnames(var1.stim);
                mat1 = get_fields_v10 (var1.stim, var_names); % Settings file with variables of interest
                % Extract eyelink_events
                var_names = fieldnames(var1.eyelink_events);
                mat2 = get_fields_v10 (var1.eyelink_events, var_names); % Settings file with variables of interest
                % Extract all eye_data variables
                var_names = fieldnames(var1.eye_data);
                mat3 = get_fields_v10 (var1.eye_data, var_names); % Settings file with variables of interest
                % Extract more variables of interest
                var_names={'session'; 'date'};
                mat4 = get_fields_v10 (var1, var_names); % Settings file with variables of interest
                
                % Combine those fields into one structure
                names = [fieldnames(mat1); fieldnames(mat2); fieldnames(mat3); fieldnames(mat4)];
                S = cell2struct([struct2cell(mat1); struct2cell(mat2); struct2cell(mat3); struct2cell(mat4)], names, 1);
                
                % Convert each column of expmatrix into structure
                for i=1:length(settings.em_name)
                    if ischar(settings.em_name{i})
                        S.(settings.em_name{i}) = S.expmatrix(:,i);
                    end
                end
                
            else
                fprintf('Data for given date does not exist, possible debugging mode recorded only\n')
            end
            
            
            %%  Convert raw data into degrees of visual angle
            
            path_raw = [settings.path_data_combined, folder_name, '/', folder_name, '_eye_traces.mat'];
            
            % Load raw saccades
            var2 = struct; varx = struct;
            if exist(path_raw, 'file')
                varx = load(path_raw);
                f1 = fieldnames(varx);
                if length(f1)==1
                    var2 = varx.(f1{1});
                end
            end
            
            % Reset raw data
            if ~isempty(fieldnames(var2))
                saccraw1 = var2.eye_raw; % Copy raw data
                for tid=1:length(saccraw1)
                    sx1 = saccraw1{tid};
                    if size(sx1,2)>1
                        sx1(:,2) = sx1(:,2)-var1.screen.dispcenter{tid}(1); % Reset to display center (pixels)
                        sx1(:,3) = sx1(:,3)-var1.screen.dispcenter{tid}(2);
                        sx1(:,3) = sx1(:,3) *-1; % For y coordinate multiply by (-1) - so that above display center is positive
                        sx1(:,2) = sx1(:,2)./var1.screen.deg2pix{tid}; % Convert to degrees of visual angle
                        sx1(:,3) = sx1(:,3)./var1.screen.deg2pix{tid}; % Convert to degrees of visual angle
                        saccraw1{tid} = sx1; % Save it back into structure
                    end
                end
                var2.eye_processed = saccraw1;
                SR = var2;
            end
            
            
            %% Do drift conversion
            
            if ~isempty(fieldnames(var1)) && ~isempty(fieldnames(var2))
                
                path1; % Path to file with settings and saccades;
                path_raw; % Path to file with raw saccades;
                fprintf('Doing drift correction\n')
                
                % Initialize variables
                acc1 = cell2mat(S.fixation_accuracy_drift); % Allowed window for drift correction
                sacc1 = S.saccades_EK;
                saccraw1 = SR.eye_processed;
                time1 = S.drift_maintained; % Time relative to which drift correction is done
                
                % Do drift correction
                [y, y_sacc, y_raw] = drift_correction_v13 (sacc1, saccraw1, acc1, time1);
                S.drift_correction = y;
                S.saccades_EK = y_sacc;
                SR.eye_processed = y_raw;
                
                % Save settings
                save (eval('path1'), 'S')
                % Save raw data
                save (eval('path_raw'), 'SR')
            end
            
            
        end
        % End of conversion pix2deg
        %==================

    end
    % Pre-processing for each day is over
    
end
% Pre-processng for each subject is over
