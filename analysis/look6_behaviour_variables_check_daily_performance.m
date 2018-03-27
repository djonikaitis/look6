%================
% Subplot 3
%================

% Initialize matrices
int_bins_dur = 50;
int_bins = 1:numel(S.session)-int_bins_dur;

% Plot bins
pbins = [];
pbins = int_bins + int_bins_dur/2;

settings.int_bins = int_bins;
settings.plot_bins = pbins;

S.trial_no = [];
S.trial_no(:,1) = 1:numel(S.START);

%==============
% Data
data_mat = struct;
data_mat.mat1_ini = S.trial_no;
data_mat.mat1_bins = settings.int_bins;
data_mat.var1{1} = S.esetup_exp_version;
data_mat.var1_match{1} = exp_versions_used;
data_mat.var1{2} = S.esetup_block_cond;
data_mat.var1_match{2} = task_names_used;
data_mat.var1{3} = S.edata_error_code;
data_mat.var1_match{3} = error_code_subset;

data_mat.output = NaN(1, numel(data_mat.mat1_bins), numel(data_mat.var1_match{1}), numel(data_mat.var1_match{2}), numel(data_mat.var1_match{3}));

for i = 1:numel(data_mat.mat1_bins)
    for j = 1:numel(data_mat.var1_match{1})
        for k = 1:numel(data_mat.var1_match{2})
            for m = 1:numel(data_mat.var1_match{3})
                
                % Index
                index = data_mat.mat1_ini >= data_mat.mat1_bins(i) & ...
                    data_mat.mat1_ini < data_mat.mat1_bins(i) + int_bins_dur & ...
                    strcmp (data_mat.var1{1}, data_mat.var1_match{1}(j)) &...
                    strcmp (data_mat.var1{2}, data_mat.var1_match{2}(k)) &...
                    strcmp (data_mat.var1{3}, data_mat.var1_match{3}(m));
                
                % Output
                data_mat.output(1,i,j,k,m) = sum(index);
                
            end
        end
    end
end

[i,j,k,m,o] = size(data_mat.output);
mat_y = reshape(data_mat.output, 1, i*j*k*m*o);

fig_plot_on = sum(mat_y) > 0;

% Plot a figure?
if fig_plot_on == 1
    
    hfig = subplot(fig_subplot_dim(1), fig_subplot_dim(2), 3);
    hold on;
    fprintf('\n%s %s: preparing panel with behaviour performance\n', settings.subject_current, num2str(settings.date_current));
    
    %=================
    % Plot blocks
    %=================

    
    % Correct block_number variable
    block_no = S.esetup_block_no;
    if max(S.session)>1
        for i = 2:max(S.session)
            ind = find(S.session==i);
            block_no(ind) = block_no(ind) + block_no(ind(1)-1);
        end
    end
    
    %============
    % Plot each block color
    for i=1:max(block_no)
        
        % Select current block
        indBl = find(block_no==i);
        
        if ~isempty(indBl)
            
            % Define coordinates of the square
            x1 = indBl(1);
            x2 = (indBl(end)-indBl(1))+1;
            y1 = -100; y2 = 300;
            
            % Which conditiopn is it
            task_name_current = unique(S.esetup_block_cond(indBl));
            
            % Color
            if strcmp(task_name_current, 'look')
                ind2 = strcmp(task_names_used, 'look');
%                 color1 = plot_set.shade_color(ind2,:);
            end
            if strcmp(task_name_current, 'avoid')
                ind2 = strcmp(task_names_used, 'avoid');
%                 color1 = plot_set.shade_color(ind2,:);
            end
            if strcmp(task_name_current, 'control fixate')
                ind2 = strcmp(task_names_used, 'control fixate');
%                 color1 = plot_set.shade_color(ind2,:);
            end
            
            h = rectangle('Position', [x1, y1, x2, y2], 'FaceColor', [0.7, 0.7, 0.7], 'EdgeColor', 'none');
        end
    end
    
    %=================
    % Plot behaviour
    %=================
    
    % Data
    temp1 = [];
    ind1 = strcmp(error_code_subset, 'correct');
    temp1(:,:,:,:,1) = data_mat.output(:,:,:,:,ind1);
    ind1 = strcmp(error_code_subset, 'looked at st2'); 
    temp1(:,:,:,:,2) = data_mat.output(:,:,:,:,ind1);

    total1 = nansum(temp1(:,:,:,:,:), 4); % Sum across look/avoid tasks
    total2 = nansum(total1(:,:,:,:,:), 5); % Sum across correct/error trials
    
    mat1 = total1(:,:,:,:,1)./total2*100;
    mat1 = 100 - (100 - mat1)*2; % Convert into target selection
    
    % Initialize structure
    plot_set = struct;
    plot_set.mat_y = mat1;
    plot_set.mat_x = settings.plot_bins;
    
    plot_set.data_color_min = [0.5,0.5,0.5];
    plot_set.data_color_max = settings.color1(42,:);
    
    plot_set.legend = exp_versions_used;
    for i=1:numel(plot_set.legend)
        plot_set.legend_y_coord(i) = -10 + i*-10;
        plot_set.legend_x_coord(i) = [settings.plot_bins(1)];
    end
    
    % Labels for plotting
    plot_set.ytick = [0:25:100];
    plot_set.ylim = [min(plot_set.legend_y_coord)-10, 110];
    plot_set.figure_title = 'Performance';
    plot_set.xlabel = 'Trial number';
    plot_set.ylabel = 'Correct target selected, %';
    
    % Plot
    plot_helper_basic_line_figure;
    
    
    
end




% 
% % Correct block_number variable
% if max(S.session)>1
%     for i = 2:max(S.session)
%         ind = find(S.session==i);
%         S.esetup_block_no(ind) = S.esetup_block_no(ind) + S.esetup_block_no(ind(1)-1);
%     end
% end
% 
% %============
% % Plot each condition
% for i=1:max(S.esetup_block_no)
%     
%     ind = find(S.esetup_block_no==i);
%     c1 = unique(S.esetup_block_cond(ind));
%     % Define coordinates of the square
%     x1 = ind(1); x2 = (ind(end)-ind(1))+1;
%     y1 = plot_set.YLim(1); y2 = plot_set.YLim(2)-plot_set.YLim(1);
%     % Color
%     if strcmp(c1, 'look')
%         color1 = settings.face_color1(5,:);
%     elseif  strcmp(c1, 'avoid')
%         color1 = settings.face_color1(6,:);
%     elseif  strcmp(c1, 'control fixate')
%         color1 = settings.face_color1(7,:);
%     end
%     
%     h = rectangle('Position', [x1, y1, x2, y2], 'FaceColor', color1, 'EdgeColor', 'none');
%     
% end
% 
% %============
% % Plot data
% plot_helper_basic_line_figure;





% 
% %% Figure 2
% 
% % Initialize data
% %=================
% mat1=[];
% fig1=2;
% 
% % Data
% total1 = nansum(test1(:,:,:,1:3),4); % Check all conditions combined
% mat1 = test1(:,:,:,3)./total1*100;
% 
% % Initialize structure
% plot_set = struct;
% plot_set.mat_y = mat1;
% plot_set.mat_x = pbins;
% 
% plot_set.data_color_min = [0.5,0.5,0.5];
% plot_set.data_color_max = settings.color1(42,:);
% 
% for i=1:size(mat1,3)
%     plot_set.legend{i} = conds1{i};
%     plot_set.legend_y_coord(i) = i*-10;
%     plot_set.legend_x_coord(i) = [pbins(1)];
% end
% 
% % Labels for plotting
% plot_set.YTick = [0:25:100];
% plot_set.YLim = [min(plot_set.legend_y_coord)-10, 110];
% plot_set.figure_title = 'Aborted trials';
% plot_set.xlabel = 'Trial number';
% plot_set.ylabel = '% of trials';
% 
% % Save data
% plot_set.figure_size = settings.figsize_2col;
% plot_set.figure_save_name = 'figure';
% plot_set.path_figure = path_fig;
% 
% 
% % Plot
% % Initialize figure
% hfig = subplot(1, num_figs, fig1);
% hold on;
% 
% %============
% % Plot each condition
% for i=1:max(S.esetup_block_no)
%     
%     ind = find(S.esetup_block_no==i);
%     c1 = unique(S.esetup_block_cond(ind));
%     % Define coordinates of the square
%     x1 = ind(1); x2 = (ind(end)-ind(1))+1;
%     y1 = plot_set.YLim(1); y2 = plot_set.YLim(2)-plot_set.YLim(1);
%     % Color
%     if strcmp(c1, 'look')
%         color1 = settings.face_color1(5,:);
%     elseif  strcmp(c1, 'avoid')
%         color1 = settings.face_color1(6,:);
%     elseif  strcmp(c1, 'control fixate')
%         color1 = settings.face_color1(7,:);
%     end
%     
%     h = rectangle('Position', [x1, y1, x2, y2], 'FaceColor', color1, 'EdgeColor', 'none');
%     
% end
% 
% % Plot data
% plot_helper_basic_line_figure;
% 
% 
% %============
% % Export the figure & save it
% 
% % Save data
% plot_set.figure_size = settings.figsize_2col;
% plot_set.figure_save_name = 'figure';
% plot_set.path_figure = path_fig;
% 
% plot_helper_save_figure;
% 
% close all;
% %===============
% 
% 
% 
% 
