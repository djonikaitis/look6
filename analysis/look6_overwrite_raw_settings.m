
%% 2017 October 28: Rename block_cond variables from numbers into words

if date_current <= 20171028
    
    v1 = 'esetup_block_cond';
    
    clear temp1_old; clear temp1_new
    temp1_old = var1.stim.(v1);
    
    if ~iscell(temp1_old) % Check whether to do analysis
        
        fprintf('Correcting field esetup_block_cond\n')
        
        temp_new = cell(numel(temp1_old),1);
        
        index = temp1_old==1;
        temp_new(index) = {'look'};
        index = temp1_old==2;
        temp_new(index)= {'avoid'};
        index = temp1_old==3;
        temp_new(index)= {'control'};
        
        % Save corrected data
        var1.stim.(v1) = temp_new;
    else
        fprintf('Structure esetup_block_cond already exists, no changes written\n')
    end
    
end


%% 2017 October 28: Fixation offset time bug

if date_current <= 20171028
    
    v1 = 'eframes_fixation_offset';
    v2 = 'eframes_fixation_off';
        
    if isfield(var1.stim, v1) % check whether to do analysis
        
        fprintf('Correcting field eframes_fixation_off & edata_fixation_off\n')

        %==================
        % Change field eframes_fixation_off
        %==================
        
        clear temp1_old; clear temp1_new
        temp1_old = var1.stim.(v1);
        temp1_new = var1.stim.(v2);
        
        for i=1:numel(temp1_old)
            ind = find(temp1_old{i}==1);
            if numel(ind)>=1
                temp1_new{i}(ind(1))=1;
            end
        end
        
        % Save corrected data
        var1.stim.(v2) = temp1_new;
        
        % Remove old field
        var1.stim = rmfield(var1.stim, v1);
        
        %=================
        % Change field edata_fixation_off timing
        %=================
        
        v1 = 'edata_fixation_off';
        v2 = 'edata_st1_on';
        
        clear temp1_old; clear temp1_new;
        temp1_old = var1.stim.(v1);
        temp1_new = var1.stim.(v2);
        
        % If ST1 appeared, that means fixation disappeared simultaneously
        % with it. If ST1 didnt appear, then fixation_off time is end of
        % the trial loop.
        ind = ~isnan(temp1_new);
        temp1_old(ind) = temp1_new(ind);
        
        % Save corrected data
        var1.stim.(v1) = temp1_old;
    else
        fprintf('Field eframes_fixation_off already corrected, no changes written\n')
    end
    
end