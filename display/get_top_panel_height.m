function height_char=get_top_panel_height(nb)
tmp= uicontrol('Style', 'text','units','pixels','String','x');
h=get(tmp,'Extent');
gui_fmt=init_gui_fmt_struct();

height_char=(gui_fmt.y_sep*(nb+2)+gui_fmt.txt_h *nb)*h(4);

delete(tmp);

end