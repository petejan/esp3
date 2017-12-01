function svCorr=CVS_CalRevs(cvsroot,varargin)

p = inputParser;

addRequired(p,'cvsroot',@ischar);
addParameter(p,'CalRev',1);

parse(p,cvsroot,varargin{:});

CalRev=p.Results.CalRev;

workingPath = pwd;
outDir = fullfile(tempname); %Make temp directory for calibration rev
%run command - make output directory for cvs
if ~mkdir(outDir)
    error('Unable to create temporary cvs directory');
end
%% get calibration rev - allowing for different revs in mbs script
display(['Extracting calibration revision ' CalRev]);

cd(outDir);
command = ['cvs -d ' cvsroot ' checkout -r ' CalRev ' system'];
[~ , output] = system(command,'-echo');

if  contains(output,{'checkout aborted' 'cannot find module'})
    svCorr = 1;
else
    cd('system');
    fid = fopen('calibration', 'r+');
    tline = fgetl(fid);
    ind = strfind(tline, ' ');
    svCorr = str2double(tline(ind(3)+1:end));  % read sv correction
    fclose(fid);
end

cd(workingPath)

rmdir(outDir,'s'); %Remove temp CVS dir