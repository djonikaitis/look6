%% Specify conditions to be modified

% rename esetup_block_cond to text from numbers
% fix eframes_fixation_offset & edata_fixation_off
overwrite_temp_index{1} = 20170817:20171028;

% edit esetup_exp_version bug (for luminance change trials)
% added field: probe_extended_map
overwrite_temp_index{2} = 20170817:20171112;

% added multiple textures to trial
overwrite_temp_index{3} = 20170817:20171128;

% edit edata_error_code ("looked at distractor" into "looked at st2")
% edit esetup_exp_version bug (for luminance change trials)
% add field esetup_response_soa
overwrite_temp_index{4} = 20170817:20170901;

% edit esetup_exp_version bug (for luminance change trials)
overwrite_temp_index{5} = 20170914:20170915;

% rename esetup_block_cond to text from numbers
overwrite_temp_index{6} = 20170817:20170819;

% rename esetup_exp_version for early training stages
overwrite_temp_index{7} = 20170817:20170831;


%% Recode block_cond from numbers into words

if  settings.overwrite_temp_switch == 1 && date_current >= overwrite_temp_index{1}(1) && date_current <= overwrite_temp_index{1}(end)
    if strcmp(var1.expname{1}, 'look6')
        v1 = 'esetup_block_cond';
        
        clear temp1_old; clear temp1_new
        temp_old = var1.(v1);
        if ~iscell(temp_old) % Check whether to do analysis
            
            fprintf('Correcting field: %s - replace numbers with condition names\n', v1)
            
            temp_new = cell(numel(temp_old),1);
            
            % Replace values
            index = temp_old==1;
            temp_new(index) = {'look'};
            index = temp_old==2;
            temp_new(index)= {'avoid'};
            index = temp_old==3;
            temp_new(index)= {'control fixate'};
            
            % Save corrected data
            var1.(v1) = temp_new;
          
            % The case of AQ on 10.28
        elseif date_current == overwrite_temp_index{1}(end) && ~isstr(temp_old{1}) && ~isstr(temp_old{2}) && isstr(temp_old{3})
            
            fprintf('Correcting field: %s - replace numbers with condition names\n', v1)            
            temp_new = cell(numel(var1.START),1);
            
            for i=1:2
                
                if i==1
                    t1 = 0;
                elseif i==2
                    t1 = numel(temp_old{1});
                end
                
                % Replace values
                index = find(temp_old{i}==1);
                index = index+t1;
                temp_new(index) = {'look'};
                index = find(temp_old{i}==2);
                index = index+t1;
                temp_new(index)= {'avoid'};
                index = find(temp_old{i}==3);
                index = index+t1;
                temp_new(index)= {'control fixate'};
                
            end
            
            %===============
            % Other blocks
            t1 = numel(temp_old{1}) + numel(temp_old{2})+1;
            index = t1 : numel(temp_new);
            temp_new(index) = temp_old(3:end);
            
            % Save corrected data
            var1.(v1) = temp_new;
            
        else
            fprintf('Field %s already corrected, no changes written\n', v1)
        end
        
    end
end


%% fixation_off time bug

if settings.overwrite_temp_switch == 1 && date_current >= overwrite_temp_index{1}(1) && date_current <= overwrite_temp_index{1}(end)
    if strcmp(var1.expname{1}, 'look6')
        
        v1 = 'fixation_off';
        v2 = 'target_on';
        
        if isfield(var1, v1) && isfield(var1, v2) % check whether to do analysis
            
            fprintf('Correcting eyelink messages %s to replace with %s\n', v1, v2)
            
            clear temp1_old; clear temp1_new;
            temp1_old = var1.(v1);
            temp1_new = var1.(v2);
            
            % If ST1 appeared, that means fixation disappeared simultaneously
            % with it. If ST1 didnt appear, then fixation_off time is end of
            % the trial loop.
            ind = ~isnan(temp1_new);
            temp1_old(ind) = temp1_new(ind);
            
            % Save corrected data
            var1.(v1) = temp1_old;
        else
            fprintf('Eyelink messages %s already corrected, no changes written\n', v1)
        end
        
    end
end


%% Edit esetup_exp_version error

if settings.overwrite_temp_switch == 1 && date_current >= overwrite_temp_index{2}(1) && date_current <= overwrite_temp_index{2}(end)
    if strcmp(var1.expname{1}, 'look6')
        
        %===========
        % esetup_exp_version;
        %===========
        
        v1 = 'esetup_exp_version';
        v2 = 'added probe trials';
        
        clear temp1_old; clear temp1_new
        temp_old = var1.(v1);
        temp_new = temp_old;        
        
        % Replace condition name
        index = strcmp(temp_old, v2);
        
        if sum(index)>0
            
            fprintf('Correcting field %s\n', v1)
            fprintf('%s instances of "%s" variable will be corrected\n', num2str(sum(index)), v2)
            
            i1 = find(index==1);
            i2 = i1-1;
            
            % Replace condition name
            temp_new(i1)=temp_old(i2);
            
            % Save corrected data
            var1.(v1) = temp_new;
            
            %===========
            % esetup_distractor_color_level;
            %===========
            
            v1 = 'esetup_st2_color_level';
            
            clear temp1_old; clear temp1_new
            temp_old = var1.(v1);
            temp_new = temp_old;
            
            fprintf('Correcting field: %s\n', v1)
            
            % Replace distractor luminance value
            temp_new(i1)=temp_old(i2);
            
            % Save corrected data
            var1.(v1) = temp_new;
        else
            fprintf('Training stage "%s" was not found, no changes to field %s\n', v2, v1)
        end
        
    end
end

%% Added field probe_extended_map

if settings.overwrite_temp_switch == 1 && date_current >= overwrite_temp_index{2}(1) && date_current <= overwrite_temp_index{2}(end)
    
    v1 = 'probe_extended_map';
    
    if ~isfield(var1, v1) % check whether to do analysis
        fprintf('Adding a field: %s \n', v1)
        temp_new = cell(numel(var1.START), 1);
        temp_new(1:end) = {0};
        var1.(v1) = temp_new;
    else
        fprintf('Field %s already exists, no changes written\n', v1)
    end
    
end

%% Added multiple textures (rename variables)

if  settings.overwrite_temp_switch == 1 && date_current >= overwrite_temp_index{3}(1) && date_current <= overwrite_temp_index{3}(end)
    if strcmp(var1.expname{1}, 'look6')
        
        v1 = 'edata_background_texture_on';
        v2 = 'edata_texture_on';

        clear temp1_old; clear temp1_new
        
        if ~isfield(var1, v1) && isfield(var1, v2) % Check whether to do analysis
            
            fprintf('Replacing field %s with %s\n', v2, v1)
            
            % Save corrected data
            var1.(v1) = var1.(v2);
            var1 = rmfield(var1, v2);
        else
            fprintf('Field %s already exists, no changes written\n', v1)
        end
        
    end
end


%% Added multiple textures (eyelink messages)

if  settings.overwrite_temp_switch == 1 && date_current >= overwrite_temp_index{3}(1) && date_current <= overwrite_temp_index{3}(end)
    if strcmp(var1.expname{1}, 'look6')
        
        v1 = 'texture_on_1';
        v2 = 'texture_on';

        clear temp1_old; clear temp1_new
        
        if ~isfield(var1, v1) && isfield(var1, v2) % Check whether to do analysis
            
            fprintf('Replacing field %s with %s\n', v2, v1)
            
            % Save corrected data
            var1.(v1) = var1.(v2);
            var1 = rmfield(var1, v2);
        else
            fprintf('Field %s already exists, no changes written\n', v1)
        end
        
    end
end

%% edit edata_error_code ("looked at distractor" into "looked at st2")

if settings.overwrite_temp_switch == 1 && date_current >= overwrite_temp_index{4}(1) && date_current <= overwrite_temp_index{4}(end)
    if strcmp(var1.expname{1}, 'look6')
        
        v1 = 'edata_error_code';
        v2 = 'looked at distractor';
        v3 = 'looked at st2';
        
        if isfield(var1, v1) % check whether to do analysis
            
            fprintf('Correcting variable %s to replace "%s" with "%s"\n', v1, v2, v3)
            
            clear temp1_old; clear temp1_new;
            temp1_old = var1.(v1);
            
            % Replace v2 with v3;
            fprintf('%s instances of %s variable will be replaced\n', num2str(sum(ind)), v1)
            ind = strcmp(temp1_old, v2);
            temp1_old(ind) = {v3};
            
            % Save corrected data
            var1.(v1) = temp1_old;
                     
        else
            fprintf('Variable %s does not exist, no changes written\n', v1)
        end
        
    end
end

%% Edit esetup_exp_version error

if settings.overwrite_temp_switch == 1 && date_current >= overwrite_temp_index{4}(1) && date_current <= overwrite_temp_index{4}(end)
    if strcmp(var1.expname{1}, 'look6')
        
        %===========
        % esetup_exp_version;
        %===========
        
        v1 = 'esetup_exp_version';
        v2 = 'delay increase';
        
        clear temp1_old; clear temp1_new
        temp_old = var1.(v1);
        temp_new = temp_old;        
        
        % Replace condition name
        index = strcmp(temp_old, v2);
        
        if sum(index)>0
            
            fprintf('Correcting field: %s\n', v1)
            fprintf('%s instances of "%s" variable will be corrected\n', num2str(sum(index)), v2)
            
            i1 = find(index==1);
            i2 = i1-1;
            
            % Replace condition name
            temp_new(i1)=temp_old(i2);
            
            % Save corrected data
            var1.(v1) = temp_new;
            
            %===========
            % esetup_distractor_color_level;
            %===========
            
            v1 = 'esetup_st2_color_level';
            
            clear temp1_old; clear temp1_new
            temp_old = var1.(v1);
            temp_new = temp_old;
            
            fprintf('Correcting field: %s\n', v1)
            
            % Replace distractor luminance value
            temp_new(i1)=temp_old(i2);
            
            % Save corrected data
            var1.(v1) = temp_new;
        else
            fprintf('Training stage "%s" was not found, no changes to field %s\n', v2, v1)
        end
        
    end
end

%% Added field esetup_response_soa

if settings.overwrite_temp_switch == 1 && date_current >= overwrite_temp_index{4}(1) && date_current <= overwrite_temp_index{4}(end)
    
    v1 = 'esetup_response_soa';
    v2 = 'esetup_distractor_soa';

    if ~isfield(var1, v1) && ~isfield(var1, v2) % check whether to do analysis
        fprintf('Adding a field: "%s" \n', v1)
        temp_new = zeros(numel(var1.START), 1);
        var1.(v1) = temp_new;
    elseif ~isfield(var1, v1) && isfield(var1, v2) % check whether to do analysis
        fprintf('Adding a field: "%s" and removing the field "%s"\n', v1, v2)
        temp_new = zeros(numel(var1.START), 1);
        var1.(v1) = temp_new;
        var1 = rmfield (var1, v2);
    else
        fprintf('Field "%s" already exists, no changes written\n', v1)
    end
    
end

%% Added field esetup_st2_color_level

if settings.overwrite_temp_switch == 1 && date_current >= overwrite_temp_index{4}(1) && date_current <= overwrite_temp_index{4}(end)
    
    v1 = 'esetup_st2_color_level';

    if ~isfield(var1, v1) && ~isfield(var1, v2) % check whether to do analysis
        fprintf('Adding a field: "%s" \n', v1)
        temp_new = zeros(numel(var1.START), 1);
        var1.(v1) = temp_new;
    else
        fprintf('Field "%s" already exists, no changes written\n', v1)
    end
    
end


%% Edit esetup_exp_version error

if settings.overwrite_temp_switch == 1 && date_current >= overwrite_temp_index{5}(1) && date_current <= overwrite_temp_index{5}(end)
    if strcmp(var1.expname{1}, 'look6')
        
        %===========
        % esetup_exp_version;
        %===========
        
        v1 = 'esetup_exp_version';
        v2 = 'distractor train luminance';
        
        clear temp1_old; clear temp1_new
        temp_old = var1.(v1);
        temp_new = temp_old;        
        
        % Replace condition name
        index = strcmp(temp_old, v2);
        
        if sum(index)>0
            
            fprintf('Correcting field: %s\n', v1)
            fprintf('%s instances of "%s" variable will be corrected\n', num2str(sum(index)), v2)
            
            i1 = find(index==1);
            i2 = i1-1;
            
            % Replace condition name
            temp_new(i1)=temp_old(i2);
            
            % Save corrected data
            var1.(v1) = temp_new;
            
            %===========
            % esetup_distractor_color_level;
            %===========
            
            v1 = 'esetup_st2_color_level';
            
            clear temp1_old; clear temp1_new
            temp_old = var1.(v1);
            temp_new = temp_old;
            
            fprintf('Correcting field: %s\n', v1)
            
            % Replace distractor luminance value
            temp_new(i1)=temp_old(i2);
            
            % Save corrected data
            var1.(v1) = temp_new;
        else
            fprintf('Training stage "%s" was not found, no changes to field %s\n', v2, v1)
        end
        
    end
end

%% Edit esetup_exp_version error

if settings.overwrite_temp_switch == 1 && date_current >= overwrite_temp_index{5}(1) && date_current <= overwrite_temp_index{5}(end)
    if strcmp(var1.expname{1}, 'look6')
        
        %===========
        % esetup_exp_version;
        %===========
        
        v1 = 'esetup_exp_version';
        v2 = 'distractor train luminance stable';
        
        clear temp1_old; clear temp1_new
        temp_old = var1.(v1);
        temp_new = temp_old;        
        
        % Replace condition name
        index = strcmp(temp_old, v2);
        
        if sum(index)>0
            
            fprintf('Correcting field: %s\n', v1)
            fprintf('%s instances of "%s" variable will be corrected\n', num2str(sum(index)), v2)
            
            i1 = find(index==1);
            i2 = i1-1;
            
            % Replace condition name
            temp_new(i1)=temp_old(i2);
            
            % Save corrected data
            var1.(v1) = temp_new;
            
            %===========
            % esetup_distractor_color_level;
            %===========
            
            v1 = 'esetup_st2_color_level';
            
            clear temp1_old; clear temp1_new
            temp_old = var1.(v1);
            temp_new = temp_old;
            
            fprintf('Correcting field: %s\n', v1)
            
            % Replace distractor luminance value
            temp_new(i1)=temp_old(i2);
            
            % Save corrected data
            var1.(v1) = temp_new;
        else
            fprintf('Training stage "%s" was not found, no changes to field %s\n', v2, v1)
        end
        
    end
end

%% Edit esetup_exp_version error

if settings.overwrite_temp_switch == 1 && date_current >= overwrite_temp_index{5}(1) && date_current <= overwrite_temp_index{5}(end)
    if strcmp(var1.expname{1}, 'look6')
        
        %===========
        % esetup_exp_version;
        %===========
        
        v1 = 'esetup_exp_version';
        v2 = 'distractor train position';
        
        clear temp1_old; clear temp1_new
        temp_old = var1.(v1);
        temp_new = temp_old;        
        
        % Replace condition name
        index = strcmp(temp_old, v2);
        
        if sum(index)>0
            
            fprintf('Correcting field: %s\n', v1)
            fprintf('%s instances of "%s" variable will be corrected\n', num2str(sum(index)), v2)
            
            i1 = find(index==1);
            i2 = i1-1;
            
            % Replace condition name
            temp_new(i1)={'task switch luminance equal'};
            
            % Save corrected data
            var1.(v1) = temp_new;
            
            %===========
            % esetup_distractor_color_level;
            %===========
            
            v1 = 'esetup_st2_color_level';
            
            clear temp1_old; clear temp1_new
            temp_old = var1.(v1);
            temp_new = temp_old;
            
            fprintf('Correcting field: %s\n', v1)
            
            % Replace distractor luminance value
            temp_new(i1)=temp_old(i2);
            
            % Save corrected data
            var1.(v1) = temp_new;
        else
            fprintf('Training stage "%s" was not found, no changes to field %s\n', v2, v1)
        end
        
    end
end


%% Recode block_cond from numbers into words

if  settings.overwrite_temp_switch == 1 && date_current >= overwrite_temp_index{6}(1) && date_current <= overwrite_temp_index{6}(end)
    if strcmp(var1.expname{1}, 'look6')
        v1 = 'esetup_exp_version';
        
        clear temp1_old; clear temp1_new
        temp_old = var1.(v1);
        if ~iscell(temp_old) % Check whether to do analysis
            
            fprintf('Correcting field: %s - replace numbers with condition names\n', v1)
            
            temp_new = cell(numel(temp_old),1);
            
            % Replace values
            index = temp_old==1;
            temp_new(index) = {'task switch luminance equal'};
            
            % Save corrected data
            var1.(v1) = temp_new;
        else
            fprintf('Structure %s already corrected, no changes written\n', v1)
        end
        
    end
end

%% Edit esetup_exp_version error

if settings.overwrite_temp_switch == 1 && date_current >= overwrite_temp_index{7}(1) && date_current <= overwrite_temp_index{7}(end)
    if strcmp(var1.expname{1}, 'look6')
        
        %===========
        % esetup_exp_version;
        %===========
        
        v1 = 'esetup_exp_version';
        
        clear temp1_old; clear temp1_new
        temp_old = var1.(v1);
        temp_new = temp_old;  
        
        %==========
        % Part 1
        v2 = 'luminance change';
        v3 = 'task switch luminance change';
        
        % Replace condition name
        index = strcmp(temp_old, v2);
        
        if sum(index)>0
            
            fprintf('Correcting field: %s from "%s" to "%s" \n', v1, v2, v3)
            
            % Replace condition name
            temp_new(index)={v3};
        end
        
        %=============
        % Part 2
        v2 = 'luminance equal';
        v3 = 'task switch luminance equal';
        
        % Replace condition name
        index = strcmp(temp_old, v2);
        
        if sum(index)>0
            
            fprintf('Correcting field: %s from "%s" to "%s" \n', v1, v2, v3)
            
            % Replace condition name
            temp_new(index)={v3};
        end
            
        % Save corrected data
        var1.(v1) = temp_new;
        
    end
end
