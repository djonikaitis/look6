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
settings.figure_folder_name = 'spikes_orientation';
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
            
            % Initialize text file for statistics
            nameOut = sprintf('%s%s.txt', path1_fig, settings.stats_file_name); % File to be outputed
            fclose('all');
            fout = fopen(nameOut,'w');
            
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
%             path1 = sprintf('%s%s/', settings.path_data_combined, folder_name);
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
                
                %==========
                % Figure calculations
                
                for fig1=1:4 % Plot figures
                    
                    %==============
                    % Save neuron name
                    neuron_name = ['ch', num2str(spikes_init.index_channel(i_unit)), '_u',  num2str(spikes_init.index_unit(i_unit))];
                    
                    
                    %==============
                    % Setup exp condition
                    S.expcond=NaN(size(S.START));
                    
                    
                    if fig1==1
                        
                        % Texture
                        m1 = unique(S.esetup_background_texture_line_angle);
                        orientation1 = m1;
                        
                        % One condition per texture
                        index = S.esetup_background_texture_on==1 & strcmp(S.edata_error_code, 'correct');
                        S.expcond(index)=1;
                        
                        % Indicate what is expected condition number
                        cond1 = 1;
                        
                        % Determine selected offset in the time (for example between first display and memory onset)
                        % S.first_display is the time plexon message was sent
                        if fig1==1
                            if isfield(S, 'texture_on')
                                S.tconst = S.texture_on - S.first_display;
                            else
                                S.tconst = S.fixation_on - S.first_display;
                            end
                            % Select appropriate interval for plottings
                            int_bins = [100, 500];
                        end
                        
                        % Save texture angles for legend
                        legend1_values = m1;
                        
                        % To calculate spiking rates or use existing
                        % matrix?
                        new_mat = 1;
                        
                    elseif fig1==2 || fig1==3 || fig1==4
                        
                        % Texture
                        m1 = unique(S.esetup_background_texture_line_angle);
                        orientation1 = m1;
                        
                        % Find memory target arc
                        [th,radiusdeg] = cart2pol(S.esetup_memory_coord(:,1), S.esetup_memory_coord(:,2));
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
                            index = S.rel_arc==m1(i) & S.esetup_block_cond==1 & S.esetup_background_texture_on==1  & strcmp(S.edata_error_code, 'correct');
                            S.expcond(index)=i+i1;
                        end
                        % Avoid task
                        i1=size(m1,1);
                        for i=1:size(m1,1)
                            index = S.rel_arc==m1(i) & S.esetup_block_cond==2 & S.esetup_background_texture_on==1  & strcmp(S.edata_error_code, 'correct');
                            S.expcond(index)=i+i1;
                        end
                        % Control task
                        i1=size(m1,1)*2;
                        for i=1:size(m1,1)
                            index = S.rel_arc==m1(i) & S.esetup_block_cond==5 & S.esetup_background_texture_on==1  & strcmp(S.edata_error_code, 'correct');
                            S.expcond(index)=i+i1;
                        end
                        
                        % Indicate what is expected condition number
                        cond1 = 1:length(m1)*3;
                        fig_names = cell(1);
                        fig_names{1} = 'Look';
                        fig_names{2} = 'Avoid';
                        fig_names{3} = 'Control';
                        
                        % Over-write spike rates?
                        if fig1==2
                            new_mat = 1;
                        elseif fig1==3 || fig1==4
                            new_mat = 0;
                        end
                        
                        % Data collected during memory delay, before
                        % target onset
                        S.tconst = S.target_on - S.first_display;
                        int_bins = [-500, -100];
                        
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
                        xmat = NaN(size(S.expcond,1), length(orientation1), length(cond1));
                        test1 = NaN(1, length(orientation1), length(cond1));
                        
                        % How many trials recorded for each condition?
                        for i=1:length(orientation1)
                            for k=1:length(cond1)
                                index = S.expcond == cond1(k) & S.esetup_background_texture_line_angle==orientation1(i);
                                test1(1,i,k)=sum(index);
                            end
                        end
                        
                        % Find spikes
                        for tid = 1:size(xmat,1)
                            for j=1:length(orientation1)
                                for k=1:length(cond1)
                                    
                                    c1 = S.expcond(tid); % Which condition it is currently?
                                    
                                    % If particular conditon on a given trial
                                    % exists, then calculate firing rates
                                    if ~isnan(c1) && c1==k
                                        
                                        % Index
                                        index = t1_spike >= t1(tid) + int_bins(1) & ...
                                            t1_spike <= t1(tid) + int_bins(2) + settings.bin_length & ...
                                            S.expcond(tid) == cond1(k) &...
                                            S.esetup_background_texture_line_angle(tid) == orientation1(j);
                                        
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
                        
                        pbins=[orientation1'];
                    
                    end
                    % End of checking whether new_mat==1
                    
                    % % % %                     % Convert to HZ
                    % % % %                     %                 xmat = xmat*(1000/settings.bin_length);
                    
                    
                    
                    
                    %% Plot figure
                    
                    
                    fig_legend=2; % Legend is on;
                    
                    hfig=figure;
                    hold on;
                    
                    % Initialize data
                    %=================
                    mat1=[]; legend1={};
                    save_name=sprintf('fig %d', fig1);
                    
                    if fig1==1
                        
                        mat1=xmat;
                        
                        %===
                        figcolor1=[10];
                        if fig1==1
                            title1 = 'Orientation selectivity';
                        end
                        
                    elseif fig1==2
                        
                        % Look task, memory location
                        m = find(legend1_values==0);
                        n = length(legend1_values);
                        mat1(:,:,1)=xmat(:,:,m);
                        % Look task, opposite location
                        m = find(legend1_values==-180);
                        n = length(legend1_values);
                        mat1(:,:,2)=xmat(:,:,m);
                        
                        % Figure names
                        title1 = fig_names{1};
                        figcolor1=[9,10];

                        % Change legend text
                        legend_text=cell(1);
                        legend_text{1} = 'Cue location';
                        legend_text{2} = 'Opposite location';
                        
                    elseif fig1==3
                        
                        % Look task, memory location
                        m = find(legend1_values==0);
                        n = length(legend1_values);
                        mat1(:,:,1)=xmat(:,:,n+m);
                        % Look task, opposite location
                        m = find(legend1_values==-180);
                        n = length(legend1_values);
                        mat1(:,:,2)=xmat(:,:,n+m);
                        
                        % Figure names
                        title1 = fig_names{2};
                        figcolor1=[9,10];
                        
                        % Change legend text
                        legend_text=cell(1);
                        legend_text{1} = 'Cue location';
                        legend_text{2} = 'Opposite location';
                        
                    elseif fig1==4
                        
                        % Look task, memory location
                        m = find(legend1_values==0);
                        n = length(legend1_values);
                        mat1(:,:,1)=xmat(:,:,n*2+m);
                        % Look task, opposite location
                        m = find(legend1_values==-180);
                        n = length(legend1_values);
                        mat1(:,:,2)=xmat(:,:,n*2+m);
                        
                        % Figure names
                        title1 = fig_names{3};
                        figcolor1=[9,10];
                        
                        % Change legend text
                        legend_text=cell(1);
                        legend_text{1} = 'Cue location';
                        legend_text{2} = 'Opposite location';
                              
                    end
                    
                    % Plot only if data exists
                    if ~isnan (nanmean(nanmean(nanmean(mat1)))) && (nanmean(nanmean(nanmean(mat1))))~=0
                        
                        % Setup axis limits
                        h_1 = max(max(nanmean(mat1)));
                        h_2 = min(min(nanmean(mat1)));
                        h_max=h_1+((h_1-h_2)*0.4);
                        h_min=h_2-((h_1-h_2)*0.4);
                        
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
                                
                                graphcond=figcolor1(k);
                                
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
                                set (h(end), 'FaceColor', face_color1(graphcond,:,:),'linestyle', 'none', 'FaceAlpha', 1)
                                
                            end
                        end
                        
                        %==================
                        % Plot lines
                        
                        for k=1:size(mat1,3)
                            if size(mat1,1)>1
                                h=plot(pbins, nanmean(mat1(:,:,k)));
                            elseif size(mat1,1)==1
                                h=plot(pbins, mat1(1,:,k));
                            end
                            graphcond=figcolor1(k);
                            set (h(end), 'LineWidth', settings.wlinegraph, 'Color', color1(graphcond,:))
                        end
                        
                        
                        %==============
                        % Figure settings
                        
                        set (gca,'FontSize', settings.fontsz);
                        set(gca,'XLim',[pbins(1)-10 pbins(end)+10]);
                        
                        set(gca,'YLim', [h_min, h_max]);
                        title (sprintf('%s', title1), 'FontSize', settings.fontszlabel)
% % %                         if h_max-h_min <=3
% % %                             set(gca,'YTick', [-2:0.5:2]);
% % %                         elseif h_max-h_min <=6
% % %                             set(gca,'YTick', [-5:1:5]);
% % %                         elseif h_max-h_min <=11
% % %                             set(gca,'YTick', [-10:2:10]);
% % %                         end                        
                        
                        title (sprintf('%s', title1), 'FontSize', settings.fontszlabel)
                        xlabel ('Texture orientation', 'FontSize', settings.fontszlabel);
                        set(gca,'XTick', [0:45:180]);
                        ylabel ('Firing rate (Hz)', 'FontSize', settings.fontszlabel);
                        
                        
                        %===========
                        % Add extra figure with legend of stimulus positions
                        
                        
                        if fig_legend == 2
                            if fig1==2 || fig1==3 || fig1==4
                                
                                d1 = h_max-h_min;
                                x1 = [pbins(1), pbins(1), pbins(1)]; y1 = [h_min+d1*0.05, h_min+d1*0.13, h_min+d1*0.21];
                                % Plot legend text
                                for k=1:length(legend_text)
                                    graphcond=figcolor1(k);
                                    text(x1(k), y1(k), legend_text{k}, 'Color', color1(graphcond,:),  'FontSize', settings.fontszlabel, 'HorizontalAlignment', 'left')
                                end
                            end
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
                % End of each figure
            end
            % End of each neuron
        end
        % End of decision whether to over-write folders or not
    end
    % End of each datge
end
% End of each subject




