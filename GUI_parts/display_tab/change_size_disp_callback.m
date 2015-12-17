function change_size_disp_callback(src,~,main_figure)
display_tab_comp=getappdata(main_figure,'Display_tab');
curr_disp=getappdata(main_figure,'Curr_disp');

val=str2double(get(src,'string'));
if val>0
   ww=str2double(get(display_tab_comp.width_disp,'string'));
   hh=str2double(get(display_tab_comp.height_disp,'string'));
   curr_disp.LayerMaxDispSize(2)=ww;
   curr_disp.LayerMaxDispSize(1)=hh;
   set(display_tab_comp.width_disp,'string',num2str(curr_disp.LayerMaxDispSize(2),'%.0f'));
   set(display_tab_comp.height_disp,'string',num2str(curr_disp.LayerMaxDispSize(1),'%.0f'));
else
    set(display_tab_comp.width_disp,'string',num2str(curr_disp.LayerMaxDispSize(2),'%.0f'));
    set(display_tab_comp.height_disp,'string',num2str(curr_disp.LayerMaxDispSize(1),'%.0f'));
    return;
end

setappdata(main_figure,'Curr_disp',curr_disp);
load_axis_panel(main_figure,0);


end