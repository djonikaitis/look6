% Defines conditions of interest and sets the colors for the paper


%%  Initialize path to the experiment (will change on different computers);


look6_path_definitions


%%  Which dates to process


if ~isfield (settings, 'data_sessions')
    settings.data_sessions = 'last';
end

if strcmp(settings.data_sessions, 'all')
elseif strcmp(settings.data_sessions, 'last')
elseif strcmp (settings.data_sessions, 'before')
    settings.data_sessions_temp = 20170401; 
elseif strcmp (settings.data_sessions, 'after')
    settings.data_sessions_temp = 20170901; 
elseif strcmp (settings.data_sessions, 'interval')
    settings.data_sessions_temp = [20170330, 20170401]; 
elseif strcmp(settings.data_sessions, 'selected')
    settings.data_sessions_temp = 20170919; % Which day data to analyse (IF using manual selection only, otherwise this value is ignored)
end



%% All subjects used in the task

s1{1}='aq';
s1{2}='hb';

if ~iscell(settings.subjects) && strcmp(settings.subjects, 'all')
    settings.subjects = cell(1);
    settings.subjects = s1;
elseif ~iscell(settings.subjects)
    a = settings.subjects;
    settings.subjects = cell(1); 
    settings.subjects{1} = a;
else
    % Will keep whatever subjects there are speficied as a cell
end


%% Initialize all major paths
% No changes needed at this part of the code

% Analysis folder
settings.path_code = sprintf('%s%s/',settings.path_baseline_code, settings.exp_name);
if isdir (settings.path_code)
else
    error('Code baseline path not specified correctly')
end

% Add path with helper functions
settings.path_helper_functions = sprintf('%shelper_functions/',settings.path_code);
if isdir (settings.path_helper_functions)
    addpath(genpath(settings.path_helper_functions));
else
    error('Helper functions path not specified correctly')
end

% Add plexon toolbox (must be installed)
if isdir (settings.path_plexon_toolbox)
    addpath (settings.path_plexon_toolbox)
else
    fprintf('\nPlexon toolbox path not specified, will skip analysis of plexon files\n')
end


%%  Folders where different data is stored

% Names of folders (no changes here needed)
path_spec_names = cell(1);
path_spec_names{1} = {'figures'; settings.path_baseline_figures};
path_spec_names{2} = {'data_combined'; settings.path_baseline_data};
path_spec_names{3} = {'data_psychtoolbox'; settings.path_baseline_data};
path_spec_names{4} = {'data_eyelink_edf'; settings.path_baseline_data};
path_spec_names{5} = {'data_temp_1';  settings.path_baseline_data}; % Converted into .asc and .dat files
path_spec_names{6} = {'data_temp_2'; settings.path_baseline_data}; % Combine saccades + psychtoolbox into one file
path_spec_names{7} = {'data_plexon_raw'; settings.path_baseline_plexon}; % Raw plexon data
path_spec_names{8} = {'data_plexon_temp_1'; settings.path_baseline_plexon}; % Plex sorted data (using plex utility)
path_spec_names{9} = {'data_plexon_temp_2'; settings.path_baseline_plexon}; % Extracted spikes, events, analog - not processed at all
path_spec_names{10} = {'data_combined_plexon'; settings.path_baseline_plexon}; % Mat structures of plexon data

% Generate path names
for i=1:numel(path_spec_names)
    v1 = ['path_', path_spec_names{i}{1}];
    v2 = sprintf('%s%s/%s/', path_spec_names{i}{2}, settings.exp_name,  path_spec_names{i}{1});
    settings.(v1) = v2;
end

%% Drift correction settings

% Drift correction settings
settings.drift_correction_on = 1;
settings.drift_correction_window_min = 0.3; % Min eye distance from fixation for drift correction (1/2 fixation size)
settings.drift_correction_window_max = 'esetup_fixation_size_drift'; % Max eye distance from fixation for drift correction
settings.drift_correction_sacc_amp = 0.5; % Max eye distance from fixation for drift correction
settings.drift_correction_time = 'fixation_drift_maintained'; % Field used for drift correction in LOOK 6
settings.drift_correction_time_backup = 'drift_maintained'; % Field used for drift correction in LOOK 5
settings.drift_correction_tstart = -110;
settings.drift_correction_tend = -10;
settings.drift_correction_trials = 11; % How many trials to use for drift correction
settings.drift_correction_method = 'median'; % 'mean' or 'median' or 'each trial'


%% Shared settings for analysis

settings.trial_total_threshold = 5; % How many trials have to be at least in the bin
settings.tboot1 = 10000; % How many times to bootstrap?
settings.p_level = 0.05; % P-value reported for signifficance
settings.error_bars = 'sem'; % 1 - bootstrap; 2 - sem;

% How big figure is?
settings.figsize_1col=[0, 0, 2.2, 2.2];
settings.figsize_2col=[0, 0, 4.5, 2.2];
settings.figsize_4col=[0, 0, 7.2, 2.2];

% Settings for doing sliding window analysis
settings.timestep = 50;
settings.intervalbins_tex=[-200:settings.timestep:500]; % Bins locked to cue
settings.intervalbins_tex_radial = [-200:settings.timestep:500]; % Large bins for plotting texture selectivity
settings.intervalbins_mem=[-200:settings.timestep:1500]; % Bins locked to memory
settings.intervalbins_sacc=[-600:settings.timestep:100]; % Bins locked to saccade cue
settings.bin_length = 80; % Milisecconds used for each time bin (for sliding window size)
settings.bin_length_long = 160; % Longer time bins
settings.baseline_bin_count = 3; % How many time bins to use for moving average analysis

settings.colormap = 'magma';

%% Figure colors

color1=[];

%===========
% Spikes, SRT

% Three differfent tasks
color1(1,:)=[0.2, 0.8, 0.3]; % Look probe
color1(2,:)=[1, 0, 0.1]; % Avoid probe
color1(3,:)= [0.2, 0.2, 0.7]; % Control 1
color1(4,:)= [0.6, 0.2, 1]; % Control 2

d1 = [1,1,1]-color1(1,:);
color1(5,:)=color1(1,:)+d1.*0.4; % Look main
d1 = [1,1,1]-color1(2,:);
color1(6,:)=color1(2,:)+d1.*0.4; % Avoid main
d1 = [1,1,1]-color1(3,:);
color1(7,:)=color1(3,:)+d1.*0.4; % Control1
d1 = [1,1,1]-color1(4,:);
color1(8,:)=color1(4,:)+d1.*0.4; % Control2

% Cued vs uncued location
color1(9,:)= [0.2, 0.8, 0.2]; % Cued
color1(10,:)= [0.3, 0.3, 0.3]; % Uncued
color1(11,:) = [0.1, 0.5, 0.4]; % Correct
color1(12,:) =  [1, 0.7, 0]; % Error
%===========
% Spikes

% Texture responses, spikes
color1(21,:)=[0.6, 0.6, 0.6]; % No texture
color1(22,:)=[0.1, 0.1, 0.1]; % Orientation 0
color1(23,:)=[0.2, 0.2, 1]; % Orientation max

% Location responses, neurophys
color1(24,:)=[0.3, 0.3, 0.3]; % Location min
color1(25,:)=[0.8, 0.8, 0.8]; % Location max

%===============
% Training effects
color1(41,:) = [1, 0.7, 0]; % Natural loss
color1(42,:) = [1, 0, 0.1]; % Aborted trials
color1(43,:) = [0.1, 0.5, 0.4]; % Correct trials


% ===============
% Face color
for i=1:size(color1,1)
    d1 = 1-color1(i,:);
    face_color1(i,:)=color1(i,:)+d1.*0.6;
end

%============
% Markers
marker1{1}='o';
marker1{2}='o'; 
marker1{3}='o'; 
marker1{4}='o';
marker1{5}='^'; 
marker1{6}='s'; 
marker1{7}='^'; 
marker1{8}='^';
marker1{9}='o'; 
marker1{10}='o'; 
marker1{11}='o'; 
marker1{12}='o';
marker1{13}='o'; 
marker1{14}='o'; 
marker1{15}='o';
marker1{16}='o';  
marker1{17}='o'; 
marker1{18}='o'; 
marker1{19}='o'; 
marker1{20}='o';


%============
% All other
settings.msize = 3;
settings.wlineerror = 0.9; 
settings.wlinegraph = 1.8;
settings.fontsz = 8;
settings.fontszlabel = 8; % 10

settings.color1 = color1;
settings.face_color1 = face_color1;
settings.marker1 = marker1;
