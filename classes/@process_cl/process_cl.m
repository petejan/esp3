
classdef process_cl < handle
    properties
        Freq
        Algo
    end
    
    methods
        function obj = process_cl(varargin)
            p = inputParser;
            
            check_algo_cl=@(algo_obj) isa(algo_obj,'algo_cl');
            
            addParameter(p,'Algo',algo_cl(),check_algo_cl);
            addParameter(p,'Freq',38000,@isnumeric);
            
            parse(p,varargin{:});
            
            results=p.Results;
            props=fieldnames(results);
            
            for i=1:length(props)
                obj.(props{i})=results.(props{i});
            end
            
        end
        function delete(obj)
            if ~isdeployed
                c = class(obj);
                disp(['ML object destructor called for class ',c])
            end
        end
    end
end

