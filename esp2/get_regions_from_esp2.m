function [regions,rawFileName] = get_regions_from_esp2(iFilePath, iFileName, voyage,varargin)


switch nargin
    case 3                
        rev = [];
    case 4
        
        rev = varargin{1};
end


if  ischar(iFileName)
    %if a d-,n- or t- file was specified instead of an i-file use the corresponding i-file
    tok = iFileName(end-7);
    num = iFileName((end-6):end);
    if (tok == 'd' || tok == 'n' || tok == 't') && ~isempty(str2double(num))
        iFileName(end-7) = 'i';
    end
else
    iFileName = sprintf('i%07d', iFileName);
end


%% Read ifile, get start time and raw filename
if ~isempty(strfind(computer, 'WIN')) %convert linux file path to
    [~, result]=system(['cygpath -w ' iFilePath]); %Windows
    fid=fopen([strtrim(result) '/' iFileName],'r');
else
    fid=fopen([iFilePath '/' iFileName],'r');
end

while 1
    tline = fgetl(fid);
    if ~ischar(tline),
        break;
    end
    if strfind(tline,'# convertEk60ToCrest') % we found the start time
        e = strfind(tline,'raw');
        rawFileName = tline(e-26:e+2);
    end
end

%% Checkout rFile
outDir = tempname;
%run command - make output directory for cvs
if ~mkdir(outDir)
    error('Unable to create temporary cvs directory');
end

idx_str=strfind(iFilePath,voyage);
remain_str=iFilePath(idx_str:end);
rFileName = ['r' iFileName(2:end)];

work_path=pwd;

if isempty(rev)
    command = ['cvs -d ' getCVSRepository ' checkout '  remain_str '/' rFileName];
else
    command = ['cvs -d ' getCVSRepository ' checkout ' '-r ' rev ' ' remain_str '/' rFileName];
end

%run command - export bottom from cvs
cd(outDir);
[~,output] = system(command,'-echo');
cd(work_path);

if ~isempty(strfind(output, 'cannot find module'));
    if ~isempty(strfind(computer, 'WIN')) %cygwin cvs uses linux paths
        [~, result]=system(['cygpath -u ' outDir]); %so convert outDir
        outDir = result;
    end
    system(['rm -Rf ' outDir]);
    regions=[];
    return;
end



rFilePath = fullfile(outDir,remain_str);


%% Read rFile and save region information in Regions
regions = readEsp2regions(fullfile(rFilePath,rFileName),1);

if ~isempty(strfind(computer, 'WIN')) %cygwin cvs uses linux paths
    [~, result]=system(['cygpath -u ' outDir]); %so convert outDir
    outDir = result;
end
system(['rm -Rf ' outDir]);


%% Subfunctions
end




