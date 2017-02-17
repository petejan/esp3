function import_line_xml_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');

layer.add_lines_from_line_xml();

end