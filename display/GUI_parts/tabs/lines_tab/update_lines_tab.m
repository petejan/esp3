function update_lines_tab(main_figure)
layer=getappdata(main_figure,'Layer');
lines_tab_comp=getappdata(main_figure,'Lines_tab');
list_lines = layer.list_lines();

if ~isempty(list_lines)
    set(lines_tab_comp.tog_line,'string',list_lines);

    utc_diff=layer.Lines(get(lines_tab_comp.tog_line,'value')).UTC_diff;
    h_diff=floor(abs(utc_diff));
    m_diff=floor(((utc_diff-h_diff)*60));
    s_diff=floor(((utc_diff*60*60-h_diff*60*60-m_diff*60)));
    
    set(lines_tab_comp.time_h_diff,'string',num2str(h_diff,'%.0f'));
    set(lines_tab_comp.time_m_diff,'string',num2str(m_diff,'%.0f'));
    set(lines_tab_comp.time_s_diff,'string',num2str(s_diff,'%.0f'));
    set(lines_tab_comp.Dist_diff,'string',num2str(layer.Lines(get(lines_tab_comp.tog_line,'value')).Dist_diff,'%.0f'))
    set(lines_tab_comp.Range_diff,'string',num2str(layer.Lines(get(lines_tab_comp.tog_line,'value')).Dr,'%.0f'));
else
    set(lines_tab_comp.tog_line,'string',{'--'});
    set(lines_tab_comp.time_h_diff,'string',0)
    set(lines_tab_comp.time_m_diff,'string',0)
    set(lines_tab_comp.time_s_diff,'string',0)
    set(lines_tab_comp.Dist_diff,'string',0)
    set(lines_tab_comp.Range_diff,'string',0)
end

set(findall(lines_tab_comp.lines_tab, '-property', 'Enable'), 'Enable', 'on');

setappdata(main_figure,'Lines_tab',lines_tab_comp);
end