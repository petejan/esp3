
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
                idx_nan=find(isnan(obj.Lat)+isnan(obj.Long)+isnan(obj.Time))>0;
                
                obj.Long(idx_nan)=nan;
                obj.Lat(idx_nan)=nan;
                obj.Time(idx_nan)=nan;
                
                [~,idx_sort]=sort(obj.Time);
                
                obj.Long=obj.Long(idx_sort);
                obj.Lat=obj.Lat(idx_sort);
                obj.Time=obj.Time(idx_sort);
                
                if length(obj.Long)>=2
                   
                    complex_pos=obj.Lat+1j*obj.Long;
                    
                    nb_points_filter=ceil(20/nanmean(diff(obj.Time*3600*24)));
                    complex_pos_fil=smooth(complex_pos,nb_points_filter,'rloess');
                    
                    d_dist=m_lldist(imag(complex_pos_fil),real(complex_pos_fil));
  
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
    end
    methods(Static)
        
        
        
        function obj=load_gps_from_file(fileN)
            try
                temp=csv2struct_perso(fileN);
                obj=gps_data_cl('Lat',temp.Lat,'Long',temp.Long,'Time',cellfun(@(x) datenum(x,'dd/mm/yyyy HH:MM:SS'),temp.Time));
            catch
                fprintf('Could not read gps file %s',fileN);
                obj=gps_data_cl.empty();
            end
        end
        
        
    end
    
end
