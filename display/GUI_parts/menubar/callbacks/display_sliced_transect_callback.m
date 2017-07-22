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


idx_reg=trans_obj.find_regions_type('Data');
%profile on;
[output_2D_surf,output_2D_bot,~,~]=trans_obj.slice_transect2D_new_int('Slice_w',Slice_w,'Slice_w_units',Slice_w_units,'Slice_h',Slice_h,'RegInt',0);

reg_tot=trans_obj.get_reg_spec(idx_reg);
[output_1D,~,~]=trans_obj.slice_transect('reg',reg_tot,'Shadow_zone',1,'Slice_w',Slice_w,'Slice_units',Slice_w_units);

fig_disp=new_echo_figure(main_figure,'Tag','Sliced Transect 1D');
ax=axes(fig_disp);
plot(ax,output_1D.slice_time_start,10*log10(output_1D.slice_abscf),'k');
hold(ax,'on');
plot(ax,output_1D.slice_time_start,10*log10(output_1D.slice_abscf+output_1D.shadow_zone_slice_abscf),'b');
if ~isempty(output_2D_surf)
    plot(ax,output_2D_surf.Time_S,10*log10(nansum(output_2D_surf.eint./output_2D_surf.Nb_good_pings_esp2)),'m');
end
if ~isempty(output_2D_bot)
    plot(ax,output_2D_bot.Time_S,10*log10(nansum(output_2D_bot.eint./output_2D_bot.Nb_good_pings_esp2)),'r');
end
% profile off;
% profile viewer;
%plot(ax,(output_2D_surf_old.cell_time_start),10*log10(nansum(output_2D_surf_old.cell_abscf)),'g');
grid(ax,'on');
xlabel(ax,'Slice Number');
ylabel(ax,'Asbcf (dB)');
legend(ax,'1D','1D Shadow Zone','2D');

reg_temp=region_cl();
if ~isempty(output_2D_surf)
    reg_temp.display_region(output_2D_surf,'main_figure',main_figure,'Name','Sliced Transect 2D (Surface Ref)');
end


if ~isempty(output_2D_bot)
    reg_temp.display_region(output_2D_bot,'main_figure',main_figure,'Name','Sliced Transect 2D (Bottom Ref)');
end




end