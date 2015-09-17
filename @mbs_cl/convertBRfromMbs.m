function idx_trans=convertBRfromMbs(mbs,varargin)
workingPath = pwd;
outDir = tempname; %Make temp directory for calibration rev
%run command - make output directory for cvs
if ~mkdir(outDir)
    error('Unable to create temporary cvs directory');
end
%% get calibration rev - allowing for different revs in mbs script
calRevs = unique(mbs.input.data.calRev);  % get all cal revisions
svCorrs=nan(1,length(calRevs));

cd(outDir);
for i = 1:length(calRevs);
    display(['Extracting calibration revision ' calRevs{i}]);
    command = ['cvs -d ' getCVSRepository ' checkout -r ' calRevs{i} ' system'];
    [~ , b] = system(command,'-echo');
    
    if ~isempty(strfind(b, 'cannot find module'));
        svCorrs(i) = NaN;
    else
        cd('system');
        fid = fopen('calibration', 'r+');
        tline = fgetl(fid);
        ind = strfind(tline, ' ');
        svCorrs(i) = str2double(tline(ind(3)+1:end));  % read sv correction
        mbs.input.data.svCorr(strcmp(mbs.input.data.calRev,calRevs{i}),1) = svCorrs(i);
        fclose(fid);
    end
end
cd(workingPath)

rmdir(outDir,'s'); %Remove temp CVS dir

transects=mbs.input.data.transect;

if nargin == 2;
    idx_trans = varargin{1};
    if length(idx_trans) > length(transects)||isempty(idx_trans)
        warning('Requested index > num transects, using num transects');
        idx_trans=1:length(transects);
    end
    
    if nanmax(idx_trans) > length(transects)        
       idx_trans(idx_trans>length(transects))=[];
       if isempty(idx_trans)
           warning('Could not find those transect, processing the last one available');
           idx_trans=length(transects);
       else
          warning('Some transects cannot be found,removing them...'); 
       end
    end
else
    idx_trans = 1:length(transects);
end

idx_transects=transects(idx_trans);
idx_transects(abs([1 diff(idx_transects)])==0)=[];


for i = idx_transects;
    idx_transect_files=find(mbs.input.data.transect==i);
    for j=idx_transect_files
        FilePath = ['X:/' mbs.input.data.voyage '/' mbs.input.data.transducer{j}];
        display(['converting bottom and bad pings for dfile ' num2str(mbs.input.data.dfile(j))]);
        [bad,mbs.input.data.bottom{j},mbs.input.data.rawFileName{j}]= get_bottom_from_esp2(FilePath, mbs.input.data.dfile(j), mbs.input.data.voyage, mbs.input.data.BotRev{j});
        mbs.input.data.bad{j}=bad;
        display(['converting regions for dfile ' num2str(mbs.input.data.dfile(j))]);
        mbs.input.data.regions{j} = get_regions_from_esp2(FilePath, mbs.input.data.dfile(j), mbs.input.data.voyage, mbs.input.data.RegRev{j});
    end
end



end