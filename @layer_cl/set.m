function obj=set(obj,varargin)

p = inputParser;

check_gps_class=@(gps_data_obj) isa(gps_data_obj,'gps_data_cl');
check_env_class=@(env_data_obj) isa(env_data_obj,'env_data_cl');
check_ac_data_class=@(ac_data_obj) isa(ac_data_obj,'ac_data_cl');
check_layer_class=@(layer_obj) isa(layer_obj,'layer_cl');

addRequired(p,'obj',check_layer_class);
addParameter(p,'ID_num',obj.ID_num,@isnumeric);
addParameter(p,'Filename',obj.Filename);
addParameter(p,'PathToFile',obj.PathToFile,@ischar);
addParameter(p,'AcData',ac_data_cl(),check_ac_data_class);
addParameter(p,'Frequencies',obj.Frequencies,@isnumeric);
addParameter(p,'GPSData',obj.GPSData,check_gps_class);
 addParameter(p,'GPSDataPings',gps_data_cl(),check_gps_class);
addParameter(p,'EnvData',obj.EnvData,check_env_class);

parse(p,obj,varargin{:});

results=p.Results;
props=fieldnames(results);

for i=1:length(props)    
    obj.(props{i})=results.(props{i});   
end


end