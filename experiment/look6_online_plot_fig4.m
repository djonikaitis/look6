% ONLINE data figure

trials_to_plot = 10; % How many trials to use for evaluation of errors/corrects

if tid<=trials_to_plot
    
    set(gca,'FontSize', fontsz);
    text(0, 0, ['Min. trials needed - ', num2str(trials_to_plot)],...
        'Color', [0.1,0.1,0.1], 'FontSize', fontsz, 'HorizontalAlignment', 'center')
    set(gca,'YLim',[-5,5]);
    set(gca,'XLim', [-19, 19]);
    set(gca,'YTick', [-10,10]);
    set(gca,'XTick', [-20,20]);
    
elseif tid > trials_to_plot
        
    duration1 = expsetup.stim.edata_fixation_off(1:tid) - expsetup.stim.edata_fixation_acquired(1:tid);
    duration1 = duration1(~isnan(duration1));
    if ~isempty (duration1)
        a = min(duration1);
        b = max(duration1);
        if a==b
            plotbins = [];
        else
            plotbins = linspace(a,b,25);
        end
    end
    
    % Select data
    if ~isempty (plotbins)
        for j=1:2
            
            % Select trials
            if j==1
                index1 = strcmp('correct', expsetup.stim.edata_error_code(1:tid));
            elseif j==2
                index1 = strcmp('broke fixation', expsetup.stim.edata_error_code(1:tid)) | strcmp('broke fixation before drift', expsetup.stim.edata_error_code(1:tid));
            end
            duration1 = expsetup.stim.edata_fixation_off(1:tid) - expsetup.stim.edata_fixation_acquired(1:tid);
            
            for i=1:length(plotbins)-1
                index = duration1(index1)>=plotbins(i) & duration1(index1)<plotbins(i+1);
                mat1(j,i) = sum(index);
                pbins(j,i) = (plotbins(i) + plotbins(i+1))/2;
            end
        end
    end
    
    if ~isempty (plotbins)
        for j=1:size(mat1,1)
            total1 = sum(mat1(1,:));
            mat0 = mat1(j,:)./total1*100;
            h=plot(pbins, mat0, 'Color', color1(1,:), 'LineWidth', 1); % Plot eye position in space and time
        end
    end
    
    
    % Figure settings
    set(gca,'FontSize', fontsz);
    set(gca,'YLim',[0, 70])
    ylabel ('Occurences (%)', 'FontSize', fontszlabel);
    set(gca,'YTick',[0:20:60]);
    
    xlabel ('Fixation duration, seconds', 'FontSize', fontszlabel);
    set(gca,'XTick', [0, 1, 2, 3, 4], 'FontSize', fontszlabel);
    set(gca,'XLim', [-0.5, 5]);
    
    % Legend
    text(0, 65, 'Correct', 'Color', color1(1,:), 'FontSize', fontsz, 'HorizontalAlignment', 'left')
    text(0, 58, 'Fixation break', 'Color', color1(5,:), 'FontSize', fontsz, 'HorizontalAlignment', 'left')
    
end