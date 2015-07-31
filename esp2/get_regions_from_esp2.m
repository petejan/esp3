function [regions,rawFileName] = get_regions_from_esp2(iFilePath, iFileName, voyage,varargin)


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

workingPath = pwd;
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
outDir = [get_tempname '/'];
%run command - make output directory for cvs
if ~mkdir(outDir)
    error('Unable to create temporary cvs directory');
end
if isempty(rev);
    command = ['cvs -d ' getCVSRepository ' checkout ' voyage '/hull/r' iFileName(2:end)];
else
    command = ['cvs -d ' getCVSRepository ' checkout -r ' num2str(rev) ' ' voyage '/hull/r' iFileName(2:end)];
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

rFilePath = [outDir voyage '/hull'];
rFileName = ['/r' iFileName(2:end)];

%% Read rFile and save region information in Regions
regions = readEsp2regions([rFilePath rFileName],pingOffset);
cd(workingPath);

if ~isempty(strfind(computer, 'WIN')) %cygwin cvs uses linux paths
    [~, result]=system(['cygpath -u ' outDir]); %so convert outDir
    outDir = result;
end
system(['rm -Rf ' outDir]);


%% Subfunctions
end
function Regions = readEsp2regions(rfile,pingOffset)

fid = fopen(rfile, 'r');
eval(repmat('fgetl(fid);',1,3));
PingCount = fgetl(fid);
RegionCount = fgetl(fid);
i =0;
Regions=region_cl.empty(0);

while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    if strfind(tline,'RegionBegin');
        i = i+1;
        tline = fgetl(fid);
        ID = {tline(5:end)};
        tline = fgetl(fid);
        c = strfind(tline,':');
        s = strfind(tline,';');
        Shape = tline(c(1)+2:c(2)-1);
        tmp = tline(c(2)+2:s-1);
        cm = strfind(tmp,',');
        sp = strfind(tmp,' ');
        
        
        
        x1 = str2double(tmp(1:cm(1)-1));
        y1 = round(str2double(tmp(cm(1)+1:sp-1)));
        x2 = str2double(tmp(sp+1:cm(2)-1));
        y2 = round(str2double(tmp(cm(2)+1:end)));
        
        Ping_ori=nanmin(x1,x2)+pingOffset;
        Sample_ori=nanmin(y1,y2)+1;
        
        Bbox_w=nanmax(x1,x2)-Ping_ori-1;
        Bbox_h=nanmax(y1,y2)-Sample_ori-1;
        
        
        if strcmp(Shape,'Polygon');  % get Region Polygon Points: 1st dim ping no, 2nd dim sample no
            tmp = tline(s+1:end);
            cm = strfind(tmp,',');
            sp = strfind(tmp,' ');
            X_cont=nan(1,length(sp));
            Y_cont=nan(1,length(sp));
            
            for j = 1:length(sp);
                X_cont(j) = str2double(tmp(sp(j)+1:cm(j)-1))+1-Ping_ori;
                if j==length(sp);
                    Y_cont(j) = round(str2double(tmp(cm(j)+1:end-1)))-Sample_ori;
                else
                    Y_cont(j) =round(str2double(tmp(cm(j)+1:sp(j+1)-1)))-Sample_ori;
                end
                
            end
        end
        
        switch Shape
            case 'Rectangle'
                Shape='Rectangular';
            otherwise
                Shape=Shape;
        end
               
        tline = fgetl(fid);
        Type = tline(13:end);
        tline = fgetl(fid);
        Class = tline(17:end);
        tline = fgetl(fid);
        Author = tline(9:end);
        tline = fgetl(fid);
        Cell_h = str2double(tline(12:end));
        Cell_h_unit='meters';
        tline = fgetl(fid);
        Reference = tline(15:end);
        
                        
        switch Reference
            case 'Bottom Referenced'
                Reference='Bottom';
            case 'Surface Referenced'
                Reference='Surface';
        end
        
        switch Type
            case 'Include'
                Type='Data';
            otherwise
                Type='Bad Data';
        end
        
        tline = fgetl(fid);
        Cell_w = str2double(tline(16:end));
        Cell_w_unit='pings';
        
         Regions(i)=region_cl(...
            'ID',str2double(ID),...
            'Name',Class,...
            'Type',Type,...
            'Idx_pings',idx_pings,...
            'Idx_r',idx_r,...
            'Shape',Shape,...
            'Sv_reg',[],...
            'Reference',Reference,...
            'Cell_w',Cell_w,...
            'Cell_w_unit',Cell_w_unit,...
            'Cell_h',Cell_h,...
            'Cell_h_unit',Cell_h_unit,...
            'Output',[]);
    end
end
fclose(fid);
end



