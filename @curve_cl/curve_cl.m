
classdef curve_cl
    properties
        XData=[];
        YData=[];
        Tag='';
        Xunit='';
        Yunit='';
        Name='';
    end
    
    
    methods
        function obj = curve_cl(varargin)
            p = inputParser;
            
            
            addParameter(p,'XData',[],@isnumeric);
            addParameter(p,'YData',[],@isnumeric);
            addParameter(p,'Tag','',@ischar);
            addParameter(p,'Xunit','',@ischar);
            addParameter(p,'Yunit','',@ischar);
            addParameter(p,'Name','',@ischar);
            
            parse(p,varargin{:});
            
            results=p.Results;
            props=fieldnames(results);
            
            for i=1:length(props)
                
                obj.(props{i})=results.(props{i});
                
            end
            
        end
 
    end
end


