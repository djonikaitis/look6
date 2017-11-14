% Plots distribution of saccade target positions and saccade time positions
% Latest revision - July 19 2016
% Donatas Jonikaitis


%% Settings


% Figure settings
figsize1=[0, 0, 2, 2];
fontsz=8;
fontszlabel=10;

wlinegraph = 1; % Width of line for the graph
color1(1,:,:) = [0.2, 0.2, 0.2];
color1(2,:,:) = [1, 0.2, 0.2];
color1(3,:,:) = [0.2, 0.7, 0.7];
color1(4,:,:) = [1, 0.5, 0.5];
% color1(4,:,:) = [1, 0.7, 0.7];


% Select look/avoid task trials (those conditons are not present always)
expcond1=NaN(size(S.data,1),1);
index=S.maincond==1 & S.trialaccepted==-1 & S.target_number==2;
if sum(index)>1
    expcond1(index)=1;
end
index=S.maincond==2 & S.trialaccepted==-1 & S.target_number==2;
if sum(index)>1
    expcond1(index)=2;
end
index=S.maincond==3 & S.trialaccepted==-1 & S.target_number==1;
if sum(index)>1
    expcond1(index)=3;
end

%% Figure 1


%================
% Select conditions
var1 = expcond1;
var2 = S.fixation_off-S.fixation_acquired;
bin1 = linspace(min(var2), max(var2), 20);
bin1_median = nanmedian(var2);

title_text{1} = 'Total fixation duration';

%================
% Select data

mat1 = NaN(1, length(bin1)-1, 4);
plot_bins = [];

for i=1:max(var1)
    for j=1:length(bin1)-1
        
        index = var2>=bin1(j) & var2<bin1(j+1) & var1==i;
        mat1(1,j,i)= sum(index);
        plot_bins(j)=(bin1(j)+bin1(j+1))./2;
        
    end
end

mat1 = log(mat1);
mat1(mat1==-Inf)=NaN; % If data is missing, matrix will look fragmented

%===============
% Plot

for fig1 = 1
    
    % Conditions
    if fig1==1
        cond = [1,2,3];
    end
    
    % Select data
    mat1_plot = mat1(1,:,cond);
    plot_bins;
    
    h = figure;
    hold on;
    
    % Plot
    for i=1:size(mat1_plot,3)
        h=plot(plot_bins, mat1_plot(:,:,i));
        graphcond=i;
        set (h(end), 'LineWidth', wlinegraph, 'Color', color1(graphcond,:))
    end
    
    % Y axis
    set (gca,'FontSize', fontsz);
    a1=[1, 10, 20, 50, 100, 500, 1000];
    b1=log(a1);
    set(gca,'YTick', b1);
    set(gca, 'YTickLabel', a1 );
    ylabel ('No of repetitions', 'FontSize', fontszlabel);
    
    % Y axis min and max
    h0(1)=min(min(mat1_plot(:,:,:)));
    h1(1)=max(max(mat1_plot(:,:,:)));
    h0=min(h0);
    h1=max(h1);
    set(gca,'YLim', ([h0-h0*0.2 h1+h1*0.5]));
    
    % Axis
    xlabel ('Duration (ms)', 'FontSize', fontszlabel);
    set(gca,'XLim',[bin1(1)-10 bin1(end)+10]);
    set(gca, 'Xtick', [bin1(1), bin1_median, bin1(end)]);
    title ([title_text{fig1}], 'FontSize', fontszlabel)
    
    
    %============
    % Export the figure & save it
    cdDir = settings.path_preprocessing_figures;
    subjectName = [settings.subject_name, num2str(settings.subject_name_date)];
    rundirexp=[cdDir, subjectName,'/', 'setup_figures/'];
    try
        cd(rundirexp)
    catch
        mkdir(rundirexp)
    end
    
    fileName=[rundirexp,'total_fix_dur_', num2str(fig1)];
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperUnits', 'inches');
    set(gcf, 'PaperPosition', figsize1)
    set(gcf, 'PaperSize', [figsize1(3),figsize1(4)]);
    print (fileName, '-dpdf')
    %===============
    
    close all
    
end



%% Figure 2


%================
% Select conditions

var1 = expcond1;
var2 = S.memory_on-S.fixation_acquired;
bin1 = linspace(min(var2), max(var2), 20);
bin1_median = nanmedian(var2);

title_text{1} = 'Fix dur before memory on';


%================
% Select data

mat1 = NaN(1, length(bin1)-1, 3);
plot_bins = [];

for i=1:max(var1)
    for j=1:length(bin1)-1
        
        index = var2>=bin1(j) & var2<bin1(j+1) & var1==i;
        mat1(1,j,i)= sum(index);
        plot_bins(j)=(bin1(j)+bin1(j+1))./2;
        
    end
end

mat1 = log(mat1);
mat1(mat1==-Inf)=NaN; % If data is missing, matrix will look fragmented

%===============
% Plot

for fig1 = 1
    
    % Conditions
    if fig1==1
        cond = [1,2,3];
    end
    
    % Select data
    mat1_plot = mat1(1,:,cond);
    plot_bins;
    
    h = figure;
    hold on;
    
    % Plot
    for i=1:size(mat1_plot,3)
        h=plot(plot_bins, mat1_plot(:,:,i));
        graphcond=i;
        set (h(end), 'LineWidth', wlinegraph, 'Color', color1(graphcond,:))
    end
    
    % Y axis
    set (gca,'FontSize', fontsz);
    a1=[1, 10, 20, 50, 100, 500, 1000];
    b1=log(a1);
    set(gca,'YTick', b1);
    set(gca, 'YTickLabel', a1 );
    ylabel ('No of repetitions', 'FontSize', fontszlabel);
    
    % Y axis min and max
    h0(1)=min(min(mat1_plot(:,:,:)));
    h1(1)=max(max(mat1_plot(:,:,:)));
    h0=min(h0);
    h1=max(h1);
    set(gca,'YLim', ([h0-h0*0.2 h1+h1*0.5]));
    
    % Axis
    xlabel ('Duration (ms)', 'FontSize', fontszlabel);
    set(gca,'XLim',[bin1(1)-10 bin1(end)+10]);
    set(gca, 'Xtick', [bin1(1), bin1_median, bin1(end)]);
    title ([title_text{fig1}], 'FontSize', fontszlabel)
    
    
    %============
    % Export the figure & save it
    cdDir = settings.path_preprocessing_figures;
    subjectName = [settings.subject_name, num2str(settings.subject_name_date)];
    rundirexp=[cdDir, subjectName,'/', 'setup_figures/'];
    try
        cd(rundirexp)
    catch
        mkdir(rundirexp)
    end
    
    fileName=[rundirexp,'pre_memory_dur_', num2str(fig1)];
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperUnits', 'inches');
    set(gcf, 'PaperPosition', figsize1)
    set(gcf, 'PaperSize', [figsize1(3),figsize1(4)]);
    print (fileName, '-dpdf')
    %===============
    
    close all
    
end

%% Figure 3


%================
% Select conditions

var1 = expcond1;
var2 = S.fixation_off-S.memory_off;
bin1 = linspace(min(var2), max(var2), 20);
bin1_median = nanmedian(var2);

title_text{1} = 'Fix dur after memory off';


%================
% Select data

mat1 = NaN(1, length(bin1)-1, 3);
plot_bins = [];

for i=1:max(var1)
    for j=1:length(bin1)-1
        
        index = var2>=bin1(j) & var2<bin1(j+1) & var1==i;
        mat1(1,j,i)= sum(index);
        plot_bins(j)=(bin1(j)+bin1(j+1))./2;
        
    end
end

mat1 = log(mat1);
mat1(mat1==-Inf)=NaN; % If data is missing, matrix will look fragmented

%===============
% Plot

for fig1 = 1
    
    % Conditions
    if fig1==1
        cond = [1,2,3];
    end
    
    % Select data
    mat1_plot = mat1(1,:,cond);
    plot_bins;
    
    h = figure;
    hold on;
    
    % Plot
    for i=1:size(mat1_plot,3)
        h=plot(plot_bins, mat1_plot(:,:,i));
        graphcond=i;
        set (h(end), 'LineWidth', wlinegraph, 'Color', color1(graphcond,:))
    end
    
    % Y axis
    set (gca,'FontSize', fontsz);
    a1=[1, 10, 20, 50, 100, 500, 1000];
    b1=log(a1);
    set(gca,'YTick', b1);
    set(gca, 'YTickLabel', a1 );
    ylabel ('No of repetitions', 'FontSize', fontszlabel);
    
    % Y axis min and max
    h0(1)=min(min(mat1_plot(:,:,:)));
    h1(1)=max(max(mat1_plot(:,:,:)));
    h0=min(h0);
    h1=max(h1);
    set(gca,'YLim', ([h0-h0*0.2 h1+h1*0.5]));
    
    % Axis
    xlabel ('Duration (ms)', 'FontSize', fontszlabel);
    set(gca,'XLim',[bin1(1)-10 bin1(end)+10]);
    set(gca, 'Xtick', [bin1(1), bin1_median, bin1(end)]);
    title ([title_text{fig1}], 'FontSize', fontszlabel)
    
    
    %============
    % Export the figure & save it
    cdDir = settings.path_preprocessing_figures;
    subjectName = [settings.subject_name, num2str(settings.subject_name_date)];
    rundirexp=[cdDir, subjectName,'/', 'setup_figures/'];
    try
        cd(rundirexp)
    catch
        mkdir(rundirexp)
    end
    
    fileName=[rundirexp,'post_memory_dur_', num2str(fig1)];
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperUnits', 'inches');
    set(gcf, 'PaperPosition', figsize1)
    set(gcf, 'PaperSize', [figsize1(3),figsize1(4)]);
    print (fileName, '-dpdf')
    %===============
    
    close all
    
end


%% FIGURE 4

%================
% Select conditions

% % Find angle of the saccade target
% [theta,rho]=cart2pol(S.st_coord(:,1),S.st_coord(:,2));
% theta = round(rad2deg(theta));
% 
% var1 = expcond1;
% var2 = NaN(size(var1,1),1);
% for i=1:max(expcond1)
%     index=expcond1==var1;
%     var2(index) = theta(index);
% end
% 
% if length(unique(removeNaN(var2)))>1
%     
%     bin1 = unique(removeNaN(var2));
%     title_text{1} = 'Saccade target position (arc)';
%     
%     %================
%     % Select data
%     
%     mat1 = NaN(1, length(bin1)-1, 3);
%     plot_bins = [];
%     
%     for i=1:max(var1)
%         for j=1:length(bin1)
%             
%             index = var2==bin1(j) & var1==i;
%             mat1(1,j,i)= sum(index);
%             plot_bins(j)=bin1(j);
%             
%         end
%     end
%     
%     mat1 = log(mat1);
%     mat1(mat1==-Inf)=NaN; % If data is missing, matrix will look fragmented
%     
%     %===============
%     % Plot
%     
%     for fig1 = 1
%         
%         % Conditions
%         if fig1==1
%             cond = [1,2,3];
%         end
%         
%         % Select data
%         mat1_plot = mat1(1,:,cond);
%         plot_bins;
%         
%         h = figure;
%         hold on;
%         
%         % Plot
%         for i=1:size(mat1_plot,3)
%             h=plot(plot_bins, mat1_plot(:,:,i));
%             graphcond=i;
%             set (h(end), 'LineWidth', wlinegraph, 'Color', color1(graphcond,:))
%         end
%         
%         % Y axis
%         set (gca,'FontSize', fontsz);
%         a1=[1, 10, 20, 50, 100, 500, 1000];
%         b1=log(a1);
%         set(gca,'YTick', b1);
%         set(gca, 'YTickLabel', a1 );
%         ylabel ('No of repetitions', 'FontSize', fontszlabel);
%         
%         % Y axis min and max
%         h0(1)=min(min(mat1_plot(:,:,:)));
%         h1(1)=max(max(mat1_plot(:,:,:)));
%         h0=min(h0);
%         h1=max(h1);
%         set(gca,'YLim', ([h0-h0*0.2 h1+h1*0.5]));
%         
%         % Axis
%         xlabel ('Saccade target (deg)', 'FontSize', fontszlabel);
%         set(gca,'XLim',[bin1(1)-20 bin1(end)+20]);
%         set(gca, 'Xtick', [bin1]);
%         title ([title_text{fig1}], 'FontSize', fontszlabel)
%         
%         
%         %============
%         % Export the figure & save it
%         cdDir = settings.path_preprocessing_figures;
%         subjectName = [settings.subject_name, num2str(settings.subject_name_date)];
%         rundirexp=[cdDir, subjectName,'/', 'setup_figures/'];
%         try
%             cd(rundirexp)
%         catch
%             mkdir(rundirexp)
%         end
%         
%         fileName=[rundirexp,'eye_target_pos_', num2str(fig1)];
%         set(gcf, 'PaperPositionMode', 'manual');
%         set(gcf, 'PaperUnits', 'inches');
%         set(gcf, 'PaperPosition', figsize1)
%         set(gcf, 'PaperSize', [figsize1(3),figsize1(4)]);
%         print (fileName, '-dpdf')
%         %===============
%         
%         close all
%         
%     end
% else
%     disp ('Figure 4 could not be printed - no unique values available')
% end
% 
% 
% %% FIGURE 5
% 
% %================
% % Select conditions
% 
% % Find angle of the saccade target
% [theta,rho]=cart2pol(S.st_coord(:,1),S.mem_pos(:,2));
% theta = round(rad2deg(theta));
% 
% var1 = expcond1;
% var2 = NaN(size(var1,1),1);
% for i=1:max(expcond1)
%     index=expcond1==var1;
%     var2(index) = theta(index);
% end
% 
% if length(unique(removeNaN(var2)))>1
%     
%     bin1 = unique(removeNaN(var2));
% 
%     title_text{1} = 'Memory target position (arc)';
%     
%     %================
%     % Select data
%     
%     mat1 = NaN(1, length(bin1)-1, 3);
%     plot_bins = [];
%     
%     for i=1:max(var1)
%         for j=1:length(bin1)
%             
%             index = var2==bin1(j) & var1==i;
%             mat1(1,j,i)= sum(index);
%             plot_bins(j)=bin1(j);
%             
%         end
%     end
%     
%     mat1 = log(mat1);
%     mat1(mat1==-Inf)=NaN; % If data is missing, matrix will look fragmented
%     
%     %===============
%     % Plot
%     
%     for fig1 = 1
%         
%         % Conditions
%         if fig1==1
%             cond = [1,2,3];
%         end
%         
%         % Select data
%         mat1_plot = mat1(1,:,cond);
%         plot_bins;
%         
%         h = figure;
%         hold on;
%         
%         % Plot
%         for i=1:size(mat1_plot,3)
%             h=plot(plot_bins, mat1_plot(:,:,i));
%             graphcond=i;
%             set (h(end), 'LineWidth', wlinegraph, 'Color', color1(graphcond,:))
%         end
%         
%         % Y axis
%         set (gca,'FontSize', fontsz);
%         a1=[1, 10, 20, 50, 100, 500, 1000];
%         b1=log(a1);
%         set(gca,'YTick', b1);
%         set(gca, 'YTickLabel', a1 );
%         ylabel ('No of repetitions', 'FontSize', fontszlabel);
%         
%         % Y axis min and max
%         h0(1)=min(min(mat1_plot(:,:,:)));
%         h1(1)=max(max(mat1_plot(:,:,:)));
%         h0=min(h0);
%         h1=max(h1);
%         set(gca,'YLim', ([h0-h0*0.2 h1+h1*0.5]));
%         
%         % Axis
%         xlabel ('Memory target (deg)', 'FontSize', fontszlabel);
%         set(gca,'XLim',[bin1(1)-20 bin1(end)+20]);
%         set(gca, 'Xtick', [bin1]);
%         title ([title_text{fig1}], 'FontSize', fontszlabel)
%         
%         
%         %============
%         % Export the figure & save it
%         cdDir = settings.path_preprocessing_figures;
%         subjectName = [settings.subject_name, num2str(settings.subject_name_date)];
%         rundirexp=[cdDir, subjectName,'/', 'setup_figures/'];
%         try
%             cd(rundirexp)
%         catch
%             mkdir(rundirexp)
%         end
%         
%         fileName=[rundirexp,'memory_target_pos_', num2str(fig1)];
%         set(gcf, 'PaperPositionMode', 'manual');
%         set(gcf, 'PaperUnits', 'inches');
%         set(gcf, 'PaperPosition', figsize1)
%         set(gcf, 'PaperSize', [figsize1(3),figsize1(4)]);
%         print (fileName, '-dpdf')
%         %===============
%         
%         close all
%         
%     end
% else
%     disp ('Figure 5 could not be printed - no unique values available')
% end
% 
