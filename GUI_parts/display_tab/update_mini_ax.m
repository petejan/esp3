function update_mini_ax(main_figure,new)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
display_tab_comp=getappdata(main_figure,'Display_tab');

axes_panel_comp=getappdata(main_figure,'Axes_panel');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
x_lim=get(axes_panel_comp.main_axes,'xlim');
y_lim=get(axes_panel_comp.main_axes,'ylim');

v1 = [x_lim(1) y_lim(1);x_lim(2) y_lim(1);x_lim(2) y_lim(2);x_lim(1) y_lim(2)];
f1=[1 2 3 4];
pings=layer.Transceivers(idx_freq).Data.get_numbers();
range=layer.Transceivers(idx_freq).Data.get_range();
nb_pings=length(pings);
nb_samples=length(range);
set(display_tab_comp.mini_ax,'units','pixels');
temp_size=get(display_tab_comp.mini_ax,'position');
size_mini=temp_size(3:4);
set(display_tab_comp.mini_ax,'units','normalized');
idx_r_disp=round(linspace(1,nb_samples,size_mini(2)));
idx_p_disp=round(linspace(1,nb_pings,size_mini(1)));

switch curr_disp.Fieldname
    case 'power'
        data_disp=10*log10(layer.Transceivers(idx_freq).Data.get_subdatamat(curr_disp.Fieldname,idx_r_disp,idx_p_disp));
        
    otherwise
        data_disp=layer.Transceivers(idx_freq).Data.get_subdatamat(curr_disp.Fieldname,idx_r_disp,idx_p_disp);
        
end

cla(display_tab_comp.mini_ax,'reset');
axes(display_tab_comp.mini_ax);
display_tab_comp.mini_echo=imagesc(pings,range,data_disp);
display_tab_comp.patch_obj=patch('Faces',f1,'Vertices',v1,'FaceColor','red','FaceAlpha',.2);
uistack(display_tab_comp.patch_obj,'top');
set(display_tab_comp.patch_obj,'ButtonDownFcn',{@move_patch_mini_axis_grab,main_figure});
set(display_tab_comp.mini_echo,'ButtonDownFcn',{@move_patch_mini_axis,main_figure});
set(display_tab_comp.mini_ax,'XTickLabels',[],'YTickLabels',[]);


set_alpha_map(main_figure,'echo_ax',display_tab_comp.mini_ax,'echo_im',display_tab_comp.mini_echo);
setappdata(main_figure,'Display_tab',display_tab_comp);


end