
classdef region_cl < handle
    properties 
        Name
        ID
        Tag
        Origin
        Unique_ID
        Remove_ST
        Type
        Idx_pings
        Idx_r
        Shape
        MaskReg
        X_cont
        Y_cont
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
            check_reference=@(ref) ~isempty(strcmp(ref,{'Surface','Bottom'}));
            check_w_unit=@(unit) ~isempty(strcmp(unit,{'pings','meters'}));
            check_h_unit=@(unit) ~isempty(strcmp(unit,{'samples','meters'}));
            
            addParameter(p,'Name','',@ischar);
            addParameter(p,'ID',0,@isnumeric);
            addParameter(p,'Unique_ID',unidrnd(2^64),@isnumeric);
            addParameter(p,'Tag','',@ischar);
            addParameter(p,'Origin','',@ischar);
            addParameter(p,'Type','Data',check_type);
            addParameter(p,'Idx_pings',[],@isnumeric);
            addParameter(p,'Idx_r',[],@isnumeric);
            addParameter(p,'Shape','Rectangular',check_shape);
            addParameter(p,'Remove_ST',0,@(x) isnumeric(x)||islogical(x));
            addParameter(p,'MaskReg',[],@(x) isnumeric(x)||islogical(x));
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
			
            if isempty(obj.MaskReg)
                obj.Shape='Rectangular';
            end
            
            switch obj.Shape
                case 'Rectangular'
                    obj.X_cont=[];
                    obj.Y_cont=[];
                case 'Polygon'
                    Mask=(obj.MaskReg);Mask(1,:)=0;Mask(end,:)=0;Mask(:,1)=0;Mask(:,end)=0;
                    [x,y]=cont_from_mask(Mask);
                    if ~isempty(y)
                        for i=1:length(x)
                            x{i}=x{i}-1;
                            y{i}=y{i}-1;
                        end
                        obj.X_cont=x;
                        obj.Y_cont=y;
                    else
                        obj.Shape='Rectangular';
                        obj.X_cont=[];
                        obj.Y_cont=[];
                    end
                otherwise
                    obj.Shape='Rectangular';
                    obj.X_cont=[];
                    obj.Y_cont=[];
            end

        end
        
        function str=print(obj)
            str=sprintf('Region %s %d Type: %s Reference: %s ',obj.Name,obj.ID,obj.Type,obj.Reference);
        end
        
        function mask=create_mask(obj,nb_samples,nb_pings)
            mask=zeros(nb_samples,nb_pings);

             switch obj.Shape
                case 'Rectangular'
                    mask(obj.Idx_r,obj.Idx_pings)=1;
                case 'Polygon'
                   mask(obj.Idx_r,obj.Idx_pings)=obj.MaskReg;
             end
                     
            
        end
        
          
    end
end

