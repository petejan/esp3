
classdef bottom_cl 
    properties
        Origin='';
        Sample_idx=[];
        Tag=[];
        Shifted=0;
        Version=-1;
    end
    
    
    methods
        function obj = bottom_cl(varargin)
            p = inputParser;
            
            addParameter(p,'Origin','',@ischar);
            addParameter(p,'Sample_idx',[],@isnumeric);
            addParameter(p,'Tag',[],@(x) isnumeric(x)||islogical(x));
            addParameter(p,'Shifted',0,@(x) isnumeric(x)); 
            addParameter(p,'Version',-1,@isnumeric);
          
            parse(p,varargin{:});
            
            results=p.Results;
            props=fieldnames(results);
            
            for i=1:length(props)        
                    obj.(props{i})=results.(props{i});
            end
            
            if isempty(obj.Tag)&&~isempty(obj.Sample_idx)
               obj.Tag=ones(size(obj.Sample_idx));
            end
            
        end
        
        function bot_out=concatenate_Bottom(bot_1,bot_2)
            
            if isempty(bot_1)
                bot_out=bot_2;
                return;
            elseif isempty(bot_2)
                bot_out=bot_1;
                return;
            end
                
            n_s=[bot_1.Sample_idx(:); bot_2.Sample_idx(:)];
            n_t=[bot_1.Tag(:); bot_2.Tag(:)];
            
            bot_out=bottom_cl('Origin',bot_1.Origin,....
                'Sample_idx',n_s,'Tag',n_t);
        end
        
    end
end

