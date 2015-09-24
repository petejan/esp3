
classdef survey_data_cl
    properties
        SurveyName
        Snapshot
        Stratum
        Transect
    end
    
    
    methods
        function obj = survey_data_cl(varargin)
            p = inputParser;
    
            ver_fmt=@(x) ischar(x)||isnumeric(x);
            
            addParameter(p,'SurveyName','',@ischar);
            addParameter(p,'Snapshot',[],@isnumeric);
            addParameter(p,'Stratum','',ver_fmt);
            addParameter(p,'Transect','',ver_fmt);
            
            
            parse(p,varargin{:});
            
            
            results=p.Results;
            props=fieldnames(results);
            
            for i=1:length(props)
                
                obj.(props{i})=results.(props{i});
                
            end
   
        end
        
    end
end