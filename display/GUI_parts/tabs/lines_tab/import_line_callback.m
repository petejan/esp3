function import_line_callback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');
lines_tab_comp=getappdata(main_figure,'Lines_tab');

if ~isempty(layer)
    if ~isempty(layer.Filename)
        [path_f,~,~]=fileparts(layer.Filename{1});
    else
        path_f=pwd;
    end
    
else
    return;
end

[Filename,path_line]= uigetfile({fullfile(path_f,'*.evl;*.dat;*.txt;*.mat;*converted.cnv;SUPERVISOR*.log')}, 'Pick a line file','MultiSelect','off');
if Filename==0
    return;
end

line=import_line(path_line,Filename);

if isempty(line)
    return;
end

layer.add_lines(line);

setappdata(main_figure,'Lines_tab',lines_tab_comp);
setappdata(main_figure,'Layer',layer);

update_lines_tab(main_figure)
display_lines(main_figure);

end
