
function settings = get_settings_path_and_dates_ini_v10(settings)


% Check whether current subject exists
if isfield(settings, 'subject_current')
else
    error ('settings.subject_current not defined')
end

% Initialize subject specific folders where data is stored
f1 = fieldnames(settings);
ind_d = strncmp(f1,'path_data_', 10);
ind_s = strfind(f1, '_subject');
for i = 1:numel(ind_d)
    if ind_d(i)==1 && isempty(ind_s{i})
        v1 = sprintf('%s%s', f1{i}, '_subject'); % Fieldname
        v2 = sprintf('%s%s/', settings.(f1{i}), settings.subject_current); % Path
        settings.(v1) = v2;
    end
end

% Get index of every folder for a given subject
path1 = settings.path_data_combined_subject;
session_init = get_path_dates_v20(path1, settings.subject_current);
if isempty(session_init.index_dates)
    fprintf('\nNo files detected, no data analysis done. Directory checked was:\n')
    fprintf('%s\n', path1)
end

% Save session_init data into settings matrix (needed for preprocessing)
f1_data = fieldnames(session_init);
for i=1:length(f1_data)
    settings.(f1_data{i}) = session_init.(f1_data{i});
end

% Which date to analyse (all days or a single day)
if isfield(settings, 'data_sessions')
    if strcmp (settings.data_sessions, 'all')
        ind = 1:length(session_init.index_unique_dates);
    elseif strcmp (settings.data_sessions, 'selected')
        ind = find(session_init.index_unique_dates==settings.data_sessions_temp);
    elseif strcmp (settings.data_sessions, 'last')
        ind = length(session_init.index_unique_dates);
    else
        fprintf('settings.data_sessions_used not defined, analyzing last session recorded\n')
        ind = length(session_init.index_unique_dates);
    end
else
    fprintf('settings.data_sessions_used not defined, analyzing last session recorded\n')
    ind = length(session_init.index_unique_dates);
end
settings.data_sessions_to_analyze = session_init.index_unique_dates(ind);

