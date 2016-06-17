
function activate_region_callback(src,evt,reg_curr,main_figure)

if strcmpi(get(gcf,'SelectionType'),'normal')
    layer=getappdata(main_figure,'Layer');
    curr_disp=getappdata(main_figure,'Curr_disp');
    
    idx_freq=find_freq_idx(layer,curr_disp.Freq);
    trans_obj=layer.Transceivers(idx_freq);
    
    [idx_reg,found]=trans_obj.find_reg_idx(reg_curr.Unique_ID);
    
    if found==0
        return;
    end
    region_tab_comp=getappdata(main_figure,'Region_tab');
    if get(region_tab_comp.tog_reg,'value')==idx_reg
        return;
    end
        axes_panel_comp=getappdata(main_figure,'Axes_panel');
    ah=axes_panel_comp.main_axes;
    reg_lines=findobj(ah,'Tag','region');
    
    for i_line=1:length(reg_lines)
        if reg_lines(i_line).UserData==reg_curr.Unique_ID
            col='r';
        else
            switch lower(reg_curr.Type)
                case 'data'
                    col='b';
                case 'bad data'
                    col=[0.5 0.5 0.5];
            end
        end
        set(reg_lines(i_line),'color',col);
    end
    
    
    list_reg = regions_to_str(layer.Transceivers(idx_freq));

    if ~isempty(list_reg)
        list_reg = regions_to_str(layer.Transceivers(idx_freq));
        
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
    else
        return
    end
else
    return;
end


