
error_code_subset = cell(1); error_code_current = cell(1);
error_code_subset{1} = 'correct';
error_code_subset{2} = 'broke fixation';
error_code_subset{3} = 'looked at st2';

error_code_current{1} = 'correct';

texture_on_current = [1];

settings.int_bins = [0:100:2500];
settings.plot_bins=(settings.int_bins(1:end-1)+settings.int_bins(2:end))/2;

settings.figure_current = num_fig(fig1);
fprintf('\nPreparing figure %s out of %s total for this analysis\n', num2str(fig1), num2str(numel(num_fig))  )

%================
% Subplot 1
%================

%==============
% Data
data_mat = struct;
data_mat.mat1_ini = S.fixation_off - S.memory_on;
data_mat.mat1_bins = settings.int_bins;
data_mat.var1{1} = S.edata_error_code;
data_mat.var1_match{1} = error_code_subset;
data_mat.output = NaN(1, numel(data_mat.mat1_bins)-1, numel(data_mat.var1_match{1}));

for i = 1:numel(data_mat.mat1_bins)-1
    for j = 1:numel(data_mat.var1_match{1})
        
        % Text variable
        st1 = data_mat.var1_match{1}(j);
        
        % Index
        index = data_mat.mat1_ini >= data_mat.mat1_bins(i) & ...
            data_mat.mat1_ini < data_mat.mat1_bins(i+1) & ...
            strcmp (data_mat.var1{1}, st1);
        
        % Output
        data_mat.output(1,i,j) = sum(index);
        
    end
end

mat_y = data_mat.output;
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
    temp1 = hist(var1, settings.int_bins);
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
    hist(var1, settings.int_bins);
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
    plot_set.mat_y = data_mat.output;
    plot_set.mat_x = settings.plot_bins;
    
    % Labels for plotting
    plot_set.xlabel = 'Memory delay, ms';
    plot_set.ylabel = 'No of trials';
    plot_set.legend = error_code_subset;
    plot_set.ylim = fig_lim;
    
    % Plot
    plot_helper_basic_line_figure;
    
end