% Function converts .edf file to .dat and .asc files
%
% path_edf - edf file is within this path
% path_asc - asc file will be outputed to this path
% path_dat - dat file will be outputed to this path
% varargin is settings structure, needed for pc setup only
%
% For mac system, add edf2asc in "/bin" folder;
% use the file from
% "/Applications/EyeLink/EDF_Access_API/Example/".
% For example in terminal type in;
% sudo cp /Users/dj/Desktop/edf2asc /usr/local/bin
% Otherwise this analysis wont work
%
% V1.0 September 6, 2016. Initial version
% V1.1 February 5, 2017. Corrected bug in which file conversion fails and
% crashes the code.
% V1.2 November 30, 2017. Added pc setup.
% V1.3 February 1, 2017. Simplified path definitions. Not compatible with
% earlier versions

function preprocessing_eye_edf2asc_v13(path_edf, path_asc, path_dat, varargin)

if ~isempty(varargin)
    settings = varargin{1};
else 
    settings = struct;
end

% Create .dat file
try
    if ismac
        if isfield(settings, 'edf2asc_path')
            edf2asc = settings.edf2asc_path;
        else
            edf2asc = 'edf2asc';
        end
        system([sprintf('%s', edf2asc), ' ', sprintf('%s', path_edf),' -s -miss -1.0 -y']);
    elseif ispc
        if isfield(settings, 'edf2asc_path')
            edf2asc = settings.edf2asc_path;
        else
            error('edf2asc.exe path is not defined')
        end
        [a, ~] = system(['edf2asc', ' ', sprintf('%s', path_edf),' -s -miss -1.0 -y']);
        if a~=0
            error('edf2asc conversion could not be completed')
        end
    end
catch
    if ismac
        error('edf2asc conversion failed. Possibly you dont have edf2asc in /bin folder setup')
    else
        error('edf2asc conversion failed. Possibly you dont have edf2asc utility setup properly')
    end
end

% Convert and move .asc file into .dat file
path_temp = sprintf('%s.asc',path_edf(1:end-4));
if exist (path_temp,'file')
    movefile(sprintf('%s',path_temp), sprintf('%s',path_dat))
else
    % Skip it without crashing code
end


% Create .asc file
try
    if ismac
        system(['edf2asc', ' ', sprintf('%s',path_edf),' -e -y']);
    elseif ispc
        if isfield(settings, 'edf2asc_path')
            edf2asc = settings.edf2asc_path;
        else
            error('edf2asc.exe path is not defined')
        end
        [a, ~] = system(['edf2asc', ' ', sprintf('%s', path_edf),' -e -y']);
        if a~=0
            error('edf2asc conversion could not be completed')
        end
    end
catch
    if ismac
        error('edf2asc conversion failed. Possibly you dont have edf2asc in /bin folder setup')
    else
        error('edf2asc conversion failed. Possibly you dont have edf2asc utility setup properly')
    end
end

% Convert and move .asc file into .dat file
path_temp = sprintf('%s.asc',path_edf(1:end-4));
if exist (path_temp,'file')
    movefile(sprintf('%s',path_temp), sprintf('%s',path_asc))
else
    % Skip it without crashing code
end



