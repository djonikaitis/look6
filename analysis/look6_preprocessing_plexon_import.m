% Extract plexon events and plexon analog signal. 
% Requires to modify this file according to data storage properties
% Latest revision - December 15, 2017
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


%% Analysis

for i_subj=1:length(settings.subjects)
    
    % Select curent subject
    settings.subject_current = settings.subjects{i_subj};
    
    % Get subject folder paths and dates to analyze
    settings = get_settings_path_and_dates_ini_v11(settings, 'path_data_plexon_raw_subject');
    dates_used = settings.data_sessions_to_analyze; 
    
    % Analysis for each day
    for i_date = 1:numel(dates_used)
        
        % Current folder to be analysed (raw date, with session index)
        date_current = dates_used(i_date);
        ind = date_current==settings.index_dates;
        folder_name_long = settings.index_directory{ind};
        folder_name_short = [settings.subject_current, num2str(date_current)];
             
        clear var1; clear var2; clear var3;
        
        %================
        % Input file
        path_plexon_pl2_raw = [settings.path_data_plexon_raw_subject, folder_name_long, '/' folder_name_long, '.pl2'];
        path_plexon_pl2_temp1 = [settings.path_data_plexon_temp1_subject, folder_name_short, '/' folder_name_short, '.pl2'];
        
        if exist(path_plexon_pl2_raw, 'file')
            path_in = path_plexon_pl2_raw;
        elseif exist(path_plexon_pl2_temp1, 'file')
            path_in = path_plexon_pl2_temp1;
        else
            path_in = [];
        end
              
        %===========
        % Extract all events from pl2 file 
        %===========
        
        % Output
        path_out =  [settings.path_data_plexon_mat, folder_name_short, '/'];
        path1 = [settings.path_data_plexon_mat, folder_name_short, '/' folder_name_short, '_events.mat'];
                      
       if ~isempty(path_in) && (~exist(path1, 'file') || settings.overwrite==1)
           
           if ~isdir(path_out)
               mkdir(path_out);
           end
           fprintf('Extracting events from %s.pl2\n', folder_name_long);
           plexon_events_v10(path_in, path1); % Script doing import of pl2 file
           
           % Load file in in order to combine it later
           if exist(path1, 'file')
               var1 = get_struct_v11(path1);
               if isempty (var1)
                   fprintf('Failed to extract events, file is empty %s\n', folder_name_short);
               else
                   fprintf('Successfully extracted events %s\n', folder_name_short);
               end
           end

       elseif isempty(path_in)
           fprintf('File "%s.pl2" does not exist for a date %s\n', folder_name_long, num2str(date_current));
       elseif exist(path1, 'file') && settings.overwrite==0
           fprintf('File "%s_events.mat" already exists, skipping event extraction for date %s\n', folder_name_long, num2str(date_current))
       else
           fprintf('Unknown error for pl2 event extractio, date %s\n', num2str(date_current))
       end
        
        %===========
        % Extract analog signal of interest from pl2 file 
        %===========
        
        % Output
        path_out =  [settings.path_data_plexon_mat, folder_name_short, '/'];
        path2 = [settings.path_data_plexon_mat, folder_name_short, '/' folder_name_short, '_analog.mat'];
        channel_names{1} = 'AI01';
           
       if ~isempty(path_in) && (~exist(path2, 'file') || settings.overwrite==1)
           
           if ~isdir(path_out)
               mkdir(path_out);
           end
           fprintf('Extracting analog signal from %s.pl2\n', folder_name_long);
           plexon_analog_v10(path_in, path2, channel_names); % Script doing import of pl2 file

           % Load file in in order to combine it later
           if exist(path2, 'file')
               var2 = get_struct_v11(path2);
               if isempty (var2)
                   fprintf('Failed to extract analog signal, file is empty %s\n', folder_name_short);
               else
                   fprintf('Successfully extracted analog signal %s\n', folder_name_short);
               end
           end
           
       elseif isempty(path_in)
           fprintf('File "%s.pl2" does not exist for a date %s\n', folder_name_long, num2str(date_current));
       elseif exist(path2, 'file') && settings.overwrite==0
           fprintf('File "%s_analog.mat" already exists, skipping analog signal extraction for date %s\n', folder_name_long, num2str(date_current))
       else
           fprintf('Unknown error for pl2 analog signal extraction, date %s\n', num2str(date_current))
       end
       
       



% 
%         
%         %============
%         % Check whether all three files exist and copy them to the folder
%         % of interest
%         %============
%         
%         % At the moment analysis can not deal wiht more than one
%         % repetition, but this can be changed in this section
%         
%         % Path to data output output folder (without session indexes, just subject name and date)
%         f_name = [settings.subject_name, num2str(date_index(i_date))];
%         path1 = sprintf('%s%s/', settings.path_data_combined_plexon, f_name);
%         
%         % Check whether to remove directory or create one
%         if settings.overwrite==1
%             if isdir(path1)
%                 rmdir(path1, 's');
%             end
%         end
%         
%         if ~isempty(fieldnames(var1))
%             if ~isdir(path1);
%                 mkdir(path1);
%             end
%             plex = var1; 
%             p1 = sprintf('%s%s_spikes.mat', path1, f_name);
%             save(eval('p1'), 'plex');
%             fprintf('Saved spikes data in folder %s\n', f_name);
%         else
%             fprintf('Spikes data - no saving completed\n');
%         end
%         
%         if ~isempty(fieldnames(var2))
%             if ~isdir(path1);
%                 mkdir(path1);
%             end
%             plex = var2;
%             p1 = sprintf('%s%s_events.mat', path1, f_name);
%             save(eval('p1'), 'plex');
%             fprintf('Saved events data in folder %s\n', f_name);
%         else
%             fprintf('Events data - no saving completed\n');
%         end
%         
%         if ~isempty(fieldnames(var3))
%             if ~isdir(path1);
%                 mkdir(path1);
%             end
%             plex = var3;
%             p1 = sprintf('%s%s_analog.mat', path1, f_name);
%             save(eval('p1'), 'plex');
%             fprintf('Saved analog data in folder %s\n', f_name);
%         else
%             fprintf('Analog data - no saving completed\n');
%         end
       
        
        
    end
    % Pre-processing for each day is over
    
end
% Pre-processng for each subject is over



%         fprintf('------------------\n');
%         
%         %===========
%         % Convert pl2 file to mat file with all spikes
%         %===========
%         
%         path_in = settings.path_data_plexon_raw;
%         path_out = settings.path_data_plexon_mat;
%         file_name_in = [folder_name_raw,'_sorted'];
%         file_name_out = [folder_name_raw,'_spikes'];
%         path_plexon_pl2 = sprintf('%s%s/%s.pl2', path_in, folder_name_raw, file_name_in); % Path to raw plexon file
%         path_plexon_mat = sprintf('%s%s/%s.mat', path_out, folder_name_raw, file_name_out); % Path to output of extracted spikes matrix
%         
%         % Check whether to remove directory or create one
%         if settings.overwrite==1
%             dir_temp = [path_out, folder_name_raw];
%             if isdir(dir_temp)
%             rmdir(dir_temp, 's');
%             end
%         end
%             
%         if ~exist (path_plexon_mat,'file')
%             if ~exist (path_plexon_pl2, 'file')
%                 fprintf('%s.pl2 does not exist, either no recording or incorrect file names provided\n', file_name_in);
%             elseif exist (path_plexon_pl2, 'file') && ~exist (path_plexon_mat,'file') % If asc file doesn't exist - do the conversion
%                 if ~exist (path_plexon_mat,'file')
%                     %=====
%                     dir_temp = [path_out, folder_name_raw];
%                     if ~isdir(dir_temp);
%                         mkdir(dir_temp);
%                     end
%                     fprintf('Extracting spikes from %s.pl2\n', file_name_in);
%                     plexon_spikes_v11(path_plexon_pl2, path_plexon_mat); % Script doing import of pl2 file
%                     
%                     %======
%                     if exist(path_plexon_mat, 'file')
%                         varx = load(path_plexon_mat);
%                         % Extract a structure which is in the var1
%                         f1 = fieldnames(varx);
%                         if length(f1)==1
%                             var1 = varx.(f1{1});
%                         end
%                     end
%                     %=====
%                 end
%             end
%         else
%             fprintf('File %s already exists, skipping spike extraction\n', file_name_out)
%         end
%         
%         
%         % Load spikes file in in order to combine it later
%         if ~exist('var1', 'var')
%             var1 = struct; % Initialize empty structur
%         end
