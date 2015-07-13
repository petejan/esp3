
classdef layer_cl < handle
    properties
        ID_num=0;
        Filename='';
        Filetype='';
        PathToFile='';
        Transceivers
        Frequencies
        GPSData
        EnvData
    end  
    
    
    methods
        function obj = layer_cl(varargin)
            p = inputParser;
            
            
            check_gps_class=@(gps_data_obj) isa(gps_data_obj,'gps_data_cl');
            check_env_class=@(env_data_obj) isa(env_data_obj,'env_data_cl');
            check_transceiver_class=@(transceiver_obj) isa(transceiver_obj,'transceiver_cl');
            
            addParameter(p,'ID_num',0,@isnumeric);
            addParameter(p,'Filename','Dummy Data',@(fname)(ischar(fname)||iscell(fname)));
            addParameter(p,'Filetype','EK60',@(ftype)(ischar(ftype)));
            addParameter(p,'PathToFile',pwd,@(fname)(ischar(fname)||iscell(fname)));
            addParameter(p,'Transceivers',transceiver_cl(),check_transceiver_class);
            addParameter(p,'Frequencies',38000,@isnumeric);
            addParameter(p,'GPSData',gps_data_cl(),check_gps_class);
            addParameter(p,'EnvData',env_data_cl(),check_env_class);
            
            parse(p,varargin{:});
            
            
            results=p.Results;
            props=fieldnames(results);
            
            for i=1:length(props)
                
                obj.(props{i})=results.(props{i});
                
            end
        end
        
        function layer_out=concatenate_Layer(layer_1,layer_2)
            
            layer_out=layer_cl('ID_num',layer_1.ID_num,...
			'Filename',[layer_1.Filename layer_2.Filename]...
                ,'Filetype',layer_1.Filetype,...
                'PathToFile',layer_1.PathToFile,...
                'Transceivers',concatenate_Transceivers(layer_1.Transceivers,layer_2.Transceivers),...
                'GPSData',concatenate_GPSData(layer_1.GPSData,layer_2.GPSData),...
                'Frequencies',layer_1.Frequencies);
   
        end
        
        
    end
end


