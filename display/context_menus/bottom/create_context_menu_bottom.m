function create_context_menu_bottom(main_figure,bottom_line)

context_menu=uicontextmenu(main_figure);
bottom_line.UIContextMenu=context_menu;
uimenu(context_menu,'Label','Display Bottom Region','Callback',{@display_bottom_region_callback,main_figure});

end

function display_bottom_region_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
trans_obj=layer.Transceivers(idx_freq);

reg_wc=trans_obj.create_WC_region('y_min',5,...
    'Type','Data',...
    'Ref','Bottom',...
    'Cell_w',10,...
    'Cell_h',0.5,...
    'Cell_w_unit','pings',...
    'Cell_h_unit','meters');

reg_wc.display_region(trans_obj);



end