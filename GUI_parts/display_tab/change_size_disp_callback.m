function change_size_disp_callback(src,~,main_figure)
display_tab_comp=getappdata(main_figure,'Display_tab');
curr_disp=getappdata(main_figure,'Curr_disp');
axes_panel_comp=getappdata(main_figure,'Axes_panel');

val=str2double(get(src,'string'));

set(axes_panel_comp.axes_panel,'units','pixels');
pos_ax=get(axes_panel_comp.axes_panel,'position');
set(axes_panel_comp.axes_panel,'units','normalized');
outputsize=[nan nan];
outputsize(1)=nanmin(curr_disp.LayerMaxDispSize(1),round(pos_ax(4)));
outputsize(2)=nanmin(curr_disp.LayerMaxDispSize(2),round(pos_ax(3)));

if val>0
    ww=str2double(get(display_tab_comp.width_disp,'string'));
    hh=str2double(get(display_tab_comp.height_disp,'string'));
    curr_disp.LayerMaxDispSize(2)=ww;
    curr_disp.LayerMaxDispSize(1)=hh;
    outputsize(1)=nanmin(curr_disp.LayerMaxDispSize(1),round(pos_ax(4)));
    outputsize(2)=nanmin(curr_disp.LayerMaxDispSize(2),round(pos_ax(3)));
    set(display_tab_comp.width_disp,'string',num2str(outputsize(2),'%.0f'));
    set(display_tab_comp.height_disp,'string',num2str(outputsize(1),'%.0f'));
else
    set(display_tab_comp.width_disp,'string',num2str(outputsize(2),'%.0f'));
    set(display_tab_comp.height_disp,'string',num2str(outputsize(1),'%.0f'));
    return;
end

setappdata(main_figure,'Curr_disp',curr_disp);
load_axis_panel(main_figure,0);


end