% Plots spike rasters for different stimulus background colors

close all;
clear all;
settings.subjects = 'aq';
settings.exp_name = 'look6';

p1 = mfilename;
fprintf('\n=========\n')
fprintf('\n Current file:  %s\n', p1)
fprintf('\n=========\n')


%% Initial setup

% Loading the files needed
if ~exist('settings', 'var')
    settings = struct;
end

% Experiment name
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

% Path to figures and statistics
settings.figure_folder_name = 'spikes_timecourse';
settings.stats_file_name = sprintf('statistics_%s_', settings.figure_folder_name);


%% Run analysis

for i_subj=1:length(settings.subjects)
    
    settings.subject_current=settings.subjects{i_subj}; % Select curent subject
    
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
    path1 = settings.path_data_combined_plexon_subject;
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
    
    
    for i_date = 1:length(date_used)
        
        date_current = date_used(i_date);
        
        % Current folder to be analysed (raw date, with session index)
        ind = date_current==settings.index_dates;
        folder_name = settings.index_directory{ind};
        
        % Path to subject specific figures folder
        path1_fig = sprintf('%s%s/%s/%s/', settings.path_figures, settings.figure_folder_name, settings.subject_current, folder_name);
        
        % Now decide whether to over-write analysis
        if  ~isdir(path1_fig) || settings.overwrite==1
            
            % Remove old path
            if ~isdir(path1_fig)
                mkdir(path1_fig)
            elseif isdir(path1_fig)
                rmdir(path1_fig, 's')
                mkdir(path1_fig)
            end
            
            % Load combined data
            path1 = sprintf('%s%s/', settings.path_data_combined_subject, folder_name);
            file_name = [folder_name];
            varx = load(sprintf('%s%s', path1, file_name));
            f1 = fieldnames(varx);
            S = struct; % Initialize empty var
            if length(f1)==1
                S = varx.(f1{1});
            end
            
%             % Load saccades data
%             path1 = sprintf('%s%s/', settings.path_data_combined_subject, folder_name);
%             file_name = [folder_name, '_saccades'];
%             varx = load(sprintf('%s%s', path1, file_name));
%             f1 = fieldnames(varx);
%             var1 = struct; % Initialize empty var
%             if length(f1)==1
%                 var1 = varx.(f1{1});
%             end
%             % Copy saccades data into structure S
%             f1 = fieldnames(var1);
%             for i = 1:length(f1)
%                 S.(f1{i}) = var1.(f1{i});
%             end
            
            
            %=============
            % Determine neurons that exist on a given day
            % For each neuron
            path1 = sprintf('%s%s/', settings.path_data_spikes, folder_name);
            spikes_init = get_path_spikes_v10 (path1, settings.subject_current); % Path to each neuron
            
            
            % Run analysis for each unit
            for i_unit = 1:length(spikes_init.index_path)
                
                
                %=================
                % Load spikes data
                path1 = spikes_init.index_path{i_unit};
                varx = load(path1);
                f1 = fieldnames(varx);
                spikes1 = struct;
                if length(f1)==1
                    spikes1 = varx.(f1{1});
                end
                
                % Save neuron name
                neuron_name = ['ch_', num2str(spikes_init.index_channel(i_unit)), '_u',  num2str(spikes_init.index_unit(i_unit))];
                
                % Initialize text file for statistics
                nameOut = sprintf('%s%/%s.txt', path1_fig, neuron_name, settings.stats_file_name); % File to be outputed
                fclose('all');
                fout = fopen(nameOut,'w');
                
                
                %% Figure calculations
                
                for fig1 = 1:6 % Plot figures
                    
                    
                    %==============
                    % Long and boring part of the code. Setup exp conditions
                    % you want to plot
                    %==============
                    
                    S.expcond = NaN(size(S.START));
                    
                    % Texture vs no texture condition, works as basic
                    % selection criterion for visual responsiveness of
                    % neurons
                    if fig1==1
                        
                        % Setup conditions
                        index = S.esetup_background_texture_on==1 & strcmp(S.edata_error_code, 'correct');
                        S.expcond(index)=1;
                        index = S.esetup_background_texture_on==0 & strcmp(S.edata_error_code, 'correct');
                        S.expcond(index)=2;
                        
                        % Indicate what is expected condition number
                        cond1 = 1:2;
                        legend1_values = cell(1);
                        legend1_values{1} = 'Texture';
                        legend1_values{2} = 'No texture';
                        
                        % Determine selected offset in the time (for example between first display and memory onset)
                        if isfield(S, 'texture_on')
                            S.tconst = S.fixation_on - S.first_display;
                        else
                            S.tconst = S.fixation_on - S.first_display;
                        end
                        
                        % Select appropriate interval for plottings
                        int_bins = settings.intervalbins_tex;
                        
                        new_mat = 1;
                        
                        % Plot data for look, avoid or control conditions
                        % (for each location separatelly)
                    elseif fig1==2 || fig1==3 || fig1==4 || fig1==5 || fig1==6 || fig1==7
                        
                        m1 = unique(S.esetup_memory_coord, 'rows');
                        [th,radiusdeg] = cart2pol(m1(:,1), m1(:,2));
                        theta = (th*180)/pi;
                        legend1_values = theta;
                        
                        % Look task
                        i1=0;
                        for i=1:size(m1,1)
                            index = S.esetup_memory_coord(:,1)==m1(i,1) & S.esetup_memory_coord(:,2)==m1(i,2) & S.esetup_block_cond==1 & S.esetup_background_texture_on==1 & strcmp(S.edata_error_code, 'correct');
                            S.expcond(index)=i+i1;
                        end
                        % Avoid task
                        i1=size(m1,1);
                        for i=1:size(m1,1)
                            index = S.esetup_memory_coord(:,1)==m1(i,1) & S.esetup_memory_coord(:,2)==m1(i,2) & S.esetup_block_cond==2 & S.esetup_background_texture_on==1  & strcmp(S.edata_error_code, 'correct');
                            S.expcond(index)=i+i1;
                        end
                        % Control task
                        i1=size(m1,1)*2;
                        for i=1:size(m1,1)
                            index = S.esetup_memory_coord(:,1)==m1(i,1) & S.esetup_memory_coord(:,2)==m1(i,2) & S.esetup_block_cond==5 & S.esetup_background_texture_on==1  & strcmp(S.edata_error_code, 'correct');
                            S.expcond(index)=i+i1;
                        end
                        % Look task, no texture
                        i1=size(m1,1)*3;
                        for i=1:size(m1,1)
                            index = S.esetup_memory_coord(:,1)==m1(i,1) & S.esetup_memory_coord(:,2)==m1(i,2) & S.esetup_block_cond==1 & S.esetup_background_texture_on==0  & strcmp(S.edata_error_code, 'correct');
                            S.expcond(index)=i+i1;
                        end
                        % Avoid task, no texture
                        i1=size(m1,1)*4;
                        for i=1:size(m1,1)
                            index = S.esetup_memory_coord(:,1)==m1(i,1) & S.esetup_memory_coord(:,2)==m1(i,2) & S.esetup_block_cond==2 & S.esetup_background_texture_on==0  & strcmp(S.edata_error_code, 'correct');
                            S.expcond(index)=i+i1;
                        end
                        % Control task, no texture
                        i1=size(m1,1)*5;
                        for i=1:size(m1,1)
                            index = S.esetup_memory_coord(:,1)==m1(i,1) & S.esetup_memory_coord(:,2)==m1(i,2) & S.esetup_block_cond==5 & S.esetup_background_texture_on==0  & strcmp(S.edata_error_code, 'correct');
                            S.expcond(index)=i+i1;
                        end
                        
                        % Indicate what is expected condition number
                        cond1 = 1:size(m1,1)*6;
                        fig_names = cell(1);
                        fig_names{1} = 'Look, texture';
                        fig_names{2} = 'Avoid, texture';
                        fig_names{3} = 'Control, texture';
                        fig_names{4} = 'Look, no texture';
                        fig_names{5} = 'Avoid, no texture';
                        fig_names{6} = 'Control, no texture';
                        
                        % Determine selected offset in the time (for example between first display and memory onset)
                        % S.first_display is the time plexon message was sent
                        if fig1==2 || fig1==3 || fig1==4 || fig1==5 || fig1==6 || fig1==7
                            S.tconst = S.memory_on - S.first_display;
                            int_bins = settings.intervalbins_mem;
                        end
                        
                        % Over-write spike rates?
                        if fig1==2
                            new_mat = 1;
                        elseif fig1>2
                            new_mat = 0;
                        end
                        
                        % Compare data to no-memory condtion
                    elseif fig1==8 || fig1==9 || fig1==10 || fig1==11
                        
                        % Find memory target arc
                        [th,radiusdeg] = cart2pol(S.em_target_coord1, S.em_target_coord2);
                        objposdeg = (th*180)/pi;
                        S.em_mem_arc = objposdeg;
                        S.em_mem_rad = radiusdeg;
                        
                        % Reset memory arc relative to RF center (assumes
                        % RF is in left lower visual field)
                        
                        % Find relative probe-memory position
                        a = unique(S.em_mem_arc); a = min(a);
                        S.rel_arc = S.em_mem_arc - a;
                        ind = S.rel_arc<-180;
                        S.rel_arc(ind)=S.rel_arc(ind)+360;
                        ind = S.rel_arc>=180;
                        S.rel_arc(ind)=S.rel_arc(ind)-360;
                        S.rel_arc = round(S.rel_arc, 1);
                        
                        % Find how many relative positions are recorded relative to memory
                        m1 = unique(S.rel_arc);
                        legend1_values = m1;
                        
                        % Look task
                        i1=0;
                        for i=1:size(m1,1)
                            index = S.rel_arc==m1(i) & S.em_blockcond==1 & S.em_background_texture_on==1  & S.trial_accepted==-1;
                            S.expcond(index)=i+i1;
                        end
                        % Avoid task
                        i1=size(m1,1);
                        for i=1:size(m1,1)
                            index = S.rel_arc==m1(i) & S.em_blockcond==2 & S.em_background_texture_on==1  & S.trial_accepted==-1;
                            S.expcond(index)=i+i1;
                        end
                        % Control task
                        i1=size(m1,1)*2;
                        for i=1:size(m1,1)
                            index = S.rel_arc==m1(i) & S.em_blockcond==5 & S.em_background_texture_on==1  & S.trial_accepted==-1;
                            S.expcond(index)=i+i1;
                        end
                        
                        % Indicate what is expected condition number
                        cond1 = 1:size(m1,1)*3;
                        fig_names = cell(1);
                        fig_names{1} = 'Look';
                        fig_names{2} = 'Avoid';
                        fig_names{3} = 'Control';
                        
                        % Determine selected offset in the time (for example between first display and memory onset)
                        % S.first_display is the time plexon message was sent
                        if fig1==5 || fig1==6
                            S.tconst = S.memory_on - S.first_display;
                            int_bins = settings.intervalbins_mem;
                        elseif fig1==7 || fig1==8
                            S.tconst = S.targets_on - S.first_display;
                            int_bins = settings.intervalbins_sacc;
                        end
                        
                        % Over-write spike rates?
                        if fig1==5 || fig1==7
                            new_mat = 1;
                        elseif fig1==6 || fig1==8
                            new_mat = 0;
                        end
                        
                    end
                    
                    
                    %===========
                    % Initialize spike timing
                    t1_spike = spikes1.ts;
                    
                    % Get timing of the events
                    t1 = spikes1.msg_1;
                    t1 = t1+S.tconst; % Reset to time relative to tconst
                    
                    
                    %============
                    % Find spikes
                    
                    if new_mat==1 % This decides whether to over_write the calculated data matrix
                        
                        %============
                        % Initialize empty matrix
                        xmat = NaN(size(S.expcond,1), length(int_bins), length(cond1));
                        test1 = NaN(1, length(cond1));
                        
                        % How many trials recorded for each condition?
                        for k=1:length(cond1)
                            index = S.expcond == cond1(k);
                            test1(k)=sum(index);
                        end
                        
                        %=============
                        % Calculate spiking rates
                        
                        for tid = 1:size(xmat,1)
                            for j = 1:length(int_bins)
                                for k=1:length(cond1)
                                    
                                    c1 = S.expcond(tid); % Which condition it is currently?
                                    
                                    % If particular conditon on a given trial
                                    % exists, then calculate firing rates
                                    if ~isnan(c1) && c1==k
                                        
                                        % Index
                                        index = t1_spike >= t1(tid) + int_bins(j) & ...
                                            t1_spike <= t1(tid) + int_bins(j) + settings.bin_length & ...
                                            S.expcond(tid) == cond1(k);
                                        
                                        % Save data
                                        if sum(index)==0
                                            xmat(tid,j,c1)=0; % Save as zero spikes
                                        elseif sum(index)>0
                                            xmat(tid,j,c1)=sum(index); % Save spikes counts
                                        end
                                    end
                                    
                                end
                            end
                        end
                        
                        % Convert to HZ
                        xmat = xmat*(1000/settings.bin_length);
                        % Initialize plot bins
                        pbins=int_bins+settings.bin_length/2;
                        
                    end
                    % End of checking whether new_mat==1
                    
                    
                    
                    %% Plot figure
                    
                    
                    fig_legend=1; % Legend is on;
                    
                    hfig=figure;
                    hold on;
                    
                    % Initialize data
                    %=================
                    mat1=[]; legend1={};
                    save_name=sprintf('fig_%d', fig1);
                    
                    % Do sopme more figure setup. Why?
                    if fig1==1
                        
                        % Average data relative to texture onset
                        mat1=xmat;

 %                                               %=
%                         % Normalize & divide
%                         v1=1:settings.baseline_bin_count;
%                         b1=[];
%                         for i=1:size(mat1,3)
%                             a = nanmean(mat1(:,v1,i),2);
%                             a = nanmean(a);
%                             b1(:,:,i) = repmat(a, size(mat1,1), size(mat1,2));
%                             b1(b1==0)=0.01;
%                         end
%                         mat1=mat1./b1;
%                         %=
                        
                        figcolor1=[23,21];
                        title1 = 'Responses to texture ';
                        
                        %===========
                        % Calculate the colors
                        color1_line = [];
                        color1_line = color1(figcolor1,:);
                        
                        % Color of the error bars
                        for i=1:size(color1_line,1)
                            d1 = 1-color1_line(i,:);
                            color1_error(i,:)=color1_line(i,:)+d1.*0.6;
                        end
                        
                        
                        
                        %                    elseif fig1==2
                        %
                        %                     % Cue locked, saccade target
                        %                     mat1=xmat;
                        %                     %===
                        %                     figcolor1=[21,22,23];
                        %                     if fig1==1
                        %                         title1 = 'Responses to fixation onset ';
                        %                     elseif fig1==2
                        %                         title1 = 'Responses to texture ';
                        %                     end
                        
                        %                     %===========
                        %                     % Calculate the colors
                        %
                        %                     color1_line=[];
                        %                     color1_line(1,:)=color1(figcolor1(1),:);
                        %
                        %                     % Orientation colors are calculated as a range
                        %                     col_min = color1(figcolor1(2),:); % Orientation 0
                        %                     col_max = color1(figcolor1(3),:); % Orientation max
                        %                     d1 = col_max-col_min;
                        %                     stepsz = 1/(length(legend1_values));
                        %                     for i=2:size(mat1,3)
                        %                         color1_line(i,:)=col_min + (d1*stepsz)*(i-1);
                        %                     end
                        %
                        %                     % Color of the error bars
                        %                     for i=1:size(color1_line,1)
                        %                         d1 = 1-color1_line(i,:);
                        %                         color1_error(i,:)=color1_line(i,:)+d1.*0.6;
                        %                     end
                        
                    elseif fig1==2 || fig1==3 || fig1==4 || fig1==5 || fig1==6 || fig1==7
                        
                        % Select data to plot
                        if fig1==2
                            mat1=xmat(:,:,1:length(legend1_values));
                            title1 = fig_names{1};
                            figcolor1=[1,10]; % Cued & uncued locations
                        elseif fig1==3
                            m = length(legend1_values);
                            mat1=xmat(:,:,m+1:m*2);
                            title1 = fig_names{2};
                            figcolor1=[2,10]; % Cued & uncued locations
                        elseif fig1==4
                            m = length(legend1_values);
                            mat1=xmat(:,:,m*2+1:m*3);
                            title1 = fig_names{3};
                            figcolor1=[4,10]; % Cued & uncued locations
                        elseif fig1==5
                            m = length(legend1_values);
                            mat1=xmat(:,:,m*3+1:m*4);
                            title1 = fig_names{4};
                            figcolor1=[1,10]; % Cued & uncued locations
                        elseif fig1==6
                            m = length(legend1_values);
                            mat1=xmat(:,:,m*4+1:m*5);
                            title1 = fig_names{5};
                            figcolor1=[2,10]; % Cued & uncued locations
                        elseif fig1==7
                            m = length(legend1_values);
                            mat1=xmat(:,:,m*5+1:m*6);
                            title1 = fig_names{6};
                            figcolor1=[4,10]; % Cued & uncued locations
                        end
                        
%                         %=
%                         % Normalize & divide
%                         v1=1:settings.baseline_bin_count;
%                         for i=1:size(mat1,3)
%                             a = nanmean(mat1(:,v1,i),2);
%                             a = nanmean(a);
%                             b1(:,:,i) = repmat(a, size(mat1,1), size(mat1,2));
%                             b1(b1==0)=NaN;
%                         end
%                         mat1=mat1./b1;
%                         %=
                        
                        %===========
                        % Calculate the colors
                        
                        figcolor2=[24,25]; % Other locations onscreen
                        
                        color1_line=[]; color1_error=[];
                        color1_line = NaN(length(legend1_values),3);
                        
                        % Cue location
                        m = find((legend1_values)<-90);
                        color1_line (m, :) = color1(figcolor1(1), :);
                        % Opposite location
                        m = find(legend1_values>0 & legend1_values<90);
                        color1_line (m, :) = color1(figcolor1(2), :);
                        % Other locations
                        b = find(isnan(color1_line(:,1)));
                        
                        % Other location colors are calculated as a range
                        col_min = color1(figcolor2(1),:); % Orientation 0
                        col_max = color1(figcolor2(2),:); % Orientation max
                        d1 = col_max-col_min;
                        stepsz = 1/(length(b));
                        for i=1:length(b)
                            color1_line(b(i),:)=col_min + (d1*stepsz)*(i);
                        end
                        
                        
                        % Color of the error bars
                        for i=1:size(color1_line,1)
                            d1 = 1-color1_line(i,:);
                            color1_error(i,:)=color1_line(i,:)+d1.*0.6;
                        end
                        
                    elseif fig1==8 || fig1==9 || fig1==10 || fig1==11
                        
                        % Select data to plot
                        if fig1==8 || fig1==9
                            
                            % Look task, memory location
                            m = find(legend1_values==0);
                            n = length(legend1_values);
                            mat1(:,:,1)=xmat(:,:,m);
                            % Look task, opposite location
                            m = find(legend1_values==-180);
                            n = length(legend1_values);
                            mat1(:,:,2)=xmat(:,:,m);
                            % Control task, probe location
                            m = find(legend1_values==0);
                            n = length(legend1_values);
                            mat1(:,:,3)=xmat(:,:,n*2+m);
                            % Figure names
                            title1 = fig_names{1};
                            
                            % Change legend text
                            legend_text=cell(1);
                            legend_text{1} = 'Look, cue location';
                            legend_text{2} = 'Look, opposite location';
                            legend_text{3} = 'Control';
                            
                        elseif fig1==10 || fig1==11
                            
                            % Look task, memory location
                            m = find(legend1_values==0);
                            n = length(legend1_values);
                            mat1(:,:,1)=xmat(:,:,n+m);
                            % Look task, opposite location
                            m = find(legend1_values==-180);
                            n = length(legend1_values);
                            mat1(:,:,2)=xmat(:,:,n+m);
                            % Control task, probe location
                            m = find(legend1_values==0);
                            n = length(legend1_values);
                            mat1(:,:,3)=xmat(:,:,n*2+m);
                            % Figure names
                            title1 = fig_names{2};
                            
                            % Change legend text
                            legend_text=cell(1);
                            legend_text{1} = 'Avoid, cue location';
                            legend_text{2} = 'Avoid, opposite location';
                            legend_text{3} = 'Control';
                            
                        end
                        
                        %                         % =
                        %                         % Normalize & divide
                        %                         v1=1:settings.baseline_bin_count;
                        %                         for i=1:size(mat1,3)
                        %                             a = nanmean(mat1(:,v1,i),2);
                        %                             a = nanmean(a);
                        %                             b1(:,:,i) = repmat(a, size(mat1,1), size(mat1,2));
                        %                             b1(b1==0)=0.01;
                        %                         end
                        %                         mat1=mat1./b1;
                        %                         % =
                        
                        figcolor1=[1,10,3];
                        
                        %===========
                        % Calculate the colors
                        color1_line = [];
                        color1_line = color1(figcolor1,:);
                        
                        % Color of the error bars
                        for i=1:size(color1_line,1)
                            d1 = 1-color1_line(i,:);
                            color1_error(i,:)=color1_line(i,:)+d1.*0.6;
                        end
                        
                        
                        
                    end
                    % End of specifying figure data and colors
                    
                    
                    % Plot only if data exists
                    if ~isnan (nanmean(nanmean(nanmean(mat1)))) && (nanmean(nanmean(nanmean(mat1))))~=0
                        
                        % Setup axis limits
                        h_1 = max(max(nanmean(mat1)));
                        h_2 = min(min(nanmean(mat1)));
                        
                        if fig_legend == 1
                            h_max=h_1+((h_1-h_2)*0.3);
                            h_min=h_2-((h_1-h_2)*0.2);
                        elseif fig_legend==2
                            h_max=h_1+((h_1-h_2)*0.4);
                            h_min=h_2-((h_1-h_2)*0.5);
                        end
                        
                        

                        
                        
                        %=================
                        % Calculate error bars
                        
                        a1=[]; b1=[]; c1=[]; d1=[]; f1=[];
                        %                 % Bootstrap analysis
                        %                 if size(mat1,1)>1
                        %                     % Bootstrap the sample
                        %                     for k=1:size(mat1,3)
                        %                         if k==1
                        %                             a1 = [mat1(:,:,k)];
                        %                         else
                        %                             a1 = [a1, mat1(:,:,k)];
                        %                         end
                        %                     end
                        %                     b1 = bootstrapnan(a1,settings.tboot1);
                        %                     c1 = prctile(b1,[2.5,97.5]);
                        %                     for k=1:size(mat1,3)
                        %                         i1=1+(size(mat1,2)*k)-size(mat1,2);
                        %                         i2=(size(mat1,2)*k);
                        %                         d1(:,:,k) = c1(1,i1:i2,:); % Lower bound (2.5 percentile)
                        %                         f1(:,:,k) = c1(2,i1:i2,:); % Upper bound (97.5 percentile)
                        %                     end
                        %                     % Save bootstrap data
                        %                     b1_bootstrap = b1;
                        %                     d1_bootstrap = d1;
                        %                     f1_bootstrap = f1;
                        %                 end
                        % SEM
                        if settings.error_bars==2 && size(mat1,1)>1
                            for k=1:size(mat1,3)
                                for i=1:size(mat1,2)
                                    d1(:,i,k) = nanmean(mat1(:,i,k))-se(mat1(:,i,k)); % Standard error, lower bound (identical to upper one)
                                    f1(:,i,k) = nanmean(mat1(:,i,k))+se(mat1(:,i,k)); % Standard error, upper bound (identical to lower one)
                                end
                            end
                        end
                        
                        %==================
                        % Plot error bars
                        
                        for k=1:size(mat1,3)
                            
                            
                            if size(mat1,1)>1
                                
                                graphcond=k;
                                
                                xc1=pbins(1); % Min x, min y
                                xc2=pbins(1); % Min x, max y
                                xc3=pbins; % Upper bound of errors
                                xc4=pbins(end); % Max x, max y
                                xc5=pbins(end); % Max x, min y
                                xc6=pbins;
                                xc6=fliplr(xc6);
                                
                                yc1=d1(:,1,k); % Lower bound of errors
                                yc2=f1(:,1,k); % upper bound of errors
                                yc3=f1(:,:,k); % Upper bound of errors
                                yc4=f1(:,end,k); % Upper bound of errors
                                yc5=d1(:,end,k); % Lower bound of errors
                                yc6=d1(:,:,k); % Lower bound of errors
                                yc6=fliplr(yc6);
                                
                                
                                h=fill([xc1,xc2,xc3,xc4, xc5, xc6],[yc1, yc2, yc3, yc4, yc5, yc6], [1 0.7 0.2],'linestyle','none');
                                set (h(end), 'FaceColor', color1_error(graphcond,:,:),'linestyle', 'none', 'FaceAlpha', 1)
                                
                            end
                        end
                        % End of error bars
                        
                        %==================
                        % Plot lines
                        
                        for k=1:size(mat1,3)
                            if size(mat1,1)>1
                                h=plot(pbins, nanmean(mat1(:,:,k)));
                            elseif size(mat1,1)==1
                                h=plot(pbins, mat1(1,:,k));
                            end
                            graphcond=k;
                            set (h(end), 'LineWidth', settings.wlinegraph, 'Color', color1_line(graphcond,:))
                        end
                        
                        
                        
                        
                        
                        %==============
                        % Figure settings
                        
                        set (gca,'FontSize', settings.fontsz);
                        set(gca,'XLim',[pbins(1)-49 pbins(end)+49]);
                        

                        
                        set(gca,'YLim', [h_min, h_max]);
                        title (sprintf('%s', title1), 'FontSize', settings.fontszlabel)
                        if h_max-h_min <=3
                            set(gca,'YTick', [-2:0.5:2]);
                        elseif h_max-h_min <=6
                            set(gca,'YTick', [-5:1:5]);
                        elseif h_max-h_min <=11
                            set(gca,'YTick', [-10:2:10]);
                        elseif  h_max-h_min <=25
                            set(gca,'YTick', [0:5:25]);
                        elseif h_max-h_min <=50
                            set(gca,'YTick', [0:10:50])
                        elseif h_max-h_min <=200
                            set(gca,'YTick', [0:50:h_max-h_min])
                        elseif h_max-h_min >200
                            set(gca,'YTick', [0:100:h_max-h_min])
                        end
                        
                        if fig1==1
                            xlabel ('Time from texture onset (ms)', 'FontSize', settings.fontszlabel);
                            set(gca,'XTick', [-400:200:400]);
                            ylabel ('Firing rate, Hz', 'FontSize', settings.fontszlabel);
                        elseif fig1==2 || fig1==3 || fig1==4 || fig1==5 || fig1==6 || fig1==7 || fig1==8 || fig1==9
                            xlabel ('Time from cue (ms)', 'FontSize', settings.fontszlabel);
                            set(gca,'XTick', [-200, 0:500:2000]);
                            ylabel ('Normalized firing rate', 'FontSize', settings.fontszlabel);
                        elseif fig1==10 || fig1==11
                            xlabel ('Time before ST (ms)', 'FontSize', settings.fontszlabel);
                            set(gca,'XTick', [-600:200:0]);
                            ylabel ('Firing rate, Hz', 'FontSize', settings.fontszlabel);
                        end
                        
                        
                        %===========
                        % Add extra figure with legend of stimulus positions
                        
                        if fig_legend == 1
                            
                            if fig1==1
                                
                                d1 = h_max-h_min;
                                x1 = [pbins(1), pbins(1)]; y1 = [h_min+d1*0.05, h_min+d1*0.15];
                                % Plot legend text
                                for k=1:length(legend1_values)
                                    graphcond=figcolor1(k);
                                    text(x1(k), y1(k), legend1_values{k}, 'Color', color1(graphcond,:),  'FontSize', settings.fontszlabel, 'HorizontalAlignment', 'left')
                                end
                                
                                
                                %                     if fig1==1 || fig1==2
                                %
                                %                         axes('Position',[0.3,0.8,0.1,0.1])
                                %                         axis 'equal'
                                %                         set (gca, 'Visible', 'off')
                                %                         hold on;
                                %
                                %                         % Initialize data values for plotting
                                %                         for i=1:length(legend1_values)
                                %
                                %                             % Color
                                %                             graphcond = i+1;
                                %
                                %                             % Find coordinates of a line
                                %                             f_rad = 1;
                                %                             f_arc = legend1_values(i);
                                %                             [xc,yc] = pol2cart(f_arc*pi/180, f_rad);
                                %
                                %                             % Plot line
                                %                             h=plot([0, xc], [0,yc]);
                                %                             set (h(end), 'LineWidth', settings.wlinegraph, 'Color', color1_line(graphcond,:))
                                %
                                %                         end
                                %                         % Add legend text
                                %                         text(-0, -1, 'Angle', 'Color', color1_line(2,:),  'FontSize', settings.fontszlabel, 'HorizontalAlignment', 'center')
                                %                         text(-0, -2, 'No tex', 'Color', color1_line(1,:),  'FontSize', settings.fontszlabel, 'HorizontalAlignment', 'center')
                                
                            elseif fig1==2 || fig1==3 || fig1==4 || fig1==5 || fig1==6 || fig1==7
                                
                                axes('Position',[0.75,0.8,0.1,0.1])
                                axis 'equal'
                                set (gca, 'Visible', 'off')
                                hold on;
                                
                                % Plot circle radius
                                cpos1 = [0,0];
                                ticks1 = [1];
                                cl1=[0.5,0.5,0.5];
                                for i=1:length(ticks1)
                                    h=rectangle('Position', [cpos1(1,1)-ticks1(i), cpos1(1,2)-ticks1(i), ticks1(i)*2, ticks1(i)*2],...
                                        'EdgeColor', cl1, 'FaceColor', 'none', 'Curvature', 1, 'LineWidth', 0.5, 'LineStyle', '-');
                                end
                                
                                % Plot fixation dot
                                cpos1 = [0,0];
                                ticks1=[0.1];
                                cl1=[0.5,0.5,0.5];
                                for i=1:length(ticks1)
                                    h=rectangle('Position', [cpos1(1,1)-ticks1(i), cpos1(1,2)-ticks1(i), ticks1(i)*2, ticks1(i)*2],...
                                        'EdgeColor', cl1, 'FaceColor', cl1, 'Curvature', 1, 'LineWidth', 0.5, 'LineStyle', '-');
                                end
                                
                                % Initialize data values for plotting
                                for i=1:length(legend1_values)
                                    
                                    % Color
                                    graphcond = i;
                                    
                                    % Find coordinates of a line
                                    f_rad = 1;
                                    f_arc = legend1_values(i);
                                    [xc,yc] = pol2cart(f_arc*pi/180, f_rad);
                                    objsize = 0.7;
                                    
                                    % Plot cirlce
                                    h=rectangle('Position', [xc(1)-objsize(1)/2, yc(1)-objsize(1)/2, objsize(1), objsize(1)],...
                                        'EdgeColor', color1_line(i,:), 'FaceColor', color1_line(i,:),'Curvature', 0, 'LineWidth', 1);
                                   
                                end
                                
                                % Cue location
                                m = find((legend1_values)<-90);
                                text(0, -2, 'Cue in RF', 'Color', color1_line(m,:),  'FontSize', settings.fontszlabel, 'HorizontalAlignment', 'center')
                                
                            elseif fig1==8 || fig1==9 || fig1==10 || fig1==11
                                
                                d1 = h_max-h_min;
                                x1 = [pbins(1), pbins(1), pbins(1)]; y1 = [h_min+d1*0.05, h_min+d1*0.13, h_min+d1*0.21];
                                % Plot legend text
                                for k=1:length(legend_text)
                                    graphcond=figcolor1(k);
                                    text(x1(k), y1(k), legend_text{k}, 'Color', color1(graphcond,:),  'FontSize', settings.fontszlabel, 'HorizontalAlignment', 'left')
                                end
                                
                                
                            end
                            % Legend spec for each figure is over
                            
                        end
                        % Fig legend is over
                        %===============
                        
                        
                        
                        %==============
                        % Export the figure & save it
                        
                        path1 = sprintf('%s%s/', path1_fig, neuron_name);
                        if ~isdir (path1)
                            mkdir (path1)
                        end
                        
                        f_name = sprintf('%s%s', path1, save_name);
                        set(gcf, 'PaperPositionMode', 'manual');
                        set(gcf, 'PaperUnits', 'inches');
                        set(gcf, 'PaperPosition', settings.figsize_1col)
                        set(gcf, 'PaperSize', [settings.figsize_1col(3),settings.figsize_1col(4)]);
                        print (f_name, '-dpdf')
                        close all;
                        %===============
                        
                    end
                    % End of decision whether data for plotting the figure
                    % exists
                    
                end
                % End of plotting each figure
            end
            % End of each neuron
            
        end
        % End of decision to over-write figure folder or not
    end
    % End of each date
end
% End of each subject



