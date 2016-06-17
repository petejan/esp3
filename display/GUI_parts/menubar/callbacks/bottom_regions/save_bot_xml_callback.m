function save_bot_xml_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');
layer.write_bot_to_bot_xml()
end