%% Specify conditions to be modified

% fix eframes_fixation_offset & edata_fixation_off
overwrite_temp_index{1} = 20170801:20171028;


%% Fixation offset time bug

if settings.overwrite_temp_switch == 1 && date_current >= overwrite_temp_index{1}(1) && date_current <= overwrite_temp_index{1}(end)
    if strcmp(var1.general.expname, 'look6')
        
        v1 = 'eframes_fixation_offset';
        v2 = 'eframes_fixation_off';
        
        if isfield(var1.stim, v1) % check whether to do analysis
            
            %===========
            % edata_fixation_off';
            %===========
            
            fprintf('Correcting field: %s\n', v2)
            
            clear temp1_old; clear temp1_new
            temp_old = var1.stim.(v1);
            temp_new = var1.stim.(v2);
            
            for i=1:numel(temp_old)
                ind = find(temp_old{i}==1);
                if numel(ind)>=1
                    temp_new{i}(ind(1))=1;
                end
            end
            
            % Save corrected data
            var1.stim.(v2) = temp_new;
            
            % Remove old field
            var1.stim = rmfield(var1.stim, v1);
            
            %===========
            % edata_fixation_off';
            %===========
            
            v1 = 'edata_fixation_off';
            v2 = 'edata_st1_on';
            fprintf('Correcting field: %s\n', v1)
            
            clear temp1_old; clear temp1_new;
            temp_old = var1.stim.(v1);
            temp_new = var1.stim.(v2);
            
            % If ST1 appeared, that means fixation disappeared simultaneously
            % with it. If ST1 didnt appear, then fixation_off time is end of
            % the trial loop.
            ind = ~isnan(temp_new);
            temp_old(ind) = temp_new(ind);
            
            % Save corrected data
            var1.stim.(v1) = temp_old;
            
        else
            fprintf('Field %s already corrected, no changes written\n', v2)
        end
    end
end

