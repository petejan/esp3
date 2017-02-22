
classdef env_data_cl < handle
    properties
        Acidity=8;
        Depth=0;
        Salinity=35;
        SoundSpeed=1500
        Temperature=18
        SVP=[];
        DropKeelOffset=0;
        DropKeelOffsetIsManual=0;
        Latitude=nan;
        SoundVelocityProfile=[]
        SoundVelocitySource='';
        WaterLevelDraft=0;
        WaterLevelDraftIsManual=0;
        TransducerName='';
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
                if isnumeric(results.(props{i}))
                    obj.(props{i})=double(results.(props{i}));
                else
                    obj.(props{i})=(results.(props{i}));
                end
                
            end
            
        end
        function delete(obj)
            
            if ~isdeployed
                c = class(obj);
                disp(['ML object destructor called for class ',c])
            end
        end
        
        
        function  obj=set_svp(obj,depth,soundspeed)
            obj.SVP.depth=double(depth);
            obj.SVP.soundspeed=double(soundspeed);
        end
    end
end