classdef curr_state_disp_cl <handle
    
    properties (SetObservable = true)
        Freq
        Fieldname
        Type
        Xaxes
        Cax
        Fieldnames
        Caxes
        DispBottom
        DispUnderBottom
        DispBotHighVis
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
            addParameter(p,'DispBotHighVis','off',@ischar);
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
            
            obj.Fieldnames={'sv','sp','power','angle','target','snr','phi','y'};
            obj.Caxes={[-70 -35],[-60 -30],[-200 0],[-10 10],[-60 -30],[0 30],[-180 180],[-200 0]};

            obj.setTypeCax();
            
        end
    end
    
    methods
        
         function setCax(obj,cax)
             if cax(2)>cax(1)
                 idx_field=find(cellfun(@(x) ~isempty(strfind(obj.Fieldname,x)),obj.Fieldnames));
                 if ~isempty(idx_field)
                     obj.Caxes{idx_field}=cax;
                     obj.Cax=cax;
                 else
                     obj.Cax=cax;
                 end
             end
        end
          
        function setTypeCax(obj)
            [cax,obj.Type]=init_cax(obj.Fieldname);  
            
            idx_field=find(cellfun(@(x) ~isempty(strfind(obj.Fieldname,x)),obj.Fieldnames));
            if ~isempty(idx_field)
                obj.Cax=obj.Caxes{idx_field};
            else
                obj.Cax=cax;
            end
        end
        
        function setField(obj,field)
            obj.Fieldname=field;
            obj.setTypeCax();
        end
        
        function cax=getCaxField(obj,field)
           idx_field=find(cellfun(@(x) ~isempty(strfind(x,field)),obj.Fieldnames));
            if ~isempty(idx_field)
                cax=obj.Caxes{idx_field};
            else
                cax=obj.Cax;
            end
        end
                
    end
    
end

