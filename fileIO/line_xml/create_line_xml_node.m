function docNode=create_line_xml_node(docNode,line_xml)

p = inputParser;
addRequired(p,'docNode',@(docnode) isa(docNode,'org.apache.xerces.dom.DocumentImpl'));
addRequired(p,'line_xml',@(x) isstruct(x));

parse(p,docNode,line_xml);


line_file=docNode.getDocumentElement;

line_node = docNode.createElement('line');
line_node.setAttribute('type',line_xml.Type);
line_node.setAttribute('tag',line_xml.Tag);
line_node.setAttribute('file_origin',line_xml.File_origin);
line_node.setAttribute('dist_diff',num2str(line_xml.Dist_diff,'%.2f'));
line_node.setAttribute('utc_diff',num2str(line_xml.UTC_diff,'%.4f'));
line_node.setAttribute('id',num2str(line_xml.ID,'%.0f'));
line_node.setAttribute('dr',num2str(line_xml.Dr,'%.2f'));


time_str=datestr(line_xml.Time,'yyyymmddHHMMSSFFF ');
time_str=time_str';
time_str=time_str(:)';
range_str=sprintf('%.4f ',line_xml.Range);

range_node = docNode.createElement('range');
range_node.appendChild(docNode.createTextNode(range_str));

time_node = docNode.createElement('time');
time_node.appendChild(docNode.createTextNode(time_str));

line_node.appendChild(range_node);
line_node.appendChild(time_node);

line_file.appendChild(line_node);

end
