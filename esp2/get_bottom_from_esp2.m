function [bad,bottom,rawFileName]=get_bottom_from_esp2(iFilePath,iFileName,voyage,cvsroot,varargin)

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


ifile_info=get_ifile_info(iFilePath,str2double(iFileName(end-6:end)));
rawFileName=ifile_info.rawFileName;
depthFactor = get_ifile_parameter(fullfile(iFilePath,iFileName),'depth_factor');

%% Checkout bFile
outDir = tempname();
%run command - make output directory for cvs
if ~mkdir(outDir)
    error('Unable to create temporary cvs directory');
end

idx_str=strfind(iFilePath,voyage);
remain_str=iFilePath(idx_str:end);
bFileName = ['b' iFileName(2:end)];

% command='cvs -d :local:Z:\ checkout -d C:\Users\ladroity\AppData\Local\Temp\tpfcb5ff88_244e_4f0c_a7f1_f89606dc1a2b tan1301/hull'

if isempty(rev)
    command = ['cvs -q -d ' cvsroot ' checkout ' strrep(fullfile(remain_str,bFileName),'\','/')];
else
    command = ['cvs -q -d ' cvsroot ' checkout ' '-r ' rev ' ' strrep(fullfile(remain_str,bFileName),'\','/')];
end


%run command - export bottom from cvs
work_path=pwd;
cd(outDir)
[~,output] = system(command,'-echo');
cd(work_path)

if ~isempty(strfind(output,'checkout aborted'))||~isempty(strfind(output,'cannot find module'))||~isempty(strfind(output,'Unknown command'))
    rmdir(outDir,'s');
    bad=[];
    bottom=[];
    return;
end


bFilePath = fullfile(outDir,remain_str);

sample_idx = load_bottom_file(fullfile(bFilePath,bFileName));
bottom = sample_idx/depthFactor;
bottom = bottom-(1/depthFactor);
bottom(end) = bottom(end)-2*(1/depthFactor);
bad = load_bad_transmits(fullfile(bFilePath,bFileName))';
bad=find(bad);

bottom=bottom_cl(...
    'Origin','Esp2',...
    'Range',bottom,...
    'Sample_idx',sample_idx);
rmdir(outDir,'s');

end