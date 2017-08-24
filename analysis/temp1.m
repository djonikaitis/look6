var1 = plexon;


% Get analog signal
samp1 = var1.analog;
samp1diff = [0;diff(samp1)];

% Setup timing
t1 = 1:length(samp1);
time1 = t1;

% Find first refresh rate
ind = find(samp1>mean(samp1) & samp1diff>0);

% Find local peaks
[pks,locs,w,p] = findpeaks(samp1);
locs = locs(locs>=ind(1)); % Select starting from first refresh rate peak;
locs_copy = locs; % Keep it just in case;

%%  Save value of the first data point

r_mat = [];
tid = 1;
r_mat(tid,1:3) = [t1(locs(1)), time1(locs(1)), samp1(locs(1))]; % Sample number, time, height

% Find the max value between refresh rates (threshold for refresh detection)
a_thresh = diff(locs);
a_thresh = max(a_thresh);
if a_thresh>10 % Suspicious refresh rates called out
    error;
end

%% Find each peak within expected refresh rate

tic
loop_over = 0;
while loop_over==0
    
    
    % Find peak of previous refresh rate
    ind_prev = find(locs==r_mat(tid,1));
    ind_prev_val = r_mat(tid,1);
    % Remove previous refresh rates from locs matrix
    locs = locs(ind_prev+1:end);
    
    if length(locs)>1
    a = locs - ind_prev_val; % Find timing of all local peaks relative to refresh rate tid-1;
    b = locs(a<a_thresh & a>a_thresh/2); % Select only local peaks that are within refresh rate range
    c = samp1(b);
    if ~isempty(c)
        [~,i1] = max(c);
        ind_now = b(i1);
        tid = tid+1;
        r_mat(tid,1:3) = [t1(ind_now), time1(ind_now), samp1(ind_now)];
    else
        error
    end 
    
    else
        loop_over=1;
    end
    
    if tid==2000
        loop_over==1
    end
    
end
toc

