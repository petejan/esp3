function export_line_callback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');

if isempty(layer)
    return;
end

write_line_to_line_xml(layer);
disp('Lines Exported');

end
