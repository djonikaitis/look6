% Offline drift correction for eye position
%
% Latest revision history:
% v1.0 30 DJ: January 2015 Initial script written
% v1.1 13 DJ: February 2015 Added 4th column; now this code is as it's own
% script
% v1.2 DJ; July 29, 2015: adapted to new format to use S structure everyhwere
% v1.3 DJ: October 10, 2016: made it into a function
% v1.4 DJ: April 5, 2017: Drift is reset relative to running average of gaze
% position (previously it was trial by trial)
%
% Input:
% sacc1 - cell array with saccades
% saccraw1 - cell array with raw eye position
% drift_mat - how much to reset the data
% t_start - time start for interval used to calculate resetting of the data
% t_end - time end for interval used to calculate resetting of the data
% saccade_amp_threshold - how big saccades are allowed during interval
%
%
% Output:
% column 1          0 - no drift correct, 1 - drift correct
% columns 2 & 3     x & y of drift correct
% column 4          amount to reset drift
%
% Donatas Jonikaitis


%% Settings

function [drift1] = drift_correction_v14 (sacc1, saccraw1, avg_mat, t_start, t_end, saccade_amp_threshold)


% For drift correction initialize empty matrix
drift_output = cell(numel(sacc1),1);
drift_factor_xy = NaN(numel(sacc1),2);


%% Do drift correction

for tid=1:numel(saccraw1)
    
    sx1 = saccraw1{tid};
    sx2 = sacc1{tid};
    
    if length(sx1)>1 && ~isnan(t_start(tid)) && ~isnan(t_end(tid))
        
        %=========
        % Select raw dta
        ind=sx1(:,1)>=t_start(tid) & sx1(:,1)<=t_end(tid);
        raw_x = sx1(ind,2);
        raw_y = sx1(ind,3);
        raw_dist = sqrt(raw_x.^2 + raw_y.^2);
        
        %==========
        % Check whethere there were some large saccades
        if length(sx2)>1
            
            x=sx2(:,5)-sx2(:,3);
            y=sx2(:,6)-sx2(:,4);
            sacc_amp=sqrt((x.^2)+(y.^2));
          
            % sacc_amp_index is large saccades
            starttimes=sx2(:,1);
            sacc_amp_index = sacc_amp>=saccade_amp_threshold & starttimes>=t_start(tid) & starttimes<=t_end(tid);
            
        else
            sacc_amp_index = 0;
        end
        
        %===========
        % Do drift correction
        
        if ~isnan(avg_mat(tid)) && avg_mat(tid)~=0 && sum(sacc_amp_index)==0
            
            % Determine how much to reset data
            a = nanmean(raw_dist); % Current trial mean/median
            b = avg_mat(tid); % mean/median position of x trials
            c = (b/a); % Proportion to reset (for example, 10%)
            c = 1;
            
            % Change saccraw data
            saccraw1{tid}(:,2) = saccraw1{tid}(:,2) - 0; %nanmean(raw_x)*c;
            saccraw1{tid}(:,3) = saccraw1{tid}(:,3) - 1.5; %nanmean(raw_y)*c;
            
            % Correct individual saccades
            if length(sx2)>1
                sacc1{tid}(:,3) = sacc1{tid}(:,3) - 0; %nanmean(raw_x)*c;
                sacc1{tid}(:,5) = sacc1{tid}(:,5) - 0; %nanmean(raw_x)*c;
                sacc1{tid}(:,4) = sacc1{tid}(:,4) - 1.5; %nanmean(raw_y)*c;
                sacc1{tid}(:,6) = sacc1{tid}(:,6) - 1.5; %nanmean(raw_y)*c;
            end
            
            % Save output
            drift_output{tid} = 'drift on';
            drift_factor_xy(tid,1) = nanmean(raw_x)*c;
            drift_factor_xy(tid,2) = nanmean(raw_y)*c;
            
        elseif sum(sacc_amp_index)>0
            drift_output{tid} = 'drift off - saccade';
        else
            drift_output{tid} = 'drift off';
        end
        
    end
end

drift1.drift_output = drift_output;
drift1.drift_factor_xy = drift_factor_xy; 
drift1.saccraw1 = saccraw1; 
drift1.sacc1 = sacc1;

