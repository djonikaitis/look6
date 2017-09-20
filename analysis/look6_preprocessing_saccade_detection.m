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
eval(sprintf('%s_settings', settings.exp_name)); % Load general settings


%% Some settings

settings.figure_folder_name = 'saccade_detection';


%% Run preprocessing

for i_subj=1:length(settings.subjects)
    
    settings.subject_current = settings.subjects{i_subj}; % Select curent subject
    
    % Initialize subject specific folders where data is stored
    f1 = fieldnames(settings);
    ind = strncmp(f1,'path_data_', 10);
    for i = 1:numel(ind)
        if ind(i)==1
            v1 = sprintf('%s%s', f1{i}, '_subject');
            settings.(v1) = sprintf('%s%s/', settings.(f1{i}), settings.subject_current);
        end
    end
    
    % Get index of every folder for a given subject
    path1 = settings.path_data_temp_3_subject;
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

        if ~exist(path3, 'file') || settings.overwrite==1
        
        fprintf('\n=======\n', folder_name);
        fprintf('\nSaccade detection for %s\n', folder_name);
        
        % Load all settings
        var1 = struct; varx = load(path1);
        f1 = fieldnames(varx);
        if length(f1)==1
            var1 = varx.(f1{1});
        end
        
        % Load raw saccade data
        var2 = struct; varx = load(path2);
        f1 = fieldnames(varx);
        if length(f1)==1
            var2 = varx.(f1{1});
        end
        
        % Copy raw data
        sacc1 = var1.saccades_EK;
        saccraw1 = var2.eye_processed;
        S = var1;


%         %% Saccade made to correct target
%         
%         
%         sacmatrix=NaN(size(sacc1,1),7); % Only one saccade is taken
%         trial_accepted = NaN(size(S.START)); % Initialize matrix which will track rejected saccades
%         
%         e_dist1=NaN(size(sacc1,1),1); % This is to store endpoint deviation data to the target
%         e_dist2=NaN(size(sacc1,1),1); % This is to store endpoint deviation data to the distractor
%         
%         minlatency_baseline=50; % Min accepted latency
%         
%         for tid=1:size(sacc1,1)
%             
%             % Data to be used
%             sx1=sacc1{tid}; % Manipulated data
%             sx2=sacc1{tid}; % Raw data
%             
%             if size(sx1,2)>1 && trial_accepted(tid)~=2 && S.em_blockcond(tid)~=5
% 
%                 
%                 % Starting position
%                 saccstart(1)=0;
%                 saccstart(2)=0;
%                 sx1(:,3)=sx1(:,3)-saccstart(1);
%                 sx1(:,4)=sx1(:,4)-saccstart(2);
%                 
%                 % Ending position
%                 if S.em_blockcond(tid)==1 && S.em_target_number(tid)==2
%                     xc = S.em_t1_coord1(tid);
%                     yc = S.em_t1_coord2(tid);
%                 elseif S.em_blockcond(tid)==2 && S.em_target_number(tid)==2
%                     xc = S.em_t2_coord1(tid);
%                     yc = S.em_t2_coord2(tid);
%                 elseif S.em_target_number(tid)==1
%                     xc = S.em_t3_coord1(tid);
%                     yc = S.em_t3_coord2(tid);
%                 end
%                 sx1(:,5)=sx1(:,5)-xc;
%                 sx1(:,6)=sx1(:,6)-yc;
%                 
%                 if ~isnan(S.targets_on(tid))
%                     
%                     % Settings on each trial used
%                     minlatency = S.targets_on(tid) + minlatency_baseline;
%                     maxlatency = S.targets_off(tid);
%                     
%                     ind1 = S.session(tid); % Which session is it
%                     threshold1 = S.fixation_accuracy{tid};
%                     threshold2 = S.response_saccade_accuracy{tid};
%                     
%                     % Find distance between wanted and actual sacc position
%                     startdev1=sqrt((sx1(:,3).^2)+(sx1(:,4).^2));
%                     enddev1=sqrt((sx1(:,5).^2)+(sx1(:,6).^2));
%                     starttimes=sx1(:,1);
%                     
%                     % index1 is correct saccades
%                     index1=startdev1<threshold1 & enddev1<threshold2 & starttimes>minlatency & starttimes<maxlatency;
%                     
%                     % If such is saccade found, record it
%                     if sum(index1)==1
%                         sacmatrix(tid,:)=[sx2(index1,1),sx2(index1,2),sx2(index1,3),sx2(index1,4),sx2(index1,5),sx2(index1,6),sx2(index1,7)];
%                         e_dist1(tid)=enddev1(index1); % Distance to the target is saved
%                     end
%                     
%                     % If no saccade is found, record error trial
%                     if sum(index1)~=1
%                         % Do nothing
%                     elseif sum(index1)==1
%                         trial_accepted(tid) = -1;
%                     end
%                 end
%             end
%         end
%         
%         %% ALSO FIND SACCADES DIRECTED TO WRONG TARGET
%         
%         for tid=1:size(sacc1,1)
%             
%             % Data to be used
%             sx1=sacc1{tid}; % Manipulated data
%             sx2=sacc1{tid}; % Raw data
%             
%             if size(sx1,2)>1 && trial_accepted(tid)~=2 && S.em_target_number(tid)==2 && S.em_blockcond(tid)~=5 % Only if two targets were presented
%                 
%                 % Starting position
%                 saccstart(1)=0;
%                 saccstart(2)=0;
%                 sx1(:,3)=sx1(:,3)-saccstart(1);
%                 sx1(:,4)=sx1(:,4)-saccstart(2);
%                 
%                 % Ending position
%                 if S.em_blockcond(tid)==1 && S.em_target_number(tid)==2
%                     xc = S.em_t2_coord1(tid);
%                     yc = S.em_t2_coord2(tid);
%                 elseif S.em_blockcond(tid)==2 && S.em_target_number(tid)==2
%                     xc = S.em_t1_coord1(tid);
%                     yc = S.em_t1_coord2(tid);
%                 end
%                 sx1(:,5)=sx1(:,5)-xc;
%                 sx1(:,6)=sx1(:,6)-yc;
%                 
%                 if ~isnan(S.distractor_on(tid))
%                     
%                     % Settings on each trial used
%                     minlatency = S.distractor_on(tid) + minlatency_baseline;
%                     maxlatency = S.distractor_off(tid);
%                     threshold1 = S.fixation_accuracy{tid};
%                     threshold2 = S.response_saccade_accuracy{tid};
%                     
%                     % Find distance between wanted and actual sacc position
%                     startdev1=sqrt((sx1(:,3).^2)+(sx1(:,4).^2));
%                     enddev1=sqrt((sx1(:,5).^2)+(sx1(:,6).^2));
%                     starttimes=sx1(:,1);
%                     
%                     % index1 is correct saccades
%                     index1=startdev1<threshold1 & enddev1<threshold2 & starttimes>minlatency & starttimes<maxlatency;
%                     
%                     
%                     % If such is saccade found, record it
%                     if isnan(trial_accepted(tid)) % Only if that trial is not used already
%                         if sum(index1)==1
%                             sacmatrix(tid,:)=[sx2(index1,1),sx2(index1,2),sx2(index1,3),sx2(index1,4),sx2(index1,5),sx2(index1,6),sx2(index1,7)];
%                             e_dist2(tid)=enddev1(index1); % Distance to the distractor is saved
%                             trial_accepted(tid)=-2;
%                         end
%                     elseif trial_accepted(tid) == -1 % If trial is used already, choose saccade directed to closer object
%                         if sum(index1) == 1 % If saccade to the distractor is found is found
%                             e_dist2(tid) = enddev1(index1); % Distance to the distractor is saved
%                             a1=e_dist1(tid); % Distance to the target
%                             a2=e_dist2(tid); % Distance to the distractor
%                             if a2<a1
%                                 sacmatrix(tid,:)=[sx2(index1,1),sx2(index1,2),sx2(index1,3),sx2(index1,4),sx2(index1,5),sx2(index1,6),sx2(index1,7)];
%                                 trial_accepted(tid) = -2;
%                             end
%                         end
%                     end
%                 end
%                 
%             end
%         end
%         
%         %=================
%         %=================
%         
%         %% Correct trial detection on fixation trials
%         
%         
%         for tid=1:size(sacc1,1)
%             
%             % Data to be used
%             if isnan(trial_accepted(tid)) && S.em_blockcond(tid)==5
%                 
%                 % If memory target appeared
%                 if ~isnan(S.memory_on(tid)) && S.em_data_reject(tid)==1 % If memory target appeared
%                     
%                     % Settings on each trial used
%                     minlatency = S.memory_on (tid);
%                     maxlatency = S.fixation_off(tid);
%                     threshold1 = S.em_fixation_window(tid);
%                     xc = 0; yc = 0; % Fixation coordinates
%                     
%                     % Select data of interest
%                     index1=saccraw1{tid}(:,1)>=minlatency & saccraw1{tid}(:,1)<=maxlatency;
%                     dat1=saccraw1{tid}(index1,:);
%                     
%                     % Reset data relative to fixation
%                     dat1(:,2)=dat1(:,2)-xc;
%                     dat1(:,3)=dat1(:,3)-yc;
%                     
%                     startdev1=sqrt((dat1(:,2).^2)+(dat1(:,3).^2));
%                     index1 = startdev1>threshold1;
%                     
%                     if sum(index1)>0
%                         trial_accepted(tid)=4; % Fixation broken before saccade target onset
%                     elseif sum(index1)==0
%                         trial_accepted(tid)=-1; % Fixation broken before saccade target onset
%                     end
%                     
%                     
%                 end
%             end
%         end
%         
%         
%         %% Saccade made to memory target during delay period
%         
%         for tid=1:size(sacc1,1)
%             
%             % Data to be used
%             sx1=sacc1{tid}; % Manipulated data
%             sx2=sacc1{tid}; % Raw data
%             
%             if size(sx1,2)>1 && trial_accepted(tid)~=2
%                 
%                 % Starting position
%                 saccstart(1)=0;
%                 saccstart(2)=0;
%                 sx1(:,3)=sx1(:,3)-saccstart(1);
%                 sx1(:,4)=sx1(:,4)-saccstart(2);
%                 
%                 % Ending position
%                 xc = S.em_target_coord1(tid);
%                 yc = S.em_target_coord2(tid);
%                 sx1(:,5)=sx1(:,5)-xc;
%                 sx1(:,6)=sx1(:,6)-yc;
%                 
%                 if ~isnan(S.memory_on(tid)) % If memory was presented
%                     
%                     % Settings on each trial used
%                     minlatency = S.memory_on(tid);
%                     if ~isnan(S.targets_on(tid)) % If response target was presented
%                         maxlatency = S.targets_on(tid) + minlatency_baseline; % Maximum is the appearance of the response target
%                     elseif isnan(S.targets_on(tid)) % If response target was not presented
%                         maxlatency = S.targets_off(tid); % Maximum is trial over period
%                     end
%                     threshold1 = S.fixation_accuracy{tid};
%                     threshold2 = S.response_saccade_accuracy{tid};
%                     
%                     % Find distance between wanted and actual sacc position
%                     startdev1=sqrt((sx1(:,3).^2)+(sx1(:,4).^2));
%                     enddev1=sqrt((sx1(:,5).^2)+(sx1(:,6).^2));
%                     starttimes=sx1(:,1);
%                     
%                     % index1 is correct saccades
%                     index1=startdev1<threshold1 & enddev1<threshold2 & starttimes>minlatency & starttimes<maxlatency;
%                     
%                     % If such is saccade found, record it
%                     if sum(index1)==1 && isnan(trial_accepted(tid)) % Only if that trial is not used already
%                         sacmatrix(tid,:)=[sx2(index1,1),sx2(index1,2),sx2(index1,3),sx2(index1,4),sx2(index1,5),sx2(index1,6),sx2(index1,7)];
%                         e_mem(tid)=enddev1(index1); % Distance to the distractor is saved
%                         trial_accepted(tid)= 5;
%                     end
%                     
%                 end
%             end
%         end
%         
%         % %% Saccade made to memory target during response period (only on few trials this is relevant)
%         %
%         % for tid=1:size(sacc1,1)
%         %
%         %     % Data to be used
%         %     sx1=sacc1{tid};
%         %     sx2=sacc1{tid};
%         %
%         %     if size(sx1,2)>1 && trial_accepted(tid)~=2
%         %
%         %         % Starting position
%         %         saccstart(1)=0;
%         %         saccstart(2)=0;
%         %         sx1(:,3)=sx1(:,3)-saccstart(1);
%         %         sx1(:,4)=sx1(:,4)-saccstart(2);
%         %
%         %         % Ending position
%         %         xc = S.expmatrix(tid,em_target_coord1);
%         %         yc = S.expmatrix(tid,em_target_coord2);
%         %         sx1(:,5)=sx1(:,5)-xc;
%         %         sx1(:,6)=sx1(:,6)-yc;
%         %
%         %         % Only if ST and memory targets don't overlap
%         %         v1 = S.expmatrix(tid,em_target_coord1)-S.expmatrix(tid,em_t3_coord1);
%         %         v2 = S.expmatrix(tid,em_target_coord2)-S.expmatrix(tid,em_t3_coord2);
%         %         r1 = sqrt(v1.^2 + v2.^2); % Distance between two targets
%         %
%         %
%         %         if ~isnan(S.memory_on(tid)) && ~isnan(S.target1_on(tid)) && S.expmatrix(tid,em_target_number)==1 && ...
%         %                 r1 >= S.response_saccade_accuracy_exp(tid)
%         %
%         %             % Settings on each trial used
%         %             minlatency = S.target1_on(tid); % Minimum is time after response target appears
%         %             maxlatency = S.target1_off(tid); % Maximum is the disappearance of all targets
%         %             threshold1 = S.fixation_accuracy_exp(tid);
%         %             threshold2 = S.response_saccade_accuracy_exp(tid);
%         %
%         %             % Find distance between wanted and actual sacc position
%         %             startdev1=sqrt((sx1(:,3).^2)+(sx1(:,4).^2));
%         %             enddev1=sqrt((sx1(:,5).^2)+(sx1(:,6).^2));
%         %             starttimes=sx1(:,1);
%         %
%         %             % index1 is correct saccades
%         %             index1=startdev1<threshold1 & enddev1<threshold2 & starttimes>minlatency & starttimes<maxlatency;
%         %
%         %             if isnan(trial_accepted(tid)) % Only if that trial is not used already
%         %                 if sum(index1)==1
%         %                     sacmatrix(tid,:)=[sx2(index1,1),sx2(index1,2),sx2(index1,3),sx2(index1,4),sx2(index1,5),sx2(index1,6),sx2(index1,7)];
%         %                     e_mem(tid)=enddev1(index1); % Distance to the distractor is saved
%         %                     trial_accepted(tid)=5;
%         %                 end
%         %             elseif trial_accepted(tid) == -1 % If trial is used already, choose saccade directed to closer object
%         %                 if sum(index1) == 1 % If saccade to the distractor is found is found
%         %                     e_mem(tid) = enddev1(index1); % Distance to the distractor is saved
%         %                     a1=e_dist1(tid); % Distance to the target
%         %                     a2=e_mem(tid); % Distance to the distractor
%         %                     if a2<a1
%         %                         sacmatrix(tid,:)=[sx2(index1,1),sx2(index1,2),sx2(index1,3),sx2(index1,4),sx2(index1,5),sx2(index1,6),sx2(index1,7)];
%         %                         trial_accepted(tid) = 5;
%         %                     end
%         %                 end
%         %             end
%         %
%         %         end
%         %     end
%         % end
%         
%         
%         
%         %% Aborted trials due to lack of motivation: Fixation not acquired during the trial
%         
%         for tid=1:size(sacc1,1)
%             
%             % Data to be used
%             if trial_accepted(tid)~=2
%                 
%                 % Time of interest
%                 if isnan(S.fixation_acquired(tid))  % If trial was terminated before fixation was acquired
%                     
%                     % Settings on each trial used
%                     minlatency = S.fixation_on(tid);
%                     maxlatency = S.fixation_off(tid);
%                     if S.fixation_drift_correction_on{tid}==1
%                         threshold1 = S.fixation_accuracy_drift{tid};
%                     else
%                         threshold1 = S.em_fixation_window(tid);
%                     end
%                     xc = 0; yc = 0; % Fixation coordinates
%                     
%                     % Select data of interest
%                     index1=saccraw1{tid}(:,1)>=minlatency & saccraw1{tid}(:,1)<=maxlatency;
%                     dat1=saccraw1{tid}(index1,:);
%                     
%                     % Reset data relative to fixation
%                     dat1(:,2)=dat1(:,2)-xc;
%                     dat1(:,3)=dat1(:,3)-yc;
%                     
%                     startdev1=sqrt((dat1(:,2).^2)+(dat1(:,3).^2));
%                     index1 = startdev1<threshold1;
%                     
%                     if sum(index1)==0
%                         trial_accepted(tid)=3; % Fixation not acquired
%                     end
%                 end
%             end
%         end
%         
%         
%         
%         %% Aborted trials due to lack of motivation: breaking fixation before stimuli appear
%         
%         %=============
%         % Part 1
%         %=============
%         
%         
%         % On trials with memory target - breaking fixation before memory appears
%         for tid=1:size(sacc1,1)
%             
%             % Data to be used
%             if trial_accepted(tid)~=2 && trial_accepted(tid)~=3
%                 
%                 % If memory target appeared
%                 if ~isnan(S.memory_on(tid)) % If memory target appeared
%                     
%                     % Settings on each trial used
%                     minlatency = S.drift_maintained (tid);
%                     maxlatency = S.memory_on(tid);
%                     threshold1 = S.em_fixation_window(tid);
%                     xc = 0; yc = 0; % Fixation coordinates
%                     
%                     % Select data of interest
%                     index1=saccraw1{tid}(:,1)>=minlatency & saccraw1{tid}(:,1)<=maxlatency;
%                     dat1=saccraw1{tid}(index1,:);
%                     
%                     % Reset data relative to fixation
%                     dat1(:,2)=dat1(:,2)-xc;
%                     dat1(:,3)=dat1(:,3)-yc;
%                     
%                     startdev1=sqrt((dat1(:,2).^2)+(dat1(:,3).^2));
%                     index1 = startdev1>threshold1;
%                     
%                     if sum(index1)>0
%                         trial_accepted(tid)=4; % Fixation broken before saccade target onset
%                     end
%                     
%                     % If memory target did not appear
%                 elseif isnan(S.memory_on(tid))
%                     
%                     % Settings on each trial used
%                     minlatency = S.drift_maintained (tid);
%                     maxlatency = S.fixation_off(tid);
%                     threshold1 = S.em_fixation_window(tid);
%                     xc = 0; yc = 0; % Fixation coordinates
%                     
%                     % Select data of interest
%                     index1=saccraw1{tid}(:,1)>=minlatency & saccraw1{tid}(:,1)<=maxlatency;
%                     dat1=saccraw1{tid}(index1,:);
%                     
%                     % Reset data relative to fixation
%                     dat1(:,2)=dat1(:,2)-xc;
%                     dat1(:,3)=dat1(:,3)-yc;
%                     
%                     startdev1=sqrt((dat1(:,2).^2)+(dat1(:,3).^2));
%                     index1 = startdev1>threshold1;
%                     
%                     if sum(index1)>0
%                         trial_accepted(tid)=4; % Fixation broken before saccade target onset
%                     end
%                     
%                 end
%             end
%         end
%         
%         % Also check for large saccades during fixation period
%         threshold1 = 1; % Max allowed saccade size
%         
%         for tid=1:size(sacc1,1)
%             
%             % Data to be used
%             sx1=sacc1{tid};
%             sx2=sacc1{tid};
%             
%             if size(sx1,2)>1  && ~isnan(S.targets_on(tid)) && isnan(trial_accepted(tid))
%                 
%                 % Find saccade length
%                 xsacc=sx1(:,5)-sx1(:,3);
%                 ysacc=sx1(:,6)-sx1(:,4);
%                 sacclength=sqrt((xsacc.^2)+(ysacc.^2));
%                 starttimes=sx1(:,1);
%                 
%                 % Settings on each trial used
%                 minlatency=S.drift_maintained(tid);
%                 maxlatency=S.memory_on(tid);
%                 
%                 % index1 is correct saccades
%                 index1=sacclength>=threshold1 & starttimes>minlatency & starttimes<=maxlatency;
%                 if sum(index1)>0
%                     trial_accepted(tid)=4; % Incorrect saccades during response period
%                 end
%             end
%             
%         end
%         
%         
%         %=============
%         % Part 3
%         %=============
%         
%         % Breaking fixation before drift is established
%         for tid=1:size(sacc1,1)
%             
%             % Data to be used
%             if isnan(trial_accepted(tid))
%                 
%                 % Time of interest
%                 if isnan(S.drift_maintained(tid)) % If memory target appeared
%                     
%                     % Settings on each trial used
%                     minlatency = S.fixation_on(tid);
%                     maxlatency = S.fixation_off(tid);
%                     if S.fixation_drift_correction_on{tid}==1
%                         threshold1 = S.fixation_accuracy_drift{tid};
%                     else
%                         threshold1 = S.em_fixation_window(tid);
%                     end
%                     xc = 0; yc = 0; % Fixation coordinates
%                     
%                     % Select data of interest
%                     index1=saccraw1{tid}(:,1)>=minlatency & saccraw1{tid}(:,1)<=maxlatency;
%                     dat1=saccraw1{tid}(index1,:);
%                     
%                     % Reset data relative to fixation
%                     dat1(:,2)=dat1(:,2)-xc;
%                     dat1(:,3)=dat1(:,3)-yc;
%                     
%                     startdev1=sqrt((dat1(:,2).^2)+(dat1(:,3).^2));
%                     index1 = startdev1>threshold1;
%                     
%                     if sum(index1)>0
%                         trial_accepted(tid)=4; % Fixation broken before saccade target onset
%                     end
%                     
%                 end
%             end
%         end
%         
%         
%         
%         %% No saccades executed during the response period
%         
%         threshold1 = 1; % Max allowed saccade size
%         
%         for tid=1:size(sacc1,1)
%             
%             % Data to be used
%             sx1=sacc1{tid};
%             sx2=sacc1{tid};
%             
%             if size(sx1,2)>1  && ~isnan(S.targets_on(tid)) && isnan(trial_accepted(tid))
%                 
%                 % Find saccade length
%                 xsacc=sx1(:,5)-sx1(:,3);
%                 ysacc=sx1(:,6)-sx1(:,4);
%                 sacclength=sqrt((xsacc.^2)+(ysacc.^2));
%                 starttimes=sx1(:,1);
%                 
%                 % Settings on each trial used
%                 minlatency=S.targets_on(tid);
%                 maxlatency=S.targets_off(tid);
%                 
%                 % index1 is correct saccades
%                 index1=sacclength>=threshold1 & starttimes>minlatency & starttimes<=maxlatency;
%                 if sum(index1)==0
%                     trial_accepted(tid)=6; % No signifficant saccade executed
%                 end
%                 
%             elseif size(sx1,2)==1 && ~isnan(S.targets_on(tid)) && isnan(trial_accepted(tid))
%                 trial_accepted(tid)=6; % No signifficant saccade executed
%             end
%             
%         end
%         
%         
%         %% Incorrect saccades during response period
%         
%         threshold1 = 0.5; % Max allowed saccade size
%         
%         for tid=1:size(sacc1,1)
%             
%             % Data to be used
%             sx1=sacc1{tid};
%             sx2=sacc1{tid};
%             
%             if size(sx1,2)>1  && ~isnan(S.targets_on(tid)) && isnan(trial_accepted(tid))
%                 
%                 % Find saccade length
%                 xsacc=sx1(:,5)-sx1(:,3);
%                 ysacc=sx1(:,6)-sx1(:,4);
%                 sacclength=sqrt((xsacc.^2)+(ysacc.^2));
%                 starttimes=sx1(:,1);
%                 
%                 % Settings on each trial used
%                 minlatency=S.targets_on(tid);
%                 maxlatency=S.targets_off(tid);
%                 
%                 % index1 is correct saccades
%                 index1=sacclength>=threshold1 & starttimes>minlatency & starttimes<=maxlatency;
%                 if sum(index1)>0
%                     trial_accepted(tid)=7; % Incorrect saccades during response period
%                 end
%             end
%             
%         end
%         
%         
%         %% Incorrect saccades between memory onset and saccade target onset
%         
%         threshold1 = 2; % Max allowed saccade size
%         
%         for tid=1:size(sacc1,1)
%             
%             % Data to be used
%             sx1=sacc1{tid}; % Manipulated data
%             sx2=sacc1{tid}; % Raw data
%             
%             % If memory appeared and then saccade target appeared (even if trial would be accepted otherwise)
%             if size(sx1,2)>1  && ~isnan(S.memory_on(tid)) && ~isnan(S.targets_on(tid))
%                 
%                 % Find saccade length
%                 xsacc=sx1(:,5)-sx1(:,3);
%                 ysacc=sx1(:,6)-sx1(:,4);
%                 sacclength=sqrt((xsacc.^2)+(ysacc.^2));
%                 starttimes=sx1(:,1);
%                 
%                 % Settings on each trial used
%                 minlatency=S.memory_on(tid);
%                 maxlatency=S.targets_on(tid);
%                 
%                 % index1 is correct saccades
%                 index1=sacclength>=threshold1 & starttimes>minlatency & starttimes<=maxlatency;
%                 if sum(index1)>0
%                     trial_accepted(tid)=8; % Incorrect saccades during response period
%                 end
%                 
%                 % If memory appeared but then saccade target did not appear
%             elseif size(sx1,2)>1  && ~isnan(S.memory_on(tid)) && isnan(S.targets_on(tid)) && isnan(trial_accepted(tid))
%                 
%                 % Find saccade length
%                 xsacc=sx1(:,5)-sx1(:,3);
%                 ysacc=sx1(:,6)-sx1(:,4);
%                 sacclength=sqrt((xsacc.^2)+(ysacc.^2));
%                 starttimes=sx1(:,1);
%                 
%                 % Settings on each trial used
%                 minlatency=S.memory_on(tid);
%                 maxlatency=S.fixation_off(tid);
%                 
%                 % index1 is correct saccades
%                 index1=sacclength>=threshold1 & starttimes>minlatency & starttimes<=maxlatency;
%                 if sum(index1)>0
%                     trial_accepted(tid)=8; % Incorrect saccades during response period
%                 end
%                 
%             end
%             
%         end
%         
%         
%         %% Remove trials if a blink occured
%         
%         threshold1 = 0; % How many ms of blink within specific time frame is tolerated
%         
%         for tid=1:size(sacc1,1)
%             
%             % Data to be used
%             if trial_accepted(tid)~=2
%                 
%                 % Time of interest
%                 if ~isnan(S.drift_maintained(tid))
%                     
%                     minlatency = S.drift_maintained(tid);
%                     maxlatency = S.targets_off(tid); % Its saved on each trial, even if t1 didnt appear
%                     
%                     index1=saccraw1{tid}(:,1)>=minlatency & saccraw1{tid}(:,1)<=maxlatency;
%                     dat1=saccraw1{tid}(index1,:); % Select data of interest
%                     index2=dat1(:,4)==0;
%                     
%                     if sum(index2)>threshold1
%                         trial_accepted(tid)=1; % Blink during saccade response period
%                     end
%                     
%                 elseif isnan(S.drift_maintained(tid)) % Blink during fixation period
%                     minlatency = S.fixation_on(tid);
%                     maxlatency = S.targets_off(tid); % T1 off is registered on each trial
%                     
%                     index1=saccraw1{tid}(:,1)>=minlatency & saccraw1{tid}(:,1)<=maxlatency;
%                     dat1=saccraw1{tid}(index1,:); % Select data of interest
%                     index2=dat1(:,4)==0;
%                     
%                     if sum(index2)>threshold1
%                         trial_accepted(tid)=1; % Blink during fixation period
%                     end
%                     
%                 end
%             end
%         end
%         
%         
%         
%         
%         %% Save converted saccades as matrix S
%         
%         path1 = sprintf('%s%s/%s/%s/', settings.path_figures, settings.figure_folder_name, settings.subject_current, folder_name) ;
%         if isdir(path1)
%             rmdir(path1, 's')
%             mkdir(path1)
%         else
%             mkdir(path1)
%         end
%         
%         %================
%         % Initialize empty file
%         
%         f_name = sprintf('%s%s.txt', path1, folder_name);
%         fclose('all');
%         fout = fopen(f_name,'w');        
%         
%         %===============
%         % Describe errors:
%         clear t1; t1={}; t0=[];
%         t0(1) = -1;
%         t1{1} = 'Good trials: Correct response (defined for each condition)';
%         
%         t0(2) = -2;
%         t1{2} = 'Good trials: Wrong target selected (trial still analysed for data)';
%         
%         t0(3) = 1;
%         t1{3} = 'Error - blink';
%         
%         t0(4) = 2;
%         t1{4} = 'Error - missing data';
%         
%         t0(5) = 3;
%         t1{5} = 'Error - aborted trial with no fixation';
%         
%         t0(6) = 4;
%         t1{6} = 'Error - aborted trial by breaking fixation';
%         
%         t0(7) = 5;
%         t1{7} = 'Error - looked at the memory';
%         
%         t0(8) = 6;
%         t1{8} = 'Error - no saccade initiated';
%         
%         t0(9) = 7;
%         t1{9} = 'Error - incorrect saccade';
%         
%         t0(10) = 8;
%         t1{10} = 'Error - broke fixation after memory but before sacccade target appeared';
%         
%         t0(11) = 99;
%         t1{11} = 'Error - Unknown error';
%         
%         
%         % Print out errors
%         a=size(sacmatrix,1); % a-total number of trials
%         index = isnan(trial_accepted);
%         trial_accepted(index)=99;
%         
%         targettext='\nTrials accepted and removed: \n';
%         fprintf(targettext);
%         fprintf(fout, targettext);
%         
%         targettext='Total trials tested: %d; \n\n';
%         fprintf(targettext, a);
%         fprintf(fout, targettext, a);
%         
%         for i_subj=1:length(t0)
%             c=length(find(trial_accepted == t0(i_subj) ));
%             targettext='%s: %d trials (%d percent) \n';
%             fprintf(targettext, t1{i_subj}, c, round((c/a)*100));
%             fprintf(fout, targettext, t1{i_subj}, c, round((c/a)*100));
%         end
%         
%         
%         % Save saccades into new matrix
%         sacc1 = struct;
%         sacc1.sacmatrix = sacmatrix;
%         sacc1.trial_accepted = trial_accepted;
%         save (eval('path3'), 'sacc1')
%         targettext='Saved saccades data: %s; \n\n';
%         fprintf(targettext, path3);

                
        end
        % End of analysis
        
    end
    % End of analysis for each day
    
end
% End of analysis for each subject

