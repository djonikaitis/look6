clear all;
clc;

% Settings
expsetup.tcpip.plex_address =  '192.168.0.2';
expsetup.tcpip.plex_port =  4013;
expsetup.tcpip.psych_address =  '192.168.0.1';
expsetup.tcpip.psych_port =  4013;
expsetup.tcpip.success_ini = 0;
expsetup.tcpip.data_file_size = 10000;


%% Setup initial connection wich will start experiment

% Initialize data file
el1 = expsetup.tcpip.data_file_size;
data_mat = NaN(el1, 1);
data_prop = whos('data_mat');

% Connection details
ip_address =  expsetup.tcpip.psych_address;
socket = expsetup.tcpip.psych_port;

% Initialize server
fprintf('\nWaiting for initial connection with the server\n')
tclient = tcpip(ip_address, socket, 'NetworkRole', 'server');
set(tclient, 'InputBufferSize', data_prop.bytes);
fopen (tclient);
fprintf('Connection with the server established\n')

% Check for data. Allow a timeout.
t1=cputime;
t2=cputime;
t_out = 30;
count = tclient.BytesAvailable;
while count ~= data_prop.bytes && t2-t1<t_out
    count = tclient.BytesAvailable;
    t2 = cputime;
end
if count==data_prop.bytes
    [data_received] = fread(tclient, length(data_mat), data_prop.class);
    fprintf ('Experimental setup instructions received\n')
else
    data_reveived = NaN(el1, 1);
    fprintf('Failed to obtain first data packet within timeout period\n')
end

% Decision about data match
if ~isnan(data_received(1:2:7))
    expsetup.general.plex_num_act_channels = data_received(5);
    expsetup.general.plex_event_start = data_received(1);
    expsetup.general.plex_event_end = data_received(3);
    expsetup.general.plex_trial_timeout_sec = data_received(7);
    expsetup.tcpip.success_ini = 1;
    fprintf('\nConnection between two computers matched, will reverse connection direction\n')
else
    error ('Connection between two computers failed - data mismatch')
end

fclose(tclient);
delete(tclient);
pause(1);

%% Initialize plexon connection and transfer some settings back to psychtoolbox computer

plex_obj = PL_InitClient(0);
if plex_obj == 0
    return
end

pars = PL_GetPars(plex_obj);
fprintf ('\nPlexon initilized successfully\n')

%% Initialize new reversed connection

el1 = expsetup.tcpip.data_file_size;

if expsetup.tcpip.success_ini == 1
    
    % Initialize data size to be used
    data_mat = NaN(el1, 1);
    data_mat(1) = pars(13);
    data_prop = whos('data_mat');
    
    % Initialize server
    tserver = tcpip(ip_address, socket);
    set(tserver, 'OutputBufferSize', data_prop.bytes);
    fopen (tserver);
    fprintf ('Initialized reversed connection\n');
    pause(2);
    
    % Write data and close
    fwrite(tserver, data_mat, data_prop.class);
    
end


%% Plexon data recording

% Get variables needed for recording
if isfield (expsetup.general, 'plex_event_start') && isfield (expsetup.general, 'plex_event_end')
    num_act_ch = 1 : expsetup.general.plex_num_act_channels;
    ev_start = expsetup.general.plex_event_start;
    ev_end = expsetup.general.plex_event_end;
    t_dur_sec = expsetup.general.plex_trial_timeout_sec;
else % Fake parameters in case of debugging
    expsetup.general.plex_num_act_channels = 1;
    expsetup.general.plex_event_start = 3;
    expsetup.general.plex_event_end = 4;
    expsetup.general.plex_trial_timeout_sec = 5;
end

% Start data acquisition
tid = 1; % Trial number

t_continue = 0;
while t_continue == 0
    
    fprintf('Recording trial %d\n', tid);
    
    % Check for data
    PL_TrialDefine(plex_obj, ev_start, ev_end, 0, 0, 0, 0, num_act_ch, 0, 0);
    sp_list = []; ev_list = [];
    [~, sp_list] = PL_TrialSpikes(plex_obj, ev_end, t_dur_sec*1000); % Time-out is in ms 
    [~, ev_list] = PL_TrialEvents(plex_obj, ev_end, t_dur_sec*1000);
    
    if ~isempty (ev_list)
        % Initialize var1 which will contain data
        var1 = [];
        var1(1,1) = tid; % Trial number
        var1(2,1) = -99; % Break sign
        var1(3,1) = ev_list(1,2); % Trial start event code
        var1(4,1) = ev_list(1,1); % Trial start event time
        var1(5,1) = ev_list(end,2); % T end
        var1(6,1) = ev_list(end,1); % T end
        var1(7:16,1) = -99; % Break sign
        
        % Restructure the data
        for i = num_act_ch
            ind = sp_list(:,2)==i;
            if sum(ind)>0
                t = [-1; i; sp_list(ind,1); -2];
            else
                t = [-1; i; -2];
            end
            var1(end+1:end+numel(t), 1) = t;
        end
         
        fprintf ('Trial %d duration %2.0f ms \n', tid, ((var1(6)-var1(4))/pars(13))*1000)
        
        %==================
        % Write data into server
        
        el1 = expsetup.tcpip.data_file_size;
        data_mat = NaN(el1, 1);
        data_prop = whos('data_mat');
        if numel(var1)<=numel(data_mat)
            data_mat(1:numel(var1)) = var1;
            fwrite(tserver, data_mat, data_prop.class);
            fprintf ('Trial data transferred\n');
        else
            fprintf('Could not fit the data into data_mat. Consider increasing the size for it\n')
            fprintf('%d elements not transferred\n', numel(var1)-numel(data_mat))
        end
        
        % TID updatd only if trial recording was successful.
        tid = tid+1; 
        
    elseif isempty(ev_list) % If data not acquired, suggest to quit the loop
        
        fprintf('\nPlexon detected no trial onset/offset.\n')
        fprintf('Potential reasons: 1) event code error or 2) psychtoolbox is paused \n')
        fprintf('For event code error quit all scripts and correct errors \n')
        fprintf('To resume paused recording, confirm recording here first, then un-pause psychtoolbox \n')
        a = input('Resume recording? y (yes) or q (quit):  ', 's');
        if strcmp(a, 'q')
            t_continue = 999;
            fprintf('Recording ended \n')
        end
    end
    % End of checking whether events detected
end


% Close connections once all is done

% you need to call PL_Close(s) to close the connection
% with the Plexon server
PL_Close(plex_obj);
plex_obj = 0;


%%


fclose(tserver);
delete(tserver);





