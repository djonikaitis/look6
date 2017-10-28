% At the moment these ara manually selected units for analysis. This is not
% going to be the case going forward.

if  date_index(i_date)==20160919
    units_used = cell(1);
    units_used{1} = 'aq2_ch17_u2_u.mat';
    units_used{2} = 'aq2_ch19_u2_u.mat';
    %     units_used{3} = 'aq2_ch20_u2_u.mat'; % Clear rf, no cue on resp
    %     units_used{4} = 'aq2_ch21_u2_u.mat'; % Barely visible RF, no cue on
    units_used{3} = 'aq2_ch21_u3_u.mat';
    units_used{4} = 'aq2_ch22_u2_u.mat';
    units_used{5} = 'aq2_ch23_u2_u.mat';
    units_used{6} = 'aq2_ch24_u2_u.mat';
    units_used{7} = 'aq2_ch25_u2_u.mat';
    units_used{8} = 'aq2_ch25_u3_u.mat';
    units_used{9} = 'aq2_ch26_u2_u.mat';
elseif date_index(i_date)==20160923
    units_used = cell(1);
    units_used{1} = 'aq3_ch18_u2_u.mat'; % Very fuzzy rf, but clear cue response
    units_used{2} = 'aq3_ch20_u2_u.mat';
    units_used{3} = 'aq3_ch21_u2_u.mat';
    units_used{4} = 'aq3_ch22_u2_u.mat';
    %     units_used{4} = 'aq3_ch23_u2_u.mat'; % Very noisy rf, no visible cue rf
    units_used{5} = 'aq3_ch24_u2_u.mat'; % Wide and fuzzy rf, clear cue on
    units_used{6} = 'aq3_ch25_u2_u.mat'; % Unclear rf (tiny small peak), but clear cue onset
    units_used{7} = 'aq3_ch26_u2_u.mat';
    units_used{8} = 'aq3_ch27_u2_u.mat';
    units_used{9} = 'aq3_ch28_u2_u.mat'; % Unclear rf (tiny small peak), but clear cue onset
    units_used{10} = 'aq3_ch29_u2_u.mat'; % Response to 3 cue locations, likely multi-unit?
    %     units_used{8} = 'aq3_ch30_u2_u.mat'; % No cue response, rf lower center.
elseif date_index(i_date)==20161012
    units_used = cell(1);
    %     units_used{1} = 'aq4_ch18_u2_u.mat'; % Rf not clearly defined, no cue on response
    units_used{1} = 'aq4_ch19_u2_u.mat';
    units_used{2} = 'aq4_ch19_u3_u.mat';
    units_used{3} = 'aq4_ch20_u2_u.mat';
    units_used{4} = 'aq4_ch21_u2_u.mat';
    units_used{5} = 'aq4_ch22_u2_u.mat';
    units_used{6} = 'aq4_ch23_u2_u.mat'; % No clear rf, but somewhat clear cue response
    units_used{7} = 'aq4_ch24_u2_u.mat';
    %     units_used{8} = 'aq4_ch25_u2_u.mat'; % No cue onset, very few spikes
elseif date_index(i_date)==20161021
    units_used = cell(1);
    units_used{1} = 'aq6_ch17_u2_u.mat';
    %     units_used{2} = 'aq6_ch17_u3_u.mat'; % No cue response (out of rf)
    units_used{2} = 'aq6_ch18_u2_u.mat'; % Some cue response, out of rf
    units_used{3} = 'aq6_ch18_u3_u.mat'; % mInor cue repsone, few spikes
    units_used{4} = 'aq6_ch19_u2_u.mat';
    units_used{5} = 'aq6_ch20_u2_u.mat';
    units_used{6} = 'aq6_ch20_u3_u.mat';
    units_used{7} = 'aq6_ch21_u2_u.mat';
    units_used{8} = 'aq6_ch23_u2_u.mat';
    units_used{9} = 'aq6_ch26_u2_u.mat'; % Minor cue response
    %     units_used{10} = 'aq6_ch27_u2_u.mat'; % No cue response
    units_used{10} = 'aq6_ch29_u3_u.mat'; % no clear rf, but there is cue response
elseif date_index(i_date)==20161028
    units_used = cell(1);
    units_used{1} = 'aq7_ch17_u2_u.mat'; % cue stim likely out of RF, kept it in
    units_used{2} = 'aq7_ch18_u2_u.mat';
    units_used{3} = 'aq7_ch19_u2_u.mat';
    units_used{4} = 'aq7_ch20_u2_u.mat';
elseif date_index(i_date)==20161030
    units_used = cell(1);
    units_used{1} = 'aq1_ch17_u2_u.mat';
    units_used{2} = 'aq1_ch21_u2_u.mat'; % No clear RF, but some visual response is there
    units_used{3} = 'aq1_ch22_u2_u.mat';
    %     units_used{3} = 'aq8_ch24_u2_u.mat'; % No cue on response
    units_used{4} = 'aq1_ch25_u2_u.mat';
    units_used{5} = 'aq1_ch28_u3_u.mat';
    %     units_used{6} = 'aq8_ch29_u2_u.mat'; % No cue on, likely out of RF
elseif date_index(i_date)==20160803
    units_used = cell(1);
    units_used{1} = 'aq1_ch9_u2_u.mat'; % Clear cue on response
    units_used{2} = 'aq1_ch10_u2_u.mat';
    units_used{3} = 'aq1_ch11_u2_u.mat'; % Visual on, but rest of respnse suppressed
    units_used{4} = 'aq1_ch12_u2_u.mat';
    units_used{5} = 'aq1_ch13_u2_u.mat';
    units_used{6} = 'aq1_ch14_u2_u.mat';
    units_used{7} = 'aq1_ch15_u2_u.mat';
    units_used{8} = 'aq1_ch16_u2_u.mat';
else
    units_used = cell(1);
end

%
%
%     units_used = cell(1);
%     units_used{1} = '';
%     units_used{2} = '';
%     units_used{3} = '';
%     units_used{4} = '';
%     units_used{5} = '';
%     units_used{6} = '';
%     units_used{7} = '';
%     units_used{8} = '';
%     units_used{9} = '';
%     units_used{10} = '';