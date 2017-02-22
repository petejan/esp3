
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
            obj.Varargin=init_varargin(obj.Name);
            if ~isempty(obj.Varargin)
                fields_in=fieldnames(obj.Varargin);
                for i=1:length(fields_in)
                    if isfield(results.Varargin,fields_in{i})
                        obj.Varargin.(fields_in{i})=results.Varargin.(fields_in{i});
                    end
                end
            end
            
            obj.Varargout=init_varargout(obj.Name);
            
        end
        function delete(obj)
            
            if ~isdeployed
                c = class(obj);
                disp(['ML object destructor called for class ',c])
            end
        end
        
        
    end
end

