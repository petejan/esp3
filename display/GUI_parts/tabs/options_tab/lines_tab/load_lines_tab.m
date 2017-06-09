function load_lines_tab(main_figure,option_tab_panel)


lines_tab_comp.lines_tab=uitab(option_tab_panel,'Title','Lines');


list_lines={'--'};
utc_str='00:00:00';
dist_diff_str=0;
range_diff_str=0;




uicontrol(lines_tab_comp.lines_tab,'Style','Text','String','Lines','units','normalized','Position',[0.5 0.8 0.1 0.1]);
lines_tab_comp.tog_line=uicontrol(lines_tab_comp.lines_tab,'Style','popupmenu','String',list_lines,'Value',length(list_lines),'units','normalized','Position', [0.6 0.8 0.3 0.1],'callback',{@tog_line,main_figure});

uicontrol(lines_tab_comp.lines_tab,'Style','Text','String','Time (hh:mm:ss)','units','normalized','Position',[0 0.6 0.2 0.1]);
lines_tab_comp.time_h_diff=uicontrol(lines_tab_comp.lines_tab,'Style','edit','unit','normalized','position',[0.2 0.6 0.15 0.1],'string',utc_str,'callback',{@change_time_callback,main_figure});
% lines_tab_comp.time_m_diff=uicontrol(lines_tab_comp.lines_tab,'Style','edit','unit','normalized','position',[0.20 0.6 0.03 0.1],'string',utc_str,'callback',{@change_time_callback,main_figure});
% lines_tab_comp.time_s_diff=uicontrol(lines_tab_comp.lines_tab,'Style','edit','unit','normalized','position',[0.25 0.6 0.03 0.1],'string',utc_str,'callback',{@change_time_callback,main_figure});

uicontrol(lines_tab_comp.lines_tab,'Style','Text','String','Dist. from sounder (m)','units','normalized','Position',[0 0.4 0.2 0.1]);
lines_tab_comp.Dist_diff=uicontrol(lines_tab_comp.lines_tab,'Style','edit','unit','normalized','position',[0.2 0.4 0.05 0.1],'string',dist_diff_str,'callback',{@change_dist_callback,main_figure});

uicontrol(lines_tab_comp.lines_tab,'Style','Text','String','Vertical offset (m)','units','normalized','Position',[0 0.2 0.2 0.1]);
lines_tab_comp.Range_diff=uicontrol(lines_tab_comp.lines_tab,'Style','edit','unit','normalized','position',[0.2 0.2 0.05 0.1],'string',range_diff_str,'callback',{@change_range_callback,main_figure});



str_delete='<HTML><center><FONT color="Red"><b>Delete</b></Font> ';
str_draw='<HTML><center><FONT color="Green"><b>Draw</b></Font> ';
uicontrol(lines_tab_comp.lines_tab,'Style','pushbutton','String',str_draw,'units','normalized','pos',[0.35 0.45 0.1 0.15],'callback',{@draw_line_callback,main_figure});
uicontrol(lines_tab_comp.lines_tab,'Style','pushbutton','String',str_delete,'units','normalized','pos',[0.45 0.45 0.1 0.15],'callback',{@delete_line_callback,main_figure});

uicontrol(lines_tab_comp.lines_tab,'Style','pushbutton','String','Import','units','normalized','pos',[0.35 0.3 0.15 0.15],'callback',{@import_line_callback,main_figure});

uicontrol(lines_tab_comp.lines_tab,'Style','pushbutton','String','Use as Offset','units','normalized','pos',[0.65 0.3 0.15 0.15],'callback',{@offset_line_callback,main_figure});
uicontrol(lines_tab_comp.lines_tab,'Style','pushbutton','String','Disp. Offset','units','normalized','pos',[0.65 0.45 0.15 0.15],'callback',{@display_offset_callback,main_figure});
uicontrol(lines_tab_comp.lines_tab,'Style','pushbutton','String','Remove Offset','units','normalized','pos',[0.8 0.3 0.15 0.15],'callback',{@remove_offset_callback,main_figure});

uicontrol(lines_tab_comp.lines_tab,'Style','pushbutton','String','Export to XML','units','normalized','pos',[0.35 0.1 0.15 0.15],'callback',{@export_line_callback,main_figure});
uicontrol(lines_tab_comp.lines_tab,'Style','pushbutton','String','Import from XML','units','normalized','pos',[0.5 0.1 0.15 0.15],'callback',{@import_line_xml_callback,main_figure});



%set(findall(lines_tab_comp.lines_tab, '-property', 'Enable'), 'Enable', 'off');
setappdata(main_figure,'Lines_tab',lines_tab_comp);

end

function draw_line_callback(~,~,main_figure)
curr_disp=getappdata(main_figure,'Curr_disp');
curr_disp.CursorMode='Draw Line';
setappdata(main_figure,'Curr_disp',curr_disp);
end


function tog_line(~,~,main_figure)
update_lines_tab(main_figure);
display_lines(main_figure)
end

function offset_line_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');

curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find(layer.Frequencies==curr_disp.Freq);

lines_tab_comp=getappdata(main_figure,'Lines_tab');

if isempty(layer.Lines)
    return;
end

line_offset=layer.Lines(get(lines_tab_comp.tog_line,'value'));
line_offset.Tag='Offset';

layer.Transceivers(idx_freq).set_transducer_depth_from_line(line_offset);

display_offset_echogram(main_figure);
update_lines_tab(main_figure);
display_lines(main_figure);
end

function remove_offset_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');

curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find(layer.Frequencies==curr_disp.Freq);
layer.Transceivers(idx_freq).reset_transducer_depth();
if ~isempty(layer.Lines)
    idx_line=strcmpi([layer.Lines(:).Tag],'Offset');
    if ~isempty(idx_line)       
        layer.Lines(idx_line).Tag='';
    end
end
update_lines_tab(main_figure);
display_lines(main_figure);

end

function display_offset_callback(~,~,main_figure)

display_offset_echogram(main_figure);

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

function change_time_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');

lines_tab_comp=getappdata(main_figure,'Lines_tab');

h_diff=sscanf(get(lines_tab_comp.time_h_diff,'string'),'%20d:%20d:%20d');


if length(h_diff)==3
    sgn=sign(h_diff(1));
    if sgn==0
        sgn=1;
    end
    UTC_diff=sgn*(abs(h_diff(1))+abs(h_diff(2))/60+abs(h_diff(3))/(60*60));
else
    UTC_diff=0;
end

if ~isempty(layer.Lines)
    if isnumeric(UTC_diff)
        if ~isnan(UTC_diff)
            layer.Lines(get(lines_tab_comp.tog_line,'value')).change_time(UTC_diff);
        end
    end
    setappdata(main_figure,'Layer',layer);
    update_lines_tab(main_figure)
    display_lines(main_figure);
else
    return
end
end

function change_range_callback(src,~,main_figure)
layer=getappdata(main_figure,'Layer');

lines_tab_comp=getappdata(main_figure,'Lines_tab');

if ~isempty(layer.Lines)
    if isnumeric(str2double(get(src,'string')))
        if ~isnan(get(src,'string'))
            layer.Lines(get(lines_tab_comp.tog_line,'value')).change_range(str2double(get(src,'string')))
        end
    end
    setappdata(main_figure,'Layer',layer);
    update_lines_tab(main_figure)
    display_lines(main_figure);
else
    return
end
end






