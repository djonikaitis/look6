% Saccadic reaction times in psychophysics task

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

settings.figure_folder_name = 'saccade rt bar';
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
        S = get_struct_v10(path1);
        sacc1 = get_struct_v10(path2);
        
        %===============
        % Figure folder
        if numel(dates_used)>1
        elseif numel(dates_used)==1
            path_fig = sprintf('%s%s/%s/%s/', settings.path_figures, settings.figure_folder_name, settings.subject_current, folder_name);
        end
        
        % Overwrite figure folders
        if ~isdir(path_fig) || settings.overwrite==1
            if ~isdir(path_fig)
                mkdir(path_fig)
            elseif isdir(path_fig)
                rmdir(path_fig, 's')
                mkdir(path_fig)
            end
        end
        
        % Initialize text file for statistics
        nameOut = sprintf('%s%s.txt', path_fig, settings.stats_file_name); % File to be outputed
        fclose('all');
        fout = fopen(nameOut,'w');
        
        %% Analysis
        
        % Reset data
        
        S.sacconset = sacc1.saccade_matrix(:,1)-S.target_on;
        
        %==============
        % Exp condition
        S.expcond = NaN(size(S.session,1),1);
        
        index1 = strcmp(sacc1.trial_accepted, 'correct target') & S.esetup_target_number==1 & strcmp(S.esetup_block_cond, 'look') & ...
            S.esetup_response_soa==0;
        S.expcond(index1)=1;
        
        index1 = strcmp(sacc1.trial_accepted, 'correct target') & S.esetup_target_number==1 & strcmp(S.esetup_block_cond, 'avoid') & ...
            S.esetup_response_soa==0;
        S.expcond(index1)=2;
        
        index1 = strcmp(sacc1.trial_accepted, 'correct target') & S.esetup_target_number==2 & strcmp(S.esetup_block_cond, 'look') & ...
            S.esetup_response_soa==0;
        S.expcond(index1)=3;
        
        index1 = strcmp(sacc1.trial_accepted, 'correct target') & S.esetup_target_number==2 & strcmp(S.esetup_block_cond, 'avoid') & ...
            S.esetup_response_soa==0;
        S.expcond(index1)=4;
        
        index1 = strcmp(sacc1.trial_accepted, 'wrong target') & S.esetup_target_number==2 & strcmp(S.esetup_block_cond, 'look') & ...
            S.esetup_response_soa==0;
        S.expcond(index1)=5;
        
        index1 = strcmp(sacc1.trial_accepted, 'wrong target') & S.esetup_target_number==2 & strcmp(S.esetup_block_cond, 'avoid') & ...
            S.esetup_response_soa==0;
        S.expcond(index1)=6;
        
        %===============
        % Memory position
        [th,radius1] = cart2pol(S.esetup_memory_coord(:,1), S.esetup_memory_coord(:,2));
        arc1 = (th*180)/pi;
        m1 = [round(arc1,1), round(radius1, 1)];
        m2 = unique(m1, 'rows');
        S.esetup_memory_arc = m1(:,1);
        S.esetup_memory_radius = m1(:,2);
        
        % ST1 position
        [th,radius1] = cart2pol(S.esetup_st1_coord(:,1), S.esetup_st1_coord(:,2));
        arc1 = (th*180)/pi;
        m1 = [round(arc1,1), round(radius1, 1)];
        m2 = unique(m1, 'rows');
        S.esetup_st1_arc = m1(:,1);
        S.esetup_st1_radius = m1(:,2);
        
        % Find relative probe-memory position
        S.rel_arc = S.esetup_memory_arc - S.esetup_st1_arc;
        S.rel_rad = S.esetup_st1_radius./S.esetup_memory_radius;
        % Round off
        S.rel_arc = round(S.rel_arc, 1);
        S.rel_rad = round(S.rel_rad, 1);
        % Reset to range -180:180
        ind = S.rel_arc<=-180;
        S.rel_arc(ind)=S.rel_arc(ind)+360;
        ind = S.rel_arc>180;
        S.rel_arc(ind)=S.rel_arc(ind)-360;
        
        
        % Determine unique stimulus positions
        b=cell(numel(dates_used), 1);
        ind = ~isnan(S.expcond);
        if sum(ind)>0
            a = [S.rel_arc(ind), S.rel_rad(ind)];
            b{i_date} =  unique(a,'rows');
        end
        
        % Add concatenation over different days
        if numel(b)>0
        end
        coords1 = cell2mat(b);
        coords1 = unique(coords1,'rows');
        
        
        %% Saccade RT
        
        if i_date==1
            mat1_ini = NaN(numel(dates_used), size(coords1,1), 8);
            mat2_ini = NaN(numel(dates_used), 8);
            test1 = NaN(length(dates_used), size(coords1,1), 8);
            mat3_ini = [];
        end
        
        % Discrimination rates
        for i=1:size(coords1,1)
            for j=1:max(S.expcond)
                
                index1 = S.expcond==j & S.rel_arc==coords1(i,1) & S.rel_rad==coords1(i,2);
                
                if sum(index1)>settings.trial_total_threshold
                    mat1_ini(i_date,i,j)=nanmedian(S.sacconset(index1),1);
                end
                test1(i_date,i,j)=sum(index1);
                
            end
        end
        %
        %         % Calculate correct performance rates
        %         for f=1:length(dates1)
        %             for j=1:max(S.expcond)
        %
        %                 index1 = S.expcond==j & S.day==dates1(f);
        %                 mat2_ini(f,j) = sum(index1);
        %
        %             end
        %         end
        %         mat3_ini(:,1)=mat2_ini(:,3) ./ (mat2_ini(:,3)+mat2_ini(:,5));
        %         mat3_ini(:,2)=mat2_ini(:,4) ./ (mat2_ini(:,4)+mat2_ini(:,6));
        
        
    end
    % End of analysis for each day
    
end
% End of loop for each subject



% % Remove days with performance bellow threshild
% for i=1:size(mat3_ini,1)
%     for j=1:size(mat3_ini,2)
%         if j==1
%             cond1 = [1,3,5];
%         elseif j==2
%             cond1 = [2,4,5];
%         end
%         if mat3_ini(i,j)<0.55
%             mat1_ini(i,:,cond1)=NaN;
%         end
%     end
% end


%% FIGURE 1

plot_set = struct;
mat1=[];

% Look correct and error
m1 = nanmean(mat1_ini,2);
mat1(:,1,1)=m1(:,3);
mat1(:,2,1)=m1(:,4);
% Avoid correct and error
mat1(:,1,2)=m1(:,5);
mat1(:,2,2)=m1(:,6);

% Initialize structure
plot_set.mat1 = mat1;

plot_set.bar_width = 0.05;
plot_set.pbins = plot_helper_bargraph_coordinates_x_v10(plot_set);

plot_set.data_color = [9,10];

plot_set.XTick = [];
plot_set.x_plot_bins = plot_set.pbins;
plot_set.xtick_label{1} = 'Correct';
plot_set.xtick_label{2} = 'Error';
plot_set.XLim = [plot_set.pbins(1)-0.1, plot_set.pbins(end)+0.1];
plot_set.YTick = [100:25:175];
plot_set.YLim = [90, 180];
plot_set.figure_title = 'Main task trials';
plot_set.xlabel = ' ';
plot_set.ylabel = 'Reaction time, ms';

plot_set.legend{1} = 'Look';
plot_set.legend{2} = 'Avoid';
for i=1:numel(plot_set.legend{1})
    plot_set.legend_y_coord(i) = 100;
    plot_set.legend_x_coord(i) = plot_set.pbins(i);
end

% Saving data
plot_set.figure_size = settings.figure_size_temp;
plot_set.figure_save_name = 'main task';
plot_set.path_figure = path_fig;


%==================
% Plot

hfig = figure;
hold on;

e_bars = plot_helper_error_bar_calculation_v10(mat1, settings);
plot_helper_bargraph_plot_v10

plot_helper_save_figure;
close all;

%===============



%% FIGURE 2

plot_set = struct;
mat1=[];

% Cued location
a1 = coords1(:,1)==0 & coords1(:,2)==1;
ind1 = find(a1==1);
% Un-cued location
a1 = coords1(:,1)==180 & coords1(:,2)==1;
ind2 = find(a1==1);

% Look correct and error
mat1(:,1,1)=mat1_ini(:,ind1,1);
mat1(:,2,1)=mat1_ini(:,ind2,1);
% Avoid correct and error
mat1(:,1,2)=mat1_ini(:,ind1,2);
mat1(:,2,2)=mat1_ini(:,ind2,2);

% Initialize structure
plot_set.mat1 = mat1;

plot_set.bar_width = 0.05;
plot_set.pbins = plot_helper_bargraph_coordinates_x_v10(plot_set);

plot_set.data_color = [9,10];

plot_set.XTick = [];
plot_set.x_plot_bins = plot_set.pbins;
plot_set.xtick_label{1} = 'Look';
plot_set.xtick_label{2} = 'Avoid';
plot_set.XLim = [plot_set.pbins(1)-0.1, plot_set.pbins(end)+0.1];
plot_set.YTick = [100:25:175];
plot_set.YLim = [90, 180];
plot_set.figure_title = 'Probe trials';
plot_set.xlabel = ' ';
plot_set.ylabel = 'Reaction time, ms';

plot_set.legend{1} = 'Cued';
plot_set.legend{2} = 'Un-cued';
for i=1:numel(plot_set.legend{1})
    plot_set.legend_y_coord(i) = 100;
    plot_set.legend_x_coord(i) = plot_set.pbins(i);
end

% Saving data
plot_set.figure_size = settings.figure_size_temp;
plot_set.figure_save_name = 'probe task';
plot_set.path_figure = path_fig;


%==================
% Plot

hfig = figure;
hold on;

e_bars = plot_helper_error_bar_calculation_v10(mat1, settings);
plot_helper_bargraph_plot_v10

plot_helper_save_figure;
close all;

%===============


