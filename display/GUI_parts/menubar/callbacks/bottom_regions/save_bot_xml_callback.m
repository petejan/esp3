function save_bot_xml_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');
layer.write_bot_to_bot_xml();
curr_disp=getappdata(main_figure,'Curr_disp');
curr_disp.Bot_changed_flag=2;
setappdata(main_figure,'Curr_disp',curr_disp);
end