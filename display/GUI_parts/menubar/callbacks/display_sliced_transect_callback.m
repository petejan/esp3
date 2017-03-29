function display_sliced_transect_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');

if isempty(layer)
return;
end
    
curr_disp=getappdata(main_figure,'Curr_disp');


idx_freq=find_freq_idx(layer,curr_disp.Freq);
trans_obj=layer.Transceivers(idx_freq);

[output_2D,~]=trans_obj.slice_transect2D('Reference','Surface');
idx_reg=trans_obj.find_regions_type('Data');
reg_tot=trans_obj.get_reg_spec(idx_reg);               
output_1D=trans_obj.slice_transect('reg',reg_tot,'Shadow_zone',1);

fig_disp=new_echo_figure(main_figure,'Tag','Sliced Transect 1D');
ax=axes(fig_disp);
plot(ax,10*log10(output_1D.slice_abscf));
hold(ax,'on');
plot(ax,10*log10(output_1D.slice_abscf+output_1D.shadow_zone_slice_abscf));
plot(ax10*log10(nansum(output_2D.cell_abscf)));
grid(ax,'on');
xlabel(ax,'Slice Number');
ylabel(ax,'Asbcf (dB)');
legend(ax,'1D','1D Shadow Zone','2D');

cax=curr_disp.getCaxField('sv');
[cmap,~,~,col_grid,~,~]=init_cmap(curr_disp.Cmap);
alpha_map=ones(size(output_2D.cell_vbscf));
alpha_map(10*log10(output_2D.cell_vbscf)<cax(1))=0;

fig_disp=new_echo_figure(main_figure,'Tag','Sliced Transect 2D');
ax=axes(fig_disp);
echo=pcolor(ax,output_2D.cell_dist_start,output_2D.cell_range_start,10*log10(output_2D.cell_vbscf));
set(echo,'AlphaData',alpha_map,'facealpha','flat','edgecolor','none');
axis(ax,'ij');
grid(ax,'on');
set(ax,'GridColor',col_grid);
colormap(ax,cmap);caxis(cax);
xlabel(ax,'Distance (meters)');
ylabel(ax,'Range (meters)')



end