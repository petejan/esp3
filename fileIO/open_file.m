function  open_file(~,~,file_id,main_figure)
layer=getappdata(main_figure,'Layer');

read_all=0;
if ~isempty(layer)
    if ~isempty(layer.PathToFile)
        path=layer.PathToFile;
    else
        path=pwd;
    end
    
else
    path=pwd;
end

Filename=layer.Filename;
if ~iscell(Filename)
    Filename={Filename};
end


if file_id==0
    [Filename,PathToFile]= uigetfile([path '/*.raw'], 'Pick a raw file','MultiSelect','on');
elseif file_id==1
    file_list=ls([path '/*.raw']);
    if ~isempty(file_list)
        i=1;
        file_diff=0;
        while i< size(file_list,1)&& file_diff==0
            file_diff=strcmp(file_list(i,:),Filename{end});
            i=i+1;
        end
        
        if file_diff
            Filename=file_list(i,:);
            PathToFile=layer.PathToFile;
        else
            Filename=0;
            PathToFile=layer.PathToFile;
        end
    else
        return;
    end
elseif file_id==2
    file_list=ls([path '/*.raw']);
    if ~isempty(file_list)
        i=size(file_list,1);
        file_diff=0;
        while i>1 && file_diff==0
            file_diff=strcmp(file_list(i,:),Filename{1});
            i=i-1;
        end
        if file_diff
            Filename=file_list(i,:);
            PathToFile=layer.PathToFile;
        else
            Filename=0;
            PathToFile=layer.PathToFile;
        end
    end
    
elseif ischar(file_id)
    idx_slash=strfind(file_id,'\');
    if isempty(idx_slash)
        idx_slash=strfind(file_id,'/');
    end
    
    if isempty(idx_slash)
        return;
    end
    Filename=file_id(idx_slash(end)+1:end);
    PathToFile=file_id(1:idx_slash(end));
    read_all=1;
end

if iscell(Filename)
    Filename_tmp=Filename{1};
else
    Filename_tmp=Filename;
end

if ~isequal(Filename, 0)
    fid = fopen([PathToFile Filename_tmp], 'r');
    fread(fid,1, 'int32', 'l');
    [dgType, ~] =read_dgHeader(fid,0);
    fclose(fid);
    switch dgType
        case 'XML0'
            ftype='EK80';
        case 'CON0'
            ftype='EK60';
        otherwise
            return;
    end
else
    return
end

setappdata(main_figure,'Layer',layer);

switch ftype
    case 'EK60'
        open_EK60_file(main_figure,PathToFile,Filename,read_all)
    case 'EK80'
        open_EK80_files(main_figure,PathToFile,Filename,read_all)
end


end