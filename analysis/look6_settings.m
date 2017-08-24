% Defines conditions of interest and sets the colors for the paper


%% All subjects used in the task

% subjects{1}='aq';
% subjects{2}='hb';

if strcmp(sN1, 'all')
    settings.subjects=subjects;
else
    settings.subjects{1}=sN1;
end

% Settings for preprocessing (conversion of edf, plexon files)
settings.preprocessing_sessions_used = 2; % 1 - all sessions used; 2 - selected session used (denoted as date: 20161231); 3 - last session used;
if settings.preprocessing_sessions_used ==2
    settings.preprocessing_day_id = 20170506; % Which day data to analyse (IF using manual selection only, otherwise this value is ignored)
end


%%  Initialize path to the experiment (will change on different computers);


% "analysis" code is stored in:
settings.path_baseline_code = sprintf('~/proj/experiments/');

% "Experiments_data" folder with eyelink and psychtoolbox data is stored in:
% settings.path_baseline_data = sprintf('~/data/neurophysiology/Experiments_data/');
settings.path_baseline_data = sprintf('~/Dropbox/Experiments_data/');
% settings.path_baseline_data = sprintf('/Volumes/group/tirin/data/RigE/Experiments_data');

% "Experiments_data" folder, with plexon data is stored in:
% (might differ from data_root folder due to large data file sizes)
settings.path_baseline_plexon = sprintf('~/data/neurophysiology/Experiments_data/');

% Path to plexon toolbox
settings.path_plexon_toolbox = '~/Dropbox/MatlabToolbox/PlexonMatlabOfflineFiles/';



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

% Add folder for figures
settings.path_figures = sprintf('%s%s/figures/', settings.path_baseline_code, settings.exp_name);


% Folders where different data is stored
% Names of folders
settings.path_spec_names{1} = 'data_combined';
settings.path_spec_names{2} = 'data_psychtoolbox';
settings.path_spec_names{3} = 'data_eyelink_edf';
settings.path_spec_names{4} = 'data_eyelink_asc';
settings.path_spec_names{5} = 'data_plexon_mat';
settings.path_spec_names{6} = 'data_plexon_raw';
settings.path_spec_names{7} = 'data_combined_plexon';
settings.path_spec_names{8} = 'data_spikes';
% Path to folders (might differ for different data types, depends upon data storage demands)
settings.path_spec_folder{1} = sprintf('%s%s/%s/', settings.path_baseline_data, settings.exp_name, settings.path_spec_names{1});
settings.path_spec_folder{2} = sprintf('%s%s/%s/', settings.path_baseline_data, settings.exp_name, settings.path_spec_names{2});
settings.path_spec_folder{3} = sprintf('%s%s/%s/', settings.path_baseline_data, settings.exp_name, settings.path_spec_names{3});
settings.path_spec_folder{4} = sprintf('%s%s/%s/', settings.path_baseline_data, settings.exp_name, settings.path_spec_names{4});
settings.path_spec_folder{5} = sprintf('%s%s/%s/', settings.path_baseline_plexon, settings.exp_name, settings.path_spec_names{5});
settings.path_spec_folder{6} = sprintf('%s%s/%s/', settings.path_baseline_plexon, settings.exp_name, settings.path_spec_names{6});
settings.path_spec_folder{7} = sprintf('%s%s/%s/', settings.path_baseline_data, settings.exp_name, settings.path_spec_names{7});
settings.path_spec_folder{8} = sprintf('%s%s/%s/', settings.path_baseline_data, settings.exp_name, settings.path_spec_names{8});

% Generate path names
for i=1:length(settings.path_spec_names)
    v1 = ['path_', settings.path_spec_names{i}];
    settings.(v1) = settings.path_spec_folder{i};
end



%% Shared settings for analysis


settings.trial_total_threshold=1; % How many trials have to be at least in the bin
settings.tboot1 = 10000; % How many times to bootstrap?
settings.p_level = 0.05; % P-value reported for signifficance
settings.error_bars = 2; % 1 - bootstrap; 2 - sem;

% How big figure is?
settings.figsize=[0, 0, 2.2, 2.2];
% settings.figsize=[0, 0, 1.8, 2.5]; % Temporary, for SFN

% color1=[];

% Settings for doing sliding window analysis
settings.timestep=25;
settings.intervalbins_tex=[-200:settings.timestep:450]; % Bins locked to cue
settings.intervalbins_mem=[-200:settings.timestep:1000]; % Bins locked to memory
settings.intervalbins_sacc=[-700:settings.timestep:100]; % Bins locked to saccade cue
settings.bin_length=40; % Milisecconds used for each time bin (for sliding window size)
settings.baseline_bin_count = 3; % How many time bins to use for moving average analysis

%% Figure colors

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




% % % Trajectories
% % 
% % color1(11,:)=[0.2, 0.4, 1]; % Traject: free choice CCW
% % d1 = [1,1,1]-color1(11,:);
% % color1(12,:)=color1(11,:)+d1.*0.4; % Traject: free choice CW
% % color1(13,:)=[0.05, 0.5, 0.4]; % Traject: rule choice CCW
% % d1 = 1-color1(13,:);
% % color1(14,:)=color1(13,:)+d1.*0.4; % Traject: rule choice CW
% % 
% % color1(15,:) = ; % Traject, -72 CCW
% % d1 = 1-color1(15,:);
% % color1(16,:)=color1(15,:)+d1.*0.4; % Traject: +72 CW
% % color1(17,:) = [0, 0.8, 0.7]; % Traject -144 CCW
% % d1 = 1-color1(17,:);
% % color1(18,:)=color1(17,:)+d1.*0.4; % Traject: +144 CW
% % 
% % color1(19,:)=[1, 0, 0.1]; % Traject: errors, CCW
% % d1 = 1-color1(19,:);
% % color1(20,:)=color1(19,:)+d1.*0.4; % Traject: errors CW
% % 
% % % Short and long latencies
% % color1(21,:) = [1, 0.7, 0]; % Saccade target, short latency
% % d1 = 1-color1(21,:);
% % color1(22,:)=color1(21,:)+d1.*0.4; % Long latency
% % 
% % color1(23,:) = [0.2, 0.8, 0.3]; % Non-chosen target, short latency
% % d1 = 1-color1(23,:);
% % color1(24,:)=color1(23,:)+d1.*0.4; % Long latency
% % 
% % color1(25,:)=[1, 0, 0.1]; % Error, short latency
% % d1 = 1-color1(25,:);
% % color1(26,:)=color1(25,:)+d1.*0.4; % Long latency
% % 
% % color1(27,:)=[0.6, 0.6, 0.6]; % Irrelevant, short latency
% % d1 = 1-color1(27,:);
% % color1(28,:)=color1(27,:)+d1.*0.4; % Long latency
% % 
% % 
% % % Colors for different targets (green, blue);
% % color1(29,:)=[0.2, 0.4, 1]; % Free choice
% % color1(30,:)=[0.2, 0.8, 0.3]; % Non-chosen target
% % color1(31,:)=[0.6, 0.6, 0.6]; % Irrelevant


% ===============
% Face color
for i=1:size(color1,1)
    d1 = 1-color1(i,:);
    facecolor1(i,:)=color1(i,:)+d1.*0.6;
end


%============
% Markers
marker1{1}='o'; marker1{2}='o'; marker1{3}='o'; marker1{4}='o';
marker1{5}='^'; marker1{6}='s'; marker1{7}='^'; marker1{8}='^';
marker1{9}='o'; marker1{10}='o'; marker1{11}='o'; marker1{12}='o';
marker1{13}='o'; marker1{14}='o'; marker1{15}='o';
 marker1{16}='o';  marker1{17}='o'; marker1{18}='o'; marker1{19}='o'; marker1{20}='o';

 %============
% All other
settings.msize=3;
settings.wlineerror=0.9; 
settings.wlinegraph=1.8;
settings.fontsz=8;
settings.fontszlabel=8; % 10


