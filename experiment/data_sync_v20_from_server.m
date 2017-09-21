% Synchronize the data with the server
% v1.0 DJ: August 11, 2016. Basic code.
% v2.0 DJ April 2, 2017. Roather quick code, able to work on its own,
% independent of experiment code. Assumption that data is stored as:
% exp_name\data_type\subject_name\session_folder\file_name
% for example: look5\plexon_data\hb\hb_2017_01_01\hb_2017_01_01.pl2
% Data has to be organized... get over it...

clear all;

expsetup.general.directory_baseline_data_output = '/Users/DJ/Dropbox/Experiments_data/';
expsetup.general.directory_baseline_data_input = '/Volumes/group/tirin/data/RigE/Experiments_data/';
expsetup.general.expname = 'look6'; % Experiment name
expsetup.general.subject_id = 'all'; % Subject name

path_append = cell(1);
path_append{1}='data_eyelink_edf';
path_append{2}='data_psychtoolbox';
path_append{3}=' figures_online_averages';


% Rename few variables for better code compatibility
path1_input = expsetup.general.directory_baseline_data_input; % Data path on computer
path1_output = expsetup.general.directory_baseline_data_output; % Data path on the server
expname = expsetup.general.expname;
subject_id = expsetup.general.subject_id;

% Determine how many experiments to run
if strcmp(expname, 'all')
    exp_dir_index = dir(path1_input);
else
    exp_dir_index.name = expname;
end

% For each experiment
for exp_i = 1:length(exp_dir_index)
    
    if ~strcmp(exp_dir_index(exp_i).name, '.') && ~strcmp(exp_dir_index(exp_i).name, '..')
        
        path1_exp = sprintf('%s%s%s', path1_input, exp_dir_index(exp_i).name, '/');
        
        % For each experiment sub-folder (edf, plexon etc)
        for append_i = 1:numel(path_append)
            
            path1_exp_append = sprintf('%s%s%s', path1_exp, path_append{append_i}, '/');
            
            if isdir(path1_exp_append)
                
                fprintf('\n============\n')
                fprintf('Will synchronise following data sub-folder: \n');
                fprintf('%s\n', path1_exp_append )
                fprintf('============\n\n')
                
                % Determine which subject to use
                if strcmp(subject_id, 'all')
                    subj_dir_index = dir(path1_exp_append);
                else
                    subj_dir_index.name = subject_id;
                end
                
                %=================
                % Run sync for each subject
                for subj_i = 1:length(subj_dir_index)
                    if ~strncmp(subj_dir_index(subj_i).name, '.', 1) && ~strncmp(subj_dir_index(subj_i).name, '..', 2)
                        
                        path1_subj = sprintf('%s%s%s', path1_exp_append, subj_dir_index(subj_i).name, '/');
                        fprintf('\nCurrent subject is %s \n\n', subj_dir_index(subj_i).name);

                        % Run synch for each session
                        session_dir_index = dir(path1_subj);
                        
                        for session_i=1:length(session_dir_index)
                            if ~strncmp(session_dir_index(session_i).name, '.', 1) && ~strncmp(session_dir_index(session_i).name, '..', 2)
                            
                                fprintf('Will synchronise following session %s \n', session_dir_index(session_i).name);

                                % Select each session folder
                                path1_session = sprintf('%s%s%s', path1_subj, session_dir_index(session_i).name, '/');
                                
                                % Create server folder if it doesn't exist
                                temp1 = path1_session(length(path1_input)+1:end);
                                path1_folder = sprintf('%s%s', path1_output, temp1); % Name of the folder on the server;
                                if ~isdir (path1_folder)
                                    mkdir(path1_folder);
                                end
                                
                                
                                index_file = dir(path1_session);
                                
                                for file_i = 1:length(index_file)
                                    if ~strncmp(index_file(file_i).name, '.', 1) && ~strncmp(index_file(file_i).name, '..', 2);
                                        
                                        % Make such a folder on the server
                                        path1_source = sprintf('%s%s', path1_session, index_file(file_i).name);
                                        temp1 = path1_source(length(path1_input)+1:end);
                                        path1_destination = sprintf('%s%s', path1_output, temp1); % Name of the folder on the server
                                        
                                        if exist(path1_destination) == 2
                                            fprintf('Data file %s exists, no sync \n\n', index_file(file_i).name);
                                        else
                                            fprintf('Will synchronise data file %s \n', index_file(file_i).name);
                                            status = 0;
                                            while status==0
                                                [status, message] = copyfile(path1_source, path1_destination);
                                                fprintf('Success \n\n');
                                                if status == 0
                                                    fprintf('Failed to sync file %s \n\n', index_file(file_i).name);
                                                end
                                            end
                                        end
                                    elseif (strncmp(index_file(file_i).name, '.', 1) || strncmp(index_file(file_i).name, '..', 2)) && file_i==length(index_file)
                                        fprintf('No files found in the folder %s \n\n', session_dir_index(session_i).name);
                                    end
                                    % End of checking whether file exists (exclude '..')
                                end
                                % End of syncing each file
                                
                                
                            end
                            % End of checking whether session folder exists (exclude '..')
                        end
                        %  End of sync for each session
                    end
                    % End of checking whether subject folder exists (exclude '..')
                end
                % End of sunc for each subject
                %==================
                
            end
            % End of checking whether append folder exists (exclude '..')
        end
        % End of each append folder (plexon, edf)
    end
    % End of checking exp folder exists (exclude '..')
end
% End of sync for each experiment
