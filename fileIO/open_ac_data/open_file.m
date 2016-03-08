function  open_file(~,~,file_id,main_figure)
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


if iscell(file_id)
    Filename=file_id;
else
    if file_id==0
        [Filename,path_f]= uigetfile( {fullfile(file_path,'*.raw;d*;*A')}, 'Pick a raw/crest/asl file','MultiSelect','on');
        if isempty(Filename)
            return;
        end
        
        if ~iscell(Filename)
            if (Filename==0)
                return;
            end
            Filename={Filename};
        end
        
        idx_keep=~cellfun(@isempty,regexp(Filename(:),'(A$|raw$|^d.*\d$)'));
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
        file_list=({f(~cellfun(@isempty,regexp({f.name},'(A$|raw$|^d.*\d$)'))).name}');
        
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
        file_list=({f(~cellfun(@isempty,regexp({f.name},'(A$|raw$|^d.*\d$)'))).name}');
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
    fid = fopen(Filename_tmp, 'r');
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
            fid = fopen(Filename_tmp, 'r','l');
            dgType=fread(fid,1,'uint16');
            fclose(fid);
        if hex2dec('FD02')~=dgType
            ftype='asl';
        else
            ftype='dfile';
        end
            
    end
else
    return
end

setappdata(main_figure,'Layer',layer);

%read_all=0;

multi_layer=0;
join=0;

if ~iscell(Filename)
    Filename={Filename};
end


if ~isequal(Filename, 0)
    
    [path_tmp,~,~]=fileparts(Filename{1});
    
    survey_struct=import_survey_data(fullfile(path_tmp,'echo_logbook.csv'));
    
    if ~isempty(survey_struct)
        
        [~,files_lay,ext_lay]=cellfun(@fileparts,Filename,'UniformOutput',0);
        for ic=1:length(files_lay)
            files_lay{ic}=deblank([files_lay{ic} ext_lay{ic}]);
        end
        
        [~,~,idx_missing]=find_survey_data(files_lay,survey_struct);
        
        idx_incomp=find(cellfun(@(x) ~isempty(x),idx_missing));
        
        if ~isempty(idx_incomp)
            choice = questdlg('It looks like you are trying to open incomplete transects... Do you want load the rest as well?', ...
                'Incomplete',...
                'Yes','No',...'Force Concatenation', ...
                'Yes');
            % Handle response
            switch choice
                case 'Yes'
                    for ifile_miss=idx_incomp
                        miss_files=fullfile(path_tmp,survey_struct.Filename(idx_missing{ifile_miss}));
                        Filename=[Filename miss_files];
                    end
                case 'No'
                otherwise
                    return;
            end
            Filename=unique(Filename);
            
        end
    end
    
    %         if ask_q==1
    %             choice = questdlg('Do you want to open files as separate layers?', ...
    %                 'File opening mode',...
    %                 'Yes','No',...'Force Concatenation', ...
    %                 'Yes');
    %             % Handle response
    %             switch choice
    %                 case 'Yes'
    %                     multi_layer=1;
    %                     %read_all=0;
    %                 case 'No'
    %                     multi_layer=0;
    %                     %read_all=1;
    %                 case 'Force Concatenation'
    %                     multi_layer=-1;
    %                 otherwise
    %                     return;
    %             end
    %
    %             if isempty(choice)
    %                 return;
    %             end
    %         else
    %             multi_layer=0;
    %         end
    
    %  if ~strcmp(ftype,'dfile')
    %         if multi_layer==0&&ID_num~=0&&~isempty(layers)
    %             choice = questdlg('Do you want to join those new layers to existing ones?', ...
    %                 'File opening mode',...
    %                 'Yes','No', ...
    %                 'No');
    %             % Handle response
    %             switch choice
    %                 case 'Yes'
    %                     join=1;
    %                 case 'No'
    %                     join=0;
    %             end
    %             if isempty(choice)
    %                 return;
    %             end
    %         else
    %             join=0;
    %         end
    
    %         if read_all==0&&join==0
    %             prompt={'First ping:',...
    %                 'Last Ping:'};
    %             name='Pings to load from each files';
    %             numlines=1;
    %             defaultanswer={'1','Inf'};
    %             answer=inputdlg(prompt,name,numlines,defaultanswer);
    %
    %             if isempty(answer)
    %                 return;
    %             end
    %
    %             ping_start= str2double(answer{1});
    %         %             ping_end= str2double(answer{2});
    %         %         else
    %         ping_start=1;
    %         ping_end=Inf;
    %         end
    % end
    
    ping_start=1;
    ping_end=Inf;
    
    switch ftype
        case 'EK60'
            open_EK60_file(main_figure,Filename,[],ping_start,ping_end,multi_layer,join)
        case 'EK80'
            open_EK80_files(main_figure,Filename,[],ping_start,ping_end,multi_layer,join)    
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
                    open_dfile_crest(main_figure,Filename,CVSCheck);
                case 0
                    open_dfile(main_figure,Filename,CVSCheck);
            end
            
    end
    
    listenEcho([],[],main_figure);
    
end
end