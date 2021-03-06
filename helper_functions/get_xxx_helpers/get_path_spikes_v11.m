% Reads multiple folders recorded on same/different days and produces
% matrix with all sessions and folders recorded
%
% Revision history:
%
% v1.0 September 1, 2016. Basic script prepared.
% V1.1 January 17, 2018. Added session numbering for multiple recordings a
% day.
%
% Data file is format: subject_date_session_chXX_uXX_type.mat
% (for example: aq_20161231_1_ch1_u1_m.mat)


function y = get_path_spikes_v11 (path1, subject_name)

% path1 is directory you want to check for data (f.e. ~/Experiment_data/Experiment_name/data_psychtoolbox/subject_name/)
% subject_name is subject initials

%% Setup

% Determine how many files with the subject name are there
index_cur_dir = dir(path1);

% Initialize output variables
temp_ind_subj = cell(length(index_cur_dir), 1);
temp_ind_dates = NaN(length(index_cur_dir), 1);
temp_ind_sessions = NaN(length(index_cur_dir), 1);
temp_ind_channels = NaN (length(index_cur_dir), 1);
temp_ind_units = NaN (length(index_cur_dir), 1);
temp_ind_unit_class = cell (length(index_cur_dir), 1);

%% Parse the file name

% Temporary variables initiated
fnames = cell (length(index_cur_dir), 1); % Temporary file name used
fdates = cell (length(index_cur_dir), 1); % Dates in string format will be stored here

% Extract file names & their sizes
for i=1:length(index_cur_dir)
    fnames{i} = index_cur_dir(i).name;
end


%============
% Extract subject names
for i=1:length(fnames)
    if length(fnames{i}) > length(subject_name)
        if strcmp(fnames{i}(1:length(subject_name)), subject_name)
            temp_ind_subj{i} = subject_name; % Save subject name
            fnames{i}(1:length(subject_name)) = [];
        else
            temp_ind_subj{i} = NaN; % Save subject name
            fnames{i} = NaN;
        end
    else
        temp_ind_subj{i} = NaN;
        fnames{i}=[]; % Discard if folder doesnt start with subject name
    end
end

% If there is a dash, extract it
for i=1:length(fnames)
    if length(fnames{i}) > 1
        if strcmp(fnames{i}(1), '_')
            fnames{i}(1) = [];
        end
    end
end

%===============
% Detect if next is year notation
for i=1:length(fnames)
    if length(fnames{i}) > 4
        if str2num(fnames{i}(1:4))
            fdates{i}(1:4) = fnames{i}(1:4);
            fnames{i}(1:4) = [];
        else 
            fdates{i} = NaN;
            fnames{i} = NaN;
        end
    else
        fdates{i} = NaN;
    end
end

% If there is a dash, extract it
for i=1:length(fnames)
    if length(fnames{i}) > 1
        if strcmp(fnames{i}(1), '_')
            fnames{i}(1) = [];
        end
    end
end

%================
% Detect if next is month notation
for i=1:length(fnames)
    if length(fnames{i}) > 2
        if str2num(fnames{i}(1:2))
            fdates{i}(5:6) = fnames{i}(1:2);
            fnames{i}(1:2) = [];
        else
            fdates{i} = NaN;
            fnames{i} = NaN;
        end
    else
        fdates{i} = NaN;
    end
end

% If there is a dash, extract it
for i=1:length(fnames)
    if length(fnames{i}) > 1
        if strcmp(fnames{i}(1), '_')
            fnames{i}(1) = [];
        end
    end
end

%=================
% Detect if next is day notation
for i=1:length(fnames)
    if length(fnames{i}) >= 2
        if str2num(fnames{i}(1:2))
            fdates{i}(7:8) = fnames{i}(1:2);
            fnames{i}(1:2) = [];
        else
            fdates{i} = NaN;
            fnames{i} = NaN;
        end
    else
        fdates{i} = NaN;
    end
end


% If there is a dash, extract it
for i=1:length(fnames)
    if length(fnames{i}) > 1
        if strcmp(fnames{i}(1), '_')
            fnames{i}(1) = [];
        end
    end
end

%=================
% If there is session number afterwards, extract it; If there is no
% session number, then skip it;

for i=1:length(fnames)
    if length(fnames{i}) >= 2
        [a,b] = strsplit(fnames{i}, '_'); % Find delimiter
        if ~isempty(b) % If delimiter exists
            if str2num(a{1})
                temp_ind_sessions(i) = str2num(a{1});
                fnames{i}(1:length(a{1})) = [];
            else
                temp_ind_sessions(i) = NaN;
            end
        else
            temp_ind_sessions(i) = NaN;
            fnames{i} = NaN;
        end
    end
end

% If there is a dash, extract it
for i=1:length(fnames)
    if length(fnames{i}) > 1
        if strcmp(fnames{i}(1), '_')
            fnames{i}(1) = [];
        end
    end
end


%=================
% Detect if next is channel notation
for i=1:length(fnames)
    if length(fnames{i}) >= 2
        if strcmp(fnames{i}(1:2), 'ch')
            fnames{i}(1:2) = [];
        else
            fnames{i}=NaN;
        end
    else
        fnames{i} = NaN;
    end
end


%=================
% Detect chanel number
for i=1:length(fnames)
    if length(fnames{i}) >= 2
        [a,b] = strsplit(fnames{i}, '_'); % Find delimiter
        if ~isempty(b) % If delimiter exists
            if str2num(a{1})
                temp_ind_channels(i) = str2num(a{1});
                fnames{i}(1:length(a{1})) = [];
            else
                temp_ind_channels(i) = NaN;
                fnames{i}=NaN;
            end
        else
            temp_ind_channels(i) = NaN;
            fnames{i} = NaN;
        end
    end
end

% If there is a dash, extract it
for i=1:length(fnames)
    if length(fnames{i}) > 1
        if strcmp(fnames{i}(1), '_')
            fnames{i}(1) = [];
        end
    end
end


%=================
% Detect if next is unit notation
for i=1:length(fnames)
    if length(fnames{i}) >= 1
        if strcmp(fnames{i}(1), 'u')
            fnames{i}(1) = [];
        else
            fnames{i}=NaN;
        end
    else
        fnames{i} = NaN;
    end
end

%=================
% Detect unit number
for i=1:length(fnames)
    if length(fnames{i}) >= 2
        [a,b] = strsplit(fnames{i}, '_'); % Find delimiter
        if ~isempty(b) % If delimiter exists
            if str2num(a{1})
                temp_ind_units(i) = str2num(a{1});
                fnames{i}(1:length(a{1})) = [];
            else
                temp_ind_units(i) = NaN;
                fnames{i}=NaN;
            end
        else
            temp_ind_units(i) = NaN;
            fnames{i} = NaN;
        end
    end
end

% If there is a dash, extract it
for i=1:length(fnames)
    if length(fnames{i}) > 1
        if strcmp(fnames{i}(1), '_')
            fnames{i}(1) = [];
        end
    end
end

%=================
% Unit classification detection
for i=1:length(fnames)
    if length(fnames{i}) >= 1
        if strcmp(fnames{i}(1), 'u') || strcmp(fnames{i}(1), 's') || strcmp(fnames{i}(1), 'm')
            temp_ind_unit_class{i}(1) = fnames{i}(1);
            fnames{i}(1) = [];
        else
            temp_ind_unit_class{i}(1) = NaN;
            fnames{i}=NaN;
        end
    else
        temp_ind_unit_class{i}(1) = NaN;
        fnames{i} = NaN;
    end
end

%% Transform date matrix from string to number

% Convert dates into numbers
for i=1:length(fdates)
    if ~isempty(fdates{i})
        if ~isnan(fdates{i})
            temp_ind_dates(i)=str2num(fdates{i});
        end
    end
end

% Find unique days used
unique_dates = unique(temp_ind_dates);
ind = isnan(unique_dates); unique_dates(ind)=[];


%% For each date and session prepare a list of paths

index_cur_dir; % This is necessary input. Contains all file names and file ordering

% Create output matrix
file_name1 = cell(1);
file_name1_short = cell(1);
session1 = [];
dates1 = [];
subject1 = cell(1);
unit1 = [];
channel1 = [];
unit_class1 = cell(1);
path_temp1 = cell(1);

        
% If there are more than 10 sessions recorded, re-order the indexes of
% the sessions into increasing sequence (from 1, 11, 2, 3) into (1, 2, 3, 11)
[~, t1] = sort(temp_ind_channels, 'ascend');

for j=1:length(t1)
    
    % Index
    if length(file_name1)==1 && isempty(file_name1{1})
        ind = 1;
    else
        ind = ind+1;
    end
    
    % Save data
    session1(ind,1) = temp_ind_sessions(t1(j));
    dates1(ind,1) = temp_ind_dates(t1(j));
    subject1{ind,1} = temp_ind_subj{t1(j)};
    unit1(ind,1) = temp_ind_units(t1(j));
    channels1(ind,1) = temp_ind_channels(t1(j));
    unit_class1{ind,1} = temp_ind_unit_class{t1(j)};
    
    path_temp1{ind,1} = [path1, index_cur_dir(t1(j)).name];
    
    % File name remove .mat notification
    a = index_cur_dir(t1(j)).name;
    m = length(a);
    if numel(a)>4 && strcmp (a(m-3:m), '.mat') 
      file_name1{ind,1} = a(1:m-4);
    else
      file_name1{ind,1} = a;
    end
    
    % Neural unit name short
    file_name1_short{ind,1} = sprintf('ch%s_u%s_%s', ...
        num2str(channels1(ind)), num2str(unit1(ind)), unit_class1{ind});
    
end
    


%% Output

y.index_dates=dates1;
y.index_sessions = session1;
y.index_subjects = subject1;
y.index_unit = unit1;
y.index_channel = channels1;
y.index_unit_type = unit_class1;
y.index_file_name = file_name1;
y.index_file_name_short = file_name1_short;
y.index_path = path_temp1;

