% Plot drift correction outcime

% Eye position for drift correction
sacc1 = var1.eye_data.saccades_EK;
saccraw1 = var2.eye_processed;
drift_output = var1.eye_data.drift_output;

% Time for drift calculations
time1 = var1.eyelink_events.(settings.drift_correction_time); % Time relative to which drift correction is done
t_start = time1 + settings.drift_correction_tstart; % Relative to time1 start checking for drift;
t_end = time1 + settings.drift_correction_tend; % Relative to time1 end checking for drift;

% Drift accuracy
a = var1.stim.(settings.drift_correction_window_max);
if iscell (a)
    amp_threshold = cell2mat(a);
elseif size(a,2)>1
    amp_threshold = a(:,4);
elseif size(a,2)==1
    amp_threshold = a;
end

%===============
% Dispersion of eye positions around the fixation

dist_mat_post = NaN(numel(sacc1),1);
x_mat_post = NaN(numel(sacc1),1);
y_mat_post = NaN(numel(sacc1),1);

 
for tid = 1:numel(saccraw1)
    
    sx1 = saccraw1{tid};
    
    if ~isnan(time1(tid))
        
        t1 = t_start(tid);
        t2 = t_end(tid);
        
        % Convert raw data into coordinates
        if length(sx1)>1
            
            % Select data samples within given time
            index1=sx1(:,1)>=t1 & sx1(:,1)<=t2;
            x1=sx1(index1,2);
            y1=sx1(index1,3);
            eyecoord1 = sqrt(x1.^2 + y1.^2); % Calculate amplitude of the eye position
            
            % Save output
            dist_mat_post(tid)=nanmean(eyecoord1);
            x_mat_post(tid)=nanmean(x1);
            y_mat_post(tid)=nanmean(y1);
        end
        
    end
end


%=================
%=================

% Set threhsold for plotting
plot_lim_x = max(amp_threshold);
plot_lim_y = max(amp_threshold);

%=============
%=============
% Plot 1

for i=1:2
    
    ind = strcmp(drift_output, 'drift on');
    if i==1
        h = subplot(2,3,1); hold on;
        t1 = [1:numel(sacc1)];
        t1 = t1(ind);
        x1 = var1.eye_data.drift_predrift_xy(ind,1);
        y1 = var1.eye_data.drift_predrift_xy(ind,2);
    elseif i==2
        h = subplot(2,3,4); hold on;
        t1 = [1:numel(sacc1)];
        t1 = t1(ind);
        x1 = x_mat_post(ind);
        y1 = y_mat_post(ind);
    end
    
    % Plot all trials
    if nansum(abs(x1))>0
        scatter(x1, y1, 1, t1);
        colormap (settings.color_map);
    end
    
    % Colormap ticks and labels
    a = length(t1); % Value to be used for bins
    bins_total = 5;
    bins_preset = [100, 250, 500, 1000, 2500, 5000];
    ind1 = find (a<=bins_preset);
    tick1 = [0 : bins_preset(ind1(1))/bins_total:bins_preset(ind1(1))];
    tick1 = round(tick1,0);
    
    caxis([0, a])
    hb = colorbar ('Limits', [0,a], 'Ticks', tick1);
    ylabel(hb,'Trial numbers', 'FontSize', settings.fontszlabel)
    axis equal
    
    % X & Y labels
    sacc1_x_label = 'X position';
    sacc1_y_label = 'Y position';
    xlabel (sacc1_x_label, 'FontSize', settings.fontszlabel)
    ylabel (sacc1_y_label, 'FontSize', settings.fontszlabel)
    
    % X & Y ticks
    x_tick =  [-2:2:2];
    y_tick = [-2:2:2];
    set(gca, 'XTick', x_tick);
    set(gca, 'YTick', y_tick);
    set(gca, 'XLim', [-plot_lim_x-plot_lim_x*0.1, plot_lim_x+plot_lim_x*0.1])
    set(gca, 'YLim', [-plot_lim_y-plot_lim_y*0.1, plot_lim_y+plot_lim_y*0.1])
    
    % Title
    if i==1
        title_text = 'Before drift';
    elseif i==2
        title_text = 'After drift';
    end
    title(title_text, 'FontSize', settings.fontszlabel)
    
end

%=================
%=================
% Plot 2

for i=1:2
    
    if i==1
        h = subplot(2,3,2); hold on;
        a_mat = var3.dist_mat;
    elseif i==2
        h = subplot(2,3,5); hold on;
        a_mat = dist_mat_post;
    end
    
    amp1 = amp_threshold; % Max axes value
    a_mat(a_mat>amp1) = max(amp1); % Clip axes
    
    % Plot all trials
    h = plot(a_mat, 'Color', settings.color1(1,:), 'LineWidth', settings.wlineerror);
    
    % Plot moving average
    b = movmedian(a_mat, settings.drift_correction_trials, 'omitnan');
    h = plot(1:length(b), b, 'LineWidth', settings.wlineerror, 'Color', settings.color1(2,:));
    
    % X & Y labels
    sacc1_x_label = 'Trial number';
    sacc1_y_label = 'Distance from disp center';
    xlabel (sacc1_x_label, 'FontSize', settings.fontszlabel)
    ylabel (sacc1_y_label, 'FontSize', settings.fontszlabel)
    
    % X ticks
    a = length(a_mat); % Value to be used for bins
    bins_total = 5;
    bins_preset = [100, 250, 500, 1000, 2500, 5000];
    ind1 = find (a<=bins_preset);
    tick1 = [0 : bins_preset(ind1(1))/bins_total:bins_preset(ind1(1))];
    tick1 = round(tick1,0);
    
    set(gca, 'XTick', tick1);
    set(gca, 'XLim', [0-a*0.1, a+a*0.1])
    
    % Y ticks
    amp1 = amp_threshold;
    a = max(amp1);
    bins_total = 4;
    bins_preset = [1, 2, 3, 4, 5, 10];
    ind1 = find (a<=bins_preset);
    tick1 = [0 : bins_preset(ind1(1))/bins_total:bins_preset(ind1(1))];
    tick1 = round(tick1,1);
    set(gca, 'YTick', tick1);
    set(gca, 'YLim', [-0.5, a+0.5])
    
    % Add legend
    text(100, a-a*0.1, 'Individual trials', 'Color', settings.color1(1,:),  'FontSize', settings.fontszlabel, 'HorizontalAlignment', 'left')
    text(100, a-a*0.2, 'Moving mean/median', 'Color', settings.color1(2,:),  'FontSize', settings.fontszlabel, 'HorizontalAlignment', 'left')

    
    
    % Title
    if i==1
        title_text = 'Before drift';
    elseif i==2
        title_text = 'After drift';
    end
    title(title_text, 'FontSize', settings.fontszlabel)
    
end


%=================
%=================
% Plot 3

for i=1:2
    
    if i==1
        h = subplot(2,3,3); hold on;
        a_mat = var3.dist_mat;
    elseif i==2
        h = subplot(2,3,6); hold on;
        a_mat = dist_mat_post;
    end
    
    amp1 = amp_threshold; % Max axes value
    a_mat(a_mat>amp1) = max(amp1); % Clip axes

    h = histogram(a_mat, 20, 'FaceColor', settings.color1(1,:), 'EdgeColor', settings.color1(1,:));
    
    sacc1_x_label = 'Fix deviation';
    sacc1_y_label = 'Trial counts';
    xlabel (sacc1_x_label, 'FontSize', settings.fontszlabel)
    ylabel (sacc1_y_label, 'FontSize', settings.fontszlabel)
    
    % Y ticks
    a = max(h.Values); % Value to be used for bins
    bins_total = 5;
    bins_preset = [100, 250, 500, 1000, 2500, 5000];
    ind1 = find (a<=bins_preset);
    tick1 = [0 : bins_preset(ind1(1))/bins_total : bins_preset(ind1(1))];
    tick1 = round(tick1,0);
    
    set(gca, 'YTick', tick1);
    set(gca, 'YLim', [0, a+a*0.1])
    
    % X ticks
    a = h.BinLimits(2);
    bins_total = 4;
    bins_preset = [1, 2, 3, 4, 5, 10];
    ind1 = find (a<=bins_preset);
    tick1 = [0 : bins_preset(ind1(1))/bins_total : bins_preset(ind1(1))];
    tick1 = round(tick1,1);
    
    set(gca, 'XTick', tick1);
    set(gca, 'XLim', [-0.5, a+0.5])
    
    % Title
    if i==1
        title_text = 'Before drift';
    elseif i==2
        title_text = 'After drift';
    end
    title(title_text, 'FontSize', settings.fontszlabel)
    
end

%=================
%=================
% Save figure

% % Save data
% plot_set.figure_size = settings.figure_size_temp;
% plot_set.figure_save_name = 'drift correction';
% plot_set.path_figure = path_fig;
% plot_helper_save_figure;
% 
% close all;


