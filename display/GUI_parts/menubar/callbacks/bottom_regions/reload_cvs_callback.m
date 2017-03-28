function reload_cvs_callback(~,~,main_figure)
layers=getappdata(main_figure,'Layers');
app_path=getappdata(main_figure,'App_path');
choice = questdlg('WARNING: This will replace all CVS Regions?', ...
                'Bottom/Region',...
                'Yes','No', ...
                'No');

            switch choice
                case 'No'
                    return;      
            end
for i=1:length(layers)
    for uui=1:length(layers(i).Frequencies)
        layers(i).Transceivers(uui).rm_region_origin('esp2');
    end   
    layers(i).CVS_BottomRegions(app_path.cvs_root)
end
setappdata(main_figure,'Layers',layers);
display_bottom(main_figure);
display_regions(main_figure,'both');
set_alpha_map(main_figure);
set_alpha_map(main_figure,'main_or_mini','mini');
update_regions_tab(main_figure,1);
order_stacks_fig(main_figure);
update_reglist_tab(main_figure,[],0);
end