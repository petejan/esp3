
classdef survey_data_cl
    properties
        SurveyName
        Voyage
        Snapshot
        Stratum
        Transect
        VerticalSlice
    end
    
    
    methods
        function obj = survey_data_cl(varargin)
            p = inputParser;
            
            ver_fmt=@(x) ischar(x)||isnumeric(x);
            
            addParameter(p,'SurveyName','',@ischar);
            addParameter(p,'Snapshot',[],@isnumeric);
            addParameter(p,'Stratum','',ver_fmt);
            addParameter(p,'Transect','',ver_fmt);
            addParameter(p,'Voyage','',@ischar);
            addParameter(p,'VerticalSlice',500);
            
            parse(p,varargin{:});
            
           
            results=p.Results;
            props=fieldnames(results);
            
            for i=1:length(props)
                
                obj.(props{i})=results.(props{i});
                
            end
            
        end
        function i_str=print_survey_data(obj)

            if ischar(obj.Stratum)
                i_str=sprintf('%s Snap %d, Strat. %s, Trans. %d',...
                    obj.SurveyName,obj.Snapshot,obj.Stratum,obj.Transect);
            else
                i_str=sprintf('%s Snap %d, Strat. %d, Trans. %d',...
                   obj.SurveyName,obj.Snapshot,obj.Stratum,obj.Transect);
            end

        end
    end
end