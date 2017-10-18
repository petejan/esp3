function order_stacks_fig(main_figure)
mini_axes_comp=getappdata(main_figure,'Mini_axes');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');
switch curr_disp.CursorMode
    case 'Normal'
        bt_on_top=0;
    otherwise
        bt_on_top=1;
end

order_stack(mini_axes_comp.mini_ax);
order_stack(axes_panel_comp.main_axes,'bt_on_top',bt_on_top);

end