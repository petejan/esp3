clear all;
close all;

dir_in='F:\Survey 2 trawl\';
xml_files=dir(fullfile(dir_in,'*.gpx'));
dir_out='F:\Survey 2 trawl_reformated\';

for ifile=1:length(xml_files)
    
    xml_file=fullfile(dir_in,xml_files(ifile).name);
    
    %<gpx version="1.1" creator="GDAL 1.11.3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ogr="http://osgeo.org/gdal" xmlns="http://www.topografix.com/GPX/1/1" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd">
    
    %<gpx version="1.1" creator="OpenCPN" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.topografix.com/GPX/1/1" xmlns:gpxx="http://www.garmin.com/xmlschemas/GpxExtensions/v3" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd" xmlns:opencpn="http://www.opencpn.org">
    
    
    docNode=xmlread(xml_file);
    waypointBookNode = docNode.getDocumentElement;
    gpxnode = waypointBookNode.getChildNodes;
    gpxnode.setAttribute('xmlns:opencpn','http://www.opencpn.org');
    node = gpxnode.getFirstChild;
    
    % <extensions>
    %       <opencpn:waypoint_range_rings visible="true" number="1" step="1" units="0" colour="#FF0000" />
    % </extensions>
    
    if ~isempty(strfind(xml_files(ifile).name,'trawl'))
        symbol='activepoint';
    else
        symbol='diamond';
    end
    
    
    
    while ~isempty(node)
        nodename=get(node,'NodeName');
        switch nodename
            case 'wpt'
                extensions_node=node.getFirstChild;
                
                while ~isempty(extensions_node)
                    nodename=get(extensions_node,'NodeName');
                    switch nodename
                        case 'extensions'
                            temp_node=extensions_node.getFirstChild;
                            while ~isempty(temp_node)
                                nodename=get(temp_node,'NodeName');
                                switch nodename
                                    case'ogr:station'
                                        name=get(temp_node,'TextContent');
                                        name_node = docNode.createElement('name');
                                        name_node.setTextContent(name);
                                        node.appendChild(name_node);
                                        type_node = docNode.createElement('type');
                                        type_node.setTextContent('WPT');
                                        node.appendChild(type_node);
                                        sym_node = docNode.createElement('sym');
                                        sym_node.setTextContent(symbol);
                                        node.appendChild(sym_node);
                                        node.removeChild(extensions_node);
                                        
                                        ext_node = docNode.createElement('extensions');
                                        range_ring_node=docNode.createElement('opencpn:waypoint_range_rings');
                                        range_ring_node.setAttribute('visible','true');
                                        range_ring_node.setAttribute('step','1');
                                        range_ring_node.setAttribute('units','0');
                                        range_ring_node.setAttribute('color','#FF0000');
                                        ext_node.appendChild(range_ring_node);
                                        node.appendChild(ext_node);
                                end
                                temp_node = temp_node.getNextSibling;
                            end
                    end
                    extensions_node = extensions_node.getNextSibling;
                end
                
        end
        node = node.getNextSibling;
    end
    
    
    xmlwrite(fullfile(dir_out,xml_files(ifile).name),docNode);
    
end