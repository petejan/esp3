function load_reg_from_rfile_callback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');

if layer.ID_num==0
    return;
end

[idx_38,~]=find_freq_idx(layer,38000);

regions = readEsp2regions(fullfile('E:\Docs\MATLAB\test_mbs','r0000165_b'),0);

layer.Transceivers(idx_38).add_region(regions);

setappdata(main_figure,'Layer',layer);
update_display(main_figure,0);

end