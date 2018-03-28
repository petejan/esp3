function display_sliced_transect_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');

if isempty(layer)
    return;
end

curr_disp=getappdata(main_figure,'Curr_disp');

[trans_obj,idx_freq]=layer.get_trans(curr_disp);
curr_disp=init_grid_val(main_figure);
[Slice_w,Slice_h]=curr_disp.get_dx_dy();

Slice_w_units=curr_disp.Xaxes_current;

idx_reg=trans_obj.find_regions_type('Data');

%profile on;
sh_height=10;
show_status_bar(main_figure);
[output_2D_surf_tot,output_2D_bot_tot,~,~,~,output_2D_sh_tot,shadow_height_est_tot,idx_freq_out]=layer.multi_freq_slice_transect2D(...
    'idx_main_freq',idx_freq,'idx_sec_freq',idx_freq,...
    'Slice_w',Slice_w,'Slice_w_units',Slice_w_units,'Slice_h',Slice_h,...
    'RegInt',0,'Shadow_zone',1,'Shadow_zone_height',sh_height,'idx_regs',idx_reg,'load_bar_comp',getappdata(main_figure,'Loading_bar'));
hide_status_bar(main_figure);

output_2D_surf=output_2D_surf_tot{idx_freq==idx_freq_out};
output_2D_sh=output_2D_sh_tot{idx_freq==idx_freq_out};
output_2D_bot=output_2D_bot_tot{idx_freq==idx_freq_out};
shadow_height_est=shadow_height_est_tot{idx_freq==idx_freq_out};

surf_slice_int=nansum(output_2D_surf.eint);
good_pings_surf=nanmax(output_2D_surf.Nb_good_pings,[],1);
x_slice=output_2D_surf.Ping_S;
num_slice=size(output_2D_surf.eint,2);

if ~isempty(output_2D_bot)
    bot_slice_int=nansum(output_2D_bot.eint);
    good_pings_bot=nanmax(output_2D_bot.Nb_good_pings,[],1);
    x_slice=output_2D_bot.Ping_S;
else
    bot_slice_int=zeros(1,num_slice);
    good_pings_bot=[];
end

if ~isempty(output_2D_sh)
    sh_slice_int=nansum(output_2D_sh.eint).*shadow_height_est/sh_height;
    good_pings_sh=nanmax(output_2D_sh.Nb_good_pings,[],1);
    x_slice=output_2D_sh.Ping_S;
else
    sh_slice_int=zeros(1,num_slice);
    good_pings_sh=[];
end

good_pings=nanmax([good_pings_sh;good_pings_bot;good_pings_surf],[],1);

fig_disp=new_echo_figure(main_figure,'Tag','Sliced Transect 1D','Keep_old',1);
ax=axes(fig_disp);hold(ax,'on');grid(ax,'on');

plot(ax,x_slice,10*log10((surf_slice_int+bot_slice_int)./good_pings),'color',[0.8 0 0],'marker','o');
plot(ax,x_slice,10*log10((sh_slice_int+surf_slice_int+bot_slice_int)./good_pings),'color',[0 0.8 0],'marker','o');

xlabel(ax,'Ping Start');
ylabel(ax,'Asbcf (dB)');
legend(ax,'2D','2D Shadow Zone');

reg_temp=trans_obj.create_WC_region(...
    'Ref','Surface',...
    'Cell_w',Slice_w,...
    'Cell_h',Slice_h,...
    'Cell_w_unit',Slice_w_units,...
    'Cell_h_unit','meters');

if ~isempty(output_2D_surf)
    reg_temp.display_region(output_2D_surf,'main_figure',main_figure,'Name','Sliced Transect 2D (Surface Ref)');
end

reg_temp.Reference='Bottom';

if ~isempty(output_2D_bot)
    reg_temp.display_region(output_2D_bot,'main_figure',main_figure,'Name','Sliced Transect 2D (Bottom Ref)');
end




end