function set_full_res_callback(src,~,main_figure)
display_tab_comp=getappdata(main_figure,'Display_tab');
curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');
[idx_freq,~]=find_freq_idx(layer,curr_disp.Freq);


val=get(src,'value');
if val>0
    curr_disp.LayerMaxDispSize(2)=length(layer.Transceivers(idx_freq).Data.Number);
    curr_disp.LayerMaxDispSize(1)=length(layer.Transceivers(idx_freq).Data.Range);
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