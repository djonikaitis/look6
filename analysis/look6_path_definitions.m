% Define the paths where code, figures, data, server access is specified.


%% Get mac address for automatic setup assignment

try
    localhost = java.net.InetAddress.getLocalHost;
    networkinterface = java.net.NetworkInterface.getByInetAddress(localhost);
    macaddress = typecast(networkinterface.getHardwareAddress, 'uint8');
catch
    macaddress = [];
    error ('Could not get mac address')
end


%% DJ office

if (~isempty (macaddress) && sum(macaddress==[136; 99; 223; 185; 223; 187])==6) || ...
        (isfield (settings, 'exp_setup') && strcmp(settings.exp_setup, 'dj office'))
    
    % save setup name
    settings.exp_setup = 'dj office';
    
    % "analysis" code is stored in:
    settings.path_baseline_code = sprintf('~/proj/experiments/');
    settings.path_baseline_figures = sprintf('~/Dropbox/Experiments/');
    
    % "Experiments_data" folder with eyelink and psychtoolbox data:
    settings.path_baseline_data = sprintf('~/proj/experiments_data/');
    
    % "Experiments_data" folder, with plexon data:
    % (might differ from other psychtoolbox data folder due to large plexon file sizes)
    settings.path_baseline_plexon = sprintf('~/proj/experiments_data/');

    % Path to plexon toolbox
    settings.path_plexon_toolbox = '~/Dropbox/MatlabToolbox/PlexonMatlabOfflineFiles/';
    
    % Path to server to download data
    settings.path_baseline_server = '/Volumes/tirin/data/RigE/Experiments_data/';
        
end


%% Plexon office


if (~isempty (macaddress) && sum(macaddress==[100; 0; 106; 109; 3; 123])==6) || ...
    (isfield (settings, 'exp_setup') && strcmp(settings.exp_setup, 'plexon office'))

    % save setup name
    settings.exp_setup = 'plexon office';

    % "analysis" code is stored in:
    settings.path_baseline_code = 'E:\DJ_exp\Experiments\';
    settings.path_baseline_figures = 'E:\DJ_exp\Experiments_figures\';
    
    % "Experiments_data" folder with eyelink and psychtoolbox data:
    settings.path_baseline_data = 'E:\DJ_exp\Experiments_data\';
    
    % "Experiments_data" folder, with plexon data:
    % (might differ from other psychtoolbox data folder due to large plexon file sizes)
    settings.path_baseline_plexon = 'E:\DJ_exp\Experiments_data\';
    
    % Path to plexon toolbox
    settings.path_plexon_toolbox = 'E:\DJ_exp\Experiments\toolbox\PlexonMatlabOfflineFiles\';
    
    % Path to server to download data
    settings.path_baseline_server = 'Z:\data\RigE\Experiments_data\';
    
    % Path to eyelink converter
    settings.edf2asc_path = '"E:\Program Files (x86)\SR Research\EyeLink\EDF_Access_API\Example\edf2asc.exe"';
    
end


%% Plexon computer lab
    
% if isfield (settings, 'exp_setup') && strcmp(settings.exp_setup, 'plexon')
%     
%     % "analysis" code is stored in:
%     settings.path_baseline_code = 'C:\Users\Plexon\Desktop\Experiments\';
%     settings.path_baseline_figures = 'C:\Users\Plexon\Desktop\Experiments_figures\';
%     
%     % "Experiments_data" folder with eyelink and psychtoolbox data:
%     settings.path_baseline_data = 'C:\Users\Plexon\Desktop\Experiments_data\';
%     
%     % "Experiments_data" folder, with plexon data:
%     % (might differ from other psychtoolbox data folder due to large plexon file sizes)
%     settings.path_baseline_plexon = 'C:\Users\Plexon\Desktop\Experiments_data\';
%     
%     % Path to plexon toolbox
%     settings.path_plexon_toolbox = 'C:\Users\Plexon\Desktop\Experiments\toolbox\PlexonMatlabOfflineFiles\';
%     
%     % Path to server to download data
%     settings.path_baseline_server = 'Y:\data\RigE\Experiments_data\';
%     
%     % Path to eyelink converter
%     settings.edf2asc_path = '"C:\Program Files (x86)\SR Research\EyeLink\EDF_Access_API\Example\edf2asc.exe"';
%     
% end


%% Experiments computer

% if isfield (settings, 'exp_setup') && strcmp(settings.exp_setup, 'edoras')
%     
%     % "analysis" code is stored in:
%     settings.path_baseline_code = 'C:\Users\Rig-E\Desktop\GitExp\';
%     settings.path_baseline_figures = 'C:\Users\Rig-E\Desktop\Experiments_figures';
%     
%     % "Experiments_data" folder with eyelink and psychtoolbox data:
%     settings.path_baseline_data = 'C:\Users\Rig-E\Desktop\Experiments_data\';
%     
%     % "Experiments_data" folder, with plexon data:
%     % (might differ from other psychtoolbox data folder due to large plexon file sizes)
%     settings.path_baseline_plexon = 'C:\Users\Rig-E\Desktop\Experiments_data\';
%     
%     % Path to plexon toolbox
%     settings.path_plexon_toolbox = 'C:\Users\Rig-E\Desktop\Experiments\toolbox\PlexonMatlabOfflineFiles\';
% 
%     % Path to server to download data
%     settings.path_baseline_server = 'Z:\data\RigE\Experiments_data\';
%     
%     % Path to eyelink converter 
%     settings.edf2asc_path = '"C:\Program Files (x86)\SR Research\EyeLink\EDF_Access_API\Example\edf2asc.exe"';
%     
% end

%% Catch errors

if ~isfield (settings, 'path_baseline_code')
    error ('No paths are specified in the path_definitions file');
end
