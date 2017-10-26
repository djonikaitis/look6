% Combine files, extract saccades, extract spikes
% V1.0 Septeber 6, 2016
% V1.1 August 26, 2017. Updated to new exp setup. Added drift plotting
% figures. Made a function.
% V1.2 October 24, 2017. Drift bug fixes.
% Donatas Jonikaitis

% function  preprocessing_eyelink_conversion_v11(settings)

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

settings.figure_folder_name = 'preprocessing_drift_correction';
settings.figure_size_temp = [0, 0, 10, 8];
settings.color_map = magma(50);

if ~isfield(settings, 'drift_correction_time')
    error ('Drift correction settings not defined in setup file')
end

%% Analysis

% Run pre-processing for each subject
for i_subj = 1:length(settings.subjects)
    
    % Select curent subject
    settings.subject_current = settings.subjects{i_subj};
    
    % Get subject folder paths and dates to analyze
    settings = get_settings_path_and_dates_ini_v11(settings, 'path_data_temp_2_subject');
    dates_used = settings.data_sessions_to_analyze;
      
%     % Eyelink folder is used to determine existence of data files
%     session_init = get_dates(settings.path_data_temp_2_subject, settings.subject_current);
%     
%     % Save session_init data into settings matrix (needed for preprocessing)
%     f1_data = fieldnames(session_init);
%     for i=1:length(f1_data)
%         settings.(f1_data{i}) = session_init.(f1_data{i});
%     end
%     
%     % Which date to analyse (all days or a single day)
%     if isfield(settings, 'preprocessing_sessions_used')
%         if settings.preprocessing_sessions_used==1
%             ind = 1:length(session_init.index_unique_dates);
%         elseif settings.preprocessing_sessions_used==2
%             ind = find(session_init.index_unique_dates==settings.preprocessing_day_id);
%         elseif settings.preprocessing_sessions_used==3
%             ind = length(session_init.index_unique_dates);
%         end
%     else
%         fprintf('settings.preprocessing_day_id not defined, analyzing all data available\n')
%         ind = 1:length(session_init.index_unique_dates);
%     end
%     date_used = session_init.index_unique_dates(ind);
%     
%     % Analysis for each separate day
%     for i_date = 1:length(date_used)
%         
%         settings.date_current = date_used(i_date);
%         
%         %==========
%         folder_name = sprintf ('%s%d', settings.subject_current, settings.date_current);
%         % Output file
%         file_name_out = sprintf ('%s%s', folder_name, '.mat');
%         path1_out = [settings.path_data_combined_subject, folder_name, '/', file_name_out];
%         path1_out_folder = [settings.path_data_combined_subject, folder_name, '/'];
%         % Input file
%         file_name_in = sprintf ('%s%s', folder_name, '_settings.mat');
%         path1_settings_in = [settings.path_data_temp_2_subject, folder_name, '/', file_name_in];
%         % Raw data
%         file_name_raw = sprintf ('%s%s', folder_name, '_eye_traces.mat');
%         path1_raw_in = [settings.path_data_temp_2_subject, folder_name, '/', file_name_raw];
%         path1_raw_out = [settings.path_data_combined_subject, folder_name, '/', file_name_raw];
% 
%         % Figure path
%         path1_fig = [settings.path_figures, settings.figure_folder_name, '/', settings.subject_current, '/'];
%         if ~isdir(path1_fig)
%             mkdir(path1_fig)
%         end
%         
%         if ~exist(path1_out, 'file') || settings.overwrite==1
%             
%             % Create directory for the data
%             if isdir(path1_out_folder)
%                 rmdir(path1_out_folder, 's')
%                 fprintf('\nPreprocessing folder already exists, contents cleared\n')
%                 mkdir(path1_out_folder);
%             else
%                 fprintf('Created new directory for converted eyelink data\n')
%                 mkdir(path1_out_folder);
%             end
%             fprintf('\nPreparing matrix %s which stores all settings and data\n', file_name_out)
%             
%             % Load structure of interest
%             var1 = load_struct(path1_settings_in);
%             var2 = load_struct(path1_raw_in);
%             
%             if isempty(fieldnames(var1)) || isempty(fieldnames(var2))
%                 fprintf('Data for given date does not exist, possible debugging mode recorded only\n')
%             end
%             
%             % Convert saccades from pix to deg
%             if ~isempty(fieldnames(var1)) && ~isempty(fieldnames(var2))
%                 var1 = convert_saccades(var1);
%             end
%             
%             % Convert raw data from pix to deg
%             if ~isempty(fieldnames(var1)) && ~isempty(fieldnames(var2))
%                 var2 = convert_raw(var1, var2);
%             end
%             
%             % Remove fields I dont need any more
%             if ~isempty(fieldnames(var2))
%                 var2 = rmfield(var2, 'eye_raw');
%                 var2 = rmfield(var2, 'eye_preblink');
%             end
%             
%             % Drift correction
%             if ~isempty(fieldnames(var1)) && ~isempty(fieldnames(var2))
%                 [var1, var2, var3] = drift_corr(settings, var1, var2);
%                 drift_plot(settings, var1, var2, var3, path1_fig);
%             end
%             
%             % Extract only some structure fields (to save on space)
%             if ~isempty(fieldnames(var1))
%                 var1 = extract_fields(var1);
%             end
%                         
%             % Save data
%             if ~isempty(fieldnames(var1)) && ~isempty(fieldnames(var2))
%                 S = var1;
%                 save (eval('path1_out'), 'S')
%                 % Save raw data
%                 SR = var2;
%                 save (eval('path1_raw_out'), 'SR')
%             end
%             
%             
%         else
%             fprintf('\nFolder name %s already exists, skipping pre-processing\n', folder_name)
%             % Do nothing
%         end
%         
%         
%     end
%     % End of analysis for each date
    
end
% End of analysis for each subject





% %============
% % Add subject name at each path
% %============
% 
% function y = convert_path_to_subj(settings, s_name)
% % Add subject name to the path for simplifying the code
% 
% f1 = fieldnames(settings);
% ind = strncmp(f1,'path_data_', 10);
% for i = 1:numel(ind)
%     if ind(i)==1
%         v1 = sprintf('%s%s', f1{i}, '_subject');
%         settings.(v1) = sprintf('%s%s/', settings.(f1{i}), s_name);
%     end
% end
% 
% y = settings;
% 
% %==============
% % Determines which dates were recorded
% %==============
% 
% function y = get_dates(path1, s_name)
% 
% % Get index of every folder for a given subject
% session_init = get_path_dates_v20(path1, s_name);
% if isempty(session_init.index_dates)
%     fprintf('------------------\n');
%     fprintf('\nNo files detected, no data preprocessing done. Directory checked was:\n')
%     fprintf('%s\n', path1)
%     fprintf('------------------\n');
% end
% 
% y = session_init;
% 
% 
% 
% %============
% % Load structure
% %============
% 
% function y = load_struct(path0)
% 
% var1 = struct; varx = struct;
% 
% % Load the structure
% if exist(path0, 'file')
%     varx = load(path0);
%     f1 = fieldnames(varx);
%     if length(f1)==1
%         var1 = varx.(f1{1});
%     end
% end
% 
% y = var1;
% 
% 
% %============
% % Convert saccades
% %============
% 
% function y = convert_saccades(var1)
% 
% %  Convert saccades into degrees of visual angle
% 
% sacc1 = var1.eye_data.saccades_EK; % Copy saccades
% 
% for tid=1:length(sacc1)
%     sx1 = sacc1{tid};
%     if size(sx1,2)>1
%         sx1(:,[3,5]) = sx1(:,[3,5])-var1.screen.dispcenter{tid}(1); % Reset to display center (pixels)
%         sx1(:,[4,6]) = sx1(:,[4,6])-var1.screen.dispcenter{tid}(2);
%         sx1(:,[4,6]) = sx1(:,[4,6]) *-1; % For y coordinate multiply by (-1) - so that above display center is positive
%         sx1(:,[3,5]) = sx1(:,[3,5])./var1.screen.deg2pix{tid}; % Convert to degrees of visual angle
%         sx1(:,[4,6]) = sx1(:,[4,6])./var1.screen.deg2pix{tid}; % Convert to degrees of visual angle
%         sacc1{tid} = sx1; % Save it back into structure
%     end
% end
% 
% var1.eye_data.saccades_EK = sacc1;
% y = var1;
% 
% 
% %========================
% %  Convert raw data into degrees of visual angle
% %========================
% 
% function y = convert_raw(var1, var2)
% 
% % Reset raw data
% 
% saccraw1 = var2.eye_raw; % Copy raw data
% 
% for tid=1:length(saccraw1)
%     sx1 = saccraw1{tid};
%     if size(sx1,2)>1
%         sx1(:,2) = sx1(:,2)-var1.screen.dispcenter{tid}(1); % Reset to display center (pixels)
%         sx1(:,3) = sx1(:,3)-var1.screen.dispcenter{tid}(2);
%         sx1(:,3) = sx1(:,3) *-1; % For y coordinate multiply by (-1) - so that above display center is positive
%         sx1(:,2) = sx1(:,2)./var1.screen.deg2pix{tid}; % Convert to degrees of visual angle
%         sx1(:,3) = sx1(:,3)./var1.screen.deg2pix{tid}; % Convert to degrees of visual angle
%         saccraw1{tid} = sx1; % Save it back into structure
%     end
% end
% 
% var2.eye_processed = saccraw1;
% y = var2;
% 
% %========================
% % Extract only fields of interest
% %========================
% 
% function y = extract_fields(var1)
% 
% var_names = fieldnames(var1.stim);
% mat1 = get_fields_v10 (var1.stim, var_names); % Settings file with variables of interest
% % Extract eyelink_events
% var_names = fieldnames(var1.eyelink_events);
% mat2 = get_fields_v10 (var1.eyelink_events, var_names); % Settings file with variables of interest
% % Extract all eye_data variables
% var_names = fieldnames(var1.eye_data);
% mat3 = get_fields_v10 (var1.eye_data, var_names); % Settings file with variables of interest
% % Extract more variables of interest
% var_names={'session'; 'date'};
% mat4 = get_fields_v10 (var1, var_names); % Settings file with variables of interest
% 
% % Combine those fields into one structure
% names = [fieldnames(mat1); fieldnames(mat2); fieldnames(mat3); fieldnames(mat4)];
% S = cell2struct([struct2cell(mat1); struct2cell(mat2); struct2cell(mat3); struct2cell(mat4)], names, 1);
% 
% y = S;
% 
% 
% 
% %========================
% % Do drift conversion
% %========================
% 
% function [var1, var2,  var3] = drift_corr(settings, var1, var2)
% 
% fprintf('Doing drift correction\n')
% 
% % Eye position for drift correction
% sacc1 = var1.eye_data.saccades_EK;
% saccraw1 = var2.eye_processed;
% 
% % Time for drift calculations
% time1 = var1.eyelink_events.(settings.drift_correction_time); % Time relative to which drift correction is done
% t_start = time1 + settings.drift_correction_tstart; % Relative to time1 start checking for drift;
% t_end = time1 + settings.drift_correction_tend; % Relative to time1 end checking for drift;
% 
% % Drift accuracy
% a = var1.stim.(settings.drift_correction_window_max);
% if iscell (a)
%     amp_threshold = cell2mat(a);
% elseif size(a,2)>1
%     amp_threshold = a(:,4);
% elseif size(a,2)==1
%     amp_threshold = a;
% end
% 
% %===============
% % Dispersion of eye positions around the fixation
% 
% dist_mat = NaN(numel(sacc1),1);
% x_mat = NaN(numel(sacc1),1);
% y_mat = NaN(numel(sacc1),1);
% 
% for tid = 1:length(saccraw1)
%     
%     sx1 = saccraw1{tid};
%     
%     if ~isnan(t_start(tid))
%         
%         t1 = t_start(tid);
%         t2 = t_end(tid);
%         
%         % Convert raw data into coordinates
%         if length(sx1)>1
%             
%             % Select data samples within given time
%             index1=sx1(:,1)>=t1 & sx1(:,1)<=t2;
%             x1=sx1(index1,2);
%             y1=sx1(index1,3);
%             eyecoord1 = sqrt(x1.^2 + y1.^2); % Calculate amplitude of the eye position
%             
%             % Save output
%             dist_mat(tid)=nanmean(eyecoord1);
%             x_mat(tid)=nanmean(x1);
%             y_mat(tid)=nanmean(y1);
%         end
%         
%     end
% end
% 
% %==========
% % Drift correction
% 
% % Remove trials with too large distance from
% % fixation
% threshold1 = amp_threshold; % Any value higher than that is not used for resetting
% a = dist_mat;
% a(a>=threshold1) = NaN; % Remove trials that deviate from fixation too much
% 
% % Calculate mean/median distance from fixation
% if strcmp(settings.drift_correction_method, 'median')
%     avg_mat = movmedian(a, settings.drift_correction_trials, 'omitnan'); % How much to reset
% else
%     avg_mat = movmean(a, settings.drift_correction_trials, 'omitnan'); % How much to reset
% end
% 
% % Over-write non existing values
% ind = isnan(a);
% avg_mat(ind)=NaN;
% 
% % Do not reset trials with small fix deviation
% threshold1 = settings.drift_correction_window_min; % Any value higher than that is not used for resetting
% avg_mat(avg_mat<=threshold1) = 0;
% 
% % Drift correction
% [y_drift_mat, y_sacc, y_raw] = drift_correction_v14 (sacc1, saccraw1, avg_mat, t_start, t_end, settings.drift_correction_sacc_amp);
% 
% var1.eye_data.drift_correction = y_drift_mat;
% var1.eye_data.saccades_EK = y_sacc; % Over-write the field
% var2.eye_processed = y_raw; % Over-wrtie the field
% 
% var3.dist_mat = dist_mat;
% var3.x_mat = x_mat;
% var3.y_mat = y_mat;
% 
% 
% %================
% % Plot drift data
% %================
% 
% function drift_plot(settings, var1, var2, var3, path1_fig)
% 
% % Re-calculate dritf corrected data for
% % plotting
% 
% % Eye position for drift correction
% sacc1 = var1.eye_data.saccades_EK;
% saccraw1 = var2.eye_processed;
% drift_correction = var1.eye_data.drift_correction;
% 
% % Time for drift calculations
% time1 = var1.eyelink_events.(settings.drift_correction_time); % Time relative to which drift correction is done
% t_start = time1 + settings.drift_correction_tstart; % Relative to time1 start checking for drift;
% t_end = time1 + settings.drift_correction_tend; % Relative to time1 end checking for drift;
% 
% % Drift accuracy
% a = var1.stim.(settings.drift_correction_window_max);
% if iscell (a)
%     amp_threshold = cell2mat(a);
% elseif size(a,2)>1
%     amp_threshold = a(:,4);
% elseif size(a,2)==1
%     amp_threshold = a;
% end
% 
% %===============
% % Dispersion of eye positions around the fixation
% 
% dist_mat_post = NaN(numel(sacc1),1);
% x_mat_post = NaN(numel(sacc1),1);
% y_mat_post = NaN(numel(sacc1),1);
% 
%  
% for tid = 1:numel(saccraw1)
%     
%     sx1 = saccraw1{tid};
%     
%     if ~isnan(time1(tid))
%         
%         t1 = t_start(tid);
%         t2 = t_end(tid);
%         
%         % Convert raw data into coordinates
%         if length(sx1)>1
%             
%             % Select data samples within given time
%             index1=sx1(:,1)>=t1 & sx1(:,1)<=t2;
%             x1=sx1(index1,2);
%             y1=sx1(index1,3);
%             eyecoord1 = sqrt(x1.^2 + y1.^2); % Calculate amplitude of the eye position
%             
%             % Save output
%             dist_mat_post(tid)=nanmean(eyecoord1);
%             x_mat_post(tid)=nanmean(x1);
%             y_mat_post(tid)=nanmean(y1);
%         end
%         
%     end
% end
% 
% 
% %=================
% %=================
% 
% % Set threhsold for plotting
% plot_lim_x = max(amp_threshold);
% plot_lim_y = max(amp_threshold);
% 
% %=============
% %=============
% % Plot 1
% 
% for i=1:2
%     
%     ind = drift_correction(:,1)==1;
%     if i==1
%         h = subplot(2,3,1); hold on;
%         t1 = [1:numel(sacc1)];
%         t1 = t1(ind);
%         x1 = var3.x_mat(ind);
%         y1 = var3.y_mat(ind);
%     elseif i==2
%         h = subplot(2,3,4); hold on;
%         t1 = [1:numel(sacc1)];
%         t1 = t1(ind);
%         x1 = x_mat_post(ind);
%         y1 = y_mat_post(ind);
%     end
%     
%     % Plot all trials
%     if nansum(abs(x1))>0
%         scatter(x1, y1, 1, t1);
%         colormap (settings.color_map);
%     end
%     
%     % Colormap ticks and labels
%     a = length(t1); % Value to be used for bins
%     bins_total = 5;
%     bins_preset = [100, 250, 500, 1000, 2500, 5000];
%     ind1 = find (a<=bins_preset);
%     tick1 = [0 : bins_preset(ind1(1))/bins_total:bins_preset(ind1(1))];
%     tick1 = round(tick1,0);
%     
%     caxis([0, a])
%     hb = colorbar ('Limits', [0,a], 'Ticks', tick1);
%     ylabel(hb,'Trial numbers', 'FontSize', settings.fontszlabel)
%     
%     % X & Y labels
%     sacc1_x_label = 'X position';
%     sacc1_y_label = 'Y position';
%     xlabel (sacc1_x_label, 'FontSize', settings.fontszlabel)
%     ylabel (sacc1_y_label, 'FontSize', settings.fontszlabel)
%     
%     % X & Y ticks
%     x_tick =  [-2:1:2];
%     y_tick = [-2:1:2];
%     set(gca, 'XTick', x_tick);
%     set(gca, 'YTick', y_tick);
%     set(gca, 'XLim', [-plot_lim_x-plot_lim_x*0.1, plot_lim_x+plot_lim_x*0.1])
%     set(gca, 'YLim', [-plot_lim_y-plot_lim_y*0.1, plot_lim_y+plot_lim_y*0.1])
%     
%     % Title
%     if i==1
%         title_text = 'Before drift';
%     elseif i==2
%         title_text = 'After drift';
%     end
%     title(title_text, 'FontSize', settings.fontszlabel)
%     
% end
% 
% %=================
% %=================
% % Plot 2
% 
% for i=1:2
%     
%     if i==1
%         h = subplot(2,3,2); hold on;
%         a_mat = var3.dist_mat;
%     elseif i==2
%         h = subplot(2,3,5); hold on;
%         a_mat = dist_mat_post;
%     end
%     
%     amp1 = amp_threshold; % Max axes value
%     a_mat(a_mat>amp1) = max(amp1); % Clip axes
%     
%     % Plot all trials
%     h = plot(a_mat, 'Color', settings.color1(1,:), 'LineWidth', settings.wlineerror);
%     
%     % Plot moving average
%     b = movmedian(a_mat, settings.drift_correction_trials, 'omitnan');
%     h = plot(1:length(b), b, 'LineWidth', settings.wlineerror, 'Color', settings.color1(2,:));
%     
%     % X & Y labels
%     sacc1_x_label = 'Trial number';
%     sacc1_y_label = 'Fix deviation';
%     xlabel (sacc1_x_label, 'FontSize', settings.fontszlabel)
%     ylabel (sacc1_y_label, 'FontSize', settings.fontszlabel)
%     
%     % X ticks
%     a = length(a_mat); % Value to be used for bins
%     bins_total = 5;
%     bins_preset = [100, 250, 500, 1000, 2500, 5000];
%     ind1 = find (a<=bins_preset);
%     tick1 = [0 : bins_preset(ind1(1))/bins_total:bins_preset(ind1(1))];
%     tick1 = round(tick1,0);
%     
%     set(gca, 'XTick', tick1);
%     set(gca, 'XLim', [0-a*0.1, a+a*0.1])
%     
%     % Y ticks
%     amp1 = amp_threshold;
%     a = max(amp1);
%     bins_total = 4;
%     bins_preset = [1, 2, 3, 4, 5, 10];
%     ind1 = find (a<=bins_preset);
%     tick1 = [0 : bins_preset(ind1(1))/bins_total:bins_preset(ind1(1))];
%     tick1 = round(tick1,1);
%     set(gca, 'YTick', tick1);
%     set(gca, 'YLim', [-0.5, a+0.5])
%     
%     
%     % Title
%     if i==1
%         title_text = 'Before drift';
%     elseif i==2
%         title_text = 'After drift';
%     end
%     title(title_text, 'FontSize', settings.fontszlabel)
%     
% end
% 
% 
% %=================
% %=================
% % Plot 3
% 
% for i=1:2
%     
%     if i==1
%         h = subplot(2,3,3); hold on;
%         a_mat = var3.dist_mat;
%     elseif i==2
%         h = subplot(2,3,6); hold on;
%         a_mat = dist_mat_post;
%     end
%     
%     amp1 = amp_threshold; % Max axes value
%     a_mat(a_mat>amp1) = max(amp1); % Clip axes
% 
%     h = histogram(a_mat, 20, 'FaceColor', settings.color1(1,:), 'EdgeColor', settings.color1(1,:));
%     
%     sacc1_x_label = 'Fix deviation';
%     sacc1_y_label = 'Trial counts';
%     xlabel (sacc1_x_label, 'FontSize', settings.fontszlabel)
%     ylabel (sacc1_y_label, 'FontSize', settings.fontszlabel)
%     
%     % Y ticks
%     a = max(h.Values); % Value to be used for bins
%     bins_total = 5;
%     bins_preset = [100, 250, 500, 1000, 2500, 5000];
%     ind1 = find (a<=bins_preset);
%     tick1 = [0 : bins_preset(ind1(1))/bins_total : bins_preset(ind1(1))];
%     tick1 = round(tick1,0);
%     
%     set(gca, 'YTick', tick1);
%     set(gca, 'YLim', [0, a+a*0.1])
%     
%     % X ticks
%     a = h.BinLimits(2);
%     bins_total = 4;
%     bins_preset = [1, 2, 3, 4, 5, 10];
%     ind1 = find (a<=bins_preset);
%     tick1 = [0 : bins_preset(ind1(1))/bins_total : bins_preset(ind1(1))];
%     tick1 = round(tick1,1);
%     
%     set(gca, 'XTick', tick1);
%     set(gca, 'XLim', [-0.5, a+0.5])
%     
%     % Title
%     if i==1
%         title_text = 'Before drift';
%     elseif i==2
%         title_text = 'After drift';
%     end
%     title(title_text, 'FontSize', settings.fontszlabel)
%     
% end
% 
% %=================
% %=================
% % Save figure
% f_name = sprintf('%sdate_%d', path1_fig, settings.date_current);
% 
% set(gcf, 'PaperPositionMode', 'manual');
% set(gcf, 'PaperUnits', 'inches');
% set(gcf, 'PaperPosition', settings.figure_size_temp)
% set(gcf, 'PaperSize', [settings.figure_size_temp(3),settings.figure_size_temp(4)]);
% print (f_name, '-dpdf')
% 
% close all;
% 
% 
