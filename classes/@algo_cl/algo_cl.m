
classdef algo_cl
    properties
        Name
        Function
        Varargin
    end
    
    
    methods
        function obj = algo_cl(varargin)
            
            p = inputParser;
            
            addParameter(p,'Name','',@ischar);
            addParameter(p,'Varargin',struct(),@isstruct);          
            parse(p,varargin{:});
                      
            results=p.Results;
            props=fieldnames(results);
            
            for i=1:length(props)   
                obj.(props{i})=results.(props{i}); 
            end
            
            obj.Function=init_func(obj.Name);
        end
        
        
        
    end
end

