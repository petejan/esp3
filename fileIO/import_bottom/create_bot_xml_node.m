function docNode=create_bot_xml_node(docNode,bot_xml)

p = inputParser;
addRequired(p,'docNode',@(docnode) isa(docNode,'org.apache.xerces.dom.DocumentImpl'));
addRequired(p,'bot_xml',@(x) isstruct(x));

parse(p,docNode,bot_xml);


bottom_file=docNode.getDocumentElement;

bottom_node = docNode.createElement('bottom_line');
bottom_node.setAttribute('Freq',num2str(bot_xml.Infos.Freq,'%.0f'));
bottom_node.setAttribute('ChannelID',bot_xml.Infos.ChannelID);

time_str=datestr(bot_xml.Bottom.Time,'yyyymmddHHMMSSFFF ');
time_str=time_str';
time_str=time_str(:)';
range_str=sprintf('%.4f ',bot_xml.Bottom.Range);
tag_str=sprintf('%.0f ',bot_xml.Bottom.Tag);

range_node = docNode.createElement('range');
range_node.appendChild(docNode.createTextNode(range_str));

time_node = docNode.createElement('time');
time_node.appendChild(docNode.createTextNode(time_str));

tag_node = docNode.createElement('tag');
tag_node.appendChild(docNode.createTextNode(tag_str));
bottom_node.appendChild(range_node);
bottom_node.appendChild(time_node);
bottom_node.appendChild(tag_node);

bottom_file.appendChild(bottom_node);
end