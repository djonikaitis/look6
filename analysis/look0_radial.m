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


% % Axis properties
% minaxis1=50; % Limits latencies plotted
% maxaxis1=200; % Limits latencies plotted
% tick_small=[50:100:maxaxis1]; % Step for small tick
% tick_large=[100:100:maxaxis1]; % Step for large tick
% xi=[0:1:360]; % Circle size for interpolation
% plotang=90; % Angle at which tick marks are drawn
%
%
% % Combine two sides?
% bilateral1=1; % 1-both sided ploted; 2-two sides are combined into one & plotted pretending as if it was 2 sides


%% Extra settings

settings.figure_folder_name = 'srt radial';
settings.figure_size_temp = settings.figsize_1col;
settings.stats_file_name = sprintf('statistics_%s_', settings.figure_folder_name);

for i_subj=1:length(settings.subjects)
    
    % Select curent subject
    settings.subject_current = settings.subjects{i_subj};
    
    % Get subject folder paths and dates to analyze
    settings = get_settings_path_and_dates_ini_v11(settings);
    dates_used = settings.data_sessions_to_analyze;
    
    % Analysis for each day
    for i_date = 1:numel(dates_used)
        
        % Current folder to be analysed (raw date, with session index)
        date_current = dates_used(i_date);
        ind0 = date_current==settings.index_dates;
        folder_name = settings.index_directory{ind0};
        
        % Data folders
        path1 = [settings.path_data_combined_subject, folder_name, '/', folder_name, '.mat'];
        path2 = [settings.path_data_combined_subject, folder_name, '/', folder_name, '_saccades.mat'];
        
        % Load all files
        S = get_struct_v11(path1);
        sacc1 = get_struct_v11(path2);
        
        %             %=====
        %             % Get current training conditions
        %             c1 = unique(S.esetup_exp_version);
        %
        %             % Initialize matrices
        %             if i_date==1
        %                 conds1 = c1;
        %                 test1 = NaN(1, numel(dates_used), numel(c1), 3);
        %             end
        %
        %             % Add extra conditions if needed
        %             if i_date>1
        %                 for i=1:numel(c1)
        %                     a = strcmp(conds1, c1{i});
        %                     if sum(a)==0
        %                         m = numel(conds1);
        %                         conds1{m+1,1} = c1{i};
        %                         test1(1, :, m+1, 1:3) = NaN;
        %                     end
        %                 end
        %             end
        %
        
        
    end
    % End of each day
end
% End of each subject




%
%         %=============
%         % Combine data from all days
%         if current_day==1
%             A = S;
%         elseif current_day>1
%             f1_data = fieldnames(A);
%             for i=1:length(f1_data);
%                 try
%                     A.(f1_data{i})=[A.(f1_data{i}); S.(f1_data{i})];
%                 end
%             end
%         end
%         %============
%
%     end
%     % End of analysis for each day
%
%     % Save the data into structure S
%     S = A;
%
%     %===============
%     %===============
%     % ANALYSIS
%     %===============
%     %===============
%
%     % Find distances needed
%     if bilateral1==1
%         index=S.objposrel<0;
%         S.objposrel(index)=S.objposrel(index)+360; % Reset them all to the positive axis
%         probeposConds=(unique(removeNaN(S.objposrel)));
%     elseif bilateral1==2
%         S.objposrel=abs(S.objposrel);
%         probeposConds=(unique(removeNaN(S.objposrel)));
%     end
%
%     % Exp Condition
%     S.expcond=NaN(size(S.data,1),1);
%     % Look trials
%     index=S.maincond==1 & S.trialaccepted==-1 & S.target_number==1 & S.t3_pos(:,2)==S.t1_pos(:,2) & S.training_stage_exp==7;
%     S.expcond(index)=1;
%     % Avoid trials
%     index=S.maincond==2 & S.trialaccepted==-1 & S.target_number==1 & S.t3_pos(:,2)==S.t1_pos(:,2) & S.training_stage_exp==7;
%     S.expcond(index)=2;
%     % Look trials (2 targest)
%     index=S.maincond==1 & S.trialaccepted==-1 & S.target_number==2 & S.training_stage_exp==7;
%     S.expcond(index)=3;
%     S.objposrel(index)=0; % Re-mark target-distractor distance
%     % Avoid trials (2 targets)
%     index=S.maincond==2 & S.trialaccepted==-1 & S.target_number==2 & S.training_stage_exp==7;
%     S.expcond(index)=4;
%
%     % Reset saccade onset time to target onset (originally its relative to trial start)
%     S.sacconset=S.sacconset-S.target1_on;
%
%     %====================
%     % Saccade RT
%
%     mat1_data=NaN(1, length(probeposConds), max(S.expcond),1);
%     d1_data=NaN(1, length(probeposConds), max(S.expcond),1);
%     f1_data=NaN(1, length(probeposConds), max(S.expcond),1);
%     test1=NaN(1, length(probeposConds), max(S.expcond),1);
%
%     for i=1:max(S.expcond);
%         for j=1:length(probeposConds)
%
%             % Index
%             index1=S.expcond==i & S.objposrel==probeposConds(j);
%
%             if sum(index1)>settings.trial_total_threshold
%
%                 % Calculate means
%                 mat1_data(subj1,j,i)=nanmedian(S.sacconset(index1),1);
%
%                 % Add SRT variability for each subject
%                 % Calculate error bars
%                 a1=[]; b1=[]; c1=[];
%                 if settings.error_bars==1
%                     % Bootstrap the sample
%                     a1 = S.sacconset(index1);
%                     b1 = bootstrap(a1,tboot1);
%                     c1 = prctile(b1,[2.5,97.5]);
%                     d1_data(subj1,j,i) = mat1_data(subj1,j,i) - c1(1); % Lower bound (2.5 percentile)
%                     f1_data(subj1,j,i) = mat1_data(subj1,j,i) + c1(2); % Upper bound (97.5 percentile)
%                 elseif settings.error_bars==2
%                     % SEM
%                     a1 = S.sacconset(index1);
%                     d1_data(subj1,j,i) = mat1_data(subj1,j,i) - se(a1); % Standard error, lower bound (identical to upper one)
%                     f1_data(subj1,j,i) = mat1_data(subj1,j,i) + se(a1); % Standard error, upper bound (identical to lower one)
%                 end
%
%
%             end
%             test1(1,j,i)=sum(index1);
%
%         end
%     end
%
%
%
% end
% % End of analysis for each subject
%
%
% %% Plot
%
% for fig_legend1=2
%     for fig1=[1:3]
%
%         % Reset to figure to the limits chosen
%         tickrange1=maxaxis1-minaxis1;
%         tick_small_temp=tick_small-minaxis1;
%         tick_small_temp(tick_small_temp<=0)=[];
%         tick_large_temp=tick_large-minaxis1;
%         tick_large_temp(tick_large_temp<=0)=[];
%
%         % Initialize the data
%         hfig=figure;
%         set (gca, 'Color', [1,1,1])
%         hold on;
%         axis equal
%
%         %================
%         % Plot figure outlines
%
%         % Fill in the largest circle
%         if tick_small_temp(end)>=tick_large_temp(end)
%             ticks1=[tickrange1];
%             cpos1 = [0,0];
%             cl1=[0.9,0.9,0.9];
%         else
%             ticks1=[tickrange1];
%             cpos1 = [0,0];
%             cl1=[0.7,0.7,0.7];
%         end
%         h=rectangle('Position', [cpos1(1,1)-ticks1, cpos1(1,2)-ticks1, ticks1*2, ticks1*2],...
%             'EdgeColor', cl1, 'FaceColor', [1,1,1], 'Curvature', 1, 'LineWidth', 0.7, 'LineStyle', '-');
%
%
%         % Draw vertical and horizontal lines
%         cl1=[0.7,0.7,0.7];
%         h=plot([-tickrange1, tickrange1], [0,0]);
%         set (h(end), 'LineWidth', 0.7, 'Color', cl1)
%         h=plot([0,0], [-tickrange1, tickrange1]);
%         set (h(end), 'LineWidth', 0.7, 'Color', cl1)
%
%         % Fill the the central cirlce
%         if tick_small_temp(1)<=tick_large_temp(1)
%             ticks1=[tick_small_temp(1)];
%             cpos1 = [0,0];
%             cl1=[0.9,0.9,0.9];
%         else
%             ticks1=[tick_large_temp(1)];
%             cpos1 = [0,0];
%             cl1=[0.7,0.7,0.7];
%         end
%         h=rectangle('Position', [cpos1(1,1)-ticks1, cpos1(1,2)-ticks1, ticks1*2, ticks1*2],...
%             'EdgeColor', cl1, 'FaceColor', [1,1,1], 'Curvature', 1, 'LineWidth', 0.7, 'LineStyle', '-');
%
%         % Plot small cirlces
%         cpos1 = [0,0];
%         ticks1=[tick_small_temp];
%         cl1=[0.9,0.9,0.9];
%         for i=1:length(ticks1);
%             h=rectangle('Position', [cpos1(1,1)-ticks1(i), cpos1(1,2)-ticks1(i), ticks1(i)*2, ticks1(i)*2],...
%                 'EdgeColor', cl1, 'FaceColor', 'none', 'Curvature', 1, 'LineWidth', 0.7, 'LineStyle', '-');
%         end
%
%         % Plot large cirlces
%         cpos1 = [0,0];
%         ticks1=[tick_large_temp];
%         cl1=[0.7,0.7,0.7];
%         for i=1:length(ticks1);
%             h=rectangle('Position', [cpos1(1,1)-ticks1(i), cpos1(1,2)-ticks1(i), ticks1(i)*2, ticks1(i)*2],...
%                 'EdgeColor', cl1, 'FaceColor', 'none', 'Curvature', 1, 'LineWidth', 0.7, 'LineStyle', '-');
%         end
%
%         % Set up the limits of the graph
%         set(gca,'YLim',[-tickrange1 tickrange1]);
%         set(gca,'XLim',[-tickrange1 tickrange1]);
%
%
%         %================
%         % Plot the data
%         %================
%
%         mat2=mat1_data-minaxis1; % Reset the matrix to minimal axis
%         d2 = d1_data-minaxis1;
%         f2 = f1_data-minaxis1;
%
%
%         conds1=[]; figcolor1=[];
%         save_name=sprintf('fig%d', fig1);
%
%         if fig1==1
%             conds1=[3,4];
%             figcolor1=[1,2];
%             title1 = 'Main task';
%         elseif fig1==2
%             conds1=[1,3];
%             figcolor1=[1,2];
%             title1 = 'Look task';
%         elseif fig1==3
%             conds1=[2,4];
%             figcolor1=[1,2];
%             title1 = 'Avoid task';
%         elseif fig1==4
%
%         end
%
%         %=================
%         % Determine which plot-bins & data is used
%
%         pbins={};
%         mat1=NaN(size(mat2,1),size(mat2,2),length(conds1)); % Initialize empty matrix
%         mj1=NaN(size(mat2,1),size(mat2,2),length(conds1)); % Initialize empty matrix
%         mj2=NaN(size(mat2,1),size(mat2,2),length(conds1)); % Initialize empty matrix
%
%
%         for k=1:length(conds1)
%
%             pbins2=NaN(1,size(mat2,2)); % Initialize empty matrix
%             index=S.expcond==conds1(k);
%             p_rel1=unique(removeNaN(S.objposrel(index))); % Find displacements for each condition
%
%             % GENERAL PART
%             % Select relevant data
%             for m=1:length(p_rel1);
%                 index2=[];
%                 index2=find(probeposConds==p_rel1(m));
%                 pbins2(1,m) = probeposConds(index2);
%                 mat1(:,m,k) = mat2(:,index2,conds1(k));
%                 mj1(:,m,k) = d2(:,index2,conds1(k));
%                 mj2(:,m,k) = f2(:,index2,conds1(k));
%             end
%
%             % SPECIFIC PART
%             % Add extra values if needed
%             %========
%             % Two sides are plotted
%             if bilateral1==1
%                 if fig1==1
%                     pbins{k}=pbins2;
%                 elseif fig1==2
%                     if k==1
%                         pbins2(1,m+1)=360;
%                         pbins{k}=pbins2;
%                         mat1(:,m+1,k)=mat1(:,1,k);
%                         mj1(:,m+1,k)=mj1(:,1,k);
%                         mj2(:,m+1,k)=mj2(:,1,k);
%                     elseif k==2
%                         pbins{k}=pbins2;
%                     end
%                 elseif fig1==3
%                     if k==1
%                         pbins2(1,m+1)=360;
%                         pbins{k}=pbins2;
%                         mat1(:,m+1,k)=mat1(:,1,k);
%                         mj1(:,m+1,k)=mj1(:,1,k);
%                         mj2(:,m+1,k)=mj2(:,1,k);
%                     elseif k==2
%                         pbins{k}=pbins2;
%                     end
%                 end
%             end
%
%         end
%
%
%
%         %=====================
%         % Plot ERROR BARS
%         for k=1:size(mat1,3)
%
%             % Select only data with existing data in it
%             index=isfinite(pbins{k});
%             plotbins=pbins{k};
%             plotbins=plotbins(index);
%             d1=mj1(:,index,k);
%             f1=mj2(:,index,k);
%
%             graphcond=figcolor1(k);
%
%             % Plot error bars
%             if length(plotbins)>1
%
%                 % Set up x (error) and a (angle on the circle)
%                 xc1=f1(:,1,:); % Max error, 1st point
%                 xc2=d1(:,1,:); % Min error, 1st point
%                 xc3=d1(:,:,:); % Lower bound of error
%                 xc4=d1(:,end,:); % Min error, last point
%                 xc5=f1(:,end,:); % Max error, last point
%                 xc6=f1(:,:,:); % Upper bound of error
%                 ac1=plotbins(1);
%                 ac2=plotbins(1);
%                 ac3=plotbins;
%                 ac4=plotbins(end);
%                 ac5=plotbins(end);
%                 ac6=plotbins;
%
%                 % Extrapolate
%                 xc11=xc1;
%                 xc22=xc2;
%                 xc33=interp1(ac3,xc3,xi, 'linear');
%                 index_0=isfinite(xc33);
%                 xc33=xc33(index_0);
%                 xc44=xc4;
%                 xc55=xc5;
%                 xc66=interp1(ac6,xc6,xi, 'linear');
%                 index_1=isfinite(xc66);
%                 xc66=xc66(index_1);
%                 ac11=ac1;
%                 ac22=ac2;
%                 ac33=xi(index_0);
%                 ac44=ac4;
%                 ac55=ac5;
%                 ac66=xi(index_1);
%
%                 % Convert to polar coordinates
%                 [x1,y1]=pol2cart(ac11*pi/180,xc11);
%                 [x2,y2]=pol2cart(ac22*pi/180,xc22);
%                 [x3,y3]=pol2cart(ac33*pi/180,xc33);
%                 [x4,y4]=pol2cart(ac44*pi/180,xc44);
%                 [x5,y5]=pol2cart(ac55*pi/180,xc55);
%                 [x6,y6]=pol2cart(ac66*pi/180,xc66);
%                 x6=fliplr(x6);
%                 y6=fliplr(y6);
%
%                 % Plot the error bars
%                 h=fill([x1,x2,x3,x4,x5,x6],[y1, y2, y3, y4, y5, y6], [1 0.7 0.2],'linestyle','none');
%                 set (h(end), 'FaceColor', facecolor1(graphcond,:,:),'linestyle', 'none', 'FaceAlpha', 1)
%
%             end
%         end
%
%         % PLOT MEANS
%         for k=1:size(mat1,3)
%
%             % Select only data with existing data in it
%             index=isfinite(pbins{k});
%             plotbins=pbins{k};
%             plotbins=plotbins(index);
%             mat1_plot2=mat1(:,index,k);
%
%             % Plot circle lines
%             if length(plotbins)>1
%                 if size(mat1,1)>1
%                     yInt = interp1(plotbins,nanmean(mat1_plot2),xi, 'linear');
%                 else
%                     yInt = interp1(plotbins,mat1_plot2,xi, 'linear');
%                 end
%                 [xc, yc] = pol2cart(xi*pi/180,yInt);
%                 h=plot(xc, yc);
%                 graphcond=figcolor1(k);
%                 set (h(end), 'LineWidth', wlinegraph, 'Color', color1(graphcond,:))
%             end
%
%             % Plot markers
%             if (fig1==1 && k==1) || settings.marker_on==1
%                 if size(mat1,1)>1
%                     [xc, yc] = pol2cart(plotbins*pi/180,nanmean(mat1_plot2));
%                 else
%                     [xc, yc] = pol2cart(plotbins*pi/180,mat1_plot2);
%                 end
%                 for j=1:length(xc)
%                     h=plot(xc(j), yc(j));
%                     graphcond=figcolor1(k);
%                     set (h(end), 'Marker', marker1{graphcond}, 'MarkerFaceColor', color1(graphcond,:), 'MarkerEdgeColor', color1(graphcond,:), ...
%                         'MarkerSize', 6)
%                 end
%             end
%
%             % Plot error bar for the marker
%             if (fig1==1 && k==1)
%                 yInt=mj2(:,1,k);
%                 [xc1, yc1] = pol2cart(0*pi/180,yInt);
%                 yInt=mj1(:,1,k);
%                 [xc2, yc2] = pol2cart(0*pi/180,yInt);
%                 h=plot([xc1,xc2],[yc1,yc2]);
%                 graphcond=figcolor1(k);
%                 set (h(end), 'LineWidth', wlineerror, 'Color', color1(graphcond,:))
%             end
%         end
%
%         % Add tick marks
%         ticks1=[tick_large_temp,tick_small_temp];
%         ticks1labels=[tick_large_temp+minaxis1, tick_small_temp+minaxis1]; % Plots real values
%         for i=1:length(ticks1)
%             [x,y] = pol2cart(plotang*pi/180,ticks1(i));
%             if ticks1labels(i)~=max(ticks1labels)
%                 text(x,y, num2str(ticks1labels(i)), 'FontSize', fontsz, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
%             else
%                 text(x,y, ['SRT ', num2str(ticks1labels(i)), ' ms'], 'FontSize', fontsz, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
%             end
%         end
%
%         % FIGURE SETUP
%         set (gca,'FontSize', fontsz);
%         set (gca,'Visible', 'off');
%
%         % Figure title
%         title (title1, 'FontSize', fontszlabel)
%
%         %============
%         % Export the figure & save it
%
%         settings.subject_path = [settings.figures_directory, sprintf('%s/%s/', settings.figure_folder_name, sN1) ];
%         if isdir (settings.subject_path)
%             cd (settings.subject_path)
%         else
%             mkdir (settings.subject_path)
%         end
%
%         if fig_legend1==1
%             fileName=[settings.subject_path, save_name, '_no_legend'];
%         elseif fig_legend1==2
%             fileName=[settings.subject_path, save_name];
%         end
%         set(gcf, 'PaperPositionMode', 'manual');
%         set(gcf, 'PaperUnits', 'inches');
%         set(gcf, 'PaperPosition', settings.figsize)
%         set(gcf, 'PaperSize', [settings.figsize(3),settings.figsize(4)]);
%         print (fileName, '-dpdf')
%         close all;
%         %===============
%         %
%         %     %==================
%         %     %==================
%         %     %=================
%         %     % Bootstrap statistics
%         %
%         %     if max(S.subjectNo)>1 && runstatistics==1 && error1==1 && (fig1==1 || fig1==2) && bilateral1==1;
%         %
%         %         fprintf(fout, '\n \n');
%         %         targettext='Bootstrap stats comparing two conditions of interest \n \n';
%         %         fprintf(fout, targettext);
%         %
%         %         if fig1==1
%         %             num_of_comparisons=3;
%         %         elseif fig1==2
%         %             num_of_comparisons=1;
%         %         end
%         %
%         %         % Test 1
%         %         for j=1:num_of_comparisons;
%         %             if j==1 && fig1==1
%         %                 fprintf(fout, '\n');
%         %                 targettext='Look vs avoid \n';
%         %                 fprintf(fout, targettext);
%         %                 diff1=b1(:,1:12)-b1(:,13:24);
%         %             elseif j==2 && fig1==1
%         %                 fprintf(fout, '\n');
%         %                 targettext='Look vs control \n';
%         %                 fprintf(fout, targettext);
%         %                 diff1=b1(:,1:12)-b1(:,25:36);
%         %             elseif j==3 && fig1==1
%         %                 fprintf(fout, '\n');
%         %                 targettext='Avoid vs control \n';
%         %                 fprintf(fout, targettext);
%         %                 diff1=b1(:,13:24)-b1(:,25:36);
%         %             elseif j==1 && fig1==2
%         %                 fprintf(fout, '\n');
%         %                 targettext='Alerting task vs control task \n';
%         %                 fprintf(fout, targettext);
%         %                 diff1=b1(:,1:12)-b1(:,13:24);
%         %             end
%         %
%         %             % Find p-values
%         %             pval=NaN(1,size(diff1,2));
%         %             for i=1:length(pval)
%         %                 if mean (diff1(:,i))>0 & sum(diff1(:,i)>0)>0
%         %                     pval(i) = (sum(diff1(:,i)<0)/tboot1);
%         %                 elseif mean (diff1(:,i))>0 & sum(diff1(:,i)>0)==0
%         %                     pval(i) = (1/tboot1);
%         %                 elseif mean (diff1(:,i))<0 & sum(diff1(:,i)>0)>0
%         %                     pval(i) = (sum(diff1(:,i)>0)/tboot1);
%         %                 elseif mean (diff1(:,i))<0 & sum(diff1(:,i)>0)==0
%         %                     pval(i) = (1/tboot1);
%         %                 end
%         %             end
%         %
%         %             % Make a two sided t-test
%         %             pval=pval*2;
%         %
%         %             targettext='Bootstrapped mean difference 2 \n';
%         %             fprintf(fout, targettext);
%         %             for i=1:size(diff1,2)
%         %                 targettext='%.2f ;';
%         %                 fprintf(fout, targettext, nanmean(diff1(:,i)));
%         %             end
%         %             fprintf(fout, '\n');
%         %             nanmean(diff1)
%         %
%         %             targettext='Bootstrapped  SD of the difference 2 \n';
%         %             fprintf(fout, targettext);
%         %             for i=1:size(diff1,2)
%         %                 targettext='%.2f ;';
%         %                 fprintf(fout, targettext, std(diff1(:,i)));
%         %             end
%         %             fprintf(fout, '\n');
%         %             nanmean(diff1)
%         %
%         %             targettext='Bootstrapped statistics 2 \n';
%         %             fprintf(fout, targettext);
%         %             for i=1:size(pval,2)
%         %                 targettext='%.4f ;';
%         %                 fprintf(fout, targettext, pval(i));
%         %             end
%         %             fprintf(fout, '\n');
%         %
%         %         end
%         %     end
%         %     %==================
%         %
%     end
% end
%
% % %% STATISTICS
% %
% % %================
% % % Latencies
% %
% %
% % if max(S.subjectNo)>1 && runstatistics==1
% %
% %     S.expcond2=NaN(size(S.data,1),1);
% %
% %     index=S.maincond==1 & S.trialaccepted==-1 & S.responsecond==2; % Look trials (2 targest)
% %     S.expcond2(index)=1;
% %     index=S.maincond==1 & S.trialaccepted==-1 & S.objposrel==0 & S.responsecond==1; % Look trials probe
% %     S.expcond2(index)=2;
% %     index=S.maincond==1 & S.trialaccepted==-1 & S.objposrel~=0 & S.responsecond==1; % Look trials probe non-cued
% %     S.expcond2(index)=3;
% %     index=S.maincond==2 & S.trialaccepted==-1 & S.responsecond==2; % Avoid trials (2 targest)
% %     S.expcond2(index)=4;
% %     index=S.maincond==2 & S.trialaccepted==-1 & S.objposrel==0 & S.responsecond==1; % Avopid trials (catch)
% %     S.expcond2(index)=5;
% %     index=S.maincond==2 & S.trialaccepted==-1 & S.objposrel~=0 & S.responsecond==1; % Avoid trials (catch)
% %     S.expcond2(index)=6;
% %     index=S.maincond==3 & S.trialaccepted==-1 & S.objposrel==0 & S.responsecond==1; % Alerting
% %     S.expcond2(index)=7;
% %     index=S.maincond==3 & S.trialaccepted==-1 & S.objposrel~=0 & S.responsecond==1; % Alerting
% %     S.expcond2(index)=8;
% %     index=S.maincond==4 & S.trialaccepted==-1 & S.objposrel==0 & S.responsecond==1; % Control
% %     S.expcond2(index)=9;
% %     index=S.maincond==4 & S.trialaccepted==-1 & S.objposrel~=0 & S.responsecond==1; % Control
% %     S.expcond2(index)=10;
% %
% %
% %     % SRT
% %     lat1=NaN(max(S.subjectNo), max(S.expcond2),1);
% %     for i=1:max(S.expcond2);
% %         for f=1:max(S.subjectNo)
% %             index1=S.expcond2==i & S.subjectNo==f;
% %             if sum(index1)>Threshold
% %                 lat1(f,i)=nanmedian(S.sacconset(index1),1);
% %             end
% %         end
% %     end
% %
% %     %==
% %     fprintf(fout, '\n');
% %     targettext='Latency in the look main task: %.0f +- %.0f ms';
% %     fprintf(fout, targettext, round(nanmean(lat1(:,1))), round(se(lat1(:,1))));
% %     fprintf(fout, '\n');
% %     targettext='Latency to cue location in the look probe task: %.0f +- %.0f ms';
% %     fprintf(fout, targettext, round(nanmean(lat1(:,2))), round(se(lat1(:,2))));
% %     fprintf(fout, '\n');
% %
% %     [a_stat,b_stat,c_stat,d_stat]=ttest(lat1(:,1),lat1(:,2));
% %     targettext='Statistics: t(%d)=%.2f, p=%.4f \n';
% %     fprintf(fout, targettext, d_stat.df, d_stat.tstat, b_stat);
% %     fprintf(fout, '\n');
% %
% %     %==
% %     fprintf(fout, '\n');
% %     targettext='Latency in the avoid main task: %.0f +- %.0f ms';
% %     fprintf(fout, targettext, round(nanmean(lat1(:,4))), round(se(lat1(:,4))));
% %     fprintf(fout, '\n');
% %     targettext='Latency to cue location in the avoid probe task: %.0f +- %.0f ms';
% %     fprintf(fout, targettext, round(nanmean(lat1(:,5))), round(se(lat1(:,5))));
% %     fprintf(fout, '\n');
% %
% %     [a_stat,b_stat,c_stat,d_stat]=ttest(lat1(:,4),lat1(:,5));
% %     targettext='Statistics: t(%d)=%.2f, p=%.4f \n';
% %     fprintf(fout, targettext, d_stat.df, d_stat.tstat, b_stat);
% %     fprintf(fout, '\n');
% %
% %     %==
% %     [a_stat,b_stat,c_stat,d_stat]=ttest(lat1(:,2),lat1(:,5));
% %     targettext='Cued location: look vs avoid probe task: t(%d)=%.2f, p=%.4f \n';
% %     fprintf(fout, targettext, d_stat.df, d_stat.tstat, b_stat);
% %     fprintf(fout, '\n');
% %
% %     %==
% %     fprintf(fout, '\n');
% %     targettext='Latency to the cue in the control task: %.0f +- %.0f ms';
% %     fprintf(fout, targettext, round(nanmean(lat1(:,9))), round(se(lat1(:,9))));
% %     fprintf(fout, '\n');
% %     targettext='Latency away from the cue in the control task: %.0f +- %.0f ms';
% %     fprintf(fout, targettext, round(nanmean(lat1(:,10))), round(se(lat1(:,10))));
% %     fprintf(fout, '\n');
% %
% %     [a_stat,b_stat,c_stat,d_stat]=ttest(lat1(:,9),lat1(:,10));
% %     targettext='Statistics: t(%d)=%.2f, p=%.4f \n';
% %     fprintf(fout, targettext, d_stat.df, d_stat.tstat, b_stat);
% %     fprintf(fout, '\n');
% %
% %     %==
% %     [a_stat,b_stat,c_stat,d_stat]=ttest(lat1(:,2),lat1(:,9));
% %     targettext='Cued location: look probe vs control: t(%d)=%.2f, p=%.4f \n';
% %     fprintf(fout, targettext, d_stat.df, d_stat.tstat, b_stat);
% %     fprintf(fout, '\n');
% %
% %     %==
% %     [a_stat,b_stat,c_stat,d_stat]=ttest(lat1(:,5),lat1(:,9));
% %     targettext='Cued location: avoid probe vs control: t(%d)=%.2f, p=%.4f \n';
% %     fprintf(fout, targettext, d_stat.df, d_stat.tstat, b_stat);
% %     fprintf(fout, '\n');
% %
% %     fprintf(fout, '\n');
% %     targettext='Latency in the look main task: %.0f +- %.0f ms';
% %     fprintf(fout, targettext, round(nanmean(lat1(:,1))), round(se(lat1(:,1))));
% %     fprintf(fout, '\n');
% %     fprintf(fout, '\n');
% %     targettext='Latency in the avoid main task: %.0f +- %.0f ms';
% %     fprintf(fout, targettext, round(nanmean(lat1(:,4))), round(se(lat1(:,4))));
% %     fprintf(fout, '\n');
% %
% %     %==
% %     [a_stat,b_stat,c_stat,d_stat]=ttest(lat1(:,1),lat1(:,4));
% %     targettext='Main task comparisons: look cued vs avoid non-cued: t(%d)=%.2f, p=%.4f \n';
% %     fprintf(fout, targettext, d_stat.df, d_stat.tstat, b_stat);
% %     fprintf(fout, '\n');
% %
% %
% % end
% %
% %
% % %% =================
% %
% % % Add ANOVA
% %
% % if max(S.subjectNo)>1 && runstatistics==1 && bilateral1==1
% %
% %     if bilateral1==1
% %         m1=[1,4,7,10]; % Those columns contain data in bbb (0, 90, 180 and 270 degrees)
% %         n1 = [2,3,5,6,7,8,9,11,12];
% %     elseif bilateral1==2
% %         m1=[1,4,7]; % Those columns contain data in bbb (0, 90, 180 and 270 degrees)
% %     end
% %
% %     for rep1=1:3
% %
% %         if rep1==1
% %             fprintf(fout, '\n \n');
% %             targettext='ANOVA for look vs avoid task \n';
% %             fprintf(fout, targettext);
% %             anovatable1=[];
% %             anovatable1(:,:,1)=mat1(:,m1,1);
% %             anovatable1(:,:,2)=mat1(:,m1,2);
% %         elseif rep1==2
% %             fprintf(fout, '\n \n');
% %             targettext='ANOVA for look vs control task \n';
% %             fprintf(fout, targettext);
% %             anovatable1=[];
% %             anovatable1(:,:,1)=mat1(:,m1,1);
% %             anovatable1(:,:,2)=mat1(:,m1,4);
% %         elseif rep1==3
% %             fprintf(fout, '\n \n');
% %             targettext='ANOVA for avoid vs control task \n';
% %             fprintf(fout, targettext);
% %             anovatable1=[];
% %             anovatable1(:,:,1)=mat1(:,m1,2);
% %             anovatable1(:,:,2)=mat1(:,m1,4);
% %         end
% %
% %         subjectfactor=anovatable1;
% %         for i=1:size(subjectfactor,1)
% %             subjectfactor(i,:,:)=i;
% %         end
% %
% %         factor1=anovatable1;
% %         for i=1:size(factor1,2)
% %             factor1(:,i,:)=i;
% %         end
% %
% %         factor2=anovatable1;
% %         for i=1:size(factor1,3)
% %             factor2(:,:,i)=i;
% %         end
% %
% %         a1=reshape(anovatable1,[],1);
% %         s1=reshape(subjectfactor,[],1);
% %         f1=reshape(factor1,[],1);
% %         f2=reshape(factor2,[],1);
% %         factnames{1}={'Position'};
% %         factnames{2}={'Condition'};
% %
% %         stats=rm_anova2(a1,s1,f1,f2,factnames);
% %
% %         % Write the results into a text file
% %         for i=1:3
% %             if i==1
% %                 var_name1='Main effect: Position';
% %             elseif i==2
% %                 var_name1='Main effect: Condition';
% %             elseif i==3
% %                 var_name1='Interaction: Position * Condition';
% %             end
% %             targettext='%s F(%d,%d)=%.2f, p=%.4f \n';
% %             fprintf(fout, targettext, var_name1, cell2mat(stats(i+1,3)), cell2mat(stats(i+4,3)), cell2mat(stats(i+1,5)), cell2mat(stats(i+1,6)));
% %         end
% %
% %     end
% %
% %     %===================
% %     % Individual condition (effect of stimulus position)
% %
% %     fprintf(fout, '\n \n');
% %     targettext='ANOVA for look probe task main effect of position \n';
% %     fprintf(fout, targettext);
% %     ddd=mat1(:,m1,1);
% %     [a,stats]=anova_rm(ddd(:,:,:));
% %     targettext='%s F(%d,%d)=%.2f, p=%.4f \n';
% %     fprintf(fout, targettext, 'Main effect', cell2mat(stats(2,3)), cell2mat(stats(3,3)), cell2mat(stats(2,5)), cell2mat(stats(2,6)));
% %
% %     fprintf(fout, '\n \n');
% %     targettext='ANOVA for avoid probe task main effect of position \n';
% %     fprintf(fout, targettext);
% %     ddd=mat1(:,m1,2);
% %     [a,stats]=anova_rm(ddd(:,:,:));
% %     targettext='%s F(%d,%d)=%.2f, p=%.4f \n';
% %     fprintf(fout, targettext, 'Main effect', cell2mat(stats(2,3)), cell2mat(stats(3,3)), cell2mat(stats(2,5)), cell2mat(stats(2,6)));
% %
% %     fprintf(fout, '\n \n');
% %     targettext='ANOVA for control task main effect of position \n';
% %     fprintf(fout, targettext);
% %     ddd=mat1(:,m1,4);
% %     [a,stats]=anova_rm(ddd(:,:,:));
% %     targettext='%s F(%d,%d)=%.2f, p=%.4f \n';
% %     fprintf(fout, targettext, 'Main effect', cell2mat(stats(2,3)), cell2mat(stats(3,3)), cell2mat(stats(2,5)), cell2mat(stats(2,6)));
% %
% %     fprintf(fout, '\n \n');
% %     targettext='ANOVA for avoid main task, effect of distractor position relative to the cue\n';
% %     fprintf(fout, targettext);
% %     ddd=mat1(:,n1,6);
% %     [a,stats]=anova_rm(ddd(:,:,:));
% %     targettext='%s F(%d,%d)=%.2f, p=%.4f \n';
% %     fprintf(fout, targettext, 'Main effect', cell2mat(stats(2,3)), cell2mat(stats(3,3)), cell2mat(stats(2,5)), cell2mat(stats(2,6)));
% %
% % end
% %
% % close all;