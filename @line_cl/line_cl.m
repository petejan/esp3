
classdef line_cl < handle
    properties
        Name
        ID
        Tag
        Type
        Range
        Time
        UTC_diff
        File_origin
    end
    
    
    methods
        
        function obj= line_cl(varargin)
            
            p = inputParser;
            addParameter(p,'Name','Line',@ischar);
            addParameter(p,'ID',unidrnd(2^64),@isnumeric);
            addParameter(p,'Tag','',@ischar);
            addParameter(p,'Type','',@ischar);
            addParameter(p,'Range',[],@isnumeric);
            addParameter(p,'Time',[],@isnumeric);
            addParameter(p,'UTC_diff',0,@isnumeric);
            addParameter(p,'File_origin',[],@ischar);
            
            parse(p,varargin{:});
            
            results=p.Results;
            props=fieldnames(results);
            
            for i=1:length(props)
                obj.(props{i})=results.(props{i});
            end
            
        end
        
        function change_time(obj,dt)
            obj.Time=obj.Time+dt/24-obj.UTC_diff/24;
            obj.UTC_diff=dt;
        end
                
    end
end
