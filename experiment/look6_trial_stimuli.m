% Prepare all the rectangles for the trial

%% Fixation converted to pixels


% Fixation stimulus
pos1 = expsetup.stim.esetup_fixation_arc(tid,1);
rad1 = expsetup.stim.esetup_fixation_radius(tid,1);
[xc, yc] = pol2cart(pos1*pi/180, rad1); % Convert to cartesian
coord1=[];
coord1(1,:)=xc; coord1(2,:)=yc; % One column, one object

% Fixation size: One row - one set of coordinates (psychtoolbox requirement)

% Fixation stimulus
sz1 = expsetup.stim.esetup_fixation_size(tid,1:4);
fixation_rect = runexp_convert_deg2pix_rect_v10(coord1, sz1); % Output - one column - one object;

% Fixation for eyelink drift
sz1 = expsetup.stim.esetup_fixation_size_drift(tid,1:4).*2;
fixation_rect_eyelink_drift = runexp_convert_deg2pix_rect_v10(coord1, sz1); % One column - one object;

% Fixation for eyelink tracking
sz1 = expsetup.stim.esetup_fixation_size_eyetrack(tid,1:4).*2;
fixation_rect_eyelink = runexp_convert_deg2pix_rect_v10(coord1, sz1); % One column - one object;


%% Memory location

coord1 = expsetup.stim.esetup_memory_coord(tid,:); % One column, one object
sz1 = expsetup.stim.esetup_memory_size(tid,1:4);
memory_rect = runexp_convert_deg2pix_rect_v10(coord1, sz1); % Output - one column - one object;


%% T1 location

coord1 = expsetup.stim.esetup_st1_coord(tid,:); % One column, one object
sz1 = expsetup.stim.esetup_target_size(tid,1:4);
st1_rect = runexp_convert_deg2pix_rect_v10(coord1, sz1); % Output - one column - one object;

% Size for eyelink tracking
sz1 = expsetup.stim.esetup_target_size_eyetrack(tid,1:4).*2;
st1_rect_eyelink = runexp_convert_deg2pix_rect_v10(coord1, sz1); % One column - one object;


%% T2 location

coord1 = expsetup.stim.esetup_st2_coord(tid,:); % One column, one object
sz1 = expsetup.stim.esetup_target_size(tid,1:4);
st2_rect = runexp_convert_deg2pix_rect_v10(coord1, sz1); % Output - one column - one object;

% Size for eyelink tracking
sz1 = expsetup.stim.esetup_target_size_eyetrack(tid,1:4).*2;
st2_rect_eyelink = runexp_convert_deg2pix_rect_v10(coord1, sz1); % One column - one object;


%% Reward feedback picture

if expsetup.stim.reward_feedback==1
    
    pos1 = expsetup.stim.esetup_fixation_arc(tid,1);
    rad1 = expsetup.stim.esetup_fixation_radius(tid,1);
    [xc, yc] = pol2cart(pos1*pi/180, rad1); % Convert to cartesian
    coord1=[];
    coord1(1,:)=xc; coord1(2,:)=yc; % One column, one object
    sz1 = expsetup.stim.reward_pic_size;
    reward_rect = runexp_convert_deg2pix_rect_v10(coord1, sz1); % One column - one object;

    % Load images
    a1 = load ('reward_pos'); % Load image specified in isntrpic
    a1 = struct2cell(a1); % Convert to cell for easines of use (no need to access structure fields)
    tex_positive = Screen('MakeTexture', window, a1{1});
    
    a1 = load ('reward_neg'); % Load image specified in isntrpic
    a1 = struct2cell(a1); % Convert to cell for easines of use (no need to access structure fields)
    tex_negative = Screen('MakeTexture', window, a1{1});
    
end

%% Prepare texture for plotting

num1 = expsetup.stim.background_texture_line_number;
length1 = round(expsetup.stim.background_texture_line_length*expsetup.screen.deg2pix);
angle1 = expsetup.stim.esetup_background_texture_line_angle(tid);

% Start of lines
x_texture_start = round(rand(num1,1).*(expsetup.screen.screen_rect(3) + (length1.*2)) - ((expsetup.screen.screen_rect(3)+(length1.*2))./2))+(expsetup.screen.screen_rect(3)/2);
y_texture_start = round(rand(num1,1).*(expsetup.screen.screen_rect(4) + (length1.*2)) - ((expsetup.screen.screen_rect(4)+(length1.*2))./2))+(expsetup.screen.screen_rect(4)/2);
% End of lines
x_texture_end = round(x_texture_start+(cosd(angle1).*length1));
y_texture_end = round(y_texture_start+(sind(angle1).*length1));

% Combine into one matrix for multiple lines
xy_texture_combined(1,1:2:num1*2)=x_texture_start;
xy_texture_combined(1,2:2:num1*2)=x_texture_end;
xy_texture_combined(2,1:2:num1*2)=y_texture_start;
xy_texture_combined(2,2:2:num1*2)=y_texture_end;

    
%% Flash for photodiode

sz1 = 110;
d1_rect = [expsetup.screen.screen_rect(3)-sz1, 1, expsetup.screen.screen_rect(3), sz1]';
% Rename
ph_rect=d1_rect;

