function set_full_res_callback(src,~,main_figure)
display_tab_comp=getappdata(main_figure,'Display_tab');
curr_disp=getappdata(main_figure,'Curr_disp');

val=get(src,'value');

axes_panel_comp=getappdata(main_figure,'Axes_panel');

set(axes_panel_comp.axes_panel,'units','pixels');
pos_ax=get(axes_panel_comp.axes_panel,'position');
set(axes_panel_comp.axes_panel,'units','normalized');
outputsize=[nan nan];
outputsize(1)=nanmax(curr_disp.LayerMaxDispSize(1),round(pos_ax(4)));
outputsize(2)=nanmax(curr_disp.LayerMaxDispSize(2),round(pos_ax(3)));


if val>0
    curr_disp.LayerMaxDispSize(2)=outputsize(2);
    curr_disp.LayerMaxDispSize(1)=outputsize(1);
    set(display_tab_comp.width_disp,'Enable','off');
    set(display_tab_comp.height_disp,'Enable','off');
else
    ww=str2double(get(display_tab_comp.width_disp,'string'));
    hh=str2double(get(display_tab_comp.height_disp,'string'));
    curr_disp.LayerMaxDispSize(2)=ww;
    curr_disp.LayerMaxDispSize(1)=hh;
    set(display_tab_comp.width_disp,'Enable','on');
    set(display_tab_comp.height_disp,'Enable','on');
end

setappdata(main_figure,'Curr_disp',curr_disp);
load_axis_panel(main_figure,0);


end