function  index_files_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');



if ~isempty(layer)
    [path_lay,~]=get_path_files(layer);
    if ~isempty(path_lay)
        file_path=path_lay{1};
    else
        file_path=pwd;
    end
else
    file_path=pwd;
end

[Filename,PathToFile]= uigetfile( {fullfile(file_path,'*.raw')}, 'Pick a raw file','MultiSelect','on');
if isempty(Filename)
    return;
end


if ~iscell(Filename)
    if (Filename==0)
        return;
    end
    Filename={Filename};
end
idx_keep=~cellfun(@isempty,regexp(Filename(:),'(raw$|^d.*\d$)'));
Filename=Filename(idx_keep);

indexing_file=waitbar(1/length(Filename),sprintf('Indexing file: %s',Filename{1}),'Name','Indexing files', 'WindowStyle', 'modal');

for i=1:length(Filename) 
    try
        waitbar(i/length(Filename),indexing_file,sprintf('Indexing file: %s',Filename{i}), 'WindowStyle', 'modal');
    catch
        indexing_file=waitbar(i/length(Filename),sprintf('Indexing file: %s',Filename{i}),'Name','Indexing files', 'WindowStyle', 'modal');
    end
    
    fileN=fullfile(PathToFile,Filename{i});
    
    if ~isdir(fullfile(PathToFile,'echoanalysisfiles'))
        mkdir(fullfile(PathToFile,'echoanalysisfiles'));
    end
    fileIdx=fullfile(PathToFile,'echoanalysisfiles',[Filename{i}(1:end-4) '_echoidx.mat']);
    if exist(fileIdx,'file')>0
       delete(fileIdx); 
    end
    idx_raw_obj=idx_from_rawEK60_v2(fileN);
    save(fileIdx,'idx_raw_obj');

end

if exist('indexing_file','var')
    close(indexing_file);
end

