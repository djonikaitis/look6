% Preprocessing of raw psychtoolbox and edf data files - combining sessions
% into daily data file, extract eye movements.
% Make sure to provide folders for data access
% Typically, this file does not have to be modified, unless recorded data
% formats change
%
% Donatas Jonikaitis
%
% V2.0: September 6, 2016. Combines psycthoolbox, eyelink and plexon files and
% saves them. It does not do any data analysis.
% Only prerequisite is that START message exists in eyelink
% messages file (to parse trials, can be replaces with any other
% message).
% V2.0 September24, 2016. Combines matrices only if all data is present
% V2.1 October 27, 2016. Separated spike detection from event detection due
% to bugs in pl2 file export.
% V2.2 October 31, 2016. Removed spike detection as it made too many
% complications given plexon data formats. Now it deals with eyelink and
% psychtoolbox data only.
% V2.3 August 24, 2017. Updated file for re-written exp design.
% V2.4 November 6, 2017. Eye movements recording is now optional
% V2.5 February 19, 2018. Simplified path definitions
%
% Input format:
% preprocessing_import_psych_and_edf_sub_v25 (settings, varargin)
% settings: settings containing path to data folders;
% varargin text input: names of structures (.stim usually) to be
% concatenated as 1 trial - 1 row (1 cell)
%
% Associated codes necessary for this to work:
% preprocessing_eye_edf2asc_v10
% preprocessing_eye_msg2tab_v20
% preprocessing_eye_saccades_EK2003_v14
% get_path_dates_v20 output must be stored in settings file: fields
% settings.index_dates, settings.index_directory, settings.subject_name
% are necessary for the code to work


function preprocessing_import_psych_and_edf_sub_v25(settings, varargin)

%==============

% Pre-specified folder names imported from settings

a = 'path_data_psychtoolbox';
if isfield (settings, a)
else
    error ('settings.%s for data preprocessing is not specified/is incorrect', a)
end

a = 'path_data_eyelink_edf';
if isfield (settings, a)
else
    error ('settings.%s for data preprocessing is not specified/is incorrect', a)
end

a = 'path_data_temp_1';
if isfield (settings, a)
else
    error ('settings.%s for data preprocessing is not specified/is incorrect', a)
end

a = 'path_data_temp_2';
if isfield (settings, a)
else
    error ('settings.%s for data preprocessing is not specified/is incorrect', a)
end

a = 'date_current';
if ~isfield (settings, a)
    error ('settings.%s is not specified. Aborting data pre-processing', a)
end

a = 'subject_current';
if ~isfield (settings, a)
    error ('settings.%s is not specified. Aborting data pre-processing', a)
end

a = 'date_current';
if ~isfield (settings, a)
    error ('settings.%s is not specified. Aborting data pre-processing', a)
    date_current = settings.date_current;
end

overwrite_saccades_EK2003 = 0; % 1 - will over-write saccade detection for EK algorithm


%% Do analysis

% How many sessions are used?
sessions_used = get_sessions_used_v10(settings, 'data_psychtoolbox');


% Do analysis for each desired session
% No changes needed for this section
for i_session = 1:numel(sessions_used)
    
    
    % Which recorded to use
    session_ind = sessions_used(i_session);
    

    %% Load psychtoolbox data (no processing needed)
    
    [path1, ~, file_name] = get_generate_path_v10(settings, 'data_psychtoolbox', '_data_structure.mat', session_ind);
    var1 = get_struct_v11(path1);
    
    if ~isempty(fieldnames(var1))
        fprintf('\nPsychtoolbox file "%s" successfully loaded\n', file_name)
    else
        var1 = struct;
        fprintf('\nPsychtoolbox file "%s" does not exist; it was not loaded\n', file_name)
    end
          
    
    %% Load/preprocess eye-tracker data
    
    % General path setup
    [path_edf] = get_generate_path_v10(settings, 'data_eyelink_edf', '.edf', session_ind);
    [path_asc, mk_dir_out] = get_generate_path_v10(settings, 'data_temp_1', '.asc', session_ind);
    [path_dat] = get_generate_path_v10(settings, 'data_temp_1', '.dat', session_ind);
    
    %============
    % Convert .edf into .asc .dat
    
    if exist(path_edf,'file') && (~exist (path_asc,'file') || ~exist (path_dat,'file')) % If asc file doesn't exist - do the conversion
        
        if ~isdir(mk_dir_out)
            mkdir (mk_dir_out)
        end
        
        preprocessing_eye_edf2asc_v13(path_edf, path_asc, path_dat) % Script doing conversion
        
        if exist (path_asc,'file') && exist (path_dat,'file')
            fprintf ('\n\n.edf file was converted to .asc and .dat files \n')
        else
            fprintf ('\n\n.edf file conversion failed (no .asc and .dat files created) \n')
        end
        
    elseif ~exist (path_edf,'file')
        fprintf ('.edf file does not exist, skipping edf conversion  \n')
    elseif exist (path_asc,'file') && exist (path_dat,'file')
        fprintf ('Eyelink files .asc and .dat exist, no conversion done  \n')
    else
        fprintf ('.edf file conversion failed, error not specified\n')
    end
    
    
    %============
    % Get eyelink messages from .asc file
    
    % Check whether message file exist. If it does, skip analysis
    path_in = get_generate_path_v10(settings, 'data_temp_1', '.asc', session_ind);
    [path_out, ~, file_name] = get_generate_path_v10(settings, 'data_temp_1', '_events.mat', session_ind);
            
    if ~exist (path_out,'file')
        if exist (path_in,'file')
            preprocessing_eye_msg2tab_v22(path_in, path_out);
        else
            fprintf ('.asc file does not exist. Can not proceed with event extraction\n')
        end
        if exist(path_out,'file')
            fprintf ('Extracted all messages into file "%s" successfully.\n', file_name)
        end
    else
        fprintf ('Messages file "%s" already exist, no conversion done  \n', file_name)
    end
    
    % Load messages file
    [path1, ~, file_name] = get_generate_path_v10(settings, 'data_temp_1', '_events.mat', session_ind);
    var_temp = get_struct_v11(path1);
    
    if ~isempty(fieldnames(var_temp))
        var4.eyelink_events = var_temp;
        fprintf('Messages file "%s" successfully loaded\n', file_name)
    else
        var4 = var_temp;
        fprintf('Messages file "%s" does not exist; it was not loaded\n', file_name)
    end
    
    

    %==============
    % Find saccades using Engbert & Kliegl (2003) algorithm
    
    
    % Extract saccades
    path_in = get_generate_path_v10(settings, 'data_temp_1', '.dat', session_ind);
    [path_out, ~, file_name] = get_generate_path_v10(settings, 'data_temp_1', '_saccades_EK.mat', session_ind);

    % IF converted file does not exist, then do conversion
    if ~exist (path_out, 'file')  || overwrite_saccades_EK2003==1     
        if exist (path_in,'file') && ~isempty(fieldnames(var4))
            
            % Saccade detection settings
            const.SAMPRATE  = []; % Sampling rate of Eye Tracker
            const.velSD     = 6; % Lambda threshold for saccade/microsaccade detection
            const.minDur    = 6; % Duration threshold for saccade detection
            const.VELTYPE   = 2; % Velocity type for saccade detection (using default)
            const.mergeInt  = 20; % Interval within which saccades/microsaccades will be merged; ms
            const.SAMPRATE = var4.eyelink_events.sampling_frequency(1); % Assumes sampling frequency does not change
            const.trial_start = var4.eyelink_events.START;
            const.trial_end = var4.eyelink_events.END;
            
            fprintf('Processing eye data based on Engbert & Kliegl (2003) algorithm \n');
            tic
            preprocessing_eye_saccades_EK2003_v16(path_in, path_out, const); % Eye movement analysis
            a = toc;
            a = round(a, 2);
            fprintf('Time taken to extract saccades was %d seconds \n', a);
        else
            fprintf ('.dat file does not exist. Can not proceed with saccade detection\n')
        end
        if exist(path_out,'file')
            fprintf ('Prepared saccades "%s" based on Engbert & Kliegl (2003); conversion complete \n', file_name)
        end
    else
        fprintf ('Saccades file "%s" already exist, no conversion done\n', file_name)
    end
    
    % Load messages file
    [path1, ~, file_name] = get_generate_path_v10(settings, 'data_temp_1', '_saccades_EK.mat', session_ind);
    var_temp = get_struct_v11(path1);
    
    if ~isempty(fieldnames(var_temp))
        var2.eye_data = var_temp;
        fprintf('Saccades file "%s" successfully loaded\n', file_name)
    else
        var2 = var_temp;
        fprintf('Saccades file "%s" does not exist; it was not loaded\n', file_name)
    end
    

    
    %% Combine psychtoolbox & eyelink into one structure
    
    comb_mat = struct;
    
    % Only if all data was successfully loaded
    a = [~isempty(fieldnames(var1)); ~isempty(fieldnames(var2)); ...
         ~isempty(fieldnames(var4))];
    
    if sum(a)==3
        
        %==================
        for rep1 = 1:3
            
            % Select variable for combining
            % Particular order is just for convenience of displaying structure
            % in command window
            if rep1==1
                temp1 = var1; % Psychtoolbox matrix
            elseif rep1==2
                temp1 = var4; % Eye messages
            elseif rep1==3
                temp1 = var2; % Saccades
            end
            
            % Generic code to combine fields and subfields
            f1 = fieldnames(temp1);
            for i=1:length(f1)
                if isstruct(temp1.(f1{i}))
                    f2 = fieldnames(temp1.(f1{i}));
                    for j=1:length(f2)
                        n1 = [f2{j}];
                        comb_mat.(f1{i}).(n1){1}=temp1.(f1{i}).(f2{j});
                    end
                else
                    comb_mat.(f1{i}){1}=temp1.(f1{i});
                end
            end
        end
        %=====================
        
        
    elseif sum(a)==1 &&~isempty(fieldnames(var1)) && var1.general.recordeyes==0 % For psychtoolbox recording only
        
        %==================
        for rep1 = 1:3
            
            % Select variable for combining
            % Particular order is just for convenience of displaying structure
            % in command window
            if rep1==1
                temp1 = var1; % Psychtoolbox matrix
            elseif rep1==2
                temp1 = struct; % Eye messages (SKIP)
            elseif rep1==3
                temp1 = struct; % Saccades (SKIP)
            end
            
            % Generic code to combine fields and subfields
            f1 = fieldnames(temp1);
            for i=1:length(f1)
                if isstruct(temp1.(f1{i}))
                    f2 = fieldnames(temp1.(f1{i}));
                    for j=1:length(f2)
                        n1 = [f2{j}];
                        comb_mat.(f1{i}).(n1){1}=temp1.(f1{i}).(f2{j});
                    end
                else
                    comb_mat.(f1{i}){1}=temp1.(f1{i});
                end
            end
        end
        %=====================
        
    else
        fprintf('Not all files (eyelink, psychtoolbox) could be loaded, omitting this recording\n')
    end
    
    
    %% Combine multiple sessions into one strucutre called S
    
    if ~isempty(fieldnames(comb_mat))
        
        temp0 = comb_mat; % Matrix with data
        
        if isfield(temp0, 'eyelink_events')  % If eyetracking is on
            temp0.session{1} = ones(size(temp0.eyelink_events.START{1}, 1), 1); % Save session number
            temp0.date{1} = ones(length(temp0.eyelink_events.START{1}), 1) * settings.date_current; % Save current date
        elseif isfield(temp0.stim, 'edata_first_display')  % If no eye tracking
            temp0.session{1} = ones(size(temp0.stim.edata_first_display{1}, 1), 1); % Save session number
            temp0.date{1} = ones(length(temp0.stim.edata_first_display{1}), 1) * settings.date_current; % Save current date
        else
            error('Files can not be combined, as field for trial numbers not specified')
        end
        
        if  ~exist('S', 'var') % First repretition
            S = temp0;
            repetition1 = 0; % Repetition number
            
        else % Second and later repetitions
            
            repetition1 = repetition1+1; % Repetition number
            temp0.session{1} = temp0.session{1} + max(S.session{end}); % Update session number
            f1 = fieldnames(temp0); % Fields of a new matrix
            for i=1:length(f1)
                
                %===============
                % If a field of structure is another structure, then combine
                % fields in structure.structure.fieldname
                
                if isstruct(temp0.(f1{i}))
                    
                    % Read out fields of newly loaded structure and combine
                    f2 = fieldnames(temp0.(f1{i})); % New structure fields
                    for j=1:length(f2)
                        % If such field already exists, concatenate
                        if isfield(S.(f1{i}), f2{j})
                            S.(f1{i}).(f2{j}) = [S.(f1{i}).(f2{j}); temp0.(f1{i}).(f2{j})];
                            % If field does not exist, create an empty one
                        else
                            % Create empty matrix and save it
                            a1 = cell(repetition1,1);
                            S.(f1{i}).(f2{j}) = [a1; temp0.(f1{i}).(f2{j})];
                        end
                    end
                    
                    % Readout fields of the older structure and see if new
                    % structure lacks any
                    f3 = fieldnames(S.(f1{i})); % Old structure fields
                    if length(f2)==length(f3)
                        % If fields of both structures match, you are good
                    else % If field in a new recording does not exist, add empty cell
                        [~, ~, if3] = intersect(f2,f3);
                        f3(if3) = []; % Remove intersecting fields
                        for i_f3=1:length(f3)
                            a1 = cell(1);
                            S.(f1{i}).(f3{i_f3}) = [S.(f1{i}).(f3{i_f3}); a1];
                        end
                        
                    end
                    
                    %==================
                    % If it is structure, combine it's fields in
                    % structure.fieldname
                else
                    % If such field already exists, concatenate
                    if isfield(S, f1{i})
                        S.(f1{i}) = [S.(f1{i}); temp0.(f1{i})];
                        % If field does not exist, create an empty one
                    else
                        % Create empty matrix and save it
                        a1 = cell(repetition1,1);
                        S.(f1{i}) = [a1; temp0.(f1{i})];
                    end
                end
            end
        end
        
    end
    
end
% End of analysis for separate sessions; From now on all data is
% combined


%% Combine some variables into matrixes
% This section can be disabled if needed

%=============
% Concatenate the fields of eyelink data (done by default)
% One row - one trial
if exist('S', 'var') && isfield (S, 'eye_data')
    
    temp1 = S.eye_data;
    f1 = fieldnames(temp1);
    
    for i2=1:length(f1)
        
        % Extract dimensions from each field
        dim1_a=NaN(size(S.session,1),1);
        dim1_b=NaN(size(S.session,1),1);
        dim_s=NaN(size(S.session,1),1);
        for rep1=1:size(S.session,1)
            if ndims(temp1.(f1{i2}){rep1})==2 % Get the size
                [dim1_a(rep1), dim1_b(rep1)] = size(temp1.(f1{i2}){rep1});
            else
                error('Combining sessions not written for 3D matrix')
            end
            dim_s(rep1) = size(S.session{rep1},1);
        end
        
        % If the field size matches session size, concatenate it
        if dim1_a==dim_s
            temp1.(f1{i2})= cat(1, temp1.(f1{i2}){:});
        end
        
    end
    S.eye_data = temp1;
end


%=============
% Concatenate the fields of eyelink messages (done by default)
% One row - one trial.
% Also control for fact that sometimes messages might not be recorded on
% some blocks

if exist('S', 'var') && isfield (S, 'eyelink_events')
    
    temp1 = S.eyelink_events;
    f1 = fieldnames(temp1);
    
    for i2=1:length(f1)
        
        % Extract dimensions from each field
        dim1_a=NaN(size(S.session,1),1);
        dim1_b=NaN(size(S.session,1),1);
        dim_s=NaN(size(S.session,1),1);
        for rep1=1:size(S.session,1)
            if ndims(temp1.(f1{i2}){rep1})==2 % Get the size
                [dim1_a(rep1), dim1_b(rep1)] = size(temp1.(f1{i2}){rep1});
            else
                error('Combining sessions not written for 3D matrix')
            end
            dim_s(rep1) = size(S.session{rep1},1);
        end
        
        % If the field size matches session size, concatenate it
        if dim1_a==dim_s
            temp1.(f1{i2})= cat(1, temp1.(f1{i2}){:});
        end
        
        % If particular messages are missing, still concatenate by creating empty field
        if any(dim1_a==0)
            for i=1:length(dim1_a)
                if dim1_a(i)==0 && isnumeric(temp1.(f1{i2}){i})
                    temp1.(f1{i2}){i}=NaN(dim_s(i),1);
                elseif dim1_a(i)==0 && iscell(temp1.(f1{i2}){i})
                    temp1.(f1{i2}){i}=cell(dim_s(i),1);
                end
            end
            temp1.(f1{i2})= cat(1, temp1.(f1{i2}){:});
        end
        
        
    end
    S.eyelink_events = temp1;
end

%=============
%% Concatenate user input fields (done only for user input fields)
% For example, fields in .stim structure are concatenated as one row-one
% trial


if exist ('S', 'var')
    for i1=1:length(varargin)
        
        f0 = varargin{i1};
        f1 = fieldnames(S.(f0)); % Fields of that structure
        
        for i2 = 1:numel(f1)
            
            mat1 = S.(f0).(f1{i2}); % Structure to be re-organized
            mat_s = S.session; % Structure with session numbers
            num_s = size(mat_s,1); % Total number of sessions tested
            
            % Extract dimensions from each field
            dim1_a = NaN(size(S.session,1),1);
            dim1_b = NaN(size(S.session,1),1);
            dim1_c = NaN(size(S.session,1),1);
            dim_s = NaN(size(S.session,1),1);
            
            % Get size of the variable
            for rep1=1:num_s
                if ndims(mat1{rep1})<=3 % Get the size
                    [dim1_a(rep1), dim1_b(rep1), dim1_c(rep1)] = size(mat1{rep1});
                else
                    error('Combining sessions is only possible 3D, not 4D matrix/structure')
                end
                dim_s(rep1) = size(mat_s{rep1},1);
            end
            
            % If the field size matches session size, concatenate it
            if dim1_a == dim_s % Combine vertically
                if length(unique(dim1_b))==1 && length(unique(dim1_c))==1
                    S.(f0).(f1{i2}) = cat(1, mat1{:});
                else
                    S.(f0).(f1{i2}) = mat1; % No combining
                end
            elseif dim1_b == dim_s % Combine horizontally
                if length(unique(dim1_a))==1 && length(unique(dim1_c))==1
                    S.(f0).(f1{i2})= cat(2, mat1{:})'; % Flip to vertical, to keep up with conventions
                else
                    S.(f0).(f1{i2}) = mat1; % No combining
                end
            end
            
            % If particular fields are missing, still concatenate by creating empty field
            if any(dim1_a==0)
                
                % Find non-empty matrix
                t1 = find(dim1_a>0);
                
                % Determine whether matrices are trial based or single shot
                if dim1_a(t1) == dim_s(t1) % If one variable per trial
                    if length(unique(dim1_b(t1)))==1 && length(unique(dim1_c(t1)))==1 % If 2 and 3rd dimensions match
                        for i=1:length(dim1_a)
                            if dim1_a(i)==0 && isnumeric(S.(f0).(f1{i2}){t1(1)})
                                S.(f0).(f1{i2}){i}=NaN(dim_s(i), dim1_b(t1(1)), dim1_c(t1(1))   );
                            elseif dim1_a(i)==0 && ischar(S.(f0).(f1{i2}){t1(1)})
                                S.(f0).(f1{i2}){i}=NaN(dim_s(i), dim1_b(t1(1)), dim1_c(t1(1)) );
                            elseif dim1_a(i)==0 && iscell(S.(f0).(f1{i2}){t1(1)})
                                S.(f0).(f1{i2}){i}=cell(dim_s(i), dim1_b(t1(1)), dim1_c(t1(1)) );
                            end
                        end
                    else % No combining
                        S.(f0).(f1{i2}) = mat1; % No combining
                    end
                elseif dim1_b(t1) == dim_s(t1)
                    if length(unique(dim1_a(t1)))==1 && length(unique(dim1_c(t1)))==1 % If 2 and 3rd dimensions match
                        for i=1:length(dim1_a)
                            if dim1_a(i)==0 && isnumeric(S.(f0).(f1{i2}){t1(1)})
                                S.(f0).(f1{i2}){i}=NaN(dim1_a(t1(1)), dim_s(i), dim1_c(t1(1))   );
                            elseif dim1_a(i)==0 && ischar(S.(f0).(f1{i2}){t1(1)})
                                S.(f0).(f1{i2}){i}=NaN(dim1_a(t1(1)), dim_s(i),  dim1_c(t1(1)) );
                            elseif dim1_a(i)==0 && iscell(S.(f0).(f1{i2}){t1(1)})
                                S.(f0).(f1{i2}){i}=cell(dim1_a(t1(1)), dim_s(i), dim1_c(t1(1)) );
                            end
                        end
                    else % No combining
                        S.(f0).(f1{i2}) = mat1; % No combining
                    end
                end
                
                % Concatenate only matrices that have as many variables as
                % trials
                if dim1_b(t1) == dim_s(t1) | dim1_a(t1) == dim_s(t1)
                    S.(f0).(f1{i2})= cat(1, S.(f0).(f1{i2}){:});
                end
                
            end
            % End of creating missing fields
            
        end
        % End of analysis for each field
        
    end
    % End of analysis for each struct array
    
    % Concatenate special cases:
    S.session = cat(1,S.session{1:end});
    S.date = cat(1,S.date{1:end});
    
end

%% Convert cells with repetitions into cells for each trial
% This makes later analysis easier

%===========
% Convert single-settings into matrix of setting per trial

if exist('S', 'var')
    fnames1 = fieldnames(S);
    for i_field1 = 1:length(fnames1)
        if isstruct(S.(fnames1{i_field1}))
            fnames2 = fieldnames(S.(fnames1{i_field1}));
            for i_field2 = 1:length(fnames2) % Go to second level structure
                
                var_temp = S.(fnames1{i_field1}).(fnames2{i_field2}); % Retrieve field of interest (this is data)
                
                if iscell(var_temp) % Only if field is a cell (and not a matrix, matrix means it was already combined earlier)
                    
                    if size(var_temp, 1) == max(S.session) % If a number of recorded sessions exist as a row vector
                        
                        % Determine how big cell array with inputs is
                        m=NaN(max(S.session), 1);
                        n=NaN(max(S.session), 1);
                        o=NaN(max(S.session), 1);
                        for rep1 = 1:max(S.session)
                            [m(rep1),n(rep1),o(rep1)] = size(var_temp{rep1});
                        end
                        
                        a = cell(1); % Initialize empty cell
                        
                        % For each session extract values
                        if sum(m)<=max(S.session) % Only if data is a row vector
                            
                            for rep1 = 1:max(S.session)
                                num_t = sum(S.session==rep1); % How many trials per session are expected?
                                b=cell(num_t,1);  % Initialize empty cell
                                
                                % If it's a character or a row vector, then
                                % replicate values for each trial
                                if isnumeric (var_temp{rep1}) || ...
                                        ischar (var_temp{rep1})
                                    for rep2 = 1:num_t
                                        b{rep2,1}=var_temp{rep1};
                                    end
                                    a{rep1} = b;
                                    % If cell is empty, then fill it with NAN
                                    % values
                                elseif isempty(var_temp{rep1})
                                    for rep2 = 1:num_t
                                        b{rep2,1}=NaN;
                                    end
                                    a{rep1} = b;
                                end
                            end
                        end
                        
                        a = cat(1, a{:}); % Concatenate
                        
                        % Will work only if variables exist
                        if isempty (a)
                            % Do nothing
                        else
                            S.(fnames1{i_field1}).(fnames2{i_field2}) = a;
                        end
                        
                    end
                    
                end
            end
        end
    end
end


%% Split off raw saccade data

if exist ('S', 'var') && isfield (S.eye_data, 'eye_raw')
    SR.eye_raw = S.eye_data.eye_raw; % With blinks removed
    SR.eye_preblink = S.eye_data.eye_preblink; % Without blinks removed
    SR.session = S.session;
    SR.date = S.date;
    % Remove raw saccade data
    S.eye_data = rmfield(S.eye_data, 'eye_raw');
    S.eye_data = rmfield(S.eye_data, 'eye_preblink');
end



%% Save

if exist('S', 'var')
    
    [~, path1, ~] = get_generate_path_v10(settings, 'data_temp_2');
    
    % Over-write directory by default
    if isdir(path1)
        rmdir(path1, 's')
        fprintf('\nPreprocessing folder already exists, contents cleared\n')
        mkdir(path1);
    else
        fprintf('\nCreated new preprocessing directory\n')
        mkdir(path1);
    end
    
    % Save main data
    path1 = get_generate_path_v10(settings, 'data_temp_2', '_settings.mat');
    save (path1, 'S')
    
    % Save raw eye position data separately, as usually it does not need to be
    % loaded
    if exist ('SR', 'var')
        path1 = get_generate_path_v10(settings, 'data_temp_2', '_eye_traces.mat');
        save (path1, 'SR')
    end
    
    % Output
    fprintf('Preprocessed data successfully saved under following name:\n')
    [~, path1, ~] = get_generate_path_v10(settings, 'data_temp_2');
    fprintf ('%s\n', path1)
    
else
    fprintf('Data for given day did not exist, no files saved\n')
end


