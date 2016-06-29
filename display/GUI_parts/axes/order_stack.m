function order_stack(echo_ax)

echo_im=findobj(echo_ax,'tag','echo');
bt_im=findobj(echo_ax,'tag','bad_transmits');
bottom_line=findobj(echo_ax,'tag','bottom');
regions=findobj(echo_ax,'tag','region','-and','visible','on');
region_text=findobj(echo_ax,'tag','region_text','-and','visible','on');
zoom_area=findobj(echo_ax,'tag','zoom_area');
tracks=findobj(echo_ax,'tag','tracks');

uistack(echo_im,'top');
uistack(bt_im,'top');
uistack(regions,'top');
uistack(region_text,'top');
uistack(bottom_line,'top');
uistack(tracks,'top');
uistack(zoom_area,'top');

end