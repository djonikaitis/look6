% Saccadic reaction times in psychophysics task

% clear all;
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
settings.figure_folder_name = 'SRT_bar';
settings.stats_file_name = sprintf('statistics_%s_', settings.figure_folder_name);


% Load and select data
for i_subj=1:length(settings.subjects)
    
    
    settings.subject_name=settings.subjects{i_subj}; % Select curent subject
    
    % Initialize subject specific folders where data is stored
    for i=1:length(settings.path_spec_names)
        v1 = ['path_', settings.path_spec_names{i}];
        settings.(v1) = sprintf ('%s%s/', settings.path_spec_folder{i}, settings.subject_name);
    end
    
    % Path to subject specific figures folder
    path1_fig = sprintf('%s%s/%s/', settings.path_figures, settings.figure_folder_name, settings.subject_name);
    
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
        
        % Get index of every folder for a given subject
        session_init = get_path_dates_v20(settings.path_data_combined, settings.subject_name);
        
        % Save session_init matrix into settings matrix
        % This part is necessary for preprocessing to run
        f1_data = fieldnames(session_init);
        for i=1:length(f1_data)
            settings.(f1_data{i})= session_init.(f1_data{i});
        end
        
        % Load data combined into one big file
        path1 = settings.path_data_combined;
        folder_index = settings.index_directory;
        file_index = folder_index; % File names are same as folder names
        comp_name = 'session'; % Which field is used for determing structure size
        S = get_combined_v11 (path1, folder_index, file_index, comp_name);
        
        % Load saccades data
        path1 = settings.path_data_combined;
        folder_index = settings.index_directory;
        file_index = cell(length(folder_index),1);
        for i=1:length(folder_index)
            file_index{i} = [folder_index{i}, '_saccades']; % File names are same as folder names
        end
        comp_name = 'trial_accepted'; % Which field is used for determing structure size
        var1 = get_combined_v11 (path1, folder_index, file_index, comp_name);
        
        % Copy saccades data into structure S
        f1 = fieldnames(var1);
        for i = 1:length(f1)
            S.(f1{i}) = var1.(f1{i});
        end
        
        %===============
        %===============
        % Data analysis
        %===============
        %===============
        
        % Reset data
        S.sacconset=S.sacmatrix(:,1)-S.targets_on;
        S.sacconset_copy = S.sacconset;
        
% % % % % %         a = ones(numel(S.session), 1)*2;
% % % % % %         S.training_stage=a;
        
        % Exp condition
        S.expcond=NaN(size(S.session,1),1);
        index1 = S.trial_accepted==-1 & S.em_target_number==1 & S.em_blockcond==1 & (S.training_stage)==2 & S.em_distractor_soa==0;
        S.expcond(index1)=1;
        index1 = S.trial_accepted==-1 & S.em_target_number==1 & S.em_blockcond==2 & (S.training_stage)==2 & S.em_distractor_soa==0;
        S.expcond(index1)=2;
        index1 = S.trial_accepted==-1 & S.em_target_number==2 & S.em_blockcond==1 & (S.training_stage)==2 & S.em_distractor_soa==0;
        S.expcond(index1)=3;
        index1 = S.trial_accepted==-1 & S.em_target_number==2 & S.em_blockcond==2 & (S.training_stage)==2 & S.em_distractor_soa==0;
        S.expcond(index1)=4;
        index1 = S.trial_accepted==-2 & S.em_target_number==2 & S.em_blockcond==1 & (S.training_stage)==2 & S.em_distractor_soa==0;
        S.expcond(index1)=5;
        index1 = S.trial_accepted==-2 & S.em_target_number==2 & S.em_blockcond==2 & (S.training_stage)==2 & S.em_distractor_soa==0;
        S.expcond(index1)=6;
        
        % Convert coordinates to degrees for probe position
        [th,radiusdeg] = cart2pol(S.em_t3_coord1, S.em_t3_coord2);
        objposdeg = (th*180)/pi;
        S.em_t3_arc = objposdeg;
        S.em_t3_rad = radiusdeg;
        
        % Convert coordinates to degrees for memory position
        [th,radiusdeg] = cart2pol(S.em_target_coord1, S.em_target_coord2);
        objposdeg = (th*180)/pi;
        S.em_mem_arc = objposdeg;
        S.em_mem_rad = radiusdeg;
        
        % Find relative probe-memory position
        S.rel_arc = S.em_mem_arc - S.em_t3_arc;
        S.rel_rad = S.em_t3_rad./S.em_mem_rad;
        % Round off
        S.rel_arc = round(S.rel_arc, 1);
        S.rel_rad = round(S.rel_rad, 1);
        % Reset to range -180:180
        ind = S.rel_arc<-180;
        S.rel_arc(ind)=S.rel_arc(ind)+360;
        ind = S.rel_arc>=180;
        S.rel_arc(ind)=S.rel_arc(ind)-360;

        
        % Calculate relative timing between probe and memory
        
        % Determine unique probe positions
        b=cell(max(S.day), 1);
        c=zeros(max(S.day), 1);
        for f=1:max(S.day)
            index1= ~isnan(S.expcond) & S.day==f;
            if sum(index1)>0
                a = [S.rel_arc(index1), S.rel_rad(index1)];
                b{f} =  unique(a,'rows');
                c(f) = f;
            end
        end
        coords1 = cell2mat(b);
        coords1 = unique(coords1,'rows');
        dates1 = find(c>0);
        
        
        %% Saccade RT
        
        mat1_ini = NaN(length(dates1), size(coords1,1), 8);
        mat2_ini = NaN(length(dates1), 8);
        test1 = NaN(length(dates1), size(coords1,1), 8);
        mat3_ini = [];
        
        % Discrimination rates
        for f=1:length(dates1)
            for i=1:size(coords1,1)
                for j=1:max(S.expcond)
                    
                    index1 = S.expcond==j & S.day==dates1(f) & S.rel_arc==coords1(i,1) & S.rel_rad==coords1(i,2);
                    
                    if sum(index1)>settings.trial_total_threshold
                        mat1_ini(f,i,j)=nanmedian(S.sacconset(index1),1);
                    end
                    test1(f,i,j)=sum(index1);
                    
                end
            end
        end
        
        % Calculate correct performance rates
        for f=1:length(dates1)
            for j=1:max(S.expcond)
                
                index1 = S.expcond==j & S.day==dates1(f);
                mat2_ini(f,j) = sum(index1);
 
            end
        end
        mat3_ini(:,1)=mat2_ini(:,3) ./ (mat2_ini(:,3)+mat2_ini(:,5));
        mat3_ini(:,2)=mat2_ini(:,4) ./ (mat2_ini(:,4)+mat2_ini(:,6));
        
        
    end
    % End of decision whether to over_write data
end
% End of loop for each subject



% Remove days with performance bellow threshild
for i=1:size(mat3_ini,1)
    for j=1:size(mat3_ini,2)
        if j==1
            cond1 = [1,3,5];
        elseif j==2
            cond1 = [2,4,5];
        end
        if mat3_ini(i,j)<0.55
            mat1_ini(i,:,cond1)=NaN;
        end
    end
end


%% FIGURE SHOWING SACCADE AMPLITUDES

for fig_legend1=2 % LEGEND ON & OFF
    
    
    for fig1=1:2
        
        hfig=figure;
        hold on;
        
        % Initialize data
        %=================
        conds1=[]; figcolor1=[];
        mat1=[];
        save_name=sprintf('fig%d', fig1);
        
        if fig1==1
            %====
            % Cued location
            a1 = coords1(:,1)==0 & coords1(:,2)==1;
            ind1 = find(a1==1);
            % Un-cued location
            a1 = coords1(:,1)==-180 & coords1(:,2)==1;
            ind2 = find(a1==1);
            %======
            % Look
            mat1(:,1,1)=mat1_ini(:,ind1,1);
            mat1(:,2,1)=mat1_ini(:,ind2,1);
            % Avoid
            mat1(:,1,2)=mat1_ini(:,ind1,2);
            mat1(:,2,2)=mat1_ini(:,ind2,2);
            
            figcolor1=[9,10];
            legend1{1}='Cued';
            legend1{2}='Non-cued';
            xlabel1{1} = 'Look';
            xlabel1{2} = 'Avoid';
            title1 = ' ';
            
        elseif fig1==2
            
            % Look correct and error
            m1 = nanmean(mat1_ini,2);
            mat1(:,1,1)=m1(:,3);
            mat1(:,2,1)=m1(:,4);
            % Avoid correct and error
            mat1(:,1,2)=m1(:,5);
            mat1(:,2,2)=m1(:,6);
            figcolor1=[11,12];
            legend1{1}='Correct';
            legend1{2}='Error';
            xlabel1{1} = 'Look';
            xlabel1{2} = 'Avoid';
            title1 = 'Main trials';
            
        end
        
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
        barwdh = 0.05; spacewidth=0.3;
        rngbar = [barwdh*b+barwdh*(b-1)*spacewidth]; % Bars plus spaces between them take that much space in total
        rngbar = rngbar/2; % Position to both sides of the unit
        xcoord = [1-rngbar:barwdh+barwdh*spacewidth:1+rngbar];
        
        pbins=xcoord;
        set(gca,'XLim',[pbins(1)-0.1 pbins(end)+0.1]);
        
        
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
                    set (h(end), 'LineWidth', settings.wlineerror, 'EdgeColor', color1(graphcond,:), 'FaceColor', color1(graphcond,:), 'BaseValue', -30);
                    
                    
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
                    
                    %========
                    % Add statistical signifficance
                    if fig1==1 || fig1==2
                        
                        if size(mat1,1)>1
                            if j==1
                                
                                % Statistics
                                [~,~,pval] = bootstrap_p_v10(b1_bootstrap(:,1,i), b1_bootstrap(:,2,i));
                                
                                % Plot properties
                                m1=[nanmean(mat1(:,1,i)),nanmean(mat1(:,2,i))];
                                m1=max(m1);
                                y1=m1+m1*0.13;
                                x1=(pbins(1)+pbins(2))/2;
                                p1=m1+m1*0.1;
                                
                                if round(pval,2)<=settings.p_level % Corrected for multiple comparisons!!!
                                    text(x1, y1, '*', 'Color',  [0.2, 0.2, 0.2],  'FontSize', settings.fontszlabel, 'HorizontalAlignment', 'center')
                                else
                                    text(x1, y1, 'ns', 'Color',  color1(graphcond,:),  'FontSize', settings.fontszlabel, 'HorizontalAlignment', 'center')
                                end
                                h=plot([pbins(1),pbins(2)], [p1,p1], 'Color',  [0.2, 0.2, 0.2],  'LineWidth', settings.wlineerror);
                                
                            end
                        end
                    %
                    %                         % Add text about statistics to a file
                    %                         if size(mat1,1)>1 && fig_legend1==2
                    %
                    %                             % Report means
                    %                             if j==1
                    %                                 targettext='%s location, %s task %.0f + se %.0f \n';
                    %                                 fprintf(fout, targettext, legend1{1}, xlabel1{i}, nanmean(mat1(:,1,i)), se(mat1(:,1,i)));
                    %                                 fprintf(fout, targettext, legend1{2}, xlabel1{i}, nanmean(mat1(:,2,i)), se(mat1(:,2,i)));
                    %                             end
                    %
                    %                             % Report comparisons
                    %                             if j==1
                    %                                 % T-Test
                    %                                 [~,pval,~,d_stat]=ttest(mat1(:,1,i),mat1(:,2,i));
                    %                                 targettext='%s task, %s location vs %s location, t-test: t(%d)=%.2f, p=%.4f \n';
                    %                                 fprintf(fout, targettext, xlabel1{i}, legend1{1}, legend1{2}, d_stat.df, d_stat.tstat, pval);
                    %
                    %                                 % Effect size
                    %                                 y1 = effect_size_v10(mat1(:,j,i),mat1(:,3,i));
                    %                                 targettext='Effect size: d=%.2f \n';
                    %                                 fprintf(fout, targettext, y1);
                    %
                    %                                 % Bootstrap signifficance test
                    %                                 [y1,y2,y3,y4,y5] = bootstrap_p_v10(b1_bootstrap(:,j,1), b1_bootstrap(:,3,1));
                    %                                 targettext='Bootstrap difference between conditions  %.1f + %.1f mean + se; [%.1f, %.1f] 95 CI; p=%.4f \n\n';
                    %                                 fprintf(fout, targettext, y1,y2,y4,y5,y3);
                    %                             end
                    %
                    %                         end
                    %                         % End of writing stats into file
                    %
                                        end
                                        %============
                                        % End of statistics part
                    
                    
                    %============
                    % ADD LEGEND
                    if fig_legend1==2
                        text(pbins(1), 115, legend1{j}, 'Color', [1,1,1],  ...
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
        
        %============
        % FIGURE SETUP
        set(gca,'FontSize', settings.fontsz);
        if fig1<=2
            set(gca,'YLim',[110 200]);
            set(gca,'YTick',120:20:200);
        end
        ylabel ('SRT (ms)', 'FontSize', settings.fontszlabel);
        
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
        elseif fig1==2
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
end
