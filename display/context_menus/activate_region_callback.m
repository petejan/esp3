
function activate_region_callback(~,~,reg_curr,main_figure)

    layer=getappdata(main_figure,'Layer');
    curr_disp=getappdata(main_figure,'Curr_disp');
    
switch curr_disp.Cmap
    
    case 'esp2'
        ac_data_col=[0 1 0];
        in_data_col=[1 0 0];
        bad_data_col=[0.5 0.5 0.5];
        txt_col='w';
    otherwise
        ac_data_col=[1 0 0];
        in_data_col=[0 1 0];
        bad_data_col=[0.5 0.5 0.5];
        txt_col='k';
end
    
    idx_freq=find_freq_idx(layer,curr_disp.Freq);
    trans_obj=layer.Transceivers(idx_freq);

    [idx_reg,found]=trans_obj.find_reg_idx(reg_curr.Unique_ID);
    
    if found==0
        return;
    end
    region_tab_comp=getappdata(main_figure,'Region_tab');

    axes_panel_comp=getappdata(main_figure,'Axes_panel');
    ah=axes_panel_comp.main_axes;
    
    reg_text=findobj(ah,'Tag','region_text');
    set(reg_text,'color',txt_col);
    
    reg_lines_ac=findobj(ah,{'Tag','region','-or','Tag','region_cont'},'-and','UserData',reg_curr.Unique_ID,'-and','Type','line');
    reg_lines_in=findobj(ah,{'Tag','region','-or','Tag','region_cont'},'-not','UserData',reg_curr.Unique_ID,'-and','Type','line');
    set(reg_lines_ac,'color',ac_data_col);
    set(reg_lines_in,'color',in_data_col);

    
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
        order_axes(main_figure);
        order_stacks_fig(main_figure);
    else
        return
    end



