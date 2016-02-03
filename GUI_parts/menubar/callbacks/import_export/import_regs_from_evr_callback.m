function import_regs_from_evr_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);

[Filename,PathToFile]= uigetfile({fullfile(layer.PathToFile,'*.evr')}, 'Pick a .evr','MultiSelect','off');
if ~ischar(Filename)
    return;
end

regions=create_regions_from_evr(fullfile(PathToFile,Filename),layer.Transceivers(idx_freq).Data.Range,layer.Transceivers(idx_freq).Data.Time);
if ~isempty(regions)
    layer.Transceivers(idx_freq).add_region(regions);
    setappdata(main_figure,'Layer',layer);
    update_display(main_figure,0);
end

end