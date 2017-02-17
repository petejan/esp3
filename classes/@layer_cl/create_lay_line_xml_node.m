function docNode=create_lay_line_xml_node(layer_obj,docNode)

p = inputParser;
addRequired(p,'layer_obj',@(obj) isa(obj,'layer_cl'));
addRequired(p,'docNode',@(docnode) isa(docNode,'org.apache.xerces.dom.DocumentImpl'));

parse(p,layer_obj,docNode);

lines=layer_obj.Lines;

for i=1:length(lines)
    line_xml.Tag=lines(i).Tag;
    line_xml.Time=lines(i).Time;
    line_xml.Type=lines(i).Type;
    line_xml.UTC_diff=lines(i).UTC_diff;
    line_xml.Dist_diff=lines(i).Dist_diff;
    line_xml.File_origin=lines(i).File_origin;
    line_xml.Dr=lines(i).Dr;
    line_xml.Range=lines(i).Range;
    line_xml.ID=lines(i).ID;
    docNode=create_line_xml_node(docNode,line_xml);
end

end

