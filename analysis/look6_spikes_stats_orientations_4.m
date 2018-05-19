%% Plot the data

error_code_current = 'correct';
texture_on_current = 1;


% Find time bin to plot
bin_ind = find(data1.mat3_plot_bins>100);
bin_ind = bin_ind(1);

% ==============
% Data
data_mat = struct;
data_mat.mat1_ini = data1.mat3_ini;
data_mat.var1{1} = S.esetup_background_texture_line_angle(:,2);
data_mat.var1_match{1} = orientations_used;
data_mat.var1{2} = S.esetup_block_cond;
data_mat.var1_match{2} = task_names_used;
data_mat.var1{3} = S.esetup_background_texture_on(:,1);
data_mat.var1_match{3} = texture_on_current;
data_mat.var1{4} = S.edata_error_code;
data_mat.var1_match{4} = error_code_current;
settings.bootstrap_on = 0;

[mat_y_ini, mat_y_upper_ini, mat_y_lower_ini, ~] = look6_helper_indexed_selection(data_mat, settings);

% =================
% Colors for the task

% Colors
c1 = NaN(numel(task_names_used), 1);
ind = strcmp(task_names_used, 'look');
if (sum(ind))==1
    c1(ind) = 1;
end
ind = strcmp(task_names_used, 'avoid');
if (sum(ind))==1
    c1(ind) = 2;
end
ind = strcmp(task_names_used, 'control fixate');
if (sum(ind))==1
    c1(ind) = 4;
end
c1_color1_temp = c1;
    
    
% ================
% Data fits

t1 = orientations_used';
or_radians = circ_axial(circ_ang2rad(t1),2);
temp1 = mat_y_ini;

% Output
temp1_output = cell(1, size(temp1,2), size(temp1,4));

for i = 1:size(temp1, 2)
    for j = 1:size(temp1, 4)
        
        % Data
        v1 = temp1(:,i,:,j);
        ydata = reshape(v1,1,numel(v1));
        xdata = or_radians;
        
        % Initialize params
        params = [0, 2, 200, 100];
        options.MaxFunctionEvaluations = 5000;
        options.MaxIterations = 5000;
        
        % Steinmetz & Moore, 2014
        if sum(isnan(ydata))<numel(ydata)
            fun = @(params,xdata) params(3) + params(4) * exp(params(2)*cos(xdata-params(1)))/(2*pi*besseli(0,params(2)));
            [x, fval] = lsqcurvefit(fun, params, xdata, ydata, [-pi, 0, 0, 0], [pi, 6, inf, inf], options);
            temp1_output{1,i,j} = x;
        end
        
    end
end

% Prepare line fits
temp1 =  mat_y_ini;
mat_x = or_radians;
mat_x_line = linspace(mat_x(1),mat_x(end));

m1 = numel(mat_x_line);
[m,n,o,p] = size(mat_y_ini);
mat_y = NaN(1,o,p);
mat_y_line = NaN(1, m1, p);
mat_y_lower = NaN(1,o,p);
mat_y_upper = NaN(1,o,p);

for j = 1:size(temp1_output,3)
    
    % Data
    i = bin_ind;
    v1 = mat_y_ini(:,i,:,j);
    mat_y(:,:,j) = reshape(v1,1,numel(v1));
    v1 = mat_y_lower_ini(:,i,:,j);
    mat_y_lower(:,:,j) = reshape(v1,1,numel(v1));
    v1 = mat_y_upper_ini(:,i,:,j);
    mat_y_upper(:,:,j) = reshape(v1,1,numel(v1));
    
    % Fits
    x = temp1_output{1,i,j};
    mat_y_line(:,:,j) = fun(x, mat_x_line);
    
end

%===================
% Is there any data to plot?
fig_plot_on = sum(sum(isnan(mat_y))) ~= numel(mat_y);


%% Plot 2

if fig_plot_on==1
    
    %===============
    % Panel 1, raw data
    
    % Initialize figure sub-panel
    current_subplot = current_subplot + 1;
    hfig = subplot(fig_subplot_dim(1), fig_subplot_dim(2), current_subplot);
    hold on;
    
    plot_set = struct;
    
    % Initialize structure with data
    plot_set.mat_y = mat_y;
    plot_set.mat_x = or_radians;
    plot_set.marker_shape{1} = 'o';
    plot_set.marker_shape{2} = 's';
    plot_set.marker_shape{3} = '>';
    plot_set.marker_only = 0;
    
    plot_set.data_color = c1_color1_temp;
    
    % Plot
    plot_helper_line_plot_v10;
    
    %==========
    % Part 2
    plot_set = struct;
    
    % Initialize structure with data
    plot_set.mat_y = mat_y_line;
    plot_set.mat_x = mat_x_line;
    
    plot_set.data_color = c1_color1_temp;
    
    % Labels for plotting
    plot_set.xlabel = 'Orientation (radians * 2)';
    plot_set.ylabel = 'Spikes/s';
    plot_set.figure_title = '100-250 ms after texture 2';
    
    % Plot
    plot_helper_line_plot_v10;
    
end

