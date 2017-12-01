
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
        MaskReg
        Poly
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
            addParameter(p,'X_cont',[],@(x) isnumeric(x)||iscell(x));
            addParameter(p,'Y_cont',[],@(x) isnumeric(x)||iscell(x));
            addParameter(p,'Idx_r',[],@isnumeric);
            addParameter(p,'Idx_pings',[],@isnumeric);
            addParameter(p,'Poly',[],@(x) isempty(x)||isa(x,'polyshape'));
            addParameter(p,'MaskReg',[],@(x) isnumeric(x)||islogical(x));
            addParameter(p,'Shape','Rectangular',check_shape);
            addParameter(p,'Remove_ST',0,@(x) isnumeric(x)||islogical(x));
            addParameter(p,'Reference','Surface',check_reference);
            addParameter(p,'Cell_w',10,@isnumeric);
            addParameter(p,'Cell_h',10,@isnumeric);
            addParameter(p,'Cell_w_unit','pings',check_w_unit);
            addParameter(p,'Cell_h_unit','meters',check_h_unit);
            
            parse(p,varargin{:});
            
            results=p.Results;
            props=properties(obj);
            
            for i=1:length(props)
                if isfield(results,props{i})
                    obj.(props{i})=results.(props{i});
                end
            end
            
            switch lower(obj.Shape)
                case 'rectangular'
                    if ~isempty(obj.Idx_pings)
                        x_reg_rect=([obj.Idx_pings(1) obj.Idx_pings(end) obj.Idx_pings(end) obj.Idx_pings(1) obj.Idx_pings(1)]);
                        y_reg_rect=([obj.Idx_r(end) obj.Idx_r(end) obj.Idx_r(1) obj.Idx_r(1) obj.Idx_r(end)]);
                        obj.Poly=polyshape(x_reg_rect,y_reg_rect,'Simplify',false);
                        if ~obj.Poly.issimplified()
                            obj.Poly.simplify();
                        end
                    elseif ~isempty(results.Poly)
                        [xlim,ylim]=obj.Poly.boundingbox;
                        obj.Idx_pings=xlim(1):xlim(end);
                        obj.Idx_r=ylim(1):ylim(end);
                    end
                case 'polygon' 
                    if ~isempty(results.Poly)
                        obj.Poly=results.Poly;
                    elseif ~isempty(results.X_cont)
                        obj.Poly=polyshape(results.X_cont,results.Y_cont,'Simplify',false);                      
                    elseif ~isempty(results.MaskReg)
                        [x,y]=cont_from_mask(results.MaskReg);
                        obj.Poly=polyshape(x,y,'Simplify',false);
                    end
                    
                    if ~obj.Poly.issimplified()
                        obj.Poly.simplify();
                    end
                    [xlim,ylim]=obj.Poly.boundingbox;
                    obj.Idx_pings=xlim(1):xlim(end);
                    obj.Idx_r=ylim(1):ylim(end);
                    obj.MaskReg=mask_from_poly(obj.Poly);
                   
                otherwise
                    obj.Shape='Rectangular';
                    obj.MaskReg=[];
                    
                    if ~isempty(obj.Idx_pings)
                        x_reg_rect=([obj.Idx_pings(1) obj.Idx_pings(end) obj.Idx_pings(end) obj.Idx_pings(1) obj.Idx_pings(1)]);
                        y_reg_rect=([obj.Idx_r(end) obj.Idx_r(end) obj.Idx_r(1) obj.Idx_r(1) obj.Idx_r(end)]);
                        obj.Poly=polyshape(x_reg_rect,y_reg_rect,'Simplify',false);
                        if ~obj.Poly.issimplified()
                            obj.Poly.simplify();
                        end
                    end
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
            mask=true(nb_samples,nb_pings);
            
            switch obj.Shape
                case 'Polygon'
                    %mask=mask_from_cont(obj.X_cont,obj.Y_cont,nb_samples,nb_pings);
                    mask=mask_from_poly(obj.Poly);
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

