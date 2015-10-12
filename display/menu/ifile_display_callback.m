function ifile_display_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');

if strcmpi(layer.Filetype,'CREST')
    file=layer.Filename{1};
    path=layer.PathToFile;
    
    tok = file(end-7);
    num = file((end-6):end);
    if (tok == 'd' || tok == 'n' || tok == 't') && ~isempty(str2double(num))
        file(end-7) = 'i';
    end
    ifiletot=fullfile(path,file);
else
   ifiletot=layer.OriginCrest;
end

if exist(ifiletot,'file')==2
    edit(ifiletot);
end

end