
%%

a = cell(1);
a{1} = 'esetup_exp_version';
a{2} = 'esetup_block_cond';
a{3} = 'probe_extended_map';

for i = 1:numel(a)
    fprintf(fout, '\n');
    if isfield (S, a{i})
        b = unique(S.(a{i}));
        if iscell(b)
            for j = 1:numel(b)
                targettext='Field "%s", variable detected: "%s"\n';
                fprintf(targettext, a{i}, b{j});
                fprintf(fout, targettext, a{i}, b{j});
            end
        elseif isdouble(b)
            targettext='Field "%s", variable detected: %s\n';
            fprintf(targettext, a{i}, num2str(b(j)) );
            fprintf(fout, targettext, a{i}, num2str(b(j)) );
        else
        end
    else
        % No field exists
        targettext='Field "%s" does not exist!\n';
        fprintf(targettext, a{i});
        fprintf(fout, targettext, a{i});
    end
end


%% 

a = cell(1);
a{1} = 'response_target_coord';
a{2} = 'response_t3_coord';

for i = 1:numel(a)
    fprintf(fout, '\n');
    if isfield (S, a{i})
        b = S.(a{i});
        if iscell(b)
            for j = 1:numel(b)
                targettext='Field "%s", number of variables used: "%s"\n';
                fprintf(targettext, a{i}, num2str(size(b{j}, 1)));
                fprintf(fout, targettext, a{i}, num2str(size(b{j}, 1)) );
            end
        else
            targettext='Field "%s" is not defined as a cell\n';
            fprintf(targettext, a{i});
        end
    else
        % No field exists
        targettext='Field "%s" does not exist!\n';
        fprintf(targettext, a{i});
        fprintf(fout, targettext, a{i});
    end
end
