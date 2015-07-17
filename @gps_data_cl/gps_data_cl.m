
classdef gps_data_cl <handle
    properties
        Lat
        Long
        Time
        Dist
        NMEA
    end
    
    methods
        function obj = gps_data_cl(varargin)
            p = inputParser;
            
            addParameter(p,'Lat',[],@isnumeric);
            addParameter(p,'Long',[],@isnumeric);
            addParameter(p,'Time',[],@isnumeric);
            addParameter(p,'NMEA','',@ischar);
            parse(p,varargin{:});
            
            results=p.Results;
            props=fieldnames(results);
            
            for i=1:length(props)  
                if size(results.(props{i}),2)==1
                    obj.(props{i})=results.(props{i});
                else
                    obj.(props{i})=results.(props{i})';
                end
            end
            
            if length(obj.Long)>=2
                dist_disp=[0;cumsum(m_lldist(obj.Long,obj.Lat))]*1000/1.852;
                obj.Dist=dist_disp;
            else
                obj.Dist=[];
            end
            
            if size(obj.Dist,2)>1
                obj.Dist=obj.Dist';
            end
            
        end
        
        
        function gps_data_out=concatenate_GPSData(gps_data_1,gps_data_2)
                gps_data_out=gps_data_cl('Lat',[gps_data_1.Lat; gps_data_2.Lat],...
                    'Long',[gps_data_1.Long; gps_data_2.Long],...
                    'Time',[gps_data_1.Time; gps_data_2.Time],...
                    'NMEA',gps_data_1.NMEA);
        end
        
        
    end
    
end
