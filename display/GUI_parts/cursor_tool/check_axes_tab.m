function is_axes_panel=check_axes_tab(main_figure)

echo_tab_panel=getappdata(main_figure,'echo_tab_panel');

if ~strcmpi(echo_tab_panel.SelectedTab.Tag,'axes_panel')
    is_axes_panel=0;
else
    is_axes_panel=1;
end


end