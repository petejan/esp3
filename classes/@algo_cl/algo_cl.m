
classdef algo_cl
    properties
        Name
        Function
        Varargin
        Varargout
    end
    
    
    methods
        function obj = algo_cl(varargin)
            
            p = inputParser;
            
            addParameter(p,'Name','',@ischar);
            addParameter(p,'Varargin',[],@(x) isstruct(x)||isempty(x));
            parse(p,varargin{:});
            
            results=p.Results;
            
            
            obj.Name=results.Name;
            
            
            obj.Function=init_func(obj.Name);
            if ~isempty(results.Varargin)
                obj.Varargin=results.Varargin;
            else
                obj.Varargin=init_varargin(obj.Name);
            end
            obj.Varargout=init_varargout(obj.Name);

        end
        
        
        
    end
end

