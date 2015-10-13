function  open_file(~,~,file_id,main_figure)
layer=getappdata(main_figure,'Layer');

if isvalid(layer)
    if ~isempty(layer)
        if ~isempty(layer.PathToFile)
            path=layer.PathToFile;
        else
            path=pwd;
        end
        
    else
        path=pwd;
    end
else
    path=pwd;
end

Filename=layer.Filename;
PathToFile=layer.PathToFile;
if iscell(file_id)
    Filename=cell(1,length(file_id));
    PathToFile=cell(1,length(file_id));
    for iui=1:length(file_id)
        [path_temp,name_temp,ext_temp]=fileparts(file_id{iui});
        Filename{iui}=[name_temp ext_temp];
        PathToFile{iui}=path_temp;
    end
else
    if file_id==0
        [Filename,PathToFile]= uigetfile( {fullfile(path,'*.raw;d*')}, 'Pick a raw/crest file','MultiSelect','on');
    elseif file_id==1
        
        f = dir(path);
        file_list=cell2mat({f(~cellfun(@isempty,regexp({f.name},'(raw$|^d.*\d$)'))).name}');
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
        f = dir(path);
        file_list=cell2mat({f(~cellfun(@isempty,regexpi({f.name},'(raw$|^d)'))).name}');
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
        [PathToFile,Filename,~]=fileparts(fileID);
        if isempty(Filename)
            return;
        end
    end
    
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
            ftype='EK80';
        case 'CON0'
            ftype='EK60';
        otherwise
            ftype='dfile';
    end
else
    return
end

setappdata(main_figure,'Layer',layer);

read_all=0;
multi_layer=1;
join=0;

if ~isequal(Filename, 0)
    choice = questdlg('Do you want to load previoulsy saved Bottom and Region?', ...
        'Bottom/Region',...
        'Yes','No', ...
        'No');
    % Handle response
    switch choice
        case 'Yes'
            load_reg=1;
            
        case 'No'
            load_reg=0;
    end
    
    if isempty(choice)
        load_reg=0;
    end
    if iscell(Filename)
        choice = questdlg('Do you want to open files as separate layers?', ...
            'File opening mode',...
            'Yes','No','No, and force concatenation', ...
            'Yes');
        % Handle response
        switch choice
            case 'Yes'
                multi_layer=1;
                read_all=0;
            case 'No'
                multi_layer=0;
                read_all=1;
            case 'No, and force concatenation'
                multi_layer=-1;
                read_all=1;
            otherwise
                return;
        end
        
        if isempty(choice)
            return;
        end
    else
        multi_layer=0;
    end
    
    if ~strcmp(ftype,'dfile')
        
        
        
        if multi_layer==0&&layer.ID_num~=0
            choice = questdlg('Do you want to join those new layers to existing ones?', ...
                'File opening mode',...
                'Yes','No', ...
                'No');
            % Handle response
            switch choice
                case 'Yes'
                    join=1;
                case 'No'
                    join=0;
            end
            if isempty(choice)
                return;
            end
        else
            join=0;
        end
        
        if read_all==0&&join==0
            prompt={'First ping:',...
                'Last Ping:'};
            name='Pings to load from each files';
            numlines=1;
            defaultanswer={'1','Inf'};
            answer=inputdlg(prompt,name,numlines,defaultanswer);
            
            if isempty(answer)
                return;
            end
            
            ping_start= str2double(answer{1});
            ping_end= str2double(answer{2});
        else
            ping_start=1;
            ping_end=Inf;
        end
    end
    
    switch ftype
        case 'EK60'
            open_EK60_file(main_figure,PathToFile,Filename,[],ping_start,ping_end,multi_layer,join,load_reg)
        case 'EK80'
            open_EK80_files(main_figure,PathToFile,Filename,[],ping_start,ping_end,multi_layer,join,load_reg)
        case 'dfile'
            choice = questdlg('Do you want to open associated Raw File or original d-file?', ...
                'd-file/raw_file',...
                'd-file','raw file', ...
                'd-file');
            % Handle response
            switch choice
                case 'raw file'
                    dfile=0;
                    
                case 'd-file'
                    dfile=1;
            end
            
            if isempty(choice)
                dfile=1;
            end
            
            choice = questdlg('Do you want to load associated CVS Bottom and Region?', ...
                'Bottom/Region',...
                'Yes','No', ...
                'No');
            % Handle response
            switch choice
                case 'Yes'
                    CVSCheck=1;
                    
                case 'No'
                    CVSCheck=0;
            end
            
            if isempty(choice)
                CVSCheck=0;
            end
            
            switch dfile
                case 1
                    open_dfile_crest(main_figure,PathToFile,Filename,CVSCheck,load_reg,multi_layer);
                case 0
                    open_dfile(main_figure,PathToFile,Filename,CVSCheck,load_reg,multi_layer);
            end
            
    end
    
    update_display(main_figure,1);
    
end
end