% Function generates full path to a file or a folder. This is important for
% saving or loading data or figures. Path can be short (ends with a folder)
% or long (ends with full file name). To get short file name skip
% varargin{2} and varargin{3}.
%
% input: settings structure with fields: subject_current, date_current;
% varargin{1}: dir_name (for example, 'data_psychtoolbox'). Necessary
% varargin{2}: file_name_append (for example, '_saccades.mat'). Optional
% varargin{3}: session_current (f.e. 1; or leave it empty). Optional
% output: path (short of long), folder name, file name;
%
% v1.0 January,19 2018. Basic version


function [y1, y2, y3] = get_generate_path_v10 (settings, varargin)

% Check whether current subject exists
if isfield(settings, 'subject_current')
    subject_current = settings.subject_current;
else
    error ('settings.subject_current not defined')
end

% Check whether current date exists
if isfield(settings, 'date_current')
    date_current = settings.date_current;
else
    date_current = [];
end

% Initialize directory name
dir_name = [];
if length(varargin) >= 1
    dir_name = varargin{1};
end

% Initialize file append name
file_name_append = [];
if length(varargin)>=2
    file_name_append = varargin{2};
end

% Initialize session number
session_current = [];
if length(varargin)>=3
    session_current = varargin{3};
end


%% Create short path

%==========
% Retrieve path to the generic folder (unspecific to date or subject);
clear path1;
f1 = sprintf('path_%s', dir_name);
if isfield (settings, f1)
    path1 = settings.(f1);
end

% If it is figures folder, add figures name
if strcmp(dir_name, 'figures')
    if isfield(settings, 'figure_folder_name')
        f1 = settings.figure_folder_name;
        if ismac
            path1 = sprintf('%s%s/', path1, f1);
        elseif ispc
            path1 = sprintf('%s%s\', path1, f1);
        else
            path1 = sprintf('%s%s/', path1, f1);
        end
    else
        error ('Field "settings.figure_folder_name" not specified')
    end
end

% First, read out folder name and decide whether to make it subject
% specific or not. If folders exist, then dont make path subject specific;
temp0 = get_path_dates_v20(path1, subject_current);

%=============
% Generate path to the subject
if isempty(temp0.index_dates)
    f1 = subject_current;
    if ismac
        path1 = sprintf('%s%s/', path1, f1);
    elseif ispc
        path1 = sprintf('%s%s\', path1, f1);
    else
        path1 = sprintf('%s%s/', path1, f1);
    end
end

%==================
% If it's a short path version, terminate analysis here
%==================


%% Create short folder and file name

%============
% Create short version of folder name and file name by default

    
% Make sure date is in string format
d_c1 = date_current;
if ~isempty(d_c1) && ~isstr(d_c1)
    d_c1 = num2str(d_c1);
end

% Make sure session number is in string format
s_c1 = session_current;
if ~isempty(s_c1) && ~isstr(s_c1)
    s_c1 = num2str(s_c1);
end

% Create folder name and file name
if ~isempty(s_c1) && ~isempty(d_c1)
    folder_name = sprintf('%s%s_%s', subject_current, d_c1, s_c1);
elseif ~isempty(d_c1)
    folder_name = sprintf('%s%s', subject_current, d_c1);
else
end

% Create file name
if ~isempty(file_name_append)
    file_name = sprintf('%s%s', folder_name, file_name_append);
end


%% Create long folder and file name (if needed)

%============
% Determine folder format used - if it is short or long
% If it is long, then make a decision to over-write it

% Get dates
temp1 = get_path_dates_v20(path1, subject_current);

% Over-write folder name if needed
if ~isempty(temp1.index_unique_dates)
    if sum(temp1.index_dates == date_current)>0 % If folder for given date exists
        
        % Find current folder
        if ~isempty(session_current)
            ind = temp1.index_dates == date_current & temp1.index_sessions == session_current;
        else
            ind = temp1.index_dates == date_current;
        end
        
        % If folder name does not match short folder name
        if ~strcmp(temp1.index_directory(ind), folder_name)
            folder_name = temp1.index_directory(ind);
            if iscell(folder_name)
                folder_name = folder_name{1};
            end
            if ~isempty(file_name_append)
                file_name = sprintf('%s%s', folder_name, file_name_append);
            end
        end
        
    end
end
    


%% Generate long path to the file

if ~isempty(date_current)
    
    if ismac
        path1_date = sprintf('%s%s/', path1, folder_name);
    elseif ispc
        path1_date = sprintf('%s%s\', path1, folder_name);
    else
        path1_date = sprintf('%s%s/', path1, folder_name);
    end
    
end

if ~isempty(file_name_append)
    
    if ismac
        path1 = sprintf('%s%s/%s', path1, folder_name, file_name);
    elseif ispc
        path1 = sprintf('%s%s\%s', path1, folder_name, file_name);
    else
        path1 = sprintf('%s%s/%s', path1, folder_name, file_name);
    end
    
end


%% Output

y1 = path1;
y2 = path1_date;

if ~isempty(file_name_append)
    y3 = file_name;
else
    y3 = [];
end
