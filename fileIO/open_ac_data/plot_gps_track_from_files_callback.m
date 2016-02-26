function  plot_gps_track_from_files_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');

if ~isempty(layer)
    if ~isempty(layer.PathToFile)
        file_path=layer.PathToFile;
    else
        file_path=pwd;
    end
else
    file_path=pwd;
end


[Filename,PathToFile]= uigetfile( {fullfile(file_path,'*.raw')}, 'Pick an EK60 raw file','MultiSelect','on');
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
if isempty(Filename)
    return;
end

if iscell(Filename)
    Filename_tmp=Filename{1};
else
    Filename_tmp=Filename;
end

if iscell(PathToFile)
    PathToFile_tmp=PathToFile{1};
else
    PathToFile_tmp=PathToFile;
end

if ~isequal(Filename, 0)
    fid = fopen(fullfile(PathToFile_tmp,Filename_tmp), 'r');
    if fid==-1
        warning('Cannot open file');
        return;
    end
    fread(fid,1, 'int32', 'l');
    [dgType, ~] =read_dgHeader(fid,0);
    fclose(fid);
    switch dgType
        case 'XML0'
            return;
        case 'CON0'
           open_EK60_file_GPS_only(main_figure,PathToFile,Filename);
        otherwise
            return
    end
else
    return
end


end
