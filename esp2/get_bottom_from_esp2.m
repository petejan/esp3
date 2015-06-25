function [bad,bottom,rawFileName]=get_bottom_from_esp2(iFilePath,iFileName,voyage,varargin)

switch nargin
    case 3        
    pingOffset = 1;   % Esp2 seem to alway miss first ping which is default value
    rev = [];         % default empty rev --> get latest revision
    case 4          % if 3 inputs find out if rev number or ping offset number 
        if  mod(cell2mat(varargin),1) ==0
            pingOffset = cell2mat(varargin);
            rev = [];
        else
            pingOffset = 1;
            rev = cell2mat(varargin);
        end
     case 5          
        if  mod(cell2mat(varargin(1)),1) ==0;
            pingOffset = cell2mat(varargin(1));
            rev = cell2mat(varargin(2));
        else
            pingOffset = cell2mat(varargin(2));
            rev = cell2mat(varargin(1));    
        end
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
outDir = [get_tempname '/'];
%run command - make output directory for cvs
if ~mkdir(outDir)
    error('Unable to create temporary cvs directory');
end
if isempty(rev);
    command = ['cvs -d ' getCVSRepository ' checkout ' voyage '/hull/b' iFileName(2:end)];
else
    command = ['cvs -d ' getCVSRepository ' checkout -r ' num2str(rev) ' ' voyage '/hull/b' iFileName(2:end)];
end
%run command - export bottom from cvs
cd(outDir);

[~, b] = system(command,'-echo');

if ~isempty(strfind(b, 'cannot find module'));
    cd(workingPath);
    if ~isempty(strfind(computer, 'WIN')) %cygwin cvs uses linux paths
        [~, result]=system(['cygpath -u ' outDir]); %so convert outDir
        outDir = result;
    end
    system(['rm -Rf ' outDir]);
    return;
end
bFilePath = [outDir voyage '/hull'];
bFileName = ['b' iFileName(2:end)];

sample_idx = load_bottom_file([bFilePath '/' bFileName]);
sample_idx=[NaN; sample_idx];
bottom = sample_idx/depthFactor;
bottom = bottom-(1/depthFactor); 
bottom(end) = bottom(end)-2*(1/depthFactor); 
bad = load_bad_transmits([bFilePath '/' bFileName])';
bad=[1;bad];

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