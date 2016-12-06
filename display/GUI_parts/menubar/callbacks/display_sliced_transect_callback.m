function display_sliced_transect_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');

if isempty(layer)
return;
end
    
curr_disp=getappdata(main_figure,'Curr_disp');


idx_freq=find_freq_idx(layer,curr_disp.Freq);
trans_obj=layer.Transceivers(idx_freq);

[output_2D,~]=trans_obj.slice_transect2D('Reference','Surface');
idx_reg=trans_obj.list_regions_type('Data');
reg_tot=trans_obj.get_reg_spec(idx_reg);               
output_1D=trans_obj.slice_transect('reg',reg_tot);

fig=figure();
plot(10*log10(output_1D.slice_abscf));
hold on;
plot(10*log10(nansum(output_2D.cell_abscf)));
grid on;
xlabel('Slice Number');
ylabel('Asbcf (dB)');
legend('1D','2D');

alpha_map=ones(size(output_2D.cell_vbscf));
alpha_map(10*log10(output_2D.cell_vbscf)<-70)=0;
new_echo_figure(main_figure);
echo=imagesc(output_2D.cell_dist_start,output_2D.cell_range_start,10*log10(output_2D.cell_vbscf));
grid on;
colormap jet;
set(echo,'AlphaData',double(output_2D.cell_vbscf>0));
grid on;
colormap jet;
axis ij
xlabel('Distance (meters)');
ylabel('Range (meters)')
caxis([-70 -35]);
set(echo,'alphadata',alpha_map)
grid on;

new_echo_figure(main_figure,'fig_handle',fig);


end