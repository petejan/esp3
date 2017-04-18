
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
            addParameter(p,'File_origin',{''},@iscell);
            
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
        
        function line_out=concatenate_Lines(line_1,line_2)

            Time_tot=[line_1.Time(:)-line_1.UTC_diff/24; line_2.Time(:)-line_2.UTC_diff/24];
            Range_tot=[line_1.Range(:)-line_1.Dr; line_2.Range(:)-line_2.Dr];
            
            [Time_tot_s,idx_sort]=sort(Time_tot);
            
            Range_s=Range_tot(idx_sort);
            
            line_out=line_cl('Name',line_1.Name,...
            'ID',line_1.ID,...
            'Tag',line_1.Tag,...
            'Type',line_1.Type,...
            'Range',Range_s,...
            'Time',Time_tot_s,...
            'UTC_diff',0,...
            'Dist_diff',line_1.Dist_diff,...
            'File_origin',union(line_1.File_origin,line_2.File_origin),...
            'Dr',0);
        end
        
        function delete(obj)
            if ~isdeployed
                c = class(obj);
                disp(['ML object destructor called for class ',c])
            end
        end
        
        
    end
end
