% Psychophysics performance

% Reset data
if isfield(S, 'target_on')
    S.sacconset = sacc1.saccade_matrix(:,1)-S.target_on;
end

task_names_subset = cell(1);
task_names_subset{1} = 'look';
task_names_subset{2} = 'avoid';

%==============
% Data

data_mat = struct;
data_mat.mat1_ini = S.sacconset;
data_mat.var1{1} = S.esetup_block_cond;
data_mat.var1_match{1} = task_names_subset;
data_mat.var1{2} = S.edata_error_code;
data_mat.var1_match{2} = error_code_subset;
data_mat.var1{3} = S.esetup_target_number;
data_mat.var1_match{3} = 2;
data_mat.var1{4} = S.esetup_st2_color_level;
data_mat.var1_match{4} = 0;
data_mat.var1{5} = S.esetup_response_soa;
data_mat.var1_match{5} = 0;

data_mat = look6_helper_indexed_selection_behaviour(data_mat, settings);

%==========
% Plot correct vs error
%==========

% Select data for plotting
mat1 = NaN(1, numel(task_names_subset), 2);
for i = 1:numel(task_names_subset)
    
    j = strcmp(error_code_subset, 'correct');
    mat1(1,i,1) = data_mat.output(1, i, j);
    
    j = strcmp(error_code_subset, 'looked at st2');
    mat1(1,i,2) = data_mat.output(1, i, j);
    
end

plot_set = struct;
plot_set.mat_y = mat1;
plot_set.bar_width = 0.05;
plot_set.mat_x = plot_helper_bargraph_coordinates_x_v10(plot_set);

plot_set.data_color = [9,10];
    
%     plot_set.XTick = [];
%     plot_set.x_plot_bins = plot_set.pbins;
%     plot_set.xtick_label{1} = 'Correct';
%     plot_set.xtick_label{2} = 'Error';
%     plot_set.XLim = [plot_set.pbins(1)-0.1, plot_set.pbins(end)+0.1];
%     plot_set.YTick = [100:25:200];
%     plot_set.YLim = [90, 225];
%     plot_set.figure_title = 'Main task trials';
%     plot_set.xlabel = ' ';
%     plot_set.ylabel = 'Reaction time, ms';
%     
%     plot_set.legend{1} = 'Look';
%     plot_set.legend{2} = 'Avoid';
%     for i=1:numel(plot_set.legend{1})
%         plot_set.legend_y_coord(i) = 100;
%         plot_set.legend_x_coord(i) = plot_set.pbins(i);
%     end
%     


%     
%     e_bars = plot_helper_error_bar_calculation_v10(mat1, settings);
%     plot_helper_bargraph_plot_v10
%     
%     
%     
%     
%     
%     %% FIGURE 2
%     
%     plot_set = struct;
%     mat1=[];
%     
%     % Cued location
%     a1 = conds1(:,1)==0 & conds1(:,2)==1;
%     ind1 = find(a1==1);
%     % Un-cued location
%     a1 = conds1(:,1)==180 & conds1(:,2)==1;
%     ind2 = find(a1==1);
%     
%     % Look correct and error
%     mat1(:,1,1)=mat1_ini(:,ind1,1);
%     mat1(:,2,1)=mat1_ini(:,ind2,1);
%     % Avoid correct and error
%     mat1(:,1,2)=mat1_ini(:,ind1,2);
%     mat1(:,2,2)=mat1_ini(:,ind2,2);
%     
%     % Initialize structure
%     plot_set.mat1 = mat1;
%     
%     plot_set.bar_width = 0.05;
%     plot_set.pbins = plot_helper_bargraph_coordinates_x_v10(plot_set);
%     
%     plot_set.data_color = [9,10];
%     
%     plot_set.XTick = [];
%     plot_set.x_plot_bins = plot_set.pbins;
%     plot_set.xtick_label{1} = 'Look';
%     plot_set.xtick_label{2} = 'Avoid';
%     plot_set.XLim = [plot_set.pbins(1)-0.1, plot_set.pbins(end)+0.1];
%     plot_set.YTick = [100:25:175];
%     plot_set.YLim = [90, 180];
%     plot_set.figure_title = 'Probe trials';
%     plot_set.xlabel = ' ';
%     plot_set.ylabel = 'Reaction time, ms';
%     
%     plot_set.legend{1} = 'Cued';
%     plot_set.legend{2} = 'Un-cued';
%     for i=1:numel(plot_set.legend{1})
%         plot_set.legend_y_coord(i) = 100;
%         plot_set.legend_x_coord(i) = plot_set.pbins(i);
%     end


