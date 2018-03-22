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

Next, modify path definitions. Reasoning is very simple: "look6" is experiment name, and question is where are you storing folder "look6" that contains different subfolders "experiment", "analysis", "data".

    % "analysis" code is stored in:
    settings.path_baseline_code = sprintf('~/proj/experiments/');

"baseline_code" refers to where folder "look6/experiment" is stored. In my case it is in directory '~/proj/experiments/look6/experiment'. As you see, settings.path_baseline_code specifies just short directory - '~/proj/experiments/', without adding 'look6/experiment'. This is always taken care of automatically and all following directions have to be short.

    settings.path_baseline_figures = sprintf('~/Dropbox/Experiments/');
    
"baseline_figures" is where output of all analysis is stored. In my case its in dropbox, for easy sharing. Modify where you want "look6/figures" to get stored.
    
    % "Experiments_data" folder with eyelink and psychtoolbox data:
    settings.path_baseline_data = sprintf('~/proj/experiments_data/');
    
"baseline_data" is again stored in computer, to save dropbox space. Thus full path is '~/proj/experiments_data/look6/data'. Modify it according to your setup.
    
    % "Experiments_data" folder, with plexon data:
    % (might differ from other psychtoolbox data folder due to large plexon file sizes)
    settings.path_baseline_plexon = sprintf('~/proj/experiments_data/');
    
In some cases you might wanna store plexon data separately, as files are massive. However, you dont need change this, as I won't provide any raw plexon data.

    % Path to plexon toolbox
    settings.path_plexon_toolbox = '~/Dropbox/MatlabToolbox/PlexonMatlabOfflineFiles/';
    
No need to modify this, as no access to raw plexon data provided.
    
    % Path to server to download data
    settings.path_baseline_server = '/Volumes/tirin/data/RigE/Experiments_data/';
    
No access to server provided either.

So if you modified your paths, we are good to go!


