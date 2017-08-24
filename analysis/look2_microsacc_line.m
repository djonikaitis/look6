% Plot line graph of performance at different locations

clear all;
close all;
clc;

% Loading the files needed
settings.exp_name = 'look2';
sN1='aq';

% Load general settings
settings_look2;

% Settings
settings.subject_no = length(settings.subject_name); % How many subjects in total used

settings.figsize=[0,0,2.2,2.2];
settings.marker_on = 0; % Plot the marker?
settings.error_bars = 2; % 1 - bootstrap; 2 - sem;
tboot1=1000; % How many times to bootstrap

% Local settings
settings.timestep=100;
settings.intervalbins_fixon = [0:settings.timestep:1000]; % Bins locked to cue
settings.intervalbins_memon = [-400:settings.timestep:1000];
settings.intervalbins_cueon = [-400:settings.timestep:200];
settings.normvar1=200; % Milisecconds used for each time bin (for sliding window size)
settings.xd=0; % Time when probe is removed relative to saccade onset


settings.figure_folder_name = 'microssaccades_line';

% Saving statistics
settings.runstatistics=0; % Run statistics?


%% LOAD DATA AND ANALYZE (ALL SUBJECTS SEPARATE)

% Load and select data
for subj1= 1:length(settings.subject_name)
    
    %===============
    % Initialize text file for statistics
    if settings.runstatistics==1
        
        settings.analysis_output_path=[settings.figures_directory, settings.figure_folder_name, '/', settings.subject_name{subj1}, '/']; % Path to analysis
        try
            cd(settings.analysis_output_path)
        catch
            mkdir(settings.analysis_output_path)
        end
        nameOut=[settings.analysis_output_path, 'statistics_', sN1, '.txt']; % File to be outputed
        
        fclose('all');
        fout = fopen(nameOut,'w');
    end
    
    %================
    % Change directory to data folder
    cd(settings.data_directory);
    index_directory = dir;
    subject_name = settings.subject_name{subj1};
    
    %==================
    % Determine how many unique days are there & and which session numbers were
    % recorded on which day (this compensates for sessions skips)
    index_dates = NaN(1,length(index_directory));
    index_sessions = NaN(1,length(index_directory));
    data_prefix = 'look2_';
    for i=1:length(index_directory)
        if length (index_directory(i).name) == length(subject_name)+8 % if file name is the right length
            a1 = index_directory(i).name(length(subject_name)+1:length(subject_name)+8);
            if length(str2num(a1))==1 && strcmp(index_directory(i).name(1:length(subject_name)), subject_name);
                index_dates(i) = str2num(a1);
            end
        end
        index_unique_days = unique(index_dates);
        ind=isnan(index_unique_days); index_unique_days(ind)=[];
    end
    %==================
    
    %==================
    
    % Run analysis for each unique session
    for current_day = 1:length(index_unique_days); % For each recorded day
        
        %===================
        % Which folder number to load
        ind1 = index_dates == index_unique_days(current_day);
        
        % Change directory to individual eyelink folder
        current_dirname = index_directory(ind1).name; % Whats current directory name
        cdDir=(sprintf('%s%s', settings.data_directory, current_dirname));
        cd(cdDir);
        current_filename = sprintf('%s_%s.mat',settings.exp_name, current_dirname); % Check whether data file exists
        load (eval('current_filename'));
        current_filename = sprintf('sacc_engbert.mat'); % Check whether data file exists
        load (eval('current_filename'));
        
        
        %==========
        % Mark conditions of the trials
        S.expcond=NaN(size(S.data,1),1);
        index1 = S.maincond==1 & S.trialaccepted==-1;
        S.expcond(index1) = 1;
        index1 = S.maincond==2 & S.trialaccepted==-1;
        S.expcond(index1) = 2;
        
        
        %==============
        % Take each micro-saccade and save it as a part of the trial
        A.mat1=[];
        % Initialize empty structure A
        f1_data = fieldnames(S);
        for k=1:length(f1_data);
            if size(S.(f1_data{k}),1)==size(S.trialaccepted,1)
                A.(sprintf(f1_data{k}))=[];
            end
        end
        
        %===========
        % Create new structure array with data for each saccade
        for i=1:length(sacc1) % For each trial
            
            % If there are any saccades recorded
            if size(sacc1{i},2)>1
                for j=1:size(sacc1{i},1) % For each recorded saccade
                    
                    % How many saccades are recorded already?
                    ind1=size(A.mat1,1);
                    ind1 = ind1+1;
                    
                    % Eye coordionates
                    m1=sacc1{i}(j,:);
                    A.mat1(ind1,1:7)=m1;
                    
                    % Every other usable field in the structure
                    f1_data = fieldnames(S);
                    for k=1:length(f1_data);
                        if size(S.(f1_data{k}),1)==size(S.trialaccepted,1)
                            A.(f1_data{k})(ind1,:)=S.(f1_data{k})(i,:);
                        end
                    end
                end
                % End of analysis if there were any saccades recorded on a
                % given trial
                
                % If no saccades are recorded
            elseif size(sacc1{i},2)==1
                
                % How many saccades are recorded already?
                ind1=size(A.mat1,1);
                ind1 = ind1+1;
                
                % Eye coordinates
                A.mat1(ind1,1:7)=NaN;
                f1_data = fieldnames(S);
                % Every other usable field in the structure
                for k=1:length(f1_data);
                    if size(S.(f1_data{k}),1)==size(S.trialaccepted,1)
                        A.(f1_data{k})(ind1,:)=S.(f1_data{k})(i,:);
                    end
                end
                
            end
        end
        clear sacc1;
        % End of loop restructuring the matrix
        
        % Saccade amplitude calculations
        xsacc=A.mat1(:,5)-A.mat1(:,3);
        ysacc=A.mat1(:,6)-A.mat1(:,4);
        A.sacc_amplitude=sqrt((xsacc.^2)+(ysacc.^2)); % Saccade amplitude
        
        % Remove too long saccades
        index=A.sacc_amplitude(:,1)>=1;
        A.mat1(index,:)=NaN;
        A.sacc_amplitude(index,:)=NaN;
        
        % Remove reponse related saccades
        index = A.mat1(:,1)>=A.sacconset;
        A.mat1(index,:)=NaN;
        
        
        %============
        %============
        %  Calculate microsaccade/saccade direction
        
        % Initialize variables for rotation
        stemp2=NaN(size(A.mat1));
        stemp2(:,1:2)=A.mat1(:,1:2); % Save time
        
        %===============
        % Select location to which resetting is done
        var11=0;
        displace1=NaN(size(A.trialaccepted,1),1);
        displace1 = var11 - A.mem_arc;
        %================
        
        % Calculate resetting angles
        displace1(displace1>=360)=displace1(displace1>=360)-360;
        displace1(displace1<0)=displace1(displace1<0)+360;
        
        % Start position rotation
        angle=displace1; x=A.mat1(:,3); y=A.mat1(:,4);
        xn = cosd(angle).*x - sind(angle).*y;
        yn = sind(angle).*x + cosd(angle).*y;
        stemp2(:,3)=xn; stemp2(:,4)=yn;
        
        % End position rotation
        angle=displace1; x=A.mat1(:,5); y=A.mat1(:,6);
        xn = cosd(angle).*x - sind(angle).*y;
        yn = sind(angle).*x + cosd(angle).*y;
        stemp2(:,5)=xn; stemp2(:,6)=yn;
        
        % Rotated output is saved into A.mat2
        A.mat2=stemp2; stemp2=[];
        
        % Calculate the position of the rotated data endpoints
        A.xangle=NaN(length(A.mat2),1);
        a=atan2(A.mat2(:,6), A.mat2(:,5)); % Angle of saccade endpoint
        index = a>=0; % Convert PI angle into degrees
        A.xangle(index)=180*(a(index)/pi);
        index = a<0; % Convert PI angle into degrees
        A.xangle(index)=360+(180*a(index)/pi);
        
        %=============
        %=============
        %=============
        
        
        % Calculate conds for each saccade direction
        A.displace1=NaN(size(A.xangle));
        
        % Micro-saccades towards memory target
        index = A.xangle(:,1)>=0 & A.xangle(:,1)<45;
        A.displace1(index,1)=1;
        index = A.xangle(:,1)>=315 & A.xangle(:,1)<=360;
        A.displace1(index,1)=1;
        % Other targets
        index = A.xangle(:,1)>=45 & A.xangle(:,1)<135;
        A.displace1(index,1)=2;
        index = A.xangle(:,1)>=135 & A.xangle(:,1)<225;
        A.displace1(index,1)=3;
        index = A.xangle(:,1)>=225 & A.xangle(:,1)<315;
        A.displace1(index,1)=4;
        
        %=============
        %=============
        %=============
        %============
        % Prepare micro-saccade analysis time-course
        
        % Loop for different timing conditions
        for reset1 = 1:2
            if reset1==1
                % Copy data
                intervalbins = settings.intervalbins_fixon;
                A.mat3 = A.mat2;
                % Remove post-memory data
                index = A.mat3(:,1)>A.memory_on;
                A.mat3(index,:) = NaN;
                % Reset data to interval desired
                A.mat3(:,1)=A.mat3(:,1)-A.drift_maintained; % Add duration of the fixation and of the delay
                A.mat3(:,2)=A.mat3(:,2)+A.drift_maintained; % Add duration of the fixation and of the delay
                % Leave only eye movements executed during measured interval
                index = A.mat3(:,1)<intervalbins(1) | A.mat1(:,1)>intervalbins(end);
                A.mat3(index,:)=NaN;
                % Save what is last time point to be measured in the analysis
                S.endvar = NaN(size(S.sacconset,1),1);
                S.endvar=S.memory_on - S.drift_maintained; % Cue onset
            elseif reset1==2
                % Copy data
                intervalbins = settings.intervalbins_memon;
                A.mat3 = A.mat2;
                % Remove post-cue data
                index = A.mat3(:,1)>A.target1_on;
                A.mat3(index,:) = NaN;
                % Reset data to interval desired
                A.mat3(:,1)=A.mat3(:,1)-A.memory_on; % Add duration of the fixation and of the delay
                A.mat3(:,2)=A.mat3(:,2)+A.memory_on; % Add duration of the fixation and of the delay
                % Leave only eye movements executed during measured interval
                index = A.mat3(:,1)<intervalbins(1) | A.mat1(:,1)>intervalbins(end);
                A.mat3(index,:)=NaN;
                % Save what is last time point to be measured in the analysis
                S.endvar = NaN(size(S.sacconset,1),1);
                S.endvar(1:end)=S.target1_on - S.memory_on; % Cue onset
            elseif reset1==3
%             % Copy data
%             intervalbins = settings.intervalbins_cueon;
%             A.mat3 = A.mat2;
%             % Do not remove post-cue data; post-saccadic data is already
%             % removed
%             % No reset data to interval needed
%             % Leave only eye movements executed during measured interval
%             index = A.mat3(:,1)<intervalbins(1) | A.mat1(:,1)>intervalbins(end);
%             A.mat3(index,:)=NaN;
%             A.saccamplitude1(index,:)=NaN;
%             % Save what is last time point to be measured in the analysis
%             S.endvar = NaN(size(S.sacconset,1),1);
%             S.endvar(1:end)=S.sacconset; % Saccade onset
            end
            
            %==========
            % Initialize empty matrices (many matrices, sorry, but saves loads of computation by not running this loop with each microsaccade)
            
            if current_day==1
                a1=NaN(length(index_unique_days), length(intervalbins), max(removeNaN(A.displace1)), 1);
                if reset1==1
                    S_fixon.mat1=a1;
                    S_fixon.test1=a1;
                    S_fixon.test2=a1;
                    S_fixon.test3=a1;
                elseif reset1==2
                    S_memon.mat1=a1;
                    S_memon.test1=a1;
                    S_memon.test2=a1;
                    S_memon.test3=a1;
                elseif reset1==3
                    S_cueon.mat1=a1;
                    S_cueon.test1=a1;
                    S_cueon.test2=a1;
                    S_cueon.test3=a1;
                end
            end
            
            % Select proper matrices for each subject and time conditoon
            if reset1==1
                mat1=S_fixon.mat1;
                test1=S_fixon.test1;
                test2=S_fixon.test2;
                test3=S_fixon.test3;
            elseif reset1==2
                mat1=S_memon.mat1;
                test1=S_memon.test1;
                test2=S_memon.test2;
                test3=S_memon.test3;
            elseif reset1==3
                mat1=S_cueon.mat1;
                test1=S_cueon.test1;
                test2=S_cueon.test2;
                test3=S_cueon.test3;
            end
            
            %======================
            %  Time course of the micro-saccade directions

            
            for j=1:length(intervalbins)
                for k=1:max(removeNaN(A.displace1))
                    for m=1:max(removeNaN(A.expcond))
                        
                        index1 = (A.mat3(:,1)>=intervalbins(j) & A.mat3(:,1)<intervalbins(j)+settings.normvar1) & ...
                            A.expcond==m & A.displace1==k;
                        
                        % How many microsaccades were found the bin?
                        test1(current_day,j,k,m)=sum(index1);
                        
                        % Number of trials recorded
                        index2 = S.expcond==m;
                        test2(current_day,j,k,m)=sum(index2); % Save to check how many trials are available
                        
                        % Determine the limit of the trial (duration or saccade onset)
                        x1=S.endvar-1; % Saccade onset ends the trial duration
                        x1(isnan(x1))=intervalbins(end)+settings.normvar1; % If no saccade detected, then trial duration is the limit
                        x1(S.trialaccepted~=-1 & S.trialaccepted~=-2)=NaN; % If trial was rejected, remove it
                        a1 = x1 (index2);
                        
                        % Define interval used for calculation of frequency
                        lower_a1 = NaN(length(a1),1); % Matrix with lower limit
                        lower_a1(1:end)=intervalbins(j);
                        higher_a1 = NaN(length(a1),1); % Matrix with higher limit
                        higher_a1(1:end)=intervalbins(j)+settings.normvar1;
                        index1 = lower_a1 >= a1; % Find cases where lower limit is past delay duration
                        lower_a1(index1)=NaN; higher_a1(index1)=NaN; % And replace it with NaN;
                        index1 = higher_a1 >= a1; % Find cases where higher limit is past delay duration
                        higher_a1(index1)=a1(index1); % Replace it with maximum limit of the delay
                        diff_a1=higher_a1-lower_a1;
                        
                        % Save it into matrix
                        test3(current_day,j,k,m)=nansum(diff_a1);
                        test3(current_day,j,k,m)=test3(current_day,j,k,m)./1000; % Convert it to seconds
                        
                        
                        % Find frequency of responses
                        if test3(current_day,j,k,m)>settings.trial_total_threshold
                            mat1(current_day,j,k,m)=test1(current_day,j,k,m)/test3(current_day,j,k,m);
                        else
                            mat1(current_day,j,k,m)=NaN;
                        end
                        
                        
                    end
                end
            end
            % End of the loop calculating microsaccade frequency

        %=============
        % Save the data
        if reset1==1
            S_fixon.mat1=mat1;
            S_fixon.test1=test1;
            S_fixon.test2=test2;
            S_fixon.test3=test3;
        elseif reset1==2
            S_memon.mat1=mat1;
            S_memon.test1=test1;
            S_memon.test2=test2;
            S_memon.test3=test3;
        elseif reset1==3
            S_cueon.mat1=mat1;
            S_cueon.test1=test1;
            S_cueon.test2=test2;
            S_cueon.test3=test3;
        end

            
            
        end
        % End of the loop for each intervalbins version (three used)
        
        
        
        
        
        
        % % % %         %=============
        % % % %         % Combine data from all days
        % % % %         if current_day==1
        % % % %             A = S;
        % % % %         elseif current_day>1
        % % % %             f1_data = fieldnames(A);
        % % % %             for i=1:length(f1_data);
        % % % %                 try
        % % % %                     A.(f1_data{i})=[A.(f1_data{i}); S.(f1_data{i})];
        % % % %                 end
        % % % %             end
        % % % %         end
        %============
        
        
        
    end
    % End of analysis for each day
    
% % % % % %     % Save the data into structure S
% % % % % %     S = A;
% % % % % %     
end
% End of analysis for each subject





% %% FIGURE SHOWING SACCADE AMPLITUDES
%
%
% for reset1 = 1:3
%
%     % initialize variables
%     if reset1==1
%         mat1=S_fixon.mat1;
%         intervalbins = settings.intervalbins_fixon;
%     elseif reset1==2
%         mat1=S_memoff.mat1;
%         intervalbins = settings.intervalbins_memoff;
%     elseif reset1==3
%         mat1=S_cueon.mat1;
%         intervalbins = settings.intervalbins_cueon;
%     end
%
%     % Avoid division by 0
%     mat1(mat1==0)=0.001;
%
%     pbins=[];
%     for j=1:length(intervalbins)
%         pbins(j)=intervalbins(j)+settings.normvar1/2;
%     end
%
%     % Start main loops
%
%     for fig_legend1=2 % LEGEND ON OR OFF
%
%         for fig1=1:2
%
%             hfig=figure;
%             hold on;
%
%             % Initialize data
%             aaa=[];legend1={};
%             if fig1==1
%                 aaa(:,:,1)=mat1(:,:,1,1);
%                 aaa(:,:,2)=mat1(:,:,2,1);
%                 aaa(:,:,3)=mat1(:,:,3,1);
%                 figcolor1=[4,5,6];
%                 title1='Correct trials';
%                 save_name = sprintf('fig1_reset%i', reset1);
%                 legend1{1} = 'Saccade';
%                 legend1{2} = 'Non-selected';
%                 legend1{3} = 'Irrelevant';
%             elseif fig1==2
%                 aaa(:,:,1)=mat1(:,:,1,2);
%                 aaa(:,:,2)=mat1(:,:,2,2);
%                 aaa(:,:,3)=mat1(:,:,3,2);
%                 figcolor1=[4,5,6];
%                 title1='Error trials';
%                 save_name = sprintf('fig2_reset%i', reset1);
%                 legend1{1} = 'Saccade';
%                 legend1{2} = 'Non-selected';
%                 legend1{3} = 'Irrelevant';
%             end
%
%             %===================
%             % Plot legend markers
%             if fig_legend1==2
%
%                 % Set axes for legent
%                 if fig1==1 || fig1==2
%                     if reset1==1
%                         x1 = [pbins(end), pbins(end), pbins(end)]; y1 = [0.42, 0.35, 0.28];
%                     elseif reset1==2
%                         x1 = [pbins(end), pbins(end), pbins(end)]; y1 = [0.34, 0.30, 0.26];
%                     elseif reset1==3
%                         x1 = [pbins(end), pbins(end), pbins(end)]; y1 = [0.15, 0.13, 0.11];
%                     end
%                 end
%
%                 % Plot legend text
%                 for k=1:length(x1)
%                     graphcond=figcolor1(k);
%                     text(x1(k), y1(k), legend1{k}, 'Color', color1(graphcond,:),  'FontSize', fontszlabel, 'HorizontalAlignment', 'right')
%                 end
%             end
%
%
%             %=================
%             % Calculate error bars
%
%             a1=[]; b1=[]; c1=[]; d1=[]; f1=[];
%             if settings.error_bars==1 & settings.subject_no>1
%                 % Bootstrap the sample
%                 for k=1:size(aaa,3)
%                     if k==1
%                         a1 = [aaa(:,:,k)];
%                     else
%                         a1 = [a1, aaa(:,:,k)];
%                     end
%                 end
%                 b1 = bootstrapnan(a1,tboot1);
%                 c1 = prctile(b1,[2.5,97.5]);
%                 for k=1:size(aaa,3)
%                     i1=1+(size(aaa,2)*k)-size(aaa,2);
%                     i2=(size(aaa,2)*k);
%                     d1(:,:,k) = c1(1,i1:i2,:); % Lower bound (2.5 percentile)
%                     f1(:,:,k) = c1(2,i1:i2,:); % Upper bound (97.5 percentile)
%
%                 end
%             elseif settings.error_bars==2 & settings.subject_no>1
%                 % SEM
%                 for k=1:size(aaa,3)
%                     for i=1:size(aaa,2)
%                         d1(:,i,k) = nanmean(aaa(:,i,k))-se(aaa(:,i,k)); % Standard error, lower bound (identical to upper one)
%                         f1(:,i,k) = nanmean(aaa(:,i,k))+se(aaa(:,i,k)); % Standard error, upper bound (identical to lower one)
%                     end
%                 end
%             end
%
%
%             % Plot error bars
%             if settings.subject_no>1
%                 for k=1:size(aaa,3)
%
%                     % Finding out non NAN values
%                     z1=~isnan(nanmean(aaa(:,:,k)));
%                     z2=sum(z1);
%                     plotbins=pbins(z1);
%
%                     graphcond=figcolor1(k);
%
%                     xc1=plotbins(1); % Min x, min y
%                     xc2=plotbins(1); % Min x, max y
%                     xc3=plotbins; % Upper bound of errors
%                     xc4=plotbins(end); % Max x, max y
%                     xc5=plotbins(end); % Max x, min y
%                     xc6=plotbins;
%                     xc6=fliplr(xc6);
%
%                     yc1=d1(:,1,k); % Lower bound of errors
%                     yc2=f1(:,1,k); % upper bound of errors
%                     yc3=f1(:,z1,k); % Upper bound of errors
%                     yc4=f1(:,z2,k); % Upper bound of errors
%                     yc5=d1(:,z2,k); % Lower bound of errors
%                     yc6=d1(:,z1,k); % Lower bound of errors
%                     yc6=fliplr(yc6);
%
%                     h=fill([xc1,xc2,xc3,xc4, xc5, xc6],[yc1, yc2, yc3, yc4, yc5, yc6], [1 0.7 0.2],'linestyle','none');
%                     set (h(end), 'FaceColor', facecolor1(graphcond,:,:),'linestyle', 'none', 'FaceAlpha', 1)
%
%                 end
%             end
%
%             % Plot means
%             plotbins=pbins;
%
%             for k=1:size(aaa,3);
%                 if size(aaa,1)>1
%                     h=plot(plotbins, nanmean(aaa(:,:,k)));
%                 else
%                     h=plot(plotbins, aaa(:,:,k));
%                 end
%                 graphcond=figcolor1(k);
%                 set (h(end), 'LineWidth', wlinegraph, 'Color', color1(graphcond,:))
%             end
%
%             plot([-4000,4000], [0,0],'-', 'LineWidth', 0.9, 'Color', [0.5,0.5,0.5] )
%
%             % FIGURE SETUP
%             set (gca,'FontSize', fontsz);
%             set(gca,'YTick',[0.1:0.1:0.4]);
%             if fig_legend1==2
%                 set(gca,'YLim',[-0.05 0.7]);
%             elseif fig_legend1==1
%                 set(gca,'YLim',[-0.05 0.50]);
%             end
%             if reset1==1
%                 set(gca,'XTick', [500:1000:2500]);
%                 set(gca,'XLim',[plotbins(1)-300 plotbins(end)+300]);
%                 xlabel ('Time during visual stimulus, ms', 'FontSize', fontszlabel);
%                 set(gca,'YLim',[-0.05 0.60]);
%             elseif reset1==2
%                 set(gca,'XTick', [-500:500:1000]);
%                 set(gca,'XLim',[plotbins(1)-200 plotbins(end)+200]);
%                 xlabel ('Time during memory delay , ms', 'FontSize', fontszlabel);
%                 set(gca,'YLim',[-0.05 0.39]);
%             elseif reset1==3
%                 set(gca,'XTick', [-250:250:250]);
%                 set(gca,'XLim',[plotbins(1)-100 plotbins(end)+100]);
%                 xlabel ('Time before/after saccade cue, ms', 'FontSize', fontszlabel);
%                 set(gca,'YLim',[-0.05 0.19]);
%             end
%             if fig1==1 || fig1==2
%                 ylabel ('Microsaccade rate, Hz', 'FontSize', fontszlabel);
%             end
%
%             % Figure title
%             title (title1, 'FontSize', fontszlabel)
%
%             %============
%             % Export the figure & save it
%
%             settings.subject_path = [settings.figures_directory, sprintf('%s/%s/', settings.figure_folder_name, sN1) ];
%             if isdir (settings.subject_path)
%                 cd (settings.subject_path)
%             else
%                 mkdir (settings.subject_path)
%             end
%
%             if fig_legend1==1
%                 fileName=[settings.subject_path, save_name, '_no_legend'];
%             elseif fig_legend1==2
%                 fileName=[settings.subject_path, save_name];
%             end
%             set(gcf, 'PaperPositionMode', 'manual');
%             set(gcf, 'PaperUnits', 'inches');
%             set(gcf, 'PaperPosition', settings.figsize)
%             set(gcf, 'PaperSize', [settings.figsize(3),settings.figsize(4)]);
%             print (fileName, '-dpdf')
%             close all;
%
%             %===============
%         end
%     end
%
% end