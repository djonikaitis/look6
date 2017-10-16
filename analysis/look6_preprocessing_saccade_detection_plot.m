% Detection of correct saccades
% V1.1: September 19, 2017
% Donatas Jonikaitis

p1 = mfilename;
fprintf('\n=========\n')
fprintf('\n Current file:  %s\n', p1)
fprintf('\n=========\n')


%% Initial setup

% Loading the files needed
if ~exist('settings', 'var')
    settings = struct;
end

% Setup exp name
if ~isfield (settings, 'exp_name')
    settings.exp_name = input ('Type in experiment name: ', 's');
end

% Default subject number: all subjects
if ~isfield (settings, 'subjects')
    settings.subjects = 'all'; % Subject name
end

% Overwriting analysis defaults
if ~isfield(settings, 'overwrite')
    settings.overwrite = 1;
end

% Run settings file:
eval(sprintf('%s_analysis_settings', settings.exp_name)); % Load general settings


%% Some settings

settings.figure_folder_name = 'saccade_detection';


%% Run preprocessing

for i_subj=1:length(settings.subjects)
    
    settings.subject_current = settings.subjects{i_subj}; % Select curent subject
    
    % Initialize subject specific folders where data is stored
    f1 = fieldnames(settings);
    ind = strncmp(f1,'path_data_', 10);
    ind_s = strfind(f1, '_subject');
    for i = 1:numel(ind)
        if ind(i)==1 && isempty(ind_s{i})
            v1 = sprintf('%s%s', f1{i}, '_subject'); % Fieldname
            v2 = sprintf('%s%s/', settings.(f1{i}), settings.subject_current); % Path
            settings.(v1) = v2;
        end
    end
    
    % Get index of every folder for a given subject
    path1 = settings.path_data_combined_subject;
    session_init = get_path_dates_v20(path1, settings.subject_current);
    if isempty(session_init.index_dates)
        fprintf('\nNo files detected, no data analysis done. Directory checked was:\n')
        fprintf('%s\n', path1)
    end
    
    % Save session_init data into settings matrix (needed for preprocessing)
    f1_data = fieldnames(session_init);
    for i=1:length(f1_data)
        settings.(f1_data{i}) = session_init.(f1_data{i});
    end
    
    % Which date to analyse (all days or a single day)
    if isfield(settings, 'preprocessing_sessions_used')
        if settings.preprocessing_sessions_used==1
            ind = 1:length(session_init.index_unique_dates);
        elseif settings.preprocessing_sessions_used==2
            ind = find(session_init.index_unique_dates==settings.preprocessing_day_id);
        elseif settings.preprocessing_sessions_used==3
            ind = length(session_init.index_unique_dates);
        end
    else
        fprintf('settings.preprocessing_day_id not defined, analyzing all data available\n')
        ind = 1:length(session_init.index_unique_dates);
    end
    date_used = session_init.index_unique_dates(ind);
    
    % Analysis for each day
    for i_date = 1:numel(date_used)
        
        date_current = date_used(i_date);
        
        % Current folder to be analysed (raw date, with session index)
        ind = date_current==settings.index_dates;
        folder_name = settings.index_directory{ind};
        
        %============
        % Select files to load
        path1 = [settings.path_data_combined_subject, folder_name, '/', folder_name, '.mat']; % File with settings
        path2 = [settings.path_data_combined_subject, folder_name, '/', folder_name, '_eye_traces.mat']; % File with raw data
        path3 = [settings.path_data_combined_subject, folder_name, '/', folder_name, '_saccades.mat']; % File with raw data
        path1_fig = sprintf('%s%s/%s/%s/', settings.path_figures, settings.figure_folder_name, settings.subject_current, folder_name);

        % Now decide whether to over-write analysis
        if ~isdir(path1_fig) || settings.overwrite==1
            
            % Remove old path
            if ~isdir(path1_fig)
                mkdir(path1_fig)
            elseif isdir(path1_fig)
                rmdir(path1_fig, 's')
                mkdir(path1_fig)
            end
        end
        
        if exist(path1, 'file')
            
            % Load all settings
            var1 = struct; varx = load(path1);
            f1 = fieldnames(varx);
            if length(f1)==1
                var1 = varx.(f1{1});
            end
            S = var1;
            
            
            %% Reshape saccades matrix
            
            %============
            %============
            % Restructure saccades matrix into one saccade per row
            % This is for fast plotting of all saccades observed in the
            % experiments
            
            ST = struct; % Initalize output matrix
            temp_data = var1.saccades_EK; % Saccades data
            
            % Create a matrix with trial numbers (so that data could be re-accessed)
            mat1 = []; % Output matrix
            i = 1; % Row counts
            n = 1; % As many columns as there is data
            
            for tid = 1:numel(temp_data)
                
                [m,~] = size(temp_data{tid}); % One row - one saccade
                if m>0
                    mat1(i:i+m-1,1:n) = tid; % Save one row for one saccade
                elseif m==0
                    mat1(i,1:n) = tid; % Save one row for one saccade
                end
                i = size(mat1,1)+1; % Update number of rows for the next trial
                
            end
            
            ST.trial_no = mat1;
            
            %=================
            % Create matrix with all settings
            
            f1 = fieldnames(var1);
            
            for fid = 1:numel(f1) % For each data field
                if ~iscell(var1.(f1{fid}))
                    
                    mat1 = []; % Output matrix
                    i = 1; % Row counts
                    [~,n] = size(var1.(f1{fid})); % As manu columns as there is data
                    for tid = 1:numel(temp_data) % For each trial
                        [m,~] = size(temp_data{tid}); % One row - one saccade
                        if m>0
                            mat1(i:i+m-1,1:n) = repmat(var1.(f1{fid})(tid,:),m,1); % Save one row for one saccade
                        elseif m==0
                            mat1(i,1:n) = var1.(f1{fid})(tid,:); % Save one row for one saccade
                        end
                        i = size(mat1,1)+1; % Update number of rows for the next trial
                    end
                    
                    % Save output
                    ST.(f1{fid}) = mat1;
                    
                end
            end
            
            %=============
            % Restructure saccades matrix
            f1 = cell(1);
            f1{1} = 'sacc1';
            
            for fid = 1:numel(f1)
                
                %=========
                % Determine how many columns each trial data contains, as its
                % necessary for data concatenation
                temp1 = [];
                for tid=1:length(temp_data)
                    temp1(tid) = size(temp_data{tid},2);
                end
                n = max(temp1);
                
                %========
                mat1 = []; % Empty output matrix
                
                % For each trial extract data and concatenate with previous
                % trial
                for tid=1:numel(temp_data)
                    % If there is data
                    if ~isempty(temp_data{tid})
                        % Save each row as an event
                        for j=1:size(temp_data{tid},1) % One row - one event
                            m1=temp_data{tid}(j,:);
                            m=size(mat1,1);
                            mat1(m+1,1:n)=m1;
                        end
                        % Else save as NaN
                    elseif isempty(temp_data{tid})
                        % Add an extra line with empty matrix
                        m=size(mat1,1);
                        mat1(m+1,1:n)=NaN;
                    end
                end
                % Save output
                ST.(f1{fid})=mat1;
            end
            
            clear temp_data;
            
            %============
            %  Create matrix to track why saccades were accepted/rejected
            
            ST.sacc_classify = cell(numel(ST.START), 1);
            ST.sacc_classify (1:end) = {'no sorting started'};
            
            %============
            %============
            % Calculate some extra variables for data evaluation
            
            
            %=============
            % Saccade onset distance from the fixation
            
            sx1 = ST.sacc1;
            
            x1=sx1(:,3);
            y1=sx1(:,4);
            l1=sqrt((x1.^2)+(y1.^2));
            ST.sacc_start_fix_dist = l1;
            
            %=============
            % Saccade endpoint distance from the fixation
            
            sx1 = ST.sacc1;
            
            x1=sx1(:,5);
            y1=sx1(:,6);
            l1=sqrt((x1.^2)+(y1.^2));
            ST.sacc_end_fix_dist = l1;
            
            %============
            % Remove saccades that are occur either before memory or after ST offset
            
            % Index for removing some saccades
            temp1 = ST.memory_on;
            temp2 = ST.fixation_off;
            index = (ST.sacc1(:,1) < temp1) | (ST.sacc1(:,1) > temp2) ;
            
            ST.sacc_classify(index) =  {'reject: trial timing'};
            
            %============
            % Remove saccades that start or end too far from fixation
            
            index = ST.sacc_start_fix_dist > 15;
            ST.sacc_classify(index) =  {'reject: amplitude start'};
            
            index = ST.sacc_end_fix_dist > 15;
            ST.sacc_classify(index) =  {'reject: amplitude end'};
            
            index = isnan(ST.sacc1(:,1));
            ST.sacc_classify(index) =  {'reject: no data'};
            
            
            %% Figure 1: all saccade endpoints
            
            h = figure;
            ind = strcmp(ST.sacc_classify, 'no sorting started');

            plot(ST.sacc1(ind,3), ST.sacc1(ind,4), '.k')
           
         
            

            
            
 
            
            


            
            
     
            

            
            
        end
        % End of analysis
        
    end
    % End of analysis for each day
    
end
% End of analysis for each subject

