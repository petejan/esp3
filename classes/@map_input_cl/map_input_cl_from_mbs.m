function obj=map_input_cl_from_mbs(mbs,varargin)

p = inputParser;
check_mbs_cl=@(x) isempty(x)|isa(x,'mbs_cl');
addRequired(p,'mbs',check_mbs_cl);
addParameter(p,'Proj','lambert',@ischar);
addParameter(p,'AbscfMax',0.001,@isnumeric);
addParameter(p,'Rmax',30,@isnumeric);
addParameter(p,'Freq',38000,@isnumeric);
addParameter(p,'Coast',1,@isnumeric);
addParameter(p,'Depth_Contour',500,@isnumeric);
parse(p,mbs,varargin{:});

obj=map_input_cl();
mbs_out=mbs.Output.slicedTransectSum.Data;
mbs_out_reg=mbs.Output.regionSum.Data;
mbs_head=mbs.Header;
nb_trans=size(mbs_out,1);
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

nb_trans=size(mbs_out,1);

obj.Snapshot=zeros(1,nb_trans);
obj.SliceLat=cell(1,nb_trans);
obj.SliceLon=cell(1,nb_trans);
obj.SliceAbscf=cell(1,nb_trans);

obj.LatLim=[nan nan];
obj.LonLim=[nan nan];

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
    
    idx_file=find(obj.Snapshot(i)==[mbs.Output.regionSum.Data{:,1}]...
        &strcmpi(obj.Stratum(i),{mbs.Output.regionSum.Data{:,2}})...
        &obj.Transect(i)==[mbs.Output.regionSum.Data{:,3}],1);
    if ~isempty(idx_file)
        obj.Filename{i}=mbs.Output.regionSum.Data{idx_file,4};
    end
    
end


end