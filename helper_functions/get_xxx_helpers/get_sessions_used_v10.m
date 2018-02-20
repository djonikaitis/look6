% Function checks given date and finds how many sessions are recorded
% v1.0 February 19, 2018. Simplified with only output being "sessions used"

function sessions_used = get_sessions_used_v10(settings, varargin)

if length(varargin)==1
    dir_name = varargin{1};
else
    dir_name = 'data_combined';
end

% Check whether current subject exists
if isfield(settings, 'subject_current')
    subject_current = settings.subject_current;
else
    error ('settings.subject_current not defined')
end

% Check whether current subject exists
if isfield(settings, 'date_current')
    date_current = settings.date_current;
else
    error ('settings.date_current not defined')
end

%==========
% Retrieve path to the folder
clear path1;
f1 = sprintf('path_%s', dir_name);
if isfield (settings, f1)
    path1 = settings.(f1);
end

% First, read out folder name and decide whether to make it subject
% specific or not. If folders exist, then dont make path subject specific;
temp0 = get_path_dates_v20(path1, subject_current);

%=============
% Generate path to the subject

if isempty(temp0.index_dates)
    f1 = subject_current;
    if ismac
        path2 = sprintf('%s%s/', path1, f1);
    elseif ispc
        path2 = sprintf('%s%s\', path1, f1);
    else
        path2 = sprintf('%s%s/', path1, f1);
    end
end

% Generate path to current date
if isempty(temp0.index_dates)
    temp1 = get_path_dates_v20(path2, subject_current);
    if isempty(temp1.index_dates)
        fprintf('\nNo files detected, no data analysis done. Directory checked was:\n')
        fprintf('%s\n', path2)
        sessions_used = [];
    elseif ~isempty(temp1.index_dates)
        ind = settings.date_current == temp1.index_dates;
        sessions_used = temp1.index_sessions(ind);
    end
else
    temp1 = temp0; 
    clear temp0;
    sessions_used = [];
end


