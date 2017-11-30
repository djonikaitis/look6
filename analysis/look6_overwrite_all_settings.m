%% Specify conditions to be modified

% rename esetup_block_cond;
% fix eframes_fixation_offset & edata_fixation_off
overwrite_temp_index{1} = 20170801:20171028;
% added field: probe_extended_map
overwrite_temp_index{2} = 20160101:20171112;


%% Recode block_cond from numbers into words

if  settings.overwrite_temp_switch == 1 && date_current >= overwrite_temp_index{1}(1) && date_current <= overwrite_temp_index{1}(end)
    if strcmp(var1.expname{1}, 'look6')
        v1 = 'esetup_block_cond';
        
        clear temp1_old; clear temp1_new
        temp_old = var1.(v1);
        if ~iscell(temp_old) % Check whether to do analysis
            
            fprintf('Correcting field: %s\n', v1)
            
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
        else
            fprintf('Structure %s already exists, no changes written\n', v1)
        end
        
    end
end

%% fixation_off time bug

if settings.overwrite_temp_switch == 1 && date_current >= overwrite_temp_index{1}(1) && date_current <= overwrite_temp_index{1}(end)
    if strcmp(var1.expname{1}, 'look6')
        
        v1 = 'fixation_off';
        v2 = 'target_on';
        
        if isfield(var1, v1) % check whether to do analysis
            
            fprintf('Correcting eyelink messages %s\n', v1)
            
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
        
        clear temp1_old; clear temp1_new
        temp_old = var1.(v1);
        temp_new = temp_old;        
        
        % Replace condition name
        index = strcmp(temp_old, 'added probe trials');
        
        if sum(index)>0
            
            fprintf('Correcting field: %s\n', v1)
            fprintf('%s instances of "added probe trials" variable will be corrected\n', num2str(sum(index)))
            
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
            fprintf('Training stage "added probe trials" was not found, no changes to field %s\n', v1)
        end
        
    end
end

%% Added field probe_extended_map

if settings.overwrite_temp_switch == 1 && date_current >= overwrite_temp_index{2}(1) && date_current <= overwrite_temp_index{2}(end)
    
    v1 = 'probe_extended_map';
    
    if ~isfield(var1, v1) % check whether to do analysis
        fprintf('Correcting field: %s \n', v1)
        var1.(v1) = 0;
    else
        fprintf('Field %s already exists, no changes written\n', v1)
    end
    
end

%% Added multiple textures

