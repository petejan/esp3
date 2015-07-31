
classdef region_cl < handle
    properties 
        Name
        ID
        Tag
        Unique_ID
        Type
        Idx_pings
        Idx_r
        Shape
        Sv_reg
        X_cont
        Y_cont
        Reference
        Cell_w
        Cell_w_unit
        Cell_h
        Cell_h_unit
        Output
        
    end
    
    
    methods
        function obj = region_cl(varargin)
            p = inputParser;
            
            check_type=@(type) ~isempty(strcmp(type,{'Data','Bad Data'}));
            check_shape=@(shape) ~isempty(strcmp(shape,{'Rectangular','Polygon'}));
            check_reference=@(ref) ~isempty(strcmp(ref,{'Surface','Bottom'}));
            check_w_unit=@(unit) ~isempty(strcmp(unit,{'pings','meters'}));
            check_h_unit=@(unit) ~isempty(strcmp(unit,{'samples','meters'}));
            check_output=@(output) isempty(output)||isstruct(output);
            
            addParameter(p,'Name','',@ischar);
            addParameter(p,'ID',0,@isnumeric);
            addParameter(p,'Unique_ID',unidrnd(2^64),@isnumeric);
            addParameter(p,'Tag','UNC',@ischar);
            addParameter(p,'Type','Data',check_type);
            addParameter(p,'Idx_pings',[],@isnumeric);
            addParameter(p,'Idx_r',[],@isnumeric);
            addParameter(p,'Shape','Rectangular',check_shape);
            addParameter(p,'Sv_reg',[],@isnumeric);
            addParameter(p,'Reference','Surface',check_reference);
            addParameter(p,'Cell_w',5,@isnumeric);
            addParameter(p,'Cell_h',5,@isnumeric);
            addParameter(p,'Cell_w_unit','pings',check_w_unit);
            addParameter(p,'Cell_h_unit','meters',check_h_unit);
            addParameter(p,'Output',[],check_output)

            parse(p,varargin{:});
            
            results=p.Results;
            props=fieldnames(results);
            
            for i=1:length(props)
                obj.(props{i})=results.(props{i});
            end
            if isempty(obj.Sv_reg)
                obj.Shape='Rectangular';
            end
            
            switch obj.Shape
                case 'Rectangular'
                    obj.X_cont=[];
                    obj.Y_cont=[];
                case 'Polygon'
                    Mask=~isnan(obj.Sv_reg);Mask(1,:)=0;Mask(end,:)=0;Mask(:,1)=0;Mask(:,end)=0;
                    %Mask=ceil(filter2(ones(2,2),Mask,'same'));
                    C=contourc(double(Mask),[1 1]);
                    if ~isempty(C)
                        [x,y,~]=C2xyz(C);
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
        
        function mask=create_mask(obj,nb_samples,nb_pings)
            mask=zeros(nb_samples,nb_pings);

             switch obj.Shape
                case 'Rectangular'
                    mask(obj.Idx_r,obj.Idx_pings)=1;
                case 'Polygon'
                   ask(obj.Idx_r,obj.Idx_pings)=~isnan(obj.Sv_reg);
             end
                     
            
        end
        
          
    end
end

