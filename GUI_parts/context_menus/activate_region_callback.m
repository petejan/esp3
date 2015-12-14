
function activate_region_callback(~,~,reg_curr,main_figure)

if strcmpi(get(gcf,'SelectionType'),'normal')
    layer=getappdata(main_figure,'Layer');
    curr_disp=getappdata(main_figure,'Curr_disp');
    
    idx_freq=find_freq_idx(layer,curr_disp.Freq);
    Transceiver=layer.Transceivers(idx_freq);
    
    [idx_reg,found]=find_reg_idx(Transceiver,reg_curr.Unique_ID);
    
    if found==0
        return;
    end
    
    region_tab_comp=getappdata(main_figure,'Region_tab');
    list_reg = list_regions(layer.Transceivers(idx_freq));
    axes_panel_comp=getappdata(main_figure,'Axes_panel');
    ah=axes_panel_comp.main_axes;
    clear_lines(ah);
    
    if ~isempty(list_reg)
        list_reg = list_regions(layer.Transceivers(idx_freq));
        
        if ~isempty(list_reg)
            if length(list_reg)>=idx_reg
                set(region_tab_comp.tog_reg,'value',idx_reg)
                set(region_tab_comp.tog_reg,'string',list_reg);
            else
                
                set(region_tab_comp.tog_reg,'value',1)
                set(region_tab_comp.tog_reg,'string',list_reg);
            end
        else
            set(region_tab_comp.tog_reg,'value',1)
            set(region_tab_comp.tog_reg,'string',{'--'});
        end
        setappdata(main_figure,'Layer',layer);
        update_regions_tab(main_figure);
        display_regions(main_figure);
    else
        return
    end
else
    return;
end


