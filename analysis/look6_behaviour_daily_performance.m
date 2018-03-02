% Psychophysics performance

%===============
% Data analysis
%===============

% Determine exp versions used
conds1 = unique(S.esetup_exp_version);

% Initialize matrices
int_bins = 1:50:numel(S.session);
test1 = NaN(1, length(int_bins)-1, numel(conds1), 3);

% Sliding window analysis
for i = 1:size(test1,1)
    for j = 1:length(int_bins)-1
        for k=1:numel(conds1)
            
            ind = int_bins(j):1:int_bins(j+1);
            
            % Correct trials
            index1 = strncmp(S.edata_error_code(ind), 'correct', 7) & ...
                strcmp(S.esetup_exp_version(ind), conds1{k});
            test1(1,j,k,1)= sum(index1);
            
            % Wrong target trials
            index1 = strcmp(S.edata_error_code(ind), 'looked at st2') & ...
                strcmp(S.esetup_exp_version(ind), conds1{k});
            test1(1,j,k,2)= sum(index1);
            
            % Aborted trials
            index1 = strcmp(S.edata_error_code(ind), 'broke fixation') & ...
                strcmp(S.esetup_exp_version(ind), conds1{k});
            test1(1,j,k,3)= sum(index1);
            
        end
    end
end

% Plot bins
pbins = [];
for i = 1:numel(int_bins)-1
    pbins(i) = (int_bins(i)+int_bins(i+1))/2;
end

% Number of subplots
num_figs = 2;


%% Figure 1

% Initialize data
%=================
mat1=[];
fig1=1;

% Data
total1 = nansum(test1(:,:,:,1:2),4); % Check all conditions combined
mat1 = test1(:,:,:,1)./total1*100;
mat1 = 100 - (100 - mat1)*2; % Convert into target selection

% Initialize structure
plot_set = struct;
plot_set.mat_y = mat1;
plot_set.mat_x = pbins;

plot_set.data_color_min = [0.5,0.5,0.5];
plot_set.data_color_max = settings.color1(42,:);

for i=1:size(mat1,3)
    plot_set.legend{i} = conds1{i};
    plot_set.legend_y_coord(i) = i*-10;
    plot_set.legend_x_coord(i) = [pbins(1)];
end

% Labels for plotting
plot_set.YTick = [0:25:100];
plot_set.YLim = [min(plot_set.legend_y_coord)-10, 110];
plot_set.figure_title = 'Performance';
plot_set.xlabel = 'Trial number';
plot_set.ylabel = 'Correct response, % of trials';

% Save data
plot_set.figure_size = settings.figsize_2col;
plot_set.figure_save_name = 'fig';
plot_set.path_figure = path_fig;

% Plot
hfig = subplot(1, num_figs, fig1);
hold on;

% Correct block_number variable
if max(S.session)>1
    for i = 2:max(S.session)
        ind = find(S.session==i);
        S.esetup_block_no(ind) = S.esetup_block_no(ind) + S.esetup_block_no(ind(1)-1);
    end
end

%============
% Plot each condition
for i=1:max(S.esetup_block_no)
    
    ind = find(S.esetup_block_no==i);
    c1 = unique(S.esetup_block_cond(ind));
    % Define coordinates of the square
    x1 = ind(1); x2 = (ind(end)-ind(1))+1;
    y1 = plot_set.YLim(1); y2 = plot_set.YLim(2)-plot_set.YLim(1);
    % Color
    if strcmp(c1, 'look')
        color1 = settings.face_color1(5,:);
    elseif  strcmp(c1, 'avoid')
        color1 = settings.face_color1(6,:);
    elseif  strcmp(c1, 'control fixate')
        color1 = settings.face_color1(7,:);
    end
    
    h = rectangle('Position', [x1, y1, x2, y2], 'FaceColor', color1, 'EdgeColor', 'none');
    
end

%============
% Plot data
plot_helper_basic_line_figure;



%% Figure 2

% Initialize data
%=================
mat1=[];
fig1=2;

% Data
total1 = nansum(test1(:,:,:,1:3),4); % Check all conditions combined
mat1 = test1(:,:,:,3)./total1*100;

% Initialize structure
plot_set = struct;
plot_set.mat_y = mat1;
plot_set.mat_x = pbins;

plot_set.data_color_min = [0.5,0.5,0.5];
plot_set.data_color_max = settings.color1(42,:);

for i=1:size(mat1,3)
    plot_set.legend{i} = conds1{i};
    plot_set.legend_y_coord(i) = i*-10;
    plot_set.legend_x_coord(i) = [pbins(1)];
end

% Labels for plotting
plot_set.YTick = [0:25:100];
plot_set.YLim = [min(plot_set.legend_y_coord)-10, 110];
plot_set.figure_title = 'Aborted trials';
plot_set.xlabel = 'Trial number';
plot_set.ylabel = '% of trials';

% Save data
plot_set.figure_size = settings.figsize_2col;
plot_set.figure_save_name = 'figure';
plot_set.path_figure = path_fig;


% Plot
% Initialize figure
hfig = subplot(1, num_figs, fig1);
hold on;

%============
% Plot each condition
for i=1:max(S.esetup_block_no)
    
    ind = find(S.esetup_block_no==i);
    c1 = unique(S.esetup_block_cond(ind));
    % Define coordinates of the square
    x1 = ind(1); x2 = (ind(end)-ind(1))+1;
    y1 = plot_set.YLim(1); y2 = plot_set.YLim(2)-plot_set.YLim(1);
    % Color
    if strcmp(c1, 'look')
        color1 = settings.face_color1(5,:);
    elseif  strcmp(c1, 'avoid')
        color1 = settings.face_color1(6,:);
    elseif  strcmp(c1, 'control fixate')
        color1 = settings.face_color1(7,:);
    end
    
    h = rectangle('Position', [x1, y1, x2, y2], 'FaceColor', color1, 'EdgeColor', 'none');
    
end

% Plot data
plot_helper_basic_line_figure;


%============
% Export the figure & save it

% Save data
plot_set.figure_size = settings.figsize_2col;
plot_set.figure_save_name = 'figure';
plot_set.path_figure = path_fig;

plot_helper_save_figure;

close all;
%===============



