function  plot_gps_track_from_files_callback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');
if ~isempty(layer)
    [path_lay,~]=layer.get_path_files();
    if ~isempty(path_lay)
        file_path=path_lay{1};
    else
        file_path=pwd;
    end
else
    file_path=pwd;
end


[Filename,PathTofile]= uigetfile( {fullfile(file_path,'*.raw')}, 'Pick an EK60 raw file','MultiSelect','on');
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

for ic=1:length(Filename)
    Filename{ic}=fullfile(PathTofile,Filename{ic});
end

if iscell(Filename)
    Filename_tmp=Filename{1};
else
    Filename_tmp=Filename;
end

if ~isequal(Filename, 0)
    fid = fopen(fullfile(Filename_tmp), 'r');
    if fid==-1
        warning('Cannot open file');
        return;
    end
    fread(fid,1, 'int32', 'l');
    [dgType, ~] =read_dgHeader(fid,0);
    fclose(fid);
    switch dgType
        case 'XML0'
            open_EK80_file_GPS_only(main_figure,Filename);
        case 'CON0'
           open_EK60_file_GPS_only(main_figure,Filename);
        otherwise
            return
    end
else
    return
end


end
