

classdef survey_data_cl
    properties
        Voyage
        SurveyName
        Snapshot
        Stratum
        Transect
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
            addParameter(p,'Voyage','',ver_fmt);
            addParameter(p,'StartTime',0,@isnumeric);
            addParameter(p,'EndTime',1,@isnumeric);      
            parse(p,varargin{:});
            
            results=p.Results;
            
            obj.Voyage=results.Voyage;
            obj.SurveyName=results.SurveyName;
            obj.Snapshot=results.Snapshot;
            obj.Stratum=results.Stratum;
            obj.Transect=results.Transect;
            obj.StartTime=results.StartTime;
            obj.EndTime=results.EndTime;
            
            if isnumeric(obj.Stratum)
                obj.Stratum=num2str(obj.Stratum,'%.0f');
            end
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