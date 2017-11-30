% Define the paths where code, figures, data, server access is specified.

%% DJ office

if isfield (settings, 'exp_setup') && strcmp(settings.exp_setup, 'dj office')
    
    % "analysis" code is stored in:
    settings.path_baseline_code = sprintf('~/proj/experiments/');
    settings.path_baseline_figures = sprintf('~/Dropbox/Experiments/');
    
    % "Experiments_data" folder with eyelink and psychtoolbox data:
    settings.path_baseline_data = sprintf('~/proj/experiments_data/');
    
    % "Experiments_data" folder, with plexon data:
    % (might differ from other psychtoolbox data folder due to large plexon file sizes)
    settings.path_baseline_plexon = sprintf('~/data/neurophysiology/Experiments_data/');
    
    % Path to plexon toolbox
    settings.path_plexon_toolbox = '~/Dropbox/MatlabToolbox/PlexonMatlabOfflineFiles/';
    
    % Path to server to download data
    settings.path_baseline_server = '/Volumes/tirin/data/RigE/Experiments_data/';
    
end


%% Plexon computer
    
if isfield (settings, 'exp_setup') && strcmp(settings.exp_setup, 'plexon')
    
    % "analysis" code is stored in:
    settings.path_baseline_code = 'C:\Users\Plexon\Desktop\Experiments\';
    settings.path_baseline_figures = 'C:\Users\Plexon\Desktop\Experiments_figures\';
    
    % "Experiments_data" folder with eyelink and psychtoolbox data:
    settings.path_baseline_data = 'C:\Users\Plexon\Desktop\Experiments_data\';
    
    % "Experiments_data" folder, with plexon data:
    % (might differ from other psychtoolbox data folder due to large plexon file sizes)
    settings.path_baseline_plexon = 'C:\Users\Plexon\Desktop\Experiments_data\';
    
    % Path to plexon toolbox
    settings.path_plexon_toolbox = '~/Dropbox/MatlabToolbox/PlexonMatlabOfflineFiles/';
    
    % Path to server to download data
    settings.path_baseline_server = 'Y:\data\RigE\Experiments_data\';
    
end

%% Experiments computer

if isfield (settings, 'exp_setup') && strcmp(settings.exp_setup, 'edoras')
    
    % "analysis" code is stored in:
    settings.path_baseline_code = 'C:\Users\Rig-E\Desktop\GitExp\';
    settings.path_baseline_figures = 'C:\Users\Rig-E\Desktop\Experiments_figures';
    
    % "Experiments_data" folder with eyelink and psychtoolbox data:
    settings.path_baseline_data = 'C:\Users\Rig-E\Desktop\Experiments_data\';
    
    % "Experiments_data" folder, with plexon data:
    % (might differ from other psychtoolbox data folder due to large plexon file sizes)
    settings.path_baseline_plexon = 'C:\Users\Rig-E\Desktop\Experiments_data\';
    
    % Path to plexon toolbox
    settings.path_plexon_toolbox = '~/Dropbox/MatlabToolbox/PlexonMatlabOfflineFiles/';
    
    % Path to server to download data
    settings.path_baseline_server = 'Z:\data\RigE\Experiments_data\';
    
end

%% Catch errors

if ~isfield (settings, 'path_baseline_code')
    error ('exp_setup not defined. No paths are specified in the path_definitions file');
end
