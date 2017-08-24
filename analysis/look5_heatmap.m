% Plot heatmap of performance at different locations
% Plots spike rasters for different stimulus background colors

clear all;
close all;
clc;


%% Initial setup

% Loading the files needed
if ~exist('settings', 'var')
    settings = struct;
end

if ~isfield (settings, 'exp_name')
    settings.exp_name = input ('Type in experiment name: ', 's');
end
% Default subject number: all subjects
if ~isfield (settings, 'subjects')
    sN1 = 'all'; % Subject name
end

% Run settings file:
eval(sprintf('%s_settings', settings.exp_name)); % Load general settings


%% Some settings

% Path to figures and statistics
settings.figure_folder_name = 'heatmap';
settings.stats_file_name = sprintf('statistics_%s_', settings.figure_folder_name);


%% Analysis

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
    
    % Load data combined into one big file
    path1 = settings.path_data_combined;
    folder_index = session_init.index_directory;
    file_index = folder_index;
    S = get_combined_v11 (path1, folder_index, file_index, 'session');
    
    % Load saccade data
    for i=1:length(folder_index)
        file_index{i}=[folder_index{i}, '_saccades'];
    end
    var1 = get_combined_v11 (path1, folder_index, file_index, 'trial_accepted');
    
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
    
    % Remove trials that are practice trials
    %=======
    % EMPTY
    %=======
    %=======
    %=======
    
    % Exp condition
    S.expcond=NaN(size(S.session,1),1);
    index1 = S.trial_accepted==-1 & S.em_probe_trial==1 & S.em_blockcond==1 & cell2mat(S.training_stage)==1;
    S.expcond(index1)=1;
    index1 = S.trial_accepted==-1 & S.em_probe_trial==1 & S.em_blockcond==2 & cell2mat(S.training_stage)==1;
    S.expcond(index1)=2;
    index1 = S.trial_accepted==-1 & S.em_probe_trial==1 & S.em_blockcond==3 & cell2mat(S.training_stage)==1;
    S.expcond(index1)=3;
    index1 = S.trial_accepted==-1 & S.em_probe_trial==1 & S.em_blockcond==4 & cell2mat(S.training_stage)==1;
    S.expcond(index1)=4;
    %
    %     % For each day do a z-score of saccade latencies
    %     a = unique(S.day);
    %     for k=1:length(a)
    %         for p=1:max(S.expcond)
    %             index1 = S.day == a(k) & S.expcond==p;
    %             temp1 = zscore(S.sacconset(index1));
    %             S.sacconset(index1)=temp1;
    %         end
    %     end
    
    % Copy target_coord
    st1 = S.em_target_coord1; st2 = S.em_target_coord2;
    % Quadrant 1 is not changed
    % Quadrant 2 flip x
    index = st1<0 & st2>0;
    S.em_t3_coord1(index)=S.em_t3_coord1(index).*-1;
    S.em_target_coord1(index)=S.em_target_coord1(index).*-1;
    % Quadrant 3 flip x flip y
    index = st1<0 & st2<0;
    S.em_t3_coord1(index)=S.em_t3_coord1(index).*-1;
    S.em_t3_coord2(index)=S.em_t3_coord2(index).*-1;
    S.em_target_coord1(index)=S.em_target_coord1(index).*-1;
    S.em_target_coord2(index)=S.em_target_coord2(index).*-1;
    % Quadrant 4 flip y
    index = st1>0 & st2<0;
    S.em_t3_coord2(index)=S.em_t3_coord2(index).*-1;
    S.em_target_coord2(index)=S.em_target_coord2(index).*-1;
    
    %===============
    % Determine coordinates used for the grid (make it flexible across experiments)
    
    p_x = []; p_y = [];
    index = S.trial_accepted==-1 & S.em_probe_trial==1 & cell2mat(S.training_stage)==1;
    % Find probe position x
    p_x = S.em_t3_coord1(index,1);
    if size(p_x,2)>1
        p_x=p_x';
    end
    % Find probe position y
    p_y = S.em_t3_coord2(index,1);
    if size(p_y,2)>1
        p_y=p_y';
    end
    probe_pos_cond = unique([p_x, p_y], 'rows');
    
    min_x = min(probe_pos_cond(:,1));
    max_x = max(probe_pos_cond(:,1));
    min_y = min(probe_pos_cond(:,2));
    max_y = max(probe_pos_cond(:,2));
    [grid_x,grid_y]=meshgrid([min_x:1:max_x], [min_y:1:max_y]);
    [grid_x,grid_y]=meshgrid([-8:1:8], [-8:1:8]);

    
    %=============
    % Setup grid matrix
    
    if i_subj==1
        mat1_ini=NaN(size(grid_x,1), size(grid_x,2), max(removeNaN(S.expcond)), length(settings.subjects));
        mat2_ini=NaN(size(grid_x,1), size(grid_x,2), max(removeNaN(S.expcond)), length(settings.subjects));
        test1=NaN(size(grid_x,1), size(grid_x,2), max(removeNaN(S.expcond)), length(settings.subjects));
        test2=NaN(size(grid_x,1), size(grid_x,2), max(removeNaN(S.expcond)), length(settings.subjects));
    end
    
    
    %%  Calculate matrix with latencies
    
    for p=1:max(S.expcond)
        for k=1:size(grid_x,1)
            for m=1:size(grid_x,2)
                
                
                % Proportions
                index1 = S.expcond==p & S.em_t3_coord1 == grid_x(k,m) & S.em_t3_coord2 == grid_y(k,m);
                
                %==================
                % For trials where data exists
                
                if sum(index1)>=settings.trial_total_threshold;
                    mat1_ini(k,m,p,i_subj)=nanmean(S.sacconset(index1));
                end
                
                % How many trials were in the bin? (For check-up purposes)
                if sum(index1)>0
                    test1(k,m,p,i_subj)=sum(index1);
                end
            end
        end
        
    end
    % End of analysis calculating saccade RT
    %==================
    %==================
    
    
    %%  Fill in missing data
    
    % For trials where data does not exist, do extrapolation
    % Calculate matrix with latencies
    for p=1:size(mat1_ini,3)
        index = ~isnan(mat1_ini(:,:,p)); i1 = sum(sum(index));
        if i1 >0 % If data exists, else waste no time
            for k=1:size(grid_x,1)
                for m=1:size(grid_x,2)
                    
                    if isnan(mat1_ini(k,m,p))
                        x = grid_x(k,m); y = grid_y(k,m);
                        dist_mat = sqrt(((x-grid_x).^2) + ((y-grid_y).^2));
                        dist_vect = sqrt( (x-S.em_t3_coord1).^2 + (y-S.em_t3_coord2).^2);
                        a = unique(dist_mat);
                        a(a==0)=[];
                        
                        index1 = 0;
                        while sum(index1)==0 && ~isempty(a)
                            index1 = S.expcond==p & dist_vect == a(1);
                            if sum(index1)>settings.trial_total_threshold
                                test2(k,m,p,i_subj) = sum(index1);
                                mat2_ini(k,m,p,i_subj) = nanmean(S.sacconset(index1));
                            end
                            a(1)=[];
                        end
                        
                    end
                    
                end
            end
        end
    end
    % End of filling in data
    
    
end
% End of analysis for each subject
% ===========

mat3_ini = NaN(size(mat1_ini));
index = ~isnan(mat1_ini);
mat3_ini(index)=mat1_ini(index);
index = ~isnan(mat2_ini);
mat3_ini(index)=mat2_ini(index);

test3 = NaN(size(test1));
index = ~isnan(test1);
test3(index)=test1(index);
index = ~isnan(test2);
test3(index)=test2(index);

%% FIGURE

for fig_legend1=2
    
    for fig1=[1,2,4, 9, 10]
        
        % Initialize data
        %=================
        mat1=[]; coordx=[]; coordy=[];
        c1_heatmap = inferno(100);
        if fig1==1
            % Select data
            cond1=1;
            coordx = grid_x; coordy = grid_y;
            mat1=mat3_ini(:,:,cond1);
            % Settings
            title1 = 'Look';
            save_name = 'look_zRT';
            % Axis limits
            h_max = max(max(mat1)); h_max=h_max+h_max*0.01;
            h_min = min(min(mat1)); h_min=h_min-h_min*0.01;
        elseif fig1==2
            % Select data
            cond1=2;
            coordx = grid_x; coordy = grid_y;
            mat1=mat3_ini(:,:,cond1);
            % Settings
            title1 = 'Avoid';
            save_name = 'avoid_zRT';
            % Axis limits
            h_max = max(max(mat1)); h_max=h_max+h_max*0.01;
            h_min = min(min(mat1)); h_min=h_min-h_min*0.01;
        elseif fig1==4
            % Select data
            cond1=4;
            coordx = grid_x; coordy = grid_y;
            mat1=mat3_ini(:,:,cond1);
            % Settings
            title1 = 'Control';
            save_name = 'control_zRT';
            % Axis limits
            h_max = max(max(mat1)); h_max=h_max+h_max*0.01;
            h_min = min(min(mat1)); h_min=h_min-h_min*0.01;
            %         elseif fig1==5
            %             % Select data
            %             cond1=1;
            %             coordx = grid_x; coordy = grid_y;
            %             mat1=test1(:,:,cond1);
            %             % Settings
            %             title1 = 'Trial counts';
            %             save_name = 'trials_look';
            %             mat1(mat1>50)=15;
        elseif fig1==9
            % Select data
            coordx = grid_x; coordy = grid_y;
            mat1=mat3_ini(:,:,4)-mat3_ini(:,:,1);
            % Settings
            title1 = 'Look';
            save_name = 'look_RT_diff';
            % Axis limits
            h_max = max(max(mat1)); h_max=h_max+h_max*0.01;
            h_min = min(min(mat1)); h_min=h_min-h_min*0.01;
        elseif fig1==10
            % Select data
            coordx = grid_x; coordy = grid_y;
            mat1=mat3_ini(:,:,4)-mat3_ini(:,:,2);
            % Settings
            title1 = 'Avoid';
            save_name = 'avoid_RT_diff';
            % Axis limits
            h_max = max(max(mat1)); h_max=h_max+h_max*0.01;
            h_min = min(min(mat1)); h_min=h_min-h_min*0.01;
        end
        
        hfig=figure;
        hold on;
        
        %         % Resize matrix & coordinates for my own specifications
        %         if fig1==1 || fig1==2 || fig1==3 || fig1==4
        %             szfactor=3; % Makes figure smoother
        %             sz=size(mat1); sz=sz*szfactor;
        %             mat1 = imresize(mat1 , sz , 'bilinear' );
        %             coordx = imresize(coordx , sz , 'bilinear' );
        %             coordy = imresize(coordy , sz , 'bilinear' );
        %         end
        
        
        % Plot heatmap
        if fig1==1 || fig1==2 || fig1==3 || fig1==4 || fig1==9 || fig1==10
            if ~isnan(h_min) && ~isnan(h_max) && (h_min~=h_max)
                contourf(coordx, coordy, mat1, 'LineColor', 'none', 'LevelListMode', 'manual', 'LevelList', linspace(h_min, h_max, 100))
                caxis([h_min,h_max]); % Limit the color range to be plotted
                colormap(c1_heatmap)
                if fig_legend1 == 2
                    if fig1==1 || fig1==2 || fig1==3 || fig1==4
                        h = colorbar('YTick',[100:10:150], 'location', 'EastOutside');
                        h.Label.String = 'SRT';
                        h.Label.FontSize = settings.fontszlabel;
                    end
                    if fig1==9 || fig1==10
                        h = colorbar('YTick',[-20:5:20], 'location', 'EastOutside');
                        h.Label.String = 'SRT diff';
                        h.Label.FontSize = settings.fontszlabel;
                    end
                end
            end
        end
        
        
        %
        %         % Plot trial counts as blocks
        %         if fig1==5 || fig1==6 || fig1==7 || fig1==8
        %             for k=1:size(grid_x,1)
        %                 for m=1:size(grid_x,2)
        %                     if ~isnan(mat1(k,m))
        %                         % Plot rectangles
        %                         h1 = rectangle('Position', [grid_x(k,m)-0.5, grid_y(k,m)-0.5, 1, 1]);
        %                         % Find color range
        %                         a = min(min(mat1)); b=max(max(mat1));
        %                         cs = linspace( a,b, size(c1_heatmap,1));
        %                         % Apply color
        %                         c1 = find (mat1(k,m)>=cs);
        %                         c1=c1(end); % Find first macthing color
        %                         set(h1, 'FaceColor', c1_heatmap(c1,:), 'EdgeColor', 'none')
        %                     end
        %                 end
        %             end
        %             surf(coordx, coordy, mat1, 'LineStyle', 'none')
        %             colormap(c1_heatmap)
        %         end
        
        
        %======================
        % Add notation for saccade target/distractor/remapped location
        
        % Plot saccade target
        pos1 = [6,6];
        [th,radiusdeg] = cart2pol(pos1(1), pos1(2));
        rad=1;
        objposdeg = 45;
        [xc,yc]=pol2cart(objposdeg*pi/180,radiusdeg);
        
        ang=0:0.01:2*pi;
        xp=rad*cos(ang);
        yp=rad*sin(ang);
        h = plot(xc+xp,yc+yp);
        set (h(end), 'LineWidth', settings.wlinegraph, 'Color', [0.5, 0.5, 0.5])
        
        %==============
        % Settings
        
        set (gca,'FontSize', settings.fontsz);
        xlabel ('Probe position, deg', 'FontSize', settings.fontszlabel);
        ylabel ('Probe position, deg', 'FontSize', settings.fontszlabel);
        title (title1, 'FontSize', settings.fontszlabel)
        if fig1==1 || fig1==2 || fig1==3 || fig1==4 || fig1==9 || fig1==10
            set(gca,'YLim',[min_y max_y]);
            set(gca,'Ytick',[-6: 6: 6]);
            set(gca,'XLim',[min_x max_x]);
            set(gca,'Xtick',[-6: 6:  6]);
        elseif fig1==5 || fig1==6 || fig1==7 || fig1==8
            set(gca,'YLim',[min_y-1 max_y+1]);
            set(gca,'Ytick',[-6: 6: 6]);
            set(gca,'XLim',[min_x-1 max_x+1]);
            set(gca,'Xtick',[-6: 6:  6]);
        end
        
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
        %         print (fileName, '-dpdf')
        print (fileName, '-dtiff', '-r600')
        close all;
        %===============
        
    end
end

