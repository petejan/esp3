function set_caxis(~,~,main_figure)
display_tab_comp=getappdata(main_figure,'Display_tab');

layer=getappdata(main_figure,'Layer');

curr_disp=getappdata(main_figure,'Curr_disp');
[trans_obj,idx_freq]=layer.get_trans(curr_disp);

if isempty(idx_freq)
    return;
end

[idx_field,~]=find_field_idx(trans_obj.Data,curr_disp.Fieldname);
if isempty(idx_field)
    return;
end

cax=str2double(get([display_tab_comp.caxis_down display_tab_comp.caxis_up],'String'));
if cax(2)<cax(1)||isnan(cax(1))||isnan(cax(2))
    cax=curr_disp.Cax;
    set(display_tab_comp.caxis_up,'String',num2str(cax(2),'%.0f'));
    set(display_tab_comp.caxis_down,'String',num2str(cax(1),'%.0f'));
end

curr_disp.setCax(cax);

setappdata(main_figure,'Layer',layer);

end