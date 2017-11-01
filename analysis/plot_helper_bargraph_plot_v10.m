% Plots bars and sets up figure settings 

mat1 = plot_set.mat1;
pbins = plot_set.pbins;

for k=1:size(mat1,3)
    for j=1:size(mat1,2)
        if ~isnan(nanmean(mat1(:,j,k)))
            
            %=======
            % MEANS
            if size(mat1,1)>1
                h=bar(pbins(1), nanmean(mat1(:,j,k)), plot_set.bar_width);
            else
                h=bar(pbins(1), mat1(:,j,k), plot_set.bar_width);
            end
            
            % Select color
            if isfield(plot_set, 'data_color_min')
                c1 = color1_range(j,:);
            elseif isfield(plot_set, 'data_color') && ~isempty(plot_set.data_color)
                graphcond = plot_set.data_color(j);
                c1 = settings.color1(graphcond,:);
            else
                error ('Figure colors not specified')
            end
            
            % Set color
            if isfield(plot_set, 'bar_base_value')
            else
                plot_set.bar_base_value = 0;
            end
            set (h(end), 'LineWidth', settings.wlineerror, 'EdgeColor', c1, 'FaceColor', c1, 'BaseValue', plot_set.bar_base_value);
            
            
            %             %=======
            %             % Plot error bars
            %             if size(mat1,1)>1
            % %                 graphcond=figcolor1(j);
            %                 % SEM
            %                 ciAmpli1 = e_bars.bootstrap_lower(:,j,i);
            %                 ciAmpli2 = e_bars.bootstrap_upper(:,j,i);
            %                 h=plot([pbins(1),pbins(1)], [nanmean(mat1(:,j,i)), ciAmpli1]);
            % %                 set (h(end), 'LineWidth', settings.wlineerror, 'Color', facecolor1(graphcond,:))
            %                 h=plot([pbins(1),pbins(1)], [nanmean(mat1(:,j,i)),ciAmpli2]);
            % %                 set (h(end), 'LineWidth', settings.wlineerror, 'Color', color1(graphcond,:))
            %             end
            
        end
        % Remove first plotbin
        pbins(1)=[];
        
    end
end

%============
% ADD LEGEND

if isfield (plot_set, 'legend')
    for i=1:numel(plot_set.legend)
        text(plot_set.legend_x_coord(i), plot_set.legend_y_coord(i), plot_set.legend{i},...
            'Color', [1,1,1], 'FontSize', settings.fontsz, 'HorizontalAlignment', 'left', 'Rotation', 90);
    end
end

hfig = gca;
set (hfig, 'FontSize', settings.fontsz);

% Y Tick
if isfield (plot_set, 'YTick')
    hfig.YTick = plot_set.YTick;
end

% Y Lim
if isfield (plot_set, 'YLim')
    hfig.YLim = plot_set.YLim;
end

% X Lim
if isfield (plot_set, 'XLim')
    hfig.XLim = plot_set.XLim;
end

% X label
if isfield (plot_set, 'xlabel')
    xlabel (plot_set.xlabel, 'FontSize', settings.fontszlabel);
end

% Y label
if isfield (plot_set, 'ylabel')
    ylabel (plot_set.ylabel, 'FontSize', settings.fontszlabel);
end

% Figure title
if isfield (plot_set, 'figure_title')
    title (plot_set.figure_title, 'FontSize', settings.fontszlabel)
end

% X-tick label
if isfield (plot_set, 'xtick_label')
    
    % Find x-tick marks
    t1 = plot_set.pbins;
    m1 = plot_set.mat1;
    c1 = [];
    for j=1:size(m1,3)
        n = size(m1, 2);
        if j==1
            ind = (j*n-j*n+1 : j*n);
        else
            ind = (j*n-n+1 : j*n);
        end
        c1(j)=mean(t1(ind));
    end
    
    hfig.XTick = c1;
    set(hfig,'XTickLabel', plot_set.xtick_label,'FontSize', settings.fontszlabel)
end
