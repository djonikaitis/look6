
function data_mat = look6_helper_indexed_selection_behaviour(data_mat, settings)


%% Indexes

% Initialize empty matrix
ind_output = cell(numel(data_mat.var1_match), 1);

% Prepare indexes
for i= 1:numel(data_mat.var1_match)
    
    a = data_mat.var1{i};
    b = data_mat.var1_match{i};
    
    % If its numeric variable
    if isnumeric(b)
        temp1 = NaN([size(a,1), numel(b)]);
        for j = 1:numel(b)
            temp1(:,j) = a == b(j);
        end
        ind_output{i} = temp1;
    end
    
    % If its text variable
    if isstr(b)
        temp1 = strncmp(a,b, numel(b));
        ind_output{i} = temp1;
    end
    
    % If its cell, assume it's text
    if iscell(b)
        temp1 = NaN([size(a,1), numel(b)]);
        for j = 1:numel(b)
            if ischar(b{j})
                temp1(:,j) = strncmp(a, b{j}, numel(b{j}));
            else
                error('Cell arrays are defined for text inputs only')
            end
        end
        ind_output{i} = temp1;
    end
    
end


%% How many reps for each variable

% Determine number of dimensions used
num_var = NaN(numel(data_mat.var1_match), 1);
for i = 1:numel(data_mat.var1_match)
    a = data_mat.var1_match{i};
    if isstr(a) % String variables coded as size 1
        num_var(i) = 1;
    else
        num_var(i) = numel(a);
    end
end


%% Prepare multi-dimensional matrix

% Initialize matrix
if isfield(data_mat, 'mat1_ini_bin_start') && isfield(data_mat, 'mat1_ini_bin_end') && ...
        ~isempty(data_mat.mat1_ini_bin_start) && ~isempty(data_mat.mat1_ini_bin_end)
    m = numel(data_mat.mat1_ini_bin_start);
    mat_y = NaN([1, m, num_var']);
    test1 = NaN([1, num_var']);
    mat_y_lower = NaN([1, m, num_var']);
    mat_y_upper = NaN([1, m, num_var']);
else
    mat_y = NaN([1, num_var']);
    test1 = NaN([1, num_var']);
    mat_y_lower = NaN([1, num_var']);
    mat_y_upper = NaN([1, num_var']);
end


% Expand ind_output matrix
a = numel(ind_output);
if a<10
    for i = a+1:10
        a1 = size(data_mat.var1{1}, 1);
        ind_output{i} = ones(a1, 1);
    end
elseif a>10
    error('Code not written for more than 10 variables')
end

% Calculate indexes
i1 = size(ind_output{1}, 2);
for i = 1:i1
    
    j1 = size(ind_output{2}, 2);
    for j = 1:j1
        
        k1 = size(ind_output{3}, 2);
        for k = 1:k1
            
            m1 = size(ind_output{4}, 2);
            for m = 1:m1
                
                n1 = size(ind_output{5}, 2);
                for n=1:n1
                    
                    o1 = size(ind_output{6}, 2);
                    for o=1:o1
                        
                        p1 = size(ind_output{7}, 2);
                        for p=1:p1
                            
                            q1 = size(ind_output{8}, 2);
                            for q=1:q1
                                
                                r1 = size(ind_output{9}, 2);
                                for r=1:r1
                                    
                                    s1 = size(ind_output{10}, 2);
                                    for s=1:s1
                                        
                                        % Index
                                        index = ind_output{1}(:,i) == 1 & ...
                                            ind_output{2}(:,j) == 1 & ...
                                            ind_output{3}(:,k) == 1 & ...
                                            ind_output{4}(:,m) == 1 & ...
                                            ind_output{5}(:,n) == 1 & ...
                                            ind_output{6}(:,o) == 1 & ...
                                            ind_output{7}(:,p) == 1 & ...
                                            ind_output{8}(:,q) == 1 & ...
                                            ind_output{9}(:,r) == 1 & ...
                                            ind_output{10}(:,s) == 1;
                                        
                                        %============
                                        % Bin data
                                        %============
                                        if isfield(data_mat, 'mat1_ini_bin_start') && isfield(data_mat, 'mat1_ini_bin_end') && ...
                                                ~isempty(data_mat.mat1_ini_bin_start) && ~isempty(data_mat.mat1_ini_bin_end)
                                            for z = 1:numel(data_mat.mat1_ini_bin_start)
                                                
                                                index_bin = data_mat.mat1_ini>=data_mat.mat1_ini_bin_start(z) & ...
                                                    data_mat.mat1_ini<data_mat.mat1_ini_bin_end(z);
                                                ind1 = index==1 & index_bin==1;
                                                
                                                temp1 = data_mat.mat1_ini(ind1,:);
                                                test1(1,z,i,j,k,m,n,o,p,q,r,s) = sum(ind1);
                                                
                                                % Get means
                                                a = [];
                                                if sum(ind1)>=settings.trial_number_threshold
                                                    if isfield(data_mat, 'method')
                                                        if strcmp(data_mat.method, 'mean')
                                                            a = nanmean(temp1);
                                                        elseif strcmp(data_mat.method, 'median')
                                                            a = nanmedian(temp1);
                                                        end
                                                    else
                                                        a = nanmedian(temp1);
                                                    end
                                                    mat_y(1,z,i,j,k,m,n,o,p,q,r,s) = a;
                                                end
                                                
                                                % Get error bars
                                                if sum(ind1)>=settings.trial_number_threshold
                                                    a = plot_helper_error_bar_calculation_v10(temp1, settings);
                                                    mat_y_upper(1,z,i,j,k,m,n,o,p,q,r,s)= a.se_upper;
                                                    mat_y_lower(1,z,i,j,k,m,n,o,p,q,r,s)= a.se_lower;
                                                end
                                                
                                            end
                                            
                                            %=============
                                            % No bin data
                                            %=============
                                            
                                        else
                                            
                                            % If mat1_ini exists
                                            if isfield(data_mat, 'mat1_ini') && size(data_mat.mat1_ini, 2)==1
                                                
                                                ind1 = index;
                                                temp1 = data_mat.mat1_ini(ind1,:);
                                                test1(1,i,j,k,m,n,o,p,q,r,s) = sum(ind1);
                                                
                                                % Get means
                                                a = [];
                                                if sum(ind1)>=settings.trial_number_threshold
                                                    if isfield(data_mat, 'method')
                                                        if strcmp(data_mat.method, 'mean')
                                                            a = nanmean(temp1);
                                                        elseif strcmp(data_mat.method, 'median')
                                                            a = nanmedian(temp1);
                                                        end
                                                    else
                                                        a = nanmedian(temp1);
                                                    end
                                                    mat_y(1,i,j,k,m,n,o,p,q,r,s) = a;
                                                end
                                                
                                                % Get error bars
                                                if sum(ind1)>=settings.trial_number_threshold
                                                    a = plot_helper_error_bar_calculation_v10(temp1, settings);
                                                    mat_y_upper(1,i,j,k,m,n,o,p,q,r,s)= a.se_upper;
                                                    mat_y_lower(1,i,j,k,m,n,o,p,q,r,s)= a.se_lower;
                                                end
                                                
                                                
                                                %=============
                                                % Only trial counts
                                                %=============
                                                
                                            else % If mat1_ini does not exist
                                                test1(1,i,j,k,m,n,o,p,q,r,s) = sum(index);
                                            end
                                            
                                        end
                                        %=============
                                        % End of bin or no bin data
                                        
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

data_mat.mat_y = mat_y;
data_mat.trial_counts = test1;
data_mat.mat_y_upper = mat_y_upper;
data_mat.mat_y_lower = mat_y_lower;

