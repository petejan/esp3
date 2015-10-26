function obj=map_input_cl_from_obj(Ext_obj,varargin)

p = inputParser;
check_layer_cl=@(x) isempty(x)|isa(x,'layer_cl')|isa(x,'mbs_cl');
addRequired(p,'Ext_obj',check_layer_cl);
addParameter(p,'Proj','lambert',@ischar);
addParameter(p,'AbscfMax',0.001,@isnumeric);
addParameter(p,'Rmax',30,@isnumeric);
addParameter(p,'SliceSize',100,@isnumeric);
addParameter(p,'Freq',38000,@isnumeric);
addParameter(p,'Coast',1,@isnumeric);
addParameter(p,'Depth_Contour',500,@isnumeric);

parse(p,Ext_obj,varargin{:});

switch class(Ext_obj)
    case 'layer_cl'
        layers=Ext_obj;
        nb_trans=length(layers);
    case 'mbs_cl'
        mbs=Ext_obj;
        mbs_out=mbs.Output.slicedTransectSum.Data;
        mbs_out_reg=mbs.Output.regionSum.Data;
        mbs_head=mbs.Header;
        nb_trans=size(mbs_out,1);
end


obj=map_input_cl();

obj.Trip=cell(1,nb_trans);
obj.Filename=cell(1,nb_trans);
obj.Snapshot=zeros(1,nb_trans);
obj.Stratum=cell(1,nb_trans);
obj.Transect=zeros(1,nb_trans);
obj.Lat=cell(1,nb_trans);
obj.Lon=cell(1,nb_trans);
obj.SliceLat=cell(1,nb_trans);
obj.SliceLon=cell(1,nb_trans);
obj.SliceAbscf=cell(1,nb_trans);
obj.Proj=p.Results.Proj;
obj.AbscfMax=p.Results.AbscfMax;
obj.Rmax=p.Results.Rmax;
obj.Coast=p.Results.Coast;
obj.Depth_Contour=p.Results.Depth_Contour;

obj.LatLim=[nan nan];
obj.LonLim=[nan nan];

switch class(Ext_obj)
    case 'mbs_cl'
        for i=1:nb_trans
            obj.Trip{i}=mbs_head.voyage;
            obj.SliceLat{i}=mbs_out{i,6};
            obj.SliceLon{i}=mbs_out{i,7};
            obj.SliceLon{i}(obj.SliceLon{i}<0)=obj.SliceLon{i}(obj.SliceLon{i}<0)+360;
            obj.SliceAbscf{i}=mbs_out{i,8};
            obj.Snapshot(i)=mbs_out{i,1};
            obj.Stratum{i}=mbs_out{i,2};
            obj.Transect(i)=mbs_out{i,3};
            obj.LatLim(1)=nanmin(obj.LatLim(1),nanmin(obj.SliceLat{i}));
            obj.LonLim(1)=nanmin(obj.LonLim(1),nanmin(obj.SliceLon{i}));
            obj.LatLim(2)=nanmax(obj.LatLim(2),nanmax(obj.SliceLat{i}));
            obj.LonLim(2)=nanmax(obj.LonLim(2),nanmax(obj.SliceLon{i}));
            
            idx_file=find(obj.Snapshot(i)==[mbs_out_reg{:,1}]...
                &strcmpi(obj.Stratum(i),{mbs_out_reg{:,2}})...
                &obj.Transect(i)==[mbs_out_reg{:,3}],1);
            if ~isempty(idx_file)
                obj.Filename{i}=mbs_out_reg{idx_file,4};
            end
            
        end
        
    case 'layer_cl'
        for i=1:nb_trans
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
            
            if p.Results.SliceSize>0
                idx_reg=1:length(layers(i).Transceivers(idx_freq).Regions);
                reg=layers(i).Transceivers(idx_freq).get_reg_spec(idx_reg);
                output=layers(i).Transceivers(idx_freq).slice_transect('reg',reg,'Slice_w',p.Results.SliceSize,'Slice_units','pings');
                obj.SliceLat{i}=output.slice_lat_esp2;
                obj.SliceLon{i}=output.slice_lon_esp2;
                obj.SliceAbscf{i}=output.slice_abscf;
            end
        end
        
        for it=1:nb_trans
            if ~isempty(obj.Lat{it})
                obj.LatLim(1)=nanmin(obj.LatLim(1),nanmin(obj.Lat{it}));
                obj.LonLim(1)=nanmin(obj.LonLim(1),nanmin(obj.Lon{it}));
                obj.LatLim(2)=nanmax(obj.LatLim(2),nanmax(obj.Lat{it}));
                obj.LonLim(2)=nanmax(obj.LonLim(2),nanmax(obj.Lon{it}));
            end
        end
end

[obj.LatLim,obj.LonLim]=ext_lat_lon_lim(obj.LatLim,obj.LonLim,0.1);


end