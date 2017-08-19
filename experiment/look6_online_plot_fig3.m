% ONLINE data figure
% Recalculates from pixels back to degrees - however it's easy to plot
% everythng in raw data (pixels).


%================
% Plot fixation BEFORE drift correction
%================

if ~isnan(expsetup.stim.edata_fixation_on(tid))
    
    % Radius & window
    [fix_xc, fix_yc] = RectCenter(fixation_rect);
    x1=fix_xc-expsetup.screen.dispcenter(1); y1=fix_yc-expsetup.screen.dispcenter(2);
    x1=x1/expsetup.screen.deg2pix; y1=y1/expsetup.screen.deg2pix; % Convert to degrees
    eyecoord1 = sqrt(x1.^2 + y1.^2); % Calculate amplitude of the eye position
    radius1 = eyecoord1;
    if expsetup.stim.esetup_fixation_drift_correction_on(tid)==1
        saccwindow = expsetup.stim.esetup_fixation_size_drift(tid,4);
    else
        saccwindow = expsetup.stim.esetup_fixation_size_eyetrack(tid,4);
    end
    
    % Plot fixation before it was acquired
    starttime1 = expsetup.stim.edata_fixation_on(tid) - expsetup.stim.edata_first_display(tid);
    starttime1 = starttime1*1000;
    if ~isnan(expsetup.stim.edata_fixation_acquired(tid))
        trialdur = expsetup.stim.edata_fixation_acquired(tid) - expsetup.stim.edata_fixation_on(tid);
        trialdur = trialdur*1000;
    elseif ~isnan(expsetup.stim.edata_fixation_off(tid))
        trialdur = expsetup.stim.edata_fixation_off(tid) - expsetup.stim.edata_fixation_on(tid); % Convert to seconds
        trialdur = trialdur*1000;
    end
    h=rectangle('Position', [starttime1, radius1-saccwindow, trialdur, saccwindow*2],...
        'EdgeColor', [0.85, 0.85, 0.85],  'FaceColor', [0.85, 0.85, 0.85], 'Curvature', 0, 'LineWidth', 1);
    
    % Plot fixation after it was acquired, during drift correction
    if ~isnan(expsetup.stim.edata_fixation_drift_maintained(tid))
        starttime1 = expsetup.stim.edata_fixation_acquired(tid) - expsetup.stim.edata_first_display(tid);
        starttime1 = starttime1*1000;
        trialdur = expsetup.stim.edata_fixation_drift_maintained(tid) - expsetup.stim.edata_fixation_acquired(tid);
        trialdur = trialdur*1000;
        h=rectangle('Position', [starttime1, radius1-saccwindow, trialdur, saccwindow*2],...
            'EdgeColor', [0.65, 0.65, 0.65],  'FaceColor', [0.65, 0.65, 0.65], 'Curvature', 0, 'LineWidth', 1);
    end
    
end

%================
% Plot fixation AFTER drift correction
%===============

if ~isnan(expsetup.stim.edata_fixation_drift_maintained(tid))
    
    % Radius & window
    [fix_xc, fix_yc] = RectCenter(fixation_rect);
    x1=fix_xc-expsetup.screen.dispcenter(1); y1=fix_yc-expsetup.screen.dispcenter(2);
    x1=x1/expsetup.screen.deg2pix; y1=y1/expsetup.screen.deg2pix; % Convert to degrees
    eyecoord1 = sqrt(x1.^2 + y1.^2); % Calculate amplitude of the eye position
    radius1 = eyecoord1;
    saccwindow = expsetup.stim.esetup_fixation_size_eyetrack(tid,4);
    
    % Plot fixation
    if ~isnan(expsetup.stim.edata_fixation_off(tid))
        starttime1 = expsetup.stim.edata_fixation_drift_maintained(tid) - expsetup.stim.edata_first_display(tid);
        starttime1 = starttime1*1000;
        trialdur = expsetup.stim.edata_fixation_off(tid) - expsetup.stim.edata_fixation_drift_maintained(tid);
        trialdur = trialdur*1000;
        h=rectangle('Position', [starttime1, radius1-saccwindow, trialdur, saccwindow*2],...
            'EdgeColor', [1, 0.8, 0.8],  'FaceColor', [1, 0.8, 0.8], 'Curvature', 0, 'LineWidth', 1);
    end
    
end

%==========================
% Plot saccade target onset
%=========================

if ~isnan(expsetup.stim.edata_st1_on(tid)) && ~isnan(expsetup.stim.edata_st1_off(tid))
    
    % Radius & window
    [fix_xc, fix_yc] = RectCenter(st1_rect);
    x1=fix_xc-expsetup.screen.dispcenter(1); y1=fix_yc-expsetup.screen.dispcenter(2);
    x1=x1/expsetup.screen.deg2pix; y1=y1/expsetup.screen.deg2pix; % Convert to degrees
    eyecoord1 = sqrt(x1.^2 + y1.^2); % Calculate amplitude of the eye position
    radius1 = eyecoord1;
    saccwindow = expsetup.stim.esetup_target_size_eyetrack(tid,4);
    
    % Plot saccade target
    starttime1 = expsetup.stim.edata_st1_on(tid) - expsetup.stim.edata_first_display(tid);
    starttime1 = starttime1*1000;
    trialdur = expsetup.stim.edata_st1_off(tid) - expsetup.stim.edata_st1_on(tid);
    trialdur = trialdur*1000;
    h=rectangle('Position', [starttime1, radius1-saccwindow, trialdur, saccwindow*2],...
        'EdgeColor', [1, 0.5, 0.5], 'FaceColor', [1, 0.5, 0.5], 'Curvature', 0, 'LineWidth', 1);
    text(starttime1, -3, 'ST1', 'Color', [1, 0.5, 0.5],  'FontSize', fontszlabel, 'HorizontalAlignment', 'left')

end

%==========================
% Plot distractor
%=========================

if ~isnan(expsetup.stim.edata_st2_on(tid)) && ~isnan(expsetup.stim.edata_st2_off(tid))
    
    % Radius & window
    [fix_xc, fix_yc] = RectCenter(st2_rect);
    x1=fix_xc-expsetup.screen.dispcenter(1); y1=fix_yc-expsetup.screen.dispcenter(2);
    x1=x1/expsetup.screen.deg2pix; y1=y1/expsetup.screen.deg2pix; % Convert to degrees
    eyecoord1 = sqrt(x1.^2 + y1.^2); % Calculate amplitude of the eye position
    radius1 = eyecoord1;
    saccwindow = expsetup.stim.esetup_target_size_eyetrack(tid,4);
    
    % Plot saccade target
    starttime1 = expsetup.stim.edata_st2_on(tid) - expsetup.stim.edata_first_display(tid);
    starttime1 = starttime1*1000;
    trialdur = expsetup.stim.edata_st2_off(tid) - expsetup.stim.edata_st2_on(tid);
    trialdur = trialdur*1000;
    h=rectangle('Position', [starttime1, radius1-saccwindow, trialdur, saccwindow*2],...
        'EdgeColor', [0.7, 0.1, 0.1], 'FaceColor', 'none', 'Curvature', 0, 'LineWidth', 1);
    text(starttime1, -5, 'ST2', 'Color', [0.7, 0.1, 0.1],  'FontSize', fontszlabel, 'HorizontalAlignment', 'left')
        
end

%==========================
% Plot memory target
%==========================

if ~isnan(expsetup.stim.edata_memory_on(tid))
    
    % Radius & window
    [fix_xc, fix_yc] = RectCenter(memory_rect);
    x1=fix_xc-expsetup.screen.dispcenter(1); y1=fix_yc-expsetup.screen.dispcenter(2);
    x1=x1/expsetup.screen.deg2pix; y1=y1/expsetup.screen.deg2pix; % Convert to degrees
    eyecoord1 = sqrt(x1.^2 + y1.^2); % Calculate amplitude of the eye position
    radius1 = eyecoord1;
    saccwindow = expsetup.stim.esetup_target_size_eyetrack(tid,4);
    
    % Plot saccade target
    starttime1 = expsetup.stim.edata_memory_on(tid) - expsetup.stim.edata_first_display(tid);
    starttime1 = starttime1*1000;
    if ~isnan(expsetup.stim.edata_memory_off(tid))
        trialdur = expsetup.stim.edata_memory_off(tid) - expsetup.stim.edata_memory_on(tid);
        trialdur = trialdur*1000;
    elseif isnan(expsetup.stim.edata_memory_off(tid))
        trialdur = expsetup.stim.esetup_memory_duration(tid);
        trialdur = trialdur*1000;
    end
    h=rectangle('Position', [starttime1, radius1-saccwindow, trialdur, saccwindow*2],...
        'EdgeColor', [0.4, 0.4, 1],  'FaceColor', 'none', 'Curvature', 0, 'LineWidth', 1);
    text(starttime1, -1, 'M', 'Color', [0.4, 0.4, 1],  'FontSize', fontszlabel, 'HorizontalAlignment', 'left')
    
end
    
%====================
% Plot reward timing
if ~isnan(expsetup.stim.edata_reward_on(tid))
    yc = 0;
    saccwindow = 1;
    starttime1 = expsetup.stim.edata_reward_on(tid) - expsetup.stim.edata_first_display(tid);
    starttime1 = starttime1*1000;
    trialdur = expsetup.stim.edata_reward_size_ms(tid);
    h=rectangle('Position', [starttime1, yc-saccwindow, trialdur, saccwindow],...
        'EdgeColor', [0.2, 0.2, 0.5], 'FaceColor', 'none', 'Curvature', 0, 'LineWidth', 1);
    text(starttime1, 2, 'Reward', 'Color', [0.2, 0.2, 0.5],  'FontSize', fontszlabel, 'HorizontalAlignment', 'left')
end

%==============
% Plot eye position data
%==============

% Eye position
sx2 = [expsetup.stim.eframes_time{tid}, expsetup.stim.eframes_eye_x{tid}, expsetup.stim.eframes_eye_y{tid}]; % Data to be used
sx2(:,1) = sx2(:,1) - sx2(1,1); % Reset time to 0
sx2(:,1) = sx2(:,1) * 1000; % Convert to miliseconds
ind=sx2(:,2)==0; % Replace zeros (no recording)
sx2(ind,2)=NaN; sx2(ind,3)=NaN; % Replace zeros
% Convert to degrees
x1=sx2(:,2)-expsetup.screen.dispcenter(1); y1=sx2(:,3)-expsetup.screen.dispcenter(2);
x1=x1./expsetup.screen.deg2pix; y1=y1./expsetup.screen.deg2pix;

% Plot eye position
if size(sx2,1)>1
    eyecoord1 = sqrt(x1.^2 + y1.^2); % Calculate amplitude of the eye position
    h=plot(sx2(:,1), eyecoord1, 'k', 'LineWidth', 1); % Plot eye position in space and time
end

% %=================
% Fig settings

set (gca,'FontSize', fontsz);

% Set the legend
text(0, 13, expsetup.stim.edata_error_code{tid}, 'Color', color1(1,:), 'FontSize', fontszlabel, 'HorizontalAlignment', 'left')

% Y axis
eyecoord1=[0, 5, 10, 15];
set(gca,'YTick',eyecoord1);

set(gca,'YLim',[-6.5, 16]);
ylabel ('Gaze position, deg', 'FontSize', fontszlabel)

% X axis
if ~isnan(expsetup.stim.edata_memory_on(tid)) && ~isnan(expsetup.stim.edata_st1_on(tid))
    set(gca,'XTick', [0, ...
        round(  (expsetup.stim.edata_memory_on(tid) - expsetup.stim.edata_first_display(tid)) * 1000   ),...
        round(  (expsetup.stim.edata_st1_on(tid) - expsetup.stim.edata_first_display(tid)) * 1000  ),...
        round(  (expsetup.stim.edata_loop_over(tid) - expsetup.stim.edata_first_display(tid)) * 1000  )  ]);
else
    set(gca,'XTick', [0, round(   (expsetup.stim.edata_loop_over(tid)- expsetup.stim.edata_first_display(tid)) * 1000  ) ]);
end
a1 = (expsetup.stim.edata_loop_over(tid) - expsetup.stim.edata_first_display(tid)) * 1000;
set(gca,'XLim',[-250,a1+250]);
xlabel ('Time from trial start (ms)', 'FontSize', fontszlabel)

