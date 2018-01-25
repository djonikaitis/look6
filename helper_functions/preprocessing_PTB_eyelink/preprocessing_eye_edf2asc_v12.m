% Function converts .edf file to .dat and .asc files
%
% pathin - edf file is within this folder
% pathout - asc file will be outputed to this folder
% f_name - file name within the folder (for example: aq_2000_12_31)
%
% Add edf2asc in "/bin" folder;
% use the file from
% "/Applications/EyeLink/EDF_Access_API/Example/"
% Otherwise this analysis wont work
%
% V1.0 September 6, 2016. Initial version
% V1.1 February 5, 2017. Corrected bug in which file conversion fails and
% crashes the code.
% V1.2 November 30, 2017. Added pc setup.

function preprocessing_eye_edf2asc_v12(path_in, path_out, file_name, settings)

% Create .dat file
try
    path_edf = sprintf('%s%s.edf', path_in, file_name);
    if ismac
        system(['edf2asc', ' ', sprintf('%s', path_edf),' -s -miss -1.0 -y']);
    elseif ispc
        if isfield(settings, 'edf2asc_path')
            edf2asc = settings.edf2asc_path;
        else
            error('edf2asc.exe path is not defined')
        end
        [a, b] = system(['edf2asc', ' ', sprintf('%s', path_edf),' -s -miss -1.0 -y']);
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
path_1 = sprintf('%s%s.asc', path_in, file_name);
if exist (path_1,'file')
    path_2 = sprintf('%s%s.dat', path_out, file_name);
    movefile(sprintf('%s',path_1), sprintf('%s',path_2))
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
        [a, b] = system(['edf2asc', ' ', sprintf('%s', path_edf),' -e -y']);
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

% Move .asc file into it's folder
path_1 = sprintf('%s%s.asc', path_in, file_name);
if exist (path_1,'file')
    path_2 = sprintf('%s%s.asc', path_out, file_name);
    movefile(sprintf('%s',path_1), sprintf('%s',path_2));
else
    % Skip it, without crashing code
end


