function import_line_callback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');
lines_tab_comp=getappdata(main_figure,'Lines_tab');

if ~isempty(layer)
    if ~isempty(layer.PathToFile)
        path=layer.PathToFile;
    else
        path=pwd;
    end
    
else
    return;
end

[Filename,PathToFile]= uigetfile({fullfile(path,'*.evl;*.dat;*.txt;*.mat;*converted.cnv')}, 'Pick a line file','MultiSelect','off');
if Filename==0
    return;
end

line=import_line(PathToFile,Filename);

if isempty(line)
    return;
end

layer.add_lines(line);

setappdata(main_figure,'Lines_tab',lines_tab_comp);
setappdata(main_figure,'Layer',layer);

update_lines_tab(main_figure)
display_lines(main_figure);

end
