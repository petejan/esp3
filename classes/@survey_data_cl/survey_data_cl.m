

classdef survey_data_cl
    properties
        Voyage
        SurveyName
        Snapshot
        Stratum
        Transect
        Comment
        StartTime
        EndTime
    end
    
    
    methods
        function obj = survey_data_cl(varargin)
            p = inputParser;
            
            ver_fmt=@(x) ischar(x)||isnumeric(x);
            
            addParameter(p,'SurveyName','',ver_fmt);
            addParameter(p,'Snapshot',0,@isnumeric);
            addParameter(p,'Stratum','',ver_fmt);
            addParameter(p,'Transect',0,@isnumeric);
            addParameter(p,'Comment','',ver_fmt);
            addParameter(p,'Voyage','',ver_fmt);
            addParameter(p,'StartTime',0,@isnumeric);
            addParameter(p,'EndTime',1,@isnumeric);      
            parse(p,varargin{:});
            
            results=p.Results;
            
            obj.Voyage=results.Voyage;
            obj.SurveyName=results.SurveyName;
            obj.Snapshot=results.Snapshot;
            
            if ~ischar(results.Stratum)
                obj.Stratum=num2str(results.Stratum,'%.0f');
            else
                obj.Stratum=results.Stratum;
            end
            
            if ~ischar(results.Comment)
                obj.Comment=num2str(obj.Comment);
            else
                obj.Comment=results.Comment;
            end
            
            obj.Transect=results.Transect;
            obj.StartTime=results.StartTime;
            obj.EndTime=results.EndTime;
            
            if isnumeric(obj.SurveyName)
                obj.SurveyName='';
            end
            
            if isnumeric(obj.Voyage)
                obj.Voyage='';
            end
            
            if isempty(obj.Snapshot)
                obj.Snapshot=0;
            end
            
            if isempty(obj.Transect)
                obj.Transect=0;
            end
            
            
        end
        
        function i_str=print_survey_data(obj)  
            i_str=sprintf('%s Snap %d, Strat. %s, Trans. %d',...
                obj.Voyage,obj.Snapshot,obj.Stratum,obj.Transect); 
            if obj.Snapshot==0&&strcmp(obj.Stratum,'')&&obj.Transect==0
                i_str='';
            end
        end
        
        
    end
end