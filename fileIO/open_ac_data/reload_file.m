function  reload_file(~,~,main_figure)
layer=getappdata(main_figure,'Layer');
if isempty(layer)
    return;
end

layers=getappdata(main_figure,'Layers');
ftype=layer.Filetype;

Filename=layer.Filename;
vec_freq=layer.Frequencies;
layers=layers.delete_layers(layer.ID_num);
setappdata(main_figure,'Layers',layers);

ping_start=1;
ping_end=Inf;

switch ftype
    case {'EK60','EK80'}
        open_raw_file(main_figure,Filename,vec_freq,ping_start,ping_end)
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
loadEcho(main_figure);

end
