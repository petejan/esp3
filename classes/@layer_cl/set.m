function layer_obj=set(layer_obj,varargin)

p = inputParser;

check_gps_class=@(gps_data_obj) isa(gps_data_obj,'gps_data_cl');
check_env_class=@(env_data_obj) isa(env_data_obj,'env_data_cl');
check_layer_class=@(layer_obj) isa(layer_obj,'layer_cl');

addRequired(p,'layer_obj',check_layer_class);
addParameter(p,'Unique_ID',layer_obj.Unique_ID,@ischar);
addParameter(p,'Filename',layer_obj.Filename);
addParameter(p,'Frequencies',layer_obj.Frequencies,@isnumeric);
addParameter(p,'GPSData',layer_obj.GPSData,check_gps_class);
addParameter(p,'EnvData',layer_obj.EnvData,check_env_class);

parse(p,layer_obj,varargin{:});

results=p.Results;
props=fieldnames(results);

for i=1:length(props)    
    layer_obj.(props{i})=results.(props{i});   
end


end