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

function [y_drift_mat, y_sacc, y_raw] = drift_correction_v14 (sacc1, saccraw1, drift_mat, t_start, t_end, saccade_amp_threshold)


% For drift correction initialize empty matrix
drift_correct=NaN(length(sacc1),4); % Initialize matrix


%% Do drift correction

for tid=1:length(saccraw1)
    
    sx1 = saccraw1{tid};
    sx2 = sacc1{tid};
    
    if ~isnan(t_start(tid))
        
        % Convert raw data into coordinates
        if length(sx1)>1
            index1=sx1(:,1)>=t_start(tid) & sx1(:,1)<=t_end(tid);
            x1=sx1(index1,2);
            y1=sx1(index1,3);
            dist1 = sqrt(x1.^2 + y1.^2); % Calculate amplitude of the eye position
        end
        
        % Check whethere there were some large saccades during period of
        % interest
        if length(sx2)>1
            
            % Find saccade length
            xsacc=sx2(:,5)-sx2(:,3);
            ysacc=sx2(:,6)-sx2(:,4);
            sacclength=sqrt((xsacc.^2)+(ysacc.^2));
            
            % index1 is correct saccades
            starttimes=sx2(:,1);
            index1 = sacclength>=saccade_amp_threshold & starttimes>=t_start(tid) & starttimes<=t_end(tid);
            amp_index1=+index1;
        else
            amp_index1=0;
        end        
        
        % Do drift correction
        if length(sx1)>1
            
            if ~isnan(drift_mat(tid)) && sum(amp_index1)==0 && drift_mat(tid)~=0
                
                % Determine how much to reset data
                a = nanmean(dist1); % Current trial mean/median
                b = drift_mat(tid); % mean/median position of x trials
                c = b/a; % Proportion to reset (for example, 10%)
                
                % Change saccraw data
                saccraw1{tid}(:,2) = saccraw1{tid}(:,2) - nanmean(x1)*c;
                saccraw1{tid}(:,3) = saccraw1{tid}(:,3) - nanmean(y1)*c;
                
                % Correct individual saccades
                if length(sx2)>1
                    sacc1{tid}(:,3) = sacc1{tid}(:,3) - nanmean(x1)*c;
                    sacc1{tid}(:,5) = sacc1{tid}(:,5) - nanmean(x1)*c;
                    sacc1{tid}(:,4) = sacc1{tid}(:,4) - nanmean(y1)*c;
                    sacc1{tid}(:,6) = sacc1{tid}(:,6) - nanmean(y1)*c;
                end
                
                % Save correction factor
                drift_correct(tid,1) = 1;
                drift_correct(tid,2) = nanmean(x1)*c;
                drift_correct(tid,3) = nanmean(y1)*c;
                drift_correct(tid,4) = drift_mat(tid);
                
            else
                % Save factor of correction
                drift_correct(tid,1) = 0;
                drift_correct(tid,2) = nanmean(x1);
                drift_correct(tid,3) = nanmean(y1);
                drift_correct(tid,4) = nanmean(dist1);
            end
        end
        
    end
end

y_drift_mat = drift_correct;
y_raw = saccraw1;
y_sacc = sacc1;

