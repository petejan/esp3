function order_stack(echo_ax)

echo_im=findobj(echo_ax,'tag','echo');
bt_im=findobj(echo_ax,'tag','bad_transmits');
lines=findobj(echo_ax,'Type','Line','-not','tag','region','-not','tag','region_cont');
regions_cont=findobj(echo_ax,'tag','region_cont','-and','visible','on');
regions=findobj(echo_ax,'tag','region','-and','visible','on');
region_text=findobj(echo_ax,'tag','region_text','-and','visible','on');
zoom_area=findobj(echo_ax,'tag','zoom_area');

uistack([region_text;lines;zoom_area;regions;regions_cont;bt_im;echo_im],'top');

end