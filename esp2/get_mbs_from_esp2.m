function [filenames,outDir]=get_mbs_from_esp2(varargin)

p = inputParser;

addParameter(p,'MbsId',[]);
addParameter(p,'Rev',[]);

parse(p,varargin{:});

MbsId=p.Results.MbsId;
Rev=p.Results.Rev;

if ~isempty(MbsId)
    if min([isstrprop(MbsId(1:end-14) , 'alpha'), isstrprop(MbsId(end-13:end) , 'digit')]) ~= 1  % check if string is of MBS ID type
        warning('Wrong MBSId Format');
        return;
    end
end

outDir = tempname();


if ~mkdir(outDir)
    error('Unable to create temporary cvs directory');
end

if isempty(MbsId)
    command = ['cvs -d ' getCVSRepository ' checkout mbs'];
else
    
    if isempty(Rev); % Get latest revision
        command = ['cvs -d ' getCVSRepository ' checkout mbs/' MbsId];
    else             % Get specified revision
        command = ['cvs -d ' getCVSRepository ' checkout -r ' Rev ' mbs/' MbsId];
    end
    
end


%run command
work_path=pwd;
cd(outDir)
[~,output] = system(command);
cd(work_path)

if ~isempty(strfind(output,'checkout aborted'))||~isempty(strfind(output,'cannot find module'))
    rmdir(outDir,'s');
    filenames={};
    return;
end

list_mbs=dir(fullfile(outDir,'mbs'));

filenames=fullfile(outDir,'mbs',{list_mbs(~[list_mbs(:).isdir]).name});



end