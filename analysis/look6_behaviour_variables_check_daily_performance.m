%================
% Subplot 3-4
%================

settings.bin_length = 50;
settings.int_bins_start = 1:1:numel(S.session)-settings.bin_length;
settings.int_bins_end = settings.int_bins_start + settings.bin_length;
settings.plot_bins = (settings.int_bins_start+settings.int_bins_end)/2;

% Trial numbers
S.trial_no = [];
S.trial_no(:,1) = 1:numel(S.START);

%==============
% Data
data_mat = struct;
data_mat.mat1_ini = S.trial_no;
data_mat.mat1_ini_bin_start = settings.int_bins_start;
data_mat.mat1_ini_bin_end = settings.int_bins_end;
data_mat.var1{1} = S.esetup_block_cond;
data_mat.var1_match{1} = task_names_used;
data_mat.var1{2} = S.edata_error_code;
data_mat.var1_match{2} = error_code_subset;

data_mat = look6_helper_indexed_selection_behaviour(data_mat, settings);

% Is there data to plot?
[i,j,k,m,o] = size(data_mat.trial_counts);
mat_y = reshape(data_mat.trial_counts, 1, i*j*k*m*o);

fig_plot_on = nansum(mat_y) > 0;

% Plot a figure?
if fig_plot_on == 1
    
    fprintf('\n%s %s: preparing panels with behaviour performance\n', settings.subject_current, num2str(settings.date_current));
    
    %=================
    % Plot blocks
    %=================
    
    for i_fig1 = [4,5]
        
        hfig = subplot(fig_subplot_dim(1), fig_subplot_dim(2), i_fig1);
        hold on;
        
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
            ind_block = find(block_no==i);
            
            if ~isempty(ind_block)
                
                % Define coordinates of the square
                x1 = ind_block(1);
                x2 = (ind_block(end)-ind_block(1))+1;
                y1 = -100; y2 = 300;
                
                % Which conditiopn is it
                task_name_current = unique(S.esetup_block_cond(ind_block));
                
                % Color
                if strcmp(task_name_current, 'look')
                    color1 = settings.face_color1(1,:);
                end
                if strcmp(task_name_current, 'avoid')
                    color1 = settings.face_color1(2,:);
                end
                if strcmp(task_name_current, 'control fixate')
                    color1 = settings.face_color1(4,:);
                end
                
                h = rectangle('Position', [x1, y1, x2, y2], 'FaceColor', color1, 'EdgeColor', 'none');
            end
        end
    end
end


%=================
% Subplot 4
%=================

if fig_plot_on == 1
    
    hfig = subplot(fig_subplot_dim(1), fig_subplot_dim(2), 4);
    hold on;
    
    % Data
    temp1 = [];
    ind1 = strcmp(error_code_subset, 'correct');
    temp1(:,:,:,1) = data_mat.trial_counts(:,:,:,ind1);
    ind1 = strcmp(error_code_subset, 'looked at st2');
    temp1(:,:,:,2) = data_mat.trial_counts(:,:,:,ind1);
    
    total1 = nansum(temp1, 3); % Sum across look/avoid tasks
    total2 = nansum(total1, 4); % Sum across correct/error trials
    
    mat1 = total1(:,:,:,:,1)./total2*100;
    mat1 = 100 - (100 - mat1)*2; % Convert into target selection
    
    % Initialize structure
    plot_set = struct;
    plot_set.mat_y = mat1;
    plot_set.mat_x = settings.plot_bins;
    
    plot_set.data_color_min = [0.5,0.5,0.5];
    plot_set.data_color_max = settings.color1(42,:);
    
    % Labels for plotting
    plot_set.ytick = [0:25:100];
    plot_set.ylim = [-10, 110];
    plot_set.figure_title = 'Performance';
    plot_set.xlabel = 'Trial number';
    plot_set.ylabel = 'Correct target selected, %';
    
    % Plot
    plot_helper_line_plot_v10;
    
    
end

%=================
% Subplot 4
%=================

if fig_plot_on == 1
    
    hfig = subplot(fig_subplot_dim(1), fig_subplot_dim(2), 5);
    hold on;
    
    % Data
    temp1 = [];
    temp1 = data_mat.trial_counts;
    total1 = nansum(temp1, 3); % Sum across look/avoid tasks
    total2 = nansum(total1, 4); % Sum across correct/error trials
    ind1 = strcmp(error_code_subset, 'broke fixation');
    mat1 = total1(:,:,:,ind1)./total2*100;
    
    % Initialize structure
    plot_set = struct;
    plot_set.mat_y = mat1;
    plot_set.mat_x = settings.plot_bins;
    
    plot_set.data_color_min = [0.5,0.5,0.5];
    plot_set.data_color_max = settings.color1(42,:);
    
    % Labels for plotting
    plot_set.ytick = [0:25:100];
    plot_set.ylim = [-10, 110];
    plot_set.figure_title = 'Performance';
    plot_set.xlabel = 'Trial number';
    plot_set.ylabel = 'Aborted trials, %';
    
    % Plot
    plot_helper_line_plot_v10;
    
end

