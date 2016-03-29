classdef curr_state_disp_cl <handle
    
    properties (SetObservable = true)
        Freq
        Fieldname
        Type
        Xaxes
        Cax
        DispBottom
        DispUnderBottom
        DispTracks
        DispBadTrans
        DispReg
        DispLines
        CursorMode
        Grid_x
        Grid_y
        CurrLayerID
        NbLayers
        Cmap
    end
    
    methods
        function obj =curr_state_disp_cl(varargin)
            
            p = inputParser;
            addParameter(p,'Freq',38000,@isnumeric);
            addParameter(p,'Fieldname','sv',@ischar);
            addParameter(p,'DispBottom','on',@ischar);
            addParameter(p,'DispUnderBottom','on',@ischar);
            addParameter(p,'DispTracks','on',@ischar);
            addParameter(p,'DispBadTrans','on',@ischar);
            addParameter(p,'DispReg','on',@ischar);
            addParameter(p,'DispLines','on',@ischar);
            addParameter(p,'Xaxes','Number',@ischar);
            addParameter(p,'Grid_x',100,@isnumeric);
            addParameter(p,'Grid_y',100,@isnumeric);
            addParameter(p,'CursorMode','Normal',@ischar);
            addParameter(p,'CurrLayerID',0,@isnumeric);
            addParameter(p,'NbLayers',0,@isnumeric);
            addParameter(p,'Cmap','jet',@ischar);
            
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
            [~,obj.Type]=init_cax(obj.Fieldname);
            obj.setTypeCax();
        end
        
        function setCax(obj,cax)
           if cax(2)>cax(1)
              obj.Cax=[cax(1) cax(2)]; 
           end
        end
        
    end
    
end

