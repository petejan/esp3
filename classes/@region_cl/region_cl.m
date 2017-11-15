
classdef region_cl
    properties
        Name
        ID
        Tag
        Origin
        Version=-1;
        Unique_ID
        Remove_ST
        Line_ID=[]
        Type
        Idx_pings
        Idx_r
        Shape
        X_cont
        Y_cont
        MaskReg
        Reference
        Cell_w
        Cell_w_unit
        Cell_h
        Cell_h_unit
        
    end
    
    
    
    methods
        function obj = region_cl(varargin)
            p = inputParser;
            
            check_type=@(type) ~isempty(strcmp(type,{'Data','Bad Data'}));
            check_shape=@(shape) ~isempty(strcmp(shape,{'Rectangular','Polygon'}));
            check_reference=@(ref) ~isempty(strcmp(ref,{'Surface','Bottom','Line'}));
            check_w_unit=@(unit) ~isempty(strcmp(unit,{'pings','meters'}));
            check_h_unit=@(unit) ~isempty(strcmp(unit,{'samples','meters'}));

            
            addParameter(p,'Name','',@ischar);
            addParameter(p,'ID',0,@isnumeric);
            addParameter(p,'Version',-1,@isnumeric);
            addParameter(p,'Unique_ID',generate_Unique_ID(),@ischar);
            addParameter(p,'Tag','',@ischar);
            addParameter(p,'Origin','',@ischar);
            addParameter(p,'Type','Data',check_type);
            addParameter(p,'Idx_pings',[],@isnumeric);
            addParameter(p,'Idx_r',[],@isnumeric);
            addParameter(p,'MaskReg',[],@(x) isnumeric(x)||islogical(x));
            addParameter(p,'X_cont',[],@(x) isempty(x)||iscell(x));
            addParameter(p,'Y_cont',[],@(x) isnumeric(x)||iscell(x));
            addParameter(p,'Shape','Rectangular',check_shape);
            addParameter(p,'Remove_ST',0,@(x) isnumeric(x)||islogical(x));
            addParameter(p,'Reference','Surface',check_reference);
            addParameter(p,'Cell_w',10,@isnumeric);
            addParameter(p,'Cell_h',10,@isnumeric);
            addParameter(p,'Cell_w_unit','pings',check_w_unit);
            addParameter(p,'Cell_h_unit','meters',check_h_unit);
            
            parse(p,varargin{:});
            
            results=p.Results;
            props=fieldnames(results);
            
            for i=1:length(props)
                obj.(props{i})=results.(props{i});
            end
            
            switch lower(obj.Shape)
                case 'rectangular'
                    obj.X_cont=[];
                    obj.Y_cont=[];
                case 'polygon'
                    if isempty(results.X_cont)&&~isempty(results.MaskReg)
                        [x,y]=cont_from_mask(results.MaskReg);
                        [x,y]=reduce_reg_contour(x,y,10);
                        if ~isempty(y)
                            obj.X_cont=x;
                            obj.Y_cont=y;
                            obj.MaskReg=(results.MaskReg);
                        else
                            obj.Shape='Rectangular';
                            obj.X_cont=[];
                            obj.Y_cont=[];
                            obj.MaskReg=[];
                        end
                        
                    elseif ~isempty(results.X_cont)&&isempty(results.MaskReg)
                        [obj.X_cont,obj.Y_cont]=reduce_reg_contour(obj.X_cont,obj.Y_cont,10);
                        obj.Shape='Polygon';
                        obj.X_cont=results.X_cont;
                        obj.Y_cont=results.Y_cont;
                        obj.MaskReg=(obj.create_mask());
                    end
                     
                otherwise
                    obj.Shape='Rectangular';
                    obj.X_cont=[];
                    obj.Y_cont=[];
                    obj.MaskReg=[];
            end
            
        end
        
        function str=print(obj)
            str=sprintf('Region %s %d Type: %s Reference: %s ',obj.Name,obj.ID,obj.Type,obj.Reference);
        end
        
        function str=tag_str(obj)
            str=sprintf('Region %d',obj.Unique_ID);
        end
        
        function str=disp_str(obj)
            str=sprintf('%s(%.0f)',obj.Tag,obj.ID);
        end
        
        function mask=create_mask(obj)
            nb_pings=length(obj.Idx_pings);
            nb_samples=length(obj.Idx_r);
            mask=ones(nb_samples,nb_pings);
            
            switch obj.Shape
                case 'Polygon'
                    mask=mask_from_cont(obj.X_cont,obj.Y_cont,nb_samples,nb_pings);
            end
            
            
        end
        
        function mask=get_mask(obj)
            nb_pings=length(obj.Idx_pings);
            nb_samples=length(obj.Idx_r);
            mask=ones(nb_samples,nb_pings);
            
            switch obj.Shape
                case 'Polygon'
                    mask=obj.MaskReg;
            end
            
        end
        function delete(obj)
            if ~isdeployed
                c = class(obj);
                disp(['ML object destructor called for class ',c])
            end
        end
        
        
        h_fig = display_region(reg_obj,trans_obj,varargin)
    end
end

