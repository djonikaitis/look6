% Plots spike rasters for different stimulus background colors

clear all;
close all;
clc;

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

% Path to figures and statistics
settings.figure_folder_name = 'spikes_summary_bar';
settings.stats_file_name = sprintf('statistics_%s_', settings.figure_folder_name);


%% Run analysis

for i_subj=1:length(settings.subjects)
    
    settings.subject_name=settings.subjects{i_subj}; % Select curent subject
    
    % Initialize subject specific folders where data is stored. Necessary
    % bit of code.
    for i=1:length(settings.path_spec_names)
        v1 = ['path_', settings.path_spec_names{i}];
        settings.(v1) = sprintf ('%s%s/', settings.path_spec_folder{i}, settings.subject_name);
    end
    
    % Get index of every folder for a given subject
    session_init = get_path_dates_v20(settings.path_data_spikes, settings.subject_name);
    
    % Save session_init matrix into settings matrix
    % This part is necessary for preprocessing to run
    f1_data = fieldnames(session_init);
    for i=1:length(f1_data)
        settings.(f1_data{i})= session_init.(f1_data{i});
    end
    
    % Which date to analyse (all days or a single day)
    if settings.preprocessing_sessions_used==1
        ind = [1:length(session_init.index_unique_dates)];
    elseif settings.preprocessing_sessions_used==2
        ind = find(session_init.index_unique_dates==settings.preprocessing_day_id);
    elseif settings.preprocessing_sessions_used==3
        ind = length(session_init.index_unique_dates);
    end
    date_index = session_init.index_unique_dates(ind);
    
    
    
    %% Figure calculations
    
    for fig1 = 4 % Plot figures
        
        
        current_neuron_index = 0; % Initialize current neuron index; This number will increase until next figure is initialized
        
        % Initialize fig folder based on whether it is one day or all dates
        % combined
        if settings.preprocessing_sessions_used==1;
            
            % Path to subject specific figures folder
            path1_fig = sprintf('%s%s/%s/', settings.path_figures, settings.figure_folder_name, settings.subject_name);
            
            if ~isdir(path1_fig) || settings.overwrite==1
                % Remove old path
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
                
                settings.analysis_rerun = 1;
            else
                settings.analysis_rerun = 0;
            end
            
        else
            % Do that for each date separatelly, bellow
        end
        
        
        %% Load data of each date
        
        
        for i_date = 1:length(date_index)
            
            % Current folder to be analysed (raw date, with session index)
            i1 = find(date_index(i_date)==settings.index_dates);
            folder_name = settings.index_directory{i1};
            
            % Initialize fig folder based on whether it is one day or all dates
            % combined
            if settings.preprocessing_sessions_used==1
                % For all dates combined was done above
            else
                % Path to subject specific figures folder
                path1_fig = sprintf('%s%s/%s/%s/', settings.path_figures, settings.figure_folder_name, settings.subject_name, folder_name);
                
                if ~isdir(path1_fig) || settings.overwrite==1
                    % Remove old path
                    if ~isdir(path1_fig)
                        mkdir(path1_fig)
                    elseif isdir(path1_fig) % This will delete individual day folders
                        rmdir(path1_fig, 's')
                        mkdir(path1_fig)
                    end
                    
                    % Initialize text file for statistics
                    nameOut = sprintf('%s%s.txt', path1_fig, settings.stats_file_name); % File to be outputed
                    fclose('all');
                    fout = fopen(nameOut,'w');
                    
                    settings.analysis_rerun = 1;
                else
                    settings.analysis_rerun = 0;
                end
                
            end
            
            
            %%  Now decide whether to over-write analysis
            
            
            if  settings.analysis_rerun == 1;
                
                
                % Load combined data
                path1 = sprintf('%s%s/', settings.path_data_combined, folder_name);
                file_name = [folder_name];
                varx = load(sprintf('%s%s', path1, file_name));
                f1 = fieldnames(varx);
                S = struct; % Initialize empty var
                if length(f1)==1
                    S = varx.(f1{1});
                end
                
                % Load saccades data
                path1 = sprintf('%s%s/', settings.path_data_combined, folder_name);
                file_name = [folder_name, '_saccades'];
                varx = load(sprintf('%s%s', path1, file_name));
                f1 = fieldnames(varx);
                var1 = struct; % Initialize empty var
                if length(f1)==1
                    var1 = varx.(f1{1});
                end
                % Copy saccades data into structure S
                f1 = fieldnames(var1);
                for i = 1:length(f1)
                    S.(f1{i}) = var1.(f1{i});
                end
                
                
                %=============
                % Determine neurons that exist on a given day
                % For each neuron
                path1 = sprintf('%s%s/', settings.path_data_spikes, folder_name);
                spikes_init = get_path_spikes_v10 (path1, settings.subject_name); % Path to each neuron
                
                
                %=============
                % Determine neurons that exist on a given day
                % For each neuron
                path1 = sprintf('%s%s/', settings.path_data_spikes, folder_name);
                spikes_init = get_path_spikes_v10 (path1, settings.subject_name); % Path to each neuron
                
                %=================
                % Devise strategy how to load units used from data base
                prep_units_used; % Script with selected units
                b=[];
                for i = 1:length(units_used)
                    if ~isempty(units_used{i})
                        a = strcmp(units_used{i}, spikes_init.index_file_name);
                        b(i) = find(a==1);
                    end
                end
                units_used = b;
                
                
                %%  Run analysis for each unit
                for i_unit = units_used
                    
                    
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
                    
                    %==============
                    % Long and boring part of the code. Setup exp conditions
                    % you want to plot
                    %==============
                    
                    
                    % Texture vs no texture condition, works as basic
                    % selection criterion for visual responsiveness of
                    % neurons
                    if fig1==1
                        
                        S.expcond=NaN(size(S.trial_accepted));

                        % Setup conditions
                        index = S.em_background_texture_on==1 & S.trial_accepted==-1;
                        S.expcond(index)=1;
                        index = S.em_background_texture_on==0 & S.trial_accepted==-1;
                        S.expcond(index)=2;
                        
                        % Indicate what is expected condition number
                        cond1 = 1:2;
                        legend1_values = cell(1);
                        legend1_values{1} = 'Texture';
                        legend1_values{2} = 'No texture';
                        
                        % Determine selected offset in the time (for example between first display and memory onset)
                        if isfield(S, 'texture_on')
                            S.tconst = S.texture_on - S.first_display;
                        else
                            S.tconst = S.fixation_on - S.first_display;
                        end
                        
                        % Select appropriate interval for plottings
                        int_bins = [100, 500];
                        
                        new_mat = 1;
                        
                        % Plot data for look, avoid or control conditions
                        % (for each location separatelly)
                    elseif fig1==2 || fig1==3 || fig1==4
                        
                        S.expcond=NaN(size(S.trial_accepted));
                        S.expcond2=NaN(size(S.trial_accepted));
                        
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
                        S.rel_arc = round(S.rel_arc);
                        ind = S.rel_arc<=-180;
                        S.rel_arc(ind)=S.rel_arc(ind)+360;
                        ind = S.rel_arc>180;
                        S.rel_arc(ind)=S.rel_arc(ind)-360;
                        
                        % Find how many relative positions are recorded relative to memory
                        m1 = unique(S.rel_arc);
                        legend1_values = m1;
                        
                        % Texture on
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
                        
                        % No texture
                        i1=length(m1)*3;
                        for i=1:size(m1,1)
                            index = S.rel_arc==m1(i) & S.em_blockcond==1 & S.em_background_texture_on==0  & S.trial_accepted==-1;
                            S.expcond(index)=i+i1;
                        end
                        % Avoid task
                        i1=size(m1,1)*4;
                        for i=1:size(m1,1)
                            index = S.rel_arc==m1(i) & S.em_blockcond==2 & S.em_background_texture_on==0  & S.trial_accepted==-1;
                            S.expcond(index)=i+i1;
                        end
                        % Control task
                        i1=size(m1,1)*5;
                        for i=1:size(m1,1)
                            index = S.rel_arc==m1(i) & S.em_blockcond==5 & S.em_background_texture_on==0  & S.trial_accepted==-1;
                            S.expcond(index)=i+i1;
                        end
                        
                        % Indicate what is expected condition number
                        cond1 = 1:length(m1)*6;
                        fig_names = cell(1);
                        fig_names{1} = 'Control';
                        fig_names{2} = 'Look';
                        fig_names{3} = 'Avoid';
                        
                        %=======
                        % Baseline
                        % Texture on
                        % Look task
                        index = S.em_blockcond==1 & S.em_background_texture_on==1  & S.trial_accepted==-1;
                        S.expcond2(index)=1;
                        % Avoid task
                        index = S.em_blockcond==2 & S.em_background_texture_on==1  & S.trial_accepted==-1;
                        S.expcond2(index)=2;
                        % Control task
                        index = S.em_blockcond==5 & S.em_background_texture_on==1  & S.trial_accepted==-1;
                        S.expcond2(index)=3;
                        % No texture
                        index = S.em_blockcond==1 & S.em_background_texture_on==0  & S.trial_accepted==-1;
                        S.expcond2(index)=4;
                        % Avoid task
                        index = S.em_blockcond==2 & S.em_background_texture_on==0  & S.trial_accepted==-1;
                        S.expcond2(index)=5;
                        % Control task
                        index = S.em_blockcond==5 & S.em_background_texture_on==0  & S.trial_accepted==-1;
                        S.expcond2(index)=6;
                        
                        % Over-write spike rates?
                        if fig1==2
                            new_mat = 1;
                        elseif fig1>2
                            new_mat = 1;
                        end
                        
                        % Data collected during memory delay, before
                        % target onset
                        S.tconst = S.fixation_off - S.first_display;
                        int_bins = [-400, -100];
                        
                        % Calculate baseline performance (make sure same bin size as t_const)
                        S.tconst_base= S.memory_on - S.first_display;
                        int_bins_base = [-300, 0];
                        
                    end
                    
                    
                    %===========
                    % Initialize spike timing
                    t1_spike = spikes1.ts;
                    
                    % Get timing of the events
                    t1 = spikes1.msg_1;
                    t1 = t1+S.tconst; % Reset to time relative to tconst
                    
                    % Get timing for the baseline
                    t1_base = spikes1.msg_1;
                    t1_base = t1+S.tconst_base;
                    
                    %================
                    % Create matrix to store average spiking data
                    current_neuron_index = current_neuron_index + 1;
                    if current_neuron_index == 1
                        xmat_avg = NaN(1, length(int_bins), length(cond1));
                        xmat_avg_base = NaN(1, length(int_bins), length(cond1));
                    else
                        xmat_avg(current_neuron_index, :, :) = NaN;
                        xmat_avg_base(current_neuron_index, :, :) = NaN;
                    end
                    
                    
                    %============
                    % Find spikes
                    
                    if new_mat==1 % This decides whether to over_write the calculated data matrix
                        
                        %============
                        % Initialize empty matrix
                        xmat = NaN(size(S.expcond,1), length(int_bins), length(cond1));
                        test1 = NaN(1, length(cond1));
                        xmat_base = NaN(size(S.expcond,1), length(int_bins), length(cond1));
                        
                        
                        % How many trials recorded for each condition?
                        for k=1:length(cond1)
                            index = S.expcond == cond1(k);
                            test1(k)=sum(index);
                        end
                        
                        %=============
                        % Calculate spiking rates (selected interval)
                        
                        for tid = 1:size(xmat,1)
                            for k=1:length(cond1)
                                
                                c1 = S.expcond(tid); % Which condition it is currently?
                                % If particular conditon on a given trial
                                % exists, then calculate firing rates
                                if ~isnan(c1) && c1==k
                                    
                                    % Index
                                    index = t1_spike >= t1(tid) + int_bins(1) & ...
                                        t1_spike <= t1(tid) + int_bins(2) & ...
                                        S.expcond(tid) == cond1(k);
                                    
                                    % Save data
                                    if sum(index)==0
                                        xmat(tid,1,c1)=0; % Save as zero spikes
                                    elseif sum(index)>0
                                        xmat(tid,1,c1)=sum(index); % Save spikes counts
                                    end
                                end
                                
                            end
                        end
                        % End of spike rate calculation
                        
                        xmat_avg(current_neuron_index, :, :) = nanmean(xmat);
                        xmat_avg (xmat_avg==0) = NaN; % Exlcute neurons with 0 recorded baseline

                        %===============
                        % Calculate spiking rate baseline
                        
                        for tid = 1:size(xmat_base,1)
                            for k=1:length(cond1)
                                
                                c1 = S.expcond2(tid); % Which condition it is currently?
                                % If particular conditon on a given trial
                                % exists, then calculate firing rates
                                if ~isnan(c1) && c1==k
                                    
                                    % Index
                                    index = t1_spike >= t1_base(tid) + int_bins_base(1) & ...
                                        t1_spike <= t1_base(tid) + int_bins_base(2) & ...
                                        S.expcond2(tid) == cond1(k);
                                    
                                    % Save data
                                    if sum(index)==0
                                        xmat_base(tid,1,c1)=0; % Save as zero spikes
                                    elseif sum(index)>0
                                        xmat_base(tid,1,c1)=sum(index); % Save spikes counts
                                    end
                                end
                                
                            end
                        end
                        % End of spike rate calculation
                        
                        xmat_avg_base(current_neuron_index, :, :) = nanmean(xmat_base);
                        xmat_avg_base (xmat_avg_base==0) = NaN; % Exlcute neurons with 0 recorded baseline
                        
                    end
                    % End of decision whether to calculate spike rates
                    
                    
                end
                % End of each neuron
            end
            % End of decision to over-write figure folder or not
        end
        % End of each date
        
        pbins=int_bins+settings.bin_length/2;
        
        
        %% Plot figure
        
        
        fig_legend1=2; % Legend is on;
        
        hfig=figure;
        hold on;
        
        % Initialize data
        %=================
        mat1=[]; legend1={};
        save_name=sprintf('fig %d', fig1);
        
        % Select data from matrix
        if fig1==1
            
            % Average data relative to texture onset
            mat1(:,1)=xmat_avg(:,1,1);
            mat1(:,2)=xmat_avg(:,1,2);
            %                     %=
            %                     % Normalize & divide
            %                     v1=1:settings.baseline_bin_count;
            %                     b1=[];
            %                     for i=1:size(mat1,3)
            %                         a = nanmean(mat1(:,v1,i),2);
            %                         a = nanmean(a);
            %                         b1(:,:,i) = repmat(a, size(mat1,1), size(mat1,2));
            %                         b1(b1==0)=0.01;
            %                     end
            %                     mat1=mat1./b1;
            %                     %=
            %
            figcolor1=[23,21];
            title1 = 'Responses to texture ';
            
            legend1=legend1_values;
            xlabel1{1} = ' ';
            
            % Texture condition
        elseif fig1==2
            
            
            % Look task, memory location
            m = find(legend1_values==0);
            n = length(legend1_values);
            mat1(:,1,2)=xmat_avg(:,1,m);
            % Look task, opposite location
            m = find(abs(legend1_values)==180);
            n = length(legend1_values);
            mat1(:,2,2)=xmat_avg(:,1,m);
            % Avoid task, memory location
            m = find(legend1_values==0);
            n = length(legend1_values);
            mat1(:,1,3)=xmat_avg(:,1,n+m);
            % Avoid task, opposite location
            m = find(abs(legend1_values)==180);
            n = length(legend1_values);
            mat1(:,2,3)=xmat_avg(:,1,n+m);
            % Control task, memory location
            m = find(legend1_values==0);
            n = length(legend1_values);
            mat1(:,1,1)=xmat_avg(:,1,n*2+m);
            % Control task, opposite location
            m = find(abs(legend1_values)==180);
            n = length(legend1_values);
            mat1(:,2,1)=xmat_avg(:,1,n*2+m);
            
            mat1 = mat1.*100;
            
            % Figure names
            title1 = fig_names{1};
            
            figcolor1=[9,10];
            legend1{1}='Cued';
            legend1{2}='Non-cued';
            xlabel1{1} = 'Control';
            xlabel1{2} = 'Look';
            xlabel1{3} = 'Avoid';
            title1 = 'Texture on';
            
            % No texture condition
        elseif fig1==3
            
            % Look task, memory location
            m = find(legend1_values==0);
            n = length(legend1_values);
            mat1(:,1,2)=xmat_avg(:,1,n*3+m);
            % Look task, opposite location
            m = find(abs(legend1_values)==180);
            n = length(legend1_values);
            mat1(:,2,2)=xmat_avg(:,1,n*3+m);
            % Avoid task, memory location
            m = find(legend1_values==0);
            n = length(legend1_values);
            mat1(:,1,3)=xmat_avg(:,1,n*4+m);
            % Avoid task, opposite location
            m = find(abs(legend1_values)==180);
            n = length(legend1_values);
            mat1(:,2,3)=xmat_avg(:,1,n*4+m);
            % Control task, memory location
            m = find(legend1_values==0);
            n = length(legend1_values);
            mat1(:,1,1)=xmat_avg(:,1,n*5+m);
            % Control task, opposite location
            m = find(abs(legend1_values)==180);
            n = length(legend1_values);
            mat1(:,2,1)=xmat_avg(:,1,n*5+m);
            
            % Figure names
            title1 = fig_names{1};
            
            figcolor1=[9,10];
            legend1{1}='Cued';
            legend1{2}='Non-cued';
            xlabel1{1} = 'Control';
            xlabel1{2} = 'Look';
            xlabel1{3} = 'Avoid';
            title1 = ' ';
            
        elseif fig1==4
            
            mat0 = [];
            % Texture present
            % Look task, memory location
            m = find(legend1_values==0);
            n = length(legend1_values);
            mat0(:,1,1)=xmat_avg(:,1,m);
            % Look task, opposite location
            m = find(abs(legend1_values)==180);
            n = length(legend1_values);
            mat0(:,2,1)=xmat_avg(:,1,m);
            % Avoid task, memory location
            m = find(legend1_values==0);
            n = length(legend1_values);
            mat0(:,1,2)=xmat_avg(:,1,n+m);
            % Avoid task, opposite location
            m = find(abs(legend1_values)==180);
            n = length(legend1_values);
            mat0(:,2,2)=xmat_avg(:,1,n+m);
%             % Control task, memory location
%             m = find(legend1_values==0);
%             n = length(legend1_values);
%             mat0(:,1,3)=xmat_avg(:,1,n*2+m);
%             % Control task, opposite location
%             m = find(abs(legend1_values)==180);
%             n = length(legend1_values);
%             mat0(:,2,3)=xmat_avg(:,1,n*2+m);           
            
            mat1(:,1,1)=(mat0(:,1,1)-mat0(:,2,1))./mat0(:,2,1);
            mat1(:,2,1)=(mat0(:,1,2)-mat0(:,2,2))./mat0(:,2,2);
%             mat1(:,3,1)=(mat0(:,1,3)-mat0(:,2,3))./mat0(:,2,3);
            
%             mat0 = [];
%             % Texture absent
%             % Look task, memory location
%             m = find(legend1_values==0);
%             n = length(legend1_values);
%             mat0(:,1,1)=xmat_avg(:,1,n*3+m);
%             % Look task, opposite location
%             m = find(abs(legend1_values)==180);
%             n = length(legend1_values);
%             mat0(:,2,1)=xmat_avg(:,1,n*3+m);
%             % Avoid task, memory location
%             m = find(legend1_values==0);
%             n = length(legend1_values);
%             mat0(:,1,2)=xmat_avg(:,1,n*4+m);
%             % Avoid task, opposite location
%             m = find(abs(legend1_values)==180);
%             n = length(legend1_values);
%             mat0(:,2,2)=xmat_avg(:,1,n*4+m);
%             
%             mat1(:,1,2)=(mat0(:,1,1)-mat0(:,2,1))./mat0(:,2,1);
%             mat1(:,2,2)=(mat0(:,1,2)-mat0(:,2,2))./mat0(:,2,2);
            
mat1 = mat1.*100;
            figcolor1=[1,2,4];
            legend1{1}='Look';
            legend1{2}='Avoid';
%             legend1{3}='Control';

            xlabel1{1} = ' ';
%             xlabel1{2} = 'Blank';
%             xlabel1{3} = 'Avoid';
            title1 = ' ';
            
        end
        % End of specifying figure data and colors
        
        
        % Plot only if data exists
        if ~isnan (nanmean(nanmean(nanmean(mat1))))
            
            %================
            % Calculate the number of bars to be plotted
            b=-1; c=[];
            for i=1:size(mat1,3);
                t1=mat1(:,:,i);
                if size(mat1,1)>1
                    t1=nanmean(t1);
                end
                t1=length(t1);
                b=t1+1+b; % This one is total number of bars (across all experiments)
                c(i)=t1; % This one is for knowing how many bars per experiment (for exp labels)
            end
            
            % Bar positions
            barwdh  = 0.05; spacewidth=0.3;
            rngbar = [barwdh*b+barwdh*(b-1)*spacewidth]; % Bars plus spaces between them take that much space in total
            rngbar = rngbar/2; % Position to both sides of the unit
            xcoord = [1-rngbar:barwdh+barwdh*spacewidth:1+rngbar];
            
            pbins=xcoord;
            set(gca,'XLim',[pbins(1)-0.1 pbins(end)+0.1]);
            
            % Setup axis limits
            h_1 = max(max(nanmean(mat1)));
            h_2 = min(min(nanmean(mat1)));
            h_max=h_1+((h_1-h_2)*0.1);
            h_min=h_2-((h_1-h_2)*0.4);
            
            
            %=================
            % Calculate error bars
            
            a1=[]; b1=[]; c1=[]; d1=[]; f1=[];
            % Bootstrap the sample
            if size(mat1,1)>1
                for k=1:size(mat1,3)
                    if k==1
                        a1 = [mat1(:,:,k)];
                    else
                        a1 = [a1, mat1(:,:,k)];
                    end
                end
                b1 = bootstrapnan(a1,settings.tboot1);
                c1 = prctile(b1,[2.5,97.5]);
                for k=1:size(mat1,3)
                    i1=1+(size(mat1,2)*k)-size(mat1,2);
                    i2=(size(mat1,2)*k);
                    d1(:,:,k) = c1(1,i1:i2,:); % Lower bound (2.5 percentile)
                    f1(:,:,k) = c1(2,i1:i2,:); % Upper bound (97.5 percentile)
                    b2(:,:,k) = b1(:,i1:i2,:); % Restructure original matrix for bootstrap stats
                end
                b1_bootstrap = b2;
                d1_bootstrap = d1;
                f1_bootstrap = f1;
            end
            % SEM
            if settings.error_bars==2 && size(mat1,1)>1
                for k=1:size(mat1,3)
                    for i=1:size(mat1,2)
                        d1(:,i,k) = nanmean(mat1(:,i,k))-se(mat1(:,i,k)); % Standard error, lower bound (identical to upper one)
                        f1(:,i,k) = nanmean(mat1(:,i,k))+se(mat1(:,i,k)); % Standard error, upper bound (identical to lower one)
                    end
                end
            end
            
            
            %===============
            % Plot the bars
            for i=1:size(mat1,3)
                for j=1:size(mat1,2)
                    if nanmean(mat1(:,j,i))>0
                        
                        %=======
                        % MEANS
                        if size(mat1,1)>1
                            h=bar(pbins(1), nanmean(mat1(:,j,i)), barwdh);
                        else
                            h=bar(pbins(1), mat1(:,j,i), barwdh);
                        end
                        graphcond=figcolor1(j);
                        set (h(end), 'LineWidth', settings.wlineerror, 'EdgeColor', color1(graphcond,:), 'FaceColor', color1(graphcond,:), 'BaseValue', -2);
                        
                        
                        %=======
                        % Plot error bars
                        if size(mat1,1)>1
                            graphcond=figcolor1(j);
                            % SEM
                            ciAmpli1 = d1(:,j,i);
                            ciAmpli2 = f1(:,j,i);
                            h=plot([pbins(1),pbins(1)], [nanmean(mat1(:,j,i)),ciAmpli1]);
                            set (h(end), 'LineWidth', settings.wlineerror, 'Color', facecolor1(graphcond,:))
                            h=plot([pbins(1),pbins(1)], [nanmean(mat1(:,j,i)),ciAmpli2]);
                            set (h(end), 'LineWidth', settings.wlineerror, 'Color', color1(graphcond,:))
                        end
                        
                        %                                 %========
                        %                                 % Add statistical signifficance
                        %                                 if fig1==1 || fig1==2
                        %
                        %                                     if size(mat1,1)>1
                        %                                         if j==1
                        %
                        %                                             % Statistics
                        %                                             [~,~,pval] = bootstrap_p_v10(b1_bootstrap(:,1,i), b1_bootstrap(:,2,i));
                        %
                        %                                             % Plot properties
                        %                                             m1=[nanmean(mat1(:,1,i)),nanmean(mat1(:,2,i))];
                        %                                             m1=max(m1);
                        %                                             y1=m1+m1*0.2;
                        %                                             x1=(pbins(1)+pbins(2))/2;
                        %                                             p1=m1+m1*0.15;
                        %
                        %                                             %                                 if round(pval,2)<=settings.p_level % Corrected for multiple comparisons!!!
                        %                                             text(x1, y1, '*', 'Color',  color1(graphcond,:),  'FontSize', settings.fontszlabel, 'HorizontalAlignment', 'center')
                        %                                             %                                 else
                        %                                             %                                     text(x1, y1, 'ns', 'Color',  color1(graphcond,:),  'FontSize', settings.fontszlabel, 'HorizontalAlignment', 'center')
                        %                                             %                                 end
                        %                                             h=plot([pbins(1),pbins(2)], [p1,p1], 'Color',  color1(graphcond,:),  'LineWidth', settings.wlineerror);
                        %
                        %                                         end
                        %                                     end
                        %                                     %
                        %                                     %                         % Add text about statistics to a file
                        %                                     %                         if size(mat1,1)>1 && fig_legend1==2
                        %                                     %
                        %                                     %                             % Report means
                        %                                     %                             if j==1
                        %                                     %                                 targettext='%s location, %s task %.0f + se %.0f \n';
                        %                                     %                                 fprintf(fout, targettext, legend1{1}, xlabel1{i}, nanmean(mat1(:,1,i)), se(mat1(:,1,i)));
                        %                                     %                                 fprintf(fout, targettext, legend1{2}, xlabel1{i}, nanmean(mat1(:,2,i)), se(mat1(:,2,i)));
                        %                                     %                             end
                        %                                     %
                        %                                     %                             % Report comparisons
                        %                                     %                             if j==1
                        %                                     %                                 % T-Test
                        %                                     %                                 [~,pval,~,d_stat]=ttest(mat1(:,1,i),mat1(:,2,i));
                        %                                     %                                 targettext='%s task, %s location vs %s location, t-test: t(%d)=%.2f, p=%.4f \n';
                        %                                     %                                 fprintf(fout, targettext, xlabel1{i}, legend1{1}, legend1{2}, d_stat.df, d_stat.tstat, pval);
                        %                                     %
                        %                                     %                                 % Effect size
                        %                                     %                                 y1 = effect_size_v10(mat1(:,j,i),mat1(:,3,i));
                        %                                     %                                 targettext='Effect size: d=%.2f \n';
                        %                                     %                                 fprintf(fout, targettext, y1);
                        %                                     %
                        %                                     %                                 % Bootstrap signifficance test
                        %                                     %                                 [y1,y2,y3,y4,y5] = bootstrap_p_v10(b1_bootstrap(:,j,1), b1_bootstrap(:,3,1));
                        %                                     %                                 targettext='Bootstrap difference between conditions  %.1f + %.1f mean + se; [%.1f, %.1f] 95 CI; p=%.4f \n\n';
                        %                                     %                                 fprintf(fout, targettext, y1,y2,y4,y5,y3);
                        %                                     %                             end
                        %                                     %
                        %                                     %                         end
                        %                                     %                         % End of writing stats into file
                        %                                     %
                        %                                 end
                        %                                 %============
                        %                                 % End of statistics part
                        
                        
                        %============
                        % ADD LEGEND
                        if fig_legend1==2
                            text(pbins(1), 5, legend1{j}, 'Color', [1,1,1],  ...
                                'FontSize', settings.fontsz, 'HorizontalAlignment', 'left', 'Rotation', 90);
                        end
                        
                    end
                    % Remove first plotbin
                    pbins(1)=[];
                    
                end
                % Remove one bar between experiments
                try
                    pbins(1)=[];
                end
            end
            
            
            %==============
            % Figure settings
            
            set (gca,'FontSize', settings.fontsz);
%             set(gca,'XLim',[pbins(1)-49 pbins(end)+49]);
            set(gca,'YLim', [0, h_max+h_max*0.3]);
            title (sprintf('%s', title1), 'FontSize', settings.fontszlabel)
%             if h_max-h_min <=1
%                 set(gca,'YTick', [0.2:0.2:0.8]);
%             elseif h_max-h_min <=6
%                 set(gca,'YTick', [-5:1:5]);
%             elseif h_max-h_min <=11
%                 set(gca,'YTick', [-10:2:10]);
%             end
            
            %============
            % FIGURE SETUP
            set(gca,'FontSize', settings.fontsz);
            if fig1==4
                set(gca,'YTick', [10:10:50]);
            end
            
            if fig1==1
                ylabel ('Firing rel. to baseline', 'FontSize', settings.fontszlabel);
            elseif fig1==2 || fig1==3
                ylabel ('Firing rel. to baseline', 'FontSize', settings.fontszlabel);
            elseif fig1==4
                ylabel ('Firing rate increase, %', 'FontSize', settings.fontszlabel);
            end
            
            
            % Put experiment names for the X labels
            tick1=[];
            for i=1:size(mat1,3)
                a=xcoord(1:c(i));
                a=(a(1)+a(end))/2;
                try xcoord(1:c(i)+1)=[]; end
                tick1(i)=a;
            end
            
            set(gca,'XTick',tick1);
            if fig1==1
                set(gca,'XTickLabel', xlabel1,'FontSize', settings.fontszlabel)
            elseif fig1==2 || fig1==3 || fig1==4
                set(gca,'XTickLabel', xlabel1,'FontSize', settings.fontszlabel)
            end
            
            
            % Figure title
            title (title1, 'FontSize', settings.fontszlabel)
            
            %============
            % Export the figure & save it
            
            if fig_legend1==1
                fileName=[path1_fig, save_name];
            elseif fig_legend1==2
                fileName=[path1_fig, save_name,  '_legend'];
            end
            set(gcf, 'PaperPositionMode', 'manual');
            set(gcf, 'PaperUnits', 'inches');
            set(gcf, 'PaperPosition', settings.figsize)
            set(gcf, 'PaperSize', [settings.figsize(3),settings.figsize(4)]);
            print (fileName, '-dpdf')
            print (fileName, '-dtiff', '-r600')
            close all;
            %===============
            
        end
        % End of decision whether data for plotting the figure
        % exists
        
    end
    % End of each figure
end
% End of each subject




