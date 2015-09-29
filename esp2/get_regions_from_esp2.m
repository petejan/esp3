function [regions,rawFileName] = get_regions_from_esp2(iFilePath,iFileName,voyage,cvsroot,varargin)


switch nargin
    case 4                
        rev = [];
    case 5       
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


ifile_info=parse_ifile(iFilePath,str2double(iFileName(end-6:end)));
rawFileName=ifile_info.rawFileName;

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
    command = ['cvs -q -d ' cvsroot ' checkout ' strrep(fullfile(remain_str,rFileName),'\','/')];
else
    command = ['cvs -q -d ' cvsroot ' checkout ' '-r ' rev ' ' strrep(fullfile(remain_str,rFileName),'\','/')];
end

%run command - export bottom from cvs
cd(outDir);
[~,output] = system(command,'-echo');
cd(work_path);

if ~isempty(strfind(output,'checkout aborted'))||~isempty(strfind(output,'cannot find module'))||~isempty(strfind(output,'Unknown command'))
    rmdir(outDir,'s');
    regions=[];
    return;
end

rFilePath = fullfile(outDir,remain_str);

%% Read rFile and save region information in Regions
regions = readEsp2regions(fullfile(rFilePath,rFileName),1);

rmdir(outDir,'s');


end




