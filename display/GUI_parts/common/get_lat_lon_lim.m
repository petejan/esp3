
function [lat_lim,lon_lim,lat,lon]=get_lat_lon_lim(obj)
        lat=cell(1,length(obj));
        lon=cell(1,length(obj));
        
        lat_lim=[nan nan];
        lon_lim=[nan nan];

switch class(obj)
    case 'layer_cl'
        lat=cell(1,length(obj));
        lon=cell(1,length(obj));
        
        lat_lim=[nan nan];
        lon_lim=[nan nan];
        for i=1:length(obj)
            lat{i}=obj(i).GPSData.Lat;
            lon{i}=obj(i).GPSData.Long;
            if ~isempty(lat{i})
                lat_lim(1)=nanmin(lat_lim(1),nanmin(lat{i}));
                lon_lim(1)=nanmin(lon_lim(1),nanmin(lon{i}));
                lat_lim(2)=nanmax(lat_lim(2),nanmax(lat{i}));
                lon_lim(2)=nanmax(lon_lim(2),nanmax(lon{i}));
            end
        end
    case {'mbs_cl' 'survey_cl'}
        for ii=1:length(obj)
            map_temp=map_input_cl.map_input_cl_from_obj(obj(ii));
            lat{ii}=[map_temp.SliceLat{:}];
            lon{ii}=[map_temp.SliceLong{:}];
            if ~isempty(lat{ii})
                lat_lim(1)=nanmin(lat_lim(1),nanmin(lat{ii}));
                lon_lim(1)=nanmin(lon_lim(1),nanmin(lon{ii}));
                lat_lim(2)=nanmax(lat_lim(2),nanmax(lat{ii}));
                lon_lim(2)=nanmax(lon_lim(2),nanmax(lon{ii}));
            end
        end
end

idx_empty=find(cellfun(@(x) isempty(x),lat));
lat(idx_empty)=[];
lon(idx_empty)=[];


end


