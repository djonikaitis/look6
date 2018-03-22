# look6

"analysis" folder contains all scripts necessary for analysis. "experiment" folder runs experiment.
"helper functions" folder contains all side scripts that are used for analysis and experiment.

Lets focus on "analysis" folder first. 
All codes are run by using "analysis_vXX" file (XX is a number that denotes file version). If you run this code, all analysis should be performed. However, this file wont work, before you change path settings.

open file "look6_path_definitions". Here you must specify path where data is stored. As you recall, experiment is called "look6", so all paths are specifying where you are storing the folder "look6". You can have multiple "look6" folders for storing experiment code, raw data and figures. This is done so that you could manage storage space effectivelly. As example, let's have a look how I store data on "DJ office" setup (section starting on line 17 in the "look6_path_definitions" file). Easiest is for you to copy this section and modify it based on your setup. For example, you will call your setup as 'guest setup'.

    if (~isempty (macaddress) && sum(macaddress==[136; 99; 223; 185; 223; 187])==6) || ...
        (isfield (settings, 'exp_setup') && strcmp(settings.exp_setup, 'dj office'))
        
modify this part into:

    if (~isempty (macaddress) && sum(macaddress==[YOUR MAC ADDRESS])==6) || ...
        (isfield (settings, 'exp_setup') && strcmp(settings.exp_setup, 'guest setup'))

Next, modify path definitions. Reasoning is very simple: "look6" is experiment name, and question is where are you storing folder "look6"?

    % "analysis" code is stored in:
    settings.path_baseline_code = sprintf('~/proj/experiments/');
"baseline_code" refers to where folder "experiments" is stored. For example, it could be for you in your 

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



"look6" folder with all figures is stored in the path '~/Dropbox/Experiments/', whereas all data is stored in the path '~/proj/experiments_data/'. I could store all data on dropbox, but I don't have enough space there, thus data is stored under separate path. Edit the fields "settings.path_" to match your computer.
Also, I use mac address to access each setup without changing the code (variable "macaddress"). For this you find your mac address, and correspondingly edit the code. Alternatively, you could also name your setup and access it as a settings part. For example, if you want to call your setup 'guest_setup', 

