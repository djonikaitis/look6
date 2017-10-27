% Psychophysics performance

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

settings.figure_folder_name = 'last day performance';
settings.figure_size_temp = settings.figsize_1col;
settings.stats_file_name = sprintf('statistics_%s_', settings.figure_folder_name);


% %% Preprocessing
% 
% % Load and select data
% for i_subj=1:length(settings.subjects)
%     
%     settings.subject_name=settings.subjects{i_subj}; % Select curent subject
%     
%     % Initialize subject specific folders where data is stored
%     for i=1:length(settings.path_spec_names)
%         v1 = ['path_', settings.path_spec_names{i}];
%         settings.(v1) = sprintf ('%s%s/', settings.path_spec_folder{i}, settings.subject_name);
%     end
%     
%     % Path to subject specific figures folder
%     path1_fig = sprintf('%s%s/%s/', settings.path_figures, settings.figure_folder_name, settings.subject_name);
%     if ~isdir(path1_fig)
%         mkdir(path1_fig)
%     elseif isdir(path1_fig)
%         rmdir(path1_fig, 's')
%         mkdir(path1_fig)
%     end
%     
%     % Initialize text file for statistics
%     nameOut = sprintf('%s%s.txt', path1_fig, settings.stats_file_name); % File to be outputed
%     fclose('all');
%     fout = fopen(nameOut,'w');
%     
%     % Get index of every folder for a given subject
%     session_init = get_path_dates_v20(settings.path_data_combined, settings.subject_name);
%     
%     % Save session_init matrix into settings matrix
%     % This part is necessary for preprocessing to run
%     f1_data = fieldnames(session_init);
%     for i=1:length(f1_data)
%         settings.(f1_data{i})= session_init.(f1_data{i});
%     end
% 
%     % Which date to analyse (all days or a single day)
%     if settings.preprocessing_sessions_used==1
%         ind = [1:length(session_init.index_unique_dates)];
%     elseif settings.preprocessing_sessions_used==2
%         ind = find(session_init.index_unique_dates==settings.preprocessing_day_id);
%     elseif settings.preprocessing_sessions_used==3
%         ind = length(session_init.index_unique_dates);
%     end
%     date_index = session_init.index_unique_dates(ind);
%     
%     for i_date = 1:length(date_index)
%         
%         % Current folder to be analysed (raw date, with session index)
%         i1 = find(date_index(i_date)==settings.index_dates);
%         folder_name = settings.index_directory{i1};
% 
%         % Load combined data
%         path1 = sprintf('%s%s/', settings.path_data_combined, folder_name);
%         file_name = [folder_name];
%         varx = load(sprintf('%s%s', path1, file_name));
%         f1 = fieldnames(varx);
%         S = struct; % Initialize empty var
%         if length(f1)==1
%             S = varx.(f1{1});
%         end
%         
%         % Load saccades data
%         path1 = sprintf('%s%s/', settings.path_data_combined, folder_name);
%         file_name = [folder_name, '_saccades'];
%         varx = load(sprintf('%s%s', path1, file_name));
%         f1 = fieldnames(varx);
%         var1 = struct; % Initialize empty var
%         if length(f1)==1
%             var1 = varx.(f1{1});
%         end
%         
%         % Copy saccades data into structure S
%         f1 = fieldnames(var1);
%         for i = 1:length(f1)
%             S.(f1{i}) = var1.(f1{i});
%         end
%     
%         %===============
%         %===============
%         % Data analysis
%         %===============
%         %===============
%     
%         % Rename some error codes (to avoid negative ones)
%         
%         S.expcond=NaN(size(S.session,1),1);
%         S.expcond = S.trial_accepted;
%         index = S.trial_accepted==-1;
%         S.expcond(index)=11;
%         index = S.trial_accepted==-2;
%         S.expcond(index)=12;
%         index = S.trial_accepted==99;
%         S.expcond(index)=13;
%     
%         S.training_stage = cell2mat(S.training_stage);
%     
%         % Initialize matrices
%         if i_date==ind_date(1)
%             test1 = NaN(length(ind_date), max(S.expcond), 2);
%         end
%     
%         % Error probability rates
%         for i=1:max(S.expcond)
%             for k = 1:max(S.training_stage)
%                 
%                 % Matrix with index
%                 index1 = S.expcond==i & S.training_stage==k;
%                 
%                 % Save data
%                 if sum(index1)>=1
%                     test1(i_date,i,k)=sum(index1);
%                 end
%                 
%             end
%         end
%         % End of error probability analysis
%     
%     end
% end
% % End of analysis for each subject
% 
% 
% %% Plot aggregate data
% 
% 
% %================
% % Plot data
% 
% % Initialize figure
% hfig=figure;
% hold on;
%   
% for fig1=1:4
%     
%     % Initialize data
%     %=================
%     conds1=[]; figcolor1=[]; legend1={}; total=[];
%     mat1=[];
%     save_name='Trial counts';
%   
%     % General motivation
%     if fig1==1
%         
%         t1 = nansum(test1,3); % Check all conditions combined
%         total=sum(t1,2); % Total number of trias
%         mat1(:,1)=t1(:,1) + t1(:,2) + t1(:,13); % Regular data loss (blinks, file loss, unknown error)
%         mat1(:,2)=t1(:,3) + t1(:,4); % Aborted trials (failures to initialize trial)
%         
%         % Convert data to %
%         for j=1:size(mat1,2)
%             mat1(:,j) = (mat1(:,j)./total)*100;
%         end
%         mat1 = mat1';
%         pbins = 1:size(mat1,2);
%         figcolor1=[41,42];
%         
%         legend1{1}='Natural loss';
%         legend1{2}='Aborted trials';
%         title1 = 'Data loss';
%         
%         % Task accuracy per day (all tasks combined)
%     elseif fig1==2
%         
%         t1 = nansum(test1,3);
%         total=t1(:,11) + t1(:,12); % Total number of triasl
%         mat1(:,1)=t1(:,11); % Correct trials
%         % Convert data to %
%         for j=1:size(mat1,2)
%             mat1(:,j) = (mat1(:,j)./total)*100;
%         end
%         mat1 = mat1';
%         pbins = 1:size(mat1,2);
%         figcolor1=[43];
%         legend1{1}='Correct target selected';
%         title1 = 'Task accuracy';
%         
%         % Total number of trials
%     elseif fig1==3
%         t1 = nansum(test1,3);
%         mat1=t1(:,11) + t1(:,12); % Total number of trials completed
%         mat1 = mat1';
%         pbins = 1:size(mat1,2);
%         figcolor1=[43];
%         legend1{1}='Completed trials';
%         title1 = 'General motivation';
%         
%     elseif fig1==4
%         t1 = nansum(test1(:,:,2),3);
%         mat1=t1(:,11) + t1(:,12); % Total number of trials completed
%         mat1 = mat1';
%         ind = mat1==0;
%         mat1(ind)=[];
%         pbins = 1:size(mat1,2);
%         figcolor1=[43];
%         legend1{1}='Completed trials';
%         title1 = 'Neurophys dates';
%         
%     end
%     
%     % Initialize figure
%     hfig = subplot(1, 4, fig1);
%     hold on;
% 
%     
%     if fig1==2
%         graphcond=43;
%         d1 = [1,1,1]-color1(graphcond,:);
%         color_temp=color1(graphcond,:)+d1.*0.9; % Look main
%         h=rectangle('Position', [pbins(1)-1, 80, pbins(end)+1, 20],...
%             'EdgeColor', 'none', 'FaceColor', color_temp, 'Curvature', 0, 'LineWidth', 1, 'LineStyle', '-');
%     end
%     
%     if fig1==3 || fig1==4
%         graphcond=43;
%         d1 = [1,1,1]-color1(graphcond,:);
%         color_temp=color1(graphcond,:)+d1.*0.9; % Look main
%         h=rectangle('Position', [pbins(1)-1, 750, pbins(end)+1, 2000],...
%             'EdgeColor', 'none', 'FaceColor', color_temp, 'Curvature', 0, 'LineWidth', 1, 'LineStyle', '-');
%         graphcond=1;
%     end
%     
%     
%     
%     %================
%     % Plot legend markers
%     
%     
%     % Set axes for legent
%     if fig1==1
%         x1 = [pbins(1), pbins(1)]; y1 = [80, 70];
%     elseif fig1==2
%         x1 = [pbins(1), pbins(1)]; y1 = [60];
%     elseif fig1==3 || fig1==4
%         x1 = [pbins(1)]; y1 = [max(mat1(1,:))+50];
%     end
%     
%     % Plot legend text
%     for k=1:length(legend1)
%         graphcond=figcolor1(k);
%         text(x1(k), y1(k), legend1{k}, 'Color', color1(graphcond,:),  'FontSize', settings.fontszlabel, 'HorizontalAlignment', 'left')
%     end
%     
%     %==================
%     % Plot lines
%     
%     for k=1:size(mat1,1)
%         h=plot(pbins, mat1(k,:));
%         graphcond=figcolor1(k);
%         set (h(end), 'LineWidth', settings.wlinegraph, 'Color', color1(graphcond,:))
%     end
%     
%     %==============
%     % Figure settings
%     
%     set (gca,'FontSize', settings.fontsz);
%     if fig1==1
%         set(gca,'YTick', 0:20:80);
%         set(gca,'YLim',[-5 105]);
%         ylabel ('Frequency, %', 'FontSize', settings.fontszlabel);
%     elseif fig1==2
%         set(gca,'YTick', [60:20:100]);
%         set(gca,'YLim',[50 105]);
%         ylabel ('Frequency, %', 'FontSize', settings.fontszlabel);
%     elseif fig1==3 || fig1==4
%         set(gca,'YTick', [250:250:1500]);
%         ylabel ('Number of trials', 'FontSize', settings.fontszlabel);
%         set(gca,'YLim',[min(mat1(1,:))-200, max(mat1(1,:)+200)]);
%     end
%     set(gca,'XLim',[pbins(1)-5, pbins(end)+5]);
%     xlabel ('Training day number', 'FontSize', settings.fontszlabel);
%     if pbins(end)<=10
%         set(gca,'XTick', [1,5,10]);
%     elseif pbins(end)<=20
%         set(gca,'XTick', [1,5:5:pbins(end)]);
%     elseif pbins(end)<=50
%         set(gca,'XTick', [1,10:10:pbins(end)]);
%     elseif pbins(end)<=100
%         set(gca,'XTick', [1,20:20:pbins(end)]);
%     end
%     
%     % Figure title
%     title (title1, 'FontSize', settings.fontszlabel)
%     
% 
%     
% end
% 
% %============
% % Export the figure & save it
% 
% fileName=[path1_fig, save_name];
% set(gcf, 'PaperPositionMode', 'manual');
% set(gcf, 'PaperUnits', 'inches');
% set(gcf, 'PaperPosition', settings.figsize1)
% set(gcf, 'PaperSize', [settings.figsize1(3),settings.figsize1(4)]);
% print (fileName, '-dpdf')
% print (fileName, '-dtiff', '-r600')
% close all;
% %===============
