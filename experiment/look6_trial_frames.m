% Initialize frames matrix which will contain every frame info for the trial


%% Blank variables

t1 = expsetup.stim.esetup_fixation_acquire_duration(tid,1);
dur1 = t1 + 20; % How long the trial is
time_unit = expsetup.screen.ifi;
b1 = ceil(dur1/time_unit) + 1; % How many frames to initalize (always add extra frame at the end)

% Create all fields filled with NaNs
f1 = fieldnames(expsetup.stim);
ind = strncmp(f1,'eframes', 7);
for i=1:numel(ind)
    if ind(i)==1
        if iscell(expsetup.stim.(f1{i}))
            [~,n,o]=size(expsetup.stim.(f1{i}){1});
            frames_mat = NaN(b1, n, o); 
            expsetup.stim.(f1{i}){tid} = frames_mat;
        end
    end
end


%% Blinking fixation

b1 = 1/expsetup.stim.fixation_blink_frequency/2; % How many ms blink lasts; /2 because: 1 blink = 1 stim on + 1 blank
b1=round(b1/time_unit); % How many frames blink lasts
m1 = [ones(b1,1); zeros(b1,1)]; % Stim on + blank
% Fill in trialmat with blinks
temp1 = frames_mat;
ans1 = floor(size(temp1,1)/length(m1)); % How many reps per trial
m1 = repmat(m1,ans1,1); % How many reps per trial
temp1(1:length(m1),1) = m1;
if length(m1)<size(temp1,1)
    ind = length(m1)+1:size(temp1,1);
    temp1(ind,1) = m1(1:numel(ind));
end
% Save data
expsetup.stim.eframes_fixation{tid}=temp1;


