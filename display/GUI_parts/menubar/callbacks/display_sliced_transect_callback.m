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


%idx_reg=trans_obj.find_regions_tag('E');
idx_reg=trans_obj.find_regions_type('Data');
%[output_2D_surf_old,~]=trans_obj.slice_transect2D('Reference','Surface','Slice_w',Slice_w,'Slice_w_units',Slice_w_units,'Slice_h',Slice_h,'regIDs',[trans_obj.Regions(idx_reg).Unique_ID]);
% [output_2D_bot,~]=trans_obj.slice_transect2D('Reference','bottom','Slice_w',Slice_w,'Slice_w_units',Slice_w_units,'Slice_h',Slice_h);

[output_2D_surf,~]=trans_obj.slice_transect2D_new_int('Reference','Surface','Slice_w',Slice_w,'Slice_w_units',Slice_w_units,'Slice_h',Slice_h,'RegInt',0);
[output_2D_bot,~]=trans_obj.slice_transect2D_new_int('Reference','Bottom','Slice_w',Slice_w,'Slice_w_units',Slice_w_units,'Slice_h',Slice_h,'RegInt',0);


reg_tot=trans_obj.get_reg_spec(idx_reg);
[output_1D,~,~]=trans_obj.slice_transect('reg',reg_tot,'Shadow_zone',1,'Slice_w',Slice_w,'Slice_units',Slice_w_units);

fig_disp=new_echo_figure(main_figure,'Tag','Sliced Transect 1D');
ax=axes(fig_disp);
plot(ax,output_1D.slice_time_start,10*log10(output_1D.slice_abscf),'k');
hold(ax,'on');
plot(ax,output_1D.slice_time_start,10*log10(output_1D.slice_abscf+output_1D.shadow_zone_slice_abscf),'b');
if ~isempty(output_2D_surf)
    plot(ax,nanmean(output_2D_surf.Time_S),10*log10(nansum(output_2D_surf.Sa_lin./output_2D_surf.Nb_good_pings_esp2)),'m');
end
if ~isempty(output_2D_bot)
    plot(ax,nanmean(output_2D_bot.Time_S),10*log10(nansum(output_2D_bot.Sa_lin./output_2D_bot.Nb_good_pings_esp2)),'r');
end
%plot(ax,(output_2D_surf_old.cell_time_start),10*log10(nansum(output_2D_surf_old.cell_abscf)),'g');
grid(ax,'on');
xlabel(ax,'Slice Number');
ylabel(ax,'Asbcf (dB)');
legend(ax,'1D','1D Shadow Zone','2D');

cax=curr_disp.getCaxField('sv');
[cmap,~,~,col_grid,~,~]=init_cmap(curr_disp.Cmap);



if ~isempty(output_2D_surf)
    y_disp=(output_2D_surf.Range_ref_min+output_2D_surf.Range_ref_max)/2;   
    alpha_map=ones(size(output_2D_surf.Sv_mean_lin));
    alpha_map(10*log10(output_2D_surf.Sv_mean_lin)<cax(1))=0;
    fig_disp=new_echo_figure(main_figure,'Tag','Sliced Transect 2D (surface)','Name','Sliced Transect 2D (surface)');
    ax=axes(fig_disp);
    echo=pcolor(ax,output_2D_surf.Dist_S,y_disp,10*log10(output_2D_surf.Sv_mean_lin));
    set(echo,'AlphaData',alpha_map,'facealpha','flat','alphadatamapping','none','edgecolor','none');
    axis(ax,'ij');
    grid(ax,'on');
    set(ax,'GridColor',col_grid);
    colormap(ax,cmap);caxis(cax);
    xlabel(ax,curr_disp.Xaxes);
    ylabel(ax,'Range (meters)')
end


if ~isempty(output_2D_bot)
    alpha_map=ones(size(output_2D_bot.Sv_mean_lin));
    alpha_map(10*log10(output_2D_bot.Sv_mean_lin)<cax(1))=0;
    y_disp=(output_2D_bot.Range_ref_min+output_2D_bot.Range_ref_max)/2;  
    fig_disp=new_echo_figure(main_figure,'Tag','Sliced Transect 2D (bottom)','Name','Sliced Transect 2D (bottom)');
    ax=axes(fig_disp);
    echo=pcolor(ax,output_2D_bot.Dist_S,y_disp,10*log10(output_2D_bot.Sv_mean_lin));
    set(echo,'AlphaData',alpha_map,'facealpha','flat','alphadatamapping','none','edgecolor','none');
    axis(ax,'ij');
    grid(ax,'on');
    set(ax,'GridColor',col_grid);
    colormap(ax,cmap);caxis(cax);
end
xlabel(ax,curr_disp.Xaxes);
ylabel(ax,'Range (meters)')



end