% Plot saccadic enpoints on trials when condition was classified as broke
% fixation during memory delay
% Latest revision - 12 August 2016
% Donatas Jonikaitis

% Figure settings
figsize1=[0, 0, 2, 2];
fontsz=8;
fontszlabel=10;

wlinegraph = 1; % Width of line for the graph
marker1{1}='o'; marker1{2}='o'; marker1{3}='o'; marker1{4}='o';
msize = 2;

target_coordinates = unique([S.expmatrix(:,em_target_coord1), S.expmatrix(:,em_target_coord2)], 'rows');

% Typical coordinates are [-6 6 combination]
color1(1,:)=[0.6, 0.75, 1]; % [-6, -6];
color1(2,:)=[0.3, 0.2, 0.8]; % [-6, 6];
color1(3,:)=[1, 0.5, 0.55]; % [6, -6];
color1(4,:)=[1, 0.1, 0.2]; % [6, 6];

threshold1 = 2; % Saccade size to be considered


% % % %     % Select look/avoid task trials (those conditons are not present always)
% % % %     expcond1=NaN(size(S.data,1),1);
% % % %     index=S.maincond==1 & S.target_number==2;
% % % %     if sum(index)>1
% % % %         expcond1(index)=1;
% % % %     end
% % % %     index=S.maincond==2;
% % % %     if sum(index)>1
% % % %         expcond1(index)=2;
% % % %     end
% % % %     index=S.maincond==3;
% % % %     if sum(index)>1
% % % %         expcond1(index)=3;
% % % %     end


%% Calculate target distance and angle


%==========
t1 = S.target_coord;
[theta, rho] = cart2pol(t1(:,1), t1(:,2)); % Transform coordinates to amplitude
theta = rad2deg(theta); % Transform to degrees (just for initial plotting)

% Calculate angle and amplitude of each saccade
for tid=1:size(sacc1,1)
    
    % Data to be used
    sx1=sacc1{tid};
    
    % Calculate direction of each saccade
    
    
    
end




%============

% % % % for tid=1:size(sacc1,1)
% % % %     
% % % %     % Data to be used
% % % %     sx1=sacc1{tid};
% % % %     sx2=sacc1{tid};
% % % %     
% % % %     % Starting point distance
% % % %     
% % % %     
% % % %     % Starting position
% % % %     saccstart(1)=0;
% % % %     saccstart(2)=0;
% % % %     sx1(:,3)=sx1(:,3)-saccstart(1);
% % % %     sx1(:,4)=sx1(:,4)-saccstart(2);
% % % %     
% % % %     % Ending position
% % % %     if S.expmatrix(tid,em_blockcond)==1 && S.expmatrix(tid,em_target_number)==2
% % % %         xc = S.expmatrix(tid,em_t1_coord1);
% % % %         yc = S.expmatrix(tid,em_t1_coord2);
% % % %     elseif S.expmatrix(tid,em_blockcond)==2 && S.expmatrix(tid,em_target_number)==2
% % % %         xc = S.expmatrix(tid,em_t2_coord1);
% % % %         yc = S.expmatrix(tid,em_t2_coord2);
% % % %     elseif S.expmatrix(tid,em_target_number)==1
% % % %         xc = S.expmatrix(tid,em_t3_coord1);
% % % %         yc = S.expmatrix(tid,em_t3_coord2);
% % % %     end
% % % %     sx1(:,5)=sx1(:,5)-xc;
% % % %     sx1(:,6)=sx1(:,6)-yc;
    
    % % % %         % Setup figure colors
    % % % %         if S.expmatrix(tid,em_target_coord1)==target_coordinates(1,1) && S.expmatrix(tid,em_target_coord2)==target_coordinates(1,2)
    % % % %             graphcond = 1;
    % % % %         elseif S.expmatrix(tid,em_target_coord1)==target_coordinates(2,1) && S.expmatrix(tid,em_target_coord2)==target_coordinates(2,2)
    % % % %             graphcond = 2;
    % % % %         elseif S.expmatrix(tid,em_target_coord1)==target_coordinates(3,1) && S.expmatrix(tid,em_target_coord2)==target_coordinates(3,2)
    % % % %             graphcond = 3;
    % % % %         elseif S.expmatrix(tid,em_target_coord1)==target_coordinates(4,1) && S.expmatrix(tid,em_target_coord2)==target_coordinates(4,2)
    % % % %             graphcond = 4;
    % % % %         end
    % % % %
    % % % %         % If memory appeared and then saccade target appeared (even if trial would be accepted otherwise)
    % % % %         if size(sx1,2)>1  && ~isnan(S.memory_on(tid)) && ~isnan(S.target1_on(tid)) && S.trialaccepted(tid)==-1
    % % % %
    % % % %             % Find saccade length
    % % % %             xsacc=sx1(:,5)-sx1(:,3);
    % % % %             ysacc=sx1(:,6)-sx1(:,4);
    % % % %             sacclength=sqrt((xsacc.^2)+(ysacc.^2));
    % % % %             starttimes=sx1(:,1);
    % % % %
    % % % %             % Settings on each trial used
    % % % %             minlatency=S.target1_on(tid);
    % % % %             maxlatency=S.target1_on(tid)+300;
    % % % %
    % % % %             % index1 is correct saccades
    % % % %             index1=sacclength>=threshold1 & starttimes>minlatency & starttimes<=maxlatency;
    % % % %             if sum(index1)>0
    % % % %                 for i=1:length(index1)
    % % % %                     if index1(i)==1
    % % % %                         mat1=[sx2(i,1),sx2(i,2),sx2(i,3),sx2(i,4),sx2(i,5),sx2(i,6),sx2(i,7)];
    % % % %                         h = plot ([mat1(1,3), mat1(1,5)], [mat1(1,4), mat1(1,6)]);
    % % % %                         set (h(end), 'LineWidth', wlinegraph, 'Color', color1(graphcond,:))
    % % % %                         set (h(end), 'Marker', marker1{graphcond}, 'MarkerFaceColor', color1(graphcond,:), ...
    % % % %                             'MarkerEdgeColor', color1(graphcond,:), 'MarkerSize', msize)
    % % % %                     end
    % % % %                 end
    % % % %             end
    % % % %
    % % % %             % If memory appeared but then saccade target did not appear
    % % % %         elseif size(sx1,2)>1  && ~isnan(S.memory_on(tid)) && S.trialaccepted(tid)==-1
    % % % %
    % % % %             % Find saccade length
    % % % %             xsacc=sx1(:,5)-sx1(:,3);
    % % % %             ysacc=sx1(:,6)-sx1(:,4);
    % % % %             sacclength=sqrt((xsacc.^2)+(ysacc.^2));
    % % % %             starttimes=sx1(:,1);
    % % % %
    % % % %             % Settings on each trial used
    % % % %             minlatency=S.memory_on(tid);
    % % % %             maxlatency=S.fixation_off(tid);
    % % % %
    % % % %             % index1 is correct saccades
    % % % %             index1=sacclength>=threshold1 & starttimes>minlatency & starttimes<=maxlatency;
    % % % %             if sum(index1)>0
    % % % %                 for i=1:length(index1)
    % % % %                     if index1(i)==1
    % % % %                         mat1=[sx2(i,1),sx2(i,2),sx2(i,3),sx2(i,4),sx2(i,5),sx2(i,6),sx2(i,7)];
    % % % %                         h = plot ([mat1(1,3), mat1(1,5)], [mat1(1,4), mat1(1,6)]);
    % % % %                         set (h(end), 'LineWidth', wlinegraph, 'Color', color1(graphcond,:))
    % % % %                         set (h(end), 'Marker', marker1{graphcond}, 'MarkerFaceColor', color1(graphcond,:), ...
    % % % %                             'MarkerEdgeColor', color1(graphcond,:), 'MarkerSize', msize)
    % % % %                     end
    % % % %                 end
    % % % %             end
    % % % %
    % % % %         end
    % % % %     end
    % % % %
    % % % %
    % % % %     set (gca,'FontSize', fontsz);
    % % % %     set(gca,'YTick', -6:6:6);
    % % % %     set(gca,'YLim',[-12 12]);
    % % % %     set(gca,'XTick', -6:6:6);
    % % % %     set(gca,'XLim',[-12 12]);
    % % % %
    % % % %
    % % % %     %===============
    % % % %     % Insert legend
    % % % %     %===============
    % % % %
    % % % %     for t1 = 1:size(target_coordinates,1)
    % % % %
    % % % %         objsize = S.raw_exp_settings{1}.stim.response_size(4);
    % % % %
    % % % %         h=rectangle('Position', [target_coordinates(t1,1)-objsize/2, target_coordinates(t1,2)-objsize/2, objsize, objsize],...
    % % % %             'EdgeColor', color1(t1,:), 'FaceColor', 'none', 'Curvature', 1, 'LineWidth', 1);
    % % % %     end
    % % % %
    % % % %
    % % % %
    % % % %
    % % % %
    % % % %
    % % % %
% end













% % Plot saccadic enpoints on trials when condition was classified as broke
% % fixation during memory delay
% % Latest revision - 12 August 2016
% % Donatas Jonikaitis
%
% % Figure settings
% figsize1=[0, 0, 2, 2];
% fontsz=8;
% fontszlabel=10;
%
% wlinegraph = 1; % Width of line for the graph
% marker1{1}='o'; marker1{2}='o'; marker1{3}='o'; marker1{4}='o';
% msize = 2;
%
% target_coordinates = unique([S.expmatrix(:,em_target_coord1), S.expmatrix(:,em_target_coord2)], 'rows');
%
% % Typical coordinates are [-6 6 combination]
% color1(1,:)=[0.6, 0.75, 1]; % [-6, -6];
% color1(2,:)=[0.3, 0.2, 0.8]; % [-6, 6];
% color1(3,:)=[1, 0.5, 0.55]; % [6, -6];
% color1(4,:)=[1, 0.1, 0.2]; % [6, 6];
%
% threshold1 = 2; % Saccade size to be considered
%
% if settings.plot_broken_trial_endpoints==1
%
%     % Select look/avoid task trials (those conditons are not present always)
%     expcond1=NaN(size(S.data,1),1);
%     index=S.maincond==1 & S.target_number==2;
%     if sum(index)>1
%         expcond1(index)=1;
%     end
%     index=S.maincond==2;
%     if sum(index)>1
%         expcond1(index)=2;
%     end
%     index=S.maincond==3;
%     if sum(index)>1
%         expcond1(index)=3;
%     end
%
%     % Recalculate each saccade as distance away from the target
%
%
%
%
%
%
%     %     for cond1 = 1:max(expcond1)
%
%     hfig = figure; hold on;
%
%     for tid=1:size(sacc1,1)
%
%         % Data to be used
%         sx1=sacc1{tid};
%         sx2=sacc1{tid};
%
%         % Setup figure colors
%         if S.expmatrix(tid,em_target_coord1)==target_coordinates(1,1) && S.expmatrix(tid,em_target_coord2)==target_coordinates(1,2)
%             graphcond = 1;
%         elseif S.expmatrix(tid,em_target_coord1)==target_coordinates(2,1) && S.expmatrix(tid,em_target_coord2)==target_coordinates(2,2)
%             graphcond = 2;
%         elseif S.expmatrix(tid,em_target_coord1)==target_coordinates(3,1) && S.expmatrix(tid,em_target_coord2)==target_coordinates(3,2)
%             graphcond = 3;
%         elseif S.expmatrix(tid,em_target_coord1)==target_coordinates(4,1) && S.expmatrix(tid,em_target_coord2)==target_coordinates(4,2)
%             graphcond = 4;
%         end
%
%         % If memory appeared and then saccade target appeared (even if trial would be accepted otherwise)
%         if size(sx1,2)>1  && ~isnan(S.memory_on(tid)) && ~isnan(S.target1_on(tid)) && S.trialaccepted(tid)==-1
%
%             % Find saccade length
%             xsacc=sx1(:,5)-sx1(:,3);
%             ysacc=sx1(:,6)-sx1(:,4);
%             sacclength=sqrt((xsacc.^2)+(ysacc.^2));
%             starttimes=sx1(:,1);
%
%             % Settings on each trial used
%             minlatency=S.target1_on(tid);
%             maxlatency=S.target1_on(tid)+300;
%
%             % index1 is correct saccades
%             index1=sacclength>=threshold1 & starttimes>minlatency & starttimes<=maxlatency;
%             if sum(index1)>0
%                 for i=1:length(index1)
%                     if index1(i)==1
%                         mat1=[sx2(i,1),sx2(i,2),sx2(i,3),sx2(i,4),sx2(i,5),sx2(i,6),sx2(i,7)];
%                         h = plot ([mat1(1,3), mat1(1,5)], [mat1(1,4), mat1(1,6)]);
%                         set (h(end), 'LineWidth', wlinegraph, 'Color', color1(graphcond,:))
%                         set (h(end), 'Marker', marker1{graphcond}, 'MarkerFaceColor', color1(graphcond,:), ...
%                             'MarkerEdgeColor', color1(graphcond,:), 'MarkerSize', msize)
%                     end
%                 end
%             end
%
%             % If memory appeared but then saccade target did not appear
%         elseif size(sx1,2)>1  && ~isnan(S.memory_on(tid)) && S.trialaccepted(tid)==-1
%
%             % Find saccade length
%             xsacc=sx1(:,5)-sx1(:,3);
%             ysacc=sx1(:,6)-sx1(:,4);
%             sacclength=sqrt((xsacc.^2)+(ysacc.^2));
%             starttimes=sx1(:,1);
%
%             % Settings on each trial used
%             minlatency=S.memory_on(tid);
%             maxlatency=S.fixation_off(tid);
%
%             % index1 is correct saccades
%             index1=sacclength>=threshold1 & starttimes>minlatency & starttimes<=maxlatency;
%             if sum(index1)>0
%                 for i=1:length(index1)
%                     if index1(i)==1
%                         mat1=[sx2(i,1),sx2(i,2),sx2(i,3),sx2(i,4),sx2(i,5),sx2(i,6),sx2(i,7)];
%                         h = plot ([mat1(1,3), mat1(1,5)], [mat1(1,4), mat1(1,6)]);
%                         set (h(end), 'LineWidth', wlinegraph, 'Color', color1(graphcond,:))
%                         set (h(end), 'Marker', marker1{graphcond}, 'MarkerFaceColor', color1(graphcond,:), ...
%                             'MarkerEdgeColor', color1(graphcond,:), 'MarkerSize', msize)
%                     end
%                 end
%             end
%
%         end
%     end
%
%
%     set (gca,'FontSize', fontsz);
%     set(gca,'YTick', -6:6:6);
%     set(gca,'YLim',[-12 12]);
%     set(gca,'XTick', -6:6:6);
%     set(gca,'XLim',[-12 12]);
%
%
%     %===============
%     % Insert legend
%     %===============
%
%     for t1 = 1:size(target_coordinates,1)
%
%         objsize = S.raw_exp_settings{1}.stim.response_size(4);
%
%         h=rectangle('Position', [target_coordinates(t1,1)-objsize/2, target_coordinates(t1,2)-objsize/2, objsize, objsize],...
%             'EdgeColor', color1(t1,:), 'FaceColor', 'none', 'Curvature', 1, 'LineWidth', 1);
%     end
%
%
%
%
%
%
%
%     %     end
%
%
% end