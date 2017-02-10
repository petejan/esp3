
classdef gps_data_cl
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
            
            if ~isempty(p.Results.Lat)
                results=p.Results;
                props=fieldnames(results);
                
                for i=1:length(props)
                    if isprop(obj,props{i})
                        if size(results.(props{i}),2)==1
                            obj.(props{i})=results.(props{i});
                        else
                            obj.(props{i})=results.(props{i})';
                        end
                    end
                end
                
                obj.Long(obj.Long<0)=obj.Long(obj.Long<0)+360;
                idx_nan=find(isnan(obj.Lat)+isnan(obj.Long))>0;
                
                obj.Long(idx_nan)=nan;
                obj.Lat(idx_nan)=nan;
                
                [~,idx_sort]=sort(obj.Time);
                
                obj.Long=obj.Long(idx_sort);
                obj.Lat=obj.Lat(idx_sort);
                obj.Time=obj.Time(idx_sort);
                
                if length(obj.Long)>=2
                    
                    d_dist=m_lldist(obj.Lat,obj.Long);
                    
                    d_dist(isnan(d_dist))=0;
                    dist_disp=[0;cumsum(d_dist)]*1000;%In meters!!!!!!!!!!!!!!!!!!!!!
                    
                    obj.Dist=dist_disp;
                else
                    obj.Dist=zeros(size(obj.Lat));
                end
                
                if size(obj.Dist,2)>1
                    obj.Dist=obj.Dist';
                end
            else
                nb_pings=length(p.Results.Time);
                obj.Long=zeros(nb_pings,1);
                obj.Lat=zeros(nb_pings,1);
                obj.Time=p.Results.Time;
                obj.Dist=zeros(nb_pings,1);
                obj.NMEA='';
            end
            
            
        end
        
        
        function gps_data_out=concatenate_GPSData(gps_data_1,gps_data_2)
            Long_tot=[gps_data_1.Long(:); gps_data_2.Long(:)];
            Lat_tot=[gps_data_1.Lat(:); gps_data_2.Lat(:)];
            Time_tot=[gps_data_1.Time(:); gps_data_2.Time(:)];
            [Time_tot_s,idx_sort]=sort(Time_tot);
            Lat_tot_s=Lat_tot(idx_sort);
            Long_tot_s=Long_tot(idx_sort);
            
            gps_data_out=gps_data_cl('Lat',Lat_tot_s,...
                'Long',Long_tot_s,...
                'Time',Time_tot_s,...
                'NMEA',gps_data_1.NMEA);
        end
        
        function gps_data_out=clean_gps_track(gps_data)
            if isempty(gps_data)
                gps_data_out=gps_data;
                return;
            end
            if isempty(gps_data.Long)
                gps_data_out=gps_data;
                return;
            end
            [~,~,id_keep]=DouglasPeucker(gps_data.Long,gps_data.Lat,2*1e-6,0);
            gps_data_out=gps_data_cl('Lat',gps_data.Lat(id_keep),'Long',gps_data.Long(id_keep),'Time',gps_data.Time(id_keep),'NMEA',gps_data.NMEA);
        end
        
        function save_gps_to_file(obj,fileN,idx_pings)
            
            if isempty(idx_pings)
                idx_pings=1:length(obj.Lat);
            end
            
            idx_pings=intersect(idx_pings,find(~isnan(obj.Time(:))&~isnan(obj.Lat(:))&~isnan(obj.Long(:))));
            struct_obj.Lat=obj.Lat(idx_pings);
            struct_obj.Long=obj.Long(idx_pings);
            struct_obj.Time=cellfun(@(x) datestr(x,'dd/mm/yyyy HH:MM:SS'),(num2cell(obj.Time(idx_pings))),'UniformOutput',0);
            struct2csv(struct_obj,fileN);
            
        end
        
    end
    methods(Static)
        
        
        function obj=load_gps_from_file(fileN)
            [~,~,ext]=fileparts(fileN);
            switch ext
                case {'.csv','.txt'}
                    try
                        temp=csv2struct(fileN);
                        fields = isfield(temp,{'Lat','Long','Time'});
                        temp.Time=cellfun(@(x) strrep(x,'a.m.','AM'),temp.Time,'UniformOutput',0);
                        temp.Time=cellfun(@(x) strrep(x,'p.m.','PM'),temp.Time,'UniformOutput',0);
                        time_temp=cellfun(@(x) datenum(x,'dd/mm/yyyy HH:MM:SS AM'),temp.Time);
                        
                         if all(fields)
                            obj=gps_data_cl('Lat',temp.Lat,'Long',temp.Long,'Time',time_temp);
                        else
                            obj=gps_data_cl.empty();
                        end
                       
                    catch
                        fprintf('Could not read gps file %s',fileN);
                        obj=gps_data_cl.empty();
                    end
                    
                case '.mat'
                    gps_data=load(fileN);
                    fields = isfield(gps_data,{'Lat','Long','Time'});
                    if all(fields)
                        obj=gps_data_cl('Lat',gps_data.Lat,'Long',gps_data.Long,'Time',gps_data.Time);
                    else
                        obj=gps_data_cl.empty();
                    end
            end
        end
        
        
        
        
    end
    
end
