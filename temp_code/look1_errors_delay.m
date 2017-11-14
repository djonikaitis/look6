% Plot line graph of performance at different locations

clear all;
close all;
clc;

% Loading the files needed
disp(' ')
experiment_name='look1';
sN1{1}='all';
% sN1{1}=input('Subjects name  ', 's');

% All subjects used in the task
sNall{1}='pm';

if strcmp(sN1, 'all')
    subjectName_temp=sNall;
else
    subjectName_temp=sN1;
end

% Load the settings
settings_look1;

% Error bars
error1=2; % 1-bootstrapped error, 2-SEM
tboot1=10000; % How many times to bootstrap
eb1=2; % 1-lines as error bars, 2-shaded area as error bars

Threshold=5; % Min number of trials acceptable

% Figure parameters
figsize1=[0, 0, 2, 1.8];
markeron1=0;

% Delay durations used for evaluations
intervalbins = linspace(0, 1400, 14);


%% Determine how many days and files are recorded

for rep1=1:length(subjectName_temp);
    
    % Change directory to data folder
    cdDir=(sprintf('%s',cdDir_data));
    cd(cdDir);
    index_directory = dir;
    subject_name = subjectName_temp{rep1};
    
    %==================
    % Determine how many unique days are there & and which session numbers were
    % recorded on which day (this compensates for sessions skips)
    index_dates = NaN(1,length(index_directory));
    index_sessions = NaN(1,length(index_directory));
    for i=1:length(index_directory)
        if length (index_directory(i).name) == length(subject_name)+6
            a1 = index_directory(i).name(length(subject_name)+1:length(subject_name)+6);
            if length(str2num(a1))==1
                index_dates(i) = str2num(a1);
            end
        end
        index_unique_days = unique(index_dates);
        ind=isnan(index_unique_days); index_unique_days(ind)=[];
    end
    %==================
    
    % Run analysis for each unique session
    for current_day = 1:length(index_unique_days); % For each recorded day
        
        %===================
        % Which folder number to load
        ind1 = index_dates == index_unique_days(current_day);
        
        % Change directory to individual eyelink folder
        current_dirname = index_directory(ind1).name; % Whats current directory name
        cdDir=(sprintf('%s%s', cdDir_data, current_dirname));
        cd(cdDir);
        current_filename = sprintf('%s_%s.mat',experiment_name, current_dirname); % Check whether data file exists
        load (eval('current_filename'));
    
        %==================

        % ExpCondition
        S.expcond=NaN(size(S.data,1),1);

        % Look & Avoid
        index=S.maincond==1 & S.target_number==2;
        S.expcond(index)=1;
        index=S.maincond==2 & S.target_number==2;
        S.expcond(index)=2;
        
        numcond=2;
        
        % Errors to be analysed
        error_tab = [-1, -2, 5];
        
        %===============
        % Select data
        
        mat1 = NaN(length(error_tab), length(intervalbins)-1, numcond);
        plot_bins = [];
        
        for i = 1:length(error_tab)
            for j=1:length(intervalbins)-1
                for k=1:size(mat1,3)
                    
                    % Index
                    index1 = S.delay_duration_exp>=intervalbins(j) & S.delay_duration_exp<intervalbins(j+1) & ...
                        S.expcond==k & S.trialaccepted==error_tab(i);
                    
                    % Record data
                    if sum(index1)>1
                        mat1(i,j,k)= sum(index1);
                    end
                    
                end
                plot_bins(j)=(intervalbins(j)+intervalbins(j+1))./2;
            end
        end
        
        
        %================
        % Plot data
        
        for fig1=[1:2]
            
            % Select data
            mat1_plot=[];
            if fig1==1 % Look
                mat1_plot(:,:,1)=mat1(:,:,1);
                % Convert data to %
                for j=1:size(mat1_plot,2)
                    mat1_plot(:,j,1) = (mat1_plot(:,j,1)./nansum(mat1_plot(:,j,1)))*100;
                end
                figcolor1=[1,2,3];
            elseif fig1==2
                mat1_plot(:,:,1)=mat1(:,:,2);
                % Convert data to %
                for j=1:size(mat1_plot,2)
                    mat1_plot(:,j,1) = (mat1_plot(:,j,1)./nansum(mat1_plot(:,j,1)))*100;
                end
                figcolor1=[1,2,3];
            end
            
            % Initialize figure
            hfig=figure;
            hold on;
            
            %================
            % Plot legend markers
            
                
            if fig1==1
                x0_data = [100, 100, 100]; x1_data = [120, 120, 120]; 
                x1_text = [140, 140, 140];  
                y1 = [125, 113, 101];
            end
            for k=1:length(x1_data)
                h=plot([x0_data(k),x1_data(k)], [y1(k), y1(k)]);
                graphcond=figcolor1(k);
                set (h(end), 'LineWidth', wlinegraph, 'Color', color1(graphcond,:))
                if markeron1==1
                    set (h(end), 'Marker', marker1{graphcond}, 'MarkerFaceColor', facecolor1(graphcond,:), ...
                        'MarkerEdgeColor', color1(graphcond,:), 'MarkerSize', msize)
                end
                if k==1
                    text(x1_text(k), y1(k), 'Correct', 'Color', color1(graphcond,:),  'FontSize', fontszlabel, 'HorizontalAlignment', 'left')
                elseif k==2
                    text(x1_text(k), y1(k), 'Wrong target', 'Color', color1(graphcond,:),  'FontSize', fontszlabel, 'HorizontalAlignment', 'left')
                elseif k==3
                    text(x1_text(k), y1(k), 'Looked at memory', 'Color', color1(graphcond,:),  'FontSize', fontszlabel, 'HorizontalAlignment', 'left')
                end
            end
            
            % Plot lines
            for k=1:size(mat1_plot,1)
                
                % Plot data
                if max(S.subject_number)>1
                    h=plot(plot_bins, nanmean(mat1_plot(k,:,:)));
                else
                    h=plot(plot_bins, mat1_plot(k,:,:));
                end
                graphcond=figcolor1(k);
                set (h(end), 'LineWidth', wlinegraph, 'Color', color1(graphcond,:))
                if markeron1==1
                    set (h(end), 'Marker', marker1{graphcond}, 'MarkerFaceColor', facecolor1(graphcond,:), ...
                        'MarkerEdgeColor', color1(graphcond,:), 'MarkerSize', msize)
                end
                
            end
            
            %==============
            % Figure settings
            
            set (gca,'FontSize', fontsz);
            if fig1==1
                set(gca,'YTick', 25:25:75);
                set(gca,'YLim',[-10 140]);
                set(gca,'XTick', [200:300:800]);
                set(gca,'XLim',[plot_bins(1)-45 plot_bins(end)+45]);
            end
            xlabel ('Memory delay (ms)', 'FontSize', fontszlabel);
            ylabel ('Frequency (%)', 'FontSize', fontszlabel);
            
            % Figure title
            if fig1==1
                title (['Look, day ', num2str(current_day)], 'FontSize', fontszlabel)
            elseif fig1==2
                title (['Avoid, day ', num2str(current_day)], 'FontSize', fontszlabel)
            end
            
            %============
            % Export the figure & save it
            
            rundirexp=[cdDir_fig,'errors_delay/', subject_name, '/'];
            try
                cd(rundirexp)
            catch
                mkdir(rundirexp)
            end
            if fig1==1
                fileName=[rundirexp, 'look_', num2str(current_day)];
            elseif fig1==2
                fileName=[rundirexp, 'avoid_', num2str(current_day)];
            end
            
            set(gcf, 'PaperPositionMode', 'manual');
            set(gcf, 'PaperUnits', 'inches');
            set(gcf, 'PaperPosition', figsize1)
            set(gcf, 'PaperSize', [figsize1(3),figsize1(4)]);
            print (fileName, '-dpdf')
            close all;
            
        end
        

    end
    
    
end

