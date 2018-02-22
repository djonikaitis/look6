% v1.0 September, 2017. Basic version
% v1.1 Octover 24, 2017. Added extra input to specify path name to check
% v1.0 January 19, 2018. Simplified with only output being "dates used".
% Renamed the function, thus reset to v1.0

function dates_used = get_dates_used_v10(settings, varargin)

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
        path1 = sprintf('%s%s/', path1, f1);
    elseif ispc
        path1 = sprintf('%s%s\', path1, f1);
    else
        path1 = sprintf('%s%s/', path1, f1);
    end
end

if isempty(temp0.index_dates)
    temp1 = get_path_dates_v20(path1, subject_current);
    if isempty(temp1.index_dates)
        fprintf('\nNo files detected, no data analysis done. Directory checked was:\n')
        fprintf('%s\n', path1)
    end
else
    temp1 = temp0; 
    clear temp0;
end


% Which date to analyse (all days or a single day)
if isfield(settings, 'data_sessions')
    if strcmp (settings.data_sessions, 'all')
        ind = 1:length(temp1.index_unique_dates);
    elseif strcmp (settings.data_sessions, 'last')
        ind = length(temp1.index_unique_dates);
    elseif strcmp (settings.data_sessions, 'before')
        ind = find(temp1.index_unique_dates<=settings.data_sessions_temp);
    elseif strcmp (settings.data_sessions, 'after')
        ind = find(temp1.index_unique_dates>=settings.data_sessions_temp);
    elseif strcmp (settings.data_sessions, 'interval')
        ind = find(temp1.index_unique_dates>=settings.data_sessions_temp(1) & temp1.index_unique_dates<=settings.data_sessions_temp(2));
    elseif strcmp (settings.data_sessions, 'selected')
        ind = find(temp1.index_unique_dates==settings.data_sessions_temp);
    else
        fprintf('settings.data_sessions_used not defined, analyzing last session recorded\n')
        ind = length(temp1.index_unique_dates);
    end
else
    fprintf('settings.data_sessions_used not defined, analyzing last session recorded\n')
    ind = length(session_init.index_unique_dates);
end

if sum(ind)>0
    dates_used = temp1.index_unique_dates(ind);
else
    dates_used = [];
end

