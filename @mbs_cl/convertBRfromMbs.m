function convertBRfromMbs(mbs,varargin)
workingPath = pwd;
outDir = [get_tempname '/']; %Make temp directory for calibration rev
%run command - make output directory for cvs
if ~mkdir(outDir)
    error('Unable to create temporary cvs directory');
end
%% get calibration rev - allowing for different revs in mbs script
calRevs = unique(mbs.input.data.calRev);  % get all cal revisions
svCorrs=nan(1,length(calRevs));

cd(outDir);
for i = 1:length(calRevs);
    display(['Extracting calibration revision ' num2str(calRevs(i))]);
    command = ['cvs -d ' getCVSRepository ' checkout -r ' num2str(calRevs(i)) ' system'];
    [~ , b] = system(command,'-echo');
    
    if ~isempty(strfind(b, 'cannot find module'));
        svCorrs(i) = NaN;
    else
        cd('system');
        fid = fopen('calibration', 'r+');
        tline = fgetl(fid);
        ind = strfind(tline, ' ');
        svCorrs(i) = str2double(tline(ind(3)+1:end));  % read sv correction
        mbs.input.data.svCorr(mbs.input.data.calRev == calRevs(i),1) = svCorrs(i);
        fclose(fid);
    end
end
cd(workingPath)

if ~isempty(strfind(computer, 'WIN')) %cygwin cvs uses linux paths
    [~, result]=system(['cygpath -u ' outDir]); %so convert outDir
    outDir = result;
end
system(['rm -Rf ' outDir]); %Remove temp CVS dir


transects=mbs.input.data.transect;
transects(abs([1;diff(mbs.input.data.transect)])==0)=[];

if nargin == 2;
    uu = varargin{1};
    if length(uu) > length(transects)
        warning('Requested index > num transects, using num transects');
        uu=1:length(transects);
    end
else
    uu = 1:length(transects);
end

idx_transects = transects(uu);


for i = idx_transects';
    idx_transect_files=find(mbs.input.data.transect==i);
    for j=idx_transect_files'
        linuxFilePath = ['/data/ac1/' mbs.input.data.voyage '/' mbs.input.data.transducer{j}];
        display(['converting bottom and bad pings for dfile ' num2str(mbs.input.data.dfile(j))]);
        [bad,mbs.input.data.bottom{j},mbs.input.data.rawFileName{j}]= get_bottom_from_esp2(linuxFilePath, mbs.input.data.dfile(j), mbs.input.data.voyage, mbs.input.data.BotRev(j));
        mbs.input.data.bad{j}=(bad==1);
        display(['converting regions for dfile ' num2str(mbs.input.data.dfile(j))]);
        mbs.input.data.regions{j} = get_regions_from_esp2(linuxFilePath, mbs.input.data.dfile(j), mbs.input.data.voyage, mbs.input.data.RegRev(j));
    end
end



end