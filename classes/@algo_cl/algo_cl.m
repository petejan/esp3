
classdef algo_cl
    properties
        Name
        Function
        Varargin
    end
    
    
    methods
        function obj = algo_cl(varargin)
            
            p = inputParser;
            
            check_function=@(func) isa(func,'function_handle');
            
            addParameter(p,'Name','',@ischar);
            addParameter(p,'Varargin',struct(),@isstruct);
            addParameter(p,'Function',@nan,check_function);
            
            
            parse(p,varargin{:});
            
            
            results=p.Results;
            props=fieldnames(results);
            
            for i=1:length(props)
                
                obj.(props{i})=results.(props{i});
                
            end
        end
        
        
        
    end
end

