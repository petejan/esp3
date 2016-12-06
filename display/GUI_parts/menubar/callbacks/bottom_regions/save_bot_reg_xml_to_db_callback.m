function save_bot_reg_xml_to_db_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');
layer.write_reg_to_reg_xml();
layer.write_bot_to_bot_xml();

layer.save_bot_reg_to_db();
end


