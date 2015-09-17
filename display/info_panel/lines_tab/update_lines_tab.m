function update_lines_tab(main_figure)
layer=getappdata(main_figure,'Layer');
lines_tab_comp=getappdata(main_figure,'Lines_tab');
list_lines = layer.list_lines();

if ~isempty(list_lines)
    set(lines_tab_comp.tog_line,'string',list_lines);
    set(lines_tab_comp.UTC_diff,'string',num2str(layer.Lines(get(lines_tab_comp.tog_line,'value')).UTC_diff,'%.2f'))
    set(lines_tab_comp.Dist_diff,'string',num2str(layer.Lines(get(lines_tab_comp.tog_line,'value')).Dist_diff,'%.0f'))
else
    set(lines_tab_comp.tog_line,'string',{'--'});
    set(lines_tab_comp.UTC_diff,'string',0)
     set(lines_tab_comp.Dist_diff,'string',0)
end


setappdata(main_figure,'Lines_tab',lines_tab_comp);

end