function update_mini_ax(main_figure)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
mini_axes_comp=getappdata(main_figure,'Mini_axes');

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
set(mini_axes_comp.mini_ax,'units','pixels');
temp_size=get(mini_axes_comp.mini_ax,'position');
size_mini=temp_size(3:4);
set(mini_axes_comp.mini_ax,'units','normalized');
idx_r_disp=unique(round(linspace(1,nb_samples,size_mini(2))));
idx_p_disp=unique(round(linspace(1,nb_pings,size_mini(1))));
data=layer.Transceivers(idx_freq).Data.get_subdatamat(idx_r_disp,idx_p_disp,'field',curr_disp.Fieldname);    

switch lower(deblank(curr_disp.Fieldname))
    case {'y','y_imag','y_real'}
        data_disp=10*log10(abs(data));
    case {'power','powerdenoised','powerunmatched'}
        data(data<=0)=nan;
        data_disp=10*log10(data);
    otherwise
        data_disp=data;
end

data_disp=single(data_disp);

patch_col='b';
 
set(mini_axes_comp.mini_ax,'Xlim',[pings(1) pings(end)],'Ylim',[range(1) range(end)])
set(mini_axes_comp.mini_echo,'XData',pings,'YData',range,'CData',data_disp);
set(mini_axes_comp.patch_obj,'Faces',f1,'Vertices',v1,'FaceColor',patch_col,'EdgeColor',patch_col,'LineWidth',2);
update_grid_mini_ax(main_figure);
set_alpha_map(main_figure,'main_or_mini','mini');
set(findall(set(findall(mini_axes_comp.mini_ax, '-property', 'Enable'), 'Enable', 'on'), '-property', 'Enable'), 'Enable', 'on')

end