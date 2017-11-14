% Plot saccade directions for different conditions, raw data for
% verification purposes
% Latest revision - October 10, 2016
% Donatas Jonikaitis

close all;


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
    sN1 = 'all'; % Subject name
end

% Overwriting analysis defaults
if ~isfield(settings, 'overwrite')
    settings.overwrite = 1;
end

% Run settings file:
eval(sprintf('%s_settings', settings.exp_name)); % Load general settings


%% Some settings

settings.figure_folder_name = 'saccades_verify';
settings.stats_file_name = sprintf('statistics_%s_', settings.figure_folder_name);


%% Run preprocessing

for i=1:length(settings.subjects)
    
    settings.subject_name=settings.subjects{i}; % Select curent subject
    
    % Initialize subject specific folders where data is stored
    for i=1:length(settings.path_spec_names)
        v1 = ['path_', settings.path_spec_names{i}];
        settings.(v1) = sprintf ('%s%s/', settings.path_spec_folder{i}, settings.subject_name);
    end
    
    % Get index of every folder for a given subject
    session_init = get_path_dates_v20(settings.path_data_combined, settings.subject_name);
    
    % Which date to analyse (all days or a single day)
    if settings.preprocessing_sessions_used==1
        ind = [1:length(session_init.index_unique_dates)];
    elseif settings.preprocessing_sessions_used==2
        ind = find(session_init.index_unique_dates==settings.preprocessing_day_id);
    elseif settings.preprocessing_sessions_used==3
        ind = length(session_init.index_unique_dates);
    end
    date_index = session_init.index_unique_dates(ind);
    
    
    for i_date = 1:length(date_index)
        
        
        folder_name = [settings.subject_name, num2str(date_index(i_date))];
        
        % Path to subject specific figures folder
        path1_fig = sprintf('%s%s/%s/%s/', settings.path_figures, settings.figure_folder_name, settings.subject_name, folder_name);
        if ~isdir(path1_fig)
            mkdir(path1_fig)
        elseif isdir(path1_fig)
            rmdir(path1_fig, 's')
            mkdir(path1_fig)
        end
        
        % Initialize text file for statistics
        nameOut = sprintf('%s%s.txt', path1_fig, settings.stats_file_name); % File to be outputed
        fclose('all');
        fout = fopen(nameOut,'w');
        
        
        %============
        % Load data
        
        path1 = [settings.path_data_combined, folder_name, '/', folder_name, '.mat']; % File with settings
        path2 = [settings.path_data_combined, folder_name, '/', folder_name, '_eye_traces.mat']; % File with raw data
        path3 = [settings.path_data_combined, folder_name, '/', folder_name, '_saccades.mat']; % File with saccades
        
        
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
        % Load detected saccades
        var3 = struct; varx = load(path3);
        f1 = fieldnames(varx);
        if length(f1)==1
            var3 = varx.(f1{1});
        end
        
        % Copy raw data
        saccraw1 = var2.eye_processed;
        sacc1 = var1.saccades_EK;
        S = var1;
        
        % Save saccade date into matrix S for simplicity
        S.sacmatrix = var3.sacmatrix;
        S.trial_accepted = var3.trial_accepted;        
      
        
    
        %% Plot
                    
        for fig1 = 1 % Plot figures
            
            %==============
            % Setup exp condition
            S.expcond=NaN(size(S.trial_accepted));
            
            % Figure one plots saccades to different locations
            if fig1==1
                
                % Select conditions
                m1 = unique([S.em_t1_coord1, S.em_t1_coord2], 'rows');
                for i=1:size(m1,1)
                    index = S.em_t1_coord1==m1(i,1) & S.em_t1_coord2==m1(i,2);
                    S.expcond(index)=i;
                end
                
                % Save memory positions for legend
                [theta,rho] = cart2pol(m1(:,1),m1(:,2));
                theta = (theta/pi)*180;
                legend1_values = theta;
                
            end
            
            %=================
            % Plot figure
            
            if fig1==1
                
                fig_legend=2; % Legend is on;
                
                for rep1 = 1:max(S.expcond)
                    
                    hfig=figure;
                    hold on;
                    
                    save_name = sprintf('fig %d loc %d', fig1, rep1);
                    fig_title = 'Memory delay saccades';
                    
                    %==================
                    % Plot memory target locations
                    
                    for k1 = 1:length(theta)
                        
                        % Coordinates
                        f_arc = theta(k1);
                        f_rad = rho(k1);
                        [xc,yc] = pol2cart(f_arc*pi/180, f_rad);
                        pos1=[xc,yc];
                        
                        % Shape
                        v1 = 1;
                        % Size
                        a = cell2mat(S.response_size);
                        m1 = unique(a, 'rows');
                        if size(m1,1)==1
                            objsize = m1(1,3:4);
                        else
                            objsize = m1(1,3:4);
                        end
                        % Color
                        fcolor1 = [0.2, 0.2, 0.2];
                        
                        % Plot
                        if k1==rep1
                            h=rectangle('Position', [pos1(1)-objsize(1)/2, pos1(2)-objsize(2)/2, objsize(1), objsize(2)],...
                                'EdgeColor', fcolor1, 'FaceColor', fcolor1, 'Curvature', v1, 'LineWidth', 1);
                        elseif k1~=rep1
                            h=rectangle('Position', [pos1(1)-objsize(1)/2, pos1(2)-objsize(2)/2, objsize(1), objsize(2)],...
                                'EdgeColor', fcolor1, 'FaceColor', 'none', 'Curvature', v1, 'LineWidth', 1);
                        end
                        
                    end
                    % End of memory target plotting
                    
                    
                    %======================
                    % Plot all saccades from all trials
                    for tid=1:size(sacc1,1)
                        if S.expcond(tid)==rep1 && ~isnan(S.memory_on(tid))
                            
                            sx1 = saccraw1{tid}; % Raw eye-traces
                            sx2 = sacc1{tid}; % Saccades data
                            
                            if ~isnan(S.targets_on(tid))
                                fcolor1 = [0.5, 0.5, 0.5];
                            elseif isnan(S.targets_on(tid))
                                fcolor1 = [0.3, 0.3, 0.8];
                            end
                                                        
                            % Plot every single saccade detected during
                            % memory delay
                            t1 = S.memory_on(tid); % Relative to first display
                            t2 = S.fixation_off(tid); % Delay is officially over, regardless whether it is correct or error trial
                            if size(sx2,2)>1
                                for i=1:size(sx2,1)
                                    if sx2(i,1)>t1 && sx2(i,1)<=t2
                                        index1=sx1(:,1)>=sx2(i,1) & sx1(:,1)<=sx2(i,2);
                                        x1=sx1(index1,2); y1=sx1(index1,3); % Convert to eye position in space
                                        h=plot(x1, y1, 'Color', fcolor1,  'LineWidth', 0.5);
                                    end
                                end
                            end
                            % Every saccade was plotted
                            
                        end
                    end
                    % End of plotting each trial in one figure
                    
                    
                    %==================
                    % Figure settings
                    axis equal
                    set(gca,'FontSize', settings.fontsz);
                    set(gca,'XLim',[-12,12]);
                    set(gca,'YLim',[-12,12]);
                    set(gca,'YTick',[-round(abs(xc),1), 0, round(abs(xc),1)]);
                    set(gca,'XTick',[-round(abs(yc),1), 0, round(abs(yc),1)]);
                    xlabel ('degrees v.a.', 'FontSize', settings.fontszlabel)
                    ylabel ('degrees v.a.', 'FontSize', settings.fontszlabel)
                    title (fig_title, 'FontSize', settings.fontszlabel)
                    
                    % Save figure
                    f_name = sprintf('%s%s', path1_fig, save_name);
                    set(gcf, 'PaperPositionMode', 'manual');
                    set(gcf, 'PaperUnits', 'inches');
                    set(gcf, 'PaperPosition', settings.figsize)
                    set(gcf, 'PaperSize', [settings.figsize(3),settings.figsize(4)]);
                    print (f_name, '-dpdf')
                    %===============
                    
                    close all;
                end
                % End of exp cond for fig1
            end
            % End of fig1
            

            
            
        end
        % End of fig1 loop (as many figures as there are)
        
        
    end
    % End of analysis for each day
    
end
% End of analysis for each subject

