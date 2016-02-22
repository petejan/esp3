

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
            
            addParameter(p,'SurveyName',' ',ver_fmt);
            addParameter(p,'Snapshot',0,@isnumeric);
            addParameter(p,'Stratum',' ',ver_fmt);
            addParameter(p,'Transect',0,ver_fmt);
            addParameter(p,'Voyage',' ',ver_fmt);
            addParameter(p,'StartTime',0,@isnumeric);
            addParameter(p,'EndTime',1,@isnumeric);
            
            parse(p,varargin{:});
            
            results=p.Results;
            
            obj.Voyage=results.Voyage;
            obj.SurveyName=results.SurveyName;
            obj.Snapshot=results.Snapshot;
            obj.Stratum=results.Stratum;
            obj.Transect=results.Stratum;
            obj.StartTime=results.StartTime;
            obj.EndTime=results.EndTime;
            
            
        end
        function i_str=print_survey_data(obj)
                        
            if ~iscell(obj.Voyage)
                if ischar(obj.Stratum)
                    i_str=sprintf('%s Snap %d, Strat. %s, Trans. %d',...
                        obj.Voyage,obj.Snapshot,obj.Stratum,obj.Transect);
                else
                    i_str=sprintf('%s Snap %d, Strat. %d, Trans. %d',...
                        obj.Voyage,obj.Snapshot,obj.Stratum,obj.Transect);
                end
            else
                if ischar(obj.Stratum{1})
                    i_str=sprintf('%s Snap %d, Strat. %s, Trans. %d',...
                        obj.Voyage,obj.Snapshot,obj.Stratum,obj.Transect);
                else
                    i_str=sprintf('%s Snap %d, Strat. %d, Trans. %d',...
                        obj.Voyage,obj.Snapshot,obj.Stratum,obj.Transect);
                end
            end
            if ~isempty(strfind(i_str,'NaN'))
                i_str='';
            end
        end
        
      
        
        
    end
end