classdef curr_state_disp_cl <handle
    
    properties (SetObservable = true)
        Freq
        Fieldname
        Type
        Xaxes
        Cax
        DispBottom
        DispTracks
        DispBadTrans
        DispReg
        DispLines
        Grid_x
        Grid_y
    end
    
    methods
        function obj =curr_state_disp_cl(varargin)
            
            p = inputParser;
            addParameter(p,'Freq',38000,@isnumeric);
            addParameter(p,'Fieldname','power',@ischar);
            addParameter(p,'Cax',[-100 -90],@ischar);
            addParameter(p,'DispBottom','on',@ischar);
            addParameter(p,'DispTracks','on',@ischar);
            addParameter(p,'DispBadTrans',true,@islogical);
            addParameter(p,'DispReg',true,@islogical);
            addParameter(p,'DispLines',true,@islogical);
            addParameter(p,'Xaxes','Number',@ischar);
            addParameter(p,'Grid_x',100,@isnumeric);
            addParameter(p,'Grid_y',100,@isnumeric);
            parse(p,varargin{:});
            results=p.Results;
            props=fieldnames(results);
            
            for i=1:length(props)
                obj.(props{i})=results.(props{i});
            end
            
            obj.setTypeCax();
            
        end
    end
    
    methods
        function setTypeCax(obj)
            [obj.Cax,obj.Type]=init_cax(obj.Fieldname);  
        end
        
        function setField(obj,field)
            obj.Fieldname=field;
            obj.setTypeCax();
        end
        
    end
    
end

