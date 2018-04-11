function load_lines_tab(main_figure,option_tab_panel)


lines_tab_comp.lines_tab=uitab(option_tab_panel,'Title','Lines');


list_lines={'--'};
utc_str='00:00:00';
dist_diff_str=0;
range_diff_str=0;

gui_fmt=init_gui_fmt_struct();

pos=create_pos_3(6,3,gui_fmt.x_sep,gui_fmt.y_sep,gui_fmt.txt_w,gui_fmt.box_w,gui_fmt.box_h);
p_button=pos{3,2}{1};


uicontrol(lines_tab_comp.lines_tab,gui_fmt.txtStyle,'String','Lines','Position',pos{1,2}{1});
lines_tab_comp.tog_line=uicontrol(lines_tab_comp.lines_tab,gui_fmt.popumenuStyle,...
    'String',list_lines,'Value',length(list_lines),'Position',pos{1,2}{2}+[0 0 2*gui_fmt.txt_w 0],'callback',{@tog_line,main_figure});

uicontrol(lines_tab_comp.lines_tab,gui_fmt.txtTitleStyle,'String','Offsets:','Position',pos{2,1}{1});
uicontrol(lines_tab_comp.lines_tab,gui_fmt.txtStyle,'String','Time (hh:mm:ss)','Position',pos{3,1}{1});
lines_tab_comp.time_h_diff=uicontrol(lines_tab_comp.lines_tab,gui_fmt.edtStyle,'position',pos{3,1}{2}+[0 0 gui_fmt.box_w 0],'string',utc_str,'callback',{@change_time_callback,main_figure});

uicontrol(lines_tab_comp.lines_tab,gui_fmt.txtStyle,'String','Distance(m)','Position',pos{4,1}{1});
lines_tab_comp.Dist_diff=uicontrol(lines_tab_comp.lines_tab,gui_fmt.edtStyle,'position',pos{4,1}{2},'string',dist_diff_str,'callback',{@change_dist_callback,main_figure});

uicontrol(lines_tab_comp.lines_tab,gui_fmt.txtStyle,'String','Vertical(m)','Position',pos{5,1}{1});
lines_tab_comp.Range_diff=uicontrol(lines_tab_comp.lines_tab,gui_fmt.edtStyle,'position',pos{5,1}{2},'string',range_diff_str,'callback',{@change_range_callback,main_figure});

p_button=pos{3,3}{1};
p_button(3)=gui_fmt.button_w;

str_delete='<HTML><center><FONT color="Red"><b>Delete</b></Font> ';
str_draw='<HTML><center><FONT color="Green"><b>Draw</b></Font> ';
uicontrol(lines_tab_comp.lines_tab,gui_fmt.pushbtnStyle,'String',str_draw,'pos',p_button,'callback',{@draw_line_callback,main_figure});
uicontrol(lines_tab_comp.lines_tab,gui_fmt.pushbtnStyle,'String',str_delete,'pos',p_button+[p_button(3) 0 0 0],'callback',{@delete_line_callback,main_figure});


gui_fmt.button_w=gui_fmt.button_w*2;
p_button=pos{4,3}{1};
p_button(3)=gui_fmt.button_w;
uicontrol(lines_tab_comp.lines_tab,gui_fmt.pushbtnStyle,'String','Import','pos',p_button,'callback',{@import_line_callback,main_figure});
uicontrol(lines_tab_comp.lines_tab,gui_fmt.pushbtnStyle,'String','Save to XML','pos',p_button+[p_button(3) 0 0 0],'callback',{@export_line_callback,main_figure});
uicontrol(lines_tab_comp.lines_tab,gui_fmt.pushbtnStyle,'String','Load from XML','pos',p_button+2*[p_button(3) 0 0 0],'callback',{@import_line_xml_callback,main_figure});

p_button=pos{5,3}{1};
p_button(3)=gui_fmt.button_w;
uicontrol(lines_tab_comp.lines_tab,gui_fmt.pushbtnStyle,'String','Use as Offset','pos',p_button,'callback',{@offset_line_callback,main_figure});
uicontrol(lines_tab_comp.lines_tab,gui_fmt.pushbtnStyle,'String','Disp. Offset','pos',p_button+[p_button(3) 0 0 0],'callback',{@display_offset_callback,main_figure});
uicontrol(lines_tab_comp.lines_tab,gui_fmt.pushbtnStyle,'String','Remove Offset','pos',p_button+2*[p_button(3) 0 0 0],'callback',{@remove_offset_callback,main_figure});


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
[trans_obj,~]=layer.get_trans(curr_disp);

lines_tab_comp=getappdata(main_figure,'Lines_tab');

if isempty(layer.Lines)
    return;
end

line_offset=layer.Lines(get(lines_tab_comp.tog_line,'value'));
line_offset.Tag='Offset';

trans_obj.set_transducer_depth_from_line(line_offset);

display_offset_echogram(main_figure);
update_lines_tab(main_figure);
display_lines(main_figure);
end

function remove_offset_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');

curr_disp=getappdata(main_figure,'Curr_disp');
[trans_obj,~]=layer.get_trans(curr_disp);

trans_obj.reset_transducer_depth();
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
nb_lines=numel(layer.Lines);
if ~isempty(layer.Lines)
    active_line=layer.Lines(nanmin(nb_lines,get(lines_tab_comp.tog_line,'value')));
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






