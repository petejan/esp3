classdef curr_state_disp_cl <handle
    
    properties (SetObservable = true)
        Freq
        Fieldname
        Fieldnames
        Type
        Xaxes
        Cax     
        Caxes
        DispBottom
        DispUnderBottom
        UnderBotTransparency=90
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
        Font
        Bot_changed_flag%flag=0 nothing change flag=1 : changes made nothing saved; flag=2  changes made saved to the xml file; flag=3  changes made saved to db file
        UIupdate
        Proj
        Active_reg_ID=[]
        Active_line_ID=[]
        Reg_changed_flag %flag=0 nothing change flag=1 : changes made nothing saved; flag=2  changes made saved to the xml file; flag=3  changes made saved to db file
        R_disp=[1 inf];
    end
    
    methods
        function obj =curr_state_disp_cl(varargin)
            
            p = inputParser;
            addParameter(p,'Freq',38000,@isnumeric);
            addParameter(p,'Fieldname','sv',@ischar);
            addParameter(p,'DispBottom','on',@ischar);
            addParameter(p,'Proj','Lambert Conformal Conic',@ischar);
            addParameter(p,'DispBotHighVis','off',@ischar);
            addParameter(p,'DispUnderBottom','on',@ischar);
            addParameter(p,'DispTracks','on',@ischar);
            addParameter(p,'DispBadTrans','on',@ischar);
            addParameter(p,'DispReg','on',@ischar);
            addParameter(p,'DispLines','on',@ischar);
            addParameter(p,'Xaxes','pings',@ischar);
            addParameter(p,'Grid_x',100,@isnumeric);
            addParameter(p,'Grid_y',100,@isnumeric);
            addParameter(p,'CursorMode','Normal',@ischar);
            addParameter(p,'CurrLayerID',0,@isnumeric);
            addParameter(p,'NbLayers',0,@isnumeric);
            addParameter(p,'Bot_changed_flag',0,@isnumeric);
            addParameter(p,'Reg_changed_flag',0,@isnumeric);
            addParameter(p,'Cmap','ek60',@ischar);
            addParameter(p,'Font','default',@ischar);
            addParameter(p,'UIupdate',0,@isnumeric);
            addParameter(p,'UnderBotTransparency',90,@isnumeric);
            
            parse(p,varargin{:});
            results=p.Results;
            props=fieldnames(results);
            
            for i=1:length(props)
                obj.(props{i})=results.(props{i});
            end
            
            obj.Fieldnames={};
            obj.Caxes={};            
            obj.setTypeCax();
            
        end
    end
    
    methods
        
        function setCax(obj,cax)
            if cax(2)>cax(1)
                idx_field=find(cellfun(@(x) strcmpi(obj.Fieldname,x),obj.Fieldnames));
                
                if ~isempty(idx_field)
                    obj.Caxes{idx_field}=cax;
                    obj.Cax=cax;
                else
                    obj.Cax=cax;
                end
            end
        end
        
                
        function pointer=get_pointer(obj)
            %Choice of pointer being: ‘hand’, ‘hand1’, ‘hand2’, ‘closedhand’, ‘glass’, ‘glassplus’, ‘glassminus’, 
            %‘lrdrag’, ‘ldrag’, ‘rdrag’, ‘uddrag’, ‘udrag’, ‘ddrag’, ‘add’, ‘addzero’, ‘addpole’, ‘eraser’, 
            %‘help’, ‘modifiedfleur’, ‘datacursor’, ‘rotate’
            switch obj.CursorMode
                case 'Zoom In'
                    pointer='glassplus';
                case 'Zoom Out'
                    pointer='glassminus';
                case 'Bad Transmits'
                    pointer='lrdrag';
                case 'Edit Bottom'
                    pointer='crosshair';
                case 'Measure'
                    pointer='datacursor';
                case 'Create Region'
                    pointer='cross';
                case 'Draw Line'
                    pointer='addpole';
                case 'Erase Soundings'
                    pointer='eraser';
                case 'Normal'
                    pointer='arrow';
            end
        end
        
        function setTypeCax(obj)
            
            [cax,obj.Type]=init_cax(obj.Fieldname);
          
            idx_field=find(cellfun(@(x) strcmpi(obj.Fieldname,x),obj.Fieldnames));
            
            if ~isempty(idx_field)
                obj.Cax=obj.Caxes{idx_field};
            else
                obj.Caxes=[obj.Caxes cax];
                obj.Fieldnames=[obj.Fieldnames obj.Fieldname];
                obj.Cax=cax;
            end
        end
        
        function setField(obj,field)
            obj.Fieldname=field;
            obj.setTypeCax();
        end
        
        function cax=getCaxField(obj,field)
            idx_field=find(cellfun(@(x) strcmpi(field,x),obj.Fieldnames));
            if ~isempty(idx_field)
                cax=obj.Caxes{idx_field};
            else
                cax=obj.Cax;
            end
        end
        
        function delete(obj)
            
            if ~isdeployed
                c = class(obj);
                disp(['ML object destructor called for class ',c]);
            end
        end
        
    end
    
end

