% Prepare matrix with spiking rates

% plot_var1 = 'texture';
% plot_var1 = 'memory';

fig_color = [9,10]; % Colors used for the figure

% Select appropriate interval for plottings
time_step = 50;
bin_length = 100;
int_bins = [0:time_step:5000];

dat1 = expsetup.stim.edata_first_display(tid); % Data to which reset spiking rates
 
%===========
% Initialize data matrix
if tid == 1
    % Initialize empty matrix
    spikes_matrix_2 = NaN(1, length(int_bins), numel(sp_struct.spikes));
else
    % Increase matrix size
    [a,b,c,d] = size(spikes_matrix_2);
    t1 = NaN(a+1, b, c, d);
    t1(1:a, 1:b, 1:c, 1:d) = spikes_matrix_2;
    spikes_matrix_2 = t1;
end

%==============
% Determine whether data was accepted
if ~isnan(expsetup.stim.edata_memory_off(tid))
    cond1 = 1;
else
    cond1 = -1; % Rejected trial, not analysed
end

% Time in miliseconds;
if cond1>0
    cond1_t = (dat1 - expsetup.stim.edata_first_display(tid)) * 1000;
end

% Take spikes and reset them relative to appropriate time
if cond1>0
    sp1 = cell(numel(sp_struct.spikes), 1);
    for i = 1:numel(sp_struct.spikes)
        sp1{i} = sp_struct.spikes{i} - sp_struct.trial_start;
        sp1{i} = sp1{i}/expsetup.general.plex_data_rate; % Convert from sampling rate to time
        sp1{i} = sp1{i}*1000; % Reset to miliseconds
        sp1{i} = sp1{i} - cond1_t; % Reset relative to condition time
    end
end

% Calculate spiking rates
if cond1>0
    for i = 1:numel(sp1)
        for j = 1:length(int_bins)
            
            % Index
            index = sp1{i} >= int_bins(j) & ...
                sp1{i} <= int_bins(j) + bin_length;
            % Save data
            if sum(index)==0
                spikes_matrix_2(tid,j,i)=0; % Save as zero spikes
            elseif sum(index)>0
                spikes_matrix_2(tid,j,i) = sum(index) * (1000/bin_length); % Save spikes converted to firing rate
            end
        end
    end
end

% Initialize pbins
pbins=int_bins+bin_length/2;


%% Figure


% Find axis limits

if cond1>0
    h_1 = []; h_2 = [];
    for k = 1
        % Select data
        ind = tid;
        mat1 = spikes_matrix_2(ind,:,sp_struct.ch1);
        if size(mat1,1)>1
            h_1(k) = max(nanmean(mat1));
            h_2(k) = min(nanmean(mat1));
        elseif size(mat1,1)==1
            h_1(k) = max(mat1);
            h_2(k) = min(mat1);
        else
            h_1(k) = NaN;
            h_2(k) = NaN;
        end
        
        h_1 = max(h_1);
        h_2 = min(h_2);
        h_max=h_1+((h_1-h_2)*0.2); % Upper bound
        h_min=h_2-((h_1-h_2)*0.2); % Lower bound
        if h_max == h_min
            h_max = h_max+1;
            h_min = h_min-1;
        end
    end
else
    h_max = 1;
    h_min = -1;
end

%===============
% Plot texture onset
%===============

if cond1>0
    if expsetup.stim.esetup_background_texture_on(tid)==1
    % Psychtoolbox trial duration
    b = ( expsetup.stim.edata_texture_on(tid) - expsetup.stim.edata_first_display(tid) )*1000;
    rectangle ('Position', [b, h_min, 25, h_max-h_min], ...
        'FaceColor', [0.9, 0.9, 0.9], 'EdgeColor', 'none');
    text(b, h_min+((h_max-h_min)*0.1), 'Texture', 'Color', [0.2, 0.2, 0.2],  'FontSize', fontszlabel, 'HorizontalAlignment', 'left')
    end
end

%===============
% Plot memory delay
%===============

if cond1>0
    if ~isnan(expsetup.stim.edata_memory_off(tid))
        b = (expsetup.stim.edata_memory_on(tid) - expsetup.stim.edata_first_display(tid) )*1000;
        dur1 = (expsetup.stim.edata_memory_off(tid) - expsetup.stim.edata_memory_on(tid) ) * 1000;
        rectangle ('Position', [b, h_min, dur1, h_max-h_min], ...
            'FaceColor', [0.85, 0.85, 0.9], 'EdgeColor', 'none')
        text(b, h_min+((h_max-h_min)*0.05), 'Memory', 'Color',  [0.55, 0.55, 0.9],  'FontSize', fontszlabel, 'HorizontalAlignment', 'left')
    end
end

%===============
% Plot raw firing rate and probe onset timing
%===============

if cond1>0
    % Select data
    ind = tid;
    mat1 = spikes_matrix_2(ind,:,sp_struct.ch1);
    
    % Plot lines
    if size(mat1,1)>0
        if size(mat1,1)>1
            h=plot(pbins, nanmean(mat1(:,:,1)));
        elseif size(mat1,1)==1
            h=plot(pbins, mat1(1,:,1));
        end
        set (h(end), 'LineWidth', wlinegraph, 'Color', color1(9,:))
    end
end

%===============
% Plot trial end
%===============

if cond1>0
    % Plexon trial duration
    a = ( (sp_struct.trial_end-sp_struct.trial_start)/expsetup.general.plex_data_rate )*1000;
    rectangle ('Position', [a, h_min, 50, h_max-h_min], ...
        'FaceColor', [1, 0.8, 0.8], 'EdgeColor', 'none');
    % Psychtoolbox trial duration
    b = (expsetup.stim.edata_st1_off(tid) - expsetup.stim.edata_first_display(tid) )*1000;
    rectangle ('Position', [b, h_min, 25, h_max-h_min], ...
        'FaceColor', [1, 0.2, 0.2], 'EdgeColor', 'none');
    text(b, h_min+((h_max-h_min)*0.15), 'Trial ends', 'Color', [0.5, 0.1, 0.1],  'FontSize', fontszlabel, 'HorizontalAlignment', 'right')

    % Figure settings
    if a>b
        set(gca,'XLim',[-99, a+a*0.1]);
    else
        set(gca,'XLim',[-99, b+b*0.1]);
    end
end




%=============
% Figure setup
%=============

if cond1>0
    
    set (gca,'FontSize', fontszlabel);
    
    % X labels
    b = (expsetup.stim.edata_fixation_off(tid) - expsetup.stim.edata_first_display(tid))*1000;
    if b<500
        a=[0:100:500];
    elseif b<1000
        a=[0:200:1000];
    elseif b<2500
        a=[0:500:2500];
    elseif b<5000
        a=[0:1000:5000];
    else
        a=[0:2500:10000];
    end
    set(gca,'XTick',a);
    xlabel ('Time from trial start (ms)', 'FontSize', fontszlabel);
    
    
    % Set Y labels
    if h_max<50
        a=[0:10:50];
    elseif h_max<100
        a=[0:20:100];
    elseif h_max<250
        a=[0:50:250];
    elseif h_max<500
        a=[0:100:500];
    else
        a=[0:250:1500];
    end
    set(gca,'YTick', a);
    ylabel ('spikes/second', 'FontSize', fontszlabel);
    
    if h_min~=h_max
        set(gca,'YLim', [h_min, h_max]);
    else
        set(gca,'YLim', [-1, 1]);
    end
   
else
    a = [0];
    set(gca,'XTick',a);
    xlabel ('Time from trial start (ms)', 'FontSize', fontszlabel);
    set(gca,'YTick', a);
    ylabel ('spikes/second', 'FontSize', fontszlabel);
    set(gca,'YLim', [h_min, h_max]);
end

% Add channel number info
if cond1>0
    
    d1 = h_max-h_min;
    x1 = [pbins(1)]; y1 = [h_max-d1*0.05];
    k = 1;
    
    % Plot legend text
    l1 = sprintf('Channel %d', sp_struct.ch1);
    text(x1(k), y1(k), l1, 'Color', color1(k,:),  'FontSize', fontszlabel, 'HorizontalAlignment', 'left')

else
    
    d1 = h_max-h_min;
    x1 = [pbins(1)]; y1 = [h_max-d1*0.05];
    k = 1;
    
    % Plot legend text
    l1 = sprintf('Trial aborted before memory target');
    text(x1(k), 0, l1, 'Color', [0.2, 0.2, 0.2],  'FontSize', fontszlabel, 'HorizontalAlignment', 'center')

end


