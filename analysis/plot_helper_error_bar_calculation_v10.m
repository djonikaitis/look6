% Calculate error bars

function e_bars = plot_helper_error_bar_calculation_v10(mat1, settings)


a1=[]; b1=[]; c1=[]; d1=[]; f1=[];
% Bootstrap the sample

if size(mat1,1)>1
    for k=1:size(mat1,3)
        if k==1
            a1 = [mat1(:,:,k)];
        else
            a1 = [a1, mat1(:,:,k)];
        end
    end
    b1 = bootstrapnan(a1,settings.tboot1);
    c1 = prctile(b1,[2.5,97.5]);
    for k=1:size(mat1,3)
        i1=1+(size(mat1,2)*k)-size(mat1,2);
        i2=(size(mat1,2)*k);
        d1(:,:,k) = c1(1,i1:i2,:); % Lower bound (2.5 percentile)
        f1(:,:,k) = c1(2,i1:i2,:); % Upper bound (97.5 percentile)
        b2(:,:,k) = b1(:,i1:i2,:); % Restructure original matrix for bootstrap stats
    end
    b1_bootstrap = b2;
    d1_bootstrap = d1;
    f1_bootstrap = f1;
end

% SEM
d1=[]; f1=[];
if size(mat1,1)>1
    for k=1:size(mat1,3)
        for i=1:size(mat1,2)
            d1(:,i,k) = nanmean(mat1(:,i,k))-se(mat1(:,i,k)); % Standard error, lower bound (identical to upper one)
            f1(:,i,k) = nanmean(mat1(:,i,k))+se(mat1(:,i,k)); % Standard error, upper bound (identical to lower one)
        end
    end
end

if size(mat1,1)>1
    e_bars.bootstrap_upper = f1_bootstrap;
    e_bars.bootstrap_lower = d1_bootstrap;
    e_bars.bootstrap = b2_bootstrap;
    e_bars.se_upper = f1;
    e_bars.se_lower = d1;
else 
    e_bars = struct;
end
