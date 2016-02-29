function ifile_display_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');
if isempty(layer)
    return;
end

if strcmpi(layer.Filetype,'CREST')

   [path_file,file,~]=fileparts(layer.Filename{1});
    
    tok = file(end-7);
    num = file((end-6):end);
    if (tok == 'd' || tok == 'n' || tok == 't') && ~isempty(str2double(num))
        file(end-7) = 'i';
    end
    ifiletot=fullfile(path_file,file);
else
   ifiletot=layer.OriginCrest;
end

if exist(ifiletot,'file')==2
    edit(ifiletot);
end

end