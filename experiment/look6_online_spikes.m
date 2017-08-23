% Get data from plexon

num_ch1 = expsetup.general.plex_num_act_channels;
save_online_spikes_v1 = 1;

%==============
% Connect two computers
%==============

% Done in main code

%=============
% Receive data
%=============

el1 = expsetup.tcpip.data_file_size;
data_mat = NaN(el1,1);
data_prop = whos('data_mat');

t1 = cputime;
t2 = cputime;
t_out = expsetup.general.plex_trial_timeout_sec;
count = tclient.BytesAvailable;
while count~=data_prop.bytes && t2-t1<t_out
    count = tclient.BytesAvailable;
    t2 = cputime;
end
if count==data_prop.bytes
    data_received = fread(tclient, numel(data_mat), data_prop.class);
    fprintf('Received data from server for the trial %d\n', data_received (1))
else
    data_received = NaN(el1, 1);
    fprintf('Failed to obtain first data packet within timeout period\n')
end

%=============
% Extract data for each channel
%=============

%%
sp_struct = struct; % Initialize empty matrix

if data_received(1) == tid % Check that trial number is matching
    
    % Save trial start time and end time
    sp_struct.trial_start = data_received(4); % Default position in data_received for t-start
    sp_struct.trial_end = data_received(6); % Default position in data_received for t-end
    sp_struct.ch_no = cell(num_ch1,1);
    sp_struct.spikes = cell(num_ch1,1);
    
    % Find data for each channel
    r_s = find(data_received==-1); % Default channel start code
    r_e = find(data_received==-2); % Default channel end code
    for i = 1:numel(r_s) % For each channel
        ind = r_s(i)+2:r_e(i)-1; % Exclude 2 + 1 elements
        if data_received (r_s(i)+1) == i % If channel received matches expected channel
            sp_struct.ch_no{i} = data_received (r_s(i)+1); % Save channel number just in case
            if numel(ind)>0
                sp_struct.spikes{i} = data_received(ind);
            else
                sp_struct.spikes{i} = [];
            end
        else
            fprintf('Expected and recorded channel numbers do not match, check data\n');
            sp_struct = struct;
        end
    end
else
    fprintf('Trial number id between psychtoolbox and plexon do not match. Will stop recording\n');
    expsetup.general.plexon_online_spikes = 0;
end


%% Save for debugging purposes

if save_online_spikes_v1==1
    
    if tid==1
        spike_online_save = struct;
    else
    end
    
    f1 = fieldnames(sp_struct);
    for i = 1:numel(f1)
        spike_online_save.(f1{i}) = sp_struct.(f1{i});
    end
    
    dir1 = expsetup.general.directory_data_psychtoolbox_subject;
    f_name = sprintf( 'trial_%s_%s%s', num2str(tid), expsetup.general.subject_filename,  '_spike_online_save');
    d1 = sprintf('%s%s', dir1, f_name);
    save (d1, 'spike_online_save');
end

