function  open_file(~,~,file_id,main_figure)

layer=getappdata(main_figure,'Layer');
app_path=getappdata(main_figure,'App_path');


if isempty(file_id)
    return;
end


if ~isempty(layer)
    [path_lay,~]=layer.get_path_files();
    if ~isempty(path_lay)
        file_path=path_lay{1};
    else
        file_path=app_path.data;
    end
else
    file_path=app_path.data;
end


if iscell(file_id)||ischar(file_id)
    Filename=file_id;
else
    if file_id==0
        [Filename,path_f]= uigetfile( {fullfile(file_path,'*.raw;d*;*A;*.lst')}, 'Pick a raw/crest/asl/fcv30 file','MultiSelect','on');
        if isempty(Filename)
            return;
        end
        
        if ~iscell(Filename)
            if (Filename==0)
                return;
            end
            Filename={Filename};
        end
        
        idx_keep=~cellfun(@isempty,regexp(Filename(:),'(A$|raw$|lst$|^d.*\d$)'));
        Filename=Filename(idx_keep);
        if isempty(Filename)
            return;
        end
        
        for ic=1:length(Filename)
            Filename{ic}=fullfile(path_f,Filename{ic});
        end
        
        
    elseif file_id==1
        if ~isempty(layer)
            [~,Filename]=layer.get_path_files();
        else
            return;
        end
        
        f = dir(file_path);
        
        file_list=({f(~cellfun(@isempty,regexp({f.name},'(A$|raw$|lst$|^d.*\d$)'))).name}');
        
        if ~isempty(file_list)
            i=1;
            file_diff=0;
            while i< size(file_list,1)&& file_diff==0
                file_diff=strcmp(file_list{i},Filename{end});
                i=i+1;
            end
            if file_diff
                Filename=fullfile(file_path,file_list{i});
            else
                Filename=[];
            end
            
        else
            return;
        end
    elseif file_id==2
        if ~isempty(layer)
            [~,Filename]=layer.get_path_files();
        else
            return;
        end
        
        f = dir(file_path);
        
        file_list=({f(~cellfun(@isempty,regexp({f.name},'(A$|raw$|lst$|^d.*\d$)'))).name}');
        if ~isempty(file_list)
            i=size(file_list,1);
            file_diff=0;
            while i>1 && file_diff==0
                file_diff=strcmp(file_list{i},Filename{1});
                i=i-1;
            end
            if file_diff
                Filename=fullfile(file_path,file_list{i});
            else
                Filename=[];
            end
            
        end
        
    elseif ischar(file_id)
        Filename=fileID;
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

if isempty(Filename)
    return;
end

if ~isequal(Filename, 0)
    ftype=get_ftype(Filename_tmp);
else
    return;
end

setappdata(main_figure,'Layer',layer);


if ~iscell(Filename)
    Filename={Filename};
end




if ~isequal(Filename, 0)
    enabled_obj=findobj(main_figure,'Enable','on');
    set(enabled_obj,'Enable','off');
    try
        switch ftype
            case {'EK60','EK80','dfile'}
                
                missing_files=find_survey_data_db(Filename);    
                
                if ~isempty(missing_files)
                    choice = questdlg('It looks like you are trying to open incomplete transects... Do you want load the rest as well?', ...
                        'Incomplete',...
                        'Yes','No',...
                        'Yes');
                    % Handle response
                    switch choice
                        case 'Yes'
                            Filename=union(Filename,missing_files);
                            snapnow;
                        case 'No'
                        otherwise
                            return;
                    end
                    
                    
                end
        end
        
        
        ping_start=1;
        ping_end=Inf;
        
        switch ftype
            case 'fcv30'
                for ifi=1:length(Filename)
                    open_FCV30_file(main_figure,Filename{ifi});
                end
                
            case {'EK60','EK80'}
                %             profile on;
                open_raw_file(main_figure,Filename,[],ping_start,ping_end);
                %             profile off;
                %             profile viewer;
            case 'asl'
                open_asl_files(main_figure,Filename);
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
                    return;
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
                        open_dfile_crest(main_figure,Filename,CVSCheck);
                    case 0
                        open_dfile(main_figure,Filename,CVSCheck);
                end
                
        end
    catch err
        disp(err.message);
        for ife=1:length(Filename)
            fprintf('Could not open files %s\n',Filename{ife});
        end
    end
    %
    set(enabled_obj,'Enable','on');
    hide_status_bar(main_figure);
    loadEcho(main_figure);
end


end