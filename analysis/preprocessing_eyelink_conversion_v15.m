% Convert eye movement data into degrees, do drift correction
% If no eye movements present, import psychtoolbox data only.
%
% V1.0 Septeber 6, 2016
% V1.1 August 26, 2017. Updated to new exp setup. Added drift plotting
% figures. Made a function.
% V1.2 October 24, 2017. Fixed error in drift correction (does not afect
% earlier experiments).
% V1.3 November 7, 2017. Eye movements are now optional, code will work
% without as well.
% V1.4 November 30, 2017. Added exp name to saved data
% V1.5 February 12, 2017. Updated path definitions.

% Donatas Jonikaitis

function  preprocessing_eyelink_conversion_v15(settings)

% Show file you are running
p1 = mfilename;
fprintf('\n=========\n')
fprintf('Current file:  %s\n', p1)
fprintf('=========\n\n')

% Loading the files needed
if ~exist('settings', 'var')
    settings = struct;
end
settings = get_settings_ini_v10(settings);


%% Extra settings

settings.figure_folder_name = 'preprocessing_drift_correction';
settings.color_map = magma(50);


%% Analysis

% Run pre-processing for each subject
for i_subj = 1:length(settings.subjects)
    
    % Select curent subject
    settings.subject_current = settings.subjects{i_subj};
    
    % Which dates to run?
    settings.dates_used = get_dates_used_v10 (settings, 'data_temp_2');
    
    % Analysis for each separate day
    for i_date = 1:length(settings.dates_used)
        
        % Which date is it
        settings.date_current = settings.dates_used(i_date);
        
        % Generate output path
        [path1_out_full, path1_out_date, file_name_out] = get_generate_path_v10(settings, 'data_combined', '.mat');
        
        % Run analysis
        if ~exist(path1_out_full, 'file') || settings.overwrite==1
            
            %==========
            % Create figure folders
            
            [~, path_fig, ~] = get_generate_path_v10(settings, 'figures');
            if ~isdir(path_fig)
                mkdir(path_fig)
            elseif isdir(path_fig)
                try
                    rmdir(path_fig, 's')
                end
                mkdir(path_fig)
            end

            %===========
            % Create output folder
            if ~isdir(path1_out_date)
                mkdir(path1_out_date)
            elseif isdir(path1_out_date)
                try
                    rmdir(path1_out_date, 's')
                end
                fprintf('Folder with combined data already exists, contents over-written\n')
                mkdir(path1_out_date)
            end
            fprintf('Preparing matrix "%s" which stores all settings and data\n', file_name_out)
           
            % Load structure of interest
            path1 = get_generate_path_v10(settings, 'data_temp_2', '_settings.mat');
            var1 = get_struct_v11(path1);
            path1 = get_generate_path_v10(settings, 'data_temp_2', '_eye_traces.mat');
            var2 = get_struct_v11(path1);
            
            if ~isempty(fieldnames(var1)) && isempty(fieldnames(var2))
                fprintf('Psychtoolbox recording only. No eyetracking data\n')
            elseif isempty(fieldnames(var1)) && isempty(fieldnames(var2))
                fprintf('Data for given date does not exist, possible debugging mode recorded only\n')
            end
            
           
            %%  Convert saccades from pix to deg
            
            if ~isempty(fieldnames(var1)) && ~isempty(fieldnames(var2))
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
            
            %% Convert raw data from pix to deg
            
            if ~isempty(fieldnames(var1)) && ~isempty(fieldnames(var2))
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
            end
            
            % Remove fields I dont need any more (to save memory)
            if ~isempty(fieldnames(var2))
                var2 = rmfield(var2, 'eye_raw');
                var2 = rmfield(var2, 'eye_preblink');
            end
            
            %% Drift correction
            
            if ~isempty(fieldnames(var1)) && ~isempty(fieldnames(var2))
                if ~isfield(settings, 'drift_correction_time')
                    error ('Drift correction settings not defined in setup file')
                end
                if settings.drift_correction_on == 1
                    % Catch bug with changes in drift correction field
                    % naming
                    f1 = settings.drift_correction_time;
                    if isfield (var1.eyelink_events, f1)
                    elseif isfield (settings, 'drift_correction_time_backup')
                        f2 = settings.drift_correction_time_backup;
                        if isfield (var1.eyelink_events, f2)
                            var1.eyelink_events.(f1) = var1.eyelink_events.(f2);
                        end
                    end
                    [var1, var2] = preprocessing_drift_correction_v10(settings, var1, var2);
                    preprocessing_drift_plot_v10;
                end
                SR = var2;
            end
            
            
            %%  Extract only some structure fields (to save on space)
            
            % Recording with saccades
            if ~isempty(fieldnames(var1)) && isfield(var1, 'eyelink_events')
                
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
                % Extract experiment name (for over-writing the files later)
                var_names={'expname'};
                mat5 = get_fields_v10 (var1.general, var_names); % Settings file with variables of interest
                
                % Combine those fields into one structure
                names = [fieldnames(mat1); fieldnames(mat2); fieldnames(mat3); fieldnames(mat4); fieldnames(mat5)];
                S = cell2struct([struct2cell(mat1); struct2cell(mat2); struct2cell(mat3); struct2cell(mat4); struct2cell(mat5)], names, 1);
            end
            
            % Recording without saccades
            if ~isempty(fieldnames(var1)) && ~isfield(var1, 'eyelink_events')
                
                var_names = fieldnames(var1.stim);
                mat1 = get_fields_v10 (var1.stim, var_names); % Settings file with variables of interest
                % Extract more variables of interest
                var_names={'session'; 'date'};
                mat4 = get_fields_v10 (var1, var_names); % Settings file with variables of interest
                % Extract experiment name (for over-writing the files later)
                var_names={'expname'};
                mat5 = get_fields_v10 (var1.general, var_names); % Settings file with variables of interest
                
                % Combine those fields into one structure
                names = [fieldnames(mat1); fieldnames(mat4); fieldnames(mat5)];
                S = cell2struct([struct2cell(mat1); struct2cell(mat4); struct2cell(mat5)], names, 1);
            end
            
            % Save data
            if ~isempty(fieldnames(S))
                save (path1_out_full, 'S')
                % Save raw data
                if exist('SR', 'var')
                    SR = var2;
                    path1 = get_generate_path_v10(settings, 'data_combined', '_eye_traces.mat');
                    save (path1, 'SR')
                end
            end
            
            
        else
            fprintf('\nFile %s already exists, skipping eyelink data conversion\n', file_name_out)
            % Do nothing
        end
        
        
    end
    % End of analysis for each date
    
end
% End of analysis for each subject

