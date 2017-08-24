% Plots spike rasters for different stimulus background colors

% clear all;
close all;
clc;

%% Initial setup

% Loading the files needed
if ~exist('settings', 'var')
    settings = struct;
end

if ~isfield (settings, 'exp_name')
    settings.exp_name = input ('Type in experiment name: ', 's');
end
% Default subject number: all subjects
if ~isfield (settings, 'subjects')
    sN1 = 'all'; % Subject name
end

% Run settings file:
eval(sprintf('%s_settings', settings.exp_name)); % Load general settings

%% Some settings

% Path to figures and statistics
settings.figure_folder_name = 'messages_matched';
settings.stats_file_name = sprintf('statistics_%s_', settings.figure_folder_name);


%% Run analysis

for i_subj=1:length(settings.subjects)
    
    settings.subject_name=settings.subjects{i_subj}; % Select curent subject
    
    % Initialize subject specific folders where data is stored
    for i=1:length(settings.path_spec_names)
        v1 = ['path_', settings.path_spec_names{i}];
        settings.(v1) = sprintf ('%s%s/', settings.path_spec_folder{i}, settings.subject_name);
    end
    
    % Get index of every folder for a given subject
    session_init = get_path_dates_v20(settings.path_data_spikes, settings.subject_name);
    
    
    % Which date to analyse (all days or a single day)
    if settings.preprocessing_sessions_used==1
        ind = [1:length(session_init.index_unique_dates)];
    elseif settings.preprocessing_sessions_used==2
        ind = find(session_init.index_unique_dates==settings.preprocessing_day_id);
    elseif settings.preprocessing_sessions_used==3
        ind = length(session_init.index_unique_dates);
    end
    date_index = session_init.index_unique_dates(ind);
    
    
    for i_date = 1:length(ind)
        
        folder_name = session_init.index_directory{ind(i_date)};
        
        % Path to subject specific figures folder
        path1_fig = sprintf('%s%s/%s/%s/', settings.path_figures, settings.figure_folder_name, settings.subject_name, folder_name);
        if ~isdir(path1_fig)
            mkdir(path1_fig)
        elseif isdir(path1_fig)
            rmdir(path1_fig, 's')
            mkdir(path1_fig)
        end
        
        % Initialize text file for statistics
        nameOut = sprintf('%s%s.txt', path1_fig, settings.stats_file_name); % File to be outputed
        fclose('all');
        fout = fopen(nameOut,'w');
        
        % Load combined data
        path1 = sprintf('%s%s/', settings.path_data_combined, folder_name);
        file_name = [folder_name];
        varx = load(sprintf('%s%s', path1, file_name));
        f1 = fieldnames(varx);
        S = struct; % Initialize empty var
        if length(f1)==1
            S = varx.(f1{1});
        end
        
        
        %=============
        % Determine neurons that exist on a given day
        % For each neuron
        path1 = sprintf('%s%s/', settings.path_data_spikes, folder_name);
        spikes_init = get_path_spikes_v10 (path1, settings.subject_name); % Path to each neuron
        
        
        % Run analysis for each unit
        for i_unit = 1
            
            %=================
            % Load spikes data
            path1 = spikes_init.index_path{i_unit};
            varx = load(path1);
            f1 = fieldnames(varx);
            spikes1 = struct;
            if length(f1)==1
                spikes1 = varx.(f1{1});
            end
            
            %             h = figure;
            %             hold on;
            
            
            S.msg_1=NaN(size(S.session));
            S.msg_2=NaN(size(S.session));
            
            for i=1:max(S.session)
                sp = (spikes1.msg_2-spikes1.msg_1) * 1000;
                index = S. session == i;
                psy = S.fixation_off(index) - S.first_display(index);
                
                if length(sp)>=length(psy)
                    n1 = length(sp)-length(psy);
                    for i=1:n1+1
                        mat1 = sp(i:i+length(psy)-1);
                        c1(i) = corr(mat1, psy);
                        c1_ind(i) = i;
                    end
                else
                    error('DJ, there are fewer messages recorded than you expected')
                end
                
                ind = c1_ind(c1>0.9);
                
                if length(ind)==1
                    index1 = ind:ind+length(psy)-1;
                    S.msg_1(index1) = spikes1.msg_1(index1);
                    S.msg_2(index1) = spikes1.msg_2(index1);
                else
                    error('DJ, multiple (or none) high correlations observed')
                end
            end
            
            
            %             plot (a, 'r');
            %             plot(b, 'k');
            
            
            
            
            %% Figure calculations
            
            %             for fig1=1 % Plot figures
            %
            %                 %==============
            %                 % Save neuron name
            %                 neuron_name = ['ch', num2str(spikes_init.index_channel(i_unit)), ' u',  num2str(spikes_init.index_unit(i_unit))];
            %
            %
            %                 %==============
            %                 % Setup exp condition
            %                 S.expcond=NaN(size(S.trial_accepted));
            %
            %                 if fig1==1 || fig1==2 % Plot by legend angle
            %
            %                     % No texture
            %                     index = S.em_background_texture_on==0 & S.trial_accepted==-1;
            %                     S.expcond(index)=1;
            %                     % Texture
            %                     m1 = unique(S.em_background_texture_line_angle);
            %                     for i=1:length(m1)
            %                         index = S.em_background_texture_on==1 & S.em_background_texture_line_angle==m1(i) & S.trial_accepted==-1;
            %                         S.expcond(index)=i+1;
            %                     end
            %                     % Determine selected offset in the time (for example between first display and memory onset)
            %                     % S.first_display is the time plexon message was sent
            %                     if fig1==1
            %                         S.tconst = S.fixation_on - S.first_display;
            %                     elseif fig1==2
            %                         S.tconst = S.memory_on - S.first_display;
            %                     end
            %
            %                     % Save texture angles for legend
            %                     legend1_values = m1;
            %
            %                     % Select appropriate interval for plottings
            %                     int_bins = settings.intervalbins_tex;
            %
            %
            %                 elseif fig1==3 || fig1==4 || fig1==5 || fig1==6 || fig1==7 || fig1==8
            %
            %                     m1 = unique([S.em_t1_coord1, S.em_t1_coord2], 'rows');
            %
            %                     % Texture
            %                     for i=1:size(m1,1)
            %                         index = S.em_t1_coord1==m1(i,1) & S.em_t1_coord2==m1(i,2) & S.em_background_texture_on==1  & S.trial_accepted==-1;
            %                         S.expcond(index)=i;
            %                     end
            %                     % No texture
            %                     i1 = max(S.expcond);
            %                     for i=1:size(m1,1)
            %                         index = S.em_t1_coord1==m1(i,1) & S.em_t1_coord2==m1(i,2) & S.em_background_texture_on==0  & S.trial_accepted==-1;
            %                         S.expcond(index)=i+i1;
            %                     end
            %                     % Determine selected offset in the time (for example between first display and memory onset)
            %                     % S.first_display is the time plexon message was sent
            %                     if fig1==3 || fig1==4
            %                         S.tconst = S.fixation_on - S.first_display;
            %                     elseif fig1==5 || fig1==6
            %                         S.tconst = S.memory_on - S.first_display;
            %                     elseif fig1==7 || fig1==8
            %                         S.tconst = S.fixation_off - S.first_display;
            %                     end
            %
            %                     % Save texture angles for legend
            %                     [theta,rho] = cart2pol(m1(:,1),m1(:,2));
            %                     theta = (theta/pi)*180;
            %                     legend1_values = theta;
            %
            %                     % Select appropriate interval for plottings
            %                     if fig1==3 || fig1==4
            %                         int_bins = settings.intervalbins_tex;
            %                     elseif fig1==5 || fig1==6
            %                         int_bins = settings.intervalbins_mem;
            %                     elseif fig1==7 || fig1==8
            %                         int_bins = settings.intervalbins_sacc;
            %                     end
            %
            %                 end
            %
            %
            %                 %===========
            %                 % Initialize spike timing
            %                 t1_spike = spikes1.ts;
            %                 t1_spike = t1_spike*1000;
            %
            %                 % Get timing of the events
            %                 t1 = spikes1.msg_1;
            %                 t1 = t1*1000;
            %                 t1 = t1+S.tconst;
            %
            %                 %============
            %                 % Initialize empty matrix
            %                 cond1 = unique(removeNaN(S.expcond));
            %                 xmat = NaN(size(S.expcond,1), length(int_bins), length(cond1));
            %
            %
            %                 %============
            %                 % Find spikes
            %                 for tid = 1:size(xmat,1)
            %                     for j=1:length(int_bins)
            %                         for k=1:length(cond1)
            %
            %                             c1 = S.expcond(tid); % Which condition it is currently?
            %                             % If particular conditon on a given trial
            %                             % exists, then calculate firing rates
            %                             if ~isnan(c1) && c1==k
            %
            %                                 % Index
            %                                 index = t1_spike >= t1(tid) + int_bins(j) & ...
            %                                     t1_spike <= t1(tid) + int_bins(j) + settings.bin_length & ...
            %                                     S.expcond(tid) == cond1(k);
            %
            %                                 % Save data
            %                                 if sum(index)==0
            %                                     xmat(tid,j,c1)=0; % Save as zero spikes
            %                                 elseif sum(index)>0
            %                                     xmat(tid,j,c1)=sum(index); % Save spikes counts
            %                                 end
            %                             end
            %
            %                         end
            %                     end
            %                 end
            %
            %                 % Convert to HZ
            %                 xmat = xmat*(1000/settings.bin_length);
            %
            %                 pbins=int_bins+settings.bin_length/2;
            %
            %
            %                 %% Plot figure
            %
            %
            %                 fig_legend=2; % Legend is on;
            %
            %                 hfig=figure;
            %                 hold on;
            %
            %                 % Initialize data
            %                 %=================
            %                 mat1=[]; legend1={};
            %                 save_name=sprintf('fig%d %s', fig1, neuron_name);
            %                 if fig1==1 || fig1==2
            %                     % Cue locked, saccade target
            %                     mat1=xmat;
            %                     %===
            %                     figcolor1=[5,6,7];
            %                     title1 = 'Responses to texture ';
            %
            %                     %===========
            %                     % Calculate the colors
            %
            %                     color1_line=[];
            %                     color1_line(1,:)=color1(figcolor1(1),:);
            %
            %                     % Orientation colors are calculated as a range
            %                     col_min = color1(figcolor1(2),:); % Orientation 0
            %                     col_max = color1(figcolor1(3),:); % Orientation max
            %                     d1 = col_max-col_min;
            %                     stepsz = 1/(length(legend1_values));
            %                     for i=2:size(mat1,3)
            %                         color1_line(i,:)=col_min + (d1*stepsz)*(i-1);
            %                     end
            %
            %                     % Color of the error bars
            %                     for i=1:size(color1_line,1)
            %                         d1 = 1-color1_line(i,:);
            %                         color1_error(i,:)=color1_line(i,:)+d1.*0.6;
            %                     end
            %
            %                 elseif fig1==3 || fig1==4 || fig1==5 || fig1==6 || fig1==7 || fig1==8
            %
            %                     if fig1==3 || fig1==5 || fig1==7
            %                         mat1=xmat(:,:,1:length(legend1_values));
            %                         title1 = 'Texture';
            %                     elseif fig1==4 || fig1==6 || fig1==8
            %                         mat1=xmat(:,:,length(legend1_values)+1:end);
            %                         title1 = 'No texture';
            %                     end
            %                     figcolor1=[8,9];
            %
            %                     %===========
            %                     % Calculate the colors
            %
            %                     color1_line=[];
            %
            %                     % Orientation colors are calculated as a range
            %                     col_min = color1(figcolor1(1),:); % Orientation 0
            %                     col_max = color1(figcolor1(2),:); % Orientation max
            %                     d1 = col_max-col_min;
            %                     stepsz = 1/(length(legend1_values));
            %                     for i=1:size(mat1,3)
            %                         color1_line(i,:)=col_min + (d1*stepsz)*(i-1);
            %                     end
            %
            %                     % Color of the error bars
            %                     for i=1:size(color1_line,1)
            %                         d1 = 1-color1_line(i,:);
            %                         color1_error(i,:)=color1_line(i,:)+d1.*0.6;
            %                     end
            %                 end
            %
            %
            %
            %
            %                 %=================
            %                 % Calculate error bars
            %
            %                 a1=[]; b1=[]; c1=[]; d1=[]; f1=[];
            %                 %                 % Bootstrap analysis
            %                 %                 if size(mat1,1)>1
            %                 %                     % Bootstrap the sample
            %                 %                     for k=1:size(mat1,3)
            %                 %                         if k==1
            %                 %                             a1 = [mat1(:,:,k)];
            %                 %                         else
            %                 %                             a1 = [a1, mat1(:,:,k)];
            %                 %                         end
            %                 %                     end
            %                 %                     b1 = bootstrapnan(a1,settings.tboot1);
            %                 %                     c1 = prctile(b1,[2.5,97.5]);
            %                 %                     for k=1:size(mat1,3)
            %                 %                         i1=1+(size(mat1,2)*k)-size(mat1,2);
            %                 %                         i2=(size(mat1,2)*k);
            %                 %                         d1(:,:,k) = c1(1,i1:i2,:); % Lower bound (2.5 percentile)
            %                 %                         f1(:,:,k) = c1(2,i1:i2,:); % Upper bound (97.5 percentile)
            %                 %                     end
            %                 %                     % Save bootstrap data
            %                 %                     b1_bootstrap = b1;
            %                 %                     d1_bootstrap = d1;
            %                 %                     f1_bootstrap = f1;
            %                 %                 end
            %                 % SEM
            %                 if settings.error_bars==2 && size(mat1,1)>1
            %                     for k=1:size(mat1,3)
            %                         for i=1:size(mat1,2)
            %                             d1(:,i,k) = nanmean(mat1(:,i,k))-se(mat1(:,i,k)); % Standard error, lower bound (identical to upper one)
            %                             f1(:,i,k) = nanmean(mat1(:,i,k))+se(mat1(:,i,k)); % Standard error, upper bound (identical to lower one)
            %                         end
            %                     end
            %                 end
            %
            %                 %==================
            %                 % Plot error bars
            %
            %                 for k=1:size(mat1,3)
            %
            %
            %                     if size(mat1,1)>1
            %
            %                         graphcond=k;
            %
            %                         xc1=pbins(1); % Min x, min y
            %                         xc2=pbins(1); % Min x, max y
            %                         xc3=pbins; % Upper bound of errors
            %                         xc4=pbins(end); % Max x, max y
            %                         xc5=pbins(end); % Max x, min y
            %                         xc6=pbins;
            %                         xc6=fliplr(xc6);
            %
            %                         yc1=d1(:,1,k); % Lower bound of errors
            %                         yc2=f1(:,1,k); % upper bound of errors
            %                         yc3=f1(:,:,k); % Upper bound of errors
            %                         yc4=f1(:,end,k); % Upper bound of errors
            %                         yc5=d1(:,end,k); % Lower bound of errors
            %                         yc6=d1(:,:,k); % Lower bound of errors
            %                         yc6=fliplr(yc6);
            %
            %
            %                         h=fill([xc1,xc2,xc3,xc4, xc5, xc6],[yc1, yc2, yc3, yc4, yc5, yc6], [1 0.7 0.2],'linestyle','none');
            %                         set (h(end), 'FaceColor', color1_error(graphcond,:,:),'linestyle', 'none', 'FaceAlpha', 1)
            %
            %                     end
            %                 end
            %
            %                 %==================
            %                 % Plot lines
            %
            %                 for k=1:size(mat1,3)
            %                     if size(mat1,1)>1
            %                         h=plot(pbins, nanmean(mat1(:,:,k)));
            %                     elseif size(mat1,1)==1
            %                         h=plot(pbins, mat1(1,:,k));
            %                     end
            %                     graphcond=k;
            %                     set (h(end), 'LineWidth', settings.wlinegraph, 'Color', color1_line(graphcond,:))
            %                 end
            %
            %
            %
            %
            %                 %==============
            %                 % Figure settings
            %
            %                 set (gca,'FontSize', settings.fontsz);
            %                 set(gca,'XLim',[pbins(1)-49 pbins(end)+49]);
            %                 set(gca,'YTick', [0:20:80]);
            %                 set(gca,'YLim', [-1,100]);
            %                 title (sprintf('%s', title1), 'FontSize', settings.fontszlabel)
            %
            %
            %                 if fig1==1
            %                     xlabel ('Time from texture (ms)', 'FontSize', settings.fontszlabel);
            %                     set(gca,'XTick', [-400:200:400]);
            %                 elseif fig1==2
            %                     xlabel ('Time from memory (ms)', 'FontSize', settings.fontszlabel);
            %                     set(gca,'XTick', [-200, 0:500:1000]);
            %                 elseif fig1==3 || fig1==4
            %                     xlabel ('Time from texture (ms)', 'FontSize', settings.fontszlabel);
            %                     set(gca,'XTick', [-400:200:400]);
            %                 elseif fig1==5 || fig1==6
            %                     xlabel ('Time from memory (ms)', 'FontSize', settings.fontszlabel);
            %                     set(gca,'XTick', [-200, 0:500:1000]);
            %                 elseif fig1==7 || fig1==8
            %                     xlabel ('Time from ST (ms)', 'FontSize', settings.fontszlabel);
            %                     set(gca,'XTick', [-800:400:0, 200]);
            %                 end
            %                 ylabel ('Firing rate (Hz)', 'FontSize', settings.fontszlabel);
            %
            %
            %                 %===========
            %                 % Add extra figure with legend of stimulus positions
            %
            %
            %                 if fig_legend == 2
            %
            %                     if fig1==1 || fig1==2
            %
            %                         axes('Position',[0.3,0.8,0.1,0.1])
            %                         axis 'equal'
            %                         set (gca, 'Visible', 'off')
            %                         hold on;
            %
            %                         % Initialize data values for plotting
            %                         for i=1:length(legend1_values)
            %
            %                             % Color
            %                             graphcond = i+1;
            %
            %                             % Find coordinates of a line
            %                             f_rad = 1;
            %                             f_arc = legend1_values(i);
            %                             [xc,yc] = pol2cart(f_arc*pi/180, f_rad);
            %
            %                             % Plot line
            %                             h=plot([0, xc], [0,yc]);
            %                             set (h(end), 'LineWidth', settings.wlinegraph, 'Color', color1_line(graphcond,:))
            %
            %                         end
            %                         % Add legend text
            %                         text(-0, -1, 'Angle', 'Color', color1_line(2,:),  'FontSize', settings.fontszlabel, 'HorizontalAlignment', 'center')
            %                         text(-0, -2, 'No tex', 'Color', color1_line(1,:),  'FontSize', settings.fontszlabel, 'HorizontalAlignment', 'center')
            %
            %                     elseif fig1==3 || fig1==4 || fig1==5 || fig1==6 || fig1==7 || fig1==8
            %
            %                         axes('Position',[0.3,0.8,0.1,0.1])
            %                         axis 'equal'
            %                         set (gca, 'Visible', 'off')
            %                         hold on;
            %
            %                         % Plot circle radius
            %                         cpos1 = [0,0];
            %                         ticks1 = [1];
            %                         cl1=[0.5,0.5,0.5];
            %                         for i=1:length(ticks1);
            %                             h=rectangle('Position', [cpos1(1,1)-ticks1(i), cpos1(1,2)-ticks1(i), ticks1(i)*2, ticks1(i)*2],...
            %                                 'EdgeColor', cl1, 'FaceColor', 'none', 'Curvature', 1, 'LineWidth', 1, 'LineStyle', '-');
            %                         end
            %
            %                         % Plot fixation dot
            %                         cpos1 = [0,0];
            %                         ticks1=[0.2];
            %                         cl1=[0.5,0.5,0.5];
            %                         for i=1:length(ticks1);
            %                             h=rectangle('Position', [cpos1(1,1)-ticks1(i), cpos1(1,2)-ticks1(i), ticks1(i)*2, ticks1(i)*2],...
            %                                 'EdgeColor', cl1, 'FaceColor', cl1, 'Curvature', 1, 'LineWidth', 1, 'LineStyle', '-');
            %                         end
            %
            %                         % Initialize data values for plotting
            %                         for i=1:length(legend1_values)
            %
            %                             % Color
            %                             graphcond = i;
            %
            %                             % Find coordinates of a line
            %                             f_rad = 1;
            %                             f_arc = legend1_values(i);
            %                             [xc,yc] = pol2cart(f_arc*pi/180, f_rad);
            %                             objsize = 0.7;
            %
            %                             % Plot cirlce
            %                             h=rectangle('Position', [xc(1)-objsize(1)/2, yc(1)-objsize(1)/2, objsize(1), objsize(1)],...
            %                                 'EdgeColor', color1_line(i,:), 'FaceColor', color1_line(i,:),'Curvature', 1, 'LineWidth', 1);
            %
            %                             text(0, -2, 'Mem pos', 'Color', color1_line(1,:),  'FontSize', settings.fontszlabel, 'HorizontalAlignment', 'center')
            %                         end
            %
            %
            %                     end
            %                     % Fig 1 is over
            %
            %                 end
            %                 % Fig legend is over
            %                 %===============
            %
            %
            %
            %                 %==============
            %                 % Export the figure & save it
            %
            %                 path1 = [path1_fig];
            %                 if isdir (path1)
            %                     cd (path1)
            %                 else
            %                     mkdir (path1)
            %                 end
            %
            %                 fileName=[save_name];
            %                 set(gcf, 'PaperPositionMode', 'manual');
            %                 set(gcf, 'PaperUnits', 'inches');
            %                 set(gcf, 'PaperPosition', settings.figsize)
            %                 set(gcf, 'PaperSize', [settings.figsize(3),settings.figsize(4)]);
            %                 print (fileName, '-dpdf')
            %                 %                 close all;
            %                 %===============
            %
            %
            %             end
            %             % End of each figure
            
            
            
            
            
            
        end
        % End of each neuron
        
        
        
        
    end
end
% End of each subject




