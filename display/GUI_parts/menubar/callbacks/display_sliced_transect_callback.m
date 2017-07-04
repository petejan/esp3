function display_sliced_transect_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');

if isempty(layer)
return;
end
    
curr_disp=getappdata(main_figure,'Curr_disp');

Slice_w=curr_disp.Grid_x;
Slice_w_units=curr_disp.Xaxes;
Slice_h=curr_disp.Grid_y;

idx_freq=find_freq_idx(layer,curr_disp.Freq);
trans_obj=layer.Transceivers(idx_freq);



[output_2D_surf,~]=trans_obj.slice_transect2D('Reference','Surface','Slice_w',Slice_w,'Slice_w_units',Slice_w_units,'Slice_h',Slice_h);
[output_2D_bot,~]=trans_obj.slice_transect2D('Reference','bottom','Slice_w',Slice_w,'Slice_w_units',Slice_w_units,'Slice_h',Slice_h);

idx_reg=trans_obj.find_regions_type('Data');
reg_tot=trans_obj.get_reg_spec(idx_reg);               
[output_1D,~,~]=trans_obj.slice_transect('reg',reg_tot,'Shadow_zone',0,'Slice_w',Slice_w,'Slice_units',Slice_w_units);

fig_disp=new_echo_figure(main_figure,'Tag','Sliced Transect 1D');
ax=axes(fig_disp);
plot(ax,10*log10(output_1D.slice_abscf));
hold(ax,'on');
plot(ax,10*log10(output_1D.slice_abscf+output_1D.shadow_zone_slice_abscf));
plot(ax,10*log10(nansum(output_2D_surf.cell_abscf))+nansum(output_2D_bot.cell_abscf));
grid(ax,'on');
xlabel(ax,'Slice Number');
ylabel(ax,'Asbcf (dB)');
legend(ax,'1D','1D Shadow Zone','2D');

cax=curr_disp.getCaxField('sv');
[cmap,~,~,col_grid,~,~]=init_cmap(curr_disp.Cmap);

alpha_map=ones(size(output_2D_surf.cell_vbscf));
alpha_map(10*log10(output_2D_surf.cell_vbscf)<cax(1))=0;

fig_disp=new_echo_figure(main_figure,'Tag','Sliced Transect 2D (surface)','Name','Sliced Transect 2D (surface)');
ax=axes(fig_disp);
echo=pcolor(ax,output_2D_surf.cell_dist_start,output_2D_surf.cell_range_start,10*log10(output_2D_surf.cell_vbscf));
set(echo,'AlphaData',alpha_map,'facealpha','flat','edgecolor','none');
axis(ax,'ij');
grid(ax,'on');
set(ax,'GridColor',col_grid);
colormap(ax,cmap);caxis(cax);
xlabel(ax,curr_disp.Xaxes);
ylabel(ax,'Range (meters)')


alpha_map=ones(size(output_2D_bot.cell_vbscf));
alpha_map(10*log10(output_2D_bot.cell_vbscf)<cax(1))=0;

fig_disp=new_echo_figure(main_figure,'Tag','Sliced Transect 2D (bottom)','Name','Sliced Transect 2D (bottom)');
ax=axes(fig_disp);
echo=pcolor(ax,output_2D_bot.cell_dist_start,output_2D_bot.cell_range_start,10*log10(output_2D_bot.cell_vbscf));
set(echo,'AlphaData',alpha_map,'facealpha','flat','edgecolor','none');
axis(ax,'ij');
grid(ax,'on');
set(ax,'GridColor',col_grid);
colormap(ax,cmap);caxis(cax);
xlabel(ax,curr_disp.Xaxes);
ylabel(ax,'Range (meters)')





end