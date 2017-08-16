% ONLINE data figure

min_trials_to_plot = 25; % How many trials to use for evaluation of errors/corrects

if tid<=min_trials_to_plot
    var1 = expsetup.stim.edata_error_code(1:tid);
elseif tid>min_trials_to_plot
    var1 = expsetup.stim.edata_error_code(1:tid);
end
var1_names = unique(var1);

% Bar positions
bnum = numel(var1_names); % How many bars
barwdh = 0.05; spacewidth=0.3;
rngbar = [barwdh*bnum+barwdh*(bnum-1)*spacewidth]; % Bars plus spaces between them take that much space in total
rngbar = rngbar/2; % Position to both sides of the unit
plotbins = [1-rngbar:barwdh+barwdh*spacewidth:1+rngbar];

% Plot each bar
for i = 1:numel(var1_names)
    
    ind1 = strcmp(var1_names{i}, var1);
    % Plot bars
    if tid<=min_trials_to_plot
        h=bar(plotbins(i), sum(ind1), barwdh); % Plot all trials
    else
        h=bar(plotbins(i), sum(ind1)/length(ind1)*100, barwdh); % Plot proportion
    end
    graphcond=i;
    set (h(end), 'LineWidth', wlinegraph, 'EdgeColor', color1(graphcond,:), 'FaceColor', color1(graphcond,:));
    
    % Legend, plotted on each bar
    text(plotbins(i), 3, var1_names{i}, 'Color', [0.2,0.2,0.2], 'FontSize', fontsz, 'HorizontalAlignment', 'left', 'Rotation', 90)
    
end

% Figure settings
set(gca,'FontSize', fontsz);
if tid<=min_trials_to_plot/2
    set(gca,'YLim',[0,min_trials_to_plot/2+min_trials_to_plot*0.1]);
    ylabel ('Trials', 'FontSize', fontszlabel);
    set(gca,'YTick',0:5:min_trials_to_plot);
elseif tid > min_trials_to_plot/2 && tid<=min_trials_to_plot
    set(gca,'YLim',[0,tid+min_trials_to_plot*0.1]);
    ylabel ('Trials', 'FontSize', fontszlabel);
    set(gca,'YTick',0:10:min_trials_to_plot);
elseif tid>min_trials_to_plot
    set(gca,'YLim',[0,140]) % Max percent
    ylabel ('Trials (%)', 'FontSize', fontszlabel);
    set(gca,'YTick',25:25:100);
end
set(gca,'XLim',[plotbins(1)-0.1 plotbins(end)+0.1]);
xlabel ('Trial type', 'FontSize', fontszlabel);
set(gca,'XTickLabel', ' ', 'FontSize', fontszlabel)


% Add total amount of reward and trials correct
if tid>min_trials_to_plot
    if expsetup.general.reward_on>0
        reward_given = nansum(expsetup.stim.edata_reward_size_ml);
        a =  sprintf ('\nTotal reward: %i ml\n', round(reward_given));
        text(plotbins(end),130, a, 'Color', [0.2, 0.2, 0.2], 'FontSize', fontsz, 'HorizontalAlignment', 'right');
    end
    index1 = strcmp('correct', expsetup.stim.edata_error_code);
    a = sprintf ('\nCorrect trials: %i (%i percent) \n', sum(index1), round((sum(index1)/tid)*100));
    text(plotbins(end), 110, a, 'Color', [0.2, 0.2, 0.2], 'FontSize', fontsz, 'HorizontalAlignment', 'right');
end



