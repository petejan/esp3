function obj=map_input_cl_from_layers(layers,varargin)
            
            p = inputParser;
            check_layer_cl=@(x) isempty(x)|isa(x,'layer_cl');
            addRequired(p,'Layers',check_layer_cl);
            addParameter(p,'Proj','lambert',@ischar);
            addParameter(p,'AbscfMax',0.001,@isnumeric);
            addParameter(p,'Rmax',30,@isnumeric);
            addParameter(p,'SliceSize',100,@isnumeric);
            addParameter(p,'Freq',38000,@isnumeric);
            addParameter(p,'Coast',1,@isnumeric);
            
            parse(p,layers,varargin{:});
            
            obj=map_input_cl();
            obj.Trip=cell(1,length(layers));
            obj.Filename=cell(1,length(layers));
            obj.Snapshot=zeros(1,length(layers));
            obj.Stratum=cell(1,length(layers));
            obj.Transect=zeros(1,length(layers));
            obj.Lat=cell(1,length(layers));
            obj.Lon=cell(1,length(layers));
            obj.SliceLat=cell(1,length(layers));
            obj.SliceLon=cell(1,length(layers));
            obj.SliceAbscf=cell(1,length(layers));
            
            
            obj.Proj=p.Results.Proj;
            obj.AbscfMax=p.Results.AbscfMax;
            obj.Rmax=p.Results.Rmax;
            obj.Coast=p.Results.Coast;
            obj.Depth_Contour=p.Results.Depth_Contour;
            
            for i=1:length(layers)
                obj.Filename{i}=layers(i).Filename{1};
                obj.Lat{i}=layers(i).GPSData.Lat;
                obj.Lon{i}=layers(i).GPSData.Long;
                
                if ~isempty(layers(i).SurveyData)
                    obj.Trip{i}=layers(i).SurveyData.Voyage;
                    obj.Snapshot(i)=layers(i).SurveyData.Snapshot;
                    obj.Stratum{i}=layers(i).SurveyData.Stratum;
                    obj.Transect(i)=layers(i).SurveyData.Transect;
                else
                    obj.Trip{i}='';
                end
                
                [idx_freq,found]=find_freq_idx(layers(i),p.Results.Freq);
                
                if found==0
                    continue;
                end
                
                idx_reg=1:length(layers(i).Transceivers(idx_freq).Regions);
                reg=layers(i).Transceivers(idx_freq).get_reg_spec(idx_reg);
                
                output=layers(i).Transceivers(idx_freq).slice_transect('reg',reg,'Slice_w',p.Results.SliceSize,'Slice_units','pings');
                obj.SliceLat{i}=output.slice_lat_esp2;
                obj.SliceLon{i}=output.slice_lon_esp2;
                obj.SliceAbscf{i}=output.slice_abscf;
            end
            
            
            
            obj.LatLim=[nan nan];
            obj.LonLim=[nan nan];
            for it=1:length(layers)
                obj.LatLim(1)=nanmin(obj.LatLim(1),nanmin(obj.Lat{it}));
                obj.LonLim(1)=nanmin(obj.LonLim(1),nanmin(obj.Lon{it}));
                obj.LatLim(2)=nanmax(obj.LatLim(2),nanmax(obj.Lat{it}));
                obj.LonLim(2)=nanmax(obj.LonLim(2),nanmax(obj.Lon{it}));
            end
            
        end