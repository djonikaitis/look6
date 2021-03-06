close all;

error_code_current = 'correct';
texture_on_current = 1;

i_fig1 = 0;
fig_subplot_dim = [1,numel(task_names_used) + 1];
fig_size = [0, 0, fig_subplot_dim(2) * settings.figsize_1col(3), fig_subplot_dim(1) * settings.figsize_1col(4)];

% Convert axial data to radial
t1 = orientations_used';
or_radians = circ_axial(circ_ang2rad(t1),2);

%%  Calculate axis limits

%==============
% Data
data_mat = struct;
data_mat.mat1_ini = mat3_ini;
data_mat.var1{1} = S.memory_angle;
data_mat.var1_match{1} = memory_angles_used;
data_mat.var1{2} = S.esetup_block_cond;
data_mat.var1_match{2} = task_names_used;
data_mat.var1{3} = S.esetup_background_texture_line_angle(:,1);
data_mat.var1_match{3} = orientations_used;
data_mat.var1{4} = S.esetup_background_texture_on(:,1);
data_mat.var1_match{4} = texture_on_current;
data_mat.var1{5} = S.edata_error_code;
data_mat.var1_match{5} = error_code_current;
settings.bootstrap_on = 0;

[mat_y_ini, mat_y_upper_ini, mat_y_lower_ini, ~] = look6_helper_indexed_selection(data_mat, settings);

%===============
% Y limits
% Reshape matrixes to know numbers of trials
[m,n,o,q,r,s] = size(mat_y_upper_ini);
a = reshape(mat_y_lower_ini, m, n, o*q*r*s);
b = reshape(mat_y_upper_ini, m, n, o*q*r*s);

% Initialize structure with data
plot_set = struct;
plot_set.ebars_lower_y = a;
plot_set.ebars_upper_y = b;
look6_helper_data_limits;

% Add buffer on the axis
val1_min = 0.05;
val1_max = 0.05;
h0_min = plot_set.ylim(1);
h0_max = plot_set.ylim(2);
plot_set.ylim(1) = h0_min - ((h0_max - h0_min) * val1_min);
plot_set.ylim(2) = h0_max + ((h0_max - h0_min) * val1_max);

% Save output
all_fig_y_lim = plot_set.ylim;


%% Fit data

temp1 = round(mat_y_ini);

% Data fitting
temp1_output = cell(1, size(temp1,3), size(temp1,4));

for i = 1:size(temp1, 3)
    for j = 1:size(temp1, 4)
        
        % Data
        v1 = temp1(:,:,i,j,:);
        ydata = reshape(v1,1,numel(v1));
        xdata = or_radians;

        % Remove NaN values
        index = isnan(ydata);
        ydata(index) = [];
        xdata(index) = [];
        
        % Initialize params
        params = [0, 2, 200, 100];
        options.MaxFunctionEvaluations = 5000;
        options.MaxIterations = 5000;
        
        % Steinmetz & Moore, 2014
        if numel(ydata)>3
            fun = @(params,xdata) params(3) + params(4) * exp(params(2)*cos(xdata-params(1)))/(2*pi*besseli(0,params(2)));
            [x, fval] = lsqcurvefit(fun, params, xdata, ydata, [-pi, 0, 0, 0], [pi, 6/2, inf, inf], options);
            temp1_output{1,i,j} = x;
        end
        
    end
end


%%  Restructure data matrices

temp1 = round(mat_y_ini);
mat_x = or_radians;
mat_x_line = linspace(mat_x(1),mat_x(end));

[m,n,o,p,s] = size(mat_y_ini);
m1 = numel(mat_x_line);

mat_y = NaN(1,s,o,p);
mat_y_lower = NaN(1,s,o,p);
mat_y_upper = NaN(1,s,o,p);
mat_y_line = NaN(1, m1, o, p);

for i_task = 1:numel(task_names_used)
    
    for i_loc = 1:numel(memory_angles_relative_used)
        
        % Data
        v1 = temp1(:,:,i_loc,i_task,:);
        mat_y(:,:,i_loc,i_task) = reshape(v1,1,numel(v1));
        
        % Fits
        x = temp1_output{1,i_loc,i_task};
        if ~isempty(x)
        mat_y_line(:,:,i_loc,i_task) = fun(x, mat_x_line);
        end
        
    end
    
end


for i_task = 1:numel(task_names_used)
    
    %================
    % Is there any data to plot?
    fig_plot_on = sum(sum(sum(isnan(mat_y)))) ~= numel(mat_y);
    
    if fig_plot_on==1
        
        task_name_current = task_names_used{i_task};
        fprintf('\n%s: preparing panel for the "%s" task \n', settings.neuron_name, task_name_current)
        i_fig1 = i_fig1+1;
        hfig = subplot(fig_subplot_dim(1), fig_subplot_dim(2), i_fig1);
        hold on;
        
        plot_set = struct;
        
        % Initialize structure with data
        plot_set.mat_y = mat_y(:,:,:,i_task);
        plot_set.mat_x = mat_x;
        plot_set.marker_shape{1} = 'o';
        plot_set.marker_shape{2} = 's';
        plot_set.marker_shape{3} = '^';
        plot_set.marker_shape{4} = '>';
        plot_set.marker_only = 1;
        % %     plot_set.ebars_lower_y = mat_y_lower;
        % %     plot_set.ebars_upper_y = mat_y_upper;
        % %     plot_set.ebars_shade = 1;
        
        % Colors
%         if strcmp(task_name_current, 'look')
            plot_set.data_color_min = [1];
%         elseif strcmp(task_name_current, 'avoid')
%             plot_set.data_color_min = [2];
%         elseif strcmp(task_name_current, 'control fixate')
%             plot_set.data_color_min = [4];
%         else
%             plot_set.data_color = [0.1, 0.1, 0.1];
%         end
        plot_set.data_color_max = 10;
        
        % Plot
        plot_helper_line_plot_v10;
        
        
    end
    
    %================
    % Is there any data to plot?
    fig_plot_on = sum(sum(sum(isnan(mat_y_line)))) ~= numel(mat_y_line);
    
    if fig_plot_on==1
        
        plot_set = struct;
        
        % Initialize structure with data
        plot_set.mat_y = mat_y_line(:,:,:,i_task);
        plot_set.mat_x = mat_x_line;
        % %     plot_set.ebars_lower_y = mat_y_lower;
        % %     plot_set.ebars_upper_y = mat_y_upper;
        % %     plot_set.ebars_shade = 1;
        
        % Colors
        plot_set.data_color_min = [1];
        plot_set.data_color_max = [10];
        
        % Labels for plotting
        plot_set.xlabel = 'Orientation (radians * 2)';
        plot_set.ylabel = 'Spikes/s';
        plot_set.figure_title = task_names_used{i_task};
        
        % Plot
        plot_helper_line_plot_v10;
        
        
    end
    
    %===============
    % Plot inset with legend
    if fig_plot_on == 1 && i_task==1
        
        axes('Position',[0.02,0.85,0.08,0.08])
        
        axis 'equal'
        set (gca, 'Visible', 'off')
        hold on;
        
        % Plot circle radius
        cpos1 = [0,0];
        ticks1 = [1];
        cl1 = [0.5,0.5,0.5];
        for i=1:length(ticks1)
            h=rectangle('Position', [cpos1(1,1)-ticks1(i), cpos1(1,2)-ticks1(i), ticks1(i)*2, ticks1(i)*2],...
                'EdgeColor', cl1, 'FaceColor', 'none', 'Curvature', 1, 'LineWidth', 0.5, 'LineStyle', '-');
        end
        
        % Plot fixation dot
        cpos1 = [0,0];
        ticks1 = [0.1];
        cl1 = [0.5,0.5,0.5];
        for i=1:length(ticks1)
            h=rectangle('Position', [cpos1(1,1)-ticks1(i), cpos1(1,2)-ticks1(i), ticks1(i)*2, ticks1(i)*2],...
                'EdgeColor', cl1, 'FaceColor', cl1, 'Curvature', 1, 'LineWidth', 0.5, 'LineStyle', '-');
        end
        
        % Initialize data values for plotting
        for i=1:length(memory_angles_used)
            
            % Color
            graphcond = i;
            
            % Find coordinates of a line
            f_rad = 1;
            f_arc = memory_angles_used(i);
            [xc,yc] = pol2cart(f_arc*pi/180, f_rad);
            objsize = 0.7;
            
            % Plot cirlce
            h=rectangle('Position', [xc(1)-objsize(1)/2, yc(1)-objsize(1)/2, objsize(1), objsize(1)],...
                'EdgeColor', plot_set.main_color(i,:), 'FaceColor', plot_set.main_color(i,:),'Curvature', 0, 'LineWidth', 1);
            
        end
        
%         % Cue location
%         m = find(memory_angles_used==0);
%         if numel(m)>1
%             m=m(1);
%         end
%         text(0, -2, 'Cue in RF', 'Color', plot_set.main_color(m,:),  'FontSize', settings.font_size_label, 'HorizontalAlignment', 'center');
%         
    end
    %==============
    % End of inset
    

    
end


%
%     for i_fig2 = 1:numel(memory_angles_used)
%
%         memory_angle_current = memory_angles_used(i_fig2);
%
%         %==============
%         % Data
%         data_mat = struct;
%         data_mat.mat1_ini = mat1_ini;
%         data_mat.var1{1} = S.esetup_background_texture_line_angle(:,1);
%         data_mat.var1_match{1} = orientations_used;
%         data_mat.var1{2} = S.esetup_block_cond;
%         data_mat.var1_match{2} = task_name_current;
%         data_mat.var1{3} = S.memory_angle;
%         data_mat.var1_match{3} = memory_angle_current;
%         data_mat.var1{4} = S.esetup_background_texture_on(:,1);
%         data_mat.var1_match{4} = texture_on_current;
%         data_mat.var1{5} = S.edata_error_code;
%         data_mat.var1_match{5} = error_code_current;
%         settings.bootstrap_on = 0;
%
%         [mat_y, mat_y_upper, mat_y_lower, ~] = look6_helper_indexed_selection(data_mat, settings);
%
%         %================
%         % Is there any data to plot?
%         fig_plot_on = sum(sum(isnan(mat_y))) ~= numel(mat_y);
%
%         if fig_plot_on == 1 % Decide whether to bother initializing a panel
%
%             % Initialize figure sub-panel
%             a = i_fig1 * (fig_subplot_dim(2)) - (fig_subplot_dim(2));
%             b = a + i_fig2;
%             hfig = subplot(fig_subplot_dim(1), fig_subplot_dim(2), b);
%             hold on;
%             fprintf('\n%s: preparing panel for memory location "%s", "%s" task \n', settings.neuron_name, num2str(memory_angle_current), task_name_current);
%
%             plot_set = struct;
%
%             %===============
%             % Averages data
%             % Initialize structure with data
%             plot_set.mat_y = mat_y;
%             plot_set.mat_x = settings.plot_bins;
%             plot_set.ebars_lower_y = mat_y_lower;
%             plot_set.ebars_upper_y = mat_y_upper;
%             plot_set.ebars_shade = 1;
%
%             plot_set.ylim = all_fig_y_lim;
%
%             % Colors
%             plot_set.data_color_min = [23];
%             plot_set.data_color_max = [21];
%
% %             % Labels for plotting
% %             if extended_title == 0
% %                 plot_set.xlabel = 'Time after cue, ms';
% %                 plot_set.ylabel = 'Firing rate, Hz';
% %             end
% %
% % %             % Figure title
% %             if extended_title==0
% %                 plot_set.figure_title = sprintf('%s, loc %s', task_name_current, num2str(memory_angle_current));
% %                 extended_title = 1;
% %             else
% %                 plot_set.figure_title = sprintf('Location %s deg', num2str(memory_angle_current));
% %             end
%
%             % Plot
%             plot_helper_line_plot_v10;
%
%         end
%         % End of decision whether to plot data
%     end
%     % End of each location
%
% end
% % End of each condition (look etc)





%==========
% Save data
%==========

if ~isnan(all_fig_y_lim(1)) && ~isnan(all_fig_y_lim(2))

    plot_set.figure_size = fig_size;
    plot_set.figure_save_name = sprintf ('%s_fig%s', settings.neuron_name, num2str(settings.figure_current));
    plot_set.path_figure = path_fig;

    plot_helper_save_figure;
    close all;

end