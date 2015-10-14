
classdef env_data_cl
    properties
        Acidity
        Depth
        Salinity
        SoundSpeed
        Temperature
        SVP
    end
    methods
        function obj = env_data_cl(varargin)
            p = inputParser;
            
            addParameter(p,'Acidity',8,@isnumeric);
            addParameter(p,'Depth',100,@isnumeric);
            addParameter(p,'Salinity',35,@isnumeric);
            addParameter(p,'Temperature',18,@isnumeric);
            addParameter(p,'SoundSpeed',1490,@isnumeric)
            addParameter(p,'SVP',struct('depth',[],'soundspeed',[]),@isnumeric);
            
            parse(p,varargin{:});
            
            
            results=p.Results;
            props=fieldnames(results);
            
            for i=1:length(props)
                
                obj.(props{i})=results.(props{i});
                
            end
            
        end
        
         
        function  obj=set_svp(obj,depth,soundspeed)
            obj.SVP.depth=depth;
            obj.SVP.soundspeed=soundspeed;      
        end
    end
end