function save_bot_reg_xml_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');
layer.write_reg_to_reg_xml();
layer.write_bot_to_bot_xml()
curr_disp=getappdata(main_figure,'Curr_disp');
curr_disp.Bot_changed_flag=2;
curr_disp.Reg_changed_flag=2;
setappdata(main_figure,'Curr_disp',curr_disp);
end