% Plot saccadic enpoints relative to the saccade (attended target)
% Latest revision - 29 July 2016
% Donatas Jonikaitis

% Heatmap of saccades

c1_heatmap= [1.0000    1.0000    1.0000
    0.9900    0.9900    0.9900
    0.9800    0.9800    0.9800
    0.9700    0.9700    0.9700
    0.9600    0.9600    0.9600
    0.9500    0.9500    0.9500
    0.9400    0.9400    0.9400
    0.9300    0.9300    0.9300
    0.9200    0.9200    0.9200
    0.9100    0.9100    0.9100
    0.9000    0.9000    0.9000
    0.8900    0.8900    0.8900
    0.8800    0.8800    0.8800
    0.8700    0.8700    0.8700
    0.8600    0.8600    0.8600
    0.8500    0.8500    0.8500
    0.8400    0.8400    0.8400
    0.8300    0.8300    0.8300
    0.8200    0.8200    0.8200
    0.8100    0.8100    0.8100
    0.8000    0.8000    0.8000
    0.8089    0.8052    0.7645
    0.8178    0.8103    0.7291
    0.8267    0.8155    0.6936
    0.8357    0.8207    0.6581
    0.8446    0.8258    0.6226
    0.8535    0.8310    0.5872
    0.8624    0.8362    0.5517
    0.8713    0.8414    0.5162
    0.8802    0.8465    0.4807
    0.8891    0.8517    0.4453
    0.8980    0.8569    0.4098
    0.9070    0.8620    0.3743
    0.9159    0.8672    0.3389
    0.9248    0.8724    0.3034
    0.9337    0.8775    0.2679
    0.9426    0.8827    0.2324
    0.9515    0.8879    0.1970
    0.9604    0.8930    0.1615
    0.9693    0.8982    0.1260
    0.9783    0.9034    0.0906
    0.9872    0.9086    0.0551
    0.9961    0.9137    0.0196
    0.9817    0.8710    0.0194
    0.9673    0.8282    0.0192
    0.9529    0.7854    0.0190
    0.9386    0.7427    0.0189
    0.9242    0.6999    0.0187
    0.9098    0.6571    0.0185
    0.8954    0.6144    0.0183
    0.8810    0.5716    0.0181
    0.8667    0.5289    0.0179
    0.8523    0.4861    0.0177
    0.8379    0.4433    0.0176
    0.8235    0.4006    0.0174
    0.8092    0.3578    0.0172
    0.7948    0.3150    0.0170
    0.7804    0.2723    0.0168
    0.7660    0.2295    0.0166
    0.7516    0.1867    0.0164
    0.7373    0.1440    0.0162
    0.7229    0.1012    0.0161
    0.7085    0.0585    0.0159
    0.6941    0.0157    0.0157];


fontsz=10;
fontszlabel=10;
legend_on=1;

%% Figure 1 - heatmap of saccadic endpoints

if settings.plot_sacc_endpoints==1
    
    %==============
    % Settings
    figsize1=[0,0,3,3];
    
    % Determine target radius
    radius1 = 8.5;
    coord_plot = 6; % X,Y setup coordinates
    
    % Create matrices for target detection
    t_step=0.2;
    distmat_x=[-12:t_step:12]; % Specifies figure limits
    distmat_y=[-12:t_step:12]; % Specifies figure limits
    
    % Select look/avoid task trials (those conditons are not present always)
    expcond1=NaN(size(S.data,1),1);
    index=S.maincond==1 & S.trialaccepted==-1 & S.target_number==2;
    if sum(index)>1
        expcond1(index)=1;
    end
    index=S.maincond==2 & S.trialaccepted==-1 & target_number==2;
    if sum(index)>1
        expcond1(index)=2;
    end
    index=S.maincond==3 & S.trialaccepted==-1 & target_number==1;
    if sum(index)>1
        expcond1(index)=3;
    end
    
    % Prepare figure titles
    title_text{1}='Look';
    title_text{2}='Avoid';
    title_text{3}='Control';
    sacc_target1_angle = [45:90:359]; % Target angles to plot
    
    %============
    % Angle for rotation
    
    displace1=NaN(size(S.data,1),1);
    var11=45; % Angle to which rotate
    
    % Find angle of the saccade target
    [theta,rho]=cart2pol(S.st_coord(:,1),S.st_coord(:,2));
    theta = round(rad2deg(theta));
    
    
    index=expcond1==1;
    displace1(index) = var11 -  theta(index);
    index=expcond1==2;
    displace1(index) = var11 -  theta(index);
    index=expcond1==3;
    displace1(index) = var11 -  theta(index);
    
    displace1(displace1>=360)=displace1(displace1>=360)-360;
    displace1(displace1<0)=displace1(displace1<0)+360;
    
    %================
    % Rotate data of saccade endpoints
    sacmatrix = S.data;
    sm1=NaN(length(sacmatrix),6);
    
    % Start position
    anglex1=displace1; x=sacmatrix(:,3); y=sacmatrix(:,4);
    xn = cosd(anglex1).*x - sind(anglex1).*y;
    yn = sind(anglex1).*x + cosd(anglex1).*y;
    sm1(:,3)=xn; sm1(:,4)=yn;
    
    % End position
    anglex1=displace1; x=sacmatrix(:,5); y=sacmatrix(:,6);
    xn = cosd(anglex1).*x - sind(anglex1).*y;
    yn = sind(anglex1).*x + cosd(anglex1).*y;
    sm1(:,5)=xn; sm1(:,6)=yn;
    
    
    %=================
    % Rotate data of fixations
    
    sm2=NaN(length(sacmatrix),6);
    
    for tid=1:size(sacmatrix,1)
        
        sx2=saccraw1{tid}; % Raw data
        
        if length(sx2)>1
            if ~isnan(S.fixation_acquired(tid)) && ~isnan(S.fixation_off(tid))
                
                fixtime1=S.drift_maintained(tid);
                fixtime2=S.fixation_off(tid);
                
                index1=sx2(:,1)>=fixtime1 & sx2(:,1)<=fixtime2;
                coord1=[];
                coord1(1)=nanmean(sx2(index1,2));
                coord1(2)=nanmean(sx2(index1,3));
                
                % Average position rotated
                anglex1=displace1(tid); x=coord1(1); y=coord1(2);
                xn = cosd(anglex1)*x - sind(anglex1)*y;
                yn = sind(anglex1)*x + cosd(anglex1)*y;
                sm2(tid,5)=xn; sm2(tid,6)=yn;
            elseif isnan(S.fixation_acquired(tid))
                sm2(tid,5)=NaN; sm2(tid,6)=NaN;
            end
        else
            sm2(tid,5)=NaN; sm2(tid,6)=NaN;
        end
    end
    
    
    %================
    % Prepare a matrix with coordinates
    coords1 = CombVec(distmat_x, distmat_y)'; % Contains all combinations of coordinates (x,y)
    coords2 = CombVec([1:length(distmat_x)], [1:length(distmat_y)])'; % Contains coordinates
    mat1_raw=zeros(length(distmat_y), length(distmat_x));
    mat1_normalized=[];
    
    
    % Manual distance check
    for cond1=1:max(expcond1)
        
        % Select data
        temp1=sm1(expcond1==cond1,:);
        
        for y1=1:length(distmat_y)
            for x1=1:length(distmat_x)
                index = (temp1(:,6)>=distmat_y(y1)-t_step & temp1(:,6)<distmat_y(y1)+t_step) &...
                    (temp1(:,5)>=distmat_x(x1)-t_step & temp1(:,5)<distmat_x(x1)+t_step);
                mat1_raw(y1,x1)=sum(index);
            end
        end
        
        % Reset to maximum
        mat1_raw=mat1_raw/max(mat1_raw(:));
        mat1_normalized(:,:,cond1)=mat1_raw;
    end
    
    
    % PLOT
    for fig1=1:size(mat1_normalized,3)
        
        if sum(sum(mat1_normalized(:,:,fig1)))>0
            
            hfig=figure;
            hold on;
            
            % Add dummy interval bounds (due to limits in matlab)
            mat1=mat1_normalized(:,:,fig1);
            
            % PLOT
            
            [h,C]=contourf(mat1, 'LineColor', 'none',  'LevelListMode', 'manual', 'LevelList', [0:0.1:1]);
            colormap(c1_heatmap)
            
            if legend_on==1
                colorbar('XTick',[0:0.5:1],'location', 'EastOutside')
            end
            
            %=============
            % Plot fixation
            % Settings and coordinates
            objsize=1;
            fcolor1=[0.2, 0.2, 0.2];
            xc=[]; yc=[];
            xc(1,1)=0; yc(1,1)=0; % Fixation
            % No changes from this part
            coord1=[];
            for i=1:length(xc) % Prepare as many coordinates as needed
                coord1(i,1)=xc(i)-objsize/2;
                coord1(i,2)=yc(i)-objsize/2;
                coord1(i,3)=xc(i)+objsize/2;
                coord1(i,4)=yc(i)+objsize/2;
            end
            % Convert to heatmap coordinates (X)
            x1=1:length(distmat_x); % How many time bins are there?
            plotbins_x=distmat_x; % Recenter intervalbins to the center of the bin
            p_x=polyfit(plotbins_x,x1,1);
            % Convert to heatmap coordinates (Y)
            y1=1:length(distmat_y); % How many time bins are there?
            plotbins_y=distmat_y; % Recenter intervalbins to the center of the bin
            p_y=polyfit(plotbins_y,y1,1);
            % Points with fitted coordinates
            ticks1_x=coord1;
            ticks2_x=polyval(p_x,ticks1_x);
            ticks1_y=coord1;
            ticks2_y=polyval(p_y,ticks1_y);
            % Plot coordinates
            ticks3=[];
            ticks3(:,1)=ticks2_x(:,1);
            ticks3(:,2)=ticks2_y(:,2);
            ticks3(:,3)=abs(ticks2_x(:,3)-ticks2_x(:,1));
            ticks3(:,4)=abs(ticks2_y(:,4)-ticks2_y(:,2));
            % Plot
            for i=1:size(ticks3,1)
                h=rectangle('Position', ticks3(i,:),...
                    'EdgeColor', fcolor1, 'FaceColor', 'none', 'Curvature', 0, 'LineWidth', 1);
            end
            
            %=============
            % Plot saccade targets
            % Settings and coordinates
            objsize=1;
            fcolor1=[0.2, 0.2, 0.2];
            angle1=sacc_target1_angle;
            radiusdeg=radius1;
            xc=[]; yc=[];
            [xc, yc] = pol2cart(angle1*pi/180,radiusdeg);
            % No changes from this part
            coord1=[];
            for i=1:length(xc) % Prepare as many coordinates as needed
                coord1(i,1)=xc(i)-objsize/2;
                coord1(i,2)=yc(i)-objsize/2;
                coord1(i,3)=xc(i)+objsize/2;
                coord1(i,4)=yc(i)+objsize/2;
            end
            % Convert to heatmap coordinates (X)
            x1=1:length(distmat_x); % How many time bins are there?
            plotbins_x=distmat_x; % Recenter intervalbins to the center of the bin
            p_x=polyfit(plotbins_x,x1,1);
            % Convert to heatmap coordinates (Y)
            y1=1:length(distmat_y); % How many time bins are there?
            plotbins_y=distmat_y; % Recenter intervalbins to the center of the bin
            p_y=polyfit(plotbins_y,y1,1);
            % Points with fitted coordinates
            ticks1_x=coord1;
            ticks2_x=polyval(p_x,ticks1_x);
            ticks1_y=coord1;
            ticks2_y=polyval(p_y,ticks1_y);
            % Plot coordinates
            ticks3=[];
            ticks3(:,1)=ticks2_x(:,1);
            ticks3(:,2)=ticks2_y(:,2);
            ticks3(:,3)=(ticks2_x(:,3)-ticks2_x(:,1));
            ticks3(:,4)=(ticks2_y(:,4)-ticks2_y(:,2));
            % Plot
            for i=1:size(ticks3,1)
                h=rectangle('Position', ticks3(i,:),...
                    'EdgeColor', fcolor1, 'FaceColor', 'none', 'Curvature', 0, 'LineWidth', 1);
            end
            
            
            %===============
            % Figure setup
            set (gca,'FontSize', fontsz);
            axis('square')
            
            % Define X axis & set tick labels
            x1=1:length(distmat_x); % How many time bins are there?
            plotbins_x=distmat_x; % Recenter intervalbins to the center of the bin
            p=polyfit(plotbins_x,x1,1);
            ticks1=[-coord_plot:coord_plot:coord_plot];
            ticks2=polyval(p,ticks1);
            
            set(gca,'XLim',[1,size(mat1,2)])
            set(gca,'XTick',ticks2) % X-tick
            set(gca,'XTickLabel',ticks1); % Set the lables
            xlabel ('Horizontal (deg)', 'FontSize', fontszlabel);
            
            % Define Y axis & set tick labels
            y1=1:length(distmat_y); % How many time bins are there?
            plotbins_y=distmat_y; % Recenter intervalbins to the center of the bin
            p=polyfit(plotbins_y,y1,1);
            ticks1=[-coord_plot:coord_plot:coord_plot];
            ticks2=polyval(p,ticks1);
            
            set(gca,'YLim',[1,size(mat1,1)])
            set(gca,'YTick',ticks2) % Y-tick
            set(gca,'YTickLabel',ticks1); % Set the lables
            ylabel ('Vertical (deg)', 'FontSize', fontszlabel);
            
            % Figure title
            title ([title_text{fig1}], 'FontSize', fontszlabel)
            mat1=[];
            
            %============
            % Export the figure & save it
            cdDir = settings.path_preprocessing_figures;
            subjectName = [settings.subject_name, num2str(settings.subject_name_date)];
            rundirexp=[cdDir, subjectName,'/', 'saccade_heatmap/'];
            try
                cd(rundirexp)
            catch
                mkdir(rundirexp)
            end
            
            
            fileName=[rundirexp,'sacc_', num2str(fig1)];
            set(gcf, 'PaperPositionMode', 'manual');
            set(gcf, 'PaperUnits', 'inches');
            set(gcf, 'PaperPosition', figsize1)
            set(gcf, 'PaperSize', [figsize1(3),figsize1(4)]);
            print (fileName, '-dpdf')
            %===============
            
            
        end
        
        close all;
        
    end
    
    %% Add fixation plot
    
    if settings.plot_sacc_endpoints==1
        
        figsize1=[0,0,3,1.7];
        
        % Y axis - accuracy of fixation
        amp1=[-3, 3]; % Y
        nsteps1=50;
        distmat_y=linspace(amp1(1),amp1(2),nsteps1);
        
        % X axis - fixtation duration
        amp2 = [0; max(S.fixation_off - S.fixation_acquired)];
        distmat_x=[amp2(1):1:amp2(2)];
        
        disp ('Plotting fixation heatmap, that usually takes a while...')
        
        % Matrix
        
        mat1=zeros(length(distmat_y), length(distmat_x), max(expcond1));
        
        for tid=1:size(sacc1,1)
            for j=1:length(distmat_x)
                
                % Select time data - after fixation acquired, before fixation
                % is of
                sacc_mat = saccraw1{tid};
                
                if ~isnan(S.fixation_acquired(tid)) && ~isnan(S.fixation_off(tid))
                    
                    % Remove "pre-fixation acquired" and "post-fixation offset" data
                    index=sacc_mat(:,1)<S.fixation_acquired(tid);
                    sacc_mat(index,1) = NaN;
                    index=sacc_mat(:,1)>S.fixation_off(tid);
                    sacc_mat(index,1) = NaN;
                    
                    % Reset to "fixation acquired" time
                    sacc_mat(:,1)=sacc_mat(:,1)-S.fixation_acquired(tid);
                    
                    index1=sacc_mat(:,1)==distmat_x(j); % Select time points of interest
                    x1=sacc_mat(index1,2); y1=sacc_mat(index1,3); % Get x & y coordintas
                    
                    if length(x1)>=1
                        
                        % Calculate amplitude of the eye position
                        eyecoord1 = sqrt(x1.^2 + y1.^2);
                        eyecoord1=nanmean(eyecoord1);
                        
                        % Save data into matrix
                        dim1=expcond1(tid);
                        ind1=distmat_y-eyecoord1; ind1=abs(ind1); ind2=min(ind1);
                        ind1_mat1 = ind1==ind2;
                        if dim1>=1
                            mat1(ind1_mat1,j,dim1)=mat1(ind1_mat1,j,dim1)+1;
                        end
                    end
                end
            end
        end
    end
    
    % Recalculate into % of saccades
    for k=1:size(mat1,3)
        a1=max(max(mat1(:,:,k))); % Max number of trials
        mat1(:,:,k)=mat1(:,:,k)./a1;
    end
    
    %==========
    %==========
    % INDIVIDUAL SUBJECTS PLOT
    
    for fig1=1:size(mat1,3)
        
        if sum(sum(mat1(:,:,fig1)))>0
            
            hfig=figure;
            hold on;
            
            % Restructure data, add dummy interval bounds (due to limits in matlab)
            plot_mat1=mat1(:,:,fig1);
            
            % PLOT
            [h,C]=contourf(plot_mat1, 'LineColor', 'none',  'LevelListMode', 'manual', 'LevelList', [0:0.1:1]);
            colormap(c1_heatmap)
            
            if legend_on==1
                colorbar('XTick',[0:0.5:1],'location', 'EastOutside')
            end
            
            
            %===============
            % Figure setup
            set (gca,'FontSize', fontsz);
            
            % Define vertical axis & set tick labels
            x1=1:length(distmat_y); % How many time bins are there?
            plotbins=distmat_y; % Recenter intervalbins to the center of the bin
            p=polyfit(plotbins,x1,1);
            ticks1=[-1,0,1];
            ticks2=polyval(p,ticks1);
            
            set(gca,'YLim',[1,size(plot_mat1,1)])
            set(gca,'YTick',ticks2) % Y-tick
            set(gca,'YTickLabel',ticks1); % Set the lables
            ylabel ('Eye position (deg)', 'FontSize', fontszlabel);
            
            % Define horizontal axis & set tick labels
            x1=1:length(distmat_x); % How many time bins are there?
            plotbins=distmat_x; % Recenter intervalbins to the center of the bin
            p=polyfit(plotbins,x1,1);
            ticks1=[0:500:amp2(2)];
            ticks2=polyval(p,ticks1);
            
            set(gca,'XLim',[-50,size(plot_mat1,2)+50])
            set(gca,'XTick',ticks2) % X-tick
            set(gca,'XTickLabel',ticks1); % Set the lables
            xlabel ('Time (ms)', 'FontSize', fontszlabel);
            
            % Figure title
            title ([title_text{fig1}], 'FontSize', fontszlabel)
            
            %============
            % Export the figure & save it
            cdDir = settings.path_preprocessing_figures;
            subjectName = [settings.subject_name, num2str(settings.subject_name_date)];
            rundirexp=[cdDir, subjectName,'/', 'saccade_heatmap/'];
            try
                cd(rundirexp)
            catch
                mkdir(rundirexp)
            end
            
            
            fileName=[rundirexp,'fix_', num2str(fig1)];
            set(gcf, 'PaperPositionMode', 'manual');
            set(gcf, 'PaperUnits', 'inches');
            set(gcf, 'PaperPosition', figsize1)
            set(gcf, 'PaperSize', [figsize1(3),figsize1(4)]);
            print (fileName, '-dpdf')
            %===============
            
            close all;
            
        end
    end
    
    disp ('Done!')
    
end
