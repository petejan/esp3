
classdef line_cl < handle
    properties
        Name
        ID
        Tag
        Type
        Range
        Time
        UTC_diff
        Dist_diff
        File_origin
        Dr=0;
    end
    
    
    methods
        
        function obj= line_cl(varargin)
            pause(1e-2);
            unique_ID=str2double(datestr(now,'yyyymmddHHMMSSFFF'));
            p = inputParser;
            addParameter(p,'Name','Line',@ischar);
            addParameter(p,'ID',unique_ID,@isnumeric);
            addParameter(p,'Tag','',@ischar);
            addParameter(p,'Type','',@ischar);
            addParameter(p,'Range',[],@isnumeric);
            addParameter(p,'Time',[],@isnumeric);
            addParameter(p,'UTC_diff',0,@isnumeric);
            addParameter(p,'Dist_diff',0,@isnumeric);
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
        
        function change_range(obj,dr)
            obj.Range=obj.Range+(dr-obj.Dr);
            obj.Dr=dr;
        end
        function delete(obj)
            if ~isdeployed
                c = class(obj);
                disp(['ML object destructor called for class ',c])
            end
        end
    end
end
