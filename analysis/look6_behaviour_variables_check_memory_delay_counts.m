

%================
% Subplot 1
%================

error_code_current = cell(1);
error_code_current{1} = 'correct';
texture_on_current = [1];

settings.bin_length = 100;
settings.int_bins_start = [0:100:2500];
settings.int_bins_end = settings.int_bins_start + settings.bin_length;
settings.plot_bins = (settings.int_bins_start+settings.int_bins_end)/2;

% Y limits

%==============
% Data
data_mat = struct;
data_mat.mat1_ini = S.fixation_off - S.memory_on;
data_mat.mat1_ini_bin_start = settings.int_bins_start;
data_mat.mat1_ini_bin_end = settings.int_bins_end;
data_mat.var1{1} = S.edata_error_code;
data_mat.var1_match{1} = error_code_subset;

[data_mat] = look6_helper_indexed_selection_behaviour(data_mat, settings);


mat_y = data_mat.mat_y;
fig_plot_on = sum(sum(isnan(mat_y))) ~= numel(mat_y);

if fig_plot_on == 1
    
    hfig = subplot(fig_subplot_dim(1), fig_subplot_dim(2), 1);
    hold on;
    fprintf('\n%s %s: preparing panel with memory delays\n', settings.subject_current, num2str(settings.date_current));
    
    %==============
    % histogram
    %==============
    
    plot_set = struct;
    
    % Add histogram
    var1 = S.esetup_memory_delay*1000;
    temp1 = hist(var1, settings.int_bins_start);
    plot_set.ylim = [min(temp1), max(temp1)];
    
    % Calculate axis limits
    % Add buffer on the axis
    val1_min = 0.05;
    val1_max = 0.05;
    h0_min = plot_set.ylim(1);
    h0_max = plot_set.ylim(2);
    plot_set.ylim(1) = h0_min - ((h0_max - h0_min) * val1_min);
    plot_set.ylim(2) = h0_max + ((h0_max - h0_min) * val1_max);
    
    fig_lim = plot_set.ylim;
    
    % Plot histogram;
    hist(var1, settings.int_bins_start);
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor',[0.7 0.9 0.7],'EdgeColor','w')
    
    %=============
    % Line figures
    %=============
    
    plot_set = struct;
    
    % Colors
    plot_set.data_color = NaN(1, numel(error_code_subset));
    ind1 = strcmp(error_code_subset, 'correct');
    if ~isempty(ind1)
        plot_set.data_color(ind1) = [11];
    end
    ind1 = strcmp(error_code_subset, 'broke fixation');
    if ~isempty(ind1)
        plot_set.data_color(ind1) = [12];
    end
    ind1 = strcmp(error_code_subset, 'looked at st2');
    if ~isempty(ind1)
        plot_set.data_color(ind1) = [13];
    end
    
    % Figure title
    plot_set.figure_title = sprintf('Memory delay durations');
    
    %===============
    % Averages data
    % Initialize structure with data
    plot_set.mat_y = data_mat.trial_counts;
    plot_set.mat_x = settings.plot_bins;
    
    % Labels for plotting
    plot_set.xlabel = 'Memory delay, ms';
    plot_set.ylabel = 'No of trials';
    plot_set.legend = error_code_subset;
    plot_set.ylim = fig_lim;
    
    % Plot
    plot_helper_basic_line_figure;
    
end