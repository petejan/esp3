function create_context_menu_mf_plot(main_figure,tab_tag)
layer=getappdata(main_figure,'Layer');
if isempty(layer)
    return;
end
multi_freq_disp_tab_comp=getappdata(main_figure,tab_tag);

axes_to_copy=multi_freq_disp_tab_comp.ax;
mf_plot_menu = uicontextmenu(ancestor(multi_freq_disp_tab_comp.multi_freq_disp_tab,'figure'));
uimenu(mf_plot_menu,'Label','Copy to clipboard','Callback',{@copy_plot_to_clipboard_callback,axes_to_copy,main_figure});

axes_to_copy.UIContextMenu=mf_plot_menu;

end

function copy_plot_to_clipboard_callback(~,~,axes_to_copy,main_figure)
    save_axes_to_png(main_figure,axes_to_copy,[],'-clipboard');
end