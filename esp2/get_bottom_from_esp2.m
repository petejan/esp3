function [bad,bottom,rawFileName]=get_bottom_from_esp2(iFilePath,iFileName,voyage,varargin)

switch nargin
    case 3
        rev = [];
    case 4    
        rev = varargin{1};
end

workingPath=pwd;
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
depthFactor = getdf([iFilePath '/' iFileName]);

%% Checkout bFile
outDir = get_tempname();
%run command - make output directory for cvs
if ~mkdir(outDir)
    error('Unable to create temporary cvs directory');
end

idx_str=strfind(iFilePath,voyage);
remain_str=iFilePath(idx_str:end);
bFileName = ['b' iFileName(2:end)];
work_path=pwd;

if isempty(rev)
    command = ['cvs -d ' getCVSRepository ' checkout '  remain_str '/' bFileName];
else
    command = ['cvs -d ' getCVSRepository ' checkout ' '-r ' rev ' ' remain_str '/' bFileName];
end

%run command - export bottom from cvs
cd(outDir);
[~,output] = system(command,'-echo');
cd(work_path);

if ~isempty(strfind(output, 'checkout aborted'))
    if ~isempty(strfind(computer, 'WIN')) %cygwin cvs uses linux paths
        [~, result]=system(['cygpath -u ' outDir]); %so convert outDir
        outDir = result;
    end
    system(['rm -Rf ' outDir]);
    bad=[];
    bottom=[];
    return;
end


bFilePath = fullfile(outDir,remain_str);

sample_idx = load_bottom_file(fullfile(bFilePath,bFileName));
bottom = sample_idx/depthFactor;
bottom = bottom-(1/depthFactor);
bottom(end) = bottom(end)-2*(1/depthFactor);
bad = load_bad_transmits([bFilePath '/' bFileName])';
bad=find(bad);

bottom=bottom_cl(...
    'Origin','Esp2',...
    'Range',bottom,...
    'Sample_idx',sample_idx);

cd(workingPath);

if ~isempty(strfind(computer, 'WIN')) %cygwin cvs uses linux paths
    [~, result]=system(['cygpath -u ' outDir]); %so convert outDir
    outDir = result;
end
system(['rm -Rf ' outDir]);

end