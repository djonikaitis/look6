% Detection of correct saccades
% Latest version: October 16, 2017
% Donatas Jonikaitis


% Show file you are running
p1 = mfilename;
fprintf('\n=========\n')
fprintf('\n Current file:  %s\n', p1)
fprintf('\n=========\n')

% Loading the files needed
if ~exist('settings', 'var')
    settings = struct;
end
settings = get_settings_ini_v10(settings);


%% Extra settings

settings.figure_folder_name = 'saccade_detection';


%% Analysis


for i_subj=1:length(settings.subjects)
    
    % Select curent subject
    settings.subject_current = settings.subjects{i_subj};
    
    % Get subject folder paths and dates to analyze
    settings = get_settings_path_and_dates_ini_v10(settings);
    dates_used = settings.data_sessions_to_analyze;
    
    % Analysis for each day
    for i_date = 1:numel(dates_used)
        
        % Current folder to be analysed (raw date, with session index)
        date_current = dates_used(i_date);
        ind = date_current==settings.index_dates;
        folder_name = settings.index_directory{ind};
        
        % Figure folder
        path_fig = sprintf('%s%s/%s/%s/', settings.path_figures, settings.figure_folder_name, settings.subject_current, folder_name);
        
        % Overwrite figure folders
        if ~isdir(path_fig) || settings.overwrite==1
            if ~isdir(path_fig)
                mkdir(path_fig)
            elseif isdir(path_fig)
                rmdir(path_fig, 's')
                mkdir(path_fig)
            end
        end
        
        % Data folders
        path1 = [settings.path_data_combined_subject, folder_name, '/', folder_name, '.mat']; 
        path2 = [settings.path_data_combined_subject, folder_name, '/', folder_name, '_eye_traces.mat']; 
        path3 = [settings.path_data_combined_subject, folder_name, '/', folder_name, '_saccades.mat']; 
        path4 = [settings.path_data_combined_subject, folder_name, '/', folder_name, '_individual_saccades.mat']; 
        
        % Run analysis
        if exist(path1, 'file')
            
            
            %% Reshape saccades matrix
            
            % Load all settings
            var1 = get_struct_v10(path1);
            
            % Initialize few variables
            sacc1 = var1.saccades_EK;
            saccade_matrix = NaN(size(sacc1,1), 7); % Only one saccade is taken
            trial_accepted = cell(size(sacc1,1), 1); % Initialize matrix which will track rejected saccades
            
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
            
            
            %================
            % Calculate saccade start distance from st1
            
            sx1 = ST.sacc1;
                        
            xc = ST.esetup_st1_coord(:,1);
            yc = ST.esetup_st1_coord(:,2);
            x1=sx1(:,3)-xc;
            y1=sx1(:,4)-yc;
            l1=sqrt((x1.^2)+(y1.^2));
            ST.sacc_start_st1_dist = l1;

            %================
            % Calculate saccade end distance from st1
            
            sx1 = ST.sacc1;
            
            xc = ST.esetup_st1_coord(:,1);
            yc = ST.esetup_st1_coord(:,2);
            x1=sx1(:,5)-xc;
            y1=sx1(:,6)-yc;
            l1=sqrt((x1.^2)+(y1.^2));
            ST.sacc_end_st1_dist = l1;
            
            %================
            % Calculate saccade end distance from st2
            
            sx1 = ST.sacc1;
            
            xc = ST.esetup_st2_coord(:,1);
            yc = ST.esetup_st2_coord(:,2);
            x1=sx1(:,5)-xc;
            y1=sx1(:,6)-yc;
            l1=sqrt((x1.^2)+(y1.^2));
            ST.sacc_end_st2_dist = l1;
            
            
            %% remove outlier saccades
            
            index = isnan(ST.sacc1(:,1));
            ST.sacc_classify(index) =  {'reject - no data'};
            
            % Saccades before/after trial 
            temp1 = ST.first_display;
            temp2 = ST.loop_over;
            index = (ST.sacc1(:,1) < temp1) | (ST.sacc1(:,1) > temp2) ;
            ST.sacc_classify(index) =  {'reject - saccade timing'};
                        
            % Distance outliers
            ind = strcmp(ST.sacc_classify, 'no sorting started');
            v1 = ST.sacc_start_fix_dist(ind);
            a_m = nanmean(v1); a_s = nanstd(v1);
            a_sdev_th = 3;
            
            index = ST.sacc_end_fix_dist > a_m + a_s*a_sdev_th; % 3 standard deviations
            ST.sacc_classify(index) =  {'reject1'};
            
                        
            %% Figure 1: all saccade endpoints
            
            h = figure; hold on
            ind = strcmp(ST.sacc_classify, 'no sorting started');
            plot(ST.sacc1(ind,5), ST.sacc1(ind,6), '.k')
            ind = strcmp(ST.sacc_classify, 'reject1');
            plot(ST.sacc1(ind,5), ST.sacc1(ind,6), '.r')

            
            %% aborted: no fixation
            
            % sacc endpoint threshold
            th1 = NaN(numel(ST.START), 1);
            ind = ST.esetup_fixation_drift_correction_on == 1;
            th1(ind) = ST.esetup_fixation_size_drift(ind,4);
            ind = ST.esetup_fixation_drift_correction_on == 0;
            th1(ind) = ST.esetup_fixation_size_eyetrack(ind,4);
            
            % Check for saccades
            ind = isnan(ST.fixation_acquired) & ~isnan(ST.fixation_on) & ~isnan(ST.fixation_off) & ...
                ST.sacc1(:,1) >= ST.fixation_on & ST.sacc1(:,1) <= ST.fixation_off & ST.sacc_end_fix_dist>=th1;
            
            ST.sacc_classify(ind) = {'aborted - no fixation acquired'};
            
            % Check for saccades
            ind = isnan(ST.fixation_drift_maintained) & ~isnan(ST.fixation_acquired) & ~isnan(ST.fixation_on) & ~isnan(ST.fixation_off) & ...
                ST.sacc1(:,1) >= ST.fixation_acquired & ST.sacc1(:,1) <= ST.fixation_off & ST.sacc_end_fix_dist>=th1;
            
            ST.sacc_classify(ind) = {'aborted - broke fixation before memory'};
           
            
            
            %% aborted: broke fixation before memory
            
            % sacc endpoint threshold
            th1 = NaN(numel(ST.START), 1);
            th1 = ST.esetup_fixation_size_eyetrack(:,4);
            
            % Check for saccades
            ind = ~isnan(ST.fixation_drift_maintained) & isnan(ST.memory_on) & ...
                ST.sacc1(:,1) >= ST.fixation_drift_maintained & ST.sacc1(:,1) <= ST.fixation_off & ST.sacc_end_fix_dist>=th1;
            
            ST.sacc_classify(ind) = {'aborted - broke fixation before memory'};
            
            % Check for saccades
            ind = ~isnan(ST.fixation_drift_maintained) & ~isnan(ST.memory_on) & ...
                ST.sacc1(:,1) >= ST.fixation_drift_maintained & ST.sacc1(:,1) <= ST.memory_on & ST.sacc_end_fix_dist>=th1;
            
            ST.sacc_classify(ind) = {'aborted - broke fixation before memory'};
            
            
            
            %% detect target saccades
            
            % sacc endpoint threshold
            th1 = NaN(numel(ST.START), 1);
            th1 = ST.esetup_fixation_size_eyetrack(:,4);
            
            % Check for saccades
            ind = ~isnan(ST.target_on) & ...
                ST.sacc1(:,1) >= ST.target_on & ST.sacc1(:,1) <= ST.target_off & ST.sacc_end_st1_dist <= th1;
            
            ST.sacc_classify(ind) = {'correct'};
            
%             h = figure; hold on;
%             plot(ST.sacc1(ind,5), ST.sacc1(ind,6), '.k')
            
            
            %             % Check for saccades
            %             ind = ~isnan(ST.st2_on) & ~isnan(ST.st2_off) &...
            %                 ST.sacc1(:,1) >= ST.st2_on & ST.sacc1(:,1) <= ST.st2_off & ST.sacc_end_st2_dist <= th1;
            %
            %             ST.sacc_classify(ind) = {'error: saccade to st2'};
            %
            %
            %             plot(ST.sacc1(ind,5), ST.sacc1(ind,6), '.r')
            
            
            
            %% detect fixation saccades during delay
            
            % sacc endpoint threshold
            th1 = NaN(numel(ST.START), 1);
            th1 = ST.esetup_fixation_size_eyetrack(:,4);
            
            % Check for saccades
            ind = ~isnan(ST.memory_on) & ~isnan(ST.target_on) &...
                ST.sacc1(:,1) >= ST.memory_on & ST.sacc1(:,1) <= ST.target_on & ST.sacc_end_fix_dist <= th1;
            
            ST.sacc_classify(ind) = {'fixation saccade'};
            
% %             h = figure; hold on;
% %             plot(ST.sacc1(ind,5), ST.sacc1(ind,6), '.r')
           
            
            %% Output into trial_accepted matrix
            
            
            % Save correct trials
            for tid = 1:numel(var1.START)
                ind = ST.trial_no==tid;
                a = 'correct';
                if sum(strcmp (ST.sacc_classify(ind), a))>0
                    trial_accepted{tid} = a;
                end
            end
            
            
            for tid=1:size(var1.START,1)
                if isempty(trial_accepted{tid})
                    trial_accepted{tid} = 'unknown error';
                end
            end
            
            %% Save errors into text file
           
            %================
            % Initialize empty file
            
            f_name = sprintf('%s%s.txt', path_fig, folder_name);
            fclose('all');
            fout = fopen(f_name,'w');
            
            % Print out errors            
            targettext='\nTrials accepted and removed: \n';
            fprintf(targettext);
            fprintf(fout, targettext);

            a=numel(trial_accepted); % a-total number of trials
            targettext='Total trials tested: %d; \n\n';
            fprintf(targettext, a);
            fprintf(fout, targettext, a);
            
            e1 = unique(trial_accepted);
            for i_data=1:numel(e1)
                c = sum(strcmp(trial_accepted, e1{i_data}));
                targettext='%s: %d trials (%d percent) \n';
                fprintf(targettext, e1{i_data}, c, round((c/a)*100));
                fprintf(fout, targettext, e1{i_data}, c, round((c/a)*100));
            end
            
            
            %% Save sacc1
            
            sacc1 = struct;
            sacc1.saccade_matrix = saccade_matrix;
            sacc1.trial_accepted = trial_accepted;
            save (eval('path3'), 'sacc1')
            targettext='Saved saccades data: %s; \n\n';
            fprintf(targettext, path3);
            
            
            %% Save ST structure
            
            sacc2 = struct;
            sacc2.trial_no = ST.trial_no;
            sacc2.sacc_classify = ST.sacc_classify;
            sacc2.sacc1 = ST.sacc1;
            save (eval('path4'), 'sacc2')
            
            
        end
        % End of analysis
        
    end
    % End of analysis for each day
    
end
% End of analysis for each subject

