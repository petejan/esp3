function display_sliced_transect_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');

if isempty(layer)
return;
end
    
curr_disp=getappdata(main_figure,'Curr_disp');
hfigs=getappdata(main_figure,'ExternalFigures');


idx_freq=find_freq_idx(layer,curr_disp.Freq);
trans_obj=layer.Transceivers(idx_freq);

[output,~]=trans_obj.slice_transect2D('Reference','Surface');

new_fig=figure();
echo=imagesc(output.cell_dist_start,output.cell_range_start,10*log10(output.cell_abscf));
grid on;
colormap jet;
set(echo,'AlphaData',double(output.cell_vbscf>0));
grid on;
colormap jet;
axis ij
xlabel('Distance (meters)');
ylabel('Range (meters)')


hfigs=[hfigs new_fig];
setappdata(main_figure,'ExternalFigures',hfigs);
grid on;


end