% V1.0 October 24, 2017. Initial version

function [var1, var2] = preprocessing_drift_correction_v10(settings, var1, var2)

fprintf('Doing drift correction\n')

% Eye position for drift correction
sacc1 = var1.eye_data.saccades_EK;
saccraw1 = var2.eye_processed;

% Time for drift calculations
time1 = var1.eyelink_events.(settings.drift_correction_time); % Time relative to which drift correction is done
t_start = time1 + settings.drift_correction_tstart; % Relative to time1 start checking for drift;
t_end = time1 + settings.drift_correction_tend; % Relative to time1 end checking for drift;

% Window size for the drift
a = var1.stim.(settings.drift_correction_window_max);
if iscell (a)
    drift_threshold = cell2mat(a);
elseif size(a,2)>1
    drift_threshold = a(:,4);
elseif size(a,2)==1
    drift_threshold = a;
end

%% Dispersion of eye positions around display center

dist_mat = NaN(numel(sacc1),1);
x_mat = NaN(numel(sacc1),1);
y_mat = NaN(numel(sacc1),1);

for tid = 1:length(saccraw1)
    
    sx1 = saccraw1{tid};
    
    if ~isnan(t_start(tid))
        
        t1 = t_start(tid);
        t2 = t_end(tid);
        
        % Convert raw data into coordinates
        if length(sx1)>1
            
            % Select data samples within given time
            index1=sx1(:,1)>=t1 & sx1(:,1)<=t2;
            x1=sx1(index1,2);
            y1=sx1(index1,3);
            eyecoord1 = sqrt(x1.^2 + y1.^2); % Calculate distance from the center
            
            % Save output
            dist_mat(tid)=nanmean(eyecoord1);
            x_mat(tid)=nanmean(x1);
            y_mat(tid)=nanmean(y1);
        end
        
    end
end


%%  Transform distance on each trial to moving average over trials

temp1 = dist_mat;
temp1(temp1>=drift_threshold) = NaN; % Remove trials that deviate from fixation too much


% Calculate mean/median distance from fixation
if strcmp(settings.drift_correction_method, 'median')
    avg_mat = movmedian(temp1, settings.drift_correction_trials, 'omitnan'); % How much to reset
elseif strcmp(settings.drift_correction_method, 'mean')
    avg_mat = movmean(temp1, settings.drift_correction_trials, 'omitnan'); % How much to reset
elseif strcmp(settings.drift_correction_method, 'each trial')
    avg_mat = temp1;
else
    avg_mat = temp1;
end

% Over-write non existing values
ind = isnan(temp1);
avg_mat(ind)=NaN;

% Do not reset trials with small fix deviation
threshold1 = settings.drift_correction_window_min; % Any value higher than that is not used for resetting
avg_mat(avg_mat<=threshold1) = 0;


%%  Drift correction

[drift1] = drift_correction_v14 (sacc1, saccraw1, avg_mat, t_start, t_end, settings.drift_correction_sacc_amp);

var1.eye_data.drift_output = drift1.drift_output;
var1.eye_data.drift_distance_for_each_trial = dist_mat;
var1.eye_data.drift_distance_average = avg_mat; 
var1.eye_data.drift_factor_xy = drift1.drift_factor_xy;
var1.eye_data.drift_predrift_xy = [x_mat, y_mat];

var1.eye_data.saccades_EK = drift1.sacc1; % Over-write the field
var2.eye_processed = drift1.saccraw1; % Over-wrtie the field

