
classdef bottom_cl 
    properties
        Origin
        Range
        Sample_idx
        Double_bot_mask
               
    end
    
    
    methods
        function obj = bottom_cl(varargin)
            p = inputParser;
            
            addParameter(p,'Origin','',@ischar);
            addParameter(p,'Range',[],@isnumeric);
            addParameter(p,'Sample_idx',[],@isnumeric);
            addParameter(p,'Double_bot_mask',[],@(x) isempty(x)||islogical(x));
          
            parse(p,varargin{:});
            
            results=p.Results;
            props=fieldnames(results);
            
            for i=1:length(props)        
                    obj.(props{i})=results.(props{i});
            end
            
        end
        
        function bot_out=concatenate_Bottom(bot_1,bot_2)

            n_r=[bot_1.Range(:); bot_2.Range(:)];
            n_s=[bot_1.Sample_idx(:); bot_2.Sample_idx(:)];
            
            bot_out=bottom_cl('Origin',bot_1.Origin,...
                'Range',n_r,...
                'Sample_idx',n_s);
        end
        
    end
end

