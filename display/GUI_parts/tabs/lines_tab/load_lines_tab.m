function load_lines_tab(main_figure,option_tab_panel)


lines_tab_comp.lines_tab=uitab(option_tab_panel,'Title','Lines');


    list_lines={'--'};
    utc_str=0;
    dist_diff_str=0;



uicontrol(lines_tab_comp.lines_tab,'Style','Text','String','Lines','units','normalized','Position',[0.5 0.8 0.1 0.1]);
lines_tab_comp.tog_line=uicontrol(lines_tab_comp.lines_tab,'Style','popupmenu','String',list_lines,'Value',length(list_lines),'units','normalized','Position', [0.6 0.8 0.3 0.1],'callback',{@tog_line,main_figure});

uicontrol(lines_tab_comp.lines_tab,'Style','Text','String','Diff with UTC(h)','units','normalized','Position',[0.5 0.6 0.2 0.1]);
lines_tab_comp.UTC_diff=uicontrol(lines_tab_comp.lines_tab,'Style','edit','unit','normalized','position',[0.7 0.6 0.1 0.1],'string',utc_str,'callback',{@change_time_callback,main_figure});

uicontrol(lines_tab_comp.lines_tab,'Style','Text','String','Distance from vessel (m)','units','normalized','Position',[0.1 0.6 0.3 0.1]);
lines_tab_comp.Dist_diff=uicontrol(lines_tab_comp.lines_tab,'Style','edit','unit','normalized','position',[0.4 0.6 0.1 0.1],'string',dist_diff_str,'callback',{@change_dist_callback,main_figure});


uicontrol(lines_tab_comp.lines_tab,'Style','pushbutton','String','Import','units','normalized','pos',[0.45 0.3 0.10 0.15],'callback',{@import_line_callback,main_figure});
uicontrol(lines_tab_comp.lines_tab,'Style','pushbutton','String','Delete','units','normalized','pos',[0.55 0.3 0.1 0.15],'callback',{@delete_line_callback,main_figure});

set(findall(lines_tab_comp.lines_tab, '-property', 'Enable'), 'Enable', 'off');
setappdata(main_figure,'Lines_tab',lines_tab_comp);
end



function tog_line(~,~,main_figure)
update_lines_tab(main_figure);
display_lines(main_figure)
end


function delete_line_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');
lines_tab_comp=getappdata(main_figure,'Lines_tab');

if ~isempty(layer.Lines)
    active_line=layer.Lines(get(lines_tab_comp.tog_line,'value'));
    layer.rm_line_id(active_line.ID);
    list_line = layer.list_lines();
    
    if ~isempty(list_line)
        set(lines_tab_comp.tog_line,'value',1)
        set(lines_tab_comp.tog_line,'string',list_line);
    else
        set(lines_tab_comp.tog_line,'value',1)
        set(lines_tab_comp.tog_line,'string',{'--'});
    end
    setappdata(main_figure,'Layer',layer);
    update_lines_tab(main_figure);
    display_lines(main_figure);
else
    return
end
end

function change_dist_callback(src,~,main_figure)
layer=getappdata(main_figure,'Layer');

lines_tab_comp=getappdata(main_figure,'Lines_tab');

if ~isempty(layer.Lines)
    if isnumeric(str2double(get(src,'string')))
        if ~isnan(str2double(get(src,'string')))
            layer.Lines(get(lines_tab_comp.tog_line,'value')).Dist_diff=str2double(get(src,'string'));
        end
    end
    setappdata(main_figure,'Layer',layer);
    update_lines_tab(main_figure)
    display_lines(main_figure);
else
    return
end
end

function change_time_callback(src,~,main_figure)
layer=getappdata(main_figure,'Layer');

lines_tab_comp=getappdata(main_figure,'Lines_tab');

if ~isempty(layer.Lines)
    if isnumeric(str2double(get(src,'string')))
        if ~isnan(get(src,'string'))
        layer.Lines(get(lines_tab_comp.tog_line,'value')).change_time(str2double(get(src,'string')))
        end
    end
    setappdata(main_figure,'Layer',layer);
    update_lines_tab(main_figure)
    display_lines(main_figure);
else
    return
end
end





