function update_lines_tab(main_figure)
layer=getappdata(main_figure,'Layer');
lines_tab_comp=getappdata(main_figure,'Lines_tab');
list_lines = layer.list_lines();

if ~isempty(list_lines)
    set(lines_tab_comp.tog_line,'string',list_lines);
    idx_line=get(lines_tab_comp.tog_line,'value');
    idx_line=nanmin(length(layer.Lines),idx_line);
   
    utc_diff=layer.Lines(idx_line).UTC_diff;
     %set(lines_tab_comp.tog_line,'value',idx_line);
   
    if utc_diff<0
        start_symb='-';
    else
        start_symb='';
    end
    
    set(lines_tab_comp.time_h_diff,'string',[start_symb datestr(abs(utc_diff/24),'HH:MM:SS')]);
    
    set(lines_tab_comp.Dist_diff,'string',num2str(layer.Lines(idx_line).Dist_diff,'%.0f'))
    set(lines_tab_comp.Range_diff,'string',num2str(layer.Lines(idx_line).Dr,'%.1f'));
else
    set(lines_tab_comp.tog_line,'string',{'--'});
    set(lines_tab_comp.time_h_diff,'string','00:00:00')
    set(lines_tab_comp.Dist_diff,'string',0)
    set(lines_tab_comp.Range_diff,'string',0)
end

%set(findall(lines_tab_comp.lines_tab, '-property', 'Enable'), 'Enable', 'on');

setappdata(main_figure,'Lines_tab',lines_tab_comp);
end