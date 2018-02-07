% Combine files, extract saccades
% V1.0 - October 10, 2016. Neurophysiology setup.
% V1.1 - November 4, 2016. Neurophys setup. Small bug fixes.
% V2.0 - February 2, 2017. Psychophysics setup. Creates one file per session
% V1.2 - September 14, 2017. Neurophys setup. Re-written experiment design.
% Converted into function.
% V1.3 - October 25, 2017. Minor adjustments to code. Incompatible with
% earlier versions.
% V1.4 - February 1, 2018. Simplified path definitions.
%
% Output - saved structures in 'temp2' folder:
% xx_settings
% xx_eye_traces
%
% Donatas Jonikaitis

function  preprocessing_import_psych_and_edf_v14(settings)

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

% Run pre-processing for each subject
for i_subj = 1:length(settings.subjects)
    
    % Select curent subject
    settings.subject_current = settings.subjects{i_subj};
    
    % Which dates to run?
    settings.dates_used = get_dates_used_v10 (settings, 'data_psychtoolbox');
    
    % Analysis for each separate day
    for i_date = 1:length(settings.dates_used)
        
        % Which date is it
        settings.date_current = settings.dates_used(i_date);
                       
        % Generate output path
        path1 = get_generate_path_v10(settings, 'data_temp_2', '_settings.mat');

        if ~exist(path1, 'file') || settings.overwrite==1
            fprintf('\nStarting file conversion and combining for the date %s\n', num2str(settings.date_current))
            %===========
            % Main preprocessing function
            preprocessing_import_psych_and_edf_sub_v25 (settings, 'stim');
            %===========
        else
            fprintf('\nFDate for the date %s already exists, skipping file import\n', num2str(settings.date_current))
            % Do nothing
        end
        
    end
     
end
% End of analysis for each subject

