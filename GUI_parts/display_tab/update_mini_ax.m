function update_mini_ax(main_figure)

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

size_mini=[300 100];

idx_r_disp=round(linspace(1,nb_samples,size_mini(2)));
idx_p_disp=round(linspace(1,nb_pings,size_mini(1)));

data_disp=layer.Transceivers(idx_freq).Data.get_subdatamat('sv',idx_r_disp,idx_p_disp);
cla(display_tab_comp.mini_ax,'reset');
axes(display_tab_comp.mini_ax);
display_tab_comp.mini_echo=imagesc(pings,range,data_disp);
patch('Faces',f1,'Vertices',v1,'FaceColor','blue','FaceAlpha',.2);
set(display_tab_comp.mini_ax,'XTickLabels',[],'YTickLabels',[])
caxis([-80 -45]);
alpha_map=double(data_disp>=-80);
set(display_tab_comp.mini_echo,'AlphaData',double(alpha_map));
colormap(display_tab_comp.mini_ax,'jet');

end