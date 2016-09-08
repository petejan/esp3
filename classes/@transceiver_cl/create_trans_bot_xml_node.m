function docNode=create_trans_bot_xml_node(trans_obj,docNode,file_id)

p = inputParser;
addRequired(p,'trans_obj',@(obj) isa(obj,'transceiver_cl'));
addRequired(p,'docNode',@(docnode) isa(docNode,'org.apache.xerces.dom.DocumentImpl'));

parse(p,trans_obj,docNode);


time=trans_obj.Data.Time;
bottom_file=docNode.getDocumentElement;

bottom_node = docNode.createElement('bottom_line');
bottom_node.setAttribute('Freq',num2str(trans_obj.Config.Frequency,'%.0f'));
bottom_node.setAttribute('ChannelID',deblank(trans_obj.Config.ChannelID));

idx_ping=find(file_id==trans_obj.Data.FileId);

time_str=datestr(time(idx_ping),'yyyymmddHHMMSSFFF ');
time_str=time_str';
time_str=time_str(:)';

range_str=sprintf('%.4f ',trans_obj.get_bottom_range(idx_ping));
tag_str=sprintf('%.0f ',trans_obj.Bottom.Tag(idx_ping));

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

